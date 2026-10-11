-- ====================================================================
-- AI ORBIT — Migration 2: RLS Policies and Atomic Quota RPC
-- Enforces row-level security and atomic quota enforcement
-- ====================================================================

-- Enable RLS on all tables
ALTER TABLE public.ai_models ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.model_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_usage ENABLE ROW LEVEL SECURITY;

-- ---------------------------------------------------------------------
-- 1. ai_models RLS
-- Clients can read enabled models. Only service_role can modify.
-- ---------------------------------------------------------------------
CREATE POLICY "Anyone can view enabled models"
    ON public.ai_models FOR SELECT
    USING (enabled = true);

-- ---------------------------------------------------------------------
-- 2. ai_agents RLS
-- Clients can read agents. Only service_role can modify.
-- ---------------------------------------------------------------------
CREATE POLICY "Anyone can view agents"
    ON public.ai_agents FOR SELECT
    USING (true);

-- ---------------------------------------------------------------------
-- 3. conversations RLS
-- Authenticated users own their conversations.
-- ---------------------------------------------------------------------
CREATE POLICY "Users can view own conversations"
    ON public.conversations FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own conversations"
    ON public.conversations FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own conversations"
    ON public.conversations FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own conversations"
    ON public.conversations FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- ---------------------------------------------------------------------
-- 4. messages RLS
-- Users can view messages in their own conversations.
-- Users and edge functions can insert messages.
-- ---------------------------------------------------------------------
CREATE POLICY "Users can view messages in their conversations"
    ON public.messages FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.conversations c
            WHERE c.id = messages.conversation_id
            AND c.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert messages in their conversations"
    ON public.messages FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.conversations c
            WHERE c.id = messages.conversation_id
            AND c.user_id = auth.uid()
        )
    );

-- ---------------------------------------------------------------------
-- 5. model_runs RLS
-- Users can view their own telemetry.
-- Writes are locked down strictly: only service_role (Edge Function)
-- ---------------------------------------------------------------------
CREATE POLICY "Users can view own model runs"
    ON public.model_runs FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- Service role bypasses RLS by default in Supabase, but explicit policy ensures no client insert/update
-- Clients have NO insert/update/delete permissions on model_runs.

-- ---------------------------------------------------------------------
-- 6. user_usage RLS
-- Users can view their own usage and quota stats.
-- Only service_role can write/modify.
-- ---------------------------------------------------------------------
CREATE POLICY "Users can view own usage"
    ON public.user_usage FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);


-- ====================================================================
-- ATOMIC QUOTA AND RATE LIMIT RPC
-- Executed inside a single transaction with row locking
-- ====================================================================

CREATE OR REPLACE FUNCTION public.check_and_increment_quota(
    p_user_id UUID,
    p_daily_limit INT DEFAULT 50,
    p_rpm_limit INT DEFAULT 15
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_today DATE := CURRENT_DATE;
    v_current_daily_count INT := 0;
    v_recent_rpm_count INT := 0;
    v_allowed BOOLEAN := true;
    v_error_code TEXT := NULL;
    v_error_message TEXT := NULL;
    v_remaining INT := 0;
BEGIN
    -- 1. Check Rate Limit (RPM in the last 60 seconds from model_runs)
    SELECT count(*)
    INTO v_recent_rpm_count
    FROM public.model_runs
    WHERE user_id = p_user_id
      AND created_at >= (timezone('utc', now()) - INTERVAL '60 seconds');

    IF v_recent_rpm_count >= p_rpm_limit THEN
        RETURN jsonb_build_object(
            'allowed', false,
            'error_code', 'rate_limited',
            'error_message', 'Rate limit exceeded: Please wait a moment before sending more messages.',
            'daily_count', v_current_daily_count,
            'daily_limit', p_daily_limit,
            'rpm_count', v_recent_rpm_count,
            'rpm_limit', p_rpm_limit,
            'remaining_daily', 0
        );
    END IF;

    -- 2. Check and Increment Daily Quota atomically with row lock
    -- Lock row if exists or insert initial row
    INSERT INTO public.user_usage (user_id, period, request_count, token_count, updated_at)
    VALUES (p_user_id, v_today, 0, 0, timezone('utc', now()))
    ON CONFLICT (user_id, period) DO NOTHING;

    -- Select with FOR UPDATE to prevent race conditions across parallel requests
    SELECT request_count
    INTO v_current_daily_count
    FROM public.user_usage
    WHERE user_id = p_user_id AND period = v_today
    FOR UPDATE;

    -- Verify daily limit
    IF v_current_daily_count >= p_daily_limit THEN
        RETURN jsonb_build_object(
            'allowed', false,
            'error_code', 'quota_exhausted',
            'error_message', 'Daily quota reached for your orbit transmission tier.',
            'daily_count', v_current_daily_count,
            'daily_limit', p_daily_limit,
            'rpm_count', v_recent_rpm_count,
            'rpm_limit', p_rpm_limit,
            'remaining_daily', 0
        );
    END IF;

    -- Increment daily request counter
    UPDATE public.user_usage
    SET request_count = request_count + 1,
        updated_at = timezone('utc', now())
    WHERE user_id = p_user_id AND period = v_today;

    v_remaining := GREATEST(0, p_daily_limit - (v_current_daily_count + 1));

    RETURN jsonb_build_object(
        'allowed', true,
        'error_code', NULL,
        'error_message', NULL,
        'daily_count', v_current_daily_count + 1,
        'daily_limit', p_daily_limit,
        'rpm_count', v_recent_rpm_count,
        'rpm_limit', p_rpm_limit,
        'remaining_daily', v_remaining
    );
END;
$$;

-- Helper to record tokens after completion
CREATE OR REPLACE FUNCTION public.record_token_usage(
    p_user_id UUID,
    p_tokens INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.user_usage
    SET token_count = token_count + GREATEST(0, p_tokens),
        updated_at = timezone('utc', now())
    WHERE user_id = p_user_id AND period = CURRENT_DATE;
END;
$$;

-- Helper to update conversation updated_at automatically
CREATE OR REPLACE FUNCTION public.touch_conversation_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE public.conversations
    SET updated_at = timezone('utc', now())
    WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trg_messages_touch_conversation
AFTER INSERT ON public.messages
FOR EACH ROW
EXECUTE FUNCTION public.touch_conversation_timestamp();

-- ====================================================================
-- AI ORBIT — Migration 4: Planet-Themed Personas & Chat History
-- Replaces football personas with planet-specialist agents and establishes
-- per-planet conversation history with RLS and OpenRouter free model routing.
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. Ensure ai_agents has all required columns
-- --------------------------------------------------------------------
ALTER TABLE public.ai_agents ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE public.ai_agents ADD COLUMN IF NOT EXISTS icon TEXT;
ALTER TABLE public.ai_agents ADD COLUMN IF NOT EXISTS accent_color TEXT;
ALTER TABLE public.ai_agents ADD COLUMN IF NOT EXISTS specialty TEXT;
ALTER TABLE public.ai_agents ADD COLUMN IF NOT EXISTS preferred_model TEXT;
ALTER TABLE public.ai_agents ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active';

-- --------------------------------------------------------------------
-- 2. Upsert OpenRouter Free Models into ai_models
-- --------------------------------------------------------------------
INSERT INTO public.ai_models (id, provider, model_id, display_name, capabilities, max_output_tokens, context_window, rpm_limit, daily_limit, enabled, priority)
VALUES
    ('11111111-1111-1111-1111-111111111101', 'openrouter', 'meta-llama/llama-3.3-70b-instruct:free', 'Llama 3.3 70B Free', ARRAY['chat', 'planning', 'reasoning', 'high-context'], 4096, 131072, 20, 200, true, 1),
    ('11111111-1111-1111-1111-111111111102', 'openrouter', 'qwen/qwen-2.5-coder-32b-instruct:free', 'Qwen 2.5 Coder 32B Free', ARRAY['coding', 'debugging', 'architecture'], 4096, 131072, 20, 200, true, 2),
    ('11111111-1111-1111-1111-111111111103', 'openrouter', 'deepseek/deepseek-r1:free', 'DeepSeek R1 Free', ARRAY['reasoning', 'logic', 'math', 'analysis'], 4096, 131072, 20, 200, true, 3),
    ('11111111-1111-1111-1111-111111111104', 'openrouter', 'mistralai/mistral-small-24b-instruct-2501:free', 'Mistral Small 24B Free', ARRAY['creative', 'storytelling', 'ideation'], 4096, 131072, 20, 200, true, 4),
    ('11111111-1111-1111-1111-111111111105', 'openrouter', 'google/gemini-2.0-flash-exp:free', 'Gemini 2.0 Flash Free', ARRAY['research', 'science', 'fast'], 4096, 131072, 30, 300, true, 5),
    ('11111111-1111-1111-1111-111111111106', 'openrouter', 'meta-llama/llama-3.1-8b-instruct:free', 'Llama 3.1 8B Free', ARRAY['fast', 'simple-chat', 'fallback'], 4096, 131072, 30, 500, true, 6),
    ('11111111-1111-1111-1111-111111111107', 'openrouter', 'openrouter/free', 'OpenRouter Auto Free', ARRAY['chat', 'fallback', 'multi-agent'], 4096, 131072, 30, 500, true, 7)
ON CONFLICT (id) DO UPDATE SET
    provider = EXCLUDED.provider,
    model_id = EXCLUDED.model_id,
    display_name = EXCLUDED.display_name,
    capabilities = EXCLUDED.capabilities,
    enabled = EXCLUDED.enabled,
    priority = EXCLUDED.priority;

-- --------------------------------------------------------------------
-- 3. Upsert Planet-Themed AI Agents (Zero football metaphors)
-- --------------------------------------------------------------------
INSERT INTO public.ai_agents (id, slug, name, description, system_prompt, icon, accent_color, specialty, preferred_model, default_model_id, temperature, max_output_tokens, status)
VALUES
    (
        '22222222-2222-2222-2222-222222222201',
        'general',
        'Earth',
        'General assistant and planning/roadmaps',
        'You are Earth, a planetary intelligence specializing in general assistance, structured planning, and comprehensive strategic roadmaps. Maintain a grounded, calm cosmic perspective. Provide clear, well-organized, step-by-step guidance and practical solutions. Answer directly, accurately, and objectively without sports metaphors or extraneous thematic filler.',
        'public',
        '#00E5FF',
        'general assistant and planning/roadmaps',
        'meta-llama/llama-3.3-70b-instruct:free',
        '11111111-1111-1111-1111-111111111101',
        0.70,
        4096,
        'active'
    ),
    (
        '22222222-2222-2222-2222-222222222202',
        'coding',
        'Mars',
        'Coding, debugging, and systems architecture',
        'You are Mars, a senior software engineering intelligence specializing in coding, debugging, and systems architecture. Maintain a focused, technical tone. Deliver precise, production-grade code, optimal engineering patterns, and concrete bug fixes. Always format code using clean markdown blocks with language tags and explain technical trade-offs concisely. Do not use sports metaphors.',
        'code',
        '#FF5252',
        'coding and debugging',
        'qwen/qwen-2.5-coder-32b-instruct:free',
        '11111111-1111-1111-1111-111111111102',
        0.20,
        4096,
        'active'
    ),
    (
        '22222222-2222-2222-2222-222222222203',
        'creative',
        'Jupiter',
        'Creative writing, storytelling, and idea generation',
        'You are Jupiter, a creative luminary specializing in imaginative writing, storytelling, innovative brainstorming, and expressive communication. Maintain an expansive, inspiring voice. Craft vivid narratives, fresh ideas, and captivating prose tailored to the user''s intent. Answer with imaginative depth and originality without using sports metaphors.',
        'auto_awesome',
        '#B388FF',
        'creative writing and ideas',
        'mistralai/mistral-small-24b-instruct-2501:free',
        '11111111-1111-1111-1111-111111111104',
        0.85,
        4096,
        'active'
    ),
    (
        '22222222-2222-2222-2222-222222222204',
        'reasoning',
        'Saturn',
        'Deep reasoning, analytical deduction, and complex problem-solving',
        'You are Saturn, an analytical engine specializing in deep reasoning, formal deduction, and multi-step logic. Maintain a deliberate, rigorous approach. Break down complex problems step by step, evaluate premises, test edge cases, address counterarguments, and provide structured logical conclusions. Answer directly with intellectual rigor and no sports metaphors.',
        'psychology',
        '#FFD700',
        'deep reasoning and analysis',
        'deepseek/deepseek-r1:free',
        '11111111-1111-1111-1111-111111111103',
        0.10,
        4096,
        'active'
    ),
    (
        '22222222-2222-2222-2222-222222222205',
        'research',
        'Neptune',
        'Research synthesis, science, and explanations',
        'You are Neptune, an objective scientific research intelligence specializing in evidence synthesis, scientific explanations, and academic inquiries. Maintain intellectual clarity and honesty. Provide factual, well-structured explanations, distinguish verified consensus from emerging theories, explicitly state uncertainties, and never hallucinate citations or data. No sports metaphors.',
        'biotech',
        '#00E676',
        'research, science and explanations',
        'meta-llama/llama-3.3-70b-instruct:free',
        '11111111-1111-1111-1111-111111111101',
        0.30,
        4096,
        'active'
    ),
    (
        '22222222-2222-2222-2222-222222222206',
        'multi-agent',
        'Pluto',
        'Autonomous multi-agent constellation missions',
        'You are Pluto, the autonomous multi-agent constellation conductor. Orbit status: Standby for Phase 2 constellation deployment.',
        'hub',
        '#FF4081',
        'autonomous multi-agent constellation',
        'openrouter/free',
        '11111111-1111-1111-1111-111111111107',
        0.50,
        2048,
        'coming_soon'
    )
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    system_prompt = EXCLUDED.system_prompt,
    icon = EXCLUDED.icon,
    accent_color = EXCLUDED.accent_color,
    specialty = EXCLUDED.specialty,
    preferred_model = EXCLUDED.preferred_model,
    default_model_id = EXCLUDED.default_model_id,
    temperature = EXCLUDED.temperature,
    max_output_tokens = EXCLUDED.max_output_tokens,
    status = EXCLUDED.status;

-- --------------------------------------------------------------------
-- 4. Create chat_history Table with RLS
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.chat_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES public.ai_agents(id) ON DELETE CASCADE,
    agent_slug TEXT NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    session_id TEXT,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    model_used TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_chat_history_slug_user ON public.chat_history(agent_slug, user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_history_agent_id_user ON public.chat_history(agent_id, user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_history_slug_session ON public.chat_history(agent_slug, session_id, created_at DESC);

-- Enable RLS
ALTER TABLE public.chat_history ENABLE ROW LEVEL SECURITY;

-- Policies for Authenticated & Anonymous/Session Users
DROP POLICY IF EXISTS "Users can view own chat history" ON public.chat_history;
CREATE POLICY "Users can view own chat history"
    ON public.chat_history FOR SELECT
    USING (
        (auth.uid() IS NOT NULL AND auth.uid() = user_id)
        OR (session_id IS NOT NULL)
    );

DROP POLICY IF EXISTS "Users can insert own chat history" ON public.chat_history;
CREATE POLICY "Users can insert own chat history"
    ON public.chat_history FOR INSERT
    WITH CHECK (
        (auth.uid() IS NOT NULL AND auth.uid() = user_id)
        OR (auth.uid() IS NULL)
    );

DROP POLICY IF EXISTS "Users can delete own chat history" ON public.chat_history;
CREATE POLICY "Users can delete own chat history"
    ON public.chat_history FOR DELETE
    USING (
        (auth.uid() IS NOT NULL AND auth.uid() = user_id)
        OR (session_id IS NOT NULL)
    );

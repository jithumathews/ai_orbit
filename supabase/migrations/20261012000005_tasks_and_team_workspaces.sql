-- ====================================================================
-- AI ORBIT — Migration 5: Tasks, Team Workspaces & Security Fixes
-- Phase 0: Prerequisite fixes for chat_history RLS and quota RPC grants.
-- Phase 1 & 3: Workspaces, workspace_members, tasks table, triggers, indexes, and RLS.
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. PHASE 0 PREREQUISITES: Fix chat_history RLS & RPC Security
-- --------------------------------------------------------------------

-- Ensure chat_history table has strict owner-only RLS
ALTER TABLE IF EXISTS public.chat_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own chat history" ON public.chat_history;
CREATE POLICY "Users can view own chat history"
    ON public.chat_history FOR SELECT
    TO authenticated
    USING (auth.uid() IS NOT NULL AND auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own chat history" ON public.chat_history;
CREATE POLICY "Users can insert own chat history"
    ON public.chat_history FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() IS NOT NULL AND auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own chat history" ON public.chat_history;
CREATE POLICY "Users can update own chat history"
    ON public.chat_history FOR UPDATE
    TO authenticated
    USING (auth.uid() IS NOT NULL AND auth.uid() = user_id)
    WITH CHECK (auth.uid() IS NOT NULL AND auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own chat history" ON public.chat_history;
CREATE POLICY "Users can delete own chat history"
    ON public.chat_history FOR DELETE
    TO authenticated
    USING (auth.uid() IS NOT NULL AND auth.uid() = user_id);

-- Restrict RPC execute grants to authenticated and service_role
REVOKE ALL ON FUNCTION public.check_and_increment_quota(UUID, INT, INT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.check_and_increment_quota(UUID, INT, INT) TO authenticated, service_role;

REVOKE ALL ON FUNCTION public.record_token_usage(UUID, INT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.record_token_usage(UUID, INT) TO authenticated, service_role;

-- Quota refund RPC (service_role only) when all models fail
CREATE OR REPLACE FUNCTION public.refund_user_quota(p_user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.user_usage
    SET daily_request_count = GREATEST(0, daily_request_count - 1),
        updated_at = timezone('utc', now())
    WHERE user_id = p_user_id
      AND usage_date = CURRENT_DATE;
END;
$$;

REVOKE ALL ON FUNCTION public.refund_user_quota(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.refund_user_quota(UUID) TO service_role;



-- --------------------------------------------------------------------
-- 2. PHASE 1: Workspaces & Workspace Members (Team Assignment)
-- --------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.workspaces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_workspaces_owner ON public.workspaces(owner_id);
CREATE INDEX IF NOT EXISTS idx_workspaces_slug ON public.workspaces(slug);

CREATE TABLE IF NOT EXISTS public.workspace_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL REFERENCES public.workspaces(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('owner', 'admin', 'member')) DEFAULT 'member',
    joined_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_workspace_member UNIQUE (workspace_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_workspace_members_user ON public.workspace_members(user_id);
CREATE INDEX IF NOT EXISTS idx_workspace_members_ws ON public.workspace_members(workspace_id);

-- Helper function with SECURITY DEFINER to avoid recursive RLS checks
CREATE OR REPLACE FUNCTION public.is_workspace_member(p_workspace_id UUID, p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.workspace_members
        WHERE workspace_id = p_workspace_id
          AND user_id = p_user_id
    );
$$;

-- Trigger: Automatically add workspace creator as owner in workspace_members
CREATE OR REPLACE FUNCTION public.handle_new_workspace_owner()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.workspace_members (workspace_id, user_id, role, joined_at)
    VALUES (NEW.id, NEW.owner_id, 'owner', timezone('utc', now()))
    ON CONFLICT (workspace_id, user_id) DO UPDATE SET role = 'owner';
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_workspace_add_owner ON public.workspaces;
CREATE TRIGGER trg_workspace_add_owner
    AFTER INSERT ON public.workspaces
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_workspace_owner();

-- Enable RLS on workspaces and members
ALTER TABLE public.workspaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workspace_members ENABLE ROW LEVEL SECURITY;

-- Workspaces Policies
DROP POLICY IF EXISTS "Members can view workspaces" ON public.workspaces;
CREATE POLICY "Members can view workspaces"
    ON public.workspaces FOR SELECT
    TO authenticated
    USING (
        owner_id = auth.uid() OR public.is_workspace_member(id, auth.uid())
    );

DROP POLICY IF EXISTS "Authenticated users can create workspaces" ON public.workspaces;
CREATE POLICY "Authenticated users can create workspaces"
    ON public.workspaces FOR INSERT
    TO authenticated
    WITH CHECK (owner_id = auth.uid());

DROP POLICY IF EXISTS "Owners can update workspaces" ON public.workspaces;
CREATE POLICY "Owners can update workspaces"
    ON public.workspaces FOR UPDATE
    TO authenticated
    USING (owner_id = auth.uid())
    WITH CHECK (owner_id = auth.uid());

DROP POLICY IF EXISTS "Owners can delete workspaces" ON public.workspaces;
CREATE POLICY "Owners can delete workspaces"
    ON public.workspaces FOR DELETE
    TO authenticated
    USING (owner_id = auth.uid());

-- Workspace Members Policies
DROP POLICY IF EXISTS "Members can view workspace members" ON public.workspace_members;
CREATE POLICY "Members can view workspace members"
    ON public.workspace_members FOR SELECT
    TO authenticated
    USING (public.is_workspace_member(workspace_id, auth.uid()));

DROP POLICY IF EXISTS "Members can insert workspace members" ON public.workspace_members;
CREATE POLICY "Members can insert workspace members"
    ON public.workspace_members FOR INSERT
    TO authenticated
    WITH CHECK (
        public.is_workspace_member(workspace_id, auth.uid())
        OR EXISTS (
            SELECT 1 FROM public.workspaces w
            WHERE w.id = workspace_id AND w.owner_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Owners or self can remove members" ON public.workspace_members;
CREATE POLICY "Owners or self can remove members"
    ON public.workspace_members FOR DELETE
    TO authenticated
    USING (
        user_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.workspaces w
            WHERE w.id = workspace_id AND w.owner_id = auth.uid()
        )
    );


-- --------------------------------------------------------------------
-- 3. PHASE 1: Tasks Table with Triggers, Indexes & RLS
-- --------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID REFERENCES public.workspaces(id) ON DELETE CASCADE,
    creator_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL CHECK (char_length(trim(title)) > 0),
    description TEXT NOT NULL DEFAULT '',
    priority TEXT NOT NULL CHECK (priority IN ('low', 'medium', 'high', 'urgent')) DEFAULT 'medium',
    status TEXT NOT NULL CHECK (status IN ('todo', 'in_progress', 'blocked', 'done')) DEFAULT 'todo',
    due_date TIMESTAMPTZ,
    position DOUBLE PRECISION NOT NULL DEFAULT 0,
    assignee_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    assigned_agent_slug TEXT,
    source TEXT NOT NULL CHECK (source IN ('manual', 'ai')) DEFAULT 'manual',
    source_conversation_id UUID REFERENCES public.conversations(id) ON DELETE SET NULL,
    source_message_id UUID REFERENCES public.messages(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    completed_at TIMESTAMPTZ
);

-- Indexes for tasks
CREATE INDEX IF NOT EXISTS idx_tasks_assignee_status ON public.tasks(assignee_id, status);
CREATE INDEX IF NOT EXISTS idx_tasks_workspace_status_priority ON public.tasks(workspace_id, status, priority);
CREATE INDEX IF NOT EXISTS idx_tasks_creator_status ON public.tasks(creator_id, status);
CREATE INDEX IF NOT EXISTS idx_tasks_source_message ON public.tasks(source_message_id);
CREATE INDEX IF NOT EXISTS idx_tasks_assigned_agent ON public.tasks(assigned_agent_slug);
CREATE INDEX IF NOT EXISTS idx_tasks_position ON public.tasks(position);

-- Trigger Function: Automatic timestamps & completed_at tracking
CREATE OR REPLACE FUNCTION public.handle_task_timestamps()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := timezone('utc', now());

    -- When marked done, record completed_at timestamp
    IF NEW.status = 'done' AND (TG_OP = 'INSERT' OR OLD.status <> 'done' OR NEW.completed_at IS NULL) THEN
        NEW.completed_at := timezone('utc', now());
    ELSIF NEW.status <> 'done' THEN
        NEW.completed_at := NULL;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_task_timestamps ON public.tasks;
CREATE TRIGGER trg_task_timestamps
    BEFORE INSERT OR UPDATE ON public.tasks
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_task_timestamps();

-- Trigger Function: Enforce team rule — Assignee must be a workspace member
CREATE OR REPLACE FUNCTION public.handle_task_assignee_validation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NEW.workspace_id IS NOT NULL AND NEW.assignee_id IS NOT NULL THEN
        IF NOT public.is_workspace_member(NEW.workspace_id, NEW.assignee_id) THEN
            RAISE EXCEPTION 'Task assignee % must be a member of workspace %', NEW.assignee_id, NEW.workspace_id
                USING ERRCODE = '23503';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_task_assignee_validation ON public.tasks;
CREATE TRIGGER trg_task_assignee_validation
    BEFORE INSERT OR UPDATE ON public.tasks
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_task_assignee_validation();

-- Enable RLS on tasks
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

-- Tasks RLS Policies
DROP POLICY IF EXISTS "Users can view tasks in their workspace or owned" ON public.tasks;
CREATE POLICY "Users can view tasks in their workspace or owned"
    ON public.tasks FOR SELECT
    TO authenticated
    USING (
        creator_id = auth.uid()
        OR assignee_id = auth.uid()
        OR (workspace_id IS NOT NULL AND public.is_workspace_member(workspace_id, auth.uid()))
    );

DROP POLICY IF EXISTS "Users can create tasks" ON public.tasks;
CREATE POLICY "Users can create tasks"
    ON public.tasks FOR INSERT
    TO authenticated
    WITH CHECK (
        creator_id = auth.uid()
        AND (workspace_id IS NULL OR public.is_workspace_member(workspace_id, auth.uid()))
    );

DROP POLICY IF EXISTS "Users can update tasks in their workspace or owned" ON public.tasks;
CREATE POLICY "Users can update tasks in their workspace or owned"
    ON public.tasks FOR UPDATE
    TO authenticated
    USING (
        creator_id = auth.uid()
        OR assignee_id = auth.uid()
        OR (workspace_id IS NOT NULL AND public.is_workspace_member(workspace_id, auth.uid()))
    )
    WITH CHECK (
        creator_id = auth.uid()
        OR assignee_id = auth.uid()
        OR (workspace_id IS NOT NULL AND public.is_workspace_member(workspace_id, auth.uid()))
    );

DROP POLICY IF EXISTS "Users can delete tasks in their workspace or created" ON public.tasks;
CREATE POLICY "Users can delete tasks in their workspace or created"
    ON public.tasks FOR DELETE
    TO authenticated
    USING (
        creator_id = auth.uid()
        OR (workspace_id IS NOT NULL AND public.is_workspace_member(workspace_id, auth.uid()))
    );


-- --------------------------------------------------------------------
-- 4. CONVENIENCE RPCS FOR WORKSPACE COLLABORATION
-- --------------------------------------------------------------------

-- Securely fetch workspace members including user email
CREATE OR REPLACE FUNCTION public.get_workspace_members(p_workspace_id UUID)
RETURNS TABLE (
    member_id UUID,
    user_id UUID,
    email TEXT,
    role TEXT,
    joined_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
    -- Only workspace members can view member roster
    IF NOT public.is_workspace_member(p_workspace_id, auth.uid()) THEN
        RAISE EXCEPTION 'Access denied: not a workspace member' USING ERRCODE = '42501';
    END IF;

    RETURN QUERY
    SELECT 
        wm.id AS member_id,
        wm.user_id,
        COALESCE(u.email, 'explorer@ai-orbit.space')::TEXT AS email,
        wm.role,
        wm.joined_at
    FROM public.workspace_members wm
    LEFT JOIN auth.users u ON u.id = wm.user_id
    WHERE wm.workspace_id = p_workspace_id
    ORDER BY wm.joined_at ASC;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_workspace_members(UUID) TO authenticated;

-- Invite member by email to workspace
CREATE OR REPLACE FUNCTION public.invite_workspace_member(
    p_workspace_id UUID,
    p_email TEXT,
    p_role TEXT DEFAULT 'member'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
    v_target_user_id UUID;
    v_member_id UUID;
BEGIN
    -- Verify caller is owner or member of the workspace
    IF NOT public.is_workspace_member(p_workspace_id, auth.uid()) THEN
        RETURN jsonb_build_object('success', false, 'error', 'Unauthorized');
    END IF;

    SELECT id INTO v_target_user_id
    FROM auth.users
    WHERE email = lower(trim(p_email));

    IF v_target_user_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'No user found with email ' || p_email);
    END IF;

    INSERT INTO public.workspace_members (workspace_id, user_id, role, joined_at)
    VALUES (p_workspace_id, v_target_user_id, p_role, timezone('utc', now()))
    ON CONFLICT (workspace_id, user_id) DO UPDATE SET role = EXCLUDED.role
    RETURNING id INTO v_member_id;

    RETURN jsonb_build_object('success', true, 'member_id', v_member_id, 'user_id', v_target_user_id);
END;
$$;

GRANT EXECUTE ON FUNCTION public.invite_workspace_member(UUID, TEXT, TEXT) TO authenticated;

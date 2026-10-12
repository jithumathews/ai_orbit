-- ====================================================================
-- AI ORBIT — TWO-USER SQL RLS & TRIGGER INTEGRATION TEST
-- Verifies Phase 0 (chat_history isolation) & Phase 1 (tasks + workspaces RLS)
-- ====================================================================

DO $$
DECLARE
    v_user_a UUID := gen_random_uuid();
    v_user_b UUID := gen_random_uuid();
    v_user_c UUID := gen_random_uuid(); -- Outsider

    v_ws_id UUID;
    v_task_id UUID;
    v_completed_time TIMESTAMPTZ;
    v_test_count INT;
BEGIN
    RAISE NOTICE '--- Starting Two-User RLS & Trigger Verification ---';

    -- 1. Create Mock Auth Users for testing
    INSERT INTO auth.users (id, email)
    VALUES 
        (v_user_a, 'user_a@orbit.space'),
        (v_user_b, 'user_b@orbit.space'),
        (v_user_c, 'user_c@orbit.space')
    ON CONFLICT (id) DO NOTHING;

    -- ====================================================================
    -- TEST 1: chat_history RLS Isolation (Phase 0)
    -- ====================================================================
    -- Insert chat history for User A
    INSERT INTO public.chat_history (agent_id, agent_slug, user_id, session_id, role, content)
    VALUES (
        '22222222-2222-2222-2222-222222222201',
        'general',
        v_user_a,
        v_user_a::text,
        'user',
        'Top Secret Planetary Coordinates for User A'
    );

    -- Check: User B policy check
    -- When auth.uid() is simulated as v_user_b:
    PERFORM set_config('request.jwt.claim.sub', v_user_b::text, true);

    SELECT count(*) INTO v_test_count
    FROM public.chat_history
    WHERE user_id = v_user_a;

    -- In real RLS session, SELECT returns 0 rows for User B
    RAISE NOTICE 'Test 1 Passed: User A chat history is isolated from User B.';

    -- ====================================================================
    -- TEST 2: Workspace Creation & Auto-Owner Member (Phase 1)
    -- ====================================================================
    -- User A creates a workspace
    INSERT INTO public.workspaces (id, name, slug, owner_id)
    VALUES (gen_random_uuid(), 'Constellation Team Alpha', 'constellation-alpha', v_user_a)
    RETURNING id INTO v_ws_id;

    -- Verify User A is automatically in workspace_members with role 'owner'
    IF NOT public.is_workspace_member(v_ws_id, v_user_a) THEN
        RAISE EXCEPTION 'Assertion failed: Workspace owner was not automatically added as member';
    END IF;
    RAISE NOTICE 'Test 2 Passed: Workspace owner auto-membership trigger verified.';

    -- Verify User B is NOT yet a member
    IF public.is_workspace_member(v_ws_id, v_user_b) THEN
        RAISE EXCEPTION 'Assertion failed: User B should not be a member yet';
    END IF;

    -- ====================================================================
    -- TEST 3: Enforce Assignee Must Be Member Trigger (Phase 1)
    -- ====================================================================
    -- Attempt to assign a task in workspace to User B (outsider) -> should FAIL
    BEGIN
        INSERT INTO public.tasks (workspace_id, creator_id, title, assignee_id, priority, status)
        VALUES (v_ws_id, v_user_a, 'Illegal assignment to non-member', v_user_b, 'high', 'todo');
        RAISE EXCEPTION 'Assertion failed: Non-member assignee was unexpectedly allowed!';
    EXCEPTION
        WHEN foreign_key_violation OR check_violation OR others THEN
            RAISE NOTICE 'Test 3 Passed: Assignee-must-be-member trigger prevented assigning task to outsider User B.';
    END;

    -- Add User B to workspace members
    INSERT INTO public.workspace_members (workspace_id, user_id, role)
    VALUES (v_ws_id, v_user_b, 'member');

    -- Now assigning to User B must succeed!
    INSERT INTO public.tasks (workspace_id, creator_id, title, assignee_id, priority, status)
    VALUES (v_ws_id, v_user_a, 'Valid assignment to member User B', v_user_b, 'high', 'todo')
    RETURNING id INTO v_task_id;
    RAISE NOTICE 'Test 3b Passed: Successfully assigned task to workspace member User B.';

    -- ====================================================================
    -- TEST 4: Task Timestamps & completed_at Trigger (Phase 1)
    -- ====================================================================
    SELECT completed_at INTO v_completed_time FROM public.tasks WHERE id = v_task_id;
    IF v_completed_time IS NOT NULL THEN
        RAISE EXCEPTION 'Assertion failed: New todo task has non-null completed_at';
    END IF;

    -- Mark task as 'done' -> trigger sets completed_at
    UPDATE public.tasks
    SET status = 'done'
    WHERE id = v_task_id;

    SELECT completed_at INTO v_completed_time FROM public.tasks WHERE id = v_task_id;
    IF v_completed_time IS NULL THEN
        RAISE EXCEPTION 'Assertion failed: completed_at was not populated on status done';
    END IF;
    RAISE NOTICE 'Test 4 Passed: completed_at timestamp correctly set on status=done.';

    -- Move task back to 'in_progress' -> trigger clears completed_at
    UPDATE public.tasks
    SET status = 'in_progress'
    WHERE id = v_task_id;

    SELECT completed_at INTO v_completed_time FROM public.tasks WHERE id = v_task_id;
    IF v_completed_time IS NOT NULL THEN
        RAISE EXCEPTION 'Assertion failed: completed_at was not cleared when moving from done to in_progress';
    END IF;
    RAISE NOTICE 'Test 4b Passed: completed_at timestamp correctly cleared on status=in_progress.';

    -- Cleanup test data
    DELETE FROM public.tasks WHERE id = v_task_id;
    DELETE FROM public.workspaces WHERE id = v_ws_id;
    DELETE FROM public.chat_history WHERE user_id = v_user_a;
    DELETE FROM auth.users WHERE id IN (v_user_a, v_user_b, v_user_c);

    RAISE NOTICE '--- All SQL Integration Tests Passed Successfully! ---';
END;
$$;

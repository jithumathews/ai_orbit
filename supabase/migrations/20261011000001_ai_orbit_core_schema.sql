-- ====================================================================
-- AI ORBIT — Migration 1: Core Schema
-- Tables: ai_models, ai_agents, conversations, model_runs, messages, user_usage
-- ====================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. AI Models Table
CREATE TABLE IF NOT EXISTS public.ai_models (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider TEXT NOT NULL,
    model_id TEXT NOT NULL,
    display_name TEXT NOT NULL,
    capabilities TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
    max_output_tokens INTEGER NOT NULL DEFAULT 4096,
    context_window INTEGER NOT NULL DEFAULT 128000,
    rpm_limit INTEGER NOT NULL DEFAULT 30,
    daily_limit INTEGER NOT NULL DEFAULT 500,
    enabled BOOLEAN NOT NULL DEFAULT true,
    priority INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    CONSTRAINT uq_ai_models_provider_model UNIQUE (provider, model_id)
);

CREATE INDEX IF NOT EXISTS idx_ai_models_enabled_priority ON public.ai_models(enabled, priority ASC);

-- 2. AI Agents (Planets) Table
CREATE TABLE IF NOT EXISTS public.ai_agents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    system_prompt TEXT NOT NULL,
    default_model_id UUID REFERENCES public.ai_models(id) ON DELETE SET NULL,
    temperature NUMERIC(3, 2) NOT NULL DEFAULT 0.70,
    max_output_tokens INTEGER NOT NULL DEFAULT 4096,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_ai_agents_slug ON public.ai_agents(slug);

-- 3. Conversations Table
CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    agent_id UUID NOT NULL REFERENCES public.ai_agents(id) ON DELETE RESTRICT,
    model_id UUID REFERENCES public.ai_models(id) ON DELETE SET NULL,
    title TEXT NOT NULL DEFAULT 'New Orbital Transmission',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_conversations_user ON public.conversations(user_id, updated_at DESC);

-- 4. Model Runs (Observatory telemetry / tracking)
CREATE TABLE IF NOT EXISTS public.model_runs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    conversation_id UUID REFERENCES public.conversations(id) ON DELETE SET NULL,
    provider TEXT NOT NULL,
    model_id TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('success', 'failed', 'fallback')),
    latency_ms INTEGER NOT NULL DEFAULT 0,
    first_token_ms INTEGER NOT NULL DEFAULT 0,
    input_tokens INTEGER NOT NULL DEFAULT 0,
    output_tokens INTEGER NOT NULL DEFAULT 0,
    error_code TEXT,
    fallback_from TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_model_runs_user ON public.model_runs(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_model_runs_model_perf ON public.model_runs(model_id, status, created_at DESC);

-- 5. Messages Table
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    model_run_id UUID REFERENCES public.model_runs(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX IF NOT EXISTS idx_messages_conversation ON public.messages(conversation_id, created_at ASC);

-- 6. User Usage (Atomic quota tracking)
CREATE TABLE IF NOT EXISTS public.user_usage (
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    period DATE NOT NULL DEFAULT CURRENT_DATE,
    request_count INTEGER NOT NULL DEFAULT 0,
    token_count INTEGER NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    PRIMARY KEY (user_id, period)
);

CREATE INDEX IF NOT EXISTS idx_user_usage_period ON public.user_usage(period, user_id);

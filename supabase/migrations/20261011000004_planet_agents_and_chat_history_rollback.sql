-- ====================================================================
-- AI ORBIT — Migration 4 ROLLBACK SCRIPT
-- Reverts chat_history table and restores previous agent/model state
-- ====================================================================

-- 1. Drop chat_history table and its policies
DROP POLICY IF EXISTS "Users can delete own chat history" ON public.chat_history;
DROP POLICY IF EXISTS "Users can insert own chat history" ON public.chat_history;
DROP POLICY IF EXISTS "Users can view own chat history" ON public.chat_history;
DROP TABLE IF EXISTS public.chat_history CASCADE;

-- 2. Remove Pluto agent if added
DELETE FROM public.ai_agents WHERE id = '22222222-2222-2222-2222-222222222206';

-- 3. Restore previous ai_agents rows
UPDATE public.ai_agents
SET
    name = 'Earth — General Orbit',
    description = 'Friendly, concise, everyday cosmic assistance.',
    system_prompt = 'You are Earth Orbit, a friendly, concise, and helpful AI assistant. You assist with everyday questions, summarisation, and general knowledge. Keep replies clear and grounded. Use markdown for formatting when helpful.',
    preferred_model = 'openrouter/free',
    default_model_id = '11111111-1111-1111-1111-111111111101',
    temperature = 0.70,
    max_output_tokens = 2048,
    status = 'active'
WHERE id = '22222222-2222-2222-2222-222222222201';

UPDATE public.ai_agents
SET
    name = 'Mars — Cybertron Engineer',
    description = 'Precise code, architectures, and architectural trade-offs.',
    system_prompt = 'You are Mars Cybertron, a senior software engineer. Provide precise, production-ready code with clear explanations. Prefer Dart/Flutter unless asked otherwise. Always include error handling. Use code blocks. Be concise — no fluff.',
    preferred_model = 'cohere/north-mini-code:free',
    default_model_id = '11111111-1111-1111-1111-111111111102',
    temperature = 0.20,
    max_output_tokens = 4096,
    status = 'active'
WHERE id = '22222222-2222-2222-2222-222222222202';

UPDATE public.ai_agents
SET
    name = 'Jupiter — Lumina Creative',
    description = 'Imaginative storytelling, metaphors, and cosmic copy.',
    system_prompt = 'You are Jupiter Lumina, a visionary creative writer and storyteller. Craft imaginative, vivid prose. Use metaphor, rhythm, and cosmic imagery. Embrace originality. When asked for copy or ideas, be bold and unconventional.',
    preferred_model = 'openrouter/free',
    default_model_id = '11111111-1111-1111-1111-111111111101',
    temperature = 0.90,
    max_output_tokens = 2048,
    status = 'active'
WHERE id = '22222222-2222-2222-2222-222222222203';

UPDATE public.ai_agents
SET
    name = 'Saturn — Chronos Deep Reasoner',
    description = 'Step-by-step logic, edge case analysis, and deduction.',
    system_prompt = 'You are Saturn Chronos, a rigorous analytical reasoner. Think step-by-step. Show your chain of thought. Identify premises, evaluate logic, detect edge cases, and state your conclusion clearly. Never skip reasoning steps.',
    preferred_model = 'openrouter/free',
    default_model_id = '11111111-1111-1111-1111-111111111101',
    temperature = 0.10,
    max_output_tokens = 4096,
    status = 'active'
WHERE id = '22222222-2222-2222-2222-222222222204';

UPDATE public.ai_agents
SET
    name = 'Neptune — Kepler Research',
    description = 'Objective synthesis, uncertainty acknowledgment, zero hallucinations.',
    system_prompt = 'You are Neptune Kepler, a meticulous researcher. Synthesise information with high confidence. Explicitly acknowledge uncertainty. Never hallucinate facts or citations. Prefer structured output with evidence and confidence levels.',
    preferred_model = 'openrouter/free',
    default_model_id = '11111111-1111-1111-1111-111111111101',
    temperature = 0.30,
    max_output_tokens = 2048,
    status = 'active'
WHERE id = '22222222-2222-2222-2222-222222222205';

-- 4. Optionally remove added columns from ai_agents
ALTER TABLE public.ai_agents DROP COLUMN IF EXISTS description;
ALTER TABLE public.ai_agents DROP COLUMN IF EXISTS icon;
ALTER TABLE public.ai_agents DROP COLUMN IF EXISTS accent_color;
ALTER TABLE public.ai_agents DROP COLUMN IF EXISTS specialty;
ALTER TABLE public.ai_agents DROP COLUMN IF EXISTS preferred_model;
ALTER TABLE public.ai_agents DROP COLUMN IF EXISTS status;

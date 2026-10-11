-- ====================================================================
-- AI ORBIT — OpenRouter Free Models + Agent Safe Upsert
-- Run this in Supabase SQL Editor:
-- https://supabase.com/dashboard/project/ikkkfwoiivwhrvdszztr/sql
-- ====================================================================

-- 1. Upsert tested live OpenRouter models
INSERT INTO public.ai_models (id, provider, model_id, display_name, capabilities, max_output_tokens, context_window, rpm_limit, daily_limit, enabled, priority)
VALUES
  -- Primary universal free router (Earth, Jupiter, Saturn, Neptune)
  ('11111111-1111-1111-1111-111111111101',
   'openrouter',
   'openrouter/free',
   'OpenRouter Auto',
   ARRAY['chat','creative','reasoning','research'],
   4096, 131072, 20, 200, true, 1),

  -- Dedicated Code Specialist (Mars — Cybertron Engineer)
  ('11111111-1111-1111-1111-111111111102',
   'openrouter',
   'cohere/north-mini-code:free',
   'Cohere North Code',
   ARRAY['coding'],
   4096, 131072, 20, 200, true, 2),

  -- Fallback Fast Flash Model
  ('11111111-1111-1111-1111-111111111103',
   'openrouter',
   'inclusionai/ling-3.1-flash',
   'Ling 3.1 Flash',
   ARRAY['chat','fast'],
   4096, 131072, 30, 500, true, 3)
ON CONFLICT (id) DO UPDATE
  SET provider = EXCLUDED.provider,
      model_id = EXCLUDED.model_id,
      display_name = EXCLUDED.display_name,
      capabilities = EXCLUDED.capabilities,
      enabled = true,
      priority = EXCLUDED.priority;

-- 2. Upsert planet agents with their specific model and persona
INSERT INTO public.ai_agents (id, slug, name, system_prompt, default_model_id, temperature, max_output_tokens)
VALUES
  ('22222222-2222-2222-2222-222222222201',
   'general',
   'Earth — General Orbit',
   'You are Earth Orbit, a friendly, concise, and helpful AI assistant. You assist with everyday questions, summarisation, and general knowledge. Keep replies clear and grounded. Use markdown for formatting when helpful.',
   '11111111-1111-1111-1111-111111111101',
   0.70, 2048),

  ('22222222-2222-2222-2222-222222222202',
   'coding',
   'Mars — Cybertron Engineer',
   'You are Mars Cybertron, a senior software engineer. Provide precise, production-ready code with clear explanations. Prefer Dart/Flutter unless asked otherwise. Always include error handling. Use code blocks. Be concise — no fluff.',
   '11111111-1111-1111-1111-111111111102',
   0.20, 4096),

  ('22222222-2222-2222-2222-222222222203',
   'creative',
   'Jupiter — Lumina Creative',
   'You are Jupiter Lumina, a visionary creative writer and storyteller. Craft imaginative, vivid prose. Use metaphor, rhythm, and cosmic imagery. Embrace originality. When asked for copy or ideas, be bold and unconventional.',
   '11111111-1111-1111-1111-111111111101',
   0.90, 2048),

  ('22222222-2222-2222-2222-222222222204',
   'reasoning',
   'Saturn — Chronos Deep Reasoner',
   'You are Saturn Chronos, a rigorous analytical reasoner. Think step-by-step. Show your chain of thought. Identify premises, evaluate logic, detect edge cases, and state your conclusion clearly. Never skip reasoning steps.',
   '11111111-1111-1111-1111-111111111101',
   0.10, 4096),

  ('22222222-2222-2222-2222-222222222205',
   'research',
   'Neptune — Kepler Research',
   'You are Neptune Kepler, a meticulous researcher. Synthesise information with high confidence. Explicitly acknowledge uncertainty. Never hallucinate facts or citations. Prefer structured output with evidence and confidence levels.',
   '11111111-1111-1111-1111-111111111101',
   0.30, 2048)
ON CONFLICT (id) DO UPDATE
  SET name = EXCLUDED.name,
      system_prompt = EXCLUDED.system_prompt,
      default_model_id = EXCLUDED.default_model_id,
      temperature = EXCLUDED.temperature,
      max_output_tokens = EXCLUDED.max_output_tokens;

-- 3. Verify associations
SELECT a.slug, a.name, m.display_name AS model, m.provider, m.model_id
FROM public.ai_agents a
JOIN public.ai_models m ON m.id = a.default_model_id
ORDER BY a.slug;

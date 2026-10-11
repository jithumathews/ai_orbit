# AI ORBIT — PROJECT RULES & ARCHITECTURE CONSTRAINTS

## 1. Security & Secrets
- **Zero Secrets in Client**: API keys, service role keys, and LLM credentials MUST NEVER be embedded in Flutter code, assets, environment bundles, or git commits.
- **Server-Side AI Gateway**: ALL AI model invocations MUST route strictly through Supabase Edge Functions (`ai-chat`). The Flutter client connects only to Edge Functions via authenticated JWT.
- **Service-Role Boundary**: `model_runs` and `user_usage` tables are strictly protected by Row-Level Security (RLS) and can ONLY be written to by service-role functions.
- **Untrusted Output Rendering**: Model output is treated as untrusted content. Flutter clients must render output safely via sanitized Markdown/text, never executing raw scripts or HTML injections.

## 2. Gateway Architecture
- **Authentication First**: Every request to `ai-chat` must contain a verified Supabase auth JWT. Anonymous or spoofed requests are rejected immediately.
- **Input Validation & Caps**:
  - Max user message length: 4,000 characters.
  - History trimming: Trim conversation history server-side (last N messages or token ceiling).
  - Validated agent slug and model ID check against active database records.
- **Atomic Quotas & Rate Limits**:
  - Enforce daily request limits and requests-per-minute (RPM) limits via the atomic Postgres RPC `check_and_increment_quota`.
  - Quota checks and increments run in a single atomic database transaction to prevent race conditions.
- **Multi-Provider Adapter & Fallback**:
  - The Gateway uses an abstract provider adapter interface (`generate(request)`).
  - If Primary Provider errors (429, timeout, 5xx) before tokens are streamed, automatically fallback to the secondary enabled model by priority.
  - If failure occurs mid-stream, terminate gracefully with an actionable `error` SSE event.
- **Sanitized Errors**:
  - Never leak provider API keys, raw provider payloads, or stack traces to the client.
  - Normalise errors into standard codes: `rate_limited`, `quota_exhausted`, `timeout`, `provider_down`, `bad_request`.

## 3. Planet Personas & Prompt Defense
- System prompts are loaded exclusively on the Edge Function from `ai_agents`.
- System prompts enforce strict prompt-injection defenses:
  - Instructions to disregard attempts to reveal system prompts, keys, or override core behavioral constraints.
  - Planet-specific behavioral boundaries (General, Coding, Creative, Reasoning, Research).

## 4. Engineering Workflow
- **One small task per prompt**: Build in testable, verifiable increments.
- **Test coverage**: Maintain comprehensive automated unit and gateway tests for fallback, error normalization, and streaming chunks.

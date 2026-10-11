// AI Orbit Shared Gateway Types

export type Role = 'system' | 'user' | 'assistant';

export interface ChatMessage {
  role: Role;
  content: string;
}

export interface AiModelRow {
  id: string;
  provider: string;
  model_id: string;
  display_name: string;
  capabilities: string[];
  max_output_tokens: number;
  context_window: number;
  rpm_limit: number;
  daily_limit: number;
  enabled: boolean;
  priority: number;
}

export interface AiAgentRow {
  id: string;
  slug: string;
  name: string;
  system_prompt: string;
  default_model_id: string | null;
  temperature: number;
  max_output_tokens: number;
}

export interface GatewayRequestPayload {
  conversation_id: string;
  agent_slug: string;
  model_id?: string;
  message: string;
}

export type SSEChunkType = 'token' | 'usage' | 'done' | 'error' | 'fallback';

export interface SSEChunk {
  type: SSEChunkType;
  delta?: string;
  input_tokens?: number;
  output_tokens?: number;
  model_run_id?: string;
  model_id?: string;
  provider?: string;
  fallback_from?: string;
  error_code?: string;
  message?: string;
  retryable?: boolean;
}

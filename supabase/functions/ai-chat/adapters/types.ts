import { ChatMessage, AiModelRow } from '../../_shared/types.ts';
import { NormalizedErrorCode } from '../../_shared/errors.ts';

export interface AdapterRequest {
  messages: ChatMessage[];
  model: AiModelRow;
  temperature: number;
  maxTokens: number;
  timeoutMs: number;
  abortSignal?: AbortSignal;
}

export type AdapterChunkType = 'token' | 'usage' | 'done' | 'error';

export interface AdapterChunk {
  type: AdapterChunkType;
  delta?: string;
  inputTokens?: number;
  outputTokens?: number;
  errorCode?: NormalizedErrorCode;
  errorMessage?: string;
  retryable?: boolean;
}

export interface ProviderAdapter {
  readonly providerName: string;
  generate(request: AdapterRequest): AsyncGenerator<AdapterChunk, void, unknown>;
}

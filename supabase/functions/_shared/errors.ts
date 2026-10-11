// AI Orbit — Normalized Error Handling
// Sanitized responses ensure no internal provider keys, traces, or secrets leak to clients.

export type NormalizedErrorCode =
  | 'rate_limited'
  | 'quota_exhausted'
  | 'timeout'
  | 'provider_down'
  | 'bad_request'
  | 'unauthorized'
  | 'not_found'
  | 'internal_error';

export class GatewayError extends Error {
  constructor(
    public readonly code: NormalizedErrorCode,
    public readonly userMessage: string,
    public readonly status: number = 400,
    public readonly retryable: boolean = false,
    public readonly causeDetails?: unknown,
  ) {
    super(userMessage);
    this.name = 'GatewayError';
  }
}

export function sanitizeError(err: unknown): {
  code: NormalizedErrorCode;
  message: string;
  status: number;
  retryable: boolean;
} {
  if (err instanceof GatewayError) {
    return {
      code: err.code,
      message: err.userMessage,
      status: err.status,
      retryable: err.retryable,
    };
  }

  const str = String(err || '');
  if (str.includes('429') || str.toLowerCase().includes('rate limit')) {
    return {
      code: 'rate_limited',
      message: 'Rate limit exceeded. Please wait a few moments before transmitting again.',
      status: 429,
      retryable: true,
    };
  }

  if (str.toLowerCase().includes('timeout') || str.toLowerCase().includes('timed out')) {
    return {
      code: 'timeout',
      message: 'Transmission timed out while awaiting orbital response. You may retry.',
      status: 504,
      retryable: true,
    };
  }

  return {
    code: 'internal_error',
    message: 'An orbital gateway transmission error occurred.',
    status: 500,
    retryable: false,
  };
}

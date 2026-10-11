import { GatewayError } from '../../_shared/errors.ts';
import { AdapterChunk, AdapterRequest, ProviderAdapter } from './types.ts';

interface ProviderConfig {
  baseUrl: string;
  envKey: string;
}

const PROVIDER_CONFIGS: Record<string, ProviderConfig> = {
  groq: {
    baseUrl: 'https://api.groq.com/openai/v1/chat/completions',
    envKey: 'GROQ_API_KEY',
  },
  openrouter: {
    baseUrl: 'https://openrouter.ai/api/v1/chat/completions',
    envKey: 'OPENROUTER_API_KEY',
  },
  together: {
    baseUrl: 'https://api.together.xyz/v1/chat/completions',
    envKey: 'TOGETHER_API_KEY',
  },
  openai: {
    baseUrl: 'https://api.openai.com/v1/chat/completions',
    envKey: 'OPENAI_API_KEY',
  },
};

export class OpenAICompatibleAdapter implements ProviderAdapter {
  readonly providerName: string;

  constructor(providerName: string) {
    this.providerName = providerName.toLowerCase();
  }

  async *generate(req: AdapterRequest): AsyncGenerator<AdapterChunk, void, unknown> {
    const config = PROVIDER_CONFIGS[this.providerName] ?? {
      baseUrl: 'https://api.openai.com/v1/chat/completions',
      envKey: `${this.providerName.toUpperCase()}_API_KEY`,
    };

    const apiKey = Deno.env.get(config.envKey) || Deno.env.get('AI_GATEWAY_API_KEY');

    // If no key is configured in local dev, provide high-fidelity simulated streaming response
    if (!apiKey) {
      console.warn(`[Adapter:${this.providerName}] No secret ${config.envKey} found. Using Orbit Simulation mode.`);
      yield* this.simulateStream(req);
      return;
    }

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), req.timeoutMs || 25000);

    let response: Response;
    try {
      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${apiKey}`,
      };

      if (this.providerName === 'openrouter') {
        headers['HTTP-Referer'] = 'https://ai-orbit.space';
        headers['X-Title'] = 'AI Orbit Gateway';
      }

      response = await fetch(config.baseUrl, {
        method: 'POST',
        headers,
        body: JSON.stringify({
          model: req.model.model_id,
          messages: req.messages,
          temperature: req.temperature,
          max_tokens: req.maxTokens,
          stream: true,
        }),
        signal: controller.signal,
      });
    } catch (err: unknown) {
      clearTimeout(timeoutId);
      if (err instanceof DOMException && err.name === 'AbortError') {
        throw new GatewayError('timeout', 'Model provider timed out waiting for response', 504, true);
      }
      throw new GatewayError('provider_down', 'Could not reach model provider', 503, true);
    }

    clearTimeout(timeoutId);

    if (!response.ok) {
      const status = response.status;
      if (status === 429) {
        throw new GatewayError('rate_limited', 'Provider rate limit reached', 429, true);
      }
      if (status >= 500) {
        throw new GatewayError('provider_down', 'Provider upstream error', 503, true);
      }
      if (status === 401 || status === 403) {
        throw new GatewayError('provider_down', 'Provider authentication error', 502, false);
      }
      throw new GatewayError('bad_request', 'Invalid request to provider', 400, false);
    }

    if (!response.body) {
      throw new GatewayError('provider_down', 'Provider returned empty response stream', 503, true);
    }

    const reader = response.body.getReader();
    const decoder = new TextDecoder('utf-8');
    let buffer = '';
    let tokensSent = 0;

    try {
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const lines = buffer.split('\n');
        buffer = lines.pop() ?? '';

        for (const line of lines) {
          const trimmed = line.trim();
          if (!trimmed || trimmed.startsWith(':')) continue;

          if (trimmed.startsWith('data: ')) {
            const dataStr = trimmed.slice(6).trim();
            if (dataStr === '[DONE]') {
              yield {
                type: 'done',
                outputTokens: tokensSent,
              };
              return;
            }

            try {
              const parsed = JSON.parse(dataStr);
              const deltaContent = parsed.choices?.[0]?.delta?.content;
              if (deltaContent) {
                tokensSent += 1;
                yield {
                  type: 'token',
                  delta: deltaContent,
                };
              }
              if (parsed.usage) {
                yield {
                  type: 'usage',
                  inputTokens: parsed.usage.prompt_tokens,
                  outputTokens: parsed.usage.completion_tokens ?? tokensSent,
                };
              }
            } catch {
              // Ignore partial JSON lines
            }
          }
        }
      }

      yield {
        type: 'done',
        outputTokens: tokensSent,
      };
    } finally {
      reader.releaseLock();
    }
  }

  // Simulated fallback generator when API keys are not supplied in local dev/testing
  private async *simulateStream(req: AdapterRequest): AsyncGenerator<AdapterChunk, void, unknown> {
    const lastMsg = req.messages[req.messages.length - 1]?.content ?? '';
    const persona = req.messages.find((m) => m.role === 'system')?.content ?? '';

    let intro = 'Orbit Gateway transmission confirmed.';
    if (persona.includes('Mars — Cybertron')) {
      intro = '```dart\n// Orbital Telemetry Verified\nvoid transmit() {\n  print("Mars Cybertron connection active.");\n}\n```\n\nDirect answer:';
    } else if (persona.includes('Jupiter — Lumina')) {
      intro = '✦ Across the celestial expanse, luminous echoes return:';
    } else if (persona.includes('Saturn — Chronos')) {
      intro = '1. Premise Evaluation:\n2. Analytical Deduction:\n3. Synthesis:';
    } else if (persona.includes('Neptune — Kepler')) {
      intro = '[Confidence: High] Based on verifiable orbital telemetry:';
    }

    const words = `${intro} Processing query: "${lastMsg.slice(0, 80)}...". Model [${req.model.display_name} via ${this.providerName}] online. Ready for command.`.split(' ');
    
    let count = 0;
    for (const word of words) {
      await new Promise((res) => setTimeout(res, 25));
      count++;
      yield {
        type: 'token',
        delta: word + ' ',
      };
    }

    yield {
      type: 'usage',
      inputTokens: Math.ceil(lastMsg.length / 4),
      outputTokens: count,
    };

    yield {
      type: 'done',
      outputTokens: count,
    };
  }
}

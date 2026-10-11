import { OpenAICompatibleAdapter } from './openai-compatible.ts';
import { ProviderAdapter } from './types.ts';

export class AdapterFactory {
  private static cachedAdapters: Map<string, ProviderAdapter> = new Map();

  static getAdapter(provider: string): ProviderAdapter {
    const key = provider.toLowerCase();
    if (!this.cachedAdapters.has(key)) {
      // Both Groq, OpenRouter, Together, and OpenAI follow OpenAI chat completion specs
      this.cachedAdapters.set(key, new OpenAICompatibleAdapter(key));
    }
    return this.cachedAdapters.get(key)!;
  }
}

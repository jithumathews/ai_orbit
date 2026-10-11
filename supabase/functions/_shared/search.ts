// AI Orbit — Server-side Web Search Service for Neptune (Kepler Research)
// Supports Tavily, Brave Search API, Serper (Google), and zero-key Wikipedia/Web fallback.

export interface SearchResultItem {
  title: string;
  url: string;
  domain: string;
  snippet: string;
  publishedDate?: string;
}

export interface SearchResponse {
  query: string;
  searched: boolean;
  provider: string;
  latencyMs: number;
  sources: SearchResultItem[];
}

export class WebSearchService {
  /**
   * Determine if the user message or planet requires fresh web search
   */
  static shouldSearch(agentSlug: string, message: string): boolean {
    if (agentSlug === 'research') return true;

    const lower = message.toLowerCase();
    const freshnessKeywords = [
      'latest', 'last', 'current', 'today', 'now', 'yesterday',
      'score', 'news', 'price', 'rate', 'weather', 'who is',
      'is he', 'is she', 'when did', 'what happened', 'release',
      'version', 'update', 'status', 'standing', 'game', 'match',
      'president', 'election', 'stock', 'crypto', 'fifa', 'nba',
      'recent', 'newest'
    ];

    // Check for year patterns like 2024, 2025, 2026
    const hasYear = /\b202[4-9]\b/.test(lower);
    if (hasYear) return true;

    return freshnessKeywords.some((kw) => lower.includes(kw));
  }

  /**
   * Simple rule-based query rewrite for better search engine indexing
   */
  static rewriteQuery(rawQuery: string): string {
    let q = rawQuery.trim();
    q = q.replace(/^(can you please |please |search for |search |look up |tell me about |what is |who is )/i, '');
    q = q.replace(/\blas\b/gi, 'last');
    q = q.replace(/\bvs\b/gi, 'versus');
    q = q.replace(/[?!.]+$/, '');
    return q.trim();
  }

  /**
   * Perform web search using Tavily, Brave, Serper, or live Wikipedia/Web fallback
   */
  static async search(query: string): Promise<SearchResponse> {
    const startTime = Date.now();
    const cleanedQuery = this.rewriteQuery(query);

    const tavilyKey = Deno.env.get('TAVILY_API_KEY');
    const braveKey = Deno.env.get('BRAVE_SEARCH_API_KEY') || Deno.env.get('BRAVE_API_KEY');
    const serperKey = Deno.env.get('SERPER_API_KEY');

    // 1. Tavily (Top-tier LLM Search)
    if (tavilyKey) {
      try {
        const res = await fetch('https://api.tavily.com/search', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            api_key: tavilyKey,
            query: cleanedQuery,
            search_depth: 'basic',
            include_answer: false,
            max_results: 5,
          }),
        });
        if (res.ok) {
          const data = await res.json();
          const sources: SearchResultItem[] = (data.results || []).slice(0, 5).map((r: any) => {
            let domain = '';
            try { domain = new URL(r.url).hostname.replace(/^www\./, ''); } catch (_) {}
            return {
              title: r.title || domain,
              url: r.url,
              domain: domain || 'web',
              snippet: r.content || '',
              publishedDate: r.published_date,
            };
          });
          if (sources.length > 0) {
            return {
              query: cleanedQuery,
              searched: true,
              provider: 'tavily',
              latencyMs: Date.now() - startTime,
              sources,
            };
          }
        }
      } catch (err) {
        console.warn('Tavily search error:', err);
      }
    }

    // 2. Brave Search API
    if (braveKey) {
      try {
        const url = `https://api.brave.com/res/v1/web/search?q=${encodeURIComponent(cleanedQuery)}&count=5`;
        const res = await fetch(url, {
          headers: {
            'Accept': 'application/json',
            'X-Subscription-Token': braveKey,
          },
        });
        if (res.ok) {
          const data = await res.json();
          const results = data.web?.results || [];
          const sources: SearchResultItem[] = results.slice(0, 5).map((r: any) => {
            let domain = '';
            try { domain = new URL(r.url).hostname.replace(/^www\./, ''); } catch (_) {}
            return {
              title: r.title || domain,
              url: r.url,
              domain: domain || 'web',
              snippet: r.description || '',
              publishedDate: r.page_age,
            };
          });
          if (sources.length > 0) {
            return {
              query: cleanedQuery,
              searched: true,
              provider: 'brave',
              latencyMs: Date.now() - startTime,
              sources,
            };
          }
        }
      } catch (err) {
        console.warn('Brave search error:', err);
      }
    }

    // 3. Serper (Google organic search API)
    if (serperKey) {
      try {
        const res = await fetch('https://google.serper.dev/search', {
          method: 'POST',
          headers: {
            'X-API-KEY': serperKey,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ q: cleanedQuery, num: 5 }),
        });
        if (res.ok) {
          const data = await res.json();
          const organic = data.organic || [];
          const sources: SearchResultItem[] = organic.slice(0, 5).map((r: any) => {
            let domain = '';
            try { domain = new URL(r.link).hostname.replace(/^www\./, ''); } catch (_) {}
            return {
              title: r.title || domain,
              url: r.link,
              domain: domain || 'web',
              snippet: r.snippet || '',
              publishedDate: r.date,
            };
          });
          if (sources.length > 0) {
            return {
              query: cleanedQuery,
              searched: true,
              provider: 'serper',
              latencyMs: Date.now() - startTime,
              sources,
            };
          }
        }
      } catch (err) {
        console.warn('Serper search error:', err);
      }
    }

    // 4. Reliable Zero-key Live Fallback: Wikipedia Encyclopedia API
    try {
      const wikiUrl = `https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=${encodeURIComponent(cleanedQuery)}&format=json&utf8=1&srlimit=5`;
      const res = await fetch(wikiUrl, {
        headers: { 'User-Agent': 'AiOrbit/1.0 (contact@ai-orbit.space)' },
      });
      if (res.ok) {
        const data = await res.json();
        const items = data.query?.search || [];
        if (items.length > 0) {
          const sources: SearchResultItem[] = items.slice(0, 5).map((item: any) => ({
            title: item.title,
            url: `https://en.wikipedia.org/wiki/${encodeURIComponent(item.title.replace(/ /g, '_'))}`,
            domain: 'en.wikipedia.org',
            snippet: (item.snippet || '').replace(/<[^>]+>/g, ''),
            publishedDate: new Date().toISOString().split('T')[0],
          }));
          return {
            query: cleanedQuery,
            searched: true,
            provider: 'wikipedia',
            latencyMs: Date.now() - startTime,
            sources,
          };
        }
      }
    } catch (err) {
      console.warn('Wikipedia fallback error:', err);
    }

    return {
      query: cleanedQuery,
      searched: true,
      provider: 'none',
      latencyMs: Date.now() - startTime,
      sources: [],
    };
  }
}

// AI Orbit — Model Status & Observatory Edge Function (`model-status`)
// Aggregates real-time health, latency, error rates, cooldown detection, and user quota.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.48.1';
import { corsHeaders } from '../_shared/cors.ts';
import { GatewayError, sanitizeError } from '../_shared/errors.ts';

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new GatewayError('unauthorized', 'Missing or invalid token', 401);
    }
    const token = authHeader.replace('Bearer ', '').trim();

    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new GatewayError('internal_error', 'Gateway configuration missing', 500);
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { data: authData, error: authError } = await supabase.auth.getUser(token);
    if (authError || !authData?.user) {
      throw new GatewayError('unauthorized', 'Invalid or expired session', 401);
    }
    const user = authData.user;

    // 1. Fetch all configured models
    const { data: models, error: modelsError } = await supabase
      .from('ai_models')
      .select('*')
      .order('priority', { ascending: true });

    if (modelsError) {
      throw new GatewayError('internal_error', 'Could not fetch models', 500);
    }

    // 2. Fetch recent model runs (last 1 hour) for health analytics
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString();
    const { data: recentRuns } = await supabase
      .from('model_runs')
      .select('model_id, status, latency_ms, first_token_ms, created_at')
      .gte('created_at', oneHourAgo);

    // Group runs by model_id
    const runsByModel = new Map<string, Array<{ status: string; latency_ms: number }>>();
    for (const run of recentRuns || []) {
      if (!runsByModel.has(run.model_id)) {
        runsByModel.set(run.model_id, []);
      }
      runsByModel.get(run.model_id)!.push(run);
    }

    // Compute health per model
    const evaluatedModels = (models || []).map((m) => {
      const runs = runsByModel.get(m.model_id) || [];
      const totalRuns = runs.length;
      const failedRuns = runs.filter((r) => r.status === 'failed').length;
      const errorRate = totalRuns > 0 ? failedRuns / totalRuns : 0;
      const avgLatency =
        totalRuns > 0
          ? Math.round(runs.reduce((acc, r) => acc + r.latency_ms, 0) / totalRuns)
          : 0;

      // Status evaluation:
      // - If not enabled: 'disabled'
      // - If recent failures >= 3 and errorRate > 0.4: 'cooldown'
      // - If avgLatency > 12000: 'degraded'
      // - Otherwise: 'healthy'
      let status: 'healthy' | 'degraded' | 'cooldown' | 'disabled' = 'healthy';
      if (!m.enabled) {
        status = 'disabled';
      } else if (failedRuns >= 3 && errorRate > 0.4) {
        status = 'cooldown';
      } else if (avgLatency > 12000) {
        status = 'degraded';
      }

      return {
        id: m.id,
        provider: m.provider,
        model_id: m.model_id,
        display_name: m.display_name,
        capabilities: m.capabilities,
        enabled: m.enabled,
        priority: m.priority,
        status,
        metrics: {
          total_runs_1h: totalRuns,
          failed_runs_1h: failedRuns,
          error_rate: Number((errorRate * 100).toFixed(1)),
          avg_latency_ms: avgLatency,
        },
      };
    });

    // 3. Fetch user daily quota usage
    const today = new Date().toISOString().slice(0, 10);
    const { data: usageData } = await supabase
      .from('user_usage')
      .select('request_count, token_count')
      .eq('user_id', user.id)
      .eq('period', today)
      .single();

    const dailyLimit = 50;
    const requestCount = usageData?.request_count ?? 0;
    const remaining = Math.max(0, dailyLimit - requestCount);

    return new Response(
      JSON.stringify({
        models: evaluatedModels,
        user_quota: {
          period: today,
          daily_count: requestCount,
          daily_limit: dailyLimit,
          remaining,
          token_count: usageData?.token_count ?? 0,
        },
      }),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
      },
    );
  } catch (err: unknown) {
    const sanitized = sanitizeError(err);
    return new Response(
      JSON.stringify({
        error: {
          code: sanitized.code,
          message: sanitized.message,
        },
      }),
      {
        status: sanitized.status,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
      },
    );
  }
});

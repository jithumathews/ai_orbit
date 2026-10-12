// AI Orbit — Edge Function: `ai-tasks`
// Handles AI Task Extraction from chat messages ('extract') and
// Natural-Language Quick Add parsing ('parse').
// Dedicated extraction model chain, server-side temporal resolution, strict validation, and zero DB writes.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.48.1';
import { corsHeaders } from '../_shared/cors.ts';
import { GatewayError, sanitizeError } from '../_shared/errors.ts';

interface DraftTask {
  title: string;
  description: string;
  priority: 'low' | 'medium' | 'high' | 'urgent';
  due_date: string | null;
  assigned_agent_slug: string | null;
  assignee_id: string | null;
  assignee_label: string | null;
  unresolved_assignee?: string | null;
}

const VALID_PRIORITIES = ['low', 'medium', 'high', 'urgent'] as const;
const MAX_TASKS = 8;
const MAX_TITLE_LEN = 80;
const MAX_DESC_LEN = 250;

const PLANET_MAP: Record<string, { slug: string; name: string }> = {
  earth: { slug: 'general', name: 'Earth' },
  general: { slug: 'general', name: 'Earth' },
  mars: { slug: 'coding', name: 'Mars' },
  coding: { slug: 'coding', name: 'Mars' },
  jupiter: { slug: 'creative', name: 'Jupiter' },
  creative: { slug: 'creative', name: 'Jupiter' },
  saturn: { slug: 'reasoning', name: 'Saturn' },
  reasoning: { slug: 'reasoning', name: 'Saturn' },
  neptune: { slug: 'research', name: 'Neptune' },
  research: { slug: 'research', name: 'Neptune' },
  pluto: { slug: 'multi-agent', name: 'Pluto' },
  'multi-agent': { slug: 'multi-agent', name: 'Pluto' },
};

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // 1. Authenticate JWT
    const authHeader = req.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new GatewayError('unauthorized', 'Missing or invalid authentication token', 401);
    }
    const token = authHeader.replace('Bearer ', '').trim();

    const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';

    if (!supabaseUrl || !supabaseServiceKey) {
      throw new GatewayError('internal_error', 'Gateway configuration error', 500);
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { data: authData, error: authError } = await supabase.auth.getUser(token);
    if (authError || !authData?.user) {
      throw new GatewayError('unauthorized', 'Invalid or expired session', 401);
    }
    const user = authData.user;

    // 2. Parse request payload
    let body: any;
    try {
      body = await req.json();
    } catch {
      throw new GatewayError('bad_request', 'Invalid JSON body', 400);
    }

    const mode = body.mode as 'extract' | 'parse';
    if (mode !== 'extract' && mode !== 'parse') {
      throw new GatewayError('bad_request', "mode must be either 'extract' or 'parse'", 400);
    }

    // 3. Atomic Quota Check
    const { data: quotaResult, error: quotaError } = await supabase.rpc(
      'check_and_increment_quota',
      {
        p_user_id: user.id,
        p_daily_limit: 50,
        p_rpm_limit: 15,
      },
    );

    if (quotaError) {
      console.error('Quota RPC error in ai-tasks:', quotaError);
      throw new GatewayError('internal_error', 'Failed to check quota', 500);
    }

    if (quotaResult && !quotaResult.allowed) {
      const code = quotaResult.error_code === 'rate_limited' ? 'rate_limited' : 'quota_exhausted';
      throw new GatewayError(code, quotaResult.error_message || 'Quota exceeded', 429);
    }

    let sourceText = '';
    let sourceMessageId: string | null = null;
    let sourceConversationId: string | null = null;
    const todayDate = body.today_date || new Date().toISOString().split('T')[0];
    const timezone = body.timezone || 'UTC';
    const workspaceId = body.workspace_id || null;
    let membersList: Array<{ user_id: string; email: string }> = [];

    // If workspace_id is provided, load member list for person name resolution
    if (workspaceId) {
      const { data: members } = await supabase.rpc('get_workspace_members', {
        p_workspace_id: workspaceId,
      });
      if (members && Array.isArray(members)) {
        membersList = members.map((m: any) => ({
          user_id: m.user_id,
          email: m.email || '',
        }));
      }
    }

    if (mode === 'extract') {
      const messageId = body.message_id;
      if (!messageId) {
        throw new GatewayError('bad_request', 'message_id is required in extract mode', 400);
      }
      sourceMessageId = messageId;

      // Load message from messages table
      const { data: msg, error: msgError } = await supabase
        .from('messages')
        .select('id, conversation_id, content, role, created_at')
        .eq('id', messageId)
        .single();

      if (msgError || !msg) {
        // Fallback: check chat_history
        const { data: histMsg, error: histError } = await supabase
          .from('chat_history')
          .select('id, content, role, user_id')
          .eq('id', messageId)
          .single();

        if (histError || !histMsg) {
          throw new GatewayError('not_found', 'Source message not found', 404);
        }
        if (histMsg.user_id !== user.id) {
          throw new GatewayError('unauthorized', 'Unauthorized access to message', 403);
        }
        sourceText = histMsg.content;
      } else {
        // Verify conversation belongs to user
        const { data: conv } = await supabase
          .from('conversations')
          .select('id, user_id')
          .eq('id', msg.conversation_id)
          .single();

        if (!conv || conv.user_id !== user.id) {
          throw new GatewayError('unauthorized', 'Unauthorized access to conversation', 403);
        }
        sourceConversationId = msg.conversation_id;
        sourceText = msg.content;

        // Phase B Item 4: If this is an assistant reply, also load the user's preceding request
        // so if the assistant refused or was brief, tasks are extracted from the user's intent!
        if (msg.role === 'assistant' && msg.conversation_id) {
          const { data: recentMsgs } = await supabase
            .from('messages')
            .select('content, role, created_at')
            .eq('conversation_id', msg.conversation_id)
            .lte('created_at', msg.created_at)
            .order('created_at', { ascending: false })
            .limit(4);

          if (recentMsgs && recentMsgs.length > 0) {
            const userMsg = recentMsgs.find((m: any) => m.role === 'user');
            if (userMsg && userMsg.content) {
              sourceText = `USER PROMPT:\n${userMsg.content}\n\nASSISTANT TRANSMISSION:\n${msg.content}\n\nINSTRUCTION: Extract all actionable tasks. If the assistant transmission gave concrete tasks, extract them. If the assistant gave an error, refusal, or lacked specific items, extract the intended tasks directly from the USER PROMPT.`;
            }
          }
        }
      }
    } else {
      // mode === 'parse' (quick add)
      const text = body.text;
      if (!text || typeof text !== 'string' || text.trim().length === 0) {
        throw new GatewayError('bad_request', 'text is required in parse mode', 400);
      }
      if (text.length > 1000) {
        throw new GatewayError('bad_request', 'Input text exceeds 1,000 characters', 400);
      }
      sourceText = text.trim();
    }

    // 4. Precompute relative dates based on client's today_date
    const baseDate = new Date(todayDate);
    const dayOfWeek = baseDate.getDay(); // 0 is Sun, 1 is Mon, 2 is Tue, 3 is Wed, 4 is Thu, 5 is Fri, 6 is Sat

    const tomorrow = new Date(baseDate);
    tomorrow.setDate(tomorrow.getDate() + 1);
    const tomorrowStr = tomorrow.toISOString().split('T')[0];

    const daysUntilFriday = ((5 - dayOfWeek) + 7) % 7;
    const thisFriday = new Date(baseDate);
    thisFriday.setDate(thisFriday.getDate() + (daysUntilFriday === 0 ? 7 : daysUntilFriday));
    const thisFridayStr = thisFriday.toISOString().split('T')[0];

    // If today is Monday (day 1), "by Monday" resolves to next Monday (7 days later)
    const daysUntilNextMonday = ((1 - dayOfWeek + 7) % 7) === 0 ? 7 : ((1 - dayOfWeek + 7) % 7);
    const nextMonday = new Date(baseDate);
    nextMonday.setDate(nextMonday.getDate() + daysUntilNextMonday);
    const nextMondayStr = nextMonday.toISOString().split('T')[0];

    const membersPrompt = membersList.length > 0
      ? `Available Team Members (assignee_id strictly for these UUIDs):\n` + membersList.map((m) => `- "${m.email}" -> ID: ${m.user_id}`).join('\n')
      : `No external team members available.`;

    const systemPrompt = `You are the AI Orbit Task Extraction Engine.
Analyze the provided text and extract actionable orbital tasks as a JSON array.

Temporal Reference (Client Date: ${todayDate}, Timezone: ${timezone}):
- "today" -> "${todayDate}"
- "tomorrow" -> "${tomorrowStr}"
- "this Friday" or "by Friday" -> "${thisFridayStr}"
- "by Monday" or "next Monday" -> "${nextMondayStr}"

Planetary AI Agent Mapping:
- "with Saturn" or "give to Saturn" -> assigned_agent_slug: "reasoning", assignee_label: "Saturn"
- "with Mars" or "give to Mars" -> assigned_agent_slug: "coding", assignee_label: "Mars"
- "with Earth" or "give to Earth" -> assigned_agent_slug: "general", assignee_label: "Earth"
- "with Jupiter" or "give to Jupiter" -> assigned_agent_slug: "creative", assignee_label: "Jupiter"
- "with Neptune" or "give to Neptune" -> assigned_agent_slug: "research", assignee_label: "Neptune"
- "with Pluto" -> assigned_agent_slug: "multi-agent", assignee_label: "Pluto"

CRITICAL SECURITY RULES:
- NEVER write planet names into "assignee_id". "assignee_id" is exclusively for human member UUIDs.
- Planetary intelligence assignments MUST go into "assigned_agent_slug".

${membersPrompt}

OUTPUT FORMAT RULES:
1. Output ONLY a valid JSON array of objects. Never wrap in markdown formatting or explanatory text.
2. Object Schema:
   {
     "title": string (max 80 chars, concise action title),
     "description": string (max 250 chars, key context or details),
     "priority": "low" | "medium" | "high" | "urgent",
     "due_date": string (YYYY-MM-DD format) or null,
     "assigned_agent_slug": string ("general" | "coding" | "creative" | "reasoning" | "research" | "multi-agent") or null,
     "assignee_id": string (UUID of matched team member) or null,
     "assignee_label": string (display label of planet or person) or null,
     "unresolved_assignee": string or null
   }
3. Maximum ${MAX_TASKS} tasks. If no actionable tasks exist, return empty array [].
4. Map urgency keywords ("urgent", "asap", "critical", "blocker") to priority "urgent".
5. SINGLE vs MULTIPLE TASKS:
   - When a statement specifies an action followed by attributes (e.g. "Fix quota RPC by Friday, urgent, assign to Mars"), output strictly ONE task object combining these attributes.
   - NEVER create separate task items for standalone priority modifiers ("urgent"), assignment clauses ("assign to Mars"), or due dates ("by Friday").
   - Only output multiple task objects when there are genuinely multiple distinct actions (e.g. "Deploy X today, test Y tomorrow, write Z by Monday").
`;

    // 5. Invoke Dedicated Extraction Model Order (Phase C Item 3)
    let rawResponse = await callExtractionModels(systemPrompt, sourceText);
    let parsedTasks = tryParseTasks(rawResponse);

    if (!parsedTasks || parsedTasks.length === 0) {
      console.warn('First parse attempt empty or failed. Retrying with explicit fix prompt...');
      const retryPrompt = `${systemPrompt}\n\nIMPORTANT: The previous output failed JSON validation. Provide ONLY pure JSON array: [ ... ]`;
      rawResponse = await callExtractionModels(retryPrompt, sourceText);
      parsedTasks = tryParseTasks(rawResponse);
    }

    // Heuristic deterministic extraction only if the input has real imperative clauses
    if (!parsedTasks || parsedTasks.length === 0) {
      parsedTasks = tryExtractImperativeClauses(sourceText, todayDate, tomorrowStr, nextMondayStr);
    }

    // 6. Honest verification: Never return a stub placeholder
    if (!parsedTasks || parsedTasks.length === 0) {
      return new Response(
        JSON.stringify({
          success: true,
          mode,
          source_message_id: sourceMessageId,
          source_conversation_id: sourceConversationId,
          tasks_count: 0,
          tasks: [],
          reason: 'no_tasks_found',
        }),
        {
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json',
          },
        },
      );
    }

    // 7. Sanitize, clamp, and map fields
    const validatedTasks: DraftTask[] = parsedTasks
      .slice(0, MAX_TASKS)
      .map((t: any) => sanitizeTask(t, membersList))
      .filter((t): t is DraftTask => t !== null && t.title.length > 0);

    return new Response(
      JSON.stringify({
        success: true,
        mode,
        source_message_id: sourceMessageId,
        source_conversation_id: sourceConversationId,
        tasks_count: validatedTasks.length,
        tasks: validatedTasks,
      }),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
      },
    );
  } catch (err: unknown) {
    console.error('ai-tasks error:', err);
    const sanitized = sanitizeError(err);
    return new Response(
      JSON.stringify({
        success: false,
        error_code: sanitized.code,
        message: sanitized.message,
      }),
      {
        status: (err as any).statusCode || 500,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
      },
    );
  }
});

// Dedicated Extraction Model Chain (Phase C Item 3)
async function callExtractionModels(systemPrompt: string, userText: string): Promise<string> {
  const openrouterKey = Deno.env.get('OPENROUTER_API_KEY');
  const groqKey = Deno.env.get('GROQ_API_KEY');
  const openaiKey = Deno.env.get('OPENAI_API_KEY');

  const openrouterModels = [
    'meta-llama/llama-3.3-70b-instruct:free',
    'mistralai/mistral-small-24b-instruct-2501:free',
    'openrouter/free',
  ];

  if (openrouterKey) {
    for (const modelId of openrouterModels) {
      try {
        const resp = await fetch('https://openrouter.ai/api/v1/chat/completions', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${openrouterKey}`,
          },
          body: JSON.stringify({
            model: modelId,
            messages: [
              { role: 'system', content: systemPrompt },
              { role: 'user', content: userText },
            ],
            temperature: 0.1,
            max_tokens: 1500,
          }),
        });

        if (resp.ok) {
          const data = await resp.json();
          const content = data.choices?.[0]?.message?.content;
          if (content && content.trim().length > 0) {
            return content;
          }
        } else {
          console.warn(`Extraction model ${modelId} failed with HTTP ${resp.status}`);
        }
      } catch (err) {
        console.warn(`Extraction model ${modelId} network error:`, err);
      }
    }
  }

  if (groqKey) {
    try {
      const resp = await fetch('https://api.groq.com/openai/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${groqKey}`,
        },
        body: JSON.stringify({
          model: 'llama-3.3-70b-versatile',
          messages: [
            { role: 'system', content: systemPrompt },
            { role: 'user', content: userText },
          ],
          temperature: 0.1,
          max_tokens: 1500,
        }),
      });
      if (resp.ok) {
        const data = await resp.json();
        return data.choices?.[0]?.message?.content || '';
      }
    } catch (e) {
      console.warn('Groq extraction error:', e);
    }
  }

  if (openaiKey) {
    try {
      const resp = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${openaiKey}`,
        },
        body: JSON.stringify({
          model: 'gpt-4o-mini',
          messages: [
            { role: 'system', content: systemPrompt },
            { role: 'user', content: userText },
          ],
          temperature: 0.1,
          max_tokens: 1500,
        }),
      });
      if (resp.ok) {
        const data = await resp.json();
        return data.choices?.[0]?.message?.content || '';
      }
    } catch (e) {
      console.warn('OpenAI extraction error:', e);
    }
  }

  return '';
}

// Strip markdown fences & parse JSON
function tryParseTasks(raw: string): any[] | null {
  if (!raw || !raw.trim()) return null;

  let cleaned = raw.trim();
  if (cleaned.startsWith('```')) {
    cleaned = cleaned.replace(/^```[a-zA-Z]*\n?/, '').replace(/\n?```$/, '').trim();
  }

  const startIdx = cleaned.indexOf('[');
  const endIdx = cleaned.lastIndexOf(']');
  if (startIdx !== -1 && endIdx !== -1 && endIdx > startIdx) {
    cleaned = cleaned.substring(startIdx, endIdx + 1);
  }

  try {
    const parsed = JSON.parse(cleaned);
    if (Array.isArray(parsed)) {
      return parsed;
    }
  } catch {
    // Parsing error
  }
  return null;
}

// Sanitize, whitelist, and clamp task object
function sanitizeTask(
  t: any,
  membersList: Array<{ user_id: string; email: string }>,
): DraftTask | null {
  if (!t || typeof t !== 'object') return null;

  let title = String(t.title || '').trim();
  if (!title) return null;
  if (title.length > MAX_TITLE_LEN) {
    title = title.substring(0, MAX_TITLE_LEN);
  }

  let description = String(t.description || '').trim();
  if (description.length > MAX_DESC_LEN) {
    description = description.substring(0, MAX_DESC_LEN);
  }

  let priority = String(t.priority || 'medium').toLowerCase() as DraftTask['priority'];
  if (!VALID_PRIORITIES.includes(priority)) {
    if (priority.includes('urgent') || priority.includes('asap') || priority.includes('crit')) {
      priority = 'urgent';
    } else if (priority.includes('high')) {
      priority = 'high';
    } else if (priority.includes('low')) {
      priority = 'low';
    } else {
      priority = 'medium';
    }
  }

  let dueDate: string | null = null;
  if (t.due_date && typeof t.due_date === 'string') {
    const d = new Date(t.due_date);
    if (!isNaN(d.getTime())) {
      dueDate = d.toISOString();
    }
  }

  let assignedAgentSlug: string | null = null;
  let assigneeLabel: string | null = null;
  let assigneeId: string | null = null;
  let unresolvedAssignee: string | null = t.unresolved_assignee || null;

  const rawAgent = String(t.assigned_agent_slug || '').toLowerCase().trim();
  if (PLANET_MAP[rawAgent]) {
    assignedAgentSlug = PLANET_MAP[rawAgent].slug;
    assigneeLabel = PLANET_MAP[rawAgent].name;
  }

  // Check if assignee_label corresponds to a planet
  if (t.assignee_label && typeof t.assignee_label === 'string') {
    const searchPlanet = t.assignee_label.toLowerCase().trim();
    if (PLANET_MAP[searchPlanet]) {
      assignedAgentSlug = PLANET_MAP[searchPlanet].slug;
      assigneeLabel = PLANET_MAP[searchPlanet].name;
    } else {
      // Check team members
      const matched = membersList.find((m) => m.email.toLowerCase().includes(searchPlanet));
      if (matched) {
        assigneeId = matched.user_id;
        assigneeLabel = matched.email;
      } else {
        unresolvedAssignee = t.assignee_label;
      }
    }
  }

  // Check explicit assignee_id
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  if (t.assignee_id && typeof t.assignee_id === 'string' && uuidRegex.test(t.assignee_id)) {
    const matched = membersList.find((m) => m.user_id === t.assignee_id);
    if (matched) {
      assigneeId = matched.user_id;
      assigneeLabel = matched.email;
    }
  }

  return {
    title,
    description,
    priority,
    due_date: dueDate,
    assigned_agent_slug: assignedAgentSlug,
    assignee_id: assigneeId,
    assignee_label: assigneeLabel,
    unresolved_assignee: unresolvedAssignee,
  };
}

// Imperative clause parser for real commands when LLM is unavailable
function tryExtractImperativeClauses(
  text: string,
  todayStr: string,
  tomorrowStr: string,
  nextMondayStr: string,
): any[] {
  let clean = text.replace(/^(USER PROMPT:|INSTRUCTION:|ASSISTANT TRANSMISSION:).*?\n/g, '').trim();
  clean = clean.replace(/^(?:add|create|new)\s+(?:a\s+)?tasks?\s*(?:to\s*)?:?\s*/i, '').trim();

  const clauses = clean
    .split(/(?:,|\band\b|;|\n)/i)
    .map((c) => c.trim())
    .filter((c) => c.length > 0);

  const actionVerbRegex = /^(deploy|test|write|fix|update|implement|review|verify|check|create|build|prepare|refactor|design|ship|publish|audit)\b/i;
  const priorityRegex = /^(urgent|asap|critical|high(?:\s+priority)?|medium(?:\s+priority)?|low(?:\s+priority)?)$/i;
  const assigneeRegex = /^(?:assign(?:ed)?\s+(?:it\s+)?to|give\s+(?:it\s+)?to|with|for|assignee:?)\s+([a-zA-Z0-9_\-\.\@\s]+)$/i;
  const temporalOnlyRegex = /^(?:by|due|on)?\s*(today|tomorrow|monday|tuesday|wednesday|thursday|friday|saturday|sunday|next\s+week|this\s+week)$/i;

  const found: any[] = [];

  for (const clause of clauses) {
    const lower = clause.toLowerCase();

    // Check if priority modifier
    if (priorityRegex.test(clause)) {
      let p = 'medium';
      if (/urgent|asap|critical/i.test(lower)) p = 'urgent';
      else if (/high/i.test(lower)) p = 'high';
      else if (/low/i.test(lower)) p = 'low';

      if (found.length > 0) {
        found[found.length - 1].priority = p;
      }
      continue;
    }

    // Check if assignee modifier
    const assignMatch = clause.match(assigneeRegex);
    if (assignMatch) {
      const target = assignMatch[1].toLowerCase().trim();
      let slug: string | null = null;
      let label: string | null = null;
      for (const [key, val] of Object.entries(PLANET_MAP)) {
        if (target.includes(key)) {
          slug = val.slug;
          label = val.name;
          break;
        }
      }
      if (found.length > 0) {
        found[found.length - 1].assigned_agent_slug = slug;
        found[found.length - 1].assignee_label = label || assignMatch[1].trim();
      }
      continue;
    }

    // Check if temporal-only modifier
    if (temporalOnlyRegex.test(clause)) {
      let dueDate: string | null = null;
      if (lower.includes('today')) dueDate = todayStr;
      else if (lower.includes('tomorrow')) dueDate = tomorrowStr;
      else if (lower.includes('monday')) dueDate = nextMondayStr;

      if (found.length > 0 && dueDate) {
        found[found.length - 1].due_date = dueDate;
      }
      continue;
    }

    // Action or title clause
    let priority = 'medium';
    if (/urgent|asap|critical/i.test(lower)) priority = 'urgent';
    else if (/high|important/i.test(lower)) priority = 'high';

    let dueDate: string | null = null;
    if (lower.includes('today')) dueDate = todayStr;
    else if (lower.includes('tomorrow')) dueDate = tomorrowStr;
    else if (lower.includes('monday')) dueDate = nextMondayStr;

    let slug: string | null = null;
    let label: string | null = null;
    for (const [key, val] of Object.entries(PLANET_MAP)) {
      if (new RegExp(`\\b${key}\\b`, 'i').test(lower)) {
        slug = val.slug;
        label = val.name;
        break;
      }
    }

    let cleanTitle = clause.trim();
    cleanTitle = cleanTitle.replace(/\b(today|tomorrow|by monday|by friday|with saturn|with mars|with earth)\b/gi, '').trim();

    found.push({
      title: cleanTitle.length > 80 ? cleanTitle.substring(0, 80) : (cleanTitle || clause),
      description: `Action item: "${clause}"`,
      priority,
      due_date: dueDate,
      assigned_agent_slug: slug,
      assignee_label: label,
      assignee_id: null,
    });
  }

  return found;
}

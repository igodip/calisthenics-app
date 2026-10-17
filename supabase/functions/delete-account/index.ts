import { createClient } from 'npm:@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

const json = (body: unknown, status = 200) => new Response(JSON.stringify(body), {
  status, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
});

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  if (request.method !== 'POST') return json({ error: 'Method not allowed' }, 405);
  const authorization = request.headers.get('Authorization');
  if (!authorization?.startsWith('Bearer ')) return json({ error: 'Authentication required' }, 401);
  try {
    const client = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
      global: { headers: { Authorization: authorization } },
    });
    const { data: { user }, error } = await client.auth.getUser();
    if (error || !user) return json({ error: 'Invalid session' }, 401);
    let body;
    try { body = await request.json(); } catch { return json({ error: 'Invalid request' }, 400); }
    if (body?.confirm !== true) return json({ error: 'Explicit confirmation required' }, 400);

    // Never accept a target user ID from the caller.
    const admin = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
    const files: string[] = [];
    async function collect(bucket: string, prefix: string) {
      for (let offset = 0; ; offset += 100) {
        const { data, error } = await admin.storage.from(bucket).list(prefix, {
          limit: 100,
          offset,
          sortBy: { column: 'name', order: 'asc' },
        });
        if (error) throw error;
        for (const item of data ?? []) {
          const path = `${prefix}/${item.name}`;
          if (item.id) files.push(path);
          else await collect(bucket, path);
        }
        if (!data || data.length < 100) break;
      }
    }
    for (const bucket of ['avatars', 'workout-plan-pdfs']) {
      files.length = 0;
      await collect(bucket, user.id);
      for (let offset = 0; offset < files.length; offset += 100) {
        const { error } = await admin.storage.from(bucket).remove(files.slice(offset, offset + 100));
        if (error) throw error;
      }
    }
    const { error: deletionError } = await admin.rpc('delete_account_data', { p_user_id: user.id });
    if (deletionError) throw deletionError;
    return json({ deleted: true });
  } catch (_) {
    // Do not log personal data or request credentials.
    console.error('Account deletion failed');
    return json({ error: 'Deletion could not be completed. Retry or contact support.' }, 500);
  }
});

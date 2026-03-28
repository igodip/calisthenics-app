import { corsHeaders } from '../_shared/cors.ts';
import {
  decodeState,
} from '../_shared/fitbit.ts';
import { createClient } from 'jsr:@supabase/supabase-js@2';

function errorRedirectUri(
  redirectUri: string,
  error: string,
): Response {
  const url = new URL(redirectUri);
  url.searchParams.set('status', 'error');
  url.searchParams.set('error', error);
  return Response.redirect(url.toString(), 302);
}

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
  const fitbitClientId = Deno.env.get('FITBIT_CLIENT_ID') ?? '';
  const fitbitClientSecret = Deno.env.get('FITBIT_CLIENT_SECRET') ?? '';
  const fitbitRedirectUri = Deno.env.get('FITBIT_REDIRECT_URI') ?? '';

  if (
    !supabaseUrl ||
    !serviceRoleKey ||
    !fitbitClientId ||
    !fitbitClientSecret ||
    !fitbitRedirectUri
  ) {
    return new Response('Missing required environment variables.', {
      status: 500,
      headers: corsHeaders,
    });
  }

  const requestUrl = new URL(request.url);
  const adminClient = createClient(supabaseUrl, serviceRoleKey);

  const authCode = requestUrl.searchParams.get('code');
  const statePayload = decodeState(requestUrl.searchParams.get('state'));

  if (authCode && statePayload) {
    const tokenResponse = await fetch('https://api.fitbit.com/oauth2/token', {
      method: 'POST',
      headers: {
        Authorization: `Basic ${btoa(`${fitbitClientId}:${fitbitClientSecret}`)}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        client_id: fitbitClientId,
        grant_type: 'authorization_code',
        redirect_uri: fitbitRedirectUri,
        code: authCode,
      }),
    });

    if (!tokenResponse.ok) {
      return errorRedirectUri(
        statePayload.mobileRedirectUri,
        `fitbit-token-exchange-failed-${tokenResponse.status}`,
      );
    }

    const tokenPayload = await tokenResponse.json();
    const now = new Date();
    const expiresAt = new Date(
      now.getTime() + Number(tokenPayload.expires_in ?? 0) * 1000,
    );

    const { error } = await adminClient.from('fitbit_connections').upsert({
      user_id: statePayload.userId,
      fitbit_user_id: tokenPayload.user_id ?? null,
      scope: tokenPayload.scope ?? null,
      access_token: tokenPayload.access_token,
      refresh_token: tokenPayload.refresh_token,
      token_type: tokenPayload.token_type ?? 'Bearer',
      expires_at: expiresAt.toISOString(),
      linked_at: now.toISOString(),
      updated_at: now.toISOString(),
    });

    if (error) {
      return errorRedirectUri(
        statePayload.mobileRedirectUri,
        `fitbit-save-failed-${error.message}`,
      );
    }

    const successUri = new URL(statePayload.mobileRedirectUri);
    successUri.searchParams.set('status', 'success');
    successUri.searchParams.set('fitbit_user_id', tokenPayload.user_id ?? '');
    successUri.searchParams.set('scope', tokenPayload.scope ?? '');
    successUri.searchParams.set('linked_at', now.toISOString());
    return Response.redirect(successUri.toString(), 302);
  }

  return new Response('Use fitbit-connect-init to start the OAuth flow.', {
    status: 400,
    headers: corsHeaders,
  });
});

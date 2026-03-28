import { corsHeaders } from '../_shared/cors.ts';
import {
  buildFitbitAuthorizeUrl,
  encodeState,
} from '../_shared/fitbit.ts';
import { createClient } from 'jsr:@supabase/supabase-js@2';

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
  const fitbitClientId = Deno.env.get('FITBIT_CLIENT_ID') ?? '';
  const fitbitRedirectUri = Deno.env.get('FITBIT_REDIRECT_URI') ?? '';

  if (!supabaseUrl || !supabaseAnonKey || !fitbitClientId || !fitbitRedirectUri) {
    return new Response('Missing required environment variables.', {
      status: 500,
      headers: corsHeaders,
    });
  }

  const authorization = request.headers.get('Authorization') ?? '';
  const userClient = createClient(supabaseUrl, supabaseAnonKey, {
    global: {
      headers: { Authorization: authorization },
    },
  });

  const {
    data: { user },
    error: userError,
  } = await userClient.auth.getUser();

  if (userError || !user) {
    return new Response('Unauthorized', {
      status: 401,
      headers: corsHeaders,
    });
  }

  const requestUrl = new URL(request.url);
  const mobileRedirectUri =
    requestUrl.searchParams.get('redirect_uri') ??
    'com.idipaolo.calisync://fitbit-callback';
  const state = encodeState({
    userId: user.id,
    mobileRedirectUri,
  });

  const authorizeUrl = buildFitbitAuthorizeUrl({
    clientId: fitbitClientId,
    redirectUri: fitbitRedirectUri,
    state,
  });

  return new Response(
    JSON.stringify({
      authorize_url: authorizeUrl.toString(),
    }),
    {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json',
      },
    },
  );
});

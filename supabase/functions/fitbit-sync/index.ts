import { corsHeaders } from '../_shared/cors.ts';
import {
  FITBIT_API_BASE_URL,
  fitbitBasicAuthHeader,
  jsonResponse,
} from '../_shared/fitbit.ts';
import { createClient } from 'jsr:@supabase/supabase-js@2';

type FitbitConnectionRow = {
  user_id: string;
  fitbit_user_id: string | null;
  scope: string | null;
  access_token: string;
  refresh_token: string;
  token_type: string | null;
  expires_at: string | null;
};

async function refreshAccessToken(params: {
  connection: FitbitConnectionRow;
  fitbitClientId: string;
  fitbitClientSecret: string;
}) {
  const response = await fetch('https://api.fitbit.com/oauth2/token', {
    method: 'POST',
    headers: {
      Authorization: fitbitBasicAuthHeader(
        params.fitbitClientId,
        params.fitbitClientSecret,
      ),
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: new URLSearchParams({
      grant_type: 'refresh_token',
      refresh_token: params.connection.refresh_token,
    }),
  });

  if (!response.ok) {
    throw new Error(`fitbit-refresh-failed-${response.status}`);
  }

  return await response.json();
}

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
  const fitbitClientId = Deno.env.get('FITBIT_CLIENT_ID') ?? '';
  const fitbitClientSecret = Deno.env.get('FITBIT_CLIENT_SECRET') ?? '';

  if (
    !supabaseUrl ||
    !supabaseAnonKey ||
    !serviceRoleKey ||
    !fitbitClientId ||
    !fitbitClientSecret
  ) {
    return jsonResponse(
      { error: 'Missing required environment variables.' },
      { status: 500, headers: corsHeaders },
    );
  }

  const authorization = request.headers.get('Authorization') ?? '';
  const userClient = createClient(supabaseUrl, supabaseAnonKey, {
    global: {
      headers: { Authorization: authorization },
    },
  });
  const adminClient = createClient(supabaseUrl, serviceRoleKey);

  const {
    data: { user },
    error: userError,
  } = await userClient.auth.getUser();

  if (userError || !user) {
    return jsonResponse({ error: 'Unauthorized' }, {
      status: 401,
      headers: corsHeaders,
    });
  }

  const { data: connection, error: connectionError } = await adminClient
    .from('fitbit_connections')
    .select(
      'user_id, fitbit_user_id, scope, access_token, refresh_token, token_type, expires_at',
    )
    .eq('user_id', user.id)
    .maybeSingle<FitbitConnectionRow>();

  if (connectionError || !connection) {
    return jsonResponse({ error: 'Fitbit connection not found.' }, {
      status: 404,
      headers: corsHeaders,
    });
  }

  let accessToken = connection.access_token;
  let refreshToken = connection.refresh_token;
  let tokenScope = connection.scope;
  let fitbitUserId = connection.fitbit_user_id;
  let expiresAt = connection.expires_at;

  const isExpired =
    expiresAt == null ||
    Number.isNaN(new Date(expiresAt).getTime()) ||
    new Date(expiresAt).getTime() <= Date.now() + 30_000;

  if (isExpired) {
    const refreshed = await refreshAccessToken({
      connection,
      fitbitClientId,
      fitbitClientSecret,
    });
    accessToken = refreshed.access_token;
    refreshToken = refreshed.refresh_token ?? refreshToken;
    tokenScope = refreshed.scope ?? tokenScope;
    fitbitUserId = refreshed.user_id ?? fitbitUserId;
    expiresAt = new Date(
      Date.now() + Number(refreshed.expires_in ?? 0) * 1000,
    ).toISOString();

    const { error: updateError } = await adminClient
      .from('fitbit_connections')
      .update({
        access_token: accessToken,
        refresh_token: refreshToken,
        fitbit_user_id: fitbitUserId,
        scope: tokenScope,
        expires_at: expiresAt,
        updated_at: new Date().toISOString(),
      })
      .eq('user_id', user.id);

    if (updateError) {
      return jsonResponse({ error: updateError.message }, {
        status: 500,
        headers: corsHeaders,
      });
    }
  }

  const activityDate = new Date().toISOString().slice(0, 10);
  const [summaryResponse, heartResponse, vo2MaxResponse] = await Promise.all([
    fetch(`${FITBIT_API_BASE_URL}/1/user/-/activities/date/${activityDate}.json`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    }),
    fetch(
      `${FITBIT_API_BASE_URL}/1/user/-/activities/heart/date/${activityDate}/1d.json`,
      {
        headers: { Authorization: `Bearer ${accessToken}` },
      },
    ),
    fetch(`${FITBIT_API_BASE_URL}/1/user/-/cardioscore/date/${activityDate}.json`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    }),
  ]);

  if (!summaryResponse.ok || !heartResponse.ok) {
    return jsonResponse(
      {
        error: `fitbit-fetch-failed-${summaryResponse.status}-${heartResponse.status}`,
      },
      { status: 502, headers: corsHeaders },
    );
  }

  const summaryPayload = await summaryResponse.json();
  const heartPayload = await heartResponse.json();
  const vo2MaxPayload = vo2MaxResponse.ok ? await vo2MaxResponse.json() : null;

  const summary = summaryPayload.summary ?? {};
  const heartActivities = heartPayload['activities-heart'];
  const heartData = Array.isArray(heartActivities) && heartActivities.length > 0
    ? heartActivities[0]?.value ?? {}
    : {};
  const cardioScoreEntries = vo2MaxPayload?.['cardioScore'];
  const cardioScore = Array.isArray(cardioScoreEntries) && cardioScoreEntries.length > 0
    ? cardioScoreEntries[0]?.value ?? {}
    : {};
  const vo2Max = typeof cardioScore['vo2Max'] === 'string'
    ? cardioScore['vo2Max']
    : null;

  const activeZoneMinutes =
    Number(summary.veryActiveMinutes ?? 0) +
    Number(summary.fairlyActiveMinutes ?? 0);

  const normalized = {
    fitbit_user_id: fitbitUserId,
    last_sync_at: new Date().toISOString(),
    scope: tokenScope ?? '',
    summary: {
      activity_date: activityDate,
      steps: Number(summary.steps ?? 0),
      calories: Number(summary.caloriesOut ?? 0),
      resting_heart_rate: heartData['restingHeartRate'] == null
          ? null
          : Number(heartData['restingHeartRate']),
      active_zone_minutes: activeZoneMinutes,
      vo2_max: vo2Max,
    },
  };

  await adminClient.from('fitbit_connections').update({
    last_sync_at: normalized.last_sync_at,
    updated_at: normalized.last_sync_at,
  }).eq('user_id', user.id);

  return jsonResponse(normalized, { headers: corsHeaders });
});

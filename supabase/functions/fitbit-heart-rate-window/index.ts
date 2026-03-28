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

async function getAccessToken(params: {
  adminClient: ReturnType<typeof createClient>;
  userId: string;
  fitbitClientId: string;
  fitbitClientSecret: string;
}) {
  const { data: connection, error } = await params.adminClient
    .from('fitbit_connections')
    .select(
      'user_id, fitbit_user_id, scope, access_token, refresh_token, expires_at',
    )
    .eq('user_id', params.userId)
    .maybeSingle<FitbitConnectionRow>();

  if (error || !connection) {
    throw new Error('fitbit-connection-not-found');
  }

  const isExpired =
    connection.expires_at == null ||
    Number.isNaN(new Date(connection.expires_at).getTime()) ||
    new Date(connection.expires_at).getTime() <= Date.now() + 30_000;

  if (!isExpired) {
    return connection.access_token;
  }

  const refreshed = await refreshAccessToken({
    connection,
    fitbitClientId: params.fitbitClientId,
    fitbitClientSecret: params.fitbitClientSecret,
  });
  const expiresAt = new Date(
    Date.now() + Number(refreshed.expires_in ?? 0) * 1000,
  ).toISOString();

  const { error: updateError } = await params.adminClient
    .from('fitbit_connections')
    .update({
      access_token: refreshed.access_token,
      refresh_token: refreshed.refresh_token ?? connection.refresh_token,
      fitbit_user_id: refreshed.user_id ?? connection.fitbit_user_id,
      scope: refreshed.scope ?? connection.scope,
      expires_at: expiresAt,
      updated_at: new Date().toISOString(),
    })
    .eq('user_id', params.userId);

  if (updateError) {
    throw new Error(updateError.message);
  }

  return refreshed.access_token as string;
}

function formatDate(value: Date): string {
  return value.toISOString().slice(0, 10);
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

  const requestUrl = new URL(request.url);
  const startAtValue = requestUrl.searchParams.get('start_at');
  const endAtValue = requestUrl.searchParams.get('end_at');
  if (!startAtValue || !endAtValue) {
    return jsonResponse(
      { error: 'start_at and end_at are required.' },
      { status: 400, headers: corsHeaders },
    );
  }

  const startAt = new Date(startAtValue);
  const endAt = new Date(endAtValue);
  if (
    Number.isNaN(startAt.getTime()) ||
    Number.isNaN(endAt.getTime()) ||
    endAt.getTime() <= startAt.getTime()
  ) {
    return jsonResponse(
      { error: 'Invalid start_at/end_at range.' },
      { status: 400, headers: corsHeaders },
    );
  }

  if (formatDate(startAt) != formatDate(endAt)) {
    return jsonResponse(
      { error: 'Only same-day timer windows are currently supported.' },
      { status: 400, headers: corsHeaders },
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
    return jsonResponse(
      { error: 'Unauthorized' },
      { status: 401, headers: corsHeaders },
    );
  }

  const accessToken = await getAccessToken({
    adminClient,
    userId: user.id,
    fitbitClientId,
    fitbitClientSecret,
  });

  const date = formatDate(startAt);
  const detailLevels = ['1sec', '1min'];

  let detailLevelUsed = '1min';
  let heartPayload: Record<string, unknown> | null = null;

  for (const detailLevel of detailLevels) {
    const response = await fetch(
      `${FITBIT_API_BASE_URL}/1/user/-/activities/heart/date/${date}/${date}/${detailLevel}.json?timezone=UTC`,
      {
        headers: { Authorization: `Bearer ${accessToken}` },
      },
    );
    if (response.ok) {
      detailLevelUsed = detailLevel;
      heartPayload = await response.json();
      break;
    }
    if (detailLevel === '1min') {
      const responseBody = await response.text();
      return jsonResponse(
        {
          error: `fitbit-heart-window-failed-${response.status}`,
          fitbit_response: responseBody,
        },
        { status: 502, headers: corsHeaders },
      );
    }
  }

  const heartIntraday = (heartPayload?.['activities-heart-intraday'] ?? null) as
    | Record<string, unknown>
    | null;
  const rawDataset = (heartIntraday?.['dataset'] ?? []) as Array<
    Record<string, unknown>
  >;
  const samples = rawDataset
    .map((sample) => {
      const time = sample['time'] as string;
      const sampledAt = new Date(`${date}T${time}.000Z`);
      return {
        sampled_at: sampledAt.toISOString(),
        sampled_at_ms: sampledAt.getTime(),
        value: Number(sample['value'] ?? 0),
      };
    })
    .filter((sample) => {
      return (
        sample.sampled_at_ms >= startAt.getTime() &&
        sample.sampled_at_ms <= endAt.getTime()
      );
    })
    .map(({ sampled_at, value }) => ({
      sampled_at,
      value,
    }));

  return jsonResponse(
    {
      start_at: startAt.toISOString(),
      end_at: endAt.toISOString(),
      detail_level_used: detailLevelUsed,
      samples,
    },
    { headers: corsHeaders },
  );
});

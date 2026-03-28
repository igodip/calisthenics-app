export const FITBIT_API_BASE_URL = 'https://api.fitbit.com';
export const FITBIT_OAUTH_AUTHORIZE_URL =
  'https://www.fitbit.com/oauth2/authorize';
export const DEFAULT_FITBIT_SCOPES = [
  'activity',
  'heartrate',
  'profile',
  'cardio_fitness',
];

export function jsonResponse(
  body: unknown,
  init: ResponseInit = {},
): Response {
  return new Response(JSON.stringify(body), {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...(init.headers ?? {}),
    },
  });
}

export function fitbitBasicAuthHeader(
  clientId: string,
  clientSecret: string,
): string {
  return `Basic ${btoa(`${clientId}:${clientSecret}`)}`;
}

export function buildFitbitAuthorizeUrl(params: {
  clientId: string;
  redirectUri: string;
  state: string;
  scopes?: string[];
}) {
  const url = new URL(FITBIT_OAUTH_AUTHORIZE_URL);
  url.searchParams.set('client_id', params.clientId);
  url.searchParams.set('response_type', 'code');
  url.searchParams.set('redirect_uri', params.redirectUri);
  url.searchParams.set(
    'scope',
    (params.scopes ?? DEFAULT_FITBIT_SCOPES).join(' '),
  );
  url.searchParams.set('state', params.state);
  url.searchParams.set('expires_in', '604800');
  return url;
}

export function decodeState(state: string | null): {
  userId: string;
  mobileRedirectUri: string;
} | null {
  if (!state) {
    return null;
  }

  try {
    const decoded = JSON.parse(atob(state));
    if (
      typeof decoded?.userId === 'string' &&
      typeof decoded?.mobileRedirectUri === 'string'
    ) {
      return {
        userId: decoded.userId,
        mobileRedirectUri: decoded.mobileRedirectUri,
      };
    }
  } catch (_) {
    // Ignore malformed state.
  }

  return null;
}

export function encodeState(payload: {
  userId: string;
  mobileRedirectUri: string;
}): string {
  return btoa(JSON.stringify(payload));
}

export function toIsoStringOrNull(value: string | number | null | undefined) {
  if (value == null) {
    return null;
  }
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date.toISOString();
}

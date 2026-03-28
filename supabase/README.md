# Supabase Fitbit Scaffold

This directory scaffolds the Fitbit backend expected by the Flutter app.

## Edge Functions

- `fitbit-connect`
  - verifies the logged-in Supabase user
  - starts the Fitbit OAuth flow
  - handles Fitbit's OAuth callback
  - stores tokens in `public.fitbit_connections`
  - redirects back to `com.idipaolo.calisync://fitbit-callback`

- `fitbit-sync`
  - verifies the logged-in Supabase user
  - refreshes Fitbit access tokens when needed
  - fetches the latest daily activity summary and resting heart rate
  - returns normalized JSON for the app profile screen

## Required Secrets

Set these in Supabase before deploying:

- `FITBIT_CLIENT_ID`
- `FITBIT_CLIENT_SECRET`
- `FITBIT_REDIRECT_URI`

Recommended value for `FITBIT_REDIRECT_URI`:

- `https://jrqjysycoqhlnyufhliy.supabase.co/functions/v1/fitbit-connect`

The Flutter app uses these function URLs by default:

- `https://jrqjysycoqhlnyufhliy.supabase.co/functions/v1/fitbit-connect-init`
- `https://jrqjysycoqhlnyufhliy.supabase.co/functions/v1/fitbit-connect`
- `https://jrqjysycoqhlnyufhliy.supabase.co/functions/v1/fitbit-sync`

You can override them with Dart defines if needed.

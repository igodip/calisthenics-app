# Push notification setup

CaliSync uses Firebase Cloud Messaging (FCM) for delivery and a Supabase Edge
Function for authenticated recipient resolution. The client remains usable when
Firebase is not configured; push registration is simply disabled.

## Events

- Trainers receive trainee feedback and completed-workout feedback.
- Trainees receive trainer replies, plan creation/imports, coaching-tip changes,
  and monthly payment status changes.
- Tapping a notification opens the relevant plan, feedback, or home section.
- Notifications received while the app is open appear as an in-app banner.

## Firebase

1. Create Android and iOS Firebase apps with bundle/package ID
   `com.idipaolo.calisync`, then enable Firebase Cloud Messaging.
2. On iOS, upload the APNs authentication key in Firebase and enable Push
   Notifications plus Background Modes > Remote notifications in Xcode.
3. Create a Firebase service-account JSON key that can send FCM messages. Do not
   commit it or pass it directly as a CLI argument (CLI process output may echo
   arguments). Store the entire JSON document as the
   `FIREBASE_SERVICE_ACCOUNT_JSON` Function secret through the Supabase
   Dashboard. Alternatively, put it in a permission-restricted temporary env
   file and use:

   ```sh
   supabase secrets set --env-file /path/to/private-firebase.env
   ```

   Securely delete the temporary env file after the upload succeeds.

4. Supply the public Firebase app values at build/run time:

   ```sh
   flutter run \
     --dart-define=FIREBASE_API_KEY=... \
     --dart-define=FIREBASE_PROJECT_ID=... \
     --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
     --dart-define=FIREBASE_ANDROID_APP_ID=...
   ```

   Add `FIREBASE_IOS_APP_ID` for an iOS build. These values identify the Firebase
   app; the private service-account JSON belongs only in Supabase secrets.

## Supabase

Apply the token-table migration and deploy the sender:

```sh
supabase db push
supabase functions deploy send-push-notification
```

The `push_device_tokens` table has RLS enabled and no direct client policies.
Authenticated clients can only claim or remove their current device token via
the restricted RPC functions. The Edge Function uses the server key to resolve
recipients and verifies every trainee/trainer relationship before sending.

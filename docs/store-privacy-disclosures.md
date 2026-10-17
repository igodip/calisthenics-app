# CaliSync store privacy disclosures

Reviewed 17 October 2026 against app code and deployed notification/database
configuration. This is a submission worksheet, not an export of the live store
console answers. Console access is required to update/confirm those answers.

Policy URL: https://igodip.github.io/calisthenics-app/docs/privacy-policy.html

Deletion URL: https://igodip.github.io/calisthenics-app/docs/delete-account.html

## Evidence and mapping

Data below is transmitted to and retained by Supabase, linked to an account.
Declare collection for app functionality and, for authentication/account records,
account management. Do not claim the app collects no data or that records are
anonymous. Optional entry does not make a transmitted field exempt.

| Implemented information | Google Play Data safety | Apple App Privacy | Required/optional and recipients |
| --- | --- | --- | --- |
| Account email; profile name | Personal info: Email address, Name | Contact Info: Email Address, Name | Email required for registration; name derived initially and editable. Supabase; assigned trainers can read names; admin account listing includes email/name. |
| Account UUID/roles | Personal info: User IDs | Identifiers: User ID | Required; linked to authentication and all stored records. |
| Weight, height, weight history | Health and fitness: Health info | Health & Fitness: Health | Optional entries; assigned trainers and privileged admins/operators. |
| Plans, exercises, completion, repetitions, duration, max tests | Health and fitness: Fitness info; App activity: Other actions for progress events where applicable | Health & Fitness: Fitness | Collected when training is used; assigned trainers and admins/operators. |
| Original trainer-uploaded workout-plan PDFs | Health and fitness: Fitness info; User-generated content/files as applicable to the store form | Health & Fitness: Fitness; User Content: Other User Content | Uploaded to private Supabase Storage after trainer confirmation (maximum 25 MB); available to the trainee, assigned trainers and admins. |
| Feedback, replies and coach tips | Messages: Other in-app messages | User Content: Emails or Text Messages (in-app communications); Other User Content for general coaching notes | Optional messages; assigned trainers, admins/operators; excerpts and names may go to FCM/APNs. |
| Exercise notes, trainer notes, payment notes | App activity: Other user-generated content | User Content: Other User Content | Optional; access varies by table. Private max-test notes exclude trainees/app admins but remain readable to backend operators. |
| Profile image | Photos and videos: Photos | User Content: Photos or Videos | Optional; uploaded to public avatar storage. Anyone with the URL can retrieve it. |
| Monthly amounts, payment status and dates | Financial info: Purchase history; classify additional financial notes according to actual content requested | Purchases: Purchase History; Other Financial Info where applicable | Trainer-entered coaching-payment records are retained even though card payments are not processed in-app. Assigned trainers, admins/operators; payment status may go to push providers. Do not declare card/bank details as collected. |
| FCM token/installation identifier/platform | Device or other IDs | Identifiers: Device ID | Notification permission/token association is optional; SDK installation processing can occur at app startup before sign-in/permission, so do not mark the entire identifier category optional without verifying an opt-out. Supabase and Google Firebase; APNs handles iOS delivery. |
| Operational IP/error/delivery metadata | Device or other IDs / App info and performance categories as applicable to the provider's retained data | Diagnostics / Other Data where applicable to retained provider data | Confirm provider logs and SDK behavior against the shipped build before submitting. No Analytics or Crashlytics SDK is enabled by this app. |
| Support email content | Messages / Other user-generated content for any in-app submission; account/contact information as applicable | Customer Support for data collected through the app or integrated partners | Support is currently an external mailbox; policy covers it. Apply each store's off-app collection definitions rather than automatically treating all external email as in-app collection. |

For Apple, declare collected account/profile/training/message/photo/payment and
push-identifier data as **linked to the user**, used for **App Functionality**;
there is no implemented advertising tracking. Do not mark the app as using data
for advertising or cross-app tracking unless production behavior changes.

For Google, assess **sharing separately from collection**. Supabase/FCM acting
solely as contracted service providers may qualify for the service-provider
exception, but that does not exempt collection. Trainer access needs its own
assessment: independently operating trainers receive personal/coaching data and
current admin assignment is not itself proof of a user-initiated sharing
exception. Declare the affected categories as shared unless the actual trainer
relationship and applicable exception are established. Notification previews
also transmit actual content to providers, not only opaque device IDs.

## Submission answers and production limits

- Data encrypted in transit: app backend requests use HTTPS. This is not
  end-to-end encryption and does not make public avatar URLs private.
- Deletion available: yes, in Settings and through the public email-request page.
  Successful deletion removes active account records, avatar files and
  workout-plan PDFs associated with the account; provider backups/logs/support
  email are not purged automatically by this flow. Deleting an individual plan
  also removes its original PDF.
- Optional data: profile photo, body measurements, free-text content and push
  permissions are optional. Necessary email/account identifiers are required.
  Push permission does not establish an opt-out from Firebase installation-ID
  processing during SDK initialization.
- No implemented location, contacts, microphone recording, advertising IDs,
  HealthKit, Health Connect, Fitbit, ad SDK, Analytics or Crashlytics collection.
- Original imported PDFs are parsed locally, then the original file and
  extracted plan are stored remotely. The PDF bucket is private and access is
  restricted to the trainee, assigned trainers and admins.
- Admins currently have broad access to personal/coaching records. Workout-day
  access is limited to the trainee, assigned trainers and admins, plus a trainer's
  own unlinked draft days. Avoid claims that data is hidden from admins/operators.

## Owner checks before confirming live console declarations

1. Enter the policy/deletion URLs above in both listings where supported and
   verify they return the published pages without authentication.
2. Apply the matrix in Play Console and App Store Connect to the **distributed
   build**, including SDK data, and review trainer sharing classifications.
3. Verify actual Supabase region, backup/log retention and support-mailbox
   retention. No fixed retention deadline can be inferred from repository code.
4. Verify Firebase/APNs configuration and Apple privacy manifests of the resolved
   dependencies. Check retained diagnostics/technical metadata classifications.
5. Confirm operator identity/contact information and any jurisdiction-specific
   health-data legal basis/consent requirements; avoid treating a policy link as
   evidence of consent to every type of processing.

Primary guidance:
- [Google Play User Data](https://support.google.com/googleplay/android-developer/answer/10144311)
- [Google Play Data safety definitions](https://support.google.com/googleplay/android-developer/answer/10787469)
- [Apple App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)
- [Firebase privacy and security](https://firebase.google.com/support/privacy)

## Source references

- `lib/pages/login_page.dart`: sign-up, email/name derivation, Supabase auth.
- `lib/pages/profile_page.dart`: body measurements, avatars/public URLs, history.
- `lib/trainer/trainer_repository.dart`: coach content, payments, plans, results.
- `lib/trainer/pdf/trainer_pdf_storage.dart` and migration
  `20261017120000_store_original_workout_plan_pdfs.sql`: private source-PDF
  uploads, access rules and plan association.
- `lib/notifications/push_notification_service.dart`: FCM initialization,
  permission, token registration/unregistration and event dispatch.
- `supabase/functions/send-push-notification/index.ts`: service-role record reads,
  recipient lookup, plaintext preview payloads and invalid-token cleanup.
- `supabase/functions/delete-account/index.ts` and migration
  `20261014120000_add_account_deletion.sql`: implemented removal boundaries.
- `lib/trainer/pdf/trainer_pdf_import.dart`: local PDF parsing.

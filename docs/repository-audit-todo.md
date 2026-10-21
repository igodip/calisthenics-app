# Repository audit TODO

Audit date: 21 October 2026.

Scope: application code, build workflows, tests, documentation, and read-only
inspection of the linked database's schema, policies, grants, migration history,
and public exercise catalog. No production user records were changed and no
destructive permission tests were performed.

These findings describe the state observed during the audit. Re-check deployed
configuration before implementing fixes; migration history differences do not
necessarily mean the corresponding database features are absent.

## 1. Highest priority

### Database write boundaries

- [ ] Restrict trainee writes to their own completion, repetitions, trainee
  notes, and other explicitly permitted fields.
- [ ] Prevent trainees from inserting/deleting trainer-authored exercise rows or
  changing exercise prescriptions through the API.
- [ ] Prevent trainees from modifying trainer replies and trainer-managed
  feedback fields.
- [ ] Add isolated database tests for trainee, assigned trainer, unassigned
  trainer, administrator, and anonymous access, including field-level writes.

Evidence: live `day_exercises` policies allow INSERT/UPDATE/DELETE through
`can_access_day`; `trainee_feedbacks` allows owner updates. Inspected grants
allow these operations, and neither table has field-protection triggers.
The existing `guard_day_content` migration protects `days`, not these tables.
Permission exposure was established from metadata, not destructive writes.

Reference: `supabase/migrations/20261016120000_unify_access_and_plan_permissions.sql`.

### Release Firebase configuration

- [ ] Supply required Firebase compile-time values to Android and iOS release
  builds, or replace the configuration mechanism with an explicit supported
  alternative.
- [ ] Fail release validation when required notification configuration is absent
  instead of silently disabling initialization.
- [ ] Verify notification initialization in the actual distributed artifacts.

Evidence: `FirebaseConfig.isConfigured` requires nonempty `String.fromEnvironment`
values; the release workflow does not supply those values. The Android client
configuration file alone does not satisfy this Dart-side check.

References: `lib/notifications/firebase_config.dart`,
`lib/notifications/push_notification_service.dart`,
`.github/workflows/test-and-build.yml`.

### iOS push setup

- [ ] Add and configure the app's push entitlement and signing configuration.
- [ ] Verify APNs credentials, provisioning capabilities, token registration,
  and delivery on a signed physical iOS device.
- [ ] Verify foreground, background, terminated-app, and notification-tap flows.

Evidence: no push entitlement file or `CODE_SIGN_ENTITLEMENTS` setting was found
in the repository. APNs credentials and physical-device delivery were not audited.

References: `ios/Runner.xcodeproj/project.pbxproj`, `ios/Runner/Info.plist`.

### Reproducible database setup and migration history

- [ ] Recover a reviewed baseline schema covering core tables, functions,
  grants, policies, triggers, storage, and required reference data.
- [ ] Resolve the missing `db/database.sql` referenced by `Codex.md`, either by
  supplying it or updating the repository's schema-source instructions.
- [ ] Reconcile local and deployed migration history after comparing actual
  schema effects; do not blindly mark migrations applied or re-run them.
- [ ] Verify that a fresh disposable database can be created from the repository.
- [ ] Document safe deployment, rollback/recovery, and environment setup steps.

Evidence: initial migrations contain history placeholders and core table
definitions are absent. Deployed history includes versions missing locally,
while some local versions are not recorded remotely. Examples of remote-only
versions observed: `20261018190943`, `20261018190952`, `20261018191000`,
`20261019200643`, `20261020115535`, and `20261020115831`.

References: `Codex.md`, `supabase/migrations/`, `supabase/config.toml`.

## 2. Reliability and engineering

### Atomic profile updates

- [ ] Save profile fields and weight/height history together in one database
  transaction.
- [ ] Define compensation/cleanup for photo uploads when database saving fails.
- [ ] Ensure retries do not duplicate measurement-history entries.
- [ ] Test failures at each stage and verify the visible result matches saved data.

Evidence: photo upload, weight-history insert, height-history insert, and profile
update are separate operations that can partially succeed.

Reference: `lib/pages/profile_page.dart`.

### Recoverable guide and terminology loading

- [x] Evict failed loading futures from both locale caches.
- [x] Add explicit retry/refresh and cache invalidation paths.
- [x] Refresh successful cached catalogs when appropriate without requiring an
  app restart.
- [x] Test offline startup followed by connectivity recovery and catalog updates.

Resolved: both repositories use a shared locale cache with five-minute expiry,
30-second request timeout, failure eviction, forced refresh, and locale/all-cache
invalidation. Pages offer retry, refresh buttons, pull-to-refresh, and reload on
foreground resume (respecting cache expiry). Home prefetch errors are handled.
Tests cover recovery, updates, locale aliases, expiry, request deduplication,
timeout, and superseded-request races; existing glossary deep links are retained.

References: `lib/data/exercise_guides.dart`,
`lib/data/terminology_repository.dart`.

### Reliable notification dispatch

- [ ] Make dispatch durable after a successful data mutation rather than relying
  solely on a subsequent client call.
- [ ] Add retry handling for transient delivery and token-registration failures.
- [ ] Add event idempotency/replay protection and appropriate rate limits.
- [ ] Test saving followed by immediate app closure, repeated events, expired
  tokens, network failure, and backend failure.

Evidence: client-triggered dispatch failures are logged without durable retry;
the same existing event can be submitted repeatedly. `_registerToken` catches
RPC failures without scheduling the registration retry mechanism.

References: `lib/notifications/push_notification_service.dart`,
`supabase/functions/send-push-notification/index.ts`.

### Backend and pre-merge CI coverage

- [ ] Run checks on pull requests before changes reach `stable`.
- [ ] Create a disposable database environment for SQL permission/integrity tests.
- [ ] Run SQL tests in CI; do not run fixture-writing tests against real user data.
- [ ] Add Edge Function tests for authorization, invalid inputs, notification
  dispatch, and deletion failures.
- [ ] Add a successful disposable-account deletion test, including storage,
  related rows, and preservation of other users' data.
- [ ] Test storage access across roles and account boundaries.

Evidence: the main workflow runs Flutter analysis/tests but does not execute SQL
or Edge Function tests, and is triggered by pushes to `stable` rather than PRs.
Existing deletion widget tests cover cancellation and failure, not actual backend
deletion success.

References: `.github/workflows/test-and-build.yml`, `supabase/tests/`,
`supabase/functions/`, `test/account_deletion_test.dart`.

### Reproducible dependencies

- [ ] Stop ignoring the application's `pubspec.lock` and commit a reviewed lockfile.
- [ ] Verify local and CI dependency resolution matches.
- [ ] Define an intentional dependency-update and regression-check process.

Evidence: `pubspec.lock` is ignored and was not tracked at audit time.

References: `.gitignore`, `pubspec.yaml`.

## 3. Product and consistency

### Complete manual program editing

- [ ] Let trainers add/remove workout days and add/remove exercises manually.
- [ ] Define activation behavior so creating an empty plan does not unexpectedly
  replace a usable active program.
- [ ] Verify manual and PDF-imported plans use the same validated data model.
- [ ] Add end-to-end coverage for building a populated program without a PDF.

Evidence: manual creation saves plan header fields; existing exercise rows can
be edited, but no trainer add/remove-day or add/remove-exercise flow was found.
Populating a new program currently depends on PDF import.

References: `lib/trainer/trainer_repository.dart`,
`lib/trainer/pages/trainer_program_page.dart`,
`supabase/migrations/20261019220000_keep_latest_workout_plan_active.sql`.

### Actual landscape support

- [ ] Revisit the global portrait-only orientation request.
- [ ] Enable intended orientations and test the full app, not only timer widgets.
- [ ] Verify timer state and reachable controls on physical-device rotation.

Evidence: timer layouts support landscape constraints in tests, but startup
requests only portrait orientations.

Reference: `lib/main.dart`.

### Paginated history and administrative lists

- [ ] Add pagination/load-more for trainer feedback and appropriate administrative
  lists.
- [ ] Make limits visible instead of silently hiding older records.
- [ ] Verify ordering, unread counts, filters, and searches across pages.

Evidence: trainer feedback is limited to the latest 200 rows without pagination;
other lists rely on backend response limits.

References: `lib/trainer/trainer_repository.dart`,
`lib/admin/admin_repository.dart`.

### Localization and privacy-documentation consistency

- [ ] Localize backend notification titles/bodies using recipient language.
- [ ] Localize the foreground notification action currently labeled `Open`.
- [ ] Update privacy policy and store-disclosure worksheet for in-app bug reports,
  their stored fields, administrator access, retention, and deletion.
- [ ] Keep store-console answers aligned with the distributed build.

Evidence: UI catalogs are synchronized, but push text remains English-only.
Documentation mainly describes support as external email despite the new
in-app bug-report storage and administration flows.

References: `supabase/functions/send-push-notification/index.ts`,
`lib/notifications/push_notification_service.dart`,
`lib/pages/bug_report_page.dart`, `docs/privacy-policy.html`,
`docs/store-privacy-disclosures.md`.

### Trainer/trainee-only privacy objective

- [ ] Decide and document the intended boundary between app administrators,
  assigned trainers, trainees, and backend operators.
- [ ] Remove unnecessary administrator access to coaching/profile data if the
  product goal is trainer/trainee-only access.
- [ ] Replace public avatar access if profile photos should be private.
- [ ] If protection from backend operators/leaks is required, design end-to-end
  encryption, including key recovery, device changes, trainer reassignment, and
  notification-preview behavior before implementation.
- [ ] Do not describe RLS or screenshot protection as end-to-end encryption.

Evidence: live administrators retain broad profile and feedback access; the
`avatars` bucket is public; coaching records are server-readable plaintext.
These limitations are documented but do not satisfy the earlier privacy objective.

References: `docs/privacy-policy.html`, `lib/pages/profile_page.dart`,
`supabase/functions/send-push-notification/index.ts`.

## 4. Outstanding release/operator verification

- [ ] Build and inspect signed Android and iOS release artifacts.
- [ ] Test real-device notification delivery and notification navigation for both roles.
- [ ] Verify Firebase/APNs production credentials and capabilities without exposing secrets.
- [ ] Exercise successful account deletion with disposable accounts and sample files only.
- [ ] Verify actual backup/log retention, restoration procedures, and support-mailbox retention.
- [ ] Confirm live Play Console/App Store Connect privacy answers and configured URLs.
- [ ] Review generated exercise artwork with a trainer.

These checks were not established by the audit's Flutter tests or metadata reads.

## Healthy baseline observed

- All 181 Flutter tests passed; static analysis reported no issues.
- All 513 UI message keys matched across Italian, English, and Spanish, with
  localization consistency tests passing.
- Public exercise guides had no missing names/descriptions in those languages.
- Terminology had 12 entries in each supported language; equal counts alone do
  not prove semantic equivalence.
- All 21 inspected public database tables had RLS enabled; this does not imply
  that every policy is sufficiently restrictive.
- Workout-plan PDFs used a private bucket; avatars used a public bucket.
- Public privacy, deletion, and support URLs returned HTTP 200.
- Account deletion is implemented; it is not a missing feature.

## Suggested implementation order

1. Database write restrictions and isolated role-based regression tests.
2. Release Firebase configuration and iOS push setup.
3. Database baseline/history and dependency reproducibility.
4. Transactional saving, recoverable caches, and reliable notification dispatch.
5. Pre-merge/backend CI and release verification.
6. Manual program editing, pagination, orientation, localization, and the agreed
   privacy architecture.

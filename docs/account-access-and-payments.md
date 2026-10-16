# Account access and payment rules

The backend is the source of truth (`current_account_access`):

- Active trainers and administrators do not need a monthly trainee payment.
- Trainees need a paid record for the current calendar month, computed on the
  server in `Europe/Rome`. Historical payments do not activate a new month.
- Suspended accounts are not shown as active. Account settings, deletion and
  logout remain reachable even when profile/access loading fails.
- Training gates, role menus and profile status refresh on app resume and every
  30 seconds while mounted. These UI gates are not encryption or a replacement
  for database authorization.

Trainer dashboard active-plan totals count active plans, not paid trainees.
Trainee workout/progress queries exclude archived/expired plans. An expired plan
does not hide another active plan. Coach tips select the latest assignment when
there is more than one trainer.

Payments are saved using `save_monthly_payment`, which validates the caller and
uses the server's current month. Empty amounts clear a prior amount; negative,
non-finite or malformed amounts are rejected. Updating an already-paid record's
amount or notes preserves `paid_at`; marking it unpaid clears that timestamp.
Notifications refer to the saved payment ID. Older clients sending a trainee ID
remain supported by the notification function.

## Database permissions and deletion

Only privileged administration can grant roles. Authenticated clients cannot
insert/delete their own trainer/admin rows; trainers can edit their own name.
Trainer status alone does not grant access to all workout days. Unlinked draft
days are visible to their creator; linked days follow plan assignments. Trainees
can update day completion but not rewrite day content.

`delete_workout_plan` validates ownership/assignment and deletes a plan and its
unshared days/exercises in one database transaction. Shared days are retained.
PDF import cleanup uses the same operation instead of sequentially deleting
children before a potentially denied parent deletion.

## Verification

After deploying migration `20261016120000_unify_access_and_plan_permissions.sql`:

```sh
npx supabase@latest db query --linked --file supabase/tests/access_and_payments.sql
flutter analyze
flutter test
flutter build apk --debug --target-platform android-arm64
```

The SQL regression creates only synthetic accounts in a transaction and rolls
everything back. It temporarily relaxes the one-day/one-plan constraint within
that transaction to test shared-data preservation; production keeps the
constraint. Existing accounts and payment history are not reset by deployment.

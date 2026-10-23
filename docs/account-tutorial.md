# First-login account tutorial

The existing pre-login onboarding remains separate. After authentication and a
successful active-account role lookup, Home checks `account_tutorials` for the
current account. New accounts and existing accounts without a receipt see the
tutorial once. Email-confirmation screens do not trigger it.

The tour explains the navigation menu and role-specific sections. Paid trainees
see plans and result history; unpaid trainees see the waiting-for-trainer state
and available features. Trainers see trainees, programs, results/private notes,
feedback, and payments. Admins also see an administration step. Skip and Finish
both save completion. Back navigates to the previous step; back from the first
step is treated as Skip.

Profile → Settings → Replay account tutorial opens the current role's tour
again. Replaying does not clear or overwrite the original server receipt.

## Persistence and failure handling

- `account_tutorials` stores user ID, first completion timestamp, and whether the
  original tour was skipped. Its owner can SELECT and INSERT, but not UPDATE,
  DELETE, or access another account's receipt. Inserts ignore duplicates.
- The auth-user foreign key cascades on account deletion. Local completion and
  pending-sync flags are also cleared by in-app account deletion.
- Completion is cached per account in SharedPreferences. Failed saves stay
  queued for the next account check/app resume. Once synced, a reinstall or
  another device retrieves the receipt from the server. Before offline completion
  is synced, another device can still show the tutorial.
- A failed server lookup does not block the app or mark the tutorial complete.
  Home's subsequent role refreshes and foreground resume retry it.
- Network reads/writes time out after five seconds. The tour has no analytics,
  does not record individual step views, and does not change training access.

Deploy only `20261024120000_add_account_tutorials.sql` before distributing the
app. Do not repair unrelated migration history or apply other pending migrations
as part of this feature. `supabase/tests/account_tutorials.sql` is intended for a
disposable development/test database, not real accounts.

Tests: `test/account_tutorial_test.dart`,
`test/account_tutorial_repository_test.dart`, and localization consistency tests.

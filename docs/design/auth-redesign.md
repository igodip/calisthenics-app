# Calisync entry-screen redesign

Implements the approved charcoal/mint concept with pull-up, handstand and dip onboarding artwork and rings on the login screen. Preview cards have been removed. UI text, controls, gradients and branding remain native widgets.

- Onboarding uses a common measured headline/description height across its three pages, including translations and scaled text. The bottom primary action and indicators remain in a shared footer. Small screens can scroll the artwork/text region; compact layouts use a shorter sign-in link.
- Create account opens registration; Skip and the existing-account link open login. The existing `hasSeenOnboarding` preference is retained.
- Login keeps its email/password authentication, confirmation, privacy notice, password recovery, deep links and trainee provisioning. It adds persistent labels, autofill hints, accessible visibility controls and a scrollable keyboard layout.
- Colors are scoped to the entry screens. Existing in-app theme preferences are unchanged.
- Bundled WebP artwork totals approximately 180 KiB. It needs no network request and is marked decorative for screen readers.

## Validation

Dart formatting and `git diff --check` passed. ARB JSON, matching generated getters and all four image assets were checked locally. Flutter setup was blocked by automatic approval review because it attempted cloud-instance metadata access. Flutter analysis, widget tests and a rendered/device visual check have NOT been completed in this environment.

Run before marking the PR ready:

```sh
flutter pub get
flutter gen-l10n
flutter analyze
flutter test test/auth_onboarding_test.dart test/login_redesign_test.dart
```

Check all three onboarding pages in English, Italian and Spanish, small phones, landscape, and 200% text scale. Check signup confirmation/privacy, login errors, reset email, recovery deep links, and the keyboard on Android/iOS. The new widget tests exercise layout alignment, forward/back/skip/signup entry, password visibility, empty input, and small/large-text layouts; they do not exercise live Supabase authentication.

No database schema or authentication query changes. `Codex.md` references `db/database.sql`, which is absent from this branch; the existing auth code and Supabase migrations were inspected and the data operations preserved.

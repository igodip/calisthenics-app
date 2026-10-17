# App Store screenshots

The **App Store screenshots** GitHub Actions workflow captures the existing app
on iPhone and iPad simulators. Each device produces five screens in Italian and
English: home, training plan, progress, exercise guides and coach feedback.
No Apple signing certificate, Apple account, Supabase secret, or real customer
account is needed. This workflow does not upload builds or submit a store release.

## Run and download

The workflow runs automatically on pull requests changing its capture files.
That provides an initial run even before it exists on the default branch.

For the **Run workflow** button, GitHub requires this workflow to also exist on
the repository's default branch (currently main). Once it does:

1. Open Actions → App Store screenshots → Run workflow.
2. Select the branch containing the app version to capture, normally stable.
3. Open the successful run and download both artifacts:
   **app-store-screenshots-iphone** and **app-store-screenshots-ipad**.
4. Upload the images under **ready/it/** to the Italian listing and **ready/en/**
   to the English listing. The iPhone artifact belongs in **iPhone with Dynamic
   Island (medium display)**; the iPad artifact belongs in **13-inch iPad**.

The source PNGs, simulator inventory, capture log and source-commit manifest are
included for diagnosis. Artifacts expire after 30 days, so download approved
assets. Review every image for accurate content, legible text, correct language
and layout before uploading. Automated validation detects missing files,
unsupported dimensions, transparency and near-blank captures; it does not replace
visual review.

## Capture fidelity and isolation

The scenario launches the production CalisthenicsApp widget and uses its real
navigation. It never calls the production main/bootstrap function.
The test supplies an in-memory HTTP client and a synthetic authenticated session
for store-demo.invalid. Only fixture requests are accepted; unhandled requests
fail the test, and none are forwarded to a real backend.

The demo records follow the current application's response models and queries.
Codex.md references db/database.sql, which is not present in this branch.
Consequently this is UI fixture coverage, not validation of the deployed schema,
RLS, or backend correctness. No database schema or production data is modified.

Fixtures are maintained in test/support/store_demo_backend.dart; dates follow
the current month to avoid showing an expired plan. Update fixtures when the app
changes its data queries. Do not replace them with production credentials.

Native screenshot protection is skipped only for a **debug simulator** when its
temporary Info.plist contains CalisyncStoreScreenshots=true. The workflow adds
that key only in its checkout. Workout-page protection has a separate debug-only
STORE_SCREENSHOTS switch. Release builds retain protection even if either
capture option is supplied. Normal device builds are unaffected.

## Local Mac capture

Install Flutter 3.47.7, Xcode, CocoaPods and a supported iOS simulator runtime.
In a clean checkout:

~~~sh
flutter pub get
export SCREENSHOT_OUTPUT_DIR="$PWD/build/store-screenshots/iphone/raw"
SIMULATOR_ID="$(python3 tool/store_screenshots/select_simulator.py iphone)"
xcrun simctl boot "$SIMULATOR_ID"
xcrun simctl bootstatus "$SIMULATOR_ID" -b
/usr/libexec/PlistBuddy -c 'Add :CalisyncStoreScreenshots bool true' ios/Runner/Info.plist
flutter drive --debug --driver=test_driver/store_screenshots.dart \
  --target=integration_test/store_screenshots_test.dart \
  --dart-define=STORE_SCREENSHOTS=true -d "$SIMULATOR_ID"
/usr/libexec/PlistBuddy -c 'Delete :CalisyncStoreScreenshots' ios/Runner/Info.plist
~~~

Repeat with ipad and the corresponding output directory. Use the workflow's
prepare_assets.py command to validate/export the JPEGs; Pillow 11.3.0 is needed.
Always remove the temporary plist key after local capture, including on failure.

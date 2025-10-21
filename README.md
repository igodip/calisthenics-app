# Calisthenics App

Calisthenics App is a Flutter application designed to help athletes follow
personalized bodyweight training plans wherever they go. The app integrates
with Supabase for authentication and data storage so that workouts, progress and
profile information stay in sync across devices.

## What you can do

- **Follow your weekly plan** – the home screen pulls the latest training plan
  from Supabase and organizes it by day. Each workout opens into a detailed
  view showing exercises, sets, reps, intensity guidance and notes to keep you
  on track.
- **Track exercises in real time** – launch the exercise tracker to quickly log
  reps with customizable quick-add buttons, undo actions, rest timers and goal
  progress indicators for every movement.
- **Use pose estimation tools** – switch to the built-in camera experience that
  leverages Google ML Kit pose detection to analyse squats, push-ups, pull-ups
  and dips, count reps and provide instant feedback on each set.
- **Manage your profile** – review and edit profile details pulled from
  Supabase, update preferences like units and timezone, and sign out securely.
- **Tune settings** – change appearance, localization and other preferences via
  the dedicated settings tab (see `lib/pages/settings.dart`).

## Tech highlights

- Flutter 3 application with a custom dark theme and localization support.
- Supabase authentication, real-time data and profile management.
- Google ML Kit pose detection for camera-based movement analysis.
- Modular component structure for cards, theming and reusable widgets.

## Getting Started

This project is a standard Flutter application. To run it locally:

1. Ensure you have Flutter installed. See the
   [Flutter installation guide](https://docs.flutter.dev/get-started/install)
   for platform-specific steps.
2. Fetch dependencies:

   ```bash
   flutter pub get
   ```

3. Run the application on an emulator or a connected device:

   ```bash
   flutter run
   ```

The Supabase instance URL and anon key are configured in `lib/main.dart`. If you
plan to point the app at a different backend, update those values accordingly.

For more Flutter resources, check out:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

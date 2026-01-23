# Calisthenics App

Calisthenics App is a Flutter application designed to help athletes follow
personalized bodyweight training plans wherever they go. The app integrates
with Supabase for authentication and data storage so that workouts, progress and
profile information stay in sync across devices.

## What you can do

- **Complete onboarding and authentication** – new users are guided through a
  three-step onboarding flow before signing in or creating an account with
  Supabase authentication.
- **Review your weekly plan** – the home screen highlights upcoming training
  days, plan progress, and the latest coach tip for the trainee.
- **Execute training days** – open a workout plan day to log completion, add
  trainee notes, and track exercise completion state.
- **Submit trainee feedback** – send feedback directly from the home experience
  and receive confirmation on submission.
- **Browse exercise guides and terminology** – browse curated exercise tips
  alongside a glossary of training terms.
- **Manage your profile and max tests** – update profile details, review payment
  status, and record max test entries per exercise.

## Tech highlights

- Flutter 3 application with a custom dark theme and localization support.
- Supabase authentication and data-backed trainee workflows.
- Plan-expired gate that blocks app access when payment is overdue.
- Modular component structure for cards, theming and reusable widgets.

## Admin portal status

The repo also ships a lightweight admin portal under `backend/admin` for
trainers and admins to review trainees, payments, plans, and feedback in
Supabase.

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

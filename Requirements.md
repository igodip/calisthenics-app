# Requirements

## App (lib/)

### Onboarding
- Store onboarding completion in SharedPreferences under the `hasSeenOnboarding` key.
- Show the onboarding flow until `hasSeenOnboarding` is true.
- Render exactly three onboarding steps and provide Skip, Back, Next, and Get Started actions to navigate or complete onboarding.

### Authentication
- Determine the authenticated state from the Supabase auth state stream and route authenticated users to the home page.
- Show a loading indicator while the auth state is resolving and show an error message when the auth stream fails.
- Provide a login mode that requires an email and password and uses Supabase `signInWithPassword`.
- Provide a signup mode that requires email, password, and password confirmation, validates matching passwords, and uses Supabase `signUp`.
- After sign-in or sign-up, ensure a `trainees` row exists for the authenticated user (insert the user ID and a derived name when missing).
- Support password reset by sending a reset email to the entered address with the `com.idipaolo.calisync://login-callback` redirect.
- Listen for recovery deep links, prompt for a new password plus confirmation, and update the Supabase user password.
- Provide a logout action that signs the user out and returns to the login screen.

### Global Navigation & Access Control
- Provide drawer navigation entries for Home, Exercise Guides, Profile, Max Tests, Terminology, and Workout Plan.
- Gate access to the app with a plan-expired check: query the most recent `trainee_monthly_payments` row for the trainee and block access when `paid` is false.
- Show a blocking overlay during the plan-expired check and show an expired-plan message when access is blocked.

### Home Overview
- Load workout days from `days` joined with `workout_plan_days` and `workout_plans` for the current trainee.
- Load the coach tip from `trainee_trainers` for the current trainee.
- Compute the next scheduled workout date from the plan start date, week number, and day code (fall back to `completed_at` when available).
- Compute weekly and monthly workout counts and list upcoming workouts for the current week.
- Compute plan progress for the most recent plan by grouping days by plan and counting completed days.
- Allow pull-to-refresh and show a retry action when loading fails.
- Provide navigation to the trainee feedback form.

### Trainee Feedback
- Require a non-empty feedback message before submission.
- Insert trainee feedback into `trainee_feedbacks` with `trainee_id` and message.
- Show success or error feedback after submission and clear the form on success.

### Workout Plans
- Load workout plans for the current trainee from `workout_plans`, sorted by `starts_on` and `created_at` (most recent first).
- Load plan days and exercises from `days`, `workout_plan_days`, and `day_exercises`, ordered by week, day code, and position.
- Group plan days by plan identity and show the latest plan first.
- Block the plan list when the latest plan status is `expired`.
- Allow opening a training day and refresh the plan data when completion status changes.

### Training Day Execution
- Render general day notes when present.
- Render each exercise with its notes, completion state, and personal trainee notes.
- Save trainee notes to `day_exercises.trainee_notes` and show success or error feedback.
- Toggle exercise completion in `day_exercises.completed`.
- Count completed repetitions for every completed exercise and persist the value to `day_exercises.completed_reps`.
- Toggle day completion state using the day completion action and persist updates.

### Exercise Guides
- Present a difficulty selector (beginner, intermediate, advanced) and filter guides by the selected difficulty.
- Display exercise guides with name, focus, tip, and description for each supported exercise.

### Terminology
- Display the terminology glossary list with each term and its description.

### Profile
- Load the trainee profile from `trainees` and show name, email, and weight.
- Load the latest payment status from `trainee_monthly_payments` and render payment/plan status chips.
- Provide an edit form that requires a non-empty full name and validates weight as a positive decimal.
- Persist profile edits to `trainees`.

### Max Tests
- Load max test entries from `max_tests` for the current trainee.
- Group max tests by exercise, show the best value per exercise, and allow expanding/collapsing the history list.
- Provide a form to add a max test with exercise, value, unit (default to localized unit), and recorded date.
- Persist new max tests to `max_tests` and refresh the list after saving.

## Trainer console (lib/trainer)

The trainer console is part of the Flutter app (not a separate web portal).
It is available to authenticated users that have a row in the `trainers`
table, and every view is scoped to the trainees assigned to the trainer
through `trainee_trainers`.

### Access Control
- Resolve the logged-in user’s access by querying the `trainers` table.
- Treat users as trainers when a `trainers` row exists, viewers otherwise.
- Restrict trainer accounts to trainees assigned to the trainer via `trainee_trainers`.

### Dashboard
- Show counts for assigned trainees, unread feedback, active plans (paid), and overdue trainees.
- List recent trainee feedback from `trainee_feedbacks`, including trainee name, read status, date, and message.
- List trainees and their payment status with an action to open the trainee program.

### Trainees
- List assigned trainees with display name and payment status, with a search filter.
- Show progress for each trainee by calculating completed vs total exercises.
- Toggle the trainee’s monthly payment status via `trainee_monthly_payments` and show saving state while updating.
- Provide an action to open the trainee program view.

### Payments
- Show summary counts for total, paid, and overdue trainees.
- Provide a quick action to mark a trainee as paid or unpaid.
- Allow editing and saving the payment amount for each trainee.
- Persist payment status and amounts to `trainee_monthly_payments` for the current month.

### Program
- Require selecting a trainee before showing program details.
- Render an overview with the training calendar (week/day labels, completed exercise counts), feedback, workout days, max tests, weight history, and payment history.
- Display trainee identity, assigned trainers, payment status, and progress percentage.
- Load max tests for the trainee and render exercise summaries.
- Allow saving a coach tip to `trainee_trainers.coach_tip`.
- List completed exercises from `day_exercises` with day labels, completion time, and notes.
- Show payment history entries with paid status, paid date, and amount.

### Plan Management
- Create workout plans for the selected trainee with required name, status, optional start date, and notes.
- Delete workout plans after confirmation.
- Reload plan data after create or delete operations.

### PDF Import
- Pick a PDF file and read it as raw bytes (falling back to the file path).
- Parse the positioned PDF text into a plan with weeks, days, and exercise slots.
- Show a preview of the parsed plan (name, day summaries, exercise count).
- On confirmation, create the plan, its days, and exercises in Supabase.
- Reload plan data after saving and report success or failure.

### Feedback
- List trainee feedback from `trainee_feedbacks` for the trainer.
- Mark feedback as read/unread.
- Answer feedback and persist the answer to `trainee_feedbacks`.
- Delete feedback after confirmation.

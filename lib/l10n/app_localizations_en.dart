// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Calisync';

  @override
  String get authErrorMessage => 'Authentication error';

  @override
  String get navHome => 'Home';

  @override
  String get navSettings => 'Settings';

  @override
  String get navProfile => 'Profile';

  @override
  String get navTerminology => 'Terminology';

  @override
  String get settingsComingSoon => 'Settings coming soon.';

  @override
  String get settingsGeneralSection => 'General';

  @override
  String get settingsDailyReminder => 'Daily workout reminder';

  @override
  String get settingsDailyReminderDescription =>
      'Get a gentle nudge to start training each day.';

  @override
  String get settingsReminderTime => 'Reminder time';

  @override
  String get settingsReminderNotSet => 'Not set';

  @override
  String get settingsSoundEffects => 'Sound effects';

  @override
  String get settingsSoundEffectsDescription =>
      'Play short sounds when logging repetitions.';

  @override
  String get settingsHapticFeedback => 'Haptic feedback';

  @override
  String get settingsHapticFeedbackDescription =>
      'Vibrate briefly on important actions.';

  @override
  String get settingsTrainingSection => 'Training preferences';

  @override
  String get settingsUnitSystem => 'Unit system';

  @override
  String get settingsUnitsMetric => 'Metric (kg)';

  @override
  String get settingsUnitsImperial => 'Imperial (lb)';

  @override
  String get settingsRestTimer => 'Default rest timer';

  @override
  String get settingsRestTimerDescription =>
      'Used when starting a rest timer from workouts.';

  @override
  String settingsRestTimerMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# minutes',
      one: '# minute',
    );
    return '$_temp0';
  }

  @override
  String settingsRestTimerMinutesSeconds(int minutes, int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '# minutes',
      one: '# minute',
    );
    String _temp1 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '# seconds',
      one: '# second',
    );
    return '$_temp0 and $_temp1';
  }

  @override
  String settingsRestTimerSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# seconds',
      one: '# second',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataSection => 'Data & privacy';

  @override
  String get settingsClearCache => 'Clear cached workouts';

  @override
  String get settingsClearCacheDescription =>
      'Remove workouts saved on this device.';

  @override
  String get settingsClearCacheSuccess => 'Local workouts cleared.';

  @override
  String get settingsExportData => 'Export training summary';

  @override
  String get settingsExportDataDescription =>
      'Receive a CSV of your recent sessions via email.';

  @override
  String get settingsExportDataSuccess =>
      'Export request submitted. Check your inbox soon.';

  @override
  String get settingsSupportSection => 'Support';

  @override
  String get settingsContactCoach => 'Contact your coach';

  @override
  String get settingsContactCoachDescription =>
      'Send a quick message for adjustments.';

  @override
  String get settingsContactCoachHint => 'Let us know how we can help.';

  @override
  String get settingsContactCoachSuccess => 'Message sent to your coach.';

  @override
  String get settingsSendMessage => 'Send message';

  @override
  String get settingsAppVersion => 'App version';

  @override
  String settingsAppVersionValue(Object version) {
    return 'Version $version';
  }

  @override
  String get exerciseTrackerTitle => 'Exercise tracker';

  @override
  String get poseEstimationTitle => 'Pose estimation';

  @override
  String get homeLoadErrorTitle => 'Unable to load workouts';

  @override
  String get retry => 'Retry';

  @override
  String get homeEmptyTitle => 'No workouts available';

  @override
  String get homeEmptyDescription =>
      'Contact your coach to receive a new plan.';

  @override
  String get unauthenticated => 'User not authenticated';

  @override
  String get defaultExerciseName => 'Exercise';

  @override
  String get generalNotes => 'General notes';

  @override
  String get trainingHeaderExercise => 'Exercise';

  @override
  String get trainingHeaderSets => 'Sets';

  @override
  String get trainingHeaderReps => 'Repetitions';

  @override
  String get trainingHeaderRest => 'Rest';

  @override
  String get trainingHeaderIntensity => 'Intensity';

  @override
  String get trainingHeaderNotes => 'Notes';

  @override
  String get trainingNotesLabel => 'Exercise notes';

  @override
  String get trainingNotesSave => 'Save notes';

  @override
  String get trainingNotesSaved => 'Notes saved';

  @override
  String trainingNotesError(Object error) {
    return 'Unable to save notes: $error';
  }

  @override
  String get trainingNotesUnavailable => 'Cannot update notes for this exercise.';

  @override
  String get trainingOpenTracker => 'Open tracker';

  @override
  String get trainingMarkComplete => 'Mark day as complete';

  @override
  String get trainingMarkIncomplete => 'Mark day as incomplete';

  @override
  String get trainingCompletionSaved => 'Workout day updated';

  @override
  String trainingCompletionError(Object error) {
    return 'Unable to update workout: $error';
  }

  @override
  String get trainingCompletionUnavailable => 'Cannot update this workout day.';

  @override
  String logoutError(Object error) {
    return 'Error while logging out: $error';
  }

  @override
  String get profileFallbackName => 'User';

  @override
  String get userNotFound => 'User not found in the database';

  @override
  String get profileLoadError => 'Error loading data';

  @override
  String get profileNoData => 'No data available';

  @override
  String get profileEmailUnavailable => 'Email not available';

  @override
  String get profileStatusActive => 'Active account';

  @override
  String get profileStatusInactive => 'Inactive account';

  @override
  String get profilePlanActive => 'Active plan';

  @override
  String get profilePlanExpired => 'Plan expired';

  @override
  String get profileUsername => 'Username';

  @override
  String get profileLastUpdated => 'Last updated';

  @override
  String get profileValueUnavailable => 'Not available';

  @override
  String get profileTimezone => 'Time zone';

  @override
  String get profileNotSet => 'Not set';

  @override
  String get profileUnitSystem => 'Unit system';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileComingSoon => 'Coming soon';

  @override
  String get profileEditSubtitle => 'Update your personal details';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileEditFullNameLabel => 'Full name';

  @override
  String get profileEditFullNameHint => 'How should we call you?';

  @override
  String get profileEditTimezoneLabel => 'Time zone';

  @override
  String get profileEditTimezoneHint => 'Example: Europe/Rome';

  @override
  String get profileEditUnitSystemLabel => 'Preferred unit system';

  @override
  String get profileEditUnitSystemNotSet => 'Not specified';

  @override
  String get profileEditUnitSystemMetric => 'Metric (kg, cm)';

  @override
  String get profileEditUnitSystemImperial => 'Imperial (lb, in)';

  @override
  String get profileEditCancel => 'Cancel';

  @override
  String get profileEditSave => 'Save changes';

  @override
  String get profileEditSuccess => 'Profile updated successfully';

  @override
  String profileEditError(Object error) {
    return 'Unable to update profile: $error';
  }

  @override
  String get featureUnavailable => 'Feature not available yet.';

  @override
  String get logout => 'Log out';

  @override
  String redirectError(Object error) {
    return 'Error during redirect: $error';
  }

  @override
  String linkError(Object error) {
    return 'Link error: $error';
  }

  @override
  String get missingFieldsError => 'Please fill out all required fields.';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get invalidCredentials => 'Invalid credentials.';

  @override
  String get signupEmailCheck =>
      'Sign-up complete! Check your email to confirm your account.';

  @override
  String unexpectedError(Object error) {
    return 'Unexpected error: $error';
  }

  @override
  String get loginGreeting =>
      'Welcome back! Sign in to continue your training.';

  @override
  String get signupGreeting => 'Create an account to unlock all workouts.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get signupButton => 'Sign up';

  @override
  String get noAccountPrompt => 'Don\'t have an account? Sign up';

  @override
  String get existingAccountPrompt => 'Already have an account? Sign in';

  @override
  String get forgotPasswordLink => 'Forgot your password?';

  @override
  String passwordResetEmailSent(String email) {
    return 'Password reset link sent to $email. Check your inbox.';
  }

  @override
  String get passwordResetEmailMissing =>
      'Enter your email to receive a reset link.';

  @override
  String get passwordResetDialogTitle => 'Choose a new password';

  @override
  String get passwordResetDialogDescription =>
      'Enter a new password to secure your account.';

  @override
  String get passwordResetNewPasswordLabel => 'New password';

  @override
  String get passwordResetConfirmPasswordLabel => 'Confirm new password';

  @override
  String get passwordResetMismatch => 'Passwords do not match.';

  @override
  String get passwordResetSuccess =>
      'Password updated successfully. You can continue using the app.';

  @override
  String get passwordResetSubmit => 'Update password';

  @override
  String get exerciseAddDialogTitle => 'Add exercise';

  @override
  String get exerciseNameLabel => 'Exercise name';

  @override
  String get quickAddValuesLabel => 'Quick add values';

  @override
  String get quickAddValuesHelper =>
      'Comma separated repetitions (e.g. 1,5,10)';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get exerciseNameMissing => 'Please provide a name.';

  @override
  String get exerciseTargetRepsLabel => 'Target reps';

  @override
  String get exerciseTargetRepsHelper => 'Optional total goal for the session';

  @override
  String get exerciseRestDurationLabel => 'Rest duration (seconds)';

  @override
  String get exerciseRestDurationHelper => 'Optional countdown timer preset';

  @override
  String get exerciseTrackerEmpty => 'No exercises yet. Tap + to add one!';

  @override
  String get exerciseAddButton => 'Add exercise';

  @override
  String get exercisePushUps => 'Push-ups';

  @override
  String get exercisePullUps => 'Pull-ups';

  @override
  String get exerciseChinUps => 'Chin-ups';

  @override
  String exerciseTotalReps(int count) {
    return '$count total reps';
  }

  @override
  String exerciseGoalProgress(int logged, int goal) {
    return '$logged / $goal reps logged';
  }

  @override
  String exerciseRestFinished(String exercise) {
    return 'Rest finished for $exercise!';
  }

  @override
  String get exerciseSetRestDuration => 'Set rest duration';

  @override
  String get exerciseDurationSecondsLabel => 'Duration (seconds)';

  @override
  String get restTimerLabel => 'Rest timer';

  @override
  String get setDuration => 'Set duration';

  @override
  String get undoLastSet => 'Undo last set';

  @override
  String get custom => 'Custom';

  @override
  String get reset => 'Reset';

  @override
  String get logRepsTitle => 'Log reps';

  @override
  String get repetitionsLabel => 'Repetitions';

  @override
  String get positiveNumberError => 'Enter a positive number.';

  @override
  String repsChip(int count) {
    return '$count reps';
  }

  @override
  String goalCount(int count) {
    return 'Goal: $count';
  }

  @override
  String get repGoalReached => 'Rep goal reached!';

  @override
  String get pause => 'Pause';

  @override
  String get start => 'Start';

  @override
  String seriesCount(int count) {
    return 'Sets: $count';
  }

  @override
  String get resetReps => 'Reset reps';

  @override
  String get emomTrackerTitle => 'EMOM tracker';

  @override
  String get emomTrackerSubtitle =>
      'Guided every-minute sets with prep countdown.';

  @override
  String get emomTrackerDescription =>
      'Configure sets, reps, and intervals to stay on pace each minute.';

  @override
  String get emomSetsLabel => 'Total sets';

  @override
  String get emomRepsLabel => 'Reps per set';

  @override
  String get emomIntervalLabel => 'Interval (seconds)';

  @override
  String get emomStartButton => 'Start EMOM';

  @override
  String get emomResetButton => 'Reset session';

  @override
  String get emomSessionComplete => 'EMOM complete';

  @override
  String emomCurrentSet(int current, int total) {
    return 'Set $current of $total';
  }

  @override
  String emomRepsPerSet(int count) {
    return '$count reps per set';
  }

  @override
  String get emomFinishedMessage => 'Nice work! You hit every minute.';

  @override
  String get emomTimeRemainingLabel => 'Time remaining this minute';

  @override
  String emomPrepHeadline(int set) {
    return 'Get ready for set $set';
  }

  @override
  String get emomPrepSubhead => 'The next set starts after this countdown.';

  @override
  String get timerTitle => 'Timer';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String weekNumber(int week) {
    return 'Week $week';
  }

  @override
  String get defaultWorkoutTitle => 'Workout';

  @override
  String get terminologyTitle => 'Terminology';

  @override
  String get termRepsTitle => 'Reps';

  @override
  String get termRepsDescription =>
      'Number of times you perform an exercise consecutively.';

  @override
  String get termSetTitle => 'Set';

  @override
  String get termSetDescription =>
      'A group of repetitions. For example: 3 sets of 10 reps means 30 repetitions total divided into 3 groups.';

  @override
  String get termRtTitle => 'RT';

  @override
  String get termRtDescription =>
      'Total Repetitions: perform all the reps with your preferred sets, reps, and tempo (if not specified).';

  @override
  String get termAmrapTitle => 'AMRAP';

  @override
  String get termAmrapDescription =>
      'As Many Reps As Possible: perform as many reps as you can in a given time.';

  @override
  String get termEmomTitle => 'EMOM';

  @override
  String get termEmomDescription =>
      'Every Minute on the Minute: start a set every minute. Rest during the remaining time.';

  @override
  String get termRampingTitle => 'Ramping';

  @override
  String get termRampingDescription =>
      'Method where the load increases with each set.';

  @override
  String get termMavTitle => 'MAV';

  @override
  String get termMavDescription =>
      'Massima Alzata Veloce: perform as many reps as possible with a load while keeping control and good speed.';

  @override
  String get termIsocineticiTitle => 'Isokinetic';

  @override
  String get termIsocineticiDescription =>
      'Exercises performed at a constant speed.';

  @override
  String get termTutTitle => 'TUT';

  @override
  String get termTutDescription =>
      'Indicates how long a repetition should last. You can manage the duration of each phase.';

  @override
  String get termIsoTitle => 'ISO';

  @override
  String get termIsoDescription =>
      'Indicates a pause at a specific point of the repetition.';

  @override
  String get termSomTitle => 'SOM';

  @override
  String get termSomDescription =>
      'Indicates the duration of each phase of the repetition.';

  @override
  String get termScaricoTitle => 'Deload';

  @override
  String get termScaricoDescription =>
      'Last week of the program to prepare for max attempts.';

  @override
  String get noCameras => 'No cameras available';

  @override
  String cameraInitFailed(Object error) {
    return 'Camera init failed: $error';
  }

  @override
  String get poseDetected => 'Pose detected';

  @override
  String get processing => 'Processing…';

  @override
  String get idle => 'Idle';

  @override
  String get cameraFront => 'front';

  @override
  String get cameraBack => 'back';

  @override
  String hudMetrics(String fps, String milliseconds, int landmarks) {
    return 'fps: $fps  ms: $milliseconds  lmks: $landmarks';
  }

  @override
  String hudOrientation(String rotation, String camera, String format) {
    return 'rot: $rotation  cam: $camera  fmt: $format';
  }
}

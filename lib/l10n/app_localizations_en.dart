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
  String get navGuides => 'Guides';

  @override
  String get navProfile => 'Profile';

  @override
  String get navTerminology => 'Terminology';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get themeDefaultLabel => 'Default';

  @override
  String get themeBlackLabel => 'Black';

  @override
  String get themePinkLabel => 'Pink';

  @override
  String get themeRedLabel => 'Red';

  @override
  String get themeBlueLabel => 'Blue';

  @override
  String get themeYellowLabel => 'Yellow';

  @override
  String get onboardingTitleOne => 'Train smarter';

  @override
  String get onboardingDescriptionOne =>
      'Follow guided workouts built for your calisthenics plan.';

  @override
  String get onboardingTitleTwo => 'Track progress';

  @override
  String get onboardingDescriptionTwo =>
      'Log sets, reps, and notes to see your improvements.';

  @override
  String get onboardingTitleThree => 'Stay consistent';

  @override
  String get onboardingDescriptionThree =>
      'Keep momentum with quick access to your next session.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get guidesTitle => 'Skills';

  @override
  String get guidesSubtitle =>
      'Explore techniques, focus areas, and coaching tips for every skill.';

  @override
  String get guidesLoadError => 'Unable to load skill guides right now.';

  @override
  String get guidesPrimaryFocus => 'Primary focus';

  @override
  String get guidesCoachTip => 'Coach tip';

  @override
  String get difficultyBeginner => 'Beginner';

  @override
  String get difficultyIntermediate => 'Intermediate';

  @override
  String get difficultyAdvanced => 'Advanced';

  @override
  String get homeLoadErrorTitle => 'Unable to load workouts';

  @override
  String get retry => 'Retry';

  @override
  String get homeCoachTipTitle => 'Coach Tip';

  @override
  String get homeCoachTipPlaceholder =>
      'Your coach\'s latest tip will appear here.';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name!';
  }

  @override
  String get homeViewStats => 'View Stats';

  @override
  String get homeProgressTitle => 'Monthly Progress';

  @override
  String get homeProgressWorkoutsLabel => 'Workouts';

  @override
  String get homeProgressTimeTrainedLabel => 'Time Trained';

  @override
  String homeProgressTimeValue(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get homeProgressNoPlan => 'No workout plan available yet.';

  @override
  String get homePlanStatsTitle => 'Plan stats';

  @override
  String get homePlanStatsDaysLabel => 'Days';

  @override
  String get homePlanStatsExercisesLabel => 'Exercises';

  @override
  String homePlanStatsCompletionValue(int progress) {
    return '$progress% completed';
  }

  @override
  String get workoutPlanTitle => 'Workout plan';

  @override
  String get traineeFeedbackTitle => 'Trainee feedback';

  @override
  String get traineeFeedbackSubtitle =>
      'Tell your coach how you\'re feeling and how the plan is going.';

  @override
  String get traineeFeedbackQuestionLabel => 'How did your training feel?';

  @override
  String get traineeFeedbackQuestionHint =>
      'Share anything going well or that needs attention.';

  @override
  String get traineeFeedbackFeelingLabel => 'How are you feeling today?';

  @override
  String get traineeFeedbackFeelingHint =>
      'Pick one option before sending your feedback.';

  @override
  String get traineeFeedbackFeelingVeryBad => 'Very bad';

  @override
  String get traineeFeedbackFeelingBad => 'Bad';

  @override
  String get traineeFeedbackFeelingOk => 'Ok';

  @override
  String get traineeFeedbackFeelingGood => 'Good';

  @override
  String get traineeFeedbackFeelingVeryGood => 'Very good';

  @override
  String get traineeFeedbackSubmit => 'Send feedback';

  @override
  String get traineeFeedbackSubmitted =>
      'Feedback saved. We\'ll share it with your coach.';

  @override
  String get traineeFeedbackLoadFailed => 'Unable to load feedback right now.';

  @override
  String get traineeFeedbackDelete => 'Delete feedback';

  @override
  String get traineeFeedbackDeleteTitle => 'Delete feedback?';

  @override
  String get traineeFeedbackDeleteMessage =>
      'Delete this feedback? This cannot be undone.';

  @override
  String get refresh => 'Refresh';

  @override
  String get homeEmptyTitle => 'No workouts available';

  @override
  String get homeEmptyDescription =>
      'Contact your coach to receive a new plan.';

  @override
  String get homeLatePaymentDescription =>
      'Your payment is due. Please settle it to keep your plan active.';

  @override
  String get homePlanDefaultTitle => 'Workout plan';

  @override
  String get homePlanLatestLabel => 'Latest plan';

  @override
  String homePlanStartedLabel(String date) {
    return 'Started $date';
  }

  @override
  String get unauthenticated => 'User not authenticated';

  @override
  String get defaultExerciseName => 'Exercise';

  @override
  String get trainingHeaderExercise => 'Exercise';

  @override
  String get trainingHeaderExercises => 'Exercises';

  @override
  String get trainingHeaderSets => 'Sets';

  @override
  String get trainingHeaderReps => 'Repetitions';

  @override
  String get trainingTodayTitle => 'Today\'s Workout';

  @override
  String get trainingStartWorkout => 'Start Workout';

  @override
  String get trainingWorkoutCompleted => 'Workout Completed';

  @override
  String trainingDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get trainingCompletionSaved => 'Workout day updated';

  @override
  String trainingCompletionError(Object error) {
    return 'Unable to update workout: $error';
  }

  @override
  String get trainingCompletionUnavailable => 'Cannot update this workout day.';

  @override
  String get trainingExerciseCompletionSaved => 'Exercise updated';

  @override
  String trainingExerciseCompletionError(Object error) {
    return 'Unable to update exercise: $error';
  }

  @override
  String get trainingExerciseCompletionUnavailable =>
      'Cannot update this exercise.';

  @override
  String get trainingExerciseNotesTitle => 'Notes';

  @override
  String get trainingExerciseYourNotesLabel => 'Your notes';

  @override
  String get trainingExerciseSaveNotes => 'Save notes';

  @override
  String get trainingExerciseResolvedLabel => 'Mark as resolved';

  @override
  String get trainingExerciseNotesSaved => 'Notes updated';

  @override
  String trainingExerciseNotesError(Object error) {
    return 'Unable to update notes: $error';
  }

  @override
  String get trainingExerciseFeedbackTitle => 'Exercise feedback';

  @override
  String get trainingExerciseFeedbackHint =>
      'Add feedback for this completed exercise.';

  @override
  String get trainingExerciseFeedbackLabel => 'How did this exercise feel?';

  @override
  String get trainingExerciseSaveFeedback => 'Save feedback';

  @override
  String get trainingExerciseFeedbackSaved => 'Exercise feedback updated';

  @override
  String trainingExerciseFeedbackError(Object error) {
    return 'Unable to update exercise feedback: $error';
  }

  @override
  String get trainingExerciseRepsTitle => 'Completed repetitions';

  @override
  String get trainingExerciseRepsHint =>
      'Count the repetitions you completed, then save the result.';

  @override
  String get trainingExerciseRepsDecrease => 'Decrease repetitions';

  @override
  String get trainingExerciseRepsIncrease => 'Increase repetitions';

  @override
  String trainingExerciseRepsCount(int count) {
    return '$count completed repetitions';
  }

  @override
  String get trainingExerciseSaveReps => 'Save reps';

  @override
  String get trainingExerciseRepsSaved => 'Repetitions updated';

  @override
  String trainingExerciseRepsError(Object error) {
    return 'Unable to update repetitions: $error';
  }

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
  String get profileNotSet => 'Not set';

  @override
  String get profileWeight => 'Weight';

  @override
  String profileWeightValue(String weight) {
    return '$weight kg';
  }

  @override
  String get profileHeight => 'Height';

  @override
  String profileHeightValue(String height) {
    return '$height cm';
  }

  @override
  String get profileMaxTestsTitle => 'Max test tracking';

  @override
  String get profileMaxTestsDescription =>
      'Log your best attempts to see how your strength evolves over time.';

  @override
  String get profileMaxTestsPeriodLabel => 'Period';

  @override
  String get profileMaxTestsPeriodMonth => 'Last 1 month';

  @override
  String get profileMaxTestsPeriodHalfYear => 'Last 6 months';

  @override
  String get profileMaxTestsPeriodYear => 'Last 1 year';

  @override
  String get profileMaxTestsPeriodAll => 'All time';

  @override
  String profileMaxTestsEmptyPeriod(String period) {
    return 'No max tests recorded in $period. Try a longer time range.';
  }

  @override
  String get profileMaxTestsBestPeriodLabel => 'Best in selected period';

  @override
  String get profileMaxTestsRefresh => 'Refresh';

  @override
  String get profileMaxTestsHistoryAction => 'View progress';

  @override
  String get profileMaxTestsEmpty =>
      'No max tests recorded yet. Add your first attempt to start tracking progress.';

  @override
  String get profileMaxTestsHistoryTitle => 'Progress over time';

  @override
  String get profileMaxTestsHistoryDescription =>
      'Review each attempt and see how your max values evolve.';

  @override
  String get profileMaxTestsHistoryEmpty =>
      'No max tests recorded yet. Add a new attempt to see your progress over time.';

  @override
  String get profileMaxTestsRecentPerformanceLabel => 'Recent Performance';

  @override
  String get profileMaxTestsGoalLabel => 'Goal';

  @override
  String get profileMaxTestsTipsTitle => 'Tips & Tutorials';

  @override
  String get profileMaxTestsTipsSubtitle =>
      'Review technique cues and accessory drills.';

  @override
  String get profileMaxTestsEmptyShort =>
      'Add a new test to see your performance chart.';

  @override
  String profileMaxTestsSessionLabel(int index) {
    return 'Session $index';
  }

  @override
  String profileMaxTestsHistoryError(Object error) {
    return 'Unable to load progress history: $error';
  }

  @override
  String profileMaxTestsHistoryDeltaLabel(String delta) {
    return 'Change $delta';
  }

  @override
  String get profileMaxTestsHistoryFirstEntry => 'First recorded attempt';

  @override
  String profileMaxTestsError(Object error) {
    return 'Unable to load max tests: $error';
  }

  @override
  String profileMaxTestsDateLabel(String date) {
    return 'Recorded on $date';
  }

  @override
  String get profileMaxTestsBestLabel => 'Personal best';

  @override
  String get profileMaxTestsShowMore => 'Show all attempts';

  @override
  String get profileMaxTestsShowLess => 'Show fewer attempts';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileEditSubtitle => 'Update your personal details';

  @override
  String get profileThemeSettingsTitle => 'Theme colors';

  @override
  String get profileThemeSettingsSubtitle => 'Choose the app color theme';

  @override
  String get profileLanguageSettingsTitle => 'Language';

  @override
  String get profileLanguageSettingsSubtitle => 'Choose the app language';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileEditFullNameLabel => 'Full name';

  @override
  String get profileEditFullNameHint => 'How should we call you?';

  @override
  String get profileEditWeightLabel => 'Weight';

  @override
  String get profileEditWeightHint => 'Enter your weight in kg (optional)';

  @override
  String get profileEditWeightInvalid => 'Enter a valid positive weight.';

  @override
  String get profileEditHeightLabel => 'Height';

  @override
  String get profileEditHeightHint => 'Enter your height in cm (optional)';

  @override
  String get profileEditHeightInvalid => 'Enter a valid positive height.';

  @override
  String get profilePhotoEdit => 'Change photo';

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
  String get logout => 'Log out';

  @override
  String get languageSystemLabel => 'System default';

  @override
  String get languageEnglishLabel => 'English';

  @override
  String get languageItalianLabel => 'Italian';

  @override
  String get languageSpanishLabel => 'Spanish';

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
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get start => 'Start';

  @override
  String get timerTitle => 'Timer';

  @override
  String get timerExercisePushUps => 'Push-ups';

  @override
  String get timerExercisePullUps => 'Pull-ups';

  @override
  String get timerExerciseSquats => 'Squats';

  @override
  String get timerExercisePlank => 'Plank';

  @override
  String get timerPhaseWork => 'WORK';

  @override
  String get timerPhaseRest => 'REST';

  @override
  String get timerWorkDurationLabel => 'Work duration';

  @override
  String get timerRestDurationLabel => 'Rest duration';

  @override
  String get timerRoundsLabel => 'Rounds';

  @override
  String get timerExercisesLabel => 'Exercises';

  @override
  String get timerAddExercise => 'Add exercise';

  @override
  String get timerExerciseNameLabel => 'Exercise name';

  @override
  String get timerExerciseNameHint => 'E.g. Muscle up, Dips, L-sit';

  @override
  String get timerNoExercisesConfigured =>
      'Add at least one exercise to start the timer.';

  @override
  String get timerControlSkip => 'SKIP';

  @override
  String get timerControlPause => 'PAUSE';

  @override
  String get timerControlPlay => 'PLAY';

  @override
  String get timerControlReset => 'RESET';

  @override
  String get timerAdjustDecrease => '-10s';

  @override
  String get timerAdjustIncrease => '+10s';

  @override
  String get timerCountdownGo => 'Go';

  @override
  String get timerCountdownStop => 'Stop';

  @override
  String get timerNextPlaceholder => 'Next: --';

  @override
  String timerNextLabel(String name, int current, int total) {
    return 'Next: $name · Set $current/$total';
  }

  @override
  String weekNumber(int week) {
    return 'Week $week';
  }

  @override
  String get defaultWorkoutTitle => 'Workout';

  @override
  String get terminologyTitle => 'Terminology';

  @override
  String get traineeFeedbackAnsweredTitle => 'Answered feedback';

  @override
  String get traineeFeedbackAnsweredEmpty => 'No answered feedback yet.';

  @override
  String get traineeFeedbackAnsweredChip => 'Answered';

  @override
  String get traineeFeedbackSentAt => 'Sent:';

  @override
  String get traineeFeedbackAnsweredAt => 'Answered:';

  @override
  String get traineeFeedbackTrainerAnswer => 'Trainer answer';

  @override
  String get traineeFeedbackLastAnsweredTitle => 'Latest trainer answer';

  @override
  String get traineeFeedbackYourMessage => 'Your message';

  @override
  String get traineeFeedbackAnsweredAtHome => 'Answered on';

  @override
  String get trainerMenuGroup => 'TRAINER';

  @override
  String get trainerNavDashboard => 'Trainer dashboard';

  @override
  String get trainerNavTrainees => 'My trainees';

  @override
  String get trainerNavFeedback => 'Trainer feedback';

  @override
  String get trainerNavPayments => 'Trainee payments';

  @override
  String get trainerWorkspaceTitle => 'Trainer workspace';

  @override
  String get trainerWorkspaceSubtitle =>
      'Your assigned athletes and their latest activity.';

  @override
  String get trainerAssignedTrainees => 'Assigned trainees';

  @override
  String get trainerUnreadFeedback => 'Unread feedback';

  @override
  String get trainerActivePlans => 'Active plans';

  @override
  String get trainerOverdue => 'Overdue';

  @override
  String get trainerTraineesTitle => 'Trainees';

  @override
  String get trainerNoAssignedTrainees =>
      'No trainees are assigned to you yet.';

  @override
  String get trainerStatusActive => 'Active';

  @override
  String get trainerPlanProgress => 'Plan progress';

  @override
  String get trainerOpenProgram => 'Open program';

  @override
  String get trainerSearchTrainees => 'Search trainees';

  @override
  String trainerAssignedCount(int count) {
    return '$count assigned trainees';
  }

  @override
  String get trainerNoMatchingTrainees => 'No matching trainees.';

  @override
  String get trainerFilterAll => 'All';

  @override
  String get trainerFilterUnread => 'Unread';

  @override
  String get trainerFilterAnswered => 'Answered';

  @override
  String get trainerNoFeedbackInView => 'No feedback in this view.';

  @override
  String get trainerStatusRead => 'Read';

  @override
  String get trainerStatusUnread => 'Unread';

  @override
  String get trainerYourAnswer => 'Your answer';

  @override
  String get trainerReplyHint => 'Reply to trainee';

  @override
  String get trainerSendAnswer => 'Send answer';

  @override
  String get trainerMarkUnread => 'Mark unread';

  @override
  String get trainerMarkRead => 'Mark read';

  @override
  String get trainerAnswerRequired => 'Write an answer first.';

  @override
  String get trainerPaid => 'Paid';

  @override
  String get trainerReceived => 'Received';

  @override
  String get trainerMonthlyAmount => 'Monthly amount';

  @override
  String get trainerAppAccessActive => 'App access active';

  @override
  String trainerLoadToolsError(String error) {
    return 'Unable to load trainer tools\n$error';
  }

  @override
  String get trainerRetry => 'Retry';

  @override
  String get trainerOverviewTab => 'Overview';

  @override
  String get trainerPlanTab => 'Plan';

  @override
  String get trainerHistoryTab => 'History';

  @override
  String trainerLoadProgramError(String error) {
    return 'Unable to load program\n$error';
  }

  @override
  String get trainerAthleteData => 'Athlete data';

  @override
  String get trainerNameLabel => 'Name';

  @override
  String get trainerWeightLabel => 'Weight';

  @override
  String get trainerPaymentLabel => 'Payment';

  @override
  String get trainerOnTime => 'On time';

  @override
  String get trainerProgressLabel => 'Progress';

  @override
  String get trainerCoachTip => 'Coach tip';

  @override
  String get trainerCoachTipHint => 'Visible to the trainee in the app';

  @override
  String get trainerPrivateNotes => 'Private trainer notes';

  @override
  String get trainerSave => 'Save';

  @override
  String get trainerCoachFieldsSaved => 'Coach tip and private notes saved.';

  @override
  String get trainerTrainingCalendar => 'Training calendar';

  @override
  String get trainerNoScheduledDays => 'No scheduled days.';

  @override
  String get trainerFeedbackTitle => 'Feedback';

  @override
  String get trainerNoFeedbackYet => 'No feedback yet.';

  @override
  String get trainerCreateWorkoutPlan => 'Create workout plan';

  @override
  String get trainerImportPdf => 'Import PDF';

  @override
  String get trainerImportingPdf => 'Reading PDF…';

  @override
  String get trainerPdfPreviewTitle => 'Review imported plan';

  @override
  String get trainerPdfPlanName => 'Plan name';

  @override
  String trainerPdfSummary(int days, int exercises) {
    return '$days days and $exercises exercises detected';
  }

  @override
  String trainerPdfDaySummary(int week, String day, int exercises) {
    return 'Week $week · Day $day: $exercises exercises';
  }

  @override
  String get trainerPdfConfirmImport => 'Import plan';

  @override
  String get trainerPdfImportSuccess => 'Workout plan imported successfully.';

  @override
  String get trainerPdfImportFailed =>
      'The PDF could not be imported. Make sure it contains GIORNO A–G workout tables.';

  @override
  String get trainerPdfPathUnavailable =>
      'The selected PDF is not available on this device.';

  @override
  String get trainerNoPlans => 'No plans created.';

  @override
  String get trainerWorkoutPlanFallback => 'Workout plan';

  @override
  String get trainerPlanStatusActive => 'Active';

  @override
  String get trainerPlanStatusInactive => 'Inactive';

  @override
  String get trainerPlanStatusUpcoming => 'Upcoming';

  @override
  String get trainerPlanStatusDraft => 'Draft';

  @override
  String get trainerPlanStatusArchived => 'Archived';

  @override
  String get trainerWorkoutDays => 'Workout days';

  @override
  String get trainerMaxTests => 'Max tests';

  @override
  String get trainerNoMaxTests => 'No max tests.';

  @override
  String get trainerWeightHistory => 'Weight history';

  @override
  String get trainerNoWeightEntries => 'No weight entries.';

  @override
  String get trainerPaymentHistory => 'Payment history';

  @override
  String get trainerNoPayments => 'No payments.';

  @override
  String get trainerTrainingDayFallback => 'Training day';

  @override
  String trainerExercisesCompleted(int completed, int total) {
    return '$completed/$total exercises completed';
  }

  @override
  String get trainerExerciseFallback => 'Exercise';

  @override
  String trainerMinutesDuration(String minutes) {
    return '$minutes min';
  }

  @override
  String trainerExerciseResult(String minutes, String reps) {
    return '$minutes min · $reps reps';
  }

  @override
  String trainerTraineeNote(String notes) {
    return 'Trainee: $notes';
  }

  @override
  String get trainerDeletePlanTitle => 'Delete plan?';

  @override
  String trainerDeletePlanMessage(String title) {
    return 'Delete “$title”?';
  }

  @override
  String get trainerCancel => 'Cancel';

  @override
  String get trainerDelete => 'Delete';

  @override
  String get trainerDeleteFeedback => 'Delete feedback';

  @override
  String get trainerDeleteFeedbackTitle => 'Delete feedback?';

  @override
  String trainerDeleteFeedbackMessage(String name) {
    return 'Delete this feedback from $name? This cannot be undone.';
  }

  @override
  String get trainerNewPlan => 'New workout plan';

  @override
  String get trainerPlanName => 'Plan name';

  @override
  String get trainerNotes => 'Notes';

  @override
  String get trainerCreate => 'Create';
}

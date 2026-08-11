import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In it, this message translates to:
  /// **'Calisync'**
  String get appTitle;

  /// No description provided for @authErrorMessage.
  ///
  /// In it, this message translates to:
  /// **'Errore durante l\'autenticazione'**
  String get authErrorMessage;

  /// No description provided for @navHome.
  ///
  /// In it, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navGuides.
  ///
  /// In it, this message translates to:
  /// **'Guide'**
  String get navGuides;

  /// No description provided for @navProfile.
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get navProfile;

  /// No description provided for @navTerminology.
  ///
  /// In it, this message translates to:
  /// **'Terminologia'**
  String get navTerminology;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In it, this message translates to:
  /// **'Tema'**
  String get settingsThemeTitle;

  /// No description provided for @themeDefaultLabel.
  ///
  /// In it, this message translates to:
  /// **'Predefinito'**
  String get themeDefaultLabel;

  /// No description provided for @themeBlackLabel.
  ///
  /// In it, this message translates to:
  /// **'Nero'**
  String get themeBlackLabel;

  /// No description provided for @themePinkLabel.
  ///
  /// In it, this message translates to:
  /// **'Rosa'**
  String get themePinkLabel;

  /// No description provided for @themeRedLabel.
  ///
  /// In it, this message translates to:
  /// **'Rosso'**
  String get themeRedLabel;

  /// No description provided for @themeBlueLabel.
  ///
  /// In it, this message translates to:
  /// **'Blu'**
  String get themeBlueLabel;

  /// No description provided for @themeYellowLabel.
  ///
  /// In it, this message translates to:
  /// **'Giallo'**
  String get themeYellowLabel;

  /// No description provided for @onboardingTitleOne.
  ///
  /// In it, this message translates to:
  /// **'Allenati meglio'**
  String get onboardingTitleOne;

  /// No description provided for @onboardingDescriptionOne.
  ///
  /// In it, this message translates to:
  /// **'Segui allenamenti guidati creati per il tuo piano di calisthenics.'**
  String get onboardingDescriptionOne;

  /// No description provided for @onboardingTitleTwo.
  ///
  /// In it, this message translates to:
  /// **'Monitora i progressi'**
  String get onboardingTitleTwo;

  /// No description provided for @onboardingDescriptionTwo.
  ///
  /// In it, this message translates to:
  /// **'Registra serie, ripetizioni e note per vedere i miglioramenti.'**
  String get onboardingDescriptionTwo;

  /// No description provided for @onboardingTitleThree.
  ///
  /// In it, this message translates to:
  /// **'Rimani costante'**
  String get onboardingTitleThree;

  /// No description provided for @onboardingDescriptionThree.
  ///
  /// In it, this message translates to:
  /// **'Mantieni il ritmo con accesso rapido alla prossima sessione.'**
  String get onboardingDescriptionThree;

  /// No description provided for @onboardingSkip.
  ///
  /// In it, this message translates to:
  /// **'Salta'**
  String get onboardingSkip;

  /// No description provided for @onboardingBack.
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get onboardingBack;

  /// No description provided for @onboardingNext.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In it, this message translates to:
  /// **'Inizia'**
  String get onboardingGetStarted;

  /// No description provided for @guidesTitle.
  ///
  /// In it, this message translates to:
  /// **'Skill'**
  String get guidesTitle;

  /// No description provided for @guidesSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Esplora tecnica, focus e consigli del coach per ogni skill.'**
  String get guidesSubtitle;

  /// No description provided for @guidesLoadError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile caricare le guide delle skill al momento.'**
  String get guidesLoadError;

  /// No description provided for @guidesPrimaryFocus.
  ///
  /// In it, this message translates to:
  /// **'Focus principale'**
  String get guidesPrimaryFocus;

  /// No description provided for @guidesCoachTip.
  ///
  /// In it, this message translates to:
  /// **'Consiglio del coach'**
  String get guidesCoachTip;

  /// No description provided for @difficultyBeginner.
  ///
  /// In it, this message translates to:
  /// **'Principiante'**
  String get difficultyBeginner;

  /// No description provided for @difficultyIntermediate.
  ///
  /// In it, this message translates to:
  /// **'Intermedio'**
  String get difficultyIntermediate;

  /// No description provided for @difficultyAdvanced.
  ///
  /// In it, this message translates to:
  /// **'Avanzato'**
  String get difficultyAdvanced;

  /// No description provided for @homeLoadErrorTitle.
  ///
  /// In it, this message translates to:
  /// **'Impossibile caricare gli allenamenti'**
  String get homeLoadErrorTitle;

  /// No description provided for @retry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get retry;

  /// No description provided for @homeCoachTipTitle.
  ///
  /// In it, this message translates to:
  /// **'Consiglio del coach'**
  String get homeCoachTipTitle;

  /// No description provided for @homeCoachTipPlaceholder.
  ///
  /// In it, this message translates to:
  /// **'Qui troverai l\'ultimo consiglio del tuo coach.'**
  String get homeCoachTipPlaceholder;

  /// No description provided for @homeGreeting.
  ///
  /// In it, this message translates to:
  /// **'Ciao, {name}!'**
  String homeGreeting(String name);

  /// No description provided for @homeViewStats.
  ///
  /// In it, this message translates to:
  /// **'Vedi statistiche'**
  String get homeViewStats;

  /// No description provided for @homeProgressTitle.
  ///
  /// In it, this message translates to:
  /// **'Progressi mensili'**
  String get homeProgressTitle;

  /// No description provided for @homeProgressWorkoutsLabel.
  ///
  /// In it, this message translates to:
  /// **'Allenamenti'**
  String get homeProgressWorkoutsLabel;

  /// No description provided for @homeProgressTimeTrainedLabel.
  ///
  /// In it, this message translates to:
  /// **'Tempo di allenamento'**
  String get homeProgressTimeTrainedLabel;

  /// No description provided for @homeProgressTimeValue.
  ///
  /// In it, this message translates to:
  /// **'{hours}h {minutes}m'**
  String homeProgressTimeValue(int hours, int minutes);

  /// No description provided for @homeProgressNoPlan.
  ///
  /// In it, this message translates to:
  /// **'Nessun workout plan disponibile al momento.'**
  String get homeProgressNoPlan;

  /// No description provided for @homePlanStatsTitle.
  ///
  /// In it, this message translates to:
  /// **'Statistiche del piano'**
  String get homePlanStatsTitle;

  /// No description provided for @homePlanStatsDaysLabel.
  ///
  /// In it, this message translates to:
  /// **'Giorni'**
  String get homePlanStatsDaysLabel;

  /// No description provided for @homePlanStatsExercisesLabel.
  ///
  /// In it, this message translates to:
  /// **'Esercizi'**
  String get homePlanStatsExercisesLabel;

  /// No description provided for @homePlanStatsCompletionValue.
  ///
  /// In it, this message translates to:
  /// **'{progress}% completato'**
  String homePlanStatsCompletionValue(int progress);

  /// No description provided for @workoutPlanTitle.
  ///
  /// In it, this message translates to:
  /// **'Piano di allenamento'**
  String get workoutPlanTitle;

  /// No description provided for @traineeFeedbackTitle.
  ///
  /// In it, this message translates to:
  /// **'Feedback atleta'**
  String get traineeFeedbackTitle;

  /// No description provided for @traineeFeedbackSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Racconta al tuo coach come ti senti e come procede il piano.'**
  String get traineeFeedbackSubtitle;

  /// No description provided for @traineeFeedbackQuestionLabel.
  ///
  /// In it, this message translates to:
  /// **'Come è andato l\'allenamento?'**
  String get traineeFeedbackQuestionLabel;

  /// No description provided for @traineeFeedbackQuestionHint.
  ///
  /// In it, this message translates to:
  /// **'Condividi cosa sta andando bene o cosa richiede attenzione.'**
  String get traineeFeedbackQuestionHint;

  /// No description provided for @traineeFeedbackFeelingLabel.
  ///
  /// In it, this message translates to:
  /// **'Come ti senti oggi?'**
  String get traineeFeedbackFeelingLabel;

  /// No description provided for @traineeFeedbackFeelingHint.
  ///
  /// In it, this message translates to:
  /// **'Scegli un\'opzione prima di inviare il feedback.'**
  String get traineeFeedbackFeelingHint;

  /// No description provided for @traineeFeedbackFeelingVeryBad.
  ///
  /// In it, this message translates to:
  /// **'Molto male'**
  String get traineeFeedbackFeelingVeryBad;

  /// No description provided for @traineeFeedbackFeelingBad.
  ///
  /// In it, this message translates to:
  /// **'Male'**
  String get traineeFeedbackFeelingBad;

  /// No description provided for @traineeFeedbackFeelingOk.
  ///
  /// In it, this message translates to:
  /// **'Così così'**
  String get traineeFeedbackFeelingOk;

  /// No description provided for @traineeFeedbackFeelingGood.
  ///
  /// In it, this message translates to:
  /// **'Bene'**
  String get traineeFeedbackFeelingGood;

  /// No description provided for @traineeFeedbackFeelingVeryGood.
  ///
  /// In it, this message translates to:
  /// **'Molto bene'**
  String get traineeFeedbackFeelingVeryGood;

  /// No description provided for @traineeFeedbackSubmit.
  ///
  /// In it, this message translates to:
  /// **'Invia feedback'**
  String get traineeFeedbackSubmit;

  /// No description provided for @traineeFeedbackSubmitted.
  ///
  /// In it, this message translates to:
  /// **'Feedback salvato. Lo condivideremo con il tuo coach.'**
  String get traineeFeedbackSubmitted;

  /// No description provided for @traineeFeedbackLoadFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile caricare il feedback in questo momento.'**
  String get traineeFeedbackLoadFailed;

  /// No description provided for @refresh.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna'**
  String get refresh;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In it, this message translates to:
  /// **'Nessun allenamento disponibile'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyDescription.
  ///
  /// In it, this message translates to:
  /// **'Contatta il tuo coach per ricevere una nuova scheda.'**
  String get homeEmptyDescription;

  /// No description provided for @homeLatePaymentDescription.
  ///
  /// In it, this message translates to:
  /// **'Il pagamento è in scadenza. Effettualo per mantenere attivo il tuo piano.'**
  String get homeLatePaymentDescription;

  /// No description provided for @homePlanDefaultTitle.
  ///
  /// In it, this message translates to:
  /// **'Piano di allenamento'**
  String get homePlanDefaultTitle;

  /// No description provided for @homePlanLatestLabel.
  ///
  /// In it, this message translates to:
  /// **'Ultimo piano'**
  String get homePlanLatestLabel;

  /// No description provided for @homePlanStartedLabel.
  ///
  /// In it, this message translates to:
  /// **'Iniziato il {date}'**
  String homePlanStartedLabel(String date);

  /// No description provided for @unauthenticated.
  ///
  /// In it, this message translates to:
  /// **'Utente non autenticato'**
  String get unauthenticated;

  /// No description provided for @defaultExerciseName.
  ///
  /// In it, this message translates to:
  /// **'Esercizio'**
  String get defaultExerciseName;

  /// No description provided for @trainingHeaderExercise.
  ///
  /// In it, this message translates to:
  /// **'Esercizio'**
  String get trainingHeaderExercise;

  /// No description provided for @trainingHeaderExercises.
  ///
  /// In it, this message translates to:
  /// **'Esercizi'**
  String get trainingHeaderExercises;

  /// No description provided for @trainingHeaderSets.
  ///
  /// In it, this message translates to:
  /// **'Serie'**
  String get trainingHeaderSets;

  /// No description provided for @trainingHeaderReps.
  ///
  /// In it, this message translates to:
  /// **'Ripetizioni'**
  String get trainingHeaderReps;

  /// No description provided for @trainingTodayTitle.
  ///
  /// In it, this message translates to:
  /// **'Allenamento di oggi'**
  String get trainingTodayTitle;

  /// No description provided for @trainingStartWorkout.
  ///
  /// In it, this message translates to:
  /// **'Inizia allenamento'**
  String get trainingStartWorkout;

  /// No description provided for @trainingWorkoutCompleted.
  ///
  /// In it, this message translates to:
  /// **'Allenamento completato'**
  String get trainingWorkoutCompleted;

  /// No description provided for @trainingDurationMinutes.
  ///
  /// In it, this message translates to:
  /// **'{minutes} min'**
  String trainingDurationMinutes(int minutes);

  /// No description provided for @trainingCompletionSaved.
  ///
  /// In it, this message translates to:
  /// **'Allenamento aggiornato'**
  String get trainingCompletionSaved;

  /// No description provided for @trainingCompletionError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aggiornare l\'allenamento: {error}'**
  String trainingCompletionError(Object error);

  /// No description provided for @trainingCompletionUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aggiornare questo giorno di allenamento.'**
  String get trainingCompletionUnavailable;

  /// No description provided for @trainingExerciseCompletionSaved.
  ///
  /// In it, this message translates to:
  /// **'Esercizio aggiornato'**
  String get trainingExerciseCompletionSaved;

  /// No description provided for @trainingExerciseCompletionError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aggiornare l\'esercizio: {error}'**
  String trainingExerciseCompletionError(Object error);

  /// No description provided for @trainingExerciseCompletionUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aggiornare questo esercizio.'**
  String get trainingExerciseCompletionUnavailable;

  /// No description provided for @trainingExerciseNotesTitle.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get trainingExerciseNotesTitle;

  /// No description provided for @trainingExerciseYourNotesLabel.
  ///
  /// In it, this message translates to:
  /// **'Le tue note'**
  String get trainingExerciseYourNotesLabel;

  /// No description provided for @trainingExerciseSaveNotes.
  ///
  /// In it, this message translates to:
  /// **'Salva note'**
  String get trainingExerciseSaveNotes;

  /// No description provided for @trainingExerciseResolvedLabel.
  ///
  /// In it, this message translates to:
  /// **'Contrassegna come risolto'**
  String get trainingExerciseResolvedLabel;

  /// No description provided for @trainingExerciseNotesSaved.
  ///
  /// In it, this message translates to:
  /// **'Note aggiornate'**
  String get trainingExerciseNotesSaved;

  /// No description provided for @trainingExerciseNotesError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aggiornare le note: {error}'**
  String trainingExerciseNotesError(Object error);

  /// No description provided for @trainingExerciseFeedbackTitle.
  ///
  /// In it, this message translates to:
  /// **'Feedback esercizio'**
  String get trainingExerciseFeedbackTitle;

  /// No description provided for @trainingExerciseFeedbackHint.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi un feedback per questo esercizio completato.'**
  String get trainingExerciseFeedbackHint;

  /// No description provided for @trainingExerciseFeedbackLabel.
  ///
  /// In it, this message translates to:
  /// **'Come è andato questo esercizio?'**
  String get trainingExerciseFeedbackLabel;

  /// No description provided for @trainingExerciseSaveFeedback.
  ///
  /// In it, this message translates to:
  /// **'Salva feedback'**
  String get trainingExerciseSaveFeedback;

  /// No description provided for @trainingExerciseFeedbackSaved.
  ///
  /// In it, this message translates to:
  /// **'Feedback esercizio aggiornato'**
  String get trainingExerciseFeedbackSaved;

  /// No description provided for @trainingExerciseFeedbackError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aggiornare il feedback esercizio: {error}'**
  String trainingExerciseFeedbackError(Object error);

  /// No description provided for @trainingExerciseRepsTitle.
  ///
  /// In it, this message translates to:
  /// **'Ripetizioni completate'**
  String get trainingExerciseRepsTitle;

  /// No description provided for @trainingExerciseRepsHint.
  ///
  /// In it, this message translates to:
  /// **'Conta le ripetizioni completate, quindi salva il risultato.'**
  String get trainingExerciseRepsHint;

  /// No description provided for @trainingExerciseRepsDecrease.
  ///
  /// In it, this message translates to:
  /// **'Diminuisci ripetizioni'**
  String get trainingExerciseRepsDecrease;

  /// No description provided for @trainingExerciseRepsIncrease.
  ///
  /// In it, this message translates to:
  /// **'Aumenta ripetizioni'**
  String get trainingExerciseRepsIncrease;

  /// No description provided for @trainingExerciseRepsCount.
  ///
  /// In it, this message translates to:
  /// **'{count} ripetizioni completate'**
  String trainingExerciseRepsCount(int count);

  /// No description provided for @trainingExerciseSaveReps.
  ///
  /// In it, this message translates to:
  /// **'Salva reps'**
  String get trainingExerciseSaveReps;

  /// No description provided for @trainingExerciseRepsSaved.
  ///
  /// In it, this message translates to:
  /// **'Ripetizioni aggiornate'**
  String get trainingExerciseRepsSaved;

  /// No description provided for @trainingExerciseRepsError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aggiornare le ripetizioni: {error}'**
  String trainingExerciseRepsError(Object error);

  /// No description provided for @logoutError.
  ///
  /// In it, this message translates to:
  /// **'Errore durante il logout: {error}'**
  String logoutError(Object error);

  /// No description provided for @profileFallbackName.
  ///
  /// In it, this message translates to:
  /// **'Utente'**
  String get profileFallbackName;

  /// No description provided for @userNotFound.
  ///
  /// In it, this message translates to:
  /// **'Utente non trovato nel database'**
  String get userNotFound;

  /// No description provided for @profileLoadError.
  ///
  /// In it, this message translates to:
  /// **'Errore nel caricamento dati'**
  String get profileLoadError;

  /// No description provided for @profileNoData.
  ///
  /// In it, this message translates to:
  /// **'Nessun dato disponibile'**
  String get profileNoData;

  /// No description provided for @profileEmailUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Email non disponibile'**
  String get profileEmailUnavailable;

  /// No description provided for @profileStatusActive.
  ///
  /// In it, this message translates to:
  /// **'Account attivo'**
  String get profileStatusActive;

  /// No description provided for @profileStatusInactive.
  ///
  /// In it, this message translates to:
  /// **'Account inattivo'**
  String get profileStatusInactive;

  /// No description provided for @profilePlanActive.
  ///
  /// In it, this message translates to:
  /// **'Piano attivo'**
  String get profilePlanActive;

  /// No description provided for @profilePlanExpired.
  ///
  /// In it, this message translates to:
  /// **'Piano scaduto'**
  String get profilePlanExpired;

  /// No description provided for @profileUsername.
  ///
  /// In it, this message translates to:
  /// **'Username'**
  String get profileUsername;

  /// No description provided for @profileNotSet.
  ///
  /// In it, this message translates to:
  /// **'Non impostato'**
  String get profileNotSet;

  /// No description provided for @profileWeight.
  ///
  /// In it, this message translates to:
  /// **'Peso'**
  String get profileWeight;

  /// No description provided for @profileWeightValue.
  ///
  /// In it, this message translates to:
  /// **'{weight} kg'**
  String profileWeightValue(String weight);

  /// No description provided for @profileHeight.
  ///
  /// In it, this message translates to:
  /// **'Altezza'**
  String get profileHeight;

  /// No description provided for @profileHeightValue.
  ///
  /// In it, this message translates to:
  /// **'{height} cm'**
  String profileHeightValue(String height);

  /// No description provided for @profileMaxTestsTitle.
  ///
  /// In it, this message translates to:
  /// **'Test massimali'**
  String get profileMaxTestsTitle;

  /// No description provided for @profileMaxTestsDescription.
  ///
  /// In it, this message translates to:
  /// **'Tieni traccia dei tuoi massimali per vedere come progredisci nel tempo.'**
  String get profileMaxTestsDescription;

  /// No description provided for @profileMaxTestsPeriodLabel.
  ///
  /// In it, this message translates to:
  /// **'Periodo'**
  String get profileMaxTestsPeriodLabel;

  /// No description provided for @profileMaxTestsPeriodMonth.
  ///
  /// In it, this message translates to:
  /// **'Ultimo mese'**
  String get profileMaxTestsPeriodMonth;

  /// No description provided for @profileMaxTestsPeriodHalfYear.
  ///
  /// In it, this message translates to:
  /// **'Ultimi 6 mesi'**
  String get profileMaxTestsPeriodHalfYear;

  /// No description provided for @profileMaxTestsPeriodYear.
  ///
  /// In it, this message translates to:
  /// **'Ultimo anno'**
  String get profileMaxTestsPeriodYear;

  /// No description provided for @profileMaxTestsPeriodAll.
  ///
  /// In it, this message translates to:
  /// **'Tutto il periodo'**
  String get profileMaxTestsPeriodAll;

  /// No description provided for @profileMaxTestsEmptyPeriod.
  ///
  /// In it, this message translates to:
  /// **'Nessun test massimale registrato in {period}. Prova un intervallo più lungo.'**
  String profileMaxTestsEmptyPeriod(String period);

  /// No description provided for @profileMaxTestsBestPeriodLabel.
  ///
  /// In it, this message translates to:
  /// **'Migliore nel periodo selezionato'**
  String get profileMaxTestsBestPeriodLabel;

  /// No description provided for @profileMaxTestsRefresh.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna'**
  String get profileMaxTestsRefresh;

  /// No description provided for @profileMaxTestsHistoryAction.
  ///
  /// In it, this message translates to:
  /// **'Vedi progressi'**
  String get profileMaxTestsHistoryAction;

  /// No description provided for @profileMaxTestsEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessun test massimale registrato. Aggiungi il primo per iniziare a tracciare i progressi.'**
  String get profileMaxTestsEmpty;

  /// No description provided for @profileMaxTestsHistoryTitle.
  ///
  /// In it, this message translates to:
  /// **'Progressi nel tempo'**
  String get profileMaxTestsHistoryTitle;

  /// No description provided for @profileMaxTestsHistoryDescription.
  ///
  /// In it, this message translates to:
  /// **'Rivedi ogni prova e osserva come evolvono i tuoi massimali.'**
  String get profileMaxTestsHistoryDescription;

  /// No description provided for @profileMaxTestsHistoryEmpty.
  ///
  /// In it, this message translates to:
  /// **'Nessun test massimale registrato. Aggiungi una nuova prova per vedere i progressi nel tempo.'**
  String get profileMaxTestsHistoryEmpty;

  /// No description provided for @profileMaxTestsRecentPerformanceLabel.
  ///
  /// In it, this message translates to:
  /// **'Performance recente'**
  String get profileMaxTestsRecentPerformanceLabel;

  /// No description provided for @profileMaxTestsGoalLabel.
  ///
  /// In it, this message translates to:
  /// **'Obiettivo'**
  String get profileMaxTestsGoalLabel;

  /// No description provided for @profileMaxTestsTipsTitle.
  ///
  /// In it, this message translates to:
  /// **'Suggerimenti e tutorial'**
  String get profileMaxTestsTipsTitle;

  /// No description provided for @profileMaxTestsTipsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Rivedi i consigli tecnici e gli esercizi complementari.'**
  String get profileMaxTestsTipsSubtitle;

  /// No description provided for @profileMaxTestsEmptyShort.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi un nuovo test per vedere il grafico delle prestazioni.'**
  String get profileMaxTestsEmptyShort;

  /// No description provided for @profileMaxTestsSessionLabel.
  ///
  /// In it, this message translates to:
  /// **'Sessione {index}'**
  String profileMaxTestsSessionLabel(int index);

  /// No description provided for @profileMaxTestsHistoryError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile caricare lo storico dei progressi: {error}'**
  String profileMaxTestsHistoryError(Object error);

  /// No description provided for @profileMaxTestsHistoryDeltaLabel.
  ///
  /// In it, this message translates to:
  /// **'Variazione {delta}'**
  String profileMaxTestsHistoryDeltaLabel(String delta);

  /// No description provided for @profileMaxTestsHistoryFirstEntry.
  ///
  /// In it, this message translates to:
  /// **'Prima registrazione'**
  String get profileMaxTestsHistoryFirstEntry;

  /// No description provided for @profileMaxTestsError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile caricare i test massimali: {error}'**
  String profileMaxTestsError(Object error);

  /// No description provided for @profileMaxTestsDateLabel.
  ///
  /// In it, this message translates to:
  /// **'Registrato il {date}'**
  String profileMaxTestsDateLabel(String date);

  /// No description provided for @profileMaxTestsBestLabel.
  ///
  /// In it, this message translates to:
  /// **'Miglior risultato'**
  String get profileMaxTestsBestLabel;

  /// No description provided for @profileMaxTestsShowMore.
  ///
  /// In it, this message translates to:
  /// **'Mostra tutti i tentativi'**
  String get profileMaxTestsShowMore;

  /// No description provided for @profileMaxTestsShowLess.
  ///
  /// In it, this message translates to:
  /// **'Mostra meno tentativi'**
  String get profileMaxTestsShowLess;

  /// No description provided for @profileEdit.
  ///
  /// In it, this message translates to:
  /// **'Modifica profilo'**
  String get profileEdit;

  /// No description provided for @profileEditSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna le tue informazioni personali'**
  String get profileEditSubtitle;

  /// No description provided for @profileThemeSettingsTitle.
  ///
  /// In it, this message translates to:
  /// **'Colori del tema'**
  String get profileThemeSettingsTitle;

  /// No description provided for @profileThemeSettingsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Scegli il colore del tema dell\'app'**
  String get profileThemeSettingsSubtitle;

  /// No description provided for @profileLanguageSettingsTitle.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get profileLanguageSettingsTitle;

  /// No description provided for @profileLanguageSettingsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Scegli la lingua dell\'app'**
  String get profileLanguageSettingsSubtitle;

  /// No description provided for @profileEditTitle.
  ///
  /// In it, this message translates to:
  /// **'Modifica profilo'**
  String get profileEditTitle;

  /// No description provided for @profileEditFullNameLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome completo'**
  String get profileEditFullNameLabel;

  /// No description provided for @profileEditFullNameHint.
  ///
  /// In it, this message translates to:
  /// **'Come vuoi essere chiamato?'**
  String get profileEditFullNameHint;

  /// No description provided for @profileEditWeightLabel.
  ///
  /// In it, this message translates to:
  /// **'Peso'**
  String get profileEditWeightLabel;

  /// No description provided for @profileEditWeightHint.
  ///
  /// In it, this message translates to:
  /// **'Inserisci il tuo peso in kg (opzionale)'**
  String get profileEditWeightHint;

  /// No description provided for @profileEditWeightInvalid.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un peso valido e positivo.'**
  String get profileEditWeightInvalid;

  /// No description provided for @profileEditHeightLabel.
  ///
  /// In it, this message translates to:
  /// **'Altezza'**
  String get profileEditHeightLabel;

  /// No description provided for @profileEditHeightHint.
  ///
  /// In it, this message translates to:
  /// **'Inserisci la tua altezza in cm (opzionale)'**
  String get profileEditHeightHint;

  /// No description provided for @profileEditHeightInvalid.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un\'altezza valida e positiva.'**
  String get profileEditHeightInvalid;

  /// No description provided for @profilePhotoEdit.
  ///
  /// In it, this message translates to:
  /// **'Cambia foto'**
  String get profilePhotoEdit;

  /// No description provided for @profileEditCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get profileEditCancel;

  /// No description provided for @profileEditSave.
  ///
  /// In it, this message translates to:
  /// **'Salva modifiche'**
  String get profileEditSave;

  /// No description provided for @profileEditSuccess.
  ///
  /// In it, this message translates to:
  /// **'Profilo aggiornato correttamente'**
  String get profileEditSuccess;

  /// No description provided for @profileEditError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aggiornare il profilo: {error}'**
  String profileEditError(Object error);

  /// No description provided for @logout.
  ///
  /// In it, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @languageSystemLabel.
  ///
  /// In it, this message translates to:
  /// **'Sistema'**
  String get languageSystemLabel;

  /// No description provided for @languageEnglishLabel.
  ///
  /// In it, this message translates to:
  /// **'Inglese'**
  String get languageEnglishLabel;

  /// No description provided for @languageItalianLabel.
  ///
  /// In it, this message translates to:
  /// **'Italiano'**
  String get languageItalianLabel;

  /// No description provided for @languageSpanishLabel.
  ///
  /// In it, this message translates to:
  /// **'Spagnolo'**
  String get languageSpanishLabel;

  /// No description provided for @redirectError.
  ///
  /// In it, this message translates to:
  /// **'Errore durante il reindirizzamento: {error}'**
  String redirectError(Object error);

  /// No description provided for @linkError.
  ///
  /// In it, this message translates to:
  /// **'Errore collegamento: {error}'**
  String linkError(Object error);

  /// No description provided for @missingFieldsError.
  ///
  /// In it, this message translates to:
  /// **'Compila tutti i campi richiesti.'**
  String get missingFieldsError;

  /// No description provided for @passwordMismatch.
  ///
  /// In it, this message translates to:
  /// **'Le password non coincidono.'**
  String get passwordMismatch;

  /// No description provided for @invalidCredentials.
  ///
  /// In it, this message translates to:
  /// **'Credenziali errate.'**
  String get invalidCredentials;

  /// No description provided for @signupEmailCheck.
  ///
  /// In it, this message translates to:
  /// **'Registrazione completata! Controlla la tua email per confermare l\'account.'**
  String get signupEmailCheck;

  /// No description provided for @unexpectedError.
  ///
  /// In it, this message translates to:
  /// **'Errore inatteso: {error}'**
  String unexpectedError(Object error);

  /// No description provided for @loginGreeting.
  ///
  /// In it, this message translates to:
  /// **'Bentornato! Accedi per continuare il tuo allenamento.'**
  String get loginGreeting;

  /// No description provided for @signupGreeting.
  ///
  /// In it, this message translates to:
  /// **'Crea un account per sbloccare tutti gli allenamenti.'**
  String get signupGreeting;

  /// No description provided for @emailLabel.
  ///
  /// In it, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In it, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In it, this message translates to:
  /// **'Conferma password'**
  String get confirmPasswordLabel;

  /// No description provided for @loginButton.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get loginButton;

  /// No description provided for @signupButton.
  ///
  /// In it, this message translates to:
  /// **'Registrati'**
  String get signupButton;

  /// No description provided for @noAccountPrompt.
  ///
  /// In it, this message translates to:
  /// **'Non hai un account? Registrati'**
  String get noAccountPrompt;

  /// No description provided for @existingAccountPrompt.
  ///
  /// In it, this message translates to:
  /// **'Hai già un account? Accedi'**
  String get existingAccountPrompt;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In it, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPasswordLink;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In it, this message translates to:
  /// **'Link per reimpostare la password inviato a {email}. Controlla la posta.'**
  String passwordResetEmailSent(String email);

  /// No description provided for @passwordResetEmailMissing.
  ///
  /// In it, this message translates to:
  /// **'Inserisci la tua email per ricevere il link di reimpostazione.'**
  String get passwordResetEmailMissing;

  /// No description provided for @passwordResetDialogTitle.
  ///
  /// In it, this message translates to:
  /// **'Scegli una nuova password'**
  String get passwordResetDialogTitle;

  /// No description provided for @passwordResetDialogDescription.
  ///
  /// In it, this message translates to:
  /// **'Inserisci una nuova password per mettere al sicuro il tuo account.'**
  String get passwordResetDialogDescription;

  /// No description provided for @passwordResetNewPasswordLabel.
  ///
  /// In it, this message translates to:
  /// **'Nuova password'**
  String get passwordResetNewPasswordLabel;

  /// No description provided for @passwordResetConfirmPasswordLabel.
  ///
  /// In it, this message translates to:
  /// **'Conferma nuova password'**
  String get passwordResetConfirmPasswordLabel;

  /// No description provided for @passwordResetMismatch.
  ///
  /// In it, this message translates to:
  /// **'Le password non coincidono.'**
  String get passwordResetMismatch;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In it, this message translates to:
  /// **'Password aggiornata con successo. Puoi continuare a usare l\'app.'**
  String get passwordResetSuccess;

  /// No description provided for @passwordResetSubmit.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna password'**
  String get passwordResetSubmit;

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get add;

  /// No description provided for @start.
  ///
  /// In it, this message translates to:
  /// **'Avvia'**
  String get start;

  /// No description provided for @timerTitle.
  ///
  /// In it, this message translates to:
  /// **'Timer'**
  String get timerTitle;

  /// No description provided for @timerExercisePushUps.
  ///
  /// In it, this message translates to:
  /// **'Piegamenti'**
  String get timerExercisePushUps;

  /// No description provided for @timerExercisePullUps.
  ///
  /// In it, this message translates to:
  /// **'Trazioni'**
  String get timerExercisePullUps;

  /// No description provided for @timerExerciseSquats.
  ///
  /// In it, this message translates to:
  /// **'Squat'**
  String get timerExerciseSquats;

  /// No description provided for @timerExercisePlank.
  ///
  /// In it, this message translates to:
  /// **'Plank'**
  String get timerExercisePlank;

  /// No description provided for @timerPhaseWork.
  ///
  /// In it, this message translates to:
  /// **'LAVORO'**
  String get timerPhaseWork;

  /// No description provided for @timerPhaseRest.
  ///
  /// In it, this message translates to:
  /// **'RECUPERO'**
  String get timerPhaseRest;

  /// No description provided for @timerWorkDurationLabel.
  ///
  /// In it, this message translates to:
  /// **'Durata lavoro'**
  String get timerWorkDurationLabel;

  /// No description provided for @timerRestDurationLabel.
  ///
  /// In it, this message translates to:
  /// **'Durata recupero'**
  String get timerRestDurationLabel;

  /// No description provided for @timerRoundsLabel.
  ///
  /// In it, this message translates to:
  /// **'Round'**
  String get timerRoundsLabel;

  /// No description provided for @timerExercisesLabel.
  ///
  /// In it, this message translates to:
  /// **'Esercizi'**
  String get timerExercisesLabel;

  /// No description provided for @timerAddExercise.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi esercizio'**
  String get timerAddExercise;

  /// No description provided for @timerExerciseNameLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome esercizio'**
  String get timerExerciseNameLabel;

  /// No description provided for @timerExerciseNameHint.
  ///
  /// In it, this message translates to:
  /// **'Es. Muscle up, Dips, L-sit'**
  String get timerExerciseNameHint;

  /// No description provided for @timerNoExercisesConfigured.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi almeno un esercizio per avviare il timer.'**
  String get timerNoExercisesConfigured;

  /// No description provided for @timerControlSkip.
  ///
  /// In it, this message translates to:
  /// **'SALTA'**
  String get timerControlSkip;

  /// No description provided for @timerControlPause.
  ///
  /// In it, this message translates to:
  /// **'PAUSA'**
  String get timerControlPause;

  /// No description provided for @timerControlPlay.
  ///
  /// In it, this message translates to:
  /// **'AVVIA'**
  String get timerControlPlay;

  /// No description provided for @timerControlReset.
  ///
  /// In it, this message translates to:
  /// **'RESET'**
  String get timerControlReset;

  /// No description provided for @timerAdjustDecrease.
  ///
  /// In it, this message translates to:
  /// **'-10s'**
  String get timerAdjustDecrease;

  /// No description provided for @timerAdjustIncrease.
  ///
  /// In it, this message translates to:
  /// **'+10s'**
  String get timerAdjustIncrease;

  /// No description provided for @timerCountdownGo.
  ///
  /// In it, this message translates to:
  /// **'Via'**
  String get timerCountdownGo;

  /// No description provided for @timerCountdownStop.
  ///
  /// In it, this message translates to:
  /// **'Stop'**
  String get timerCountdownStop;

  /// No description provided for @timerNextPlaceholder.
  ///
  /// In it, this message translates to:
  /// **'Prossimo: --'**
  String get timerNextPlaceholder;

  /// No description provided for @timerNextLabel.
  ///
  /// In it, this message translates to:
  /// **'Prossimo: {name} · Serie {current}/{total}'**
  String timerNextLabel(String name, int current, int total);

  /// No description provided for @weekNumber.
  ///
  /// In it, this message translates to:
  /// **'Settimana {week}'**
  String weekNumber(int week);

  /// No description provided for @defaultWorkoutTitle.
  ///
  /// In it, this message translates to:
  /// **'Allenamento'**
  String get defaultWorkoutTitle;

  /// No description provided for @terminologyTitle.
  ///
  /// In it, this message translates to:
  /// **'Terminologia'**
  String get terminologyTitle;

  /// No description provided for @traineeFeedbackAnsweredTitle.
  ///
  /// In it, this message translates to:
  /// **'Feedback con risposta'**
  String get traineeFeedbackAnsweredTitle;

  /// No description provided for @traineeFeedbackAnsweredEmpty.
  ///
  /// In it, this message translates to:
  /// **'Non hai ancora feedback con risposta.'**
  String get traineeFeedbackAnsweredEmpty;

  /// No description provided for @traineeFeedbackAnsweredChip.
  ///
  /// In it, this message translates to:
  /// **'Risposto'**
  String get traineeFeedbackAnsweredChip;

  /// No description provided for @traineeFeedbackSentAt.
  ///
  /// In it, this message translates to:
  /// **'Inviato:'**
  String get traineeFeedbackSentAt;

  /// No description provided for @traineeFeedbackAnsweredAt.
  ///
  /// In it, this message translates to:
  /// **'Risposto:'**
  String get traineeFeedbackAnsweredAt;

  /// No description provided for @traineeFeedbackTrainerAnswer.
  ///
  /// In it, this message translates to:
  /// **'Risposta del trainer'**
  String get traineeFeedbackTrainerAnswer;

  /// No description provided for @traineeFeedbackLastAnsweredTitle.
  ///
  /// In it, this message translates to:
  /// **'Ultima risposta del trainer'**
  String get traineeFeedbackLastAnsweredTitle;

  /// No description provided for @traineeFeedbackYourMessage.
  ///
  /// In it, this message translates to:
  /// **'Il tuo messaggio'**
  String get traineeFeedbackYourMessage;

  /// No description provided for @traineeFeedbackAnsweredAtHome.
  ///
  /// In it, this message translates to:
  /// **'Risposto il'**
  String get traineeFeedbackAnsweredAtHome;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

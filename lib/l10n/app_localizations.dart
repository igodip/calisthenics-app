import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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

  /// No description provided for @navSettings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get navSettings;

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

  /// No description provided for @settingsComingSoon.
  ///
  /// In it, this message translates to:
  /// **'Le impostazioni saranno presto disponibili.'**
  String get settingsComingSoon;

  /// No description provided for @settingsGeneralSection.
  ///
  /// In it, this message translates to:
  /// **'Generali'**
  String get settingsGeneralSection;

  /// No description provided for @settingsDailyReminder.
  ///
  /// In it, this message translates to:
  /// **'Promemoria allenamento quotidiano'**
  String get settingsDailyReminder;

  /// No description provided for @settingsDailyReminderDescription.
  ///
  /// In it, this message translates to:
  /// **'Ricevi un promemoria per iniziare ad allenarti ogni giorno.'**
  String get settingsDailyReminderDescription;

  /// No description provided for @settingsReminderTime.
  ///
  /// In it, this message translates to:
  /// **'Orario promemoria'**
  String get settingsReminderTime;

  /// No description provided for @settingsReminderNotSet.
  ///
  /// In it, this message translates to:
  /// **'Non impostato'**
  String get settingsReminderNotSet;

  /// No description provided for @settingsSoundEffects.
  ///
  /// In it, this message translates to:
  /// **'Effetti sonori'**
  String get settingsSoundEffects;

  /// No description provided for @settingsSoundEffectsDescription.
  ///
  /// In it, this message translates to:
  /// **'Riproduci brevi suoni durante la registrazione delle ripetizioni.'**
  String get settingsSoundEffectsDescription;

  /// No description provided for @settingsHapticFeedback.
  ///
  /// In it, this message translates to:
  /// **'Feedback aptico'**
  String get settingsHapticFeedback;

  /// No description provided for @settingsHapticFeedbackDescription.
  ///
  /// In it, this message translates to:
  /// **'Leggera vibrazione per le azioni importanti.'**
  String get settingsHapticFeedbackDescription;

  /// No description provided for @settingsTrainingSection.
  ///
  /// In it, this message translates to:
  /// **'Preferenze di allenamento'**
  String get settingsTrainingSection;

  /// No description provided for @settingsUnitSystem.
  ///
  /// In it, this message translates to:
  /// **'Sistema di unità'**
  String get settingsUnitSystem;

  /// No description provided for @settingsUnitsMetric.
  ///
  /// In it, this message translates to:
  /// **'Metrico (kg)'**
  String get settingsUnitsMetric;

  /// No description provided for @settingsUnitsImperial.
  ///
  /// In it, this message translates to:
  /// **'Imperiale (lb)'**
  String get settingsUnitsImperial;

  /// No description provided for @settingsRestTimer.
  ///
  /// In it, this message translates to:
  /// **'Timer di recupero predefinito'**
  String get settingsRestTimer;

  /// No description provided for @settingsRestTimerDescription.
  ///
  /// In it, this message translates to:
  /// **'Usato quando avvii un timer di recupero dagli allenamenti.'**
  String get settingsRestTimerDescription;

  /// No description provided for @settingsRestTimerMinutes.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, one {# minuto} other {# minuti}}'**
  String settingsRestTimerMinutes(int count);

  /// No description provided for @settingsRestTimerMinutesSeconds.
  ///
  /// In it, this message translates to:
  /// **'{minutes, plural, one {# minuto} other {# minuti}} e {seconds, plural, one {# secondo} other {# secondi}}'**
  String settingsRestTimerMinutesSeconds(int minutes, int seconds);

  /// No description provided for @settingsRestTimerSeconds.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, one {# secondo} other {# secondi}}'**
  String settingsRestTimerSeconds(int count);

  /// No description provided for @settingsDataSection.
  ///
  /// In it, this message translates to:
  /// **'Dati e privacy'**
  String get settingsDataSection;

  /// No description provided for @settingsClearCache.
  ///
  /// In it, this message translates to:
  /// **'Cancella allenamenti salvati'**
  String get settingsClearCache;

  /// No description provided for @settingsClearCacheDescription.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi gli allenamenti memorizzati su questo dispositivo.'**
  String get settingsClearCacheDescription;

  /// No description provided for @settingsClearCacheSuccess.
  ///
  /// In it, this message translates to:
  /// **'Allenamenti locali rimossi.'**
  String get settingsClearCacheSuccess;

  /// No description provided for @settingsExportData.
  ///
  /// In it, this message translates to:
  /// **'Esporta riepilogo allenamenti'**
  String get settingsExportData;

  /// No description provided for @settingsExportDataDescription.
  ///
  /// In it, this message translates to:
  /// **'Ricevi via email un CSV delle ultime sessioni.'**
  String get settingsExportDataDescription;

  /// No description provided for @settingsExportDataSuccess.
  ///
  /// In it, this message translates to:
  /// **'Richiesta di esportazione inviata. Controlla la casella di posta a breve.'**
  String get settingsExportDataSuccess;

  /// No description provided for @settingsSupportSection.
  ///
  /// In it, this message translates to:
  /// **'Supporto'**
  String get settingsSupportSection;

  /// No description provided for @settingsContactCoach.
  ///
  /// In it, this message translates to:
  /// **'Contatta il tuo coach'**
  String get settingsContactCoach;

  /// No description provided for @settingsContactCoachDescription.
  ///
  /// In it, this message translates to:
  /// **'Invia un messaggio rapido per chiedere modifiche.'**
  String get settingsContactCoachDescription;

  /// No description provided for @settingsContactCoachHint.
  ///
  /// In it, this message translates to:
  /// **'Dicci come possiamo aiutarti.'**
  String get settingsContactCoachHint;

  /// No description provided for @settingsContactCoachSuccess.
  ///
  /// In it, this message translates to:
  /// **'Messaggio inviato al coach.'**
  String get settingsContactCoachSuccess;

  /// No description provided for @settingsSendMessage.
  ///
  /// In it, this message translates to:
  /// **'Invia messaggio'**
  String get settingsSendMessage;

  /// No description provided for @settingsAppVersion.
  ///
  /// In it, this message translates to:
  /// **'Versione app'**
  String get settingsAppVersion;

  /// No description provided for @settingsAppVersionValue.
  ///
  /// In it, this message translates to:
  /// **'Versione {version}'**
  String settingsAppVersionValue(Object version);

  /// No description provided for @exerciseTrackerTitle.
  ///
  /// In it, this message translates to:
  /// **'Tracker esercizi'**
  String get exerciseTrackerTitle;

  /// No description provided for @poseEstimationTitle.
  ///
  /// In it, this message translates to:
  /// **'Stima postura'**
  String get poseEstimationTitle;

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

  /// No description provided for @homePlansSectionTitle.
  ///
  /// In it, this message translates to:
  /// **'Piani di allenamento'**
  String get homePlansSectionTitle;

  /// No description provided for @homePlansSectionSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Piani assegnati e il loro stato attuale.'**
  String get homePlansSectionSubtitle;

  /// No description provided for @homePlansEmptyTitle.
  ///
  /// In it, this message translates to:
  /// **'Nessun piano di allenamento'**
  String get homePlansEmptyTitle;

  /// No description provided for @homePlansEmptyDescription.
  ///
  /// In it, this message translates to:
  /// **'Chiedi al tuo coach di assegnarti un piano per vederlo qui.'**
  String get homePlansEmptyDescription;

  /// No description provided for @homePlanStatusDraft.
  ///
  /// In it, this message translates to:
  /// **'Bozza'**
  String get homePlanStatusDraft;

  /// No description provided for @homePlanStatusArchived.
  ///
  /// In it, this message translates to:
  /// **'Archiviato'**
  String get homePlanStatusArchived;

  /// No description provided for @homePlanStatusUpcoming.
  ///
  /// In it, this message translates to:
  /// **'In arrivo'**
  String get homePlanStatusUpcoming;

  /// No description provided for @homePlanStatusUnknown.
  ///
  /// In it, this message translates to:
  /// **'Stato sconosciuto'**
  String get homePlanStatusUnknown;

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

  /// No description provided for @generalNotes.
  ///
  /// In it, this message translates to:
  /// **'Note generali'**
  String get generalNotes;

  /// No description provided for @trainingHeaderExercise.
  ///
  /// In it, this message translates to:
  /// **'Esercizio'**
  String get trainingHeaderExercise;

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

  /// No description provided for @trainingHeaderRest.
  ///
  /// In it, this message translates to:
  /// **'Recupero'**
  String get trainingHeaderRest;

  /// No description provided for @trainingHeaderIntensity.
  ///
  /// In it, this message translates to:
  /// **'Intensità'**
  String get trainingHeaderIntensity;

  /// No description provided for @trainingHeaderNotes.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get trainingHeaderNotes;

  /// No description provided for @trainingNotesLabel.
  ///
  /// In it, this message translates to:
  /// **'Note dell\'esercizio'**
  String get trainingNotesLabel;

  /// No description provided for @trainingNotesSave.
  ///
  /// In it, this message translates to:
  /// **'Salva note'**
  String get trainingNotesSave;

  /// No description provided for @trainingNotesSaved.
  ///
  /// In it, this message translates to:
  /// **'Note salvate'**
  String get trainingNotesSaved;

  /// No description provided for @trainingNotesError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile salvare le note: {error}'**
  String trainingNotesError(Object error);

  /// No description provided for @trainingNotesUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aggiornare le note per questo esercizio.'**
  String get trainingNotesUnavailable;

  /// No description provided for @trainingOpenTracker.
  ///
  /// In it, this message translates to:
  /// **'Apri tracker'**
  String get trainingOpenTracker;

  /// No description provided for @trainingMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark day as complete'**
  String get trainingMarkComplete;

  /// No description provided for @trainingMarkIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Mark day as incomplete'**
  String get trainingMarkIncomplete;

  /// No description provided for @trainingCompletionSaved.
  ///
  /// In en, this message translates to:
  /// **'Workout day updated'**
  String get trainingCompletionSaved;

  /// No description provided for @trainingCompletionError.
  ///
  /// In en, this message translates to:
  /// **'Unable to update workout: {error}'**
  String trainingCompletionError(Object error);

  /// No description provided for @trainingCompletionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Cannot update this workout day.'**
  String get trainingCompletionUnavailable;

  /// No description provided for @trainingExerciseCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise completed'**
  String get trainingExerciseCompletedLabel;

  /// No description provided for @trainingExerciseCompletionSaved.
  ///
  /// In en, this message translates to:
  /// **'Exercise updated'**
  String get trainingExerciseCompletionSaved;

  /// No description provided for @trainingExerciseCompletionError.
  ///
  /// In en, this message translates to:
  /// **'Unable to update exercise: {error}'**
  String trainingExerciseCompletionError(Object error);

  /// No description provided for @trainingExerciseCompletionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Cannot update this exercise.'**
  String get trainingExerciseCompletionUnavailable;

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

  /// No description provided for @profileLastUpdated.
  ///
  /// In it, this message translates to:
  /// **'Ultimo aggiornamento'**
  String get profileLastUpdated;

  /// No description provided for @profileValueUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Non disponibile'**
  String get profileValueUnavailable;

  /// No description provided for @profileTimezone.
  ///
  /// In it, this message translates to:
  /// **'Fuso orario'**
  String get profileTimezone;

  /// No description provided for @profileNotSet.
  ///
  /// In it, this message translates to:
  /// **'Non impostato'**
  String get profileNotSet;

  /// No description provided for @profileUnitSystem.
  ///
  /// In it, this message translates to:
  /// **'Unità di misura'**
  String get profileUnitSystem;

  /// No description provided for @profileEdit.
  ///
  /// In it, this message translates to:
  /// **'Modifica profilo'**
  String get profileEdit;

  /// No description provided for @profileComingSoon.
  ///
  /// In it, this message translates to:
  /// **'Presto disponibile'**
  String get profileComingSoon;

  /// No description provided for @profileEditSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna le tue informazioni personali'**
  String get profileEditSubtitle;

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

  /// No description provided for @profileEditTimezoneLabel.
  ///
  /// In it, this message translates to:
  /// **'Fuso orario'**
  String get profileEditTimezoneLabel;

  /// No description provided for @profileEditTimezoneHint.
  ///
  /// In it, this message translates to:
  /// **'Esempio: Europe/Rome'**
  String get profileEditTimezoneHint;

  /// No description provided for @profileEditUnitSystemLabel.
  ///
  /// In it, this message translates to:
  /// **'Unità di misura preferita'**
  String get profileEditUnitSystemLabel;

  /// No description provided for @profileEditUnitSystemNotSet.
  ///
  /// In it, this message translates to:
  /// **'Non specificato'**
  String get profileEditUnitSystemNotSet;

  /// No description provided for @profileEditUnitSystemMetric.
  ///
  /// In it, this message translates to:
  /// **'Metrico (kg, cm)'**
  String get profileEditUnitSystemMetric;

  /// No description provided for @profileEditUnitSystemImperial.
  ///
  /// In it, this message translates to:
  /// **'Imperiale (lb, in)'**
  String get profileEditUnitSystemImperial;

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

  /// No description provided for @featureUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Funzionalità non ancora disponibile.'**
  String get featureUnavailable;

  /// No description provided for @logout.
  ///
  /// In it, this message translates to:
  /// **'Logout'**
  String get logout;

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

  /// No description provided for @exerciseAddDialogTitle.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi esercizio'**
  String get exerciseAddDialogTitle;

  /// No description provided for @exerciseNameLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome esercizio'**
  String get exerciseNameLabel;

  /// No description provided for @quickAddValuesLabel.
  ///
  /// In it, this message translates to:
  /// **'Valori rapidi'**
  String get quickAddValuesLabel;

  /// No description provided for @quickAddValuesHelper.
  ///
  /// In it, this message translates to:
  /// **'Ripetizioni separate da virgola (es. 1,5,10)'**
  String get quickAddValuesHelper;

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

  /// No description provided for @save.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get save;

  /// No description provided for @exerciseNameMissing.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un nome.'**
  String get exerciseNameMissing;

  /// No description provided for @exerciseTargetRepsLabel.
  ///
  /// In it, this message translates to:
  /// **'Ripetizioni obiettivo'**
  String get exerciseTargetRepsLabel;

  /// No description provided for @exerciseTargetRepsHelper.
  ///
  /// In it, this message translates to:
  /// **'Obiettivo totale opzionale per la sessione'**
  String get exerciseTargetRepsHelper;

  /// No description provided for @exerciseRestDurationLabel.
  ///
  /// In it, this message translates to:
  /// **'Durata recupero (secondi)'**
  String get exerciseRestDurationLabel;

  /// No description provided for @exerciseRestDurationHelper.
  ///
  /// In it, this message translates to:
  /// **'Preset opzionale per il conto alla rovescia'**
  String get exerciseRestDurationHelper;

  /// No description provided for @exerciseTrackerEmpty.
  ///
  /// In it, this message translates to:
  /// **'Ancora nessun esercizio. Tocca + per aggiungerne uno!'**
  String get exerciseTrackerEmpty;

  /// No description provided for @exerciseAddButton.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi esercizio'**
  String get exerciseAddButton;

  /// No description provided for @exercisePushUps.
  ///
  /// In it, this message translates to:
  /// **'Push-up'**
  String get exercisePushUps;

  /// No description provided for @exercisePullUps.
  ///
  /// In it, this message translates to:
  /// **'Trazioni alla sbarra'**
  String get exercisePullUps;

  /// No description provided for @exerciseChinUps.
  ///
  /// In it, this message translates to:
  /// **'Trazioni a presa inversa'**
  String get exerciseChinUps;

  /// No description provided for @exerciseTotalReps.
  ///
  /// In it, this message translates to:
  /// **'{count} ripetizioni totali'**
  String exerciseTotalReps(int count);

  /// No description provided for @exerciseGoalProgress.
  ///
  /// In it, this message translates to:
  /// **'{logged} / {goal} ripetizioni registrate'**
  String exerciseGoalProgress(int logged, int goal);

  /// No description provided for @exerciseRestFinished.
  ///
  /// In it, this message translates to:
  /// **'Recupero terminato per {exercise}!'**
  String exerciseRestFinished(String exercise);

  /// No description provided for @exerciseSetRestDuration.
  ///
  /// In it, this message translates to:
  /// **'Imposta durata recupero'**
  String get exerciseSetRestDuration;

  /// No description provided for @exerciseDurationSecondsLabel.
  ///
  /// In it, this message translates to:
  /// **'Durata (secondi)'**
  String get exerciseDurationSecondsLabel;

  /// No description provided for @restTimerLabel.
  ///
  /// In it, this message translates to:
  /// **'Timer di recupero'**
  String get restTimerLabel;

  /// No description provided for @setDuration.
  ///
  /// In it, this message translates to:
  /// **'Imposta durata'**
  String get setDuration;

  /// No description provided for @undoLastSet.
  ///
  /// In it, this message translates to:
  /// **'Annulla ultima serie'**
  String get undoLastSet;

  /// No description provided for @custom.
  ///
  /// In it, this message translates to:
  /// **'Personalizzato'**
  String get custom;

  /// No description provided for @reset.
  ///
  /// In it, this message translates to:
  /// **'Reimposta'**
  String get reset;

  /// No description provided for @logRepsTitle.
  ///
  /// In it, this message translates to:
  /// **'Registra ripetizioni'**
  String get logRepsTitle;

  /// No description provided for @repetitionsLabel.
  ///
  /// In it, this message translates to:
  /// **'Ripetizioni'**
  String get repetitionsLabel;

  /// No description provided for @positiveNumberError.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un numero positivo.'**
  String get positiveNumberError;

  /// No description provided for @repsChip.
  ///
  /// In it, this message translates to:
  /// **'{count} ripetizioni'**
  String repsChip(int count);

  /// No description provided for @goalCount.
  ///
  /// In it, this message translates to:
  /// **'Obiettivo: {count}'**
  String goalCount(int count);

  /// No description provided for @repGoalReached.
  ///
  /// In it, this message translates to:
  /// **'Obiettivo ripetizioni raggiunto!'**
  String get repGoalReached;

  /// No description provided for @pause.
  ///
  /// In it, this message translates to:
  /// **'Pausa'**
  String get pause;

  /// No description provided for @start.
  ///
  /// In it, this message translates to:
  /// **'Avvia'**
  String get start;

  /// No description provided for @seriesCount.
  ///
  /// In it, this message translates to:
  /// **'Serie: {count}'**
  String seriesCount(int count);

  /// No description provided for @resetReps.
  ///
  /// In it, this message translates to:
  /// **'Azzera ripetizioni'**
  String get resetReps;

  /// No description provided for @emomTrackerTitle.
  ///
  /// In it, this message translates to:
  /// **'Tracker EMOM'**
  String get emomTrackerTitle;

  /// No description provided for @emomTrackerSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Serie ogni minuto con conto alla rovescia.'**
  String get emomTrackerSubtitle;

  /// No description provided for @emomTrackerDescription.
  ///
  /// In it, this message translates to:
  /// **'Configura serie, ripetizioni e intervalli per restare sul ritmo ogni minuto.'**
  String get emomTrackerDescription;

  /// No description provided for @emomSetsLabel.
  ///
  /// In it, this message translates to:
  /// **'Serie totali'**
  String get emomSetsLabel;

  /// No description provided for @emomRepsLabel.
  ///
  /// In it, this message translates to:
  /// **'Ripetizioni per serie'**
  String get emomRepsLabel;

  /// No description provided for @emomIntervalLabel.
  ///
  /// In it, this message translates to:
  /// **'Intervallo (secondi)'**
  String get emomIntervalLabel;

  /// No description provided for @emomStartButton.
  ///
  /// In it, this message translates to:
  /// **'Avvia EMOM'**
  String get emomStartButton;

  /// No description provided for @emomResetButton.
  ///
  /// In it, this message translates to:
  /// **'Reimposta sessione'**
  String get emomResetButton;

  /// No description provided for @emomSessionComplete.
  ///
  /// In it, this message translates to:
  /// **'EMOM completato'**
  String get emomSessionComplete;

  /// No description provided for @emomCurrentSet.
  ///
  /// In it, this message translates to:
  /// **'Serie {current} di {total}'**
  String emomCurrentSet(int current, int total);

  /// No description provided for @emomRepsPerSet.
  ///
  /// In it, this message translates to:
  /// **'{count} ripetizioni per serie'**
  String emomRepsPerSet(int count);

  /// No description provided for @emomFinishedMessage.
  ///
  /// In it, this message translates to:
  /// **'Ottimo lavoro! Hai rispettato ogni minuto.'**
  String get emomFinishedMessage;

  /// No description provided for @emomTimeRemainingLabel.
  ///
  /// In it, this message translates to:
  /// **'Tempo rimanente in questo minuto'**
  String get emomTimeRemainingLabel;

  /// No description provided for @emomPrepHeadline.
  ///
  /// In it, this message translates to:
  /// **'Preparati per la serie {set}'**
  String emomPrepHeadline(int set);

  /// No description provided for @emomPrepSubhead.
  ///
  /// In it, this message translates to:
  /// **'La prossima serie parte alla fine del conto alla rovescia.'**
  String get emomPrepSubhead;

  /// No description provided for @timerTitle.
  ///
  /// In it, this message translates to:
  /// **'Timer'**
  String get timerTitle;

  /// No description provided for @weekdayMonday.
  ///
  /// In it, this message translates to:
  /// **'Lunedì'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In it, this message translates to:
  /// **'Martedì'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In it, this message translates to:
  /// **'Mercoledì'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In it, this message translates to:
  /// **'Giovedì'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In it, this message translates to:
  /// **'Venerdì'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In it, this message translates to:
  /// **'Sabato'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In it, this message translates to:
  /// **'Domenica'**
  String get weekdaySunday;

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

  /// No description provided for @termRepsTitle.
  ///
  /// In it, this message translates to:
  /// **'Reps (Ripetizioni)'**
  String get termRepsTitle;

  /// No description provided for @termRepsDescription.
  ///
  /// In it, this message translates to:
  /// **'Numero di volte che esegui un esercizio consecutivamente.'**
  String get termRepsDescription;

  /// No description provided for @termSetTitle.
  ///
  /// In it, this message translates to:
  /// **'Set (Serie)'**
  String get termSetTitle;

  /// No description provided for @termSetDescription.
  ///
  /// In it, this message translates to:
  /// **'Un gruppo di ripetizioni. Es: 3 serie da 10 reps significa 30 ripetizioni totali, divise in 3 gruppi.'**
  String get termSetDescription;

  /// No description provided for @termRtTitle.
  ///
  /// In it, this message translates to:
  /// **'RT'**
  String get termRtTitle;

  /// No description provided for @termRtDescription.
  ///
  /// In it, this message translates to:
  /// **'Ripetizioni Totali: indica che devi fare tutte quelle reps, con libera scelta di serie, ripetizioni e tempo (se non indicato).'**
  String get termRtDescription;

  /// No description provided for @termAmrapTitle.
  ///
  /// In it, this message translates to:
  /// **'AMRAP'**
  String get termAmrapTitle;

  /// No description provided for @termAmrapDescription.
  ///
  /// In it, this message translates to:
  /// **'As Many Reps As Possible: esegui quante più ripetizioni possibili in un tempo determinato.'**
  String get termAmrapDescription;

  /// No description provided for @termEmomTitle.
  ///
  /// In it, this message translates to:
  /// **'EMOM'**
  String get termEmomTitle;

  /// No description provided for @termEmomDescription.
  ///
  /// In it, this message translates to:
  /// **'Every Minute On Minute: inizi un set ogni minuto. Il tempo restante serve per riposare.'**
  String get termEmomDescription;

  /// No description provided for @termRampingTitle.
  ///
  /// In it, this message translates to:
  /// **'Ramping'**
  String get termRampingTitle;

  /// No description provided for @termRampingDescription.
  ///
  /// In it, this message translates to:
  /// **'Metodo che prevede un incremento del peso ad ogni serie'**
  String get termRampingDescription;

  /// No description provided for @termMavTitle.
  ///
  /// In it, this message translates to:
  /// **'MAV'**
  String get termMavTitle;

  /// No description provided for @termMavDescription.
  ///
  /// In it, this message translates to:
  /// **'Massima Alzata Veloce: si riferisce a una metodologia in cui si cerca di eseguire il maggior numero di ripetizioni possibili con un carico, mantenendo sempre il controllo del movimento e una buona velocità di esecuzione.'**
  String get termMavDescription;

  /// No description provided for @termIsocineticiTitle.
  ///
  /// In it, this message translates to:
  /// **'Isocinetici'**
  String get termIsocineticiTitle;

  /// No description provided for @termIsocineticiDescription.
  ///
  /// In it, this message translates to:
  /// **'Esercizi svolti a velocità costante.'**
  String get termIsocineticiDescription;

  /// No description provided for @termTutTitle.
  ///
  /// In it, this message translates to:
  /// **'TUT'**
  String get termTutTitle;

  /// No description provided for @termTutDescription.
  ///
  /// In it, this message translates to:
  /// **'Indica quanto deve durare una ripetizione. Puoi gestire tu la durata di ogni fase della rep.'**
  String get termTutDescription;

  /// No description provided for @termIsoTitle.
  ///
  /// In it, this message translates to:
  /// **'ISO'**
  String get termIsoTitle;

  /// No description provided for @termIsoDescription.
  ///
  /// In it, this message translates to:
  /// **'Indica il fermo a un punto specifico dell\'esecuzione della rep'**
  String get termIsoDescription;

  /// No description provided for @termSomTitle.
  ///
  /// In it, this message translates to:
  /// **'SOM'**
  String get termSomTitle;

  /// No description provided for @termSomDescription.
  ///
  /// In it, this message translates to:
  /// **'Indica la durata di ogni fase della ripetizione.'**
  String get termSomDescription;

  /// No description provided for @termScaricoTitle.
  ///
  /// In it, this message translates to:
  /// **'Scarico'**
  String get termScaricoTitle;

  /// No description provided for @termScaricoDescription.
  ///
  /// In it, this message translates to:
  /// **'Ultima settimana della scheda per prepararsi ai massimali.'**
  String get termScaricoDescription;

  /// No description provided for @noCameras.
  ///
  /// In it, this message translates to:
  /// **'Nessuna fotocamera disponibile'**
  String get noCameras;

  /// No description provided for @cameraInitFailed.
  ///
  /// In it, this message translates to:
  /// **'Inizializzazione fotocamera fallita: {error}'**
  String cameraInitFailed(Object error);

  /// No description provided for @poseDetected.
  ///
  /// In it, this message translates to:
  /// **'Posa rilevata'**
  String get poseDetected;

  /// No description provided for @processing.
  ///
  /// In it, this message translates to:
  /// **'Elaborazione…'**
  String get processing;

  /// No description provided for @idle.
  ///
  /// In it, this message translates to:
  /// **'In attesa'**
  String get idle;

  /// No description provided for @cameraFront.
  ///
  /// In it, this message translates to:
  /// **'frontale'**
  String get cameraFront;

  /// No description provided for @cameraBack.
  ///
  /// In it, this message translates to:
  /// **'posteriore'**
  String get cameraBack;

  /// No description provided for @hudMetrics.
  ///
  /// In it, this message translates to:
  /// **'fps: {fps}  ms: {milliseconds}  lmks: {landmarks}'**
  String hudMetrics(String fps, String milliseconds, int landmarks);

  /// No description provided for @hudOrientation.
  ///
  /// In it, this message translates to:
  /// **'rot: {rotation}  cam: {camera}  fmt: {format}'**
  String hudOrientation(String rotation, String camera, String format);
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
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
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

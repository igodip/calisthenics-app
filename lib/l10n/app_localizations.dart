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

  /// No description provided for @userIdTitle.
  ///
  /// In it, this message translates to:
  /// **'ID utente'**
  String get userIdTitle;

  /// No description provided for @userIdUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Non disponibile'**
  String get userIdUnavailable;

  /// No description provided for @featureInDevelopment.
  ///
  /// In it, this message translates to:
  /// **'Funzionalità in sviluppo.'**
  String get featureInDevelopment;

  /// No description provided for @maxTestsResultsTitle.
  ///
  /// In it, this message translates to:
  /// **'Risultati e storico'**
  String get maxTestsResultsTitle;

  /// No description provided for @maxTestsFilteredHistory.
  ///
  /// In it, this message translates to:
  /// **'Storico nel periodo selezionato'**
  String get maxTestsFilteredHistory;

  /// No description provided for @maxCategoryAll.
  ///
  /// In it, this message translates to:
  /// **'Tutti'**
  String get maxCategoryAll;

  /// No description provided for @maxCategoryPull.
  ///
  /// In it, this message translates to:
  /// **'Tirata'**
  String get maxCategoryPull;

  /// No description provided for @maxCategoryPush.
  ///
  /// In it, this message translates to:
  /// **'Spinta'**
  String get maxCategoryPush;

  /// No description provided for @maxCategoryLegs.
  ///
  /// In it, this message translates to:
  /// **'Gambe'**
  String get maxCategoryLegs;

  /// No description provided for @maxCategoryCore.
  ///
  /// In it, this message translates to:
  /// **'Core'**
  String get maxCategoryCore;

  /// No description provided for @maxCategorySkills.
  ///
  /// In it, this message translates to:
  /// **'Skill'**
  String get maxCategorySkills;

  /// No description provided for @maxCategoryOther.
  ///
  /// In it, this message translates to:
  /// **'Altri'**
  String get maxCategoryOther;

  /// No description provided for @maxUnitReps.
  ///
  /// In it, this message translates to:
  /// **'rip.'**
  String get maxUnitReps;

  /// No description provided for @maxUnitSeconds.
  ///
  /// In it, this message translates to:
  /// **'s'**
  String get maxUnitSeconds;

  /// No description provided for @maxUnitMinutes.
  ///
  /// In it, this message translates to:
  /// **'min'**
  String get maxUnitMinutes;

  /// No description provided for @maxTestsTraineeIntro.
  ///
  /// In it, this message translates to:
  /// **'Consulta i risultati registrati dal trainer, confronta i progressi e apri lo storico completo di ogni esercizio.'**
  String get maxTestsTraineeIntro;

  /// No description provided for @maxTestsTrainerIntro.
  ///
  /// In it, this message translates to:
  /// **'Controlla i progressi per esercizio, aggiungi risultati e gestisci le note private del trainer.'**
  String get maxTestsTrainerIntro;

  /// No description provided for @maxTestsSearch.
  ///
  /// In it, this message translates to:
  /// **'Cerca esercizio'**
  String get maxTestsSearch;

  /// No description provided for @maxTestsLatest.
  ///
  /// In it, this message translates to:
  /// **'Ultimo risultato'**
  String get maxTestsLatest;

  /// No description provided for @maxTestsChange.
  ///
  /// In it, this message translates to:
  /// **'Variazione'**
  String get maxTestsChange;

  /// No description provided for @maxTestsHistory.
  ///
  /// In it, this message translates to:
  /// **'Storico completo'**
  String get maxTestsHistory;

  /// No description provided for @maxTestsNoResults.
  ///
  /// In it, this message translates to:
  /// **'Non ci sono ancora risultati. Il tuo trainer può aggiungere i primi test.'**
  String get maxTestsNoResults;

  /// No description provided for @maxTestsNoMatches.
  ///
  /// In it, this message translates to:
  /// **'Nessun risultato con questi filtri. Cambia categoria, ricerca o periodo.'**
  String get maxTestsNoMatches;

  /// No description provided for @maxTestsLoadError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile caricare i massimali. Controlla la connessione e riprova.'**
  String get maxTestsLoadError;

  /// No description provided for @homeMascotAuraSwitch.
  ///
  /// In it, this message translates to:
  /// **'Tocca per cambiare aura. La scelta viene salvata su questo dispositivo.'**
  String get homeMascotAuraSwitch;

  /// No description provided for @homeMascotAuraDragonBall.
  ///
  /// In it, this message translates to:
  /// **'Aura Dragon Ball'**
  String get homeMascotAuraDragonBall;

  /// No description provided for @homeMascotAuraNaruto.
  ///
  /// In it, this message translates to:
  /// **'Aura Naruto'**
  String get homeMascotAuraNaruto;

  /// No description provided for @trainerFinalWeekLabel.
  ///
  /// In it, this message translates to:
  /// **'Ultima settimana'**
  String get trainerFinalWeekLabel;

  /// No description provided for @trainerFinalWeekTitle.
  ///
  /// In it, this message translates to:
  /// **'Allievi all’ultima settimana'**
  String get trainerFinalWeekTitle;

  /// No description provided for @homeMascotTitle.
  ///
  /// In it, this message translates to:
  /// **'Piccolo atleta nella Home'**
  String get homeMascotTitle;

  /// No description provided for @homeMascotDescription.
  ///
  /// In it, this message translates to:
  /// **'Mostra un personaggio che si allena continuamente nella Home. Disattivato per impostazione predefinita. Salvato su questo dispositivo; rispetta il movimento ridotto.'**
  String get homeMascotDescription;

  /// No description provided for @exerciseGalleryOpen.
  ///
  /// In it, this message translates to:
  /// **'Visualizza immagini di {exercise}'**
  String exerciseGalleryOpen(String exercise);

  /// No description provided for @exerciseGalleryView.
  ///
  /// In it, this message translates to:
  /// **'Visualizza immagine'**
  String get exerciseGalleryView;

  /// No description provided for @exerciseGalleryReference.
  ///
  /// In it, this message translates to:
  /// **'Illustrazione di riferimento. Segui le indicazioni del tuo trainer.'**
  String get exerciseGalleryReference;

  /// No description provided for @exerciseGalleryUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Immagine non disponibile'**
  String get exerciseGalleryUnavailable;

  /// No description provided for @exerciseGalleryZoomHint.
  ///
  /// In it, this message translates to:
  /// **'Pizzica per ingrandire'**
  String get exerciseGalleryZoomHint;

  /// No description provided for @exerciseGalleryPosition.
  ///
  /// In it, this message translates to:
  /// **'{current} di {total}'**
  String exerciseGalleryPosition(int current, int total);

  /// No description provided for @trainerPaymentAmountInvalid.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un importo valido maggiore o uguale a zero.'**
  String get trainerPaymentAmountInvalid;

  /// No description provided for @copy.
  ///
  /// In it, this message translates to:
  /// **'Copia'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In it, this message translates to:
  /// **'Copiato'**
  String get copied;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In it, this message translates to:
  /// **'Informativa sulla privacy'**
  String get privacyPolicyTitle;

  /// No description provided for @registrationPrivacyNotice.
  ///
  /// In it, this message translates to:
  /// **'Prima di creare un account, leggi come Calisync usa i tuoi dati, inclusi l’accesso di trainer e amministratori e le anteprime delle notifiche.'**
  String get registrationPrivacyNotice;

  /// No description provided for @privacySettingsDescription.
  ///
  /// In it, this message translates to:
  /// **'Scopri come vengono trattati account, allenamenti, foto e notifiche e come richiedere l’eliminazione.'**
  String get privacySettingsDescription;

  /// No description provided for @privacyPolicyOpenError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aprire l’informativa. Apri questo indirizzo nel browser:'**
  String get privacyPolicyOpenError;

  /// No description provided for @waitingForTrainerTitle.
  ///
  /// In it, this message translates to:
  /// **'In attesa del tuo trainer'**
  String get waitingForTrainerTitle;

  /// No description provided for @waitingForTrainerDescription.
  ///
  /// In it, this message translates to:
  /// **'Il tuo accesso agli allenamenti non è ancora attivo. Contatta il trainer per concordare o confermare il pagamento. Puoi comunque gestire profilo e account, leggere i feedback e consultare le guide agli esercizi.'**
  String get waitingForTrainerDescription;

  /// No description provided for @trainingAccessChecking.
  ///
  /// In it, this message translates to:
  /// **'Verifica accesso agli allenamenti…'**
  String get trainingAccessChecking;

  /// No description provided for @trainingAccessErrorTitle.
  ///
  /// In it, this message translates to:
  /// **'Impossibile verificare l’accesso'**
  String get trainingAccessErrorTitle;

  /// No description provided for @trainingAccessErrorDescription.
  ///
  /// In it, this message translates to:
  /// **'Controlla la connessione e riprova. Profilo, impostazioni e uscita dall’account restano disponibili.'**
  String get trainingAccessErrorDescription;

  /// No description provided for @trainingAccessRefresh.
  ///
  /// In it, this message translates to:
  /// **'Verifica di nuovo'**
  String get trainingAccessRefresh;

  /// No description provided for @accountSettingsTitle.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get accountSettingsTitle;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In it, this message translates to:
  /// **'Elimina account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In it, this message translates to:
  /// **'Eliminare definitivamente account, foto profilo, piani allievo, feedback, progressi e pagamenti? Questa operazione è irreversibile. Gli account e lo storico degli altri utenti vengono conservati.'**
  String get deleteAccountConfirmation;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi definitivamente il tuo account e i dati associati.'**
  String get deleteAccountDescription;

  /// No description provided for @deleteAccountProgress.
  ///
  /// In it, this message translates to:
  /// **'Eliminazione account…'**
  String get deleteAccountProgress;

  /// No description provided for @deleteAccountError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile completare l’eliminazione. Riprova o contatta dipaoloigor@gmail.com.'**
  String get deleteAccountError;

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

  /// No description provided for @themePurpleLabel.
  ///
  /// In it, this message translates to:
  /// **'Viola'**
  String get themePurpleLabel;

  /// No description provided for @themeOrangeLabel.
  ///
  /// In it, this message translates to:
  /// **'Arancione'**
  String get themeOrangeLabel;

  /// No description provided for @onboardingTitleOne.
  ///
  /// In it, this message translates to:
  /// **'Costruisci forza.\nControlla il movimento.'**
  String get onboardingTitleOne;

  /// No description provided for @onboardingDescriptionOne.
  ///
  /// In it, this message translates to:
  /// **'Il tuo allenamento calistenico, tutto in un posto.'**
  String get onboardingDescriptionOne;

  /// No description provided for @onboardingTitleTwo.
  ///
  /// In it, this message translates to:
  /// **'Guarda i tuoi\nprogressi.'**
  String get onboardingTitleTwo;

  /// No description provided for @onboardingDescriptionTwo.
  ///
  /// In it, this message translates to:
  /// **'Registra ripetizioni, tenute e ogni passo avanti.'**
  String get onboardingDescriptionTwo;

  /// No description provided for @onboardingTitleThree.
  ///
  /// In it, this message translates to:
  /// **'Fai del movimento\nun’abitudine.'**
  String get onboardingTitleThree;

  /// No description provided for @onboardingDescriptionThree.
  ///
  /// In it, this message translates to:
  /// **'La tua prossima sessione, pronta quando vuoi.'**
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
  /// **'Continua'**
  String get onboardingNext;

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

  /// No description provided for @homeMotivationalSentence1.
  ///
  /// In it, this message translates to:
  /// **'PRONTO A SUPERARTI?'**
  String get homeMotivationalSentence1;

  /// No description provided for @homeMotivationalSentence2.
  ///
  /// In it, this message translates to:
  /// **'OGGI SI MIGLIORA!'**
  String get homeMotivationalSentence2;

  /// No description provided for @homeMotivationalSentence3.
  ///
  /// In it, this message translates to:
  /// **'PRONTO A DARE IL MASSIMO?'**
  String get homeMotivationalSentence3;

  /// No description provided for @homeMotivationalSentence4.
  ///
  /// In it, this message translates to:
  /// **'IL MEGLIO DEVE ANCORA VENIRE'**
  String get homeMotivationalSentence4;

  /// No description provided for @homeMotivationalSentence5.
  ///
  /// In it, this message translates to:
  /// **'PRONTO A FARE PROGRESSI?'**
  String get homeMotivationalSentence5;

  /// No description provided for @homeMotivationalSentence6.
  ///
  /// In it, this message translates to:
  /// **'LA TUA PROSSIMA SFIDA TI ASPETTA'**
  String get homeMotivationalSentence6;

  /// No description provided for @homeMotivationalSentence7.
  ///
  /// In it, this message translates to:
  /// **'OGGI PUOI FARE DI PIÙ'**
  String get homeMotivationalSentence7;

  /// No description provided for @homeMotivationalSentence8.
  ///
  /// In it, this message translates to:
  /// **'NON SMETTERE DI MIGLIORARE'**
  String get homeMotivationalSentence8;

  /// No description provided for @homeMotivationalSentence9.
  ///
  /// In it, this message translates to:
  /// **'COSTRUISCI LA TUA VERSIONE MIGLIORE'**
  String get homeMotivationalSentence9;

  /// No description provided for @homeMotivationalSentence10.
  ///
  /// In it, this message translates to:
  /// **'UN PASSO AVANTI, OGNI GIORNO'**
  String get homeMotivationalSentence10;

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
  /// **'Nessun piano di allenamento disponibile al momento.'**
  String get homeProgressNoPlan;

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

  /// No description provided for @workoutPlanTitle.
  ///
  /// In it, this message translates to:
  /// **'Piano di allenamento'**
  String get workoutPlanTitle;

  /// No description provided for @workoutPlanPdfView.
  ///
  /// In it, this message translates to:
  /// **'Visualizza PDF del trainer'**
  String get workoutPlanPdfView;

  /// No description provided for @workoutPlanPdfError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile caricare il PDF della scheda. Riprova.'**
  String get workoutPlanPdfError;

  /// No description provided for @traineeFeedbackTitle.
  ///
  /// In it, this message translates to:
  /// **'I miei feedback'**
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

  /// No description provided for @traineeFeedbackDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina feedback'**
  String get traineeFeedbackDelete;

  /// No description provided for @traineeFeedbackDeleteTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare il feedback?'**
  String get traineeFeedbackDeleteTitle;

  /// No description provided for @traineeFeedbackDeleteMessage.
  ///
  /// In it, this message translates to:
  /// **'Eliminare questo feedback? L\'operazione non può essere annullata.'**
  String get traineeFeedbackDeleteMessage;

  /// No description provided for @bugReportSettingsTitle.
  ///
  /// In it, this message translates to:
  /// **'Segnala un problema'**
  String get bugReportSettingsTitle;

  /// No description provided for @bugReportSettingsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Hai trovato un bug? Aiutaci a risolverlo.'**
  String get bugReportSettingsSubtitle;

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

  /// No description provided for @trainingMarkAsCompleted.
  ///
  /// In it, this message translates to:
  /// **'Segna come completato'**
  String get trainingMarkAsCompleted;

  /// No description provided for @trainingWorkoutCompleted.
  ///
  /// In it, this message translates to:
  /// **'Allenamento completato'**
  String get trainingWorkoutCompleted;

  /// No description provided for @trainingIncompleteTitle.
  ///
  /// In it, this message translates to:
  /// **'Attenzione'**
  String get trainingIncompleteTitle;

  /// No description provided for @trainingIncompleteMessage.
  ///
  /// In it, this message translates to:
  /// **'Non tutti gli esercizi sono stati completati ({count}).'**
  String trainingIncompleteMessage(int count);

  /// No description provided for @trainingIncompleteOptionIgnore.
  ///
  /// In it, this message translates to:
  /// **'Ignora esercizi non completati e segna come completato'**
  String get trainingIncompleteOptionIgnore;

  /// No description provided for @trainingIncompleteOptionCompleteAll.
  ///
  /// In it, this message translates to:
  /// **'Segna tutti gli esercizi e allenamento come completati'**
  String get trainingIncompleteOptionCompleteAll;

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

  /// No description provided for @profileMaxTestsBestLabel.
  ///
  /// In it, this message translates to:
  /// **'Miglior risultato'**
  String get profileMaxTestsBestLabel;

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

  /// No description provided for @profileSettingsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Tema, privacy e gestione dell’account'**
  String get profileSettingsSubtitle;

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
  /// **'Email o password non corrette.'**
  String get invalidCredentials;

  /// No description provided for @emailNotConfirmed.
  ///
  /// In it, this message translates to:
  /// **'Conferma il tuo indirizzo email prima di accedere.'**
  String get emailNotConfirmed;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In it, this message translates to:
  /// **'Esiste già un account con questo indirizzo email.'**
  String get emailAlreadyRegistered;

  /// No description provided for @weakPassword.
  ///
  /// In it, this message translates to:
  /// **'La password non soddisfa i requisiti di sicurezza.'**
  String get weakPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un indirizzo email valido.'**
  String get invalidEmail;

  /// No description provided for @signupDisabled.
  ///
  /// In it, this message translates to:
  /// **'La registrazione non è al momento disponibile.'**
  String get signupDisabled;

  /// No description provided for @authTooManyRequests.
  ///
  /// In it, this message translates to:
  /// **'Hai effettuato troppe richieste. Riprova più tardi.'**
  String get authTooManyRequests;

  /// No description provided for @authServiceUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Il servizio non è al momento disponibile. Riprova più tardi.'**
  String get authServiceUnavailable;

  /// No description provided for @authOperationFailed.
  ///
  /// In it, this message translates to:
  /// **'Non è stato possibile completare l\'operazione. Riprova.'**
  String get authOperationFailed;

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
  /// **'Pronto per la prossima sessione?'**
  String get loginGreeting;

  /// No description provided for @signupGreeting.
  ///
  /// In it, this message translates to:
  /// **'Crea il tuo account per iniziare.'**
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
  /// **'Crea account'**
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
  /// **'Password dimenticata?'**
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

  /// No description provided for @timerModeAmrap.
  ///
  /// In it, this message translates to:
  /// **'AMRAP'**
  String get timerModeAmrap;

  /// No description provided for @timerModeEmom.
  ///
  /// In it, this message translates to:
  /// **'EMOM'**
  String get timerModeEmom;

  /// No description provided for @timerModeForTime.
  ///
  /// In it, this message translates to:
  /// **'FOR TIME'**
  String get timerModeForTime;

  /// No description provided for @timerModeTabata.
  ///
  /// In it, this message translates to:
  /// **'TABATA'**
  String get timerModeTabata;

  /// No description provided for @timerWorkoutDuration.
  ///
  /// In it, this message translates to:
  /// **'Durata (min)'**
  String get timerWorkoutDuration;

  /// No description provided for @timerWorkoutUnlimited.
  ///
  /// In it, this message translates to:
  /// **'Più a lungo possibile'**
  String get timerWorkoutUnlimited;

  /// No description provided for @timerWorkoutElapsed.
  ///
  /// In it, this message translates to:
  /// **'Tempo trascorso'**
  String get timerWorkoutElapsed;

  /// No description provided for @timerWorkoutMinute.
  ///
  /// In it, this message translates to:
  /// **'Minuto {minute}'**
  String timerWorkoutMinute(int minute);

  /// No description provided for @timerTabataWork.
  ///
  /// In it, this message translates to:
  /// **'Lavoro'**
  String get timerTabataWork;

  /// No description provided for @timerTabataRest.
  ///
  /// In it, this message translates to:
  /// **'Recupero'**
  String get timerTabataRest;

  /// No description provided for @timerWorkoutFinish.
  ///
  /// In it, this message translates to:
  /// **'Termina'**
  String get timerWorkoutFinish;

  /// No description provided for @timerWorkoutComplete.
  ///
  /// In it, this message translates to:
  /// **'COMPLETATO'**
  String get timerWorkoutComplete;

  /// No description provided for @timerPhasePrepare.
  ///
  /// In it, this message translates to:
  /// **'PREPARATI'**
  String get timerPhasePrepare;

  /// No description provided for @timerAmrapReps.
  ///
  /// In it, this message translates to:
  /// **'Ripetizioni'**
  String get timerAmrapReps;

  /// No description provided for @timerAmrapAddRep.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get timerAmrapAddRep;

  /// No description provided for @timerChangeModeTitle.
  ///
  /// In it, this message translates to:
  /// **'Cambiare timer?'**
  String get timerChangeModeTitle;

  /// No description provided for @timerChangeModeWarning.
  ///
  /// In it, this message translates to:
  /// **'Se cambi timer perderai i progressi del timer attuale.'**
  String get timerChangeModeWarning;

  /// No description provided for @timerChangeModeConfirm.
  ///
  /// In it, this message translates to:
  /// **'Cambia timer'**
  String get timerChangeModeConfirm;

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

  /// No description provided for @timerRoundsLabel.
  ///
  /// In it, this message translates to:
  /// **'Round'**
  String get timerRoundsLabel;

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

  /// No description provided for @trainerMenuGroup.
  ///
  /// In it, this message translates to:
  /// **'TRAINER'**
  String get trainerMenuGroup;

  /// No description provided for @trainerNavDashboard.
  ///
  /// In it, this message translates to:
  /// **'Dashboard trainer'**
  String get trainerNavDashboard;

  /// No description provided for @trainerNavTrainees.
  ///
  /// In it, this message translates to:
  /// **'I miei allievi'**
  String get trainerNavTrainees;

  /// No description provided for @trainerNavFeedback.
  ///
  /// In it, this message translates to:
  /// **'Feedback degli allievi'**
  String get trainerNavFeedback;

  /// No description provided for @trainerNavPayments.
  ///
  /// In it, this message translates to:
  /// **'Pagamenti allievi'**
  String get trainerNavPayments;

  /// No description provided for @trainerWorkspaceTitle.
  ///
  /// In it, this message translates to:
  /// **'Area trainer'**
  String get trainerWorkspaceTitle;

  /// No description provided for @trainerWorkspaceSubtitle.
  ///
  /// In it, this message translates to:
  /// **'I tuoi atleti assegnati e le loro attività recenti.'**
  String get trainerWorkspaceSubtitle;

  /// No description provided for @trainerAssignedTrainees.
  ///
  /// In it, this message translates to:
  /// **'Allievi assegnati'**
  String get trainerAssignedTrainees;

  /// No description provided for @trainerUnreadFeedback.
  ///
  /// In it, this message translates to:
  /// **'Feedback non letti'**
  String get trainerUnreadFeedback;

  /// No description provided for @trainerActivePlans.
  ///
  /// In it, this message translates to:
  /// **'Piani attivi'**
  String get trainerActivePlans;

  /// No description provided for @trainerOverdue.
  ///
  /// In it, this message translates to:
  /// **'Scaduto'**
  String get trainerOverdue;

  /// No description provided for @trainerTraineesTitle.
  ///
  /// In it, this message translates to:
  /// **'Allievi'**
  String get trainerTraineesTitle;

  /// No description provided for @trainerNoAssignedTrainees.
  ///
  /// In it, this message translates to:
  /// **'Non ti è ancora stato assegnato alcun allievo.'**
  String get trainerNoAssignedTrainees;

  /// No description provided for @trainerStatusActive.
  ///
  /// In it, this message translates to:
  /// **'Attivo'**
  String get trainerStatusActive;

  /// No description provided for @trainerPlanProgress.
  ///
  /// In it, this message translates to:
  /// **'Progresso del piano'**
  String get trainerPlanProgress;

  /// No description provided for @trainerOpenProgram.
  ///
  /// In it, this message translates to:
  /// **'Apri programma'**
  String get trainerOpenProgram;

  /// No description provided for @trainerSearchTrainees.
  ///
  /// In it, this message translates to:
  /// **'Cerca allievi'**
  String get trainerSearchTrainees;

  /// No description provided for @trainerAssignedCount.
  ///
  /// In it, this message translates to:
  /// **'{count} allievi assegnati'**
  String trainerAssignedCount(int count);

  /// No description provided for @trainerNoMatchingTrainees.
  ///
  /// In it, this message translates to:
  /// **'Nessun allievo corrispondente.'**
  String get trainerNoMatchingTrainees;

  /// No description provided for @trainerFilterAll.
  ///
  /// In it, this message translates to:
  /// **'Tutti'**
  String get trainerFilterAll;

  /// No description provided for @trainerFilterUnread.
  ///
  /// In it, this message translates to:
  /// **'Non letti'**
  String get trainerFilterUnread;

  /// No description provided for @trainerFilterAnswered.
  ///
  /// In it, this message translates to:
  /// **'Risposti'**
  String get trainerFilterAnswered;

  /// No description provided for @trainerNoFeedbackInView.
  ///
  /// In it, this message translates to:
  /// **'Nessun feedback in questa vista.'**
  String get trainerNoFeedbackInView;

  /// No description provided for @trainerStatusRead.
  ///
  /// In it, this message translates to:
  /// **'Letto'**
  String get trainerStatusRead;

  /// No description provided for @trainerStatusUnread.
  ///
  /// In it, this message translates to:
  /// **'Non letto'**
  String get trainerStatusUnread;

  /// No description provided for @trainerYourAnswer.
  ///
  /// In it, this message translates to:
  /// **'La tua risposta'**
  String get trainerYourAnswer;

  /// No description provided for @trainerReplyHint.
  ///
  /// In it, this message translates to:
  /// **'Rispondi all’allievo'**
  String get trainerReplyHint;

  /// No description provided for @trainerSendAnswer.
  ///
  /// In it, this message translates to:
  /// **'Invia risposta'**
  String get trainerSendAnswer;

  /// No description provided for @trainerMarkUnread.
  ///
  /// In it, this message translates to:
  /// **'Segna come non letto'**
  String get trainerMarkUnread;

  /// No description provided for @trainerMarkRead.
  ///
  /// In it, this message translates to:
  /// **'Segna come letto'**
  String get trainerMarkRead;

  /// No description provided for @trainerFeedbackMarkedRead.
  ///
  /// In it, this message translates to:
  /// **'Segnato come letto. Puoi ancora trovarlo in Tutti.'**
  String get trainerFeedbackMarkedRead;

  /// No description provided for @trainerFeedbackMarkedUnread.
  ///
  /// In it, this message translates to:
  /// **'Segnato come non letto.'**
  String get trainerFeedbackMarkedUnread;

  /// No description provided for @trainerAnswerRequired.
  ///
  /// In it, this message translates to:
  /// **'Scrivi prima una risposta.'**
  String get trainerAnswerRequired;

  /// No description provided for @trainerPaid.
  ///
  /// In it, this message translates to:
  /// **'Pagato'**
  String get trainerPaid;

  /// No description provided for @trainerReceived.
  ///
  /// In it, this message translates to:
  /// **'Incassato'**
  String get trainerReceived;

  /// No description provided for @trainerMonthlyAmount.
  ///
  /// In it, this message translates to:
  /// **'Importo mensile'**
  String get trainerMonthlyAmount;

  /// No description provided for @trainerPaymentNotes.
  ///
  /// In it, this message translates to:
  /// **'Note sul pagamento'**
  String get trainerPaymentNotes;

  /// No description provided for @trainerAppAccessActive.
  ///
  /// In it, this message translates to:
  /// **'Accesso all’app attivo'**
  String get trainerAppAccessActive;

  /// No description provided for @trainerLoadToolsError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile caricare gli strumenti trainer\n{error}'**
  String trainerLoadToolsError(String error);

  /// No description provided for @trainerRetry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get trainerRetry;

  /// No description provided for @trainerOverviewTab.
  ///
  /// In it, this message translates to:
  /// **'Panoramica'**
  String get trainerOverviewTab;

  /// No description provided for @trainerPlanTab.
  ///
  /// In it, this message translates to:
  /// **'Piano'**
  String get trainerPlanTab;

  /// No description provided for @trainerHistoryTab.
  ///
  /// In it, this message translates to:
  /// **'Cronologia'**
  String get trainerHistoryTab;

  /// No description provided for @trainerLoadProgramError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile caricare il programma\n{error}'**
  String trainerLoadProgramError(String error);

  /// No description provided for @trainerAthleteData.
  ///
  /// In it, this message translates to:
  /// **'Dati atleta'**
  String get trainerAthleteData;

  /// No description provided for @trainerNameLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get trainerNameLabel;

  /// No description provided for @trainerWeightLabel.
  ///
  /// In it, this message translates to:
  /// **'Peso'**
  String get trainerWeightLabel;

  /// No description provided for @trainerPaymentLabel.
  ///
  /// In it, this message translates to:
  /// **'Pagamento'**
  String get trainerPaymentLabel;

  /// No description provided for @trainerOnTime.
  ///
  /// In it, this message translates to:
  /// **'In regola'**
  String get trainerOnTime;

  /// No description provided for @trainerProgressLabel.
  ///
  /// In it, this message translates to:
  /// **'Progresso'**
  String get trainerProgressLabel;

  /// No description provided for @trainerCoachTip.
  ///
  /// In it, this message translates to:
  /// **'Consiglio del coach'**
  String get trainerCoachTip;

  /// No description provided for @trainerCoachTipHint.
  ///
  /// In it, this message translates to:
  /// **'Visibile all’allievo nell’app'**
  String get trainerCoachTipHint;

  /// No description provided for @trainerPrivateNotes.
  ///
  /// In it, this message translates to:
  /// **'Note private del trainer'**
  String get trainerPrivateNotes;

  /// No description provided for @trainerSave.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get trainerSave;

  /// No description provided for @trainerCoachFieldsSaved.
  ///
  /// In it, this message translates to:
  /// **'Consiglio e note private salvati.'**
  String get trainerCoachFieldsSaved;

  /// No description provided for @trainerTrainingCalendar.
  ///
  /// In it, this message translates to:
  /// **'Calendario allenamenti'**
  String get trainerTrainingCalendar;

  /// No description provided for @trainerNoScheduledDays.
  ///
  /// In it, this message translates to:
  /// **'Nessun giorno programmato.'**
  String get trainerNoScheduledDays;

  /// No description provided for @trainerShowMoreDays.
  ///
  /// In it, this message translates to:
  /// **'Mostra altri {count} giorni'**
  String trainerShowMoreDays(int count);

  /// No description provided for @trainerShowLessDays.
  ///
  /// In it, this message translates to:
  /// **'Mostra meno giorni'**
  String get trainerShowLessDays;

  /// No description provided for @trainerFeedbackTitle.
  ///
  /// In it, this message translates to:
  /// **'Feedback'**
  String get trainerFeedbackTitle;

  /// No description provided for @trainerNoFeedbackYet.
  ///
  /// In it, this message translates to:
  /// **'Nessun feedback.'**
  String get trainerNoFeedbackYet;

  /// No description provided for @trainerCreateWorkoutPlan.
  ///
  /// In it, this message translates to:
  /// **'Crea scheda di allenamento'**
  String get trainerCreateWorkoutPlan;

  /// No description provided for @trainerImportPdf.
  ///
  /// In it, this message translates to:
  /// **'Importa PDF'**
  String get trainerImportPdf;

  /// No description provided for @trainerImportingPdf.
  ///
  /// In it, this message translates to:
  /// **'Lettura PDF…'**
  String get trainerImportingPdf;

  /// No description provided for @trainerPdfPreviewTitle.
  ///
  /// In it, this message translates to:
  /// **'Controlla il piano importato'**
  String get trainerPdfPreviewTitle;

  /// No description provided for @trainerPdfPlanName.
  ///
  /// In it, this message translates to:
  /// **'Nome del piano'**
  String get trainerPdfPlanName;

  /// No description provided for @trainerPdfSummary.
  ///
  /// In it, this message translates to:
  /// **'Rilevati {days} giorni e {exercises} esercizi'**
  String trainerPdfSummary(int days, int exercises);

  /// No description provided for @trainerPdfDaySummary.
  ///
  /// In it, this message translates to:
  /// **'Settimana {week} · Giorno {day}: {exercises} esercizi'**
  String trainerPdfDaySummary(String week, String day, int exercises);

  /// No description provided for @trainerPdfConfirmImport.
  ///
  /// In it, this message translates to:
  /// **'Importa piano'**
  String get trainerPdfConfirmImport;

  /// No description provided for @trainerPdfImportSuccess.
  ///
  /// In it, this message translates to:
  /// **'Scheda di allenamento importata correttamente.'**
  String get trainerPdfImportSuccess;

  /// No description provided for @trainerPdfImportFailed.
  ///
  /// In it, this message translates to:
  /// **'Impossibile importare il PDF. Verifica che contenga tabelle di allenamento GIORNO A–G.'**
  String get trainerPdfImportFailed;

  /// No description provided for @trainerPdfFileUnavailable.
  ///
  /// In it, this message translates to:
  /// **'PDF non valido o superiore a 25 MB. Seleziona un altro file.'**
  String get trainerPdfFileUnavailable;

  /// No description provided for @trainerNoPlans.
  ///
  /// In it, this message translates to:
  /// **'Nessun piano creato.'**
  String get trainerNoPlans;

  /// No description provided for @trainerWorkoutPlanFallback.
  ///
  /// In it, this message translates to:
  /// **'Scheda di allenamento'**
  String get trainerWorkoutPlanFallback;

  /// No description provided for @trainerMaxTests.
  ///
  /// In it, this message translates to:
  /// **'Test massimali'**
  String get trainerMaxTests;

  /// No description provided for @trainerNoMaxTests.
  ///
  /// In it, this message translates to:
  /// **'Nessun test massimale.'**
  String get trainerNoMaxTests;

  /// No description provided for @trainerAddMaxTest.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi test massimale'**
  String get trainerAddMaxTest;

  /// No description provided for @trainerMaxTestExercise.
  ///
  /// In it, this message translates to:
  /// **'Esercizio'**
  String get trainerMaxTestExercise;

  /// No description provided for @trainerMaxTestExerciseRequired.
  ///
  /// In it, this message translates to:
  /// **'Seleziona un esercizio.'**
  String get trainerMaxTestExerciseRequired;

  /// No description provided for @trainerMaxTestOther.
  ///
  /// In it, this message translates to:
  /// **'Altro'**
  String get trainerMaxTestOther;

  /// No description provided for @trainerMaxTestCustomExerciseName.
  ///
  /// In it, this message translates to:
  /// **'Nome esercizio personalizzato'**
  String get trainerMaxTestCustomExerciseName;

  /// No description provided for @trainerMaxTestValue.
  ///
  /// In it, this message translates to:
  /// **'Risultato'**
  String get trainerMaxTestValue;

  /// No description provided for @trainerMaxTestValueInvalid.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un valore maggiore di zero.'**
  String get trainerMaxTestValueInvalid;

  /// No description provided for @trainerMaxTestUnit.
  ///
  /// In it, this message translates to:
  /// **'Unità'**
  String get trainerMaxTestUnit;

  /// No description provided for @trainerMaxTestDate.
  ///
  /// In it, this message translates to:
  /// **'Data del test'**
  String get trainerMaxTestDate;

  /// No description provided for @trainerMaxTestSaved.
  ///
  /// In it, this message translates to:
  /// **'Test massimale salvato.'**
  String get trainerMaxTestSaved;

  /// No description provided for @trainerMaxTestPrivateNotesHint.
  ///
  /// In it, this message translates to:
  /// **'Visibili solo ai trainer assegnati'**
  String get trainerMaxTestPrivateNotesHint;

  /// No description provided for @trainerEditMaxTestNotes.
  ///
  /// In it, this message translates to:
  /// **'Modifica note private'**
  String get trainerEditMaxTestNotes;

  /// No description provided for @trainerMaxTestNotesUpdated.
  ///
  /// In it, this message translates to:
  /// **'Note del massimale aggiornate.'**
  String get trainerMaxTestNotesUpdated;

  /// No description provided for @trainerMaxTestSaveError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile salvare il test massimale: {error}'**
  String trainerMaxTestSaveError(String error);

  /// No description provided for @trainerDeleteMaxTest.
  ///
  /// In it, this message translates to:
  /// **'Elimina test massimale'**
  String get trainerDeleteMaxTest;

  /// No description provided for @trainerDeleteMaxTestTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare il test massimale?'**
  String get trainerDeleteMaxTestTitle;

  /// No description provided for @trainerDeleteMaxTestMessage.
  ///
  /// In it, this message translates to:
  /// **'Il risultato verrà eliminato definitivamente.'**
  String get trainerDeleteMaxTestMessage;

  /// No description provided for @trainerMaxTestDeleted.
  ///
  /// In it, this message translates to:
  /// **'Test massimale eliminato.'**
  String get trainerMaxTestDeleted;

  /// No description provided for @trainerMaxTestDeleteError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile eliminare il test massimale: {error}'**
  String trainerMaxTestDeleteError(String error);

  /// No description provided for @trainerWeightHistory.
  ///
  /// In it, this message translates to:
  /// **'Cronologia peso'**
  String get trainerWeightHistory;

  /// No description provided for @trainerNoWeightEntries.
  ///
  /// In it, this message translates to:
  /// **'Nessuna registrazione del peso.'**
  String get trainerNoWeightEntries;

  /// No description provided for @trainerHeightHistory.
  ///
  /// In it, this message translates to:
  /// **'Cronologia altezza'**
  String get trainerHeightHistory;

  /// No description provided for @trainerNoHeightEntries.
  ///
  /// In it, this message translates to:
  /// **'Nessuna registrazione dell\'altezza.'**
  String get trainerNoHeightEntries;

  /// No description provided for @trainerPaymentHistory.
  ///
  /// In it, this message translates to:
  /// **'Cronologia pagamenti'**
  String get trainerPaymentHistory;

  /// No description provided for @trainerNoPayments.
  ///
  /// In it, this message translates to:
  /// **'Nessun pagamento.'**
  String get trainerNoPayments;

  /// No description provided for @trainerTrainingDayFallback.
  ///
  /// In it, this message translates to:
  /// **'Giorno di allenamento'**
  String get trainerTrainingDayFallback;

  /// No description provided for @trainerExercisesCompleted.
  ///
  /// In it, this message translates to:
  /// **'{completed}/{total} esercizi completati'**
  String trainerExercisesCompleted(int completed, int total);

  /// No description provided for @trainerPlanCompleted.
  ///
  /// In it, this message translates to:
  /// **'Completato'**
  String get trainerPlanCompleted;

  /// No description provided for @trainerExerciseFallback.
  ///
  /// In it, this message translates to:
  /// **'Esercizio'**
  String get trainerExerciseFallback;

  /// No description provided for @trainerEditExerciseTitle.
  ///
  /// In it, this message translates to:
  /// **'Modifica esercizio'**
  String get trainerEditExerciseTitle;

  /// No description provided for @trainerExerciseName.
  ///
  /// In it, this message translates to:
  /// **'Nome esercizio'**
  String get trainerExerciseName;

  /// No description provided for @trainerExerciseDuration.
  ///
  /// In it, this message translates to:
  /// **'Durata'**
  String get trainerExerciseDuration;

  /// No description provided for @trainerExerciseNotes.
  ///
  /// In it, this message translates to:
  /// **'Note del trainer'**
  String get trainerExerciseNotes;

  /// No description provided for @trainerExerciseUpdated.
  ///
  /// In it, this message translates to:
  /// **'Esercizio aggiornato correttamente.'**
  String get trainerExerciseUpdated;

  /// No description provided for @trainerExerciseNameRequired.
  ///
  /// In it, this message translates to:
  /// **'Inserisci il nome dell’esercizio.'**
  String get trainerExerciseNameRequired;

  /// No description provided for @trainerExerciseDurationInvalid.
  ///
  /// In it, this message translates to:
  /// **'Inserisci una durata valida in minuti.'**
  String get trainerExerciseDurationInvalid;

  /// No description provided for @trainerMinutesDuration.
  ///
  /// In it, this message translates to:
  /// **'{minutes} min'**
  String trainerMinutesDuration(String minutes);

  /// No description provided for @trainerExerciseResult.
  ///
  /// In it, this message translates to:
  /// **'{minutes} min · {reps} rip.'**
  String trainerExerciseResult(String minutes, String reps);

  /// No description provided for @trainerTraineeNote.
  ///
  /// In it, this message translates to:
  /// **'Allievo: {notes}'**
  String trainerTraineeNote(String notes);

  /// No description provided for @trainerTraineeExerciseFeedback.
  ///
  /// In it, this message translates to:
  /// **'Commento sull’esercizio: {comment}'**
  String trainerTraineeExerciseFeedback(String comment);

  /// No description provided for @trainerDeletePlanTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare il piano?'**
  String get trainerDeletePlanTitle;

  /// No description provided for @trainerDeletePlanMessage.
  ///
  /// In it, this message translates to:
  /// **'Eliminare “{title}”?'**
  String trainerDeletePlanMessage(String title);

  /// No description provided for @trainerCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get trainerCancel;

  /// No description provided for @trainerDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get trainerDelete;

  /// No description provided for @trainerDeleteFeedback.
  ///
  /// In it, this message translates to:
  /// **'Elimina feedback'**
  String get trainerDeleteFeedback;

  /// No description provided for @trainerDeleteFeedbackTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare il feedback?'**
  String get trainerDeleteFeedbackTitle;

  /// No description provided for @trainerDeleteFeedbackMessage.
  ///
  /// In it, this message translates to:
  /// **'Eliminare questo feedback di {name}? L\'operazione non può essere annullata.'**
  String trainerDeleteFeedbackMessage(String name);

  /// No description provided for @trainerNewPlan.
  ///
  /// In it, this message translates to:
  /// **'Nuova scheda di allenamento'**
  String get trainerNewPlan;

  /// No description provided for @trainerPlanName.
  ///
  /// In it, this message translates to:
  /// **'Nome del piano'**
  String get trainerPlanName;

  /// No description provided for @trainerNotes.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get trainerNotes;

  /// No description provided for @trainerCreate.
  ///
  /// In it, this message translates to:
  /// **'Crea'**
  String get trainerCreate;

  /// No description provided for @adminMenuGroup.
  ///
  /// In it, this message translates to:
  /// **'AMMINISTRAZIONE'**
  String get adminMenuGroup;

  /// No description provided for @adminNavConsole.
  ///
  /// In it, this message translates to:
  /// **'Console amministratore'**
  String get adminNavConsole;

  /// No description provided for @adminOverview.
  ///
  /// In it, this message translates to:
  /// **'Panoramica'**
  String get adminOverview;

  /// No description provided for @adminUsers.
  ///
  /// In it, this message translates to:
  /// **'Utenti'**
  String get adminUsers;

  /// No description provided for @adminAssignments.
  ///
  /// In it, this message translates to:
  /// **'Assegnazioni'**
  String get adminAssignments;

  /// No description provided for @adminTotalUsers.
  ///
  /// In it, this message translates to:
  /// **'Utenti totali'**
  String get adminTotalUsers;

  /// No description provided for @adminTrainees.
  ///
  /// In it, this message translates to:
  /// **'Allievi'**
  String get adminTrainees;

  /// No description provided for @adminTrainers.
  ///
  /// In it, this message translates to:
  /// **'Trainer'**
  String get adminTrainers;

  /// No description provided for @adminSuspended.
  ///
  /// In it, this message translates to:
  /// **'Sospesi'**
  String get adminSuspended;

  /// No description provided for @adminNoUsers.
  ///
  /// In it, this message translates to:
  /// **'Nessun utente corrispondente.'**
  String get adminNoUsers;

  /// No description provided for @adminNoAssignments.
  ///
  /// In it, this message translates to:
  /// **'Nessuna assegnazione trainer.'**
  String get adminNoAssignments;

  /// No description provided for @adminSearchAssignments.
  ///
  /// In it, this message translates to:
  /// **'Cerca assegnazioni'**
  String get adminSearchAssignments;

  /// No description provided for @adminSearchUsers.
  ///
  /// In it, this message translates to:
  /// **'Cerca utenti'**
  String get adminSearchUsers;

  /// No description provided for @adminRoleAdmin.
  ///
  /// In it, this message translates to:
  /// **'Amministratore'**
  String get adminRoleAdmin;

  /// No description provided for @adminRoleTrainer.
  ///
  /// In it, this message translates to:
  /// **'Trainer'**
  String get adminRoleTrainer;

  /// No description provided for @adminRoleTrainee.
  ///
  /// In it, this message translates to:
  /// **'Allievo'**
  String get adminRoleTrainee;

  /// No description provided for @adminAccessActive.
  ///
  /// In it, this message translates to:
  /// **'Accesso attivo'**
  String get adminAccessActive;

  /// No description provided for @adminAccessSuspended.
  ///
  /// In it, this message translates to:
  /// **'Accesso sospeso'**
  String get adminAccessSuspended;

  /// No description provided for @adminCurrentAccount.
  ///
  /// In it, this message translates to:
  /// **'Il tuo account'**
  String get adminCurrentAccount;

  /// No description provided for @adminGrantTrainer.
  ///
  /// In it, this message translates to:
  /// **'Assegna ruolo trainer'**
  String get adminGrantTrainer;

  /// No description provided for @adminRevokeTrainer.
  ///
  /// In it, this message translates to:
  /// **'Revoca ruolo trainer'**
  String get adminRevokeTrainer;

  /// No description provided for @adminSuspend.
  ///
  /// In it, this message translates to:
  /// **'Sospendi accesso'**
  String get adminSuspend;

  /// No description provided for @adminRestoreAccess.
  ///
  /// In it, this message translates to:
  /// **'Ripristina accesso'**
  String get adminRestoreAccess;

  /// No description provided for @adminConfirmSuspendTitle.
  ///
  /// In it, this message translates to:
  /// **'Sospendere l’account?'**
  String get adminConfirmSuspendTitle;

  /// No description provided for @adminConfirmSuspendMessage.
  ///
  /// In it, this message translates to:
  /// **'Sospendere l’accesso all’app per {name}?'**
  String adminConfirmSuspendMessage(String name);

  /// No description provided for @adminConfirmRevokeTitle.
  ///
  /// In it, this message translates to:
  /// **'Revocare il ruolo trainer?'**
  String get adminConfirmRevokeTitle;

  /// No description provided for @adminConfirmRevokeMessage.
  ///
  /// In it, this message translates to:
  /// **'Revocare l’accesso trainer a {name}? Le assegnazioni verranno rimosse.'**
  String adminConfirmRevokeMessage(String name);

  /// No description provided for @adminCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get adminCancel;

  /// No description provided for @adminConfirm.
  ///
  /// In it, this message translates to:
  /// **'Conferma'**
  String get adminConfirm;

  /// No description provided for @adminAssignmentTrainer.
  ///
  /// In it, this message translates to:
  /// **'Trainer'**
  String get adminAssignmentTrainer;

  /// No description provided for @adminAssignmentTrainee.
  ///
  /// In it, this message translates to:
  /// **'Allievo'**
  String get adminAssignmentTrainee;

  /// No description provided for @adminAddAssignment.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi assegnazione'**
  String get adminAddAssignment;

  /// No description provided for @adminRemoveAssignment.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi assegnazione'**
  String get adminRemoveAssignment;

  /// No description provided for @adminLoadError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile caricare gli strumenti amministratore\n{error}'**
  String adminLoadError(String error);

  /// No description provided for @adminActionFailed.
  ///
  /// In it, this message translates to:
  /// **'Operazione amministratore non riuscita: {error}'**
  String adminActionFailed(String error);

  /// No description provided for @authWelcomeTitle.
  ///
  /// In it, this message translates to:
  /// **'Bentornato.'**
  String get authWelcomeTitle;

  /// No description provided for @authShowPassword.
  ///
  /// In it, this message translates to:
  /// **'Mostra password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In it, this message translates to:
  /// **'Nascondi password'**
  String get authHidePassword;
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

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
  /// **'Sblocca nuove skill man mano che impari le basi.'**
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

  /// No description provided for @skillsLockedLabel.
  ///
  /// In it, this message translates to:
  /// **'Bloccato'**
  String get skillsLockedLabel;

  /// No description provided for @skillsUnlockedLabel.
  ///
  /// In it, this message translates to:
  /// **'Sbloccato'**
  String get skillsUnlockedLabel;

  /// No description provided for @skillsLockedHint.
  ///
  /// In it, this message translates to:
  /// **'Completa le skill precedenti per sbloccare la spiegazione completa.'**
  String get skillsLockedHint;

  /// No description provided for @skillsUnlockAction.
  ///
  /// In it, this message translates to:
  /// **'Sblocca skill'**
  String get skillsUnlockAction;

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

  /// No description provided for @guidesPullupName.
  ///
  /// In it, this message translates to:
  /// **'Trazioni'**
  String get guidesPullupName;

  /// No description provided for @guidesPullupFocus.
  ///
  /// In it, this message translates to:
  /// **'Dorsali, bicipiti, presa'**
  String get guidesPullupFocus;

  /// No description provided for @guidesPullupTip.
  ///
  /// In it, this message translates to:
  /// **'Spingi i gomiti verso le costole e tieni le costole chiuse per evitare oscillazioni.'**
  String get guidesPullupTip;

  /// No description provided for @guidesPullupDescription.
  ///
  /// In it, this message translates to:
  /// **'Parti da una sospensione in hollow body, poi tira finché il mento supera la sbarra. Controlla la discesa per ripetizioni più forti.'**
  String get guidesPullupDescription;

  /// No description provided for @guidesChinUpName.
  ///
  /// In it, this message translates to:
  /// **'Chin-up'**
  String get guidesChinUpName;

  /// No description provided for @guidesChinUpFocus.
  ///
  /// In it, this message translates to:
  /// **'Dorsali, bicipiti, presa'**
  String get guidesChinUpFocus;

  /// No description provided for @guidesChinUpTip.
  ///
  /// In it, this message translates to:
  /// **'Tieni le spalle depresse e spingi i gomiti verso le costole per restare forte in alto.'**
  String get guidesChinUpTip;

  /// No description provided for @guidesChinUpDescription.
  ///
  /// In it, this message translates to:
  /// **'Parti da una sospensione con i palmi verso di te, tira finché il mento supera la sbarra, poi scendi con controllo.'**
  String get guidesChinUpDescription;

  /// No description provided for @guidesPushupName.
  ///
  /// In it, this message translates to:
  /// **'Piegamenti'**
  String get guidesPushupName;

  /// No description provided for @guidesPushupFocus.
  ///
  /// In it, this message translates to:
  /// **'Petto, tricipiti, core'**
  String get guidesPushupFocus;

  /// No description provided for @guidesPushupTip.
  ///
  /// In it, this message translates to:
  /// **'Contrai i glutei e mantieni una linea dritta dalla testa ai talloni.'**
  String get guidesPushupTip;

  /// No description provided for @guidesPushupDescription.
  ///
  /// In it, this message translates to:
  /// **'Scendi con i gomiti a circa 45° rispetto al busto, sfiora il petto e risali senza lasciare che i fianchi cedano.'**
  String get guidesPushupDescription;

  /// No description provided for @guidesBodyweightSquatName.
  ///
  /// In it, this message translates to:
  /// **'Squat a corpo libero'**
  String get guidesBodyweightSquatName;

  /// No description provided for @guidesBodyweightSquatFocus.
  ///
  /// In it, this message translates to:
  /// **'Quadricipiti, glutei, core'**
  String get guidesBodyweightSquatFocus;

  /// No description provided for @guidesBodyweightSquatTip.
  ///
  /// In it, this message translates to:
  /// **'Spingi le ginocchia verso l\'esterno durante la discesa e mantieni i talloni a terra.'**
  String get guidesBodyweightSquatTip;

  /// No description provided for @guidesBodyweightSquatDescription.
  ///
  /// In it, this message translates to:
  /// **'Porta indietro e in basso le anche finché le cosce sono almeno parallele. Spingi uniformemente su tutto il piede per tornare in piedi.'**
  String get guidesBodyweightSquatDescription;

  /// No description provided for @guidesGluteBridgeName.
  ///
  /// In it, this message translates to:
  /// **'Ponte glutei'**
  String get guidesGluteBridgeName;

  /// No description provided for @guidesGluteBridgeFocus.
  ///
  /// In it, this message translates to:
  /// **'Glutei, femorali, core'**
  String get guidesGluteBridgeFocus;

  /// No description provided for @guidesGluteBridgeTip.
  ///
  /// In it, this message translates to:
  /// **'Espira mentre sali ed evita di inarcare troppo la zona lombare in alto.'**
  String get guidesGluteBridgeTip;

  /// No description provided for @guidesGluteBridgeDescription.
  ///
  /// In it, this message translates to:
  /// **'Supino con ginocchia piegate, spingi sui talloni per sollevare il bacino finché cosce e busto sono allineati, poi scendi lentamente.'**
  String get guidesGluteBridgeDescription;

  /// No description provided for @guidesHangingLegRaiseName.
  ///
  /// In it, this message translates to:
  /// **'Sollevamento gambe alla sbarra'**
  String get guidesHangingLegRaiseName;

  /// No description provided for @guidesHangingLegRaiseFocus.
  ///
  /// In it, this message translates to:
  /// **'Addominali, flessori dell\'anca, presa'**
  String get guidesHangingLegRaiseFocus;

  /// No description provided for @guidesHangingLegRaiseTip.
  ///
  /// In it, this message translates to:
  /// **'Inizia ogni ripetizione attivando i dorsali per stabilizzare il busto.'**
  String get guidesHangingLegRaiseTip;

  /// No description provided for @guidesHangingLegRaiseDescription.
  ///
  /// In it, this message translates to:
  /// **'Da una sospensione completa, solleva le gambe unite fino all\'altezza delle anche o più in alto. Scendi lentamente per mantenere tensione.'**
  String get guidesHangingLegRaiseDescription;

  /// No description provided for @guidesMuscleUpName.
  ///
  /// In it, this message translates to:
  /// **'Muscle-up'**
  String get guidesMuscleUpName;

  /// No description provided for @guidesMuscleUpFocus.
  ///
  /// In it, this message translates to:
  /// **'Dorsali, petto, tricipiti, forza nella transizione'**
  String get guidesMuscleUpFocus;

  /// No description provided for @guidesMuscleUpTip.
  ///
  /// In it, this message translates to:
  /// **'Tira in alto verso la parte alta del petto e tieni la sbarra vicina per ridurre l\'oscillazione.'**
  String get guidesMuscleUpTip;

  /// No description provided for @guidesMuscleUpDescription.
  ///
  /// In it, this message translates to:
  /// **'Da una sospensione controllata, esplodi in una trazione alta, porta i polsi sopra la sbarra e spingi fino al blocco.'**
  String get guidesMuscleUpDescription;

  /// No description provided for @guidesStraightBarDipName.
  ///
  /// In it, this message translates to:
  /// **'Dip alla sbarra'**
  String get guidesStraightBarDipName;

  /// No description provided for @guidesStraightBarDipFocus.
  ///
  /// In it, this message translates to:
  /// **'Petto, tricipiti, spalle'**
  String get guidesStraightBarDipFocus;

  /// No description provided for @guidesStraightBarDipTip.
  ///
  /// In it, this message translates to:
  /// **'Tieni i gomiti vicini al corpo e spingi verso il basso con una leggera inclinazione in avanti.'**
  String get guidesStraightBarDipTip;

  /// No description provided for @guidesStraightBarDipDescription.
  ///
  /// In it, this message translates to:
  /// **'Parti sopra la sbarra con gomiti bloccati, scendi controllando finché le spalle scendono sotto i gomiti, poi risali.'**
  String get guidesStraightBarDipDescription;

  /// No description provided for @guidesDipsName.
  ///
  /// In it, this message translates to:
  /// **'Dip alle parallele'**
  String get guidesDipsName;

  /// No description provided for @guidesDipsFocus.
  ///
  /// In it, this message translates to:
  /// **'Petto, tricipiti, spalle'**
  String get guidesDipsFocus;

  /// No description provided for @guidesDipsTip.
  ///
  /// In it, this message translates to:
  /// **'Inclina leggermente il busto in avanti e mantieni le spalle compatte per proteggere le articolazioni.'**
  String get guidesDipsTip;

  /// No description provided for @guidesDipsDescription.
  ///
  /// In it, this message translates to:
  /// **'Parti in blocco sulle parallele, scendi finché le spalle vanno sotto i gomiti, poi risali fino a un blocco forte.'**
  String get guidesDipsDescription;

  /// No description provided for @guidesAustralianRowName.
  ///
  /// In it, this message translates to:
  /// **'Rematore australiano'**
  String get guidesAustralianRowName;

  /// No description provided for @guidesAustralianRowFocus.
  ///
  /// In it, this message translates to:
  /// **'Dorsali alti, bicipiti, core'**
  String get guidesAustralianRowFocus;

  /// No description provided for @guidesAustralianRowTip.
  ///
  /// In it, this message translates to:
  /// **'Attiva il core e mantieni una linea dritta dalle spalle ai talloni.'**
  String get guidesAustralianRowTip;

  /// No description provided for @guidesAustralianRowDescription.
  ///
  /// In it, this message translates to:
  /// **'Imposta la sbarra all\'altezza della vita, appenditi sotto e tira il petto verso la sbarra con gomiti stretti.'**
  String get guidesAustralianRowDescription;

  /// No description provided for @guidesPikePushUpName.
  ///
  /// In it, this message translates to:
  /// **'Piegamenti in pike'**
  String get guidesPikePushUpName;

  /// No description provided for @guidesPikePushUpFocus.
  ///
  /// In it, this message translates to:
  /// **'Spalle, tricipiti, core'**
  String get guidesPikePushUpFocus;

  /// No description provided for @guidesPikePushUpTip.
  ///
  /// In it, this message translates to:
  /// **'Tieni i fianchi alti e abbassa la testa verso un punto appena davanti alle mani.'**
  String get guidesPikePushUpTip;

  /// No description provided for @guidesPikePushUpDescription.
  ///
  /// In it, this message translates to:
  /// **'Da una posizione a pike, piega i gomiti per portare la testa in basso, poi spingi fino a un blocco forte.'**
  String get guidesPikePushUpDescription;

  /// No description provided for @guidesHollowHoldName.
  ///
  /// In it, this message translates to:
  /// **'Tenuta hollow body'**
  String get guidesHollowHoldName;

  /// No description provided for @guidesHollowHoldFocus.
  ///
  /// In it, this message translates to:
  /// **'Core, flessori dell\'anca, postura'**
  String get guidesHollowHoldFocus;

  /// No description provided for @guidesHollowHoldTip.
  ///
  /// In it, this message translates to:
  /// **'Spingi la zona lombare a terra e tieni le costole chiuse.'**
  String get guidesHollowHoldTip;

  /// No description provided for @guidesHollowHoldDescription.
  ///
  /// In it, this message translates to:
  /// **'Sdraiati supino, solleva spalle e gambe e mantieni una forma a banana con braccia tese sopra la testa.'**
  String get guidesHollowHoldDescription;

  /// No description provided for @guidesPlankName.
  ///
  /// In it, this message translates to:
  /// **'Plank'**
  String get guidesPlankName;

  /// No description provided for @guidesPlankFocus.
  ///
  /// In it, this message translates to:
  /// **'Core, spalle, glutei'**
  String get guidesPlankFocus;

  /// No description provided for @guidesPlankTip.
  ///
  /// In it, this message translates to:
  /// **'Contrai i glutei e tieni le costole chiuse per evitare che i fianchi cedano.'**
  String get guidesPlankTip;

  /// No description provided for @guidesPlankDescription.
  ///
  /// In it, this message translates to:
  /// **'Posiziona gli avambracci sotto le spalle, allunga le gambe e mantieni una linea dritta dalla testa ai talloni respirando con calma.'**
  String get guidesPlankDescription;

  /// No description provided for @guidesLSitName.
  ///
  /// In it, this message translates to:
  /// **'L-sit'**
  String get guidesLSitName;

  /// No description provided for @guidesLSitFocus.
  ///
  /// In it, this message translates to:
  /// **'Core, flessori dell\'anca, tricipiti'**
  String get guidesLSitFocus;

  /// No description provided for @guidesLSitTip.
  ///
  /// In it, this message translates to:
  /// **'Spingi il pavimento, blocca i gomiti e tieni le ginocchia dritte.'**
  String get guidesLSitTip;

  /// No description provided for @guidesLSitDescription.
  ///
  /// In it, this message translates to:
  /// **'Da parallele o a terra, solleva le gambe all\'altezza delle anche e mantieni una L compatta.'**
  String get guidesLSitDescription;

  /// No description provided for @guidesHandstandName.
  ///
  /// In it, this message translates to:
  /// **'Tenuta in verticale'**
  String get guidesHandstandName;

  /// No description provided for @guidesHandstandFocus.
  ///
  /// In it, this message translates to:
  /// **'Spalle, core, equilibrio'**
  String get guidesHandstandFocus;

  /// No description provided for @guidesHandstandTip.
  ///
  /// In it, this message translates to:
  /// **'Allinea polsi, spalle e anche e contrai i glutei.'**
  String get guidesHandstandTip;

  /// No description provided for @guidesHandstandDescription.
  ///
  /// In it, this message translates to:
  /// **'Sali in verticale contro il muro o in equilibrio libero e mantieni una linea lunga con le punte tese.'**
  String get guidesHandstandDescription;

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
  /// **'Progressi'**
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

  /// No description provided for @homeSkillProgressTitle.
  ///
  /// In it, this message translates to:
  /// **'Progressi skill'**
  String get homeSkillProgressTitle;

  /// No description provided for @homeSkillProgressValue.
  ///
  /// In it, this message translates to:
  /// **'{unlocked} / {total}'**
  String homeSkillProgressValue(int unlocked, int total);

  /// No description provided for @homeSkillProgressLabel.
  ///
  /// In it, this message translates to:
  /// **'Skill sbloccate'**
  String get homeSkillProgressLabel;

  /// No description provided for @homeStrengthLevelTitle.
  ///
  /// In it, this message translates to:
  /// **'Livello di forza'**
  String get homeStrengthLevelTitle;

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

  /// No description provided for @profileMaxTestsAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi test massimale'**
  String get profileMaxTestsAdd;

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

  /// No description provided for @profileMaxTestsExerciseLabel.
  ///
  /// In it, this message translates to:
  /// **'Esercizio'**
  String get profileMaxTestsExerciseLabel;

  /// No description provided for @profileMaxTestsExerciseHint.
  ///
  /// In it, this message translates to:
  /// **'es. trazioni o piegamenti'**
  String get profileMaxTestsExerciseHint;

  /// No description provided for @profileMaxTestsValueLabel.
  ///
  /// In it, this message translates to:
  /// **'Risultato'**
  String get profileMaxTestsValueLabel;

  /// No description provided for @profileMaxTestsValueHint.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un valore positivo'**
  String get profileMaxTestsValueHint;

  /// No description provided for @profileMaxTestsUnitLabel.
  ///
  /// In it, this message translates to:
  /// **'Unità'**
  String get profileMaxTestsUnitLabel;

  /// No description provided for @profileMaxTestsUnitHint.
  ///
  /// In it, this message translates to:
  /// **'es. rip, kg, sec'**
  String get profileMaxTestsUnitHint;

  /// No description provided for @profileMaxTestsDateLabel.
  ///
  /// In it, this message translates to:
  /// **'Registrato il {date}'**
  String profileMaxTestsDateLabel(String date);

  /// No description provided for @profileMaxTestsCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get profileMaxTestsCancel;

  /// No description provided for @profileMaxTestsSave.
  ///
  /// In it, this message translates to:
  /// **'Salva test'**
  String get profileMaxTestsSave;

  /// No description provided for @profileMaxTestsSaveSuccess.
  ///
  /// In it, this message translates to:
  /// **'Test massimale salvato'**
  String get profileMaxTestsSaveSuccess;

  /// No description provided for @profileMaxTestsSaveError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile salvare il test: {error}'**
  String profileMaxTestsSaveError(Object error);

  /// No description provided for @profileMaxTestsDefaultUnit.
  ///
  /// In it, this message translates to:
  /// **'ripetizioni'**
  String get profileMaxTestsDefaultUnit;

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

  /// No description provided for @amrapTimerTitle.
  ///
  /// In it, this message translates to:
  /// **'Timer AMRAP'**
  String get amrapTimerTitle;

  /// No description provided for @amrapTimerSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Spingi per quante più serie possibile.'**
  String get amrapTimerSubtitle;

  /// No description provided for @amrapTimerDescription.
  ///
  /// In it, this message translates to:
  /// **'Imposta la durata totale e tieni il tempo rimanente.'**
  String get amrapTimerDescription;

  /// No description provided for @amrapDurationLabel.
  ///
  /// In it, this message translates to:
  /// **'Durata (minuti)'**
  String get amrapDurationLabel;

  /// No description provided for @amrapStartButton.
  ///
  /// In it, this message translates to:
  /// **'Avvia AMRAP'**
  String get amrapStartButton;

  /// No description provided for @amrapResetButton.
  ///
  /// In it, this message translates to:
  /// **'Reimposta AMRAP'**
  String get amrapResetButton;

  /// No description provided for @amrapTimeRemainingLabel.
  ///
  /// In it, this message translates to:
  /// **'Tempo rimanente'**
  String get amrapTimeRemainingLabel;

  /// No description provided for @countdownTitle.
  ///
  /// In it, this message translates to:
  /// **'Timer semplice'**
  String get countdownTitle;

  /// No description provided for @countdownSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Un timer essenziale per qualsiasi intervallo.'**
  String get countdownSubtitle;

  /// No description provided for @countdownDescription.
  ///
  /// In it, this message translates to:
  /// **'Imposta minuti e secondi, poi avvia il timer.'**
  String get countdownDescription;

  /// No description provided for @countdownMinutesLabel.
  ///
  /// In it, this message translates to:
  /// **'Minuti'**
  String get countdownMinutesLabel;

  /// No description provided for @countdownSecondsLabel.
  ///
  /// In it, this message translates to:
  /// **'Secondi'**
  String get countdownSecondsLabel;

  /// No description provided for @countdownStartButton.
  ///
  /// In it, this message translates to:
  /// **'Avvia timer'**
  String get countdownStartButton;

  /// No description provided for @countdownResetButton.
  ///
  /// In it, this message translates to:
  /// **'Ferma timer'**
  String get countdownResetButton;

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

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get userIdTitle => 'ID utente';

  @override
  String get userIdUnavailable => 'Non disponibile';

  @override
  String get featureInDevelopment => 'Funzionalità in sviluppo.';

  @override
  String get maxTestsResultsTitle => 'Risultati e storico';

  @override
  String get maxTestsFilteredHistory => 'Storico nel periodo selezionato';

  @override
  String get maxCategoryAll => 'Tutti';

  @override
  String get maxCategoryPull => 'Tirata';

  @override
  String get maxCategoryPush => 'Spinta';

  @override
  String get maxCategoryLegs => 'Gambe';

  @override
  String get maxCategoryCore => 'Core';

  @override
  String get maxCategorySkills => 'Skill';

  @override
  String get maxCategoryOther => 'Altri';

  @override
  String get maxUnitReps => 'rip.';

  @override
  String get maxUnitSeconds => 's';

  @override
  String get maxUnitMinutes => 'min';

  @override
  String get maxTestsTraineeIntro =>
      'Consulta i risultati registrati dal trainer, confronta i progressi e apri lo storico completo di ogni esercizio.';

  @override
  String get maxTestsTrainerIntro =>
      'Controlla i progressi per esercizio, aggiungi risultati e gestisci le note private del trainer.';

  @override
  String get maxTestsSearch => 'Cerca esercizio';

  @override
  String get maxTestsLatest => 'Ultimo risultato';

  @override
  String get maxTestsChange => 'Variazione';

  @override
  String get maxTestsHistory => 'Storico completo';

  @override
  String get maxTestsNoResults =>
      'Non ci sono ancora risultati. Il tuo trainer può aggiungere i primi test.';

  @override
  String get maxTestsNoMatches =>
      'Nessun risultato con questi filtri. Cambia categoria, ricerca o periodo.';

  @override
  String get maxTestsLoadError =>
      'Impossibile caricare i massimali. Controlla la connessione e riprova.';

  @override
  String get homeMascotAuraSwitch =>
      'Tocca per cambiare aura. La scelta viene salvata su questo dispositivo.';

  @override
  String get homeMascotAuraDragonBall => 'Aura Dragon Ball';

  @override
  String get homeMascotAuraNaruto => 'Aura Naruto';

  @override
  String get trainerFinalWeekLabel => 'Ultima settimana';

  @override
  String get trainerFinalWeekTitle => 'Allievi all’ultima settimana';

  @override
  String get homeMascotTitle => 'Piccolo atleta nella Home';

  @override
  String get homeMascotDescription =>
      'Mostra un personaggio che si allena continuamente nella Home. Disattivato per impostazione predefinita. Salvato su questo dispositivo; rispetta il movimento ridotto.';

  @override
  String exerciseGalleryOpen(String exercise) {
    return 'Visualizza immagini di $exercise';
  }

  @override
  String get exerciseGalleryView => 'Visualizza immagine';

  @override
  String get exerciseGalleryReference =>
      'Illustrazione di riferimento. Segui le indicazioni del tuo trainer.';

  @override
  String get exerciseGalleryUnavailable => 'Immagine non disponibile';

  @override
  String get exerciseGalleryZoomHint => 'Pizzica per ingrandire';

  @override
  String exerciseGalleryPosition(int current, int total) {
    return '$current di $total';
  }

  @override
  String get trainerPaymentAmountInvalid =>
      'Inserisci un importo valido maggiore o uguale a zero.';

  @override
  String get copy => 'Copia';

  @override
  String get copied => 'Copiato';

  @override
  String get privacyPolicyTitle => 'Informativa sulla privacy';

  @override
  String get registrationPrivacyNotice =>
      'Prima di creare un account, leggi come Calisync usa i tuoi dati, inclusi l’accesso di trainer e amministratori e le anteprime delle notifiche.';

  @override
  String get privacySettingsDescription =>
      'Scopri come vengono trattati account, allenamenti, foto e notifiche e come richiedere l’eliminazione.';

  @override
  String get privacyPolicyOpenError =>
      'Impossibile aprire l’informativa. Apri questo indirizzo nel browser:';

  @override
  String get waitingForTrainerTitle => 'In attesa del tuo trainer';

  @override
  String get waitingForTrainerDescription =>
      'Il tuo accesso agli allenamenti non è ancora attivo. Contatta il trainer per concordare o confermare il pagamento. Puoi comunque gestire profilo e account, leggere i feedback e consultare le guide agli esercizi.';

  @override
  String get trainingAccessChecking => 'Verifica accesso agli allenamenti…';

  @override
  String get trainingAccessErrorTitle => 'Impossibile verificare l’accesso';

  @override
  String get trainingAccessErrorDescription =>
      'Controlla la connessione e riprova. Profilo, impostazioni e uscita dall’account restano disponibili.';

  @override
  String get trainingAccessRefresh => 'Verifica di nuovo';

  @override
  String get accountSettingsTitle => 'Impostazioni';

  @override
  String get deleteAccountTitle => 'Elimina account';

  @override
  String get deleteAccountConfirmation =>
      'Eliminare definitivamente account, foto profilo, piani allievo, feedback, progressi e pagamenti? Questa operazione è irreversibile. Gli account e lo storico degli altri utenti vengono conservati.';

  @override
  String get deleteAccountDescription =>
      'Rimuovi definitivamente il tuo account e i dati associati.';

  @override
  String get deleteAccountProgress => 'Eliminazione account…';

  @override
  String get deleteAccountError =>
      'Impossibile completare l’eliminazione. Riprova o contatta dipaoloigor@gmail.com.';

  @override
  String get appTitle => 'Calisync';

  @override
  String get authErrorMessage => 'Errore durante l\'autenticazione';

  @override
  String get navHome => 'Home';

  @override
  String get navGuides => 'Guide';

  @override
  String get navProfile => 'Profilo';

  @override
  String get navTerminology => 'Terminologia';

  @override
  String get settingsThemeTitle => 'Tema';

  @override
  String get themeDefaultLabel => 'Predefinito';

  @override
  String get themeBlackLabel => 'Nero';

  @override
  String get themePinkLabel => 'Rosa';

  @override
  String get themeRedLabel => 'Rosso';

  @override
  String get themeBlueLabel => 'Blu';

  @override
  String get themeYellowLabel => 'Giallo';

  @override
  String get themePurpleLabel => 'Viola';

  @override
  String get themeOrangeLabel => 'Arancione';

  @override
  String get onboardingTitleOne => 'Costruisci forza.\nControlla il movimento.';

  @override
  String get onboardingDescriptionOne =>
      'Il tuo allenamento calistenico, tutto in un posto.';

  @override
  String get onboardingTitleTwo => 'Guarda i tuoi\nprogressi.';

  @override
  String get onboardingDescriptionTwo =>
      'Registra ripetizioni, tenute e ogni passo avanti.';

  @override
  String get onboardingTitleThree => 'Fai del movimento\nun’abitudine.';

  @override
  String get onboardingDescriptionThree =>
      'La tua prossima sessione, pronta quando vuoi.';

  @override
  String get onboardingSkip => 'Salta';

  @override
  String get onboardingBack => 'Indietro';

  @override
  String get onboardingNext => 'Continua';

  @override
  String get guidesTitle => 'Skill';

  @override
  String get guidesSubtitle =>
      'Esplora tecnica, focus e consigli del coach per ogni skill.';

  @override
  String get guidesLoadError =>
      'Impossibile caricare le guide delle skill al momento.';

  @override
  String get guidesPrimaryFocus => 'Focus principale';

  @override
  String get guidesCoachTip => 'Consiglio del coach';

  @override
  String get difficultyBeginner => 'Principiante';

  @override
  String get difficultyIntermediate => 'Intermedio';

  @override
  String get difficultyAdvanced => 'Avanzato';

  @override
  String get homeLoadErrorTitle => 'Impossibile caricare gli allenamenti';

  @override
  String get retry => 'Riprova';

  @override
  String get homeCoachTipTitle => 'Consiglio del coach';

  @override
  String get homeCoachTipPlaceholder =>
      'Qui troverai l\'ultimo consiglio del tuo coach.';

  @override
  String homeGreeting(String name) {
    return 'Ciao, $name!';
  }

  @override
  String get homeMotivationalSentence1 => 'PRONTO A SUPERARTI?';

  @override
  String get homeMotivationalSentence2 => 'OGGI SI MIGLIORA!';

  @override
  String get homeMotivationalSentence3 => 'PRONTO A DARE IL MASSIMO?';

  @override
  String get homeMotivationalSentence4 => 'IL MEGLIO DEVE ANCORA VENIRE';

  @override
  String get homeMotivationalSentence5 => 'PRONTO A FARE PROGRESSI?';

  @override
  String get homeMotivationalSentence6 => 'LA TUA PROSSIMA SFIDA TI ASPETTA';

  @override
  String get homeMotivationalSentence7 => 'OGGI PUOI FARE DI PIÙ';

  @override
  String get homeMotivationalSentence8 => 'NON SMETTERE DI MIGLIORARE';

  @override
  String get homeMotivationalSentence9 => 'COSTRUISCI LA TUA VERSIONE MIGLIORE';

  @override
  String get homeMotivationalSentence10 => 'UN PASSO AVANTI, OGNI GIORNO';

  @override
  String get homeViewStats => 'Vedi statistiche';

  @override
  String get homeProgressTitle => 'Progressi mensili';

  @override
  String get homeProgressWorkoutsLabel => 'Allenamenti';

  @override
  String get homeProgressTimeTrainedLabel => 'Tempo di allenamento';

  @override
  String homeProgressTimeValue(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get homeProgressNoPlan =>
      'Nessun piano di allenamento disponibile al momento.';

  @override
  String get homePlanStatsDaysLabel => 'Giorni';

  @override
  String get homePlanStatsExercisesLabel => 'Esercizi';

  @override
  String get workoutPlanTitle => 'Piano di allenamento';

  @override
  String get workoutPlanPdfView => 'Visualizza PDF del trainer';

  @override
  String get workoutPlanPdfError =>
      'Impossibile caricare il PDF della scheda. Riprova.';

  @override
  String get traineeFeedbackTitle => 'I miei feedback';

  @override
  String get traineeFeedbackSubtitle =>
      'Racconta al tuo coach come ti senti e come procede il piano.';

  @override
  String get traineeFeedbackQuestionLabel => 'Come è andato l\'allenamento?';

  @override
  String get traineeFeedbackQuestionHint =>
      'Condividi cosa sta andando bene o cosa richiede attenzione.';

  @override
  String get traineeFeedbackFeelingLabel => 'Come ti senti oggi?';

  @override
  String get traineeFeedbackFeelingHint =>
      'Scegli un\'opzione prima di inviare il feedback.';

  @override
  String get traineeFeedbackFeelingVeryBad => 'Molto male';

  @override
  String get traineeFeedbackFeelingBad => 'Male';

  @override
  String get traineeFeedbackFeelingOk => 'Così così';

  @override
  String get traineeFeedbackFeelingGood => 'Bene';

  @override
  String get traineeFeedbackFeelingVeryGood => 'Molto bene';

  @override
  String get traineeFeedbackSubmit => 'Invia feedback';

  @override
  String get traineeFeedbackSubmitted =>
      'Feedback salvato. Lo condivideremo con il tuo coach.';

  @override
  String get traineeFeedbackLoadFailed =>
      'Impossibile caricare il feedback in questo momento.';

  @override
  String get traineeFeedbackDelete => 'Elimina feedback';

  @override
  String get traineeFeedbackDeleteTitle => 'Eliminare il feedback?';

  @override
  String get traineeFeedbackDeleteMessage =>
      'Eliminare questo feedback? L\'operazione non può essere annullata.';

  @override
  String get bugReportSettingsTitle => 'Segnala un problema';

  @override
  String get bugReportSettingsSubtitle =>
      'Hai trovato un bug? Aiutaci a risolverlo.';

  @override
  String get bugReportTitle => 'Segnalazione bug';

  @override
  String get bugReportTitleLabel => 'Titolo';

  @override
  String get bugReportTitleHint => 'Riassumi il problema';

  @override
  String get bugReportDescriptionLabel => 'Descrizione';

  @override
  String get bugReportDescriptionHint => 'Descrivi cosa è successo';

  @override
  String get bugReportStepsLabel => 'Passaggi per riprodurlo (facoltativo)';

  @override
  String get bugReportStepsHint => 'Indica i passaggi che hai seguito';

  @override
  String get bugReportExpectedResultLabel => 'Risultato atteso (facoltativo)';

  @override
  String get bugReportExpectedResultHint =>
      'Che cosa ti aspettavi che succedesse?';

  @override
  String get bugReportActualResultLabel => 'Risultato ottenuto (facoltativo)';

  @override
  String get bugReportActualResultHint => 'Che cosa è successo invece?';

  @override
  String get bugReportSubmit => 'Invia segnalazione';

  @override
  String get bugReportSubmitted =>
      'Segnalazione inviata. Grazie per averci aiutato.';

  @override
  String bugReportSubmitError(String error) {
    return 'Impossibile inviare la segnalazione: $error';
  }

  @override
  String get bugReportRequired => 'Compila questo campo.';

  @override
  String get adminBugReportsTitle => 'Segnalazioni bug';

  @override
  String get adminBugReportsSubtitle =>
      'Consulta e gestisci i problemi segnalati dagli utenti.';

  @override
  String get adminBugReportsSearch => 'Cerca segnalazioni';

  @override
  String get adminBugReportsEmpty => 'Non ci sono segnalazioni.';

  @override
  String get adminBugReportsNoResults => 'Nessuna segnalazione corrispondente.';

  @override
  String adminBugReportsLoadError(String error) {
    return 'Impossibile caricare le segnalazioni\n$error';
  }

  @override
  String get adminBugReportDetailTitle => 'Dettagli della segnalazione';

  @override
  String get adminBugReportReporter => 'ID segnalante';

  @override
  String get adminBugReportSubmittedAt => 'Data di invio';

  @override
  String get adminBugReportStatus => 'Stato';

  @override
  String get adminBugReportStatusOpen => 'Aperta';

  @override
  String get adminBugReportStatusInProgress => 'In lavorazione';

  @override
  String get adminBugReportStatusResolved => 'Risolta';

  @override
  String get adminBugReportDescription => 'Descrizione';

  @override
  String get adminBugReportReproductionSteps => 'Passaggi per riprodurlo';

  @override
  String get adminBugReportExpectedBehavior => 'Risultato atteso';

  @override
  String get adminBugReportActualBehavior => 'Risultato ottenuto';

  @override
  String get adminBugReportPlatform => 'Piattaforma';

  @override
  String get adminBugReportAppVersion => 'Versione app';

  @override
  String get adminBugReportUnavailable => 'Non specificato';

  @override
  String get adminBugReportChangeStatus => 'Modifica stato';

  @override
  String get adminBugReportStatusUpdated =>
      'Stato della segnalazione aggiornato.';

  @override
  String adminBugReportUpdateFailed(String error) {
    return 'Impossibile aggiornare la segnalazione: $error';
  }

  @override
  String get adminBugReportDelete => 'Elimina segnalazione';

  @override
  String get adminBugReportDeleteTitle => 'Eliminare la segnalazione?';

  @override
  String get adminBugReportDeleteMessage =>
      'La segnalazione verrà eliminata definitivamente. L\'operazione non può essere annullata.';

  @override
  String get adminBugReportDeleted => 'Segnalazione eliminata.';

  @override
  String adminBugReportDeleteFailed(String error) {
    return 'Impossibile eliminare la segnalazione: $error';
  }

  @override
  String get refresh => 'Aggiorna';

  @override
  String get homeEmptyTitle => 'Nessun allenamento disponibile';

  @override
  String get homeEmptyDescription =>
      'Contatta il tuo coach per ricevere una nuova scheda.';

  @override
  String get homePlanDefaultTitle => 'Piano di allenamento';

  @override
  String get homePlanLatestLabel => 'Ultimo piano';

  @override
  String homePlanStartedLabel(String date) {
    return 'Iniziato il $date';
  }

  @override
  String get unauthenticated => 'Utente non autenticato';

  @override
  String get defaultExerciseName => 'Esercizio';

  @override
  String get trainingHeaderExercise => 'Esercizio';

  @override
  String get trainingHeaderExercises => 'Esercizi';

  @override
  String get trainingHeaderSets => 'Serie';

  @override
  String get trainingHeaderReps => 'Ripetizioni';

  @override
  String get trainingTodayTitle => 'Allenamento di oggi';

  @override
  String get trainingStartWorkout => 'Inizia allenamento';

  @override
  String get trainingMarkAsCompleted => 'Segna come completato';

  @override
  String get trainingWorkoutCompleted => 'Allenamento completato';

  @override
  String get trainingIncompleteTitle => 'Attenzione';

  @override
  String trainingIncompleteMessage(int count) {
    return 'Non tutti gli esercizi sono stati completati ($count).';
  }

  @override
  String get trainingIncompleteOptionIgnore =>
      'Ignora esercizi non completati e segna come completato';

  @override
  String get trainingIncompleteOptionCompleteAll =>
      'Segna tutti gli esercizi e allenamento come completati';

  @override
  String trainingDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get trainingCompletionSaved => 'Allenamento aggiornato';

  @override
  String trainingCompletionError(Object error) {
    return 'Impossibile aggiornare l\'allenamento: $error';
  }

  @override
  String get trainingCompletionUnavailable =>
      'Impossibile aggiornare questo giorno di allenamento.';

  @override
  String get trainingExerciseCompletionSaved => 'Esercizio aggiornato';

  @override
  String trainingExerciseCompletionError(Object error) {
    return 'Impossibile aggiornare l\'esercizio: $error';
  }

  @override
  String get trainingExerciseCompletionUnavailable =>
      'Impossibile aggiornare questo esercizio.';

  @override
  String get trainingExerciseNotesTitle => 'Note';

  @override
  String get trainingExerciseYourNotesLabel => 'Le tue note';

  @override
  String get trainingExerciseSaveNotes => 'Salva note';

  @override
  String get trainingExerciseResolvedLabel => 'Contrassegna come risolto';

  @override
  String get trainingExerciseNotesSaved => 'Note aggiornate';

  @override
  String trainingExerciseNotesError(Object error) {
    return 'Impossibile aggiornare le note: $error';
  }

  @override
  String get trainingExerciseFeedbackTitle => 'Feedback esercizio';

  @override
  String get trainingExerciseFeedbackHint =>
      'Aggiungi un feedback per questo esercizio completato.';

  @override
  String get trainingExerciseFeedbackLabel => 'Come è andato questo esercizio?';

  @override
  String get trainingExerciseSaveFeedback => 'Salva feedback';

  @override
  String get trainingExerciseFeedbackSaved => 'Feedback esercizio aggiornato';

  @override
  String trainingExerciseFeedbackError(Object error) {
    return 'Impossibile aggiornare il feedback esercizio: $error';
  }

  @override
  String get trainingExerciseRepsTitle => 'Ripetizioni completate';

  @override
  String get trainingExerciseRepsHint =>
      'Conta le ripetizioni completate, quindi salva il risultato.';

  @override
  String get trainingExerciseRepsDecrease => 'Diminuisci ripetizioni';

  @override
  String get trainingExerciseRepsIncrease => 'Aumenta ripetizioni';

  @override
  String trainingExerciseRepsCount(int count) {
    return '$count ripetizioni completate';
  }

  @override
  String get trainingExerciseSaveReps => 'Salva reps';

  @override
  String get trainingExerciseRepsSaved => 'Ripetizioni aggiornate';

  @override
  String trainingExerciseRepsError(Object error) {
    return 'Impossibile aggiornare le ripetizioni: $error';
  }

  @override
  String logoutError(Object error) {
    return 'Errore durante il logout: $error';
  }

  @override
  String get profileFallbackName => 'Utente';

  @override
  String get userNotFound => 'Utente non trovato nel database';

  @override
  String get profileLoadError => 'Errore nel caricamento dati';

  @override
  String get profileNoData => 'Nessun dato disponibile';

  @override
  String get profileEmailUnavailable => 'Email non disponibile';

  @override
  String get profileStatusActive => 'Account attivo';

  @override
  String get profileStatusInactive => 'Account inattivo';

  @override
  String get profilePlanActive => 'Piano attivo';

  @override
  String get profilePlanExpired => 'Piano scaduto';

  @override
  String get profileUsername => 'Username';

  @override
  String get profileNotSet => 'Non impostato';

  @override
  String get profileWeight => 'Peso';

  @override
  String profileWeightValue(String weight) {
    return '$weight kg';
  }

  @override
  String get profileHeight => 'Altezza';

  @override
  String profileHeightValue(String height) {
    return '$height cm';
  }

  @override
  String get profileMaxTestsTitle => 'Test massimali';

  @override
  String get profileMaxTestsPeriodLabel => 'Periodo';

  @override
  String get profileMaxTestsPeriodMonth => 'Ultimo mese';

  @override
  String get profileMaxTestsPeriodHalfYear => 'Ultimi 6 mesi';

  @override
  String get profileMaxTestsPeriodYear => 'Ultimo anno';

  @override
  String get profileMaxTestsPeriodAll => 'Tutto il periodo';

  @override
  String get profileMaxTestsBestPeriodLabel =>
      'Migliore nel periodo selezionato';

  @override
  String get profileMaxTestsRefresh => 'Aggiorna';

  @override
  String profileMaxTestsHistoryDeltaLabel(String delta) {
    return 'Variazione $delta';
  }

  @override
  String get profileMaxTestsHistoryFirstEntry => 'Prima registrazione';

  @override
  String get profileMaxTestsBestLabel => 'Miglior risultato';

  @override
  String get profileEdit => 'Modifica profilo';

  @override
  String get profileEditSubtitle => 'Aggiorna le tue informazioni personali';

  @override
  String get profileSettingsSubtitle => 'Tema, privacy e gestione dell’account';

  @override
  String get profileLanguageSettingsTitle => 'Lingua';

  @override
  String get profileLanguageSettingsSubtitle => 'Scegli la lingua dell\'app';

  @override
  String get profileEditTitle => 'Modifica profilo';

  @override
  String get profileEditFullNameLabel => 'Nome completo';

  @override
  String get profileEditFullNameHint => 'Come vuoi essere chiamato?';

  @override
  String get profileEditWeightLabel => 'Peso';

  @override
  String get profileEditWeightHint => 'Inserisci il tuo peso in kg (opzionale)';

  @override
  String get profileEditWeightInvalid => 'Inserisci un peso valido e positivo.';

  @override
  String get profileEditHeightLabel => 'Altezza';

  @override
  String get profileEditHeightHint =>
      'Inserisci la tua altezza in cm (opzionale)';

  @override
  String get profileEditHeightInvalid =>
      'Inserisci un\'altezza valida e positiva.';

  @override
  String get profilePhotoEdit => 'Cambia foto';

  @override
  String get profileEditCancel => 'Annulla';

  @override
  String get profileEditSave => 'Salva modifiche';

  @override
  String get profileEditSuccess => 'Profilo aggiornato correttamente';

  @override
  String profileEditError(Object error) {
    return 'Impossibile aggiornare il profilo: $error';
  }

  @override
  String get logout => 'Logout';

  @override
  String get languageSystemLabel => 'Sistema';

  @override
  String get languageEnglishLabel => 'Inglese';

  @override
  String get languageItalianLabel => 'Italiano';

  @override
  String get languageSpanishLabel => 'Spagnolo';

  @override
  String redirectError(Object error) {
    return 'Errore durante il reindirizzamento: $error';
  }

  @override
  String linkError(Object error) {
    return 'Errore collegamento: $error';
  }

  @override
  String get missingFieldsError => 'Compila tutti i campi richiesti.';

  @override
  String get passwordMismatch => 'Le password non coincidono.';

  @override
  String get invalidCredentials => 'Email o password non corrette.';

  @override
  String get emailNotConfirmed =>
      'Conferma il tuo indirizzo email prima di accedere.';

  @override
  String get emailAlreadyRegistered =>
      'Esiste già un account con questo indirizzo email.';

  @override
  String get weakPassword =>
      'La password non soddisfa i requisiti di sicurezza.';

  @override
  String get invalidEmail => 'Inserisci un indirizzo email valido.';

  @override
  String get signupDisabled => 'La registrazione non è al momento disponibile.';

  @override
  String get authTooManyRequests =>
      'Hai effettuato troppe richieste. Riprova più tardi.';

  @override
  String get authServiceUnavailable =>
      'Il servizio non è al momento disponibile. Riprova più tardi.';

  @override
  String get authOperationFailed =>
      'Non è stato possibile completare l\'operazione. Riprova.';

  @override
  String get signupEmailCheck =>
      'Registrazione completata! Controlla la tua email per confermare l\'account.';

  @override
  String unexpectedError(Object error) {
    return 'Errore inatteso: $error';
  }

  @override
  String get loginGreeting => 'Pronto per la prossima sessione?';

  @override
  String get signupGreeting => 'Crea il tuo account per iniziare.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Conferma password';

  @override
  String get loginButton => 'Accedi';

  @override
  String get signupButton => 'Crea account';

  @override
  String get noAccountPrompt => 'Non hai un account? Registrati';

  @override
  String get existingAccountPrompt => 'Hai già un account? Accedi';

  @override
  String get forgotPasswordLink => 'Password dimenticata?';

  @override
  String passwordResetEmailSent(String email) {
    return 'Link per reimpostare la password inviato a $email. Controlla la posta.';
  }

  @override
  String get passwordResetEmailMissing =>
      'Inserisci la tua email per ricevere il link di reimpostazione.';

  @override
  String get passwordResetDialogTitle => 'Scegli una nuova password';

  @override
  String get passwordResetDialogDescription =>
      'Inserisci una nuova password per mettere al sicuro il tuo account.';

  @override
  String get passwordResetNewPasswordLabel => 'Nuova password';

  @override
  String get passwordResetConfirmPasswordLabel => 'Conferma nuova password';

  @override
  String get passwordResetMismatch => 'Le password non coincidono.';

  @override
  String get passwordResetSuccess =>
      'Password aggiornata con successo. Puoi continuare a usare l\'app.';

  @override
  String get passwordResetSubmit => 'Aggiorna password';

  @override
  String get cancel => 'Annulla';

  @override
  String get add => 'Aggiungi';

  @override
  String get start => 'Avvia';

  @override
  String get timerTitle => 'Timer';

  @override
  String get timerModeAmrap => 'AMRAP';

  @override
  String get timerModeEmom => 'EMOM';

  @override
  String get timerModeForTime => 'FOR TIME';

  @override
  String get timerModeTabata => 'TABATA';

  @override
  String get timerWorkoutDuration => 'Durata (min)';

  @override
  String get timerWorkoutUnlimited => 'Più a lungo possibile';

  @override
  String get timerWorkoutElapsed => 'Tempo trascorso';

  @override
  String timerWorkoutMinute(int minute) {
    return 'Minuto $minute';
  }

  @override
  String get timerTabataWork => 'Lavoro';

  @override
  String get timerTabataRest => 'Recupero';

  @override
  String get timerWorkoutFinish => 'Termina';

  @override
  String get timerWorkoutComplete => 'COMPLETATO';

  @override
  String get timerPhasePrepare => 'PREPARATI';

  @override
  String get timerAmrapReps => 'Ripetizioni';

  @override
  String get timerAmrapAddRep => 'Aggiungi';

  @override
  String get timerChangeModeTitle => 'Cambiare timer?';

  @override
  String get timerChangeModeWarning =>
      'Se cambi timer perderai i progressi del timer attuale.';

  @override
  String get timerChangeModeConfirm => 'Cambia timer';

  @override
  String get timerPhaseWork => 'LAVORO';

  @override
  String get timerPhaseRest => 'RECUPERO';

  @override
  String get timerRoundsLabel => 'Round';

  @override
  String get timerControlPause => 'PAUSA';

  @override
  String get timerControlPlay => 'AVVIA';

  @override
  String get timerControlReset => 'RESET';

  @override
  String weekNumber(int week) {
    return 'Settimana $week';
  }

  @override
  String get defaultWorkoutTitle => 'Allenamento';

  @override
  String get terminologyTitle => 'Terminologia';

  @override
  String get traineeFeedbackAnsweredTitle => 'Feedback con risposta';

  @override
  String get traineeFeedbackAnsweredEmpty =>
      'Non hai ancora feedback con risposta.';

  @override
  String get traineeFeedbackAnsweredChip => 'Risposto';

  @override
  String get traineeFeedbackSentAt => 'Inviato:';

  @override
  String get traineeFeedbackAnsweredAt => 'Risposto:';

  @override
  String get traineeFeedbackTrainerAnswer => 'Risposta del trainer';

  @override
  String get traineeFeedbackLastAnsweredTitle => 'Ultima risposta del trainer';

  @override
  String get traineeFeedbackYourMessage => 'Il tuo messaggio';

  @override
  String get traineeFeedbackAnsweredAtHome => 'Risposto il';

  @override
  String get trainerMenuGroup => 'TRAINER';

  @override
  String get trainerNavDashboard => 'Dashboard trainer';

  @override
  String get trainerNavTrainees => 'I miei allievi';

  @override
  String get trainerNavFeedback => 'Feedback degli allievi';

  @override
  String get trainerNavPayments => 'Pagamenti allievi';

  @override
  String get trainerWorkspaceTitle => 'Area trainer';

  @override
  String get trainerWorkspaceSubtitle =>
      'I tuoi atleti assegnati e le loro attività recenti.';

  @override
  String get trainerAssignedTrainees => 'Allievi assegnati';

  @override
  String get trainerUnreadFeedback => 'Feedback non letti';

  @override
  String get trainerActivePlans => 'Piani attivi';

  @override
  String get trainerOverdue => 'Scaduto';

  @override
  String get trainerTraineesTitle => 'Allievi';

  @override
  String get trainerNoAssignedTrainees =>
      'Non ti è ancora stato assegnato alcun allievo.';

  @override
  String get trainerStatusActive => 'Attivo';

  @override
  String get trainerPlanProgress => 'Progresso del piano';

  @override
  String get trainerOpenProgram => 'Apri programma';

  @override
  String get trainerSearchTrainees => 'Cerca allievi';

  @override
  String trainerAssignedCount(int count) {
    return '$count allievi assegnati';
  }

  @override
  String get trainerNoMatchingTrainees => 'Nessun allievo corrispondente.';

  @override
  String get trainerFilterAll => 'Tutti';

  @override
  String get trainerFilterUnread => 'Non letti';

  @override
  String get trainerFilterAnswered => 'Risposti';

  @override
  String get trainerNoFeedbackInView => 'Nessun feedback in questa vista.';

  @override
  String get trainerStatusRead => 'Letto';

  @override
  String get trainerStatusUnread => 'Non letto';

  @override
  String get trainerYourAnswer => 'La tua risposta';

  @override
  String get trainerReplyHint => 'Rispondi all’allievo';

  @override
  String get trainerSendAnswer => 'Invia risposta';

  @override
  String get trainerMarkUnread => 'Segna come non letto';

  @override
  String get trainerMarkRead => 'Segna come letto';

  @override
  String get trainerFeedbackMarkedRead =>
      'Segnato come letto. Puoi ancora trovarlo in Tutti.';

  @override
  String get trainerFeedbackMarkedUnread => 'Segnato come non letto.';

  @override
  String get trainerAnswerRequired => 'Scrivi prima una risposta.';

  @override
  String get trainerPaid => 'Pagato';

  @override
  String get trainerReceived => 'Incassato';

  @override
  String get trainerMonthlyAmount => 'Importo mensile';

  @override
  String get trainerPaymentNotes => 'Note sul pagamento';

  @override
  String get trainerAppAccessActive => 'Accesso all’app attivo';

  @override
  String trainerLoadToolsError(String error) {
    return 'Impossibile caricare gli strumenti trainer\n$error';
  }

  @override
  String get trainerRetry => 'Riprova';

  @override
  String get trainerOverviewTab => 'Panoramica';

  @override
  String get trainerPlanTab => 'Piano';

  @override
  String get trainerHistoryTab => 'Cronologia';

  @override
  String trainerLoadProgramError(String error) {
    return 'Impossibile caricare il programma\n$error';
  }

  @override
  String get trainerAthleteData => 'Dati atleta';

  @override
  String get trainerNameLabel => 'Nome';

  @override
  String get trainerWeightLabel => 'Peso';

  @override
  String get trainerPaymentLabel => 'Pagamento';

  @override
  String get trainerOnTime => 'In regola';

  @override
  String get trainerProgressLabel => 'Progresso';

  @override
  String get trainerCoachTip => 'Consiglio del coach';

  @override
  String get trainerCoachTipHint => 'Visibile all’allievo nell’app';

  @override
  String get trainerPrivateNotes => 'Note private del trainer';

  @override
  String get trainerSave => 'Salva';

  @override
  String get trainerCoachFieldsSaved => 'Consiglio e note private salvati.';

  @override
  String get trainerTrainingCalendar => 'Calendario allenamenti';

  @override
  String get trainerNoScheduledDays => 'Nessun giorno programmato.';

  @override
  String trainerShowMoreDays(int count) {
    return 'Mostra altri $count giorni';
  }

  @override
  String get trainerShowLessDays => 'Mostra meno giorni';

  @override
  String get trainerFeedbackTitle => 'Feedback';

  @override
  String get trainerNoFeedbackYet => 'Nessun feedback.';

  @override
  String get trainerCreateWorkoutPlan => 'Crea scheda di allenamento';

  @override
  String get trainerImportPdf => 'Importa PDF';

  @override
  String get trainerImportingPdf => 'Lettura PDF…';

  @override
  String get trainerPdfPreviewTitle => 'Controlla il piano importato';

  @override
  String get trainerPdfPlanName => 'Nome del piano';

  @override
  String trainerPdfSummary(int days, int exercises) {
    return 'Rilevati $days giorni e $exercises esercizi';
  }

  @override
  String trainerPdfDaySummary(String week, String day, int exercises) {
    return 'Settimana $week · Giorno $day: $exercises esercizi';
  }

  @override
  String get trainerPdfConfirmImport => 'Importa piano';

  @override
  String get trainerPdfImportSuccess =>
      'Scheda di allenamento importata correttamente.';

  @override
  String get trainerPdfImportFailed =>
      'Impossibile importare il PDF. Verifica che contenga tabelle di allenamento GIORNO A–G.';

  @override
  String get trainerPdfFileUnavailable =>
      'PDF non valido o superiore a 25 MB. Seleziona un altro file.';

  @override
  String get trainerNoPlans => 'Nessun piano creato.';

  @override
  String get trainerWorkoutPlanFallback => 'Scheda di allenamento';

  @override
  String get trainerMaxTests => 'Test massimali';

  @override
  String get trainerNoMaxTests => 'Nessun test massimale.';

  @override
  String get trainerAddMaxTest => 'Aggiungi test massimale';

  @override
  String get trainerMaxTestExercise => 'Esercizio';

  @override
  String get trainerMaxTestExerciseRequired => 'Seleziona un esercizio.';

  @override
  String get trainerMaxTestOther => 'Altro';

  @override
  String get trainerMaxTestCustomExerciseName =>
      'Nome esercizio personalizzato';

  @override
  String get trainerMaxTestValue => 'Risultato';

  @override
  String get trainerMaxTestValueInvalid =>
      'Inserisci un valore maggiore di zero.';

  @override
  String get trainerMaxTestUnit => 'Unità';

  @override
  String get trainerMaxTestDate => 'Data del test';

  @override
  String get trainerMaxTestSaved => 'Test massimale salvato.';

  @override
  String get trainerMaxTestPrivateNotesHint =>
      'Visibili solo ai trainer assegnati';

  @override
  String get trainerEditMaxTestNotes => 'Modifica note private';

  @override
  String get trainerMaxTestNotesUpdated => 'Note del massimale aggiornate.';

  @override
  String trainerMaxTestSaveError(String error) {
    return 'Impossibile salvare il test massimale: $error';
  }

  @override
  String get trainerDeleteMaxTest => 'Elimina test massimale';

  @override
  String get trainerDeleteMaxTestTitle => 'Eliminare il test massimale?';

  @override
  String get trainerDeleteMaxTestMessage =>
      'Il risultato verrà eliminato definitivamente.';

  @override
  String get trainerMaxTestDeleted => 'Test massimale eliminato.';

  @override
  String trainerMaxTestDeleteError(String error) {
    return 'Impossibile eliminare il test massimale: $error';
  }

  @override
  String get trainerWeightHistory => 'Cronologia peso';

  @override
  String get trainerNoWeightEntries => 'Nessuna registrazione del peso.';

  @override
  String get trainerHeightHistory => 'Cronologia altezza';

  @override
  String get trainerNoHeightEntries => 'Nessuna registrazione dell\'altezza.';

  @override
  String get trainerPaymentHistory => 'Cronologia pagamenti';

  @override
  String get trainerNoPayments => 'Nessun pagamento.';

  @override
  String get trainerTrainingDayFallback => 'Giorno di allenamento';

  @override
  String trainerExercisesCompleted(int completed, int total) {
    return '$completed/$total esercizi completati';
  }

  @override
  String get trainerPlanCompleted => 'Completato';

  @override
  String get trainerExerciseFallback => 'Esercizio';

  @override
  String get trainerEditExerciseTitle => 'Modifica esercizio';

  @override
  String get trainerExerciseName => 'Nome esercizio';

  @override
  String get trainerExerciseDuration => 'Durata';

  @override
  String get trainerExerciseNotes => 'Note del trainer';

  @override
  String get trainerExerciseUpdated => 'Esercizio aggiornato correttamente.';

  @override
  String get trainerExerciseNameRequired => 'Inserisci il nome dell’esercizio.';

  @override
  String get trainerExerciseDurationInvalid =>
      'Inserisci una durata valida in minuti.';

  @override
  String trainerMinutesDuration(String minutes) {
    return '$minutes min';
  }

  @override
  String trainerExerciseResult(String minutes, String reps) {
    return '$minutes min · $reps rip.';
  }

  @override
  String trainerTraineeNote(String notes) {
    return 'Allievo: $notes';
  }

  @override
  String trainerTraineeExerciseFeedback(String comment) {
    return 'Commento sull’esercizio: $comment';
  }

  @override
  String get trainerDeletePlanTitle => 'Eliminare il piano?';

  @override
  String trainerDeletePlanMessage(String title) {
    return 'Eliminare “$title”?';
  }

  @override
  String get trainerCancel => 'Annulla';

  @override
  String get trainerDelete => 'Elimina';

  @override
  String get trainerDeleteFeedback => 'Elimina feedback';

  @override
  String get trainerDeleteFeedbackTitle => 'Eliminare il feedback?';

  @override
  String trainerDeleteFeedbackMessage(String name) {
    return 'Eliminare questo feedback di $name? L\'operazione non può essere annullata.';
  }

  @override
  String get trainerNewPlan => 'Nuova scheda di allenamento';

  @override
  String get trainerPlanName => 'Nome del piano';

  @override
  String get trainerNotes => 'Note';

  @override
  String get trainerCreate => 'Crea';

  @override
  String get adminMenuGroup => 'AMMINISTRAZIONE';

  @override
  String get adminNavConsole => 'Console amministratore';

  @override
  String get adminOverview => 'Panoramica';

  @override
  String get adminUsers => 'Utenti';

  @override
  String get adminAssignments => 'Assegnazioni';

  @override
  String get adminTotalUsers => 'Utenti totali';

  @override
  String get adminTrainees => 'Allievi';

  @override
  String get adminTrainers => 'Trainer';

  @override
  String get adminSuspended => 'Sospesi';

  @override
  String get adminNoUsers => 'Nessun utente corrispondente.';

  @override
  String get adminNoAssignments => 'Nessuna assegnazione trainer.';

  @override
  String get adminSearchAssignments => 'Cerca assegnazioni';

  @override
  String get adminSearchUsers => 'Cerca utenti';

  @override
  String get adminRoleAdmin => 'Amministratore';

  @override
  String get adminRoleTrainer => 'Trainer';

  @override
  String get adminRoleTrainee => 'Allievo';

  @override
  String get adminAccessActive => 'Accesso attivo';

  @override
  String get adminAccessSuspended => 'Accesso sospeso';

  @override
  String get adminCurrentAccount => 'Il tuo account';

  @override
  String get adminGrantTrainer => 'Assegna ruolo trainer';

  @override
  String get adminRevokeTrainer => 'Revoca ruolo trainer';

  @override
  String get adminSuspend => 'Sospendi accesso';

  @override
  String get adminRestoreAccess => 'Ripristina accesso';

  @override
  String get adminConfirmSuspendTitle => 'Sospendere l’account?';

  @override
  String adminConfirmSuspendMessage(String name) {
    return 'Sospendere l’accesso all’app per $name?';
  }

  @override
  String get adminConfirmRevokeTitle => 'Revocare il ruolo trainer?';

  @override
  String adminConfirmRevokeMessage(String name) {
    return 'Revocare l’accesso trainer a $name? Le assegnazioni verranno rimosse.';
  }

  @override
  String get adminCancel => 'Annulla';

  @override
  String get adminConfirm => 'Conferma';

  @override
  String get adminAssignmentTrainer => 'Trainer';

  @override
  String get adminAssignmentTrainee => 'Allievo';

  @override
  String get adminAddAssignment => 'Aggiungi assegnazione';

  @override
  String get adminRemoveAssignment => 'Rimuovi assegnazione';

  @override
  String adminLoadError(String error) {
    return 'Impossibile caricare gli strumenti amministratore\n$error';
  }

  @override
  String adminActionFailed(String error) {
    return 'Operazione amministratore non riuscita: $error';
  }

  @override
  String get authWelcomeTitle => 'Bentornato.';

  @override
  String get authShowPassword => 'Mostra password';

  @override
  String get authHidePassword => 'Nascondi password';
}

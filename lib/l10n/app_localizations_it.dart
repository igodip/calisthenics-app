// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

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
  String get onboardingTitleOne => 'Allenati meglio';

  @override
  String get onboardingDescriptionOne =>
      'Segui allenamenti guidati creati per il tuo piano di calisthenics.';

  @override
  String get onboardingTitleTwo => 'Monitora i progressi';

  @override
  String get onboardingDescriptionTwo =>
      'Registra serie, ripetizioni e note per vedere i miglioramenti.';

  @override
  String get onboardingTitleThree => 'Rimani costante';

  @override
  String get onboardingDescriptionThree =>
      'Mantieni il ritmo con accesso rapido alla prossima sessione.';

  @override
  String get onboardingSkip => 'Salta';

  @override
  String get onboardingBack => 'Indietro';

  @override
  String get onboardingNext => 'Avanti';

  @override
  String get onboardingGetStarted => 'Inizia';

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
      'Nessun workout plan disponibile al momento.';

  @override
  String get homePlanStatsTitle => 'Statistiche del piano';

  @override
  String get homePlanStatsDaysLabel => 'Giorni';

  @override
  String get homePlanStatsExercisesLabel => 'Esercizi';

  @override
  String homePlanStatsCompletionValue(int progress) {
    return '$progress% completato';
  }

  @override
  String get workoutPlanTitle => 'Piano di allenamento';

  @override
  String get traineeFeedbackTitle => 'Feedback atleta';

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
  String get refresh => 'Aggiorna';

  @override
  String get homeEmptyTitle => 'Nessun allenamento disponibile';

  @override
  String get homeEmptyDescription =>
      'Contatta il tuo coach per ricevere una nuova scheda.';

  @override
  String get homeLatePaymentDescription =>
      'Il pagamento è in scadenza. Effettualo per mantenere attivo il tuo piano.';

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
  String get trainingWorkoutCompleted => 'Allenamento completato';

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
  String get profileMaxTestsDescription =>
      'Tieni traccia dei tuoi massimali per vedere come progredisci nel tempo.';

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
  String profileMaxTestsEmptyPeriod(String period) {
    return 'Nessun test massimale registrato in $period. Prova un intervallo più lungo.';
  }

  @override
  String get profileMaxTestsBestPeriodLabel =>
      'Migliore nel periodo selezionato';

  @override
  String get profileMaxTestsRefresh => 'Aggiorna';

  @override
  String get profileMaxTestsHistoryAction => 'Vedi progressi';

  @override
  String get profileMaxTestsEmpty =>
      'Nessun test massimale registrato. Aggiungi il primo per iniziare a tracciare i progressi.';

  @override
  String get profileMaxTestsHistoryTitle => 'Progressi nel tempo';

  @override
  String get profileMaxTestsHistoryDescription =>
      'Rivedi ogni prova e osserva come evolvono i tuoi massimali.';

  @override
  String get profileMaxTestsHistoryEmpty =>
      'Nessun test massimale registrato. Aggiungi una nuova prova per vedere i progressi nel tempo.';

  @override
  String get profileMaxTestsRecentPerformanceLabel => 'Performance recente';

  @override
  String get profileMaxTestsGoalLabel => 'Obiettivo';

  @override
  String get profileMaxTestsTipsTitle => 'Suggerimenti e tutorial';

  @override
  String get profileMaxTestsTipsSubtitle =>
      'Rivedi i consigli tecnici e gli esercizi complementari.';

  @override
  String get profileMaxTestsEmptyShort =>
      'Aggiungi un nuovo test per vedere il grafico delle prestazioni.';

  @override
  String profileMaxTestsSessionLabel(int index) {
    return 'Sessione $index';
  }

  @override
  String profileMaxTestsHistoryError(Object error) {
    return 'Impossibile caricare lo storico dei progressi: $error';
  }

  @override
  String profileMaxTestsHistoryDeltaLabel(String delta) {
    return 'Variazione $delta';
  }

  @override
  String get profileMaxTestsHistoryFirstEntry => 'Prima registrazione';

  @override
  String profileMaxTestsError(Object error) {
    return 'Impossibile caricare i test massimali: $error';
  }

  @override
  String profileMaxTestsDateLabel(String date) {
    return 'Registrato il $date';
  }

  @override
  String get profileMaxTestsBestLabel => 'Miglior risultato';

  @override
  String get profileMaxTestsShowMore => 'Mostra tutti i tentativi';

  @override
  String get profileMaxTestsShowLess => 'Mostra meno tentativi';

  @override
  String get profileEdit => 'Modifica profilo';

  @override
  String get profileEditSubtitle => 'Aggiorna le tue informazioni personali';

  @override
  String get profileThemeSettingsTitle => 'Colori del tema';

  @override
  String get profileThemeSettingsSubtitle =>
      'Scegli il colore del tema dell\'app';

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
  String get invalidCredentials => 'Credenziali errate.';

  @override
  String get signupEmailCheck =>
      'Registrazione completata! Controlla la tua email per confermare l\'account.';

  @override
  String unexpectedError(Object error) {
    return 'Errore inatteso: $error';
  }

  @override
  String get loginGreeting =>
      'Bentornato! Accedi per continuare il tuo allenamento.';

  @override
  String get signupGreeting =>
      'Crea un account per sbloccare tutti gli allenamenti.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Conferma password';

  @override
  String get loginButton => 'Accedi';

  @override
  String get signupButton => 'Registrati';

  @override
  String get noAccountPrompt => 'Non hai un account? Registrati';

  @override
  String get existingAccountPrompt => 'Hai già un account? Accedi';

  @override
  String get forgotPasswordLink => 'Forgot your password?';

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
  String get timerExercisePushUps => 'Piegamenti';

  @override
  String get timerExercisePullUps => 'Trazioni';

  @override
  String get timerExerciseSquats => 'Squat';

  @override
  String get timerExercisePlank => 'Plank';

  @override
  String get timerPhaseWork => 'LAVORO';

  @override
  String get timerPhaseRest => 'RECUPERO';

  @override
  String get timerWorkDurationLabel => 'Durata lavoro';

  @override
  String get timerRestDurationLabel => 'Durata recupero';

  @override
  String get timerRoundsLabel => 'Round';

  @override
  String get timerExercisesLabel => 'Esercizi';

  @override
  String get timerAddExercise => 'Aggiungi esercizio';

  @override
  String get timerExerciseNameLabel => 'Nome esercizio';

  @override
  String get timerExerciseNameHint => 'Es. Muscle up, Dips, L-sit';

  @override
  String get timerNoExercisesConfigured =>
      'Aggiungi almeno un esercizio per avviare il timer.';

  @override
  String get timerControlSkip => 'SALTA';

  @override
  String get timerControlPause => 'PAUSA';

  @override
  String get timerControlPlay => 'AVVIA';

  @override
  String get timerControlReset => 'RESET';

  @override
  String get timerAdjustDecrease => '-10s';

  @override
  String get timerAdjustIncrease => '+10s';

  @override
  String get timerCountdownGo => 'Via';

  @override
  String get timerCountdownStop => 'Stop';

  @override
  String get timerNextPlaceholder => 'Prossimo: --';

  @override
  String timerNextLabel(String name, int current, int total) {
    return 'Prossimo: $name · Serie $current/$total';
  }

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
}

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
  String get navSettings => 'Impostazioni';

  @override
  String get navProfile => 'Profilo';

  @override
  String get navTerminology => 'Terminologia';

  @override
  String get settingsComingSoon =>
      'Le impostazioni saranno presto disponibili.';

  @override
  String get settingsGeneralSection => 'Generali';

  @override
  String get settingsDailyReminder => 'Promemoria allenamento quotidiano';

  @override
  String get settingsDailyReminderDescription =>
      'Ricevi un promemoria per iniziare ad allenarti ogni giorno.';

  @override
  String get settingsReminderTime => 'Orario promemoria';

  @override
  String get settingsReminderNotSet => 'Non impostato';

  @override
  String get settingsSoundEffects => 'Effetti sonori';

  @override
  String get settingsSoundEffectsDescription =>
      'Riproduci brevi suoni durante la registrazione delle ripetizioni.';

  @override
  String get settingsHapticFeedback => 'Feedback aptico';

  @override
  String get settingsHapticFeedbackDescription =>
      'Leggera vibrazione per le azioni importanti.';

  @override
  String get settingsTrainingSection => 'Preferenze di allenamento';

  @override
  String get settingsUnitSystem => 'Sistema di unità';

  @override
  String get settingsUnitsMetric => 'Metrico (kg)';

  @override
  String get settingsUnitsImperial => 'Imperiale (lb)';

  @override
  String get settingsRestTimer => 'Timer di recupero predefinito';

  @override
  String get settingsRestTimerDescription =>
      'Usato quando avvii un timer di recupero dagli allenamenti.';

  @override
  String settingsRestTimerMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# minuti',
      one: '# minuto',
    );
    return '$_temp0';
  }

  @override
  String settingsRestTimerMinutesSeconds(int minutes, int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '# minuti',
      one: '# minuto',
    );
    String _temp1 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '# secondi',
      one: '# secondo',
    );
    return '$_temp0 e $_temp1';
  }

  @override
  String settingsRestTimerSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# secondi',
      one: '# secondo',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataSection => 'Dati e privacy';

  @override
  String get settingsClearCache => 'Cancella allenamenti salvati';

  @override
  String get settingsClearCacheDescription =>
      'Rimuovi gli allenamenti memorizzati su questo dispositivo.';

  @override
  String get settingsClearCacheSuccess => 'Allenamenti locali rimossi.';

  @override
  String get settingsExportData => 'Esporta riepilogo allenamenti';

  @override
  String get settingsExportDataDescription =>
      'Ricevi via email un CSV delle ultime sessioni.';

  @override
  String get settingsExportDataSuccess =>
      'Richiesta di esportazione inviata. Controlla la casella di posta a breve.';

  @override
  String get settingsSupportSection => 'Supporto';

  @override
  String get settingsContactCoach => 'Contatta il tuo coach';

  @override
  String get settingsContactCoachDescription =>
      'Invia un messaggio rapido per chiedere modifiche.';

  @override
  String get settingsContactCoachHint => 'Dicci come possiamo aiutarti.';

  @override
  String get settingsContactCoachSuccess => 'Messaggio inviato al coach.';

  @override
  String get settingsSendMessage => 'Invia messaggio';

  @override
  String get settingsAppVersion => 'Versione app';

  @override
  String settingsAppVersionValue(Object version) {
    return 'Versione $version';
  }

  @override
  String get exerciseTrackerTitle => 'Tracker esercizi';

  @override
  String get poseEstimationTitle => 'Stima postura';

  @override
  String get homeLoadErrorTitle => 'Impossibile caricare gli allenamenti';

  @override
  String get retry => 'Riprova';

  @override
  String get homeEmptyTitle => 'Nessun allenamento disponibile';

  @override
  String get homeEmptyDescription =>
      'Contatta il tuo coach per ricevere una nuova scheda.';

  @override
  String get unauthenticated => 'Utente non autenticato';

  @override
  String get defaultExerciseName => 'Esercizio';

  @override
  String get generalNotes => 'Note generali';

  @override
  String get trainingHeaderExercise => 'Esercizio';

  @override
  String get trainingHeaderSets => 'Serie';

  @override
  String get trainingHeaderReps => 'Ripetizioni';

  @override
  String get trainingHeaderRest => 'Recupero';

  @override
  String get trainingHeaderIntensity => 'Intensità';

  @override
  String get trainingHeaderNotes => 'Note';

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
  String get profileLastUpdated => 'Ultimo aggiornamento';

  @override
  String get profileValueUnavailable => 'Non disponibile';

  @override
  String get profileTimezone => 'Fuso orario';

  @override
  String get profileNotSet => 'Non impostato';

  @override
  String get profileUnitSystem => 'Unità di misura';

  @override
  String get profileEdit => 'Modifica profilo';

  @override
  String get profileComingSoon => 'Presto disponibile';

  @override
  String get profileEditSubtitle => 'Aggiorna le tue informazioni personali';

  @override
  String get profileEditTitle => 'Modifica profilo';

  @override
  String get profileEditFullNameLabel => 'Nome completo';

  @override
  String get profileEditFullNameHint => 'Come vuoi essere chiamato?';

  @override
  String get profileEditTimezoneLabel => 'Fuso orario';

  @override
  String get profileEditTimezoneHint => 'Esempio: Europe/Rome';

  @override
  String get profileEditUnitSystemLabel => 'Unità di misura preferita';

  @override
  String get profileEditUnitSystemNotSet => 'Non specificato';

  @override
  String get profileEditUnitSystemMetric => 'Metrico (kg, cm)';

  @override
  String get profileEditUnitSystemImperial => 'Imperiale (lb, in)';

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
  String get featureUnavailable => 'Funzionalità non ancora disponibile.';

  @override
  String get logout => 'Logout';

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
  String get exerciseAddDialogTitle => 'Aggiungi esercizio';

  @override
  String get exerciseNameLabel => 'Nome esercizio';

  @override
  String get quickAddValuesLabel => 'Valori rapidi';

  @override
  String get quickAddValuesHelper =>
      'Ripetizioni separate da virgola (es. 1,5,10)';

  @override
  String get cancel => 'Annulla';

  @override
  String get add => 'Aggiungi';

  @override
  String get save => 'Salva';

  @override
  String get exerciseNameMissing => 'Inserisci un nome.';

  @override
  String get exerciseTargetRepsLabel => 'Ripetizioni obiettivo';

  @override
  String get exerciseTargetRepsHelper =>
      'Obiettivo totale opzionale per la sessione';

  @override
  String get exerciseRestDurationLabel => 'Durata recupero (secondi)';

  @override
  String get exerciseRestDurationHelper =>
      'Preset opzionale per il conto alla rovescia';

  @override
  String get exerciseTrackerEmpty =>
      'Ancora nessun esercizio. Tocca + per aggiungerne uno!';

  @override
  String get exerciseAddButton => 'Aggiungi esercizio';

  @override
  String get exercisePushUps => 'Push-up';

  @override
  String get exercisePullUps => 'Trazioni alla sbarra';

  @override
  String get exerciseChinUps => 'Trazioni a presa inversa';

  @override
  String exerciseTotalReps(int count) {
    return '$count ripetizioni totali';
  }

  @override
  String exerciseGoalProgress(int logged, int goal) {
    return '$logged / $goal ripetizioni registrate';
  }

  @override
  String exerciseRestFinished(String exercise) {
    return 'Recupero terminato per $exercise!';
  }

  @override
  String get exerciseSetRestDuration => 'Imposta durata recupero';

  @override
  String get exerciseDurationSecondsLabel => 'Durata (secondi)';

  @override
  String get restTimerLabel => 'Timer di recupero';

  @override
  String get setDuration => 'Imposta durata';

  @override
  String get undoLastSet => 'Annulla ultima serie';

  @override
  String get custom => 'Personalizzato';

  @override
  String get reset => 'Reimposta';

  @override
  String get logRepsTitle => 'Registra ripetizioni';

  @override
  String get repetitionsLabel => 'Ripetizioni';

  @override
  String get positiveNumberError => 'Inserisci un numero positivo.';

  @override
  String repsChip(int count) {
    return '$count ripetizioni';
  }

  @override
  String goalCount(int count) {
    return 'Obiettivo: $count';
  }

  @override
  String get repGoalReached => 'Obiettivo ripetizioni raggiunto!';

  @override
  String get pause => 'Pausa';

  @override
  String get start => 'Avvia';

  @override
  String seriesCount(int count) {
    return 'Serie: $count';
  }

  @override
  String get resetReps => 'Azzera ripetizioni';

  @override
  String get emomTrackerTitle => 'Tracker EMOM';

  @override
  String get emomTrackerSubtitle =>
      'Serie ogni minuto con conto alla rovescia.';

  @override
  String get emomTrackerDescription =>
      'Configura serie, ripetizioni e intervalli per restare sul ritmo ogni minuto.';

  @override
  String get emomSetsLabel => 'Serie totali';

  @override
  String get emomRepsLabel => 'Ripetizioni per serie';

  @override
  String get emomIntervalLabel => 'Intervallo (secondi)';

  @override
  String get emomStartButton => 'Avvia EMOM';

  @override
  String get emomResetButton => 'Reimposta sessione';

  @override
  String get emomSessionComplete => 'EMOM completato';

  @override
  String emomCurrentSet(int current, int total) {
    return 'Serie $current di $total';
  }

  @override
  String emomRepsPerSet(int count) {
    return '$count ripetizioni per serie';
  }

  @override
  String get emomFinishedMessage => 'Ottimo lavoro! Hai rispettato ogni minuto.';

  @override
  String get emomTimeRemainingLabel => 'Tempo rimanente in questo minuto';

  @override
  String emomPrepHeadline(int set) {
    return 'Preparati per la serie $set';
  }

  @override
  String get emomPrepSubhead =>
      'La prossima serie parte alla fine del conto alla rovescia.';

  @override
  String get timerTitle => 'Timer';

  @override
  String get weekdayMonday => 'Lunedì';

  @override
  String get weekdayTuesday => 'Martedì';

  @override
  String get weekdayWednesday => 'Mercoledì';

  @override
  String get weekdayThursday => 'Giovedì';

  @override
  String get weekdayFriday => 'Venerdì';

  @override
  String get weekdaySaturday => 'Sabato';

  @override
  String get weekdaySunday => 'Domenica';

  @override
  String weekNumber(int week) {
    return 'Settimana $week';
  }

  @override
  String get defaultWorkoutTitle => 'Allenamento';

  @override
  String get terminologyTitle => 'Terminologia';

  @override
  String get termRepsTitle => 'Reps (Ripetizioni)';

  @override
  String get termRepsDescription =>
      'Numero di volte che esegui un esercizio consecutivamente.';

  @override
  String get termSetTitle => 'Set (Serie)';

  @override
  String get termSetDescription =>
      'Un gruppo di ripetizioni. Es: 3 serie da 10 reps significa 30 ripetizioni totali, divise in 3 gruppi.';

  @override
  String get termRtTitle => 'RT';

  @override
  String get termRtDescription =>
      'Ripetizioni Totali: indica che devi fare tutte quelle reps, con libera scelta di serie, ripetizioni e tempo (se non indicato).';

  @override
  String get termAmrapTitle => 'AMRAP';

  @override
  String get termAmrapDescription =>
      'As Many Reps As Possible: esegui quante più ripetizioni possibili in un tempo determinato.';

  @override
  String get termEmomTitle => 'EMOM';

  @override
  String get termEmomDescription =>
      'Every Minute On Minute: inizi un set ogni minuto. Il tempo restante serve per riposare.';

  @override
  String get termRampingTitle => 'Ramping';

  @override
  String get termRampingDescription =>
      'Metodo che prevede un incremento del peso ad ogni serie';

  @override
  String get termMavTitle => 'MAV';

  @override
  String get termMavDescription =>
      'Massima Alzata Veloce: si riferisce a una metodologia in cui si cerca di eseguire il maggior numero di ripetizioni possibili con un carico, mantenendo sempre il controllo del movimento e una buona velocità di esecuzione.';

  @override
  String get termIsocineticiTitle => 'Isocinetici';

  @override
  String get termIsocineticiDescription =>
      'Esercizi svolti a velocità costante.';

  @override
  String get termTutTitle => 'TUT';

  @override
  String get termTutDescription =>
      'Indica quanto deve durare una ripetizione. Puoi gestire tu la durata di ogni fase della rep.';

  @override
  String get termIsoTitle => 'ISO';

  @override
  String get termIsoDescription =>
      'Indica il fermo a un punto specifico dell\'esecuzione della rep';

  @override
  String get termSomTitle => 'SOM';

  @override
  String get termSomDescription =>
      'Indica la durata di ogni fase della ripetizione.';

  @override
  String get termScaricoTitle => 'Scarico';

  @override
  String get termScaricoDescription =>
      'Ultima settimana della scheda per prepararsi ai massimali.';

  @override
  String get noCameras => 'Nessuna fotocamera disponibile';

  @override
  String cameraInitFailed(Object error) {
    return 'Inizializzazione fotocamera fallita: $error';
  }

  @override
  String get poseDetected => 'Posa rilevata';

  @override
  String get processing => 'Elaborazione…';

  @override
  String get idle => 'In attesa';

  @override
  String get cameraFront => 'frontale';

  @override
  String get cameraBack => 'posteriore';

  @override
  String hudMetrics(String fps, String milliseconds, int landmarks) {
    return 'fps: $fps  ms: $milliseconds  lmks: $landmarks';
  }

  @override
  String hudOrientation(String rotation, String camera, String format) {
    return 'rot: $rotation  cam: $camera  fmt: $format';
  }
}

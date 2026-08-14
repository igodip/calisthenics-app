// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Calisync';

  @override
  String get authErrorMessage => 'Error de autenticación';

  @override
  String get navHome => 'Inicio';

  @override
  String get navGuides => 'Guías';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navTerminology => 'Terminología';

  @override
  String get settingsThemeTitle => 'Tema';

  @override
  String get themeDefaultLabel => 'Predeterminado';

  @override
  String get themeBlackLabel => 'Negro';

  @override
  String get themePinkLabel => 'Rosa';

  @override
  String get themeRedLabel => 'Rojo';

  @override
  String get themeBlueLabel => 'Azul';

  @override
  String get themeYellowLabel => 'Amarillo';

  @override
  String get onboardingTitleOne => 'Entrena de forma inteligente';

  @override
  String get onboardingDescriptionOne =>
      'Sigue entrenamientos guiados creados para tu plan de calistenia.';

  @override
  String get onboardingTitleTwo => 'Haz seguimiento del progreso';

  @override
  String get onboardingDescriptionTwo =>
      'Registra series, repeticiones y notas para ver tus mejoras.';

  @override
  String get onboardingTitleThree => 'Mantén la constancia';

  @override
  String get onboardingDescriptionThree =>
      'Mantén el impulso con acceso rápido a tu próxima sesión.';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get onboardingBack => 'Atrás';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingGetStarted => 'Empezar';

  @override
  String get guidesTitle => 'Habilidades';

  @override
  String get guidesSubtitle =>
      'Explora técnicas, áreas de enfoque y consejos para cada habilidad.';

  @override
  String get guidesLoadError =>
      'No se pueden cargar las guías de habilidades en este momento.';

  @override
  String get guidesPrimaryFocus => 'Enfoque principal';

  @override
  String get guidesCoachTip => 'Consejo del entrenador';

  @override
  String get difficultyBeginner => 'Principiante';

  @override
  String get difficultyIntermediate => 'Intermedio';

  @override
  String get difficultyAdvanced => 'Avanzado';

  @override
  String get homeLoadErrorTitle => 'No se pueden cargar los entrenamientos';

  @override
  String get retry => 'Reintentar';

  @override
  String get homeCoachTipTitle => 'Consejo del entrenador';

  @override
  String get homeCoachTipPlaceholder =>
      'El último consejo de tu entrenador aparecerá aquí.';

  @override
  String homeGreeting(String name) {
    return 'Hola, $name!';
  }

  @override
  String get homeViewStats => 'Ver estadísticas';

  @override
  String get homeProgressTitle => 'Progreso mensual';

  @override
  String get homeProgressWorkoutsLabel => 'Entrenamientos';

  @override
  String get homeProgressTimeTrainedLabel => 'Tiempo entrenado';

  @override
  String homeProgressTimeValue(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get homeProgressNoPlan =>
      'Todavía no hay ningún plan de entrenamiento disponible.';

  @override
  String get homePlanStatsTitle => 'Estadísticas del plan';

  @override
  String get homePlanStatsDaysLabel => 'Días';

  @override
  String get homePlanStatsExercisesLabel => 'Ejercicios';

  @override
  String homePlanStatsCompletionValue(int progress) {
    return '$progress% completado';
  }

  @override
  String get workoutPlanTitle => 'Plan de entrenamiento';

  @override
  String get traineeFeedbackTitle => 'Comentarios del alumno';

  @override
  String get traineeFeedbackSubtitle =>
      'Cuéntale a tu entrenador cómo te sientes y cómo va el plan.';

  @override
  String get traineeFeedbackQuestionLabel =>
      '¿Cómo se sintió tu entrenamiento?';

  @override
  String get traineeFeedbackQuestionHint =>
      'Comparte lo que va bien o lo que necesita atención.';

  @override
  String get traineeFeedbackFeelingLabel => '¿Cómo te sentiste hoy?';

  @override
  String get traineeFeedbackFeelingHint =>
      'Elige una opción antes de enviar tus comentarios.';

  @override
  String get traineeFeedbackFeelingVeryBad => 'Muy mal';

  @override
  String get traineeFeedbackFeelingBad => 'Mal';

  @override
  String get traineeFeedbackFeelingOk => 'Regular';

  @override
  String get traineeFeedbackFeelingGood => 'Bien';

  @override
  String get traineeFeedbackFeelingVeryGood => 'Muy bien';

  @override
  String get traineeFeedbackSubmit => 'Enviar feedback';

  @override
  String get traineeFeedbackSubmitted =>
      'Feedback guardado. Lo compartiremos con tu entrenador.';

  @override
  String get traineeFeedbackLoadFailed =>
      'No se pudo cargar el feedback en este momento.';

  @override
  String get traineeFeedbackDelete => 'Eliminar feedback';

  @override
  String get traineeFeedbackDeleteTitle => '¿Eliminar el feedback?';

  @override
  String get traineeFeedbackDeleteMessage =>
      '¿Eliminar este feedback? Esta acción no se puede deshacer.';

  @override
  String get refresh => 'Actualizar';

  @override
  String get homeEmptyTitle => 'No hay entrenamientos disponibles';

  @override
  String get homeEmptyDescription =>
      'Contacta a tu entrenador para recibir un nuevo plan.';

  @override
  String get homeLatePaymentDescription =>
      'Tu pago está pendiente. Por favor, regularízalo para mantener tu plan activo.';

  @override
  String get homePlanDefaultTitle => 'Plan de entrenamiento';

  @override
  String get homePlanLatestLabel => 'Último plan';

  @override
  String homePlanStartedLabel(String date) {
    return 'Iniciado $date';
  }

  @override
  String get unauthenticated => 'Usuario no autenticado';

  @override
  String get defaultExerciseName => 'Ejercicio';

  @override
  String get trainingHeaderExercise => 'Ejercicio';

  @override
  String get trainingHeaderExercises => 'Ejercicios';

  @override
  String get trainingHeaderSets => 'Series';

  @override
  String get trainingHeaderReps => 'Repeticiones';

  @override
  String get trainingTodayTitle => 'Entrenamiento de hoy';

  @override
  String get trainingStartWorkout => 'Iniciar entrenamiento';

  @override
  String get trainingWorkoutCompleted => 'Entrenamiento completado';

  @override
  String trainingDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get trainingCompletionSaved => 'Día de entrenamiento actualizado';

  @override
  String trainingCompletionError(Object error) {
    return 'No se pudo actualizar el entrenamiento: $error';
  }

  @override
  String get trainingCompletionUnavailable =>
      'No se puede actualizar este día de entrenamiento.';

  @override
  String get trainingExerciseCompletionSaved => 'Ejercicio actualizado';

  @override
  String trainingExerciseCompletionError(Object error) {
    return 'No se pudo actualizar el ejercicio: $error';
  }

  @override
  String get trainingExerciseCompletionUnavailable =>
      'No se puede actualizar este ejercicio.';

  @override
  String get trainingExerciseNotesTitle => 'Notas';

  @override
  String get trainingExerciseYourNotesLabel => 'Tus notas';

  @override
  String get trainingExerciseSaveNotes => 'Guardar notas';

  @override
  String get trainingExerciseResolvedLabel => 'Marcar como resuelto';

  @override
  String get trainingExerciseNotesSaved => 'Notas actualizadas';

  @override
  String trainingExerciseNotesError(Object error) {
    return 'No se pudieron actualizar las notas: $error';
  }

  @override
  String get trainingExerciseFeedbackTitle => 'Feedback del ejercicio';

  @override
  String get trainingExerciseFeedbackHint =>
      'Añade feedback para este ejercicio completado.';

  @override
  String get trainingExerciseFeedbackLabel => '¿Cómo se sintió este ejercicio?';

  @override
  String get trainingExerciseSaveFeedback => 'Guardar feedback';

  @override
  String get trainingExerciseFeedbackSaved =>
      'Feedback del ejercicio actualizado';

  @override
  String trainingExerciseFeedbackError(Object error) {
    return 'No se pudo actualizar el feedback del ejercicio: $error';
  }

  @override
  String get trainingExerciseRepsTitle => 'Repeticiones completadas';

  @override
  String get trainingExerciseRepsHint =>
      'Cuenta las repeticiones completadas y guarda el resultado.';

  @override
  String get trainingExerciseRepsDecrease => 'Disminuir repeticiones';

  @override
  String get trainingExerciseRepsIncrease => 'Aumentar repeticiones';

  @override
  String trainingExerciseRepsCount(int count) {
    return '$count repeticiones completadas';
  }

  @override
  String get trainingExerciseSaveReps => 'Guardar reps';

  @override
  String get trainingExerciseRepsSaved => 'Repeticiones actualizadas';

  @override
  String trainingExerciseRepsError(Object error) {
    return 'No se pudieron actualizar las repeticiones: $error';
  }

  @override
  String logoutError(Object error) {
    return 'Error al cerrar sesión: $error';
  }

  @override
  String get profileFallbackName => 'Usuario';

  @override
  String get userNotFound => 'Usuario no encontrado en la base de datos';

  @override
  String get profileLoadError => 'Error al cargar los datos';

  @override
  String get profileNoData => 'No hay datos disponibles';

  @override
  String get profileEmailUnavailable => 'Correo electrónico no disponible';

  @override
  String get profileStatusActive => 'Cuenta activa';

  @override
  String get profileStatusInactive => 'Cuenta inactiva';

  @override
  String get profilePlanActive => 'Plan activo';

  @override
  String get profilePlanExpired => 'Plan caducado';

  @override
  String get profileUsername => 'Nombre de usuario';

  @override
  String get profileNotSet => 'No establecido';

  @override
  String get profileWeight => 'Peso';

  @override
  String profileWeightValue(String weight) {
    return '$weight kg';
  }

  @override
  String get profileHeight => 'Altura';

  @override
  String profileHeightValue(String height) {
    return '$height cm';
  }

  @override
  String get profileMaxTestsTitle => 'Seguimiento de pruebas máximas';

  @override
  String get profileMaxTestsDescription =>
      'Registra tus mejores intentos para ver cómo evoluciona tu fuerza con el tiempo.';

  @override
  String get profileMaxTestsPeriodLabel => 'Período';

  @override
  String get profileMaxTestsPeriodMonth => 'Último mes';

  @override
  String get profileMaxTestsPeriodHalfYear => 'Últimos 6 meses';

  @override
  String get profileMaxTestsPeriodYear => 'Último año';

  @override
  String get profileMaxTestsPeriodAll => 'Todo el tiempo';

  @override
  String profileMaxTestsEmptyPeriod(String period) {
    return 'No hay pruebas máximas registradas en $period. Prueba un rango de tiempo mayor.';
  }

  @override
  String get profileMaxTestsBestPeriodLabel =>
      'Mejor en el período seleccionado';

  @override
  String get profileMaxTestsRefresh => 'Actualizar';

  @override
  String get profileMaxTestsHistoryAction => 'Ver progreso';

  @override
  String get profileMaxTestsEmpty =>
      'Aún no hay pruebas máximas registradas. Añade tu primer intento para empezar a seguir el progreso.';

  @override
  String get profileMaxTestsHistoryTitle => 'Progreso en el tiempo';

  @override
  String get profileMaxTestsHistoryDescription =>
      'Revisa cada intento y observa cómo evolucionan tus valores máximos.';

  @override
  String get profileMaxTestsHistoryEmpty =>
      'Aún no hay pruebas máximas registradas. Añade un nuevo intento para ver tu progreso con el tiempo.';

  @override
  String get profileMaxTestsRecentPerformanceLabel => 'Rendimiento reciente';

  @override
  String get profileMaxTestsGoalLabel => 'Objetivo';

  @override
  String get profileMaxTestsTipsTitle => 'Consejos y tutoriales';

  @override
  String get profileMaxTestsTipsSubtitle =>
      'Revisa indicaciones de técnica y ejercicios accesorios.';

  @override
  String get profileMaxTestsEmptyShort =>
      'Añade una nueva prueba para ver tu gráfico de rendimiento.';

  @override
  String profileMaxTestsSessionLabel(int index) {
    return 'Sesión $index';
  }

  @override
  String profileMaxTestsHistoryError(Object error) {
    return 'No se pudo cargar el historial de progreso: $error';
  }

  @override
  String profileMaxTestsHistoryDeltaLabel(String delta) {
    return 'Cambio $delta';
  }

  @override
  String get profileMaxTestsHistoryFirstEntry => 'Primer intento registrado';

  @override
  String profileMaxTestsError(Object error) {
    return 'No se pudieron cargar las pruebas máximas: $error';
  }

  @override
  String profileMaxTestsDateLabel(String date) {
    return 'Registrado el $date';
  }

  @override
  String get profileMaxTestsBestLabel => 'Mejor marca';

  @override
  String get profileMaxTestsShowMore => 'Mostrar todos los intentos';

  @override
  String get profileMaxTestsShowLess => 'Mostrar menos intentos';

  @override
  String get profileEdit => 'Editar perfil';

  @override
  String get profileEditSubtitle => 'Actualiza tus datos personales';

  @override
  String get profileThemeSettingsTitle => 'Colores del tema';

  @override
  String get profileThemeSettingsSubtitle => 'Elige el tema de color de la app';

  @override
  String get profileLanguageSettingsTitle => 'Idioma';

  @override
  String get profileLanguageSettingsSubtitle => 'Elige el idioma de la app';

  @override
  String get profileEditTitle => 'Editar perfil';

  @override
  String get profileEditFullNameLabel => 'Nombre completo';

  @override
  String get profileEditFullNameHint => '¿Cómo quieres que te llamemos?';

  @override
  String get profileEditWeightLabel => 'Peso';

  @override
  String get profileEditWeightHint => 'Introduce tu peso en kg (opcional)';

  @override
  String get profileEditWeightInvalid => 'Introduce un peso positivo válido.';

  @override
  String get profileEditHeightLabel => 'Altura';

  @override
  String get profileEditHeightHint => 'Introduce tu altura en cm (opcional)';

  @override
  String get profileEditHeightInvalid =>
      'Introduce una altura positiva válida.';

  @override
  String get profilePhotoEdit => 'Cambiar foto';

  @override
  String get profileEditCancel => 'Cancelar';

  @override
  String get profileEditSave => 'Guardar cambios';

  @override
  String get profileEditSuccess => 'Perfil actualizado correctamente';

  @override
  String profileEditError(Object error) {
    return 'No se pudo actualizar el perfil: $error';
  }

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get languageSystemLabel => 'Predeterminado del sistema';

  @override
  String get languageEnglishLabel => 'Inglés';

  @override
  String get languageItalianLabel => 'Italiano';

  @override
  String get languageSpanishLabel => 'Español';

  @override
  String redirectError(Object error) {
    return 'Error durante la redirección: $error';
  }

  @override
  String linkError(Object error) {
    return 'Error de enlace: $error';
  }

  @override
  String get missingFieldsError =>
      'Por favor completa todos los campos obligatorios.';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get invalidCredentials => 'Credenciales inválidas.';

  @override
  String get signupEmailCheck =>
      '¡Registro completo! Revisa tu correo para confirmar la cuenta.';

  @override
  String unexpectedError(Object error) {
    return 'Error inesperado: $error';
  }

  @override
  String get loginGreeting =>
      '¡Bienvenido de nuevo! Inicia sesión para continuar tu entrenamiento.';

  @override
  String get signupGreeting =>
      'Crea una cuenta para desbloquear todos los entrenamientos.';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get signupButton => 'Registrarse';

  @override
  String get noAccountPrompt => '¿No tienes cuenta? Regístrate';

  @override
  String get existingAccountPrompt => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get forgotPasswordLink => '¿Olvidaste tu contraseña?';

  @override
  String passwordResetEmailSent(String email) {
    return 'Enlace de restablecimiento enviado a $email. Revisa tu bandeja de entrada.';
  }

  @override
  String get passwordResetEmailMissing =>
      'Introduce tu correo para recibir un enlace de restablecimiento.';

  @override
  String get passwordResetDialogTitle => 'Elige una nueva contraseña';

  @override
  String get passwordResetDialogDescription =>
      'Introduce una nueva contraseña para asegurar tu cuenta.';

  @override
  String get passwordResetNewPasswordLabel => 'Nueva contraseña';

  @override
  String get passwordResetConfirmPasswordLabel => 'Confirmar nueva contraseña';

  @override
  String get passwordResetMismatch => 'Las contraseñas no coinciden.';

  @override
  String get passwordResetSuccess =>
      'Contraseña actualizada correctamente. Puedes seguir usando la app.';

  @override
  String get passwordResetSubmit => 'Actualizar contraseña';

  @override
  String get cancel => 'Cancelar';

  @override
  String get add => 'Añadir';

  @override
  String get start => 'Iniciar';

  @override
  String get timerTitle => 'Temporizador';

  @override
  String get timerExercisePushUps => 'Flexiones';

  @override
  String get timerExercisePullUps => 'Dominadas';

  @override
  String get timerExerciseSquats => 'Sentadillas';

  @override
  String get timerExercisePlank => 'Plancha';

  @override
  String get timerPhaseWork => 'TRABAJO';

  @override
  String get timerPhaseRest => 'DESCANSO';

  @override
  String get timerWorkDurationLabel => 'Duración del trabajo';

  @override
  String get timerRestDurationLabel => 'Duración del descanso';

  @override
  String get timerRoundsLabel => 'Rondas';

  @override
  String get timerExercisesLabel => 'Ejercicios';

  @override
  String get timerAddExercise => 'Añadir ejercicio';

  @override
  String get timerExerciseNameLabel => 'Nombre del ejercicio';

  @override
  String get timerExerciseNameHint => 'Ej. Muscle up, Dips, L-sit';

  @override
  String get timerNoExercisesConfigured =>
      'Añade al menos un ejercicio para iniciar el temporizador.';

  @override
  String get timerControlSkip => 'SALTAR';

  @override
  String get timerControlPause => 'PAUSAR';

  @override
  String get timerControlPlay => 'REPRODUCIR';

  @override
  String get timerControlReset => 'REINICIAR';

  @override
  String get timerAdjustDecrease => '-10s';

  @override
  String get timerAdjustIncrease => '+10s';

  @override
  String get timerCountdownGo => 'Vamos';

  @override
  String get timerCountdownStop => 'Alto';

  @override
  String get timerNextPlaceholder => 'Siguiente: --';

  @override
  String timerNextLabel(String name, int current, int total) {
    return 'Siguiente: $name · Serie $current/$total';
  }

  @override
  String weekNumber(int week) {
    return 'Semana $week';
  }

  @override
  String get defaultWorkoutTitle => 'Entrenamiento';

  @override
  String get terminologyTitle => 'Terminología';

  @override
  String get traineeFeedbackAnsweredTitle => 'Feedback respondido';

  @override
  String get traineeFeedbackAnsweredEmpty =>
      'Todavía no tienes feedback respondido.';

  @override
  String get traineeFeedbackAnsweredChip => 'Respondido';

  @override
  String get traineeFeedbackSentAt => 'Enviado:';

  @override
  String get traineeFeedbackAnsweredAt => 'Respondido:';

  @override
  String get traineeFeedbackTrainerAnswer => 'Respuesta del entrenador';

  @override
  String get traineeFeedbackLastAnsweredTitle =>
      'Última respuesta del entrenador';

  @override
  String get traineeFeedbackYourMessage => 'Tu mensaje';

  @override
  String get traineeFeedbackAnsweredAtHome => 'Respondido el';

  @override
  String get trainerMenuGroup => 'ENTRENADOR';

  @override
  String get trainerNavDashboard => 'Panel del entrenador';

  @override
  String get trainerNavTrainees => 'Mis alumnos';

  @override
  String get trainerNavFeedback => 'Feedback del entrenador';

  @override
  String get trainerNavPayments => 'Pagos de alumnos';

  @override
  String get trainerWorkspaceTitle => 'Área del entrenador';

  @override
  String get trainerWorkspaceSubtitle =>
      'Tus atletas asignados y su actividad reciente.';

  @override
  String get trainerAssignedTrainees => 'Alumnos asignados';

  @override
  String get trainerUnreadFeedback => 'Feedback sin leer';

  @override
  String get trainerActivePlans => 'Planes activos';

  @override
  String get trainerOverdue => 'Vencido';

  @override
  String get trainerTraineesTitle => 'Alumnos';

  @override
  String get trainerNoAssignedTrainees =>
      'Todavía no tienes alumnos asignados.';

  @override
  String get trainerStatusActive => 'Activo';

  @override
  String get trainerPlanProgress => 'Progreso del plan';

  @override
  String get trainerOpenProgram => 'Abrir programa';

  @override
  String get trainerSearchTrainees => 'Buscar alumnos';

  @override
  String trainerAssignedCount(int count) {
    return '$count alumnos asignados';
  }

  @override
  String get trainerNoMatchingTrainees => 'No hay alumnos coincidentes.';

  @override
  String get trainerFilterAll => 'Todos';

  @override
  String get trainerFilterUnread => 'Sin leer';

  @override
  String get trainerFilterAnswered => 'Respondidos';

  @override
  String get trainerNoFeedbackInView => 'No hay feedback en esta vista.';

  @override
  String get trainerStatusRead => 'Leído';

  @override
  String get trainerStatusUnread => 'Sin leer';

  @override
  String get trainerYourAnswer => 'Tu respuesta';

  @override
  String get trainerReplyHint => 'Responder al alumno';

  @override
  String get trainerSendAnswer => 'Enviar respuesta';

  @override
  String get trainerMarkUnread => 'Marcar como no leído';

  @override
  String get trainerMarkRead => 'Marcar como leído';

  @override
  String get trainerAnswerRequired => 'Escribe primero una respuesta.';

  @override
  String get trainerPaid => 'Pagado';

  @override
  String get trainerReceived => 'Recibido';

  @override
  String get trainerMonthlyAmount => 'Importe mensual';

  @override
  String get trainerAppAccessActive => 'Acceso a la app activo';

  @override
  String trainerLoadToolsError(String error) {
    return 'No se pudieron cargar las herramientas del entrenador\n$error';
  }

  @override
  String get trainerRetry => 'Reintentar';

  @override
  String get trainerOverviewTab => 'Resumen';

  @override
  String get trainerPlanTab => 'Plan';

  @override
  String get trainerHistoryTab => 'Historial';

  @override
  String trainerLoadProgramError(String error) {
    return 'No se pudo cargar el programa\n$error';
  }

  @override
  String get trainerAthleteData => 'Datos del atleta';

  @override
  String get trainerNameLabel => 'Nombre';

  @override
  String get trainerWeightLabel => 'Peso';

  @override
  String get trainerPaymentLabel => 'Pago';

  @override
  String get trainerOnTime => 'Al día';

  @override
  String get trainerProgressLabel => 'Progreso';

  @override
  String get trainerCoachTip => 'Consejo del entrenador';

  @override
  String get trainerCoachTipHint => 'Visible para el alumno en la app';

  @override
  String get trainerPrivateNotes => 'Notas privadas del entrenador';

  @override
  String get trainerSave => 'Guardar';

  @override
  String get trainerCoachFieldsSaved => 'Consejo y notas privadas guardados.';

  @override
  String get trainerTrainingCalendar => 'Calendario de entrenamientos';

  @override
  String get trainerNoScheduledDays => 'No hay días programados.';

  @override
  String trainerShowMoreDays(int count) {
    return 'Mostrar $count días más';
  }

  @override
  String get trainerShowLessDays => 'Mostrar menos días';

  @override
  String get trainerFeedbackTitle => 'Feedback';

  @override
  String get trainerNoFeedbackYet => 'Todavía no hay feedback.';

  @override
  String get trainerCreateWorkoutPlan => 'Crear plan de entrenamiento';

  @override
  String get trainerImportPdf => 'Importar PDF';

  @override
  String get trainerImportingPdf => 'Leyendo PDF…';

  @override
  String get trainerPdfPreviewTitle => 'Revisar el plan importado';

  @override
  String get trainerPdfPlanName => 'Nombre del plan';

  @override
  String trainerPdfSummary(int days, int exercises) {
    return 'Se detectaron $days días y $exercises ejercicios';
  }

  @override
  String trainerPdfDaySummary(int week, String day, int exercises) {
    return 'Semana $week · Día $day: $exercises ejercicios';
  }

  @override
  String get trainerPdfConfirmImport => 'Importar plan';

  @override
  String get trainerPdfImportSuccess =>
      'Plan de entrenamiento importado correctamente.';

  @override
  String get trainerPdfImportFailed =>
      'No se pudo importar el PDF. Comprueba que contenga tablas de entrenamiento DÍA A–G.';

  @override
  String get trainerPdfPathUnavailable =>
      'El PDF seleccionado no está disponible en este dispositivo.';

  @override
  String get trainerNoPlans => 'No hay planes creados.';

  @override
  String get trainerWorkoutPlanFallback => 'Plan de entrenamiento';

  @override
  String get trainerPlanStatusActive => 'Activo';

  @override
  String get trainerPlanStatusInactive => 'Inactivo';

  @override
  String get trainerPlanStatusUpcoming => 'Próximo';

  @override
  String get trainerPlanStatusDraft => 'Borrador';

  @override
  String get trainerPlanStatusArchived => 'Archivado';

  @override
  String get trainerWorkoutDays => 'Días de entrenamiento';

  @override
  String get trainerMaxTests => 'Pruebas máximas';

  @override
  String get trainerNoMaxTests => 'No hay pruebas máximas.';

  @override
  String get trainerWeightHistory => 'Historial de peso';

  @override
  String get trainerNoWeightEntries => 'No hay registros de peso.';

  @override
  String get trainerPaymentHistory => 'Historial de pagos';

  @override
  String get trainerNoPayments => 'No hay pagos.';

  @override
  String get trainerTrainingDayFallback => 'Día de entrenamiento';

  @override
  String trainerExercisesCompleted(int completed, int total) {
    return '$completed/$total ejercicios completados';
  }

  @override
  String get trainerExerciseFallback => 'Ejercicio';

  @override
  String trainerMinutesDuration(String minutes) {
    return '$minutes min';
  }

  @override
  String trainerExerciseResult(String minutes, String reps) {
    return '$minutes min · $reps rep.';
  }

  @override
  String trainerTraineeNote(String notes) {
    return 'Alumno: $notes';
  }

  @override
  String trainerTraineeExerciseFeedback(String comment) {
    return 'Comentario del ejercicio: $comment';
  }

  @override
  String get trainerDeletePlanTitle => '¿Eliminar el plan?';

  @override
  String trainerDeletePlanMessage(String title) {
    return '¿Eliminar “$title”?';
  }

  @override
  String get trainerCancel => 'Cancelar';

  @override
  String get trainerDelete => 'Eliminar';

  @override
  String get trainerDeleteFeedback => 'Eliminar feedback';

  @override
  String get trainerDeleteFeedbackTitle => '¿Eliminar el feedback?';

  @override
  String trainerDeleteFeedbackMessage(String name) {
    return '¿Eliminar este feedback de $name? Esta acción no se puede deshacer.';
  }

  @override
  String get trainerNewPlan => 'Nuevo plan de entrenamiento';

  @override
  String get trainerPlanName => 'Nombre del plan';

  @override
  String get trainerNotes => 'Notas';

  @override
  String get trainerCreate => 'Crear';
}

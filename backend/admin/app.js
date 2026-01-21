(() => {
  const { createApp, ref, computed, onMounted, watch } = Vue;

  // === Configure your Supabase project ===
  const SUPABASE_URL = 'https://jrqjysycoqhlnyufhliy.supabase.co';
  const SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpycWp5c3ljb3FobG55dWZobGl5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI0MzM0NTIsImV4cCI6MjA2ODAwOTQ1Mn0.3BVA-Ar9YtLGGO12Gt6NQkMl2cn18E_b48PGtlFxxCw';
  const g = window;
  const createClient =
    (g.supabase && g.supabase.createClient) ||
    (g.Supabase && g.Supabase.createClient) ||
    g.SUPABASE_CREATE_CLIENT;
  const fallbackLocale = (navigator.language || '').toLowerCase().startsWith('it')
    ? 'it'
    : 'en';
  const supabaseLoadMessages = {
    en: 'Supabase library failed to load. Check your network or replace with local copies.',
    it: 'Impossibile caricare la libreria Supabase. Controlla la rete o sostituiscila con copie locali.',
  };
  if (!createClient) {
    console.error('Supabase JS failed to load from all CDNs (jsDelivr/ESM).');
    alert(supabaseLoadMessages[fallbackLocale]);
    return; // stop bootstrapping
  }
  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON);

  createApp({
    setup() {
      const storedLocale = localStorage.getItem('adminLocale');
      const browserLocale = (navigator.language || '').toLowerCase().startsWith('it')
        ? 'it'
        : 'en';
      const locale = ref(storedLocale || browserLocale);
      const languageOptions = [
        { value: 'en', label: 'English' },
        { value: 'it', label: 'Italiano' },
      ];
      const translations = {
        en: {
          app: {
            title: 'Calisync Admin Portal',
          },
          auth: {
            subtitle:
              'Sign in with your Supabase account to manage trainees, their workout days, and exercises.',
          },
          toolbar: {
            language: 'Language',
            admin: 'Admin',
            roleAdmin: 'Admin',
            roleTrainer: 'Trainer',
            roleViewer: 'Viewer',
            searchPlaceholder: 'Search trainees...',
          },
          sections: {
            dashboard: 'Overview',
            trainees: 'Trainees',
            payments: 'Payments',
            program: 'Program',
            exercises: 'Exercises',
            schedule: 'Schedule',
          },
          actions: {
            signIn: 'Sign in',
            signOut: 'Sign out',
            save: 'Save',
            savePlan: 'Save plan',
            saveDay: 'Save day',
            reset: 'Reset',
            delete: 'Delete',
            add: 'Add',
            addExercise: 'Add exercise',
            assignTrainer: 'Assign trainer',
            refresh: 'Refresh',
            clear: 'Clear',
            useNextWeek: 'Use next week',
            openSchedule: 'Open schedule',
            loadDays: 'Load days',
            loadPlans: 'Load plans',
            collapse: 'Collapse',
            expand: 'Expand',
          },
          labels: {
            totalCount: '{count} total',
            shownCount: '{count} shown',
            dayCount: '{count} day',
            daysCount: '{count} days',
            exerciseCount: '{count} exercise',
            exercisesCount: '{count} exercises',
            testCount: '{count} test',
            testsCount: '{count} tests',
            exerciseShort: 'ex',
            name: 'Name',
            status: 'Status',
            startsAt: 'Starts at',
            endsAt: 'Ends at',
            notes: 'Notes',
            week: 'Week',
            dayCode: 'Day code',
            title: 'Title',
            position: 'Position',
            weeks: 'Weeks',
            days: 'Days',
            exercises: 'Exercises',
            daysWithExercises: 'Days w/ exercises',
            weekNumber: 'Week {week}',
            weekDay: 'Week {week} • {day}',
            weekDayTitle: 'Week {week} • {day} — {title}',
            untitled: 'Untitled',
            exercise: 'Exercise',
            day: 'Day',
            unknownExercise: 'Unknown exercise',
          },
          dashboard: {
            feedbackTitle: 'Feedback & trainee notes',
            feedbackSubtitle: 'Latest messages that need your attention first.',
            loadingFeedback: 'Loading feedback…',
            noFeedback: 'No notes yet from trainees.',
            noticesTitle: 'General notices',
            noticesSubtitle: 'Quick reminders for upcoming changes or deloads.',
            noticePlaceholder: 'Add a notice, e.g. “Igor Monday deload week”.',
            addNotice: 'Add notice',
            noNotices: 'No general notices yet.',
            openProgram: 'Open program',
          },
          payments: {
            overviewTitle: 'Payment dashboard',
            overviewSubtitle: 'Check who is up to date and who needs a reminder.',
            manageTitle: 'Manage payments',
            manageSubtitle: 'Update payment status for each trainee.',
            overdueTitle: 'Overdue reminders',
            overdueSubtitle: 'Follow up or mark payments as received.',
            totalLabel: 'Trainees',
            paidLabel: 'On time',
            overdueLabel: 'Overdue',
            noOverdue: 'All payments are up to date.',
            noMatches: 'No trainees match this filter yet.',
            filterAll: 'All',
            filterPaid: 'On time',
            filterOverdue: 'Overdue',
            markPaid: 'Mark as paid',
          },
          program: {
            title: 'Program creation',
            titleWithName: 'Program creation • {name}',
            subtitle: 'Create workout structures, then map them into days.',
            empty: 'Select a trainee from the Trainees tab to start building a program.',
            templateTitle: 'Base template',
            templateSubtitle:
              'Sketch the week structure first, then refine with the daily schedule.',
            dayCountLabel: 'Training days',
            templateDay: 'Day {day}',
            templateExercisePlaceholder: 'Exercise',
            templateSetsPlaceholder: 'Sets/Reps',
            templateNotesPlaceholder: 'Notes',
          },
          placeholders: {
            email: 'Email',
            password: 'Password',
            exerciseExample: 'e.g. Push-ups',
            exerciseName: 'Exercise name',
            planExample: 'e.g. Summer Strength',
            planNotes: 'Optional notes for the trainee',
            notesOptional: 'Optional notes',
            notesOptionalShort: 'Notes (optional)',
            workoutTitle: 'Workout title',
            filterExercises: 'Type to filter exercises',
          },
          exercises: {
            available: 'Available exercises',
            none: 'No exercises loaded yet.',
          },
          trainees: {
            badge: 'trainee',
          },
          trainers: {
            title: 'Trainers',
            assigned: 'Assigned trainers',
            none: 'No trainers assigned',
            select: 'Select trainer',
          },
          payment: {
            onTime: 'Payments on time',
            overdue: 'Payment overdue',
            toggle: 'On time',
          },
          status: {
            savingExercise: 'Saving exercise…',
            savingPlan: 'Saving plan…',
            savingDay: 'Saving day…',
            refreshingProgress: 'Refreshing progress…',
            updatingPayment: 'Updating payment status…',
            updatingTrainer: 'Updating trainer assignment…',
            noProgress: 'No progress logged yet.',
            loadingMaxTests: 'Loading max tests…',
          },
          plans: {
            title: 'Workout plans',
            empty: 'Select a trainee from the Trainees tab to manage their plans.',
            addTitle: 'Add workout plan',
            listTitle: 'Plans',
            none: 'No plans for this trainee yet.',
          },
          schedule: {
            empty: 'Pick a trainee from the Trainees tab to manage their schedule.',
            createDay: 'Create day',
            nextWeek: 'Next: week {week}',
            quickDayPick: 'Quick day pick',
            quickDayHelp: 'Tap a code to fill the day quickly.',
            recap: 'Schedule recap',
            recapSubtitle: 'Quick snapshot of what has been added.',
            recapEmpty: 'Add a day to start building the recap.',
            highlights: 'Highlights',
            jumpToDay: 'Jump to day',
            jumpSubtitle: 'Move fast between days and auto-expand the one you need.',
            noDays: 'No days yet.',
            daysExercises: 'Days & Exercises',
            addExercise: 'Add exercise',
            searchSelect: 'Search & select',
            exerciseHelp: 'Start typing to auto-complete and click a suggestion.',
          },
          history: {
            title: 'Max test history',
            empty: 'Select a trainee from the Trainees tab to review their max test history.',
            titleWithName: 'Max test history • {name}',
            subtitle:
              'Each chart shows how max attempts evolve over time for a single exercise.',
            none: 'No max tests logged yet.',
            testsBest: '{countLabel} • best {value} {unit}',
            chartAria: 'Max test history for {exercise}',
          },
          errors: {
            loadTrainees: 'Failed to load trainees: {message}',
            updatePayment: 'Failed to update payment status.',
            loadAccess: 'Failed to load admin access: {message}',
            loadTrainers: 'Failed to load trainers: {message}',
            assignTrainer: 'Failed to assign trainer.',
            removeTrainer: 'Failed to remove trainer.',
            loadExercises: 'Failed to load exercises: {message}',
            loadProgress: 'Failed to load trainee progress: {message}',
            loadPlans: 'Failed to load plans: {message}',
            exerciseNameRequired: 'Exercise name is required.',
            exerciseNameEmpty: 'Exercise name cannot be empty.',
            createExercise: 'Failed to create exercise.',
            updateExercise: 'Failed to update exercise.',
            deleteExercise: 'Failed to delete exercise.',
            loadDays: 'Failed to load days: {message}',
            selectTrainee: 'Select a trainee first.',
            planNameRequired: 'Plan name is required.',
            createPlan: 'Failed to create plan.',
            dayCodeRequired: 'Day code is required.',
            createDay: 'Failed to create day.',
            missingPlan: 'Missing plan.',
            updatePlan: 'Failed to update plan.',
            deletePlan: 'Failed to delete plan.',
            missingDay: 'Missing day.',
            chooseExercise: 'Choose an exercise first.',
            addExercise: 'Failed to add exercise.',
            updateDay: 'Failed to update day: {message}',
            deleteDay: 'Failed to delete day: {message}',
            missingDayExercise: 'Missing day exercise.',
            updateDayExercise: 'Failed to update exercise: {message}',
            deleteDayExercise: 'Failed to delete exercise: {message}',
            loadMaxTests: 'Failed to load max tests.',
            loadMaxTestsWithMessage: 'Failed to load max tests: {message}',
          },
          confirm: {
            deleteExercise: 'Delete exercise "{name}"?',
            deletePlan: 'Delete this plan?',
            deleteDay: 'Delete this day and its exercises?',
            deleteDayExercise: 'Remove exercise from day?',
          },
          dayCodes: {
            MON: 'Mon',
            TUE: 'Tue',
            WED: 'Wed',
            THU: 'Thu',
            FRI: 'Fri',
            SAT: 'Sat',
            SUN: 'Sun',
          },
          planStatuses: {
            active: 'active',
            upcoming: 'upcoming',
            draft: 'draft',
            archived: 'archived',
          },
        },
        it: {
          app: {
            title: 'Portale Admin Calisync',
          },
          auth: {
            subtitle:
              'Accedi con il tuo account Supabase per gestire gli allievi, le loro giornate di allenamento e gli esercizi.',
          },
          toolbar: {
            language: 'Lingua',
            admin: 'Admin',
            roleAdmin: 'Admin',
            roleTrainer: 'Trainer',
            roleViewer: 'Visualizzatore',
            searchPlaceholder: 'Cerca allievi...',
          },
          sections: {
            dashboard: 'Panoramica',
            trainees: 'Allievi',
            payments: 'Pagamenti',
            program: 'Programma',
            exercises: 'Esercizi',
            schedule: 'Programma',
          },
          actions: {
            signIn: 'Accedi',
            signOut: 'Esci',
            save: 'Salva',
            savePlan: 'Salva piano',
            saveDay: 'Salva giornata',
            reset: 'Reimposta',
            delete: 'Elimina',
            add: 'Aggiungi',
            addExercise: 'Aggiungi esercizio',
            assignTrainer: 'Assegna trainer',
            refresh: 'Aggiorna',
            clear: 'Svuota',
            useNextWeek: 'Usa prossima settimana',
            openSchedule: 'Apri programma',
            loadDays: 'Carica giornate',
            loadPlans: 'Carica piani',
            collapse: 'Comprimi',
            expand: 'Espandi',
          },
          labels: {
            totalCount: '{count} totali',
            shownCount: '{count} mostrati',
            dayCount: '{count} giorno',
            daysCount: '{count} giorni',
            exerciseCount: '{count} esercizio',
            exercisesCount: '{count} esercizi',
            testCount: '{count} test',
            testsCount: '{count} test',
            exerciseShort: 'es',
            name: 'Nome',
            status: 'Stato',
            startsAt: 'Inizio',
            endsAt: 'Fine',
            notes: 'Note',
            week: 'Settimana',
            dayCode: 'Codice giorno',
            title: 'Titolo',
            position: 'Posizione',
            weeks: 'Settimane',
            days: 'Giorni',
            exercises: 'Esercizi',
            daysWithExercises: 'Giorni con esercizi',
            weekNumber: 'Settimana {week}',
            weekDay: 'Settimana {week} • {day}',
            weekDayTitle: 'Settimana {week} • {day} — {title}',
            untitled: 'Senza titolo',
            exercise: 'Esercizio',
            day: 'Giorno',
            unknownExercise: 'Esercizio sconosciuto',
          },
          dashboard: {
            feedbackTitle: 'Feedback & note allievi',
            feedbackSubtitle: 'Messaggi recenti da vedere subito.',
            loadingFeedback: 'Caricamento feedback…',
            noFeedback: 'Nessuna nota inviata dagli allievi.',
            noticesTitle: 'Avvisi generali',
            noticesSubtitle: 'Promemoria veloci per scarichi o cambiamenti.',
            noticePlaceholder: 'Aggiungi un avviso, es. “Igor lunedì settimana di scarico”.',
            addNotice: 'Aggiungi avviso',
            noNotices: 'Nessun avviso generale.',
            openProgram: 'Apri programma',
          },
          payments: {
            overviewTitle: 'Dashboard pagamenti',
            overviewSubtitle: 'Controlla chi è in regola e chi necessita un promemoria.',
            manageTitle: 'Gestione pagamenti',
            manageSubtitle: 'Aggiorna lo stato di pagamento degli allievi.',
            overdueTitle: 'Promemoria in ritardo',
            overdueSubtitle: 'Contatta o segna i pagamenti ricevuti.',
            totalLabel: 'Allievi',
            paidLabel: 'In regola',
            overdueLabel: 'In ritardo',
            noOverdue: 'Tutti i pagamenti sono in regola.',
            noMatches: 'Nessun allievo corrisponde a questo filtro.',
            filterAll: 'Tutti',
            filterPaid: 'In regola',
            filterOverdue: 'In ritardo',
            markPaid: 'Segna pagato',
          },
          program: {
            title: 'Creazione programma',
            titleWithName: 'Creazione programma • {name}',
            subtitle: 'Crea la struttura base e poi rifinisci le giornate.',
            empty: 'Seleziona un allievo dalla scheda Allievi per creare il programma.',
            templateTitle: 'Scheda base',
            templateSubtitle:
              'Imposta prima la struttura, poi rifinisci con le giornate.',
            dayCountLabel: 'Giorni di allenamento',
            templateDay: 'Giorno {day}',
            templateExercisePlaceholder: 'Esercizio',
            templateSetsPlaceholder: 'Serie/Rip.',
            templateNotesPlaceholder: 'Note',
          },
          placeholders: {
            email: 'Email',
            password: 'Password',
            exerciseExample: 'es. Push-up',
            exerciseName: 'Nome esercizio',
            planExample: 'es. Forza estiva',
            planNotes: "Note opzionali per l'allievo",
            notesOptional: 'Note opzionali',
            notesOptionalShort: 'Note (opzionali)',
            workoutTitle: 'Titolo allenamento',
            filterExercises: 'Digita per filtrare esercizi',
          },
          exercises: {
            available: 'Esercizi disponibili',
            none: 'Nessun esercizio caricato.',
          },
          trainees: {
            badge: 'allievo',
          },
          trainers: {
            title: 'Trainer',
            assigned: 'Trainer assegnati',
            none: 'Nessun trainer assegnato',
            select: 'Seleziona trainer',
          },
          payment: {
            onTime: 'Pagamenti regolari',
            overdue: 'Pagamento in ritardo',
            toggle: 'In regola',
          },
          status: {
            savingExercise: 'Salvataggio esercizio…',
            savingPlan: 'Salvataggio piano…',
            savingDay: 'Salvataggio giornata…',
            refreshingProgress: 'Aggiornamento progressi…',
            updatingPayment: 'Aggiornamento stato pagamento…',
            updatingTrainer: 'Aggiornamento assegnazione trainer…',
            noProgress: 'Nessun progresso registrato.',
            loadingMaxTests: 'Caricamento test massimali…',
          },
          plans: {
            title: 'Piani di allenamento',
            empty: 'Seleziona un allievo dalla scheda Allievi per gestire i piani.',
            addTitle: 'Aggiungi piano di allenamento',
            listTitle: 'Piani',
            none: 'Nessun piano per questo allievo.',
          },
          schedule: {
            empty: 'Seleziona un allievo dalla scheda Allievi per gestire il programma.',
            createDay: 'Crea giornata',
            nextWeek: 'Prossima: settimana {week}',
            quickDayPick: 'Scelta rapida giornata',
            quickDayHelp: 'Tocca un codice per compilare rapidamente la giornata.',
            recap: 'Riepilogo programma',
            recapSubtitle: 'Vista rapida di ciò che è stato aggiunto.',
            recapEmpty: 'Aggiungi una giornata per iniziare il riepilogo.',
            highlights: 'In evidenza',
            jumpToDay: 'Vai alla giornata',
            jumpSubtitle:
              'Passa rapidamente tra le giornate ed espandi quella che ti serve.',
            noDays: 'Nessuna giornata ancora.',
            daysExercises: 'Giornate ed esercizi',
            addExercise: 'Aggiungi esercizio',
            searchSelect: 'Cerca e seleziona',
            exerciseHelp:
              'Inizia a digitare per completare automaticamente e fai clic su un suggerimento.',
          },
          history: {
            title: 'Storico test massimali',
            empty:
              'Seleziona un allievo dalla scheda Allievi per vedere lo storico dei test massimali.',
            titleWithName: 'Storico test massimali • {name}',
            subtitle:
              'Ogni grafico mostra come evolvono i massimali nel tempo per un singolo esercizio.',
            none: 'Nessun test massimale registrato.',
            testsBest: '{countLabel} • migliore {value} {unit}',
            chartAria: 'Storico test massimali per {exercise}',
          },
          errors: {
            loadTrainees: 'Impossibile caricare gli allievi: {message}',
            updatePayment: 'Impossibile aggiornare lo stato pagamento.',
            loadAccess: 'Impossibile caricare i permessi admin: {message}',
            loadTrainers: 'Impossibile caricare i trainer: {message}',
            assignTrainer: 'Impossibile assegnare il trainer.',
            removeTrainer: 'Impossibile rimuovere il trainer.',
            loadExercises: 'Impossibile caricare gli esercizi: {message}',
            loadProgress: 'Impossibile caricare i progressi degli allievi: {message}',
            loadPlans: 'Impossibile caricare i piani: {message}',
            exerciseNameRequired: "Il nome dell'esercizio è obbligatorio.",
            exerciseNameEmpty: "Il nome dell'esercizio non può essere vuoto.",
            createExercise: "Impossibile creare l'esercizio.",
            updateExercise: "Impossibile aggiornare l'esercizio.",
            deleteExercise: "Impossibile eliminare l'esercizio.",
            loadDays: 'Impossibile caricare le giornate: {message}',
            selectTrainee: 'Seleziona prima un allievo.',
            planNameRequired: 'Il nome del piano è obbligatorio.',
            createPlan: 'Impossibile creare il piano.',
            dayCodeRequired: 'Il codice giorno è obbligatorio.',
            createDay: 'Impossibile creare la giornata.',
            missingPlan: 'Piano mancante.',
            updatePlan: 'Impossibile aggiornare il piano.',
            deletePlan: 'Impossibile eliminare il piano.',
            missingDay: 'Giornata mancante.',
            chooseExercise: 'Seleziona prima un esercizio.',
            addExercise: "Impossibile aggiungere l'esercizio.",
            updateDay: 'Impossibile aggiornare la giornata: {message}',
            deleteDay: 'Impossibile eliminare la giornata: {message}',
            missingDayExercise: 'Esercizio del giorno mancante.',
            updateDayExercise: "Impossibile aggiornare l'esercizio: {message}",
            deleteDayExercise: "Impossibile eliminare l'esercizio: {message}",
            loadMaxTests: 'Impossibile caricare i test massimali.',
            loadMaxTestsWithMessage:
              'Impossibile caricare i test massimali: {message}',
          },
          confirm: {
            deleteExercise: 'Eliminare l’esercizio "{name}"?',
            deletePlan: 'Eliminare questo piano?',
            deleteDay: 'Eliminare questa giornata e i suoi esercizi?',
            deleteDayExercise: "Rimuovere l'esercizio dalla giornata?",
          },
          dayCodes: {
            MON: 'Lun',
            TUE: 'Mar',
            WED: 'Mer',
            THU: 'Gio',
            FRI: 'Ven',
            SAT: 'Sab',
            SUN: 'Dom',
          },
          planStatuses: {
            active: 'attivo',
            upcoming: 'in arrivo',
            draft: 'bozza',
            archived: 'archiviato',
          },
        },
      };
      const interpolate = (template, params) =>
        template.replace(/\{(\w+)\}/g, (_match, key) =>
          params[key] !== undefined ? params[key] : '',
        );
      const getTranslation = (key, selectedLocale) => {
        const segments = key.split('.');
        let current = translations[selectedLocale];
        for (const segment of segments) {
          if (!current || typeof current !== 'object' || !(segment in current)) {
            return null;
          }
          current = current[segment];
        }
        return typeof current === 'string' ? current : null;
      };
      const t = (key, params = {}) => {
        const selectedLocale = locale.value in translations ? locale.value : 'en';
        const translation =
          getTranslation(key, selectedLocale) || getTranslation(key, 'en') || key;
        return interpolate(translation, params);
      };
      const formatCount = (count, singularKey, pluralKey) =>
        t(count === 1 ? singularKey : pluralKey, { count });
      const dayCodeLabel = (code) => {
        const normalized = (code || '').toUpperCase();
        const label =
          translations[locale.value]?.dayCodes?.[normalized] ||
          translations.en?.dayCodes?.[normalized];
        return label || normalized || t('labels.day');
      };
      const planStatusLabel = (status) =>
        t(`planStatuses.${status}`, { status });
      const formatWeekDayLabel = (week, code) =>
        t('labels.weekDay', { week, day: dayCodeLabel(code) });
      const formatWeekDayTitleLabel = (week, code, title) =>
        title
          ? t('labels.weekDayTitle', { week, day: dayCodeLabel(code), title })
          : formatWeekDayLabel(week, code);
      const updateDocumentLanguage = () => {
        document.documentElement.lang = locale.value;
        document.title = t('app.title');
      };

      watch(locale, (nextLocale) => {
        localStorage.setItem('adminLocale', nextLocale);
        updateDocumentLanguage();
      });
      const session = ref(null);
      const user = ref(null);
      const email = ref('');
      const password = ref('');
      const search = ref('');
      const activeSection = ref('dashboard');
      const paymentFilter = ref('all');
      const currentAdmin = ref(null);
      const currentTrainer = ref(null);
      const trainers = ref([]);
      const trainerSelections = ref({});
      const trainerAssignmentSaving = ref({});

      const users = ref([]);
      const current = ref(null);
      const days = ref([]);
      const plans = ref([]);
      const exerciseOptions = ref([]);
      const exerciseSelection = ref({});
      const exerciseEdits = ref({});
      const dayEdits = ref({});
      const dayExerciseEdits = ref({});
      const planEdits = ref({});
      const expandedDays = ref({});
      const traineeProgress = ref({});
      const loadingProgress = ref(false);
      const maxTests = ref([]);
      const loadingMaxTests = ref(false);
      const maxTestsError = ref('');
      const paymentSaving = ref({});
      const dashboardNotes = ref([]);
      const dashboardNotesLoading = ref(false);
      const dashboardNotesError = ref('');
      const announcements = ref([]);
      const newAnnouncement = ref('');
      const addingDay = ref(false);
      const addingExercise = ref(false);
      const savingExercise = ref(false);
      const savingPlan = ref(false);
      const newDayWeek = ref(1);
      const newDayCode = ref('MON');
      const newDayTitle = ref('');
      const newDayNotes = ref('');
      const newExerciseName = ref('');
      const planStatuses = ['active', 'upcoming', 'draft', 'archived'];
      const dayCodeOptions = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      const newPlanName = ref('');
      const newPlanStatus = ref(planStatuses[0]);
      const newPlanStartsAt = ref('');
      const newPlanEndsAt = ref('');
      const newPlanNotes = ref('');
      const templateDayCount = ref(3);
      const templateDayOptions = [2, 3, 4, 5];
      const templateSlotsPerDay = 6;
      const programTemplateDays = ref(
        buildTemplateDays(templateDayCount.value, templateSlotsPerDay, []),
      );
      watch(templateDayCount, (nextCount) => {
        programTemplateDays.value = buildTemplateDays(
          nextCount,
          templateSlotsPerDay,
          programTemplateDays.value,
        );
      });

      function buildTemplateDays(count, slots, existing) {
        const list = [];
        const safeExisting = Array.isArray(existing) ? existing : [];
        for (let i = 0; i < count; i += 1) {
          const previous = safeExisting[i];
          const nextSlots = [];
          for (let j = 0; j < slots; j += 1) {
            const prevSlot = previous?.slots?.[j] || {};
            nextSlots.push({
              exercise: prevSlot.exercise || '',
              sets: prevSlot.sets || '',
              notes: prevSlot.notes || '',
            });
          }
          list.push({
            id: previous?.id || `template-${i + 1}`,
            index: i + 1,
            slots: nextSlots,
          });
        }
        return list;
      }

      const nextWeek = computed(() => {
        if (!days.value.length) return 1;
        const weeks = days.value.map((d) => Number(d.week || 0));
        return Math.max(...weeks) + 1;
      });

      const dayTitleSuggestions = computed(() => {
        const titles = new Set();
        (days.value || []).forEach((day) => {
          const title = (day.title || '').trim();
          if (title) titles.add(title);
        });
        return Array.from(titles).sort((a, b) => a.localeCompare(b));
      });

      const scheduleSummary = computed(() => {
        const totalDays = days.value.length;
        const totalExercises = (days.value || []).reduce(
          (sum, day) => sum + (day.day_exercises || []).length,
          0,
        );
        const weekSet = new Set(
          (days.value || [])
            .map((day) => Number(day.week || 0))
            .filter((week) => week > 0),
        );
        const daysWithExercises = (days.value || []).filter(
          (day) => (day.day_exercises || []).length > 0,
        ).length;
        const highlights = (days.value || [])
          .map((day) => ({
            id: day.id,
            label: formatWeekDayLabel(day.week || 1, day.day_code?.toUpperCase()),
            exercises: (day.day_exercises || []).length,
          }))
          .filter((item) => item.exercises > 0)
          .sort((a, b) => b.exercises - a.exercises)
          .slice(0, 6);
        return {
          days: totalDays,
          exercises: totalExercises,
          weeks: weekSet.size,
          daysWithExercises,
          highlights,
        };
      });

      const overdueUsers = computed(() =>
        (users.value || []).filter((u) => !u.paid),
      );

      const paymentFilterOptions = [
        { value: 'all', labelKey: 'payments.filterAll' },
        { value: 'paid', labelKey: 'payments.filterPaid' },
        { value: 'overdue', labelKey: 'payments.filterOverdue' },
      ];

      const paymentUsers = computed(() => {
        const list = filteredUsers.value || [];
        const filter = paymentFilter.value;
        const filtered = list.filter((u) => {
          if (filter === 'paid') return u.paid;
          if (filter === 'overdue') return !u.paid;
          return true;
        });
        return filtered.sort((a, b) => {
          if (a.paid !== b.paid) return a.paid ? 1 : -1;
          const nameA = (a.displayName || '').toLowerCase();
          const nameB = (b.displayName || '').toLowerCase();
          if (nameA && nameB) return nameA.localeCompare(nameB);
          return (a.id || '').localeCompare(b.id || '');
        });
      });

      const paymentSummary = computed(() => {
        const total = (users.value || []).length;
        const paid = (users.value || []).filter((u) => u.paid).length;
        return {
          total,
          paid,
          overdue: total - paid,
        };
      });

      const canAssignTrainers = computed(() =>
        Boolean(currentAdmin.value?.can_assign_trainers),
      );

      const roleLabel = computed(() => {
        if (currentAdmin.value) return t('toolbar.roleAdmin');
        if (currentTrainer.value) return t('toolbar.roleTrainer');
        return t('toolbar.roleViewer');
      });

      const dayNavigation = computed(() => {
        const order = new Map(dayCodeOptions.map((code, idx) => [code, idx]));
        return (days.value || [])
          .map((day) => ({
            id: day.id,
            week: Number(day.week || 0),
            code: day.day_code?.toUpperCase() || '',
            exercises: (day.day_exercises || []).length,
            title: (day.title || '').trim(),
            label: formatWeekDayTitleLabel(
              day.week || 1,
              day.day_code?.toUpperCase(),
              day.title,
            ),
          }))
          .sort((a, b) => {
            if (a.week !== b.week) return a.week - b.week;
            const aIdx = order.has(a.code) ? order.get(a.code) : 99;
            const bIdx = order.has(b.code) ? order.get(b.code) : 99;
            if (aIdx !== bIdx) return aIdx - bIdx;
            return a.label.localeCompare(b.label);
          });
      });

      const maxTestHistory = computed(() => {
        const grouped = {};
        (maxTests.value || []).forEach((test) => {
          const exercise =
            (test.exercise || '').trim() || t('labels.unknownExercise');
          if (!grouped[exercise]) {
            grouped[exercise] = {
              exercise,
              unit: test.unit || '',
              tests: [],
            };
          }
          grouped[exercise].tests.push({
            ...test,
            value: Number(test.value || 0),
            timestamp: Date.parse(test.recorded_at || '') || Date.now(),
          });
          if (!grouped[exercise].unit && test.unit) {
            grouped[exercise].unit = test.unit;
          }
        });

        return Object.values(grouped)
          .map((entry) => {
            const sorted = entry.tests.sort((a, b) => a.timestamp - b.timestamp);
            const values = sorted.map((item) => item.value);
            const maxValue = values.length ? Math.max(...values) : 0;
            const minValue = values.length ? Math.min(...values) : 0;
            const minDate = sorted[0]?.timestamp || Date.now();
            const maxDate = sorted[sorted.length - 1]?.timestamp || minDate;
            const minDateLabel = sorted[0]?.recorded_at
              ? formatDate(sorted[0].recorded_at)
              : '';
            const maxDateLabel = sorted[sorted.length - 1]?.recorded_at
              ? formatDate(sorted[sorted.length - 1].recorded_at)
              : '';
            const range = maxValue - minValue || 1;
            const timeRange = maxDate - minDate || 1;
            const chartWidth = 260;
            const chartHeight = 90;
            const padding = 12;
            const points = sorted.map((item) => {
              const x =
                padding +
                ((item.timestamp - minDate) / timeRange) *
                  (chartWidth - padding * 2);
              const y =
                chartHeight -
                padding -
                ((item.value - minValue) / range) * (chartHeight - padding * 2);
              return {
                x: Number(x.toFixed(2)),
                y: Number(y.toFixed(2)),
                value: item.value,
                recorded_at: item.recorded_at,
              };
            });
            const polyline = points.map((point) => `${point.x},${point.y}`).join(' ');
            const latest = sorted[sorted.length - 1];
            return {
              exercise: entry.exercise,
              unit: entry.unit,
              count: sorted.length,
              minValue,
              maxValue,
              bestValue: maxValue,
              latestLabel: latest ? formatDate(latest.recorded_at) : '',
              minDateLabel,
              maxDateLabel,
              chartWidth,
              chartHeight,
              points,
              polyline,
            };
          })
          .sort((a, b) => a.exercise.localeCompare(b.exercise));
      });

      const filteredUsers = computed(() => {
        const q = search.value.trim().toLowerCase();
        if (!q) return users.value;
        return users.value.filter(
          (u) =>
            (u.displayName || '').toLowerCase().includes(q) ||
            (u.id || '').toLowerCase().includes(q),
        );
      });

      const shortId = (id) => (id ? id.toString().slice(0, 8) + '…' : '');

      const formatTestValue = (value) => {
        const numeric = Number(value || 0);
        return Number.isInteger(numeric) ? numeric.toFixed(0) : numeric.toFixed(1);
      };

      const formatDate = (value) => {
        if (!value) return '';
        const parsed = new Date(value);
        if (Number.isNaN(parsed.valueOf())) return value;
        const localeTag = locale.value === 'it' ? 'it-IT' : 'en-US';
        return parsed.toLocaleDateString(localeTag, {
          year: 'numeric',
          month: 'short',
          day: 'numeric',
        });
      };

      const currentMonthStart = () => {
        const now = new Date();
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, '0');
        return `${year}-${month}-01`;
      };

      function loadAnnouncementsFromStorage() {
        try {
          const stored = localStorage.getItem('adminAnnouncements');
          if (!stored) {
            announcements.value = [];
            return;
          }
          const parsed = JSON.parse(stored);
          announcements.value = Array.isArray(parsed) ? parsed : [];
        } catch (error) {
          console.error(error);
          announcements.value = [];
        }
      }

      function persistAnnouncements() {
        localStorage.setItem(
          'adminAnnouncements',
          JSON.stringify(announcements.value),
        );
      }

      function addAnnouncement() {
        const text = (newAnnouncement.value || '').trim();
        if (!text) return;
        const id =
          (window.crypto && window.crypto.randomUUID && window.crypto.randomUUID()) ||
          `notice-${Date.now()}-${Math.random().toString(16).slice(2)}`;
        const createdAt = new Date().toISOString();
        announcements.value = [
          { id, text, createdAt },
          ...(announcements.value || []),
        ];
        newAnnouncement.value = '';
        persistAnnouncements();
      }

      function removeAnnouncement(notice) {
        if (!notice?.id) return;
        announcements.value = (announcements.value || []).filter(
          (item) => item.id !== notice.id,
        );
        persistAnnouncements();
      }

      function formatNoticeDate(notice) {
        return notice?.createdAt ? formatDate(notice.createdAt) : '';
      }

      function resetDayForm() {
        newDayWeek.value = 1;
        newDayCode.value = 'MON';
        newDayTitle.value = '';
        newDayNotes.value = '';
      }

      function applyNextWeek() {
        newDayWeek.value = nextWeek.value;
      }

      function setDayCode(code) {
        newDayCode.value = code;
      }

      function resetExerciseForm() {
        newExerciseName.value = '';
      }

      function resetExerciseEdit(ex) {
        setExerciseEdit(ex);
      }

      function resetDayEdit(day) {
        setDayEdit(day);
      }

      function resetDayExerciseEdit(ex) {
        setDayExerciseEdit(ex);
      }

      function resetPlanForm() {
        newPlanName.value = '';
        newPlanStatus.value = planStatuses[0];
        newPlanStartsAt.value = '';
        newPlanEndsAt.value = '';
        newPlanNotes.value = '';
      }

      function normalizeDateInput(value) {
        if (!value) return '';
        if (typeof value === 'string') {
          return value.split('T')[0];
        }
        try {
          return new Date(value).toISOString().slice(0, 10);
        } catch (_e) {
          return '';
        }
      }

      function setPlanEdit(plan) {
        if (!plan?.id) return;
        planEdits.value = {
          ...planEdits.value,
          [plan.id]: {
            name: plan.name || '',
            status: plan.status || planStatuses[0],
            starts_on: normalizeDateInput(plan.starts_on),
            notes: plan.notes || '',
          },
        };
      }

      function resetPlanEdit(plan) {
        setPlanEdit(plan);
      }

      function ensureSelection(dayId) {
        if (!exerciseSelection.value[dayId]) {
          exerciseSelection.value = {
            ...exerciseSelection.value,
            [dayId]: { exercise_id: '', notes: '', query: '' },
          };
          return;
        }
        if (
          exerciseSelection.value[dayId] &&
          typeof exerciseSelection.value[dayId].query !== 'string'
        ) {
          exerciseSelection.value = {
            ...exerciseSelection.value,
            [dayId]: { ...exerciseSelection.value[dayId], query: '' },
          };
        }
      }

      function setDayExpansion(dayId, open = true) {
        expandedDays.value = { ...expandedDays.value, [dayId]: open };
      }

      function isDayOpen(day) {
        return !!expandedDays.value[day.id];
      }

      function toggleDay(day) {
        setDayExpansion(day.id, !isDayOpen(day));
      }

      function jumpToDay(item) {
        if (!item?.id) return;
        setDayExpansion(item.id, true);
        requestAnimationFrame(() => {
          const target = document.getElementById(`day-${item.id}`);
          if (target) {
            target.scrollIntoView({ behavior: 'smooth', block: 'start' });
          }
        });
      }

      function filteredExerciseOptions(day) {
        const q = (exerciseSelection.value[day.id]?.query || '').toLowerCase();
        if (!q) return exerciseOptions.value || [];
        return (exerciseOptions.value || []).filter((opt) =>
          opt.name.toLowerCase().includes(q),
        );
      }

      function pickExercise(day, opt) {
        ensureSelection(day.id);
        exerciseSelection.value = {
          ...exerciseSelection.value,
          [day.id]: {
            ...exerciseSelection.value[day.id],
            exercise_id: opt.id,
            query: opt.name,
          },
        };
      }

      function matchExercise(day) {
        ensureSelection(day.id);
        const query = (exerciseSelection.value[day.id].query || '').toLowerCase();
        const match = (exerciseOptions.value || []).find(
          (opt) => opt.name.toLowerCase() === query,
        );
        exerciseSelection.value = {
          ...exerciseSelection.value,
          [day.id]: {
            ...exerciseSelection.value[day.id],
            exercise_id: match?.id || '',
          },
        };
      }

      function setExerciseEdit(exercise) {
        if (!exercise?.id) return;
        exerciseEdits.value = {
          ...exerciseEdits.value,
          [exercise.id]: { name: exercise.name || '' },
        };
      }

      function setDayEdit(day) {
        if (!day?.id) return;
        dayEdits.value = {
          ...dayEdits.value,
          [day.id]: {
            week: day.week ?? 1,
            day_code: day.day_code || '',
            title: day.title || '',
            notes: day.notes || '',
          },
        };
      }

      function setDayExerciseEdit(exercise) {
        if (!exercise?.id) return;
        dayExerciseEdits.value = {
          ...dayExerciseEdits.value,
          [exercise.id]: {
            position: exercise.position ?? 1,
            notes: exercise.notes || '',
          },
        };
      }

      function progressFor(trainee) {
        const entry = traineeProgress.value[trainee.id] || {
          completed: 0,
          total: 0,
        };
        const percent = entry.total
          ? Math.round((entry.completed / entry.total) * 100)
          : 0;
        return { ...entry, percent };
      }

      async function emailPasswordSignIn() {
        const { data, error } = await supabase.auth.signInWithPassword({
          email: email.value,
          password: password.value,
        });
        if (error) {
          alert(error.message);
          return;
        }
        session.value = data.session;
        user.value = data.user;
        await bootstrap();
      }
      async function signOut() {
        await supabase.auth.signOut();
        location.reload();
      }

      async function bootstrap() {
        await loadAccess();
        if (canAssignTrainers.value) {
          await loadTrainers();
        }
        await loadUsers();
        await loadExercises();
        await loadTraineeProgress();
        await loadDashboardNotes();
        if (users.value.length) {
          await selectUser(users.value[0]);
          await loadPlans(users.value[0]);
          await loadDays(users.value[0]);
        }
      }

      async function loadAccess() {
        const userId = user.value?.id;
        if (!userId) return;
        try {
          const { data: adminRow, error: adminError } = await supabase
            .from('admins')
            .select('id, user_id, name, can_assign_trainers')
            .eq('user_id', userId)
            .maybeSingle();
          if (adminError && adminError.code !== 'PGRST116') {
            throw new Error(adminError.message);
          }
          const { data: trainerRow, error: trainerError } = await supabase
            .from('trainers')
            .select('id, user_id, name')
            .eq('user_id', userId)
            .maybeSingle();
          if (trainerError && trainerError.code !== 'PGRST116') {
            throw new Error(trainerError.message);
          }
          currentAdmin.value = adminRow || null;
          currentTrainer.value = trainerRow || null;
        } catch (error) {
          console.error(error);
          alert(t('errors.loadAccess', { message: error.message }));
          currentAdmin.value = null;
          currentTrainer.value = null;
        }
      }

      async function loadTrainers() {
        const { data, error } = await supabase
          .from('trainers')
          .select('id, name')
          .order('name', { ascending: true });
        if (error) {
          console.error(error);
          alert(t('errors.loadTrainers', { message: error.message }));
          return;
        }
        trainers.value = data || [];
      }

      async function loadUsers() {
        const isTrainerOnly = Boolean(currentTrainer.value && !currentAdmin.value);
        const baseSelect =
          'id, name, paid, trainee_trainers ( trainer_id, trainers ( id, name ) )';
        let query = supabase.from('trainees').select(baseSelect);
        if (isTrainerOnly) {
          query = supabase
            .from('trainees')
            .select(
              'id, name, paid, trainee_trainers!inner ( trainer_id, trainers ( id, name ) )',
            )
            .eq('trainee_trainers.trainer_id', currentTrainer.value.id);
        }
        const { data: traineeRows, error } = await query.order('name', {
          ascending: true,
        });
        if (error) {
          console.error(error);
          alert(t('errors.loadTrainees', { message: error.message }));
          return;
        }

        users.value = (traineeRows || []).map((row) => ({
          ...row,
          trainers: (row.trainee_trainers || [])
            .map((assignment) => assignment.trainers)
            .filter(Boolean),
          trainerIds: (row.trainee_trainers || []).map(
            (assignment) => assignment.trainer_id,
          ),
          displayName: row.name || shortId(row.id),
        }));
        users.value.forEach((trainee) => {
          if (!trainerSelections.value[trainee.id]) {
            trainerSelections.value = {
              ...trainerSelections.value,
              [trainee.id]: '',
            };
          }
        });
      }

      async function assignTrainerToTrainee(trainee) {
        if (!canAssignTrainers.value || !trainee?.id) return;
        const trainerId = trainerSelections.value[trainee.id];
        if (!trainerId) return;
        trainerAssignmentSaving.value = {
          ...trainerAssignmentSaving.value,
          [trainee.id]: true,
        };
        try {
          const { error } = await supabase.from('trainee_trainers').insert({
            trainee_id: trainee.id,
            trainer_id: trainerId,
          });
          if (error) {
            throw new Error('Assign trainer failed: ' + error.message);
          }
          trainerSelections.value = {
            ...trainerSelections.value,
            [trainee.id]: '',
          };
          await loadUsers();
        } catch (error) {
          console.error(error);
          alert(error.message || t('errors.assignTrainer'));
        } finally {
          trainerAssignmentSaving.value = {
            ...trainerAssignmentSaving.value,
            [trainee.id]: false,
          };
        }
      }

      async function removeTrainerAssignment(trainee, trainer) {
        if (!canAssignTrainers.value || !trainee?.id || !trainer?.id) return;
        trainerAssignmentSaving.value = {
          ...trainerAssignmentSaving.value,
          [trainee.id]: true,
        };
        try {
          const { error } = await supabase
            .from('trainee_trainers')
            .delete()
            .eq('trainee_id', trainee.id)
            .eq('trainer_id', trainer.id);
          if (error) {
            throw new Error('Remove trainer failed: ' + error.message);
          }
          await loadUsers();
        } catch (error) {
          console.error(error);
          alert(error.message || t('errors.removeTrainer'));
        } finally {
          trainerAssignmentSaving.value = {
            ...trainerAssignmentSaving.value,
            [trainee.id]: false,
          };
        }
      }

      async function updatePaymentStatus(u, nextPaid, target) {
        if (!u?.id) return;
        if (paymentSaving.value[u.id]) return;
        const previousPaid = Boolean(u.paid);
        u.paid = nextPaid;
        paymentSaving.value = { ...paymentSaving.value, [u.id]: true };
        try {
          const { error } = await supabase
            .from('trainees')
            .update({ paid: nextPaid })
            .eq('id', u.id);
          if (error) {
            throw new Error('Update payment status failed: ' + error.message);
          }
          const monthStart = currentMonthStart();
          const { error: monthlyError } = await supabase
            .from('trainee_monthly_payments')
            .upsert(
              {
                trainee_id: u.id,
                month_start: monthStart,
                paid: nextPaid,
                paid_at: nextPaid ? new Date().toISOString() : null,
              },
              { onConflict: 'trainee_id,month_start' },
            );
          if (monthlyError) {
            throw new Error('Update monthly payment failed: ' + monthlyError.message);
          }
        } catch (err) {
          console.error(err);
          u.paid = previousPaid;
          if (target && 'checked' in target) {
            target.checked = previousPaid;
          }
          alert(err.message || t('errors.updatePayment'));
        } finally {
          paymentSaving.value = { ...paymentSaving.value, [u.id]: false };
        }
      }

      function togglePayment(u, event) {
        const target = event?.target;
        const nextPaid = Boolean(target?.checked);
        void updatePaymentStatus(u, nextPaid, target);
      }

      function markPaymentPaid(u) {
        void updatePaymentStatus(u, true);
      }

      async function selectUser(u) {
        current.value = u;
        days.value = [];
        plans.value = [];
        planEdits.value = {};
        expandedDays.value = {};
        maxTests.value = [];
        maxTestsError.value = '';
        await loadMaxTests(u);
      }

      async function loadExercises() {
        const { data, error } = await supabase
          .from('exercises')
          .select('id, name')
          .order('name', { ascending: true });
        if (error) {
          console.error(error);
          alert(t('errors.loadExercises', { message: error.message }));
          return;
        }
        exerciseOptions.value = data || [];
        (exerciseOptions.value || []).forEach(setExerciseEdit);
      }

      async function loadTraineeProgress() {
        loadingProgress.value = true;
        try {
          const trainerOnly = Boolean(currentTrainer.value && !currentAdmin.value);
          const visibleIds = trainerOnly
            ? (users.value || []).map((u) => u.id).filter(Boolean)
            : [];
          if (trainerOnly && !visibleIds.length) {
            traineeProgress.value = {};
            return;
          }
          let query = supabase
            .from('day_exercises')
            .select('id, completed, days ( trainee_id )');
          if (trainerOnly) {
            query = query.in('days.trainee_id', visibleIds);
          }
          const { data, error } = await query;
          if (error) {
            throw new Error(t('errors.loadProgress', { message: error.message }));
          }
          const progress = {};
          (data || []).forEach((row) => {
            const traineeId = row.days?.trainee_id;
            if (!traineeId) return;
            if (!progress[traineeId]) {
              progress[traineeId] = { completed: 0, total: 0 };
            }
            progress[traineeId].total += 1;
            if (row.completed) {
              progress[traineeId].completed += 1;
            }
          });
          traineeProgress.value = progress;
        } catch (err) {
          console.error(err);
          alert(err.message || t('errors.loadProgress'));
        } finally {
          loadingProgress.value = false;
        }
      }

      async function loadMaxTests(u = current.value) {
        if (!u) return;
        loadingMaxTests.value = true;
        maxTestsError.value = '';
        try {
          const { data, error } = await supabase
            .from('max_tests')
            .select('id, exercise, value, unit, recorded_at')
            .eq('trainee_id', u.id)
            .order('recorded_at', { ascending: true });
          if (error) {
            throw new Error(
              t('errors.loadMaxTestsWithMessage', { message: error.message }),
            );
          }
          maxTests.value = (data || []).map((row) => ({
            ...row,
            value: Number(row.value || 0),
          }));
        } catch (err) {
          console.error(err);
          maxTests.value = [];
          maxTestsError.value = err.message || t('errors.loadMaxTests');
        } finally {
          loadingMaxTests.value = false;
        }
      }

      async function loadPlans(u = current.value) {
        if (!u) return;
        const { data, error } = await supabase
          .from('workout_plans')
          .select('id, title, status, starts_on, notes, trainee_id, created_at')
          .eq('trainee_id', u.id)
          .order('starts_on', { ascending: false, nullsLast: false })
          .order('created_at', { ascending: false });
        if (error) {
          console.error(error);
          alert(t('errors.loadPlans', { message: error.message }));
          return;
        }
        plans.value = data || [];
        planEdits.value = {};
        (plans.value || []).forEach(setPlanEdit);
      }

      async function addExerciseDefinition() {
        const name = newExerciseName.value.trim();
        if (!name) {
          alert(t('errors.exerciseNameRequired'));
          return;
        }
        savingExercise.value = true;
        try {
          const { error } = await supabase.from('exercises').insert({ name });
          if (error) {
            throw new Error('Create exercise failed: ' + error.message);
          }
          resetExerciseForm();
          await loadExercises();
        } catch (err) {
          console.error(err);
          alert(err.message || t('errors.createExercise'));
        } finally {
          savingExercise.value = false;
        }
      }

      async function updateExercise(ex) {
        if (!ex?.id) return;
        const name = (exerciseEdits.value[ex.id]?.name || '').trim();
        if (!name) {
          alert(t('errors.exerciseNameEmpty'));
          return;
        }
        savingExercise.value = true;
        try {
          const { error } = await supabase
            .from('exercises')
            .update({ name })
            .eq('id', ex.id);
          if (error) {
            throw new Error('Update exercise failed: ' + error.message);
          }
          await loadExercises();
          await loadDays();
        } catch (err) {
          console.error(err);
          alert(err.message || t('errors.updateExercise'));
        } finally {
          savingExercise.value = false;
        }
      }

      async function deleteExercise(ex) {
        if (!ex?.id) return;
        const confirmed = confirm(
          t('confirm.deleteExercise', { name: ex.name || ex.id }),
        );
        if (!confirmed) return;
        savingExercise.value = true;
        try {
          const { error } = await supabase
            .from('exercises')
            .delete()
            .eq('id', ex.id);
          if (error) {
            throw new Error('Delete exercise failed: ' + error.message);
          }
          await loadExercises();
          await loadDays();
        } catch (err) {
          console.error(err);
          alert(err.message || t('errors.deleteExercise'));
        } finally {
          savingExercise.value = false;
        }
      }

      async function loadDays(u = current.value) {
        if (!u) return;
        const { data, error } = await supabase
          .from('days')
          .select(`
                id, week, day_code, title, notes,
                day_exercises (
                  id, position, notes,
                  exercises ( id, name )
                )
              `)
          .eq('trainee_id', u.id)
          .order('week', { ascending: true })
          .order('day_code', { ascending: true })
          .order('position', { ascending: true, referencedTable: 'day_exercises' });
        if (error) {
          alert(t('errors.loadDays', { message: error.message }));
          return;
        }
        days.value = data || [];
        (days.value || []).forEach((d) => ensureSelection(d.id));
        (days.value || []).forEach(setDayEdit);
        (days.value || [])
          .flatMap((d) => d.day_exercises || [])
          .forEach(setDayExerciseEdit);
        (days.value || []).forEach((d, idx) => {
          if (expandedDays.value[d.id] === undefined) {
            setDayExpansion(d.id, idx === 0);
          }
        });
      }

      async function loadDashboardNotes() {
        dashboardNotesLoading.value = true;
        dashboardNotesError.value = '';
        const fetchNotes = (orderColumn) =>
          supabase
            .from('days')
            .select('id, notes, week, day_code, trainee_id, created_at, trainees ( name )')
            .not('notes', 'is', null)
            .order(orderColumn, { ascending: false })
            .limit(8);
        try {
          const trainerOnly = Boolean(currentTrainer.value && !currentAdmin.value);
          const visibleIds = trainerOnly
            ? (users.value || []).map((u) => u.id).filter(Boolean)
            : [];
          if (trainerOnly && !visibleIds.length) {
            dashboardNotes.value = [];
            return;
          }
          const applyFilter = (query) =>
            trainerOnly ? query.in('trainee_id', visibleIds) : query;
          let { data, error } = await applyFilter(fetchNotes('created_at'));
          if (error) {
            const fallback = await applyFilter(fetchNotes('id'));
            data = fallback.data;
            error = fallback.error;
          }
          if (error) {
            throw new Error(t('errors.loadDays', { message: error.message }));
          }
          dashboardNotes.value = (data || []).map((row) => ({
            id: row.id,
            notes: row.notes || '',
            traineeName: row.trainees?.name || shortId(row.trainee_id),
            dayLabel: formatWeekDayLabel(row.week || 1, row.day_code),
            dateLabel: row.created_at ? formatDate(row.created_at) : '',
          }));
        } catch (err) {
          console.error(err);
          dashboardNotes.value = [];
          dashboardNotesError.value = err.message || t('errors.loadDays');
        } finally {
          dashboardNotesLoading.value = false;
        }
      }

      async function addPlan() {
        if (!current.value) {
          alert(t('errors.selectTrainee'));
          return;
        }
        const name = (newPlanName.value || '').trim();
        if (!name) {
          alert(t('errors.planNameRequired'));
          return;
        }
        savingPlan.value = true;
        try {
          const payload = {
            trainee_id: current.value.id,
            name,
            status: (newPlanStatus.value || '').trim() || null,
            starts_on: newPlanStartsAt.value || null,
            notes: (newPlanNotes.value || '').trim() || null,
          };
          const { error } = await supabase.from('workout_plans').insert(payload);
          if (error) {
            throw new Error('Create plan failed: ' + error.message);
          }
          resetPlanForm();
          await loadPlans();
        } catch (err) {
          console.error(err);
          alert(err.message || t('errors.createPlan'));
        } finally {
          savingPlan.value = false;
        }
      }

      async function addDay() {
        if (!current.value) {
          alert(t('errors.selectTrainee'));
          return;
        }
        const week = Number(newDayWeek.value || 1);
        const dayCode = (newDayCode.value || '').trim();
        if (!dayCode) {
          alert(t('errors.dayCodeRequired'));
          return;
        }
        addingDay.value = true;
        try {
          const { error } = await supabase.from('days').insert({
            trainee_id: current.value.id,
            week: week,
            day_code: dayCode,
            title: newDayTitle.value.trim() || null,
            notes: newDayNotes.value.trim() || null,
          });
          if (error) {
            throw new Error('Create day failed: ' + error.message);
          }
          resetDayForm();
          await loadDays();
        } catch (err) {
          console.error(err);
          alert(err.message || t('errors.createDay'));
        } finally {
          addingDay.value = false;
        }
      }

      async function savePlan(plan) {
        if (!plan?.id) {
          alert(t('errors.missingPlan'));
          return;
        }
        const form = planEdits.value[plan.id] || {};
        const name = (form.name || '').trim();
        if (!name) {
          alert(t('errors.planNameRequired'));
          return;
        }
        savingPlan.value = true;
        try {
          const payload = {
            name,
            status: (form.status || '').trim() || null,
            starts_on: form.starts_on || null,
            notes: (form.notes || '').trim() || null,
          };
          const { error } = await supabase
            .from('workout_plans')
            .update(payload)
            .eq('id', plan.id);
          if (error) {
            throw new Error('Update plan failed: ' + error.message);
          }
          await loadPlans();
        } catch (err) {
          console.error(err);
          alert(err.message || t('errors.updatePlan'));
        } finally {
          savingPlan.value = false;
        }
      }

      async function deletePlan(plan) {
        if (!plan?.id) return;
        const confirmed = confirm(t('confirm.deletePlan'));
        if (!confirmed) return;
        savingPlan.value = true;
        try {
          const { error } = await supabase
            .from('workout_plans')
            .delete()
            .eq('id', plan.id);
          if (error) {
            throw new Error('Delete plan failed: ' + error.message);
          }
          await loadPlans();
        } catch (err) {
          console.error(err);
          alert(err.message || t('errors.deletePlan'));
        } finally {
          savingPlan.value = false;
        }
      }

      async function addExerciseToDay(day) {
        if (!day?.id) {
          alert(t('errors.missingDay'));
          return;
        }
        ensureSelection(day.id);
        const selection = exerciseSelection.value[day.id];
        const exerciseId = selection?.exercise_id;
        if (!exerciseId) {
          alert(t('errors.chooseExercise'));
          return;
        }
        addingExercise.value = true;
        try {
          const positions = (day.day_exercises || []).map((ex) =>
            typeof ex.position === 'number' ? ex.position : Number(ex.position) || 0,
          );
          const nextPosition = (positions.length ? Math.max(...positions) : 0) + 1;
          const { error } = await supabase.from('day_exercises').insert({
            day_id: day.id,
            exercise_id: exerciseId,
            notes: (selection.notes || '').trim() || null,
            position: nextPosition,
          });
          if (error) {
            throw new Error('Add exercise failed: ' + error.message);
          }
          exerciseSelection.value = {
            ...exerciseSelection.value,
            [day.id]: { exercise_id: '', notes: '' },
          };
          await loadDays();
        } catch (err) {
          console.error(err);
          alert(err.message || t('errors.addExercise'));
        } finally {
          addingExercise.value = false;
        }
      }

      async function saveDay(day) {
        if (!day?.id) {
          alert(t('errors.missingDay'));
          return;
        }
        const form = dayEdits.value[day.id] || {};
        const week = Number(form.week || 1);
        const dayCode = (form.day_code || '').trim();
        if (!dayCode) {
          alert(t('errors.dayCodeRequired'));
          return;
        }
        const payload = {
          week,
          day_code: dayCode,
          title: (form.title || '').trim() || null,
          notes: (form.notes || '').trim() || null,
        };
        const { error } = await supabase
          .from('days')
          .update(payload)
          .eq('id', day.id);
        if (error) {
          alert(t('errors.updateDay', { message: error.message }));
          return;
        }
        await loadDays();
      }

      async function deleteDay(day) {
        if (!day?.id) return;
        const confirmed = confirm(t('confirm.deleteDay'));
        if (!confirmed) return;
        const { error } = await supabase.from('days').delete().eq('id', day.id);
        if (error) {
          alert(t('errors.deleteDay', { message: error.message }));
          return;
        }
        await loadDays();
      }

      async function saveDayExercise(ex) {
        if (!ex?.id) {
          alert(t('errors.missingDayExercise'));
          return;
        }
        const form = dayExerciseEdits.value[ex.id] || {};
        const payload = {
          position: Number(form.position || 1),
          notes: (form.notes || '').trim() || null,
        };
        const { error } = await supabase
          .from('day_exercises')
          .update(payload)
          .eq('id', ex.id);
        if (error) {
          alert(t('errors.updateDayExercise', { message: error.message }));
          return;
        }
        await loadDays();
      }

      async function deleteDayExercise(ex) {
        if (!ex?.id) return;
        const confirmed = confirm(t('confirm.deleteDayExercise'));
        if (!confirmed) return;
        const { error } = await supabase
          .from('day_exercises')
          .delete()
          .eq('id', ex.id);
        if (error) {
          alert(t('errors.deleteDayExercise', { message: error.message }));
          return;
        }
        await loadDays();
      }

      onMounted(async () => {
        updateDocumentLanguage();
        loadAnnouncementsFromStorage();
        const {
          data: { session: sess },
        } = await supabase.auth.getSession();
        session.value = sess;
        user.value = sess?.user || null;
        if (session.value) await bootstrap();

        supabase.auth.onAuthStateChange((_e, s) => {
          session.value = s;
          user.value = s?.user || null;
          if (s) bootstrap();
        });
      });

      return {
        session,
        user,
        email,
        password,
        search,
        activeSection,
        locale,
        languageOptions,
        t,
        roleLabel,
        users,
        filteredUsers,
        overdueUsers,
        paymentSummary,
        paymentFilter,
        paymentFilterOptions,
        paymentUsers,
        canAssignTrainers,
        trainers,
        trainerSelections,
        trainerAssignmentSaving,
        current,
        days,
        maxTests,
        maxTestHistory,
        exerciseOptions,
        exerciseSelection,
        exerciseEdits,
        dayEdits,
        dayExerciseEdits,
        expandedDays,
        nextWeek,
        dayTitleSuggestions,
        scheduleSummary,
        dayNavigation,
        plans,
        planEdits,
        planStatuses,
        dayCodeOptions,
        newDayWeek,
        newDayCode,
        newDayTitle,
        newDayNotes,
        addingDay,
        addingExercise,
        savingExercise,
        savingPlan,
        newExerciseName,
        newPlanName,
        newPlanStatus,
        newPlanStartsAt,
        newPlanEndsAt,
        newPlanNotes,
        templateDayCount,
        templateDayOptions,
        programTemplateDays,
        dashboardNotes,
        dashboardNotesLoading,
        dashboardNotesError,
        announcements: computed(() =>
          (announcements.value || []).map((notice) => ({
            ...notice,
            dateLabel: formatNoticeDate(notice),
          })),
        ),
        newAnnouncement,
        loadingProgress,
        loadingMaxTests,
        maxTestsError,
        paymentSaving,
        progressFor,
        formatTestValue,
        formatCount,
        dayCodeLabel,
        planStatusLabel,
        applyNextWeek,
        setDayCode,
        emailPasswordSignIn,
        signOut,
        selectUser,
        loadDays,
        loadMaxTests,
        loadPlans,
        loadDashboardNotes,
        addAnnouncement,
        removeAnnouncement,
        addPlan,
        addDay,
        resetDayForm,
        resetExerciseForm,
        resetPlanForm,
        addExerciseDefinition,
        addExerciseToDay,
        updateExercise,
        deleteExercise,
        assignTrainerToTrainee,
        removeTrainerAssignment,
        resetExerciseEdit,
        filteredExerciseOptions,
        pickExercise,
        matchExercise,
        toggleDay,
        isDayOpen,
        jumpToDay,
        saveDay,
        resetDayEdit,
        deleteDay,
        resetPlanEdit,
        savePlan,
        deletePlan,
        saveDayExercise,
        resetDayExerciseEdit,
        deleteDayExercise,
        shortId,
        togglePayment,
        markPaymentPaid,
      };
    },
  }).mount('#app');
})();

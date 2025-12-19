(() => {
  const { createApp, ref, computed, onMounted } = Vue;

  // === Configure your Supabase project ===
  const SUPABASE_URL = 'https://jrqjysycoqhlnyufhliy.supabase.co';
  const SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpycWp5c3ljb3FobG55dWZobGl5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI0MzM0NTIsImV4cCI6MjA2ODAwOTQ1Mn0.3BVA-Ar9YtLGGO12Gt6NQkMl2cn18E_b48PGtlFxxCw';
  const g = window;
  const createClient =
    (g.supabase && g.supabase.createClient) ||
    (g.Supabase && g.Supabase.createClient) ||
    g.SUPABASE_CREATE_CLIENT;
  if (!createClient) {
    console.error('Supabase JS failed to load from all CDNs (jsDelivr/ESM).');
    alert('Supabase library failed to load. Check your network or replace with local copies.');
    return; // stop bootstrapping
  }
  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON);

  createApp({
    setup() {
      const session = ref(null);
      const user = ref(null);
      const email = ref('');
      const password = ref('');
      const search = ref('');
      const activeSection = ref('exercises');

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

      const nextWeek = computed(() => {
        if (!days.value.length) return 1;
        const weeks = days.value.map((d) => Number(d.week || 0));
        return Math.max(...weeks) + 1;
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
        await loadUsers();
        await loadExercises();
        await loadTraineeProgress();
        if (users.value.length) {
          selectUser(users.value[0]);
          await loadPlans(users.value[0]);
          await loadDays(users.value[0]);
        }
      }

      async function loadUsers() {
        const { data: traineeRows, error } = await supabase
          .from('trainees')
          .select('id, name')
          .order('name', { ascending: true });
        if (error) {
          console.error(error);
          alert('Failed to load trainees: ' + error.message);
          return;
        }

        users.value = (traineeRows || []).map((row) => ({
          ...row,
          displayName: row.name || shortId(row.id),
        }));
      }

      function selectUser(u) {
        current.value = u;
        days.value = [];
        plans.value = [];
        planEdits.value = {};
        expandedDays.value = {};
      }

      async function loadExercises() {
        const { data, error } = await supabase
          .from('exercises')
          .select('id, name')
          .order('name', { ascending: true });
        if (error) {
          console.error(error);
          alert('Failed to load exercises: ' + error.message);
          return;
        }
        exerciseOptions.value = data || [];
        (exerciseOptions.value || []).forEach(setExerciseEdit);
      }

      async function loadTraineeProgress() {
        loadingProgress.value = true;
        try {
          const { data, error } = await supabase
            .from('day_exercises')
            .select('id, completed, days ( trainee_id )');
          if (error) {
            throw new Error('Failed to load progress: ' + error.message);
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
          alert(err.message || 'Failed to load trainee progress.');
        } finally {
          loadingProgress.value = false;
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
          alert('Failed to load plans: ' + error.message);
          return;
        }
        plans.value = data || [];
        planEdits.value = {};
        (plans.value || []).forEach(setPlanEdit);
      }

      async function addExerciseDefinition() {
        const name = newExerciseName.value.trim();
        if (!name) {
          alert('Exercise name is required.');
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
          alert(err.message || 'Failed to create exercise.');
        } finally {
          savingExercise.value = false;
        }
      }

      async function updateExercise(ex) {
        if (!ex?.id) return;
        const name = (exerciseEdits.value[ex.id]?.name || '').trim();
        if (!name) {
          alert('Exercise name cannot be empty.');
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
          alert(err.message || 'Failed to update exercise.');
        } finally {
          savingExercise.value = false;
        }
      }

      async function deleteExercise(ex) {
        if (!ex?.id) return;
        const confirmed = confirm('Delete exercise "' + (ex.name || ex.id) + '"?');
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
          alert(err.message || 'Failed to delete exercise.');
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
          alert('Failed to load days: ' + error.message);
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

      async function addPlan() {
        if (!current.value) {
          alert('Select a trainee first.');
          return;
        }
        const name = (newPlanName.value || '').trim();
        if (!name) {
          alert('Plan name is required.');
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
          alert(err.message || 'Failed to create plan.');
        } finally {
          savingPlan.value = false;
        }
      }

      async function addDay() {
        if (!current.value) {
          alert('Select a trainee first.');
          return;
        }
        const week = Number(newDayWeek.value || 1);
        const dayCode = (newDayCode.value || '').trim();
        if (!dayCode) {
          alert('Day code is required.');
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
          alert(err.message || 'Failed to create day.');
        } finally {
          addingDay.value = false;
        }
      }

      async function savePlan(plan) {
        if (!plan?.id) {
          alert('Missing plan.');
          return;
        }
        const form = planEdits.value[plan.id] || {};
        const name = (form.name || '').trim();
        if (!name) {
          alert('Plan name is required.');
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
          alert(err.message || 'Failed to update plan.');
        } finally {
          savingPlan.value = false;
        }
      }

      async function deletePlan(plan) {
        if (!plan?.id) return;
        const confirmed = confirm('Delete this plan?');
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
          alert(err.message || 'Failed to delete plan.');
        } finally {
          savingPlan.value = false;
        }
      }

      async function addExerciseToDay(day) {
        if (!day?.id) {
          alert('Missing day.');
          return;
        }
        ensureSelection(day.id);
        const selection = exerciseSelection.value[day.id];
        const exerciseId = selection?.exercise_id;
        if (!exerciseId) {
          alert('Choose an exercise first.');
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
          alert(err.message || 'Failed to add exercise.');
        } finally {
          addingExercise.value = false;
        }
      }

      async function saveDay(day) {
        if (!day?.id) {
          alert('Missing day.');
          return;
        }
        const form = dayEdits.value[day.id] || {};
        const week = Number(form.week || 1);
        const dayCode = (form.day_code || '').trim();
        if (!dayCode) {
          alert('Day code is required.');
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
          alert('Failed to update day: ' + error.message);
          return;
        }
        await loadDays();
      }

      async function deleteDay(day) {
        if (!day?.id) return;
        const confirmed = confirm('Delete this day and its exercises?');
        if (!confirmed) return;
        const { error } = await supabase.from('days').delete().eq('id', day.id);
        if (error) {
          alert('Failed to delete day: ' + error.message);
          return;
        }
        await loadDays();
      }

      async function saveDayExercise(ex) {
        if (!ex?.id) {
          alert('Missing day exercise.');
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
          alert('Failed to update exercise: ' + error.message);
          return;
        }
        await loadDays();
      }

      async function deleteDayExercise(ex) {
        if (!ex?.id) return;
        const confirmed = confirm('Remove exercise from day?');
        if (!confirmed) return;
        const { error } = await supabase
          .from('day_exercises')
          .delete()
          .eq('id', ex.id);
        if (error) {
          alert('Failed to delete exercise: ' + error.message);
          return;
        }
        await loadDays();
      }

      onMounted(async () => {
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
        users,
        filteredUsers,
        current,
        days,
        exerciseOptions,
        exerciseSelection,
        exerciseEdits,
        dayEdits,
        dayExerciseEdits,
        expandedDays,
        nextWeek,
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
        loadingProgress,
        progressFor,
        applyNextWeek,
        setDayCode,
        emailPasswordSignIn,
        signOut,
        selectUser,
        loadDays,
        loadPlans,
        addPlan,
        addDay,
        resetDayForm,
        resetExerciseForm,
        resetPlanForm,
        addExerciseDefinition,
        addExerciseToDay,
        updateExercise,
        deleteExercise,
        resetExerciseEdit,
        filteredExerciseOptions,
        pickExercise,
        matchExercise,
        toggleDay,
        isDayOpen,
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
      };
    },
  }).mount('#app');
})();

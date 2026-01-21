import {
  createSupabaseClient,
  getBrowserLocale,
  getSupabaseLoadMessage,
} from './supabase-client.js';
import { createI18n, languageOptions } from './i18n.js';
import {
  dayCodeOptions,
  planStatuses,
  templateDayOptions,
  templateSlotsPerDay,
} from './constants.js';

(() => {
  const { createApp, ref, computed, onMounted, watch } = Vue;

  const fallbackLocale = getBrowserLocale();
  const { supabase, error } = createSupabaseClient();
  if (!supabase) {
    console.error(error);
    alert(getSupabaseLoadMessage(fallbackLocale));
    return;
  }

  createApp({
    setup() {
      const storedLocale = localStorage.getItem('adminLocale');
      const locale = ref(storedLocale || fallbackLocale);
      const {
        t,
        formatCount,
        dayCodeLabel,
        planStatusLabel,
        formatWeekDayLabel,
        formatWeekDayTitleLabel,
        updateDocumentLanguage,
      } = createI18n(locale);

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
      const exerciseSelection = ref({});
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
      const paymentHistory = ref([]);
      const loadingPayments = ref(false);
      const paymentsError = ref('');
      const dashboardNotes = ref([]);
      const dashboardNotesLoading = ref(false);
      const dashboardNotesError = ref('');
      const announcements = ref([]);
      const newAnnouncement = ref('');
      const addingDay = ref(false);
      const addingExercise = ref(false);
      const savingPlan = ref(false);
      const newDayWeek = ref(1);
      const newDayCode = ref('MON');
      const newDayTitle = ref('');
      const newDayNotes = ref('');
      const newPlanName = ref('');
      const newPlanStatus = ref(planStatuses[0]);
      const newPlanStartsAt = ref('');
      const newPlanEndsAt = ref('');
      const newPlanNotes = ref('');
      const templateDayCount = ref(3);
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

      const trainingCalendar = computed(() => {
        const order = new Map(dayCodeOptions.map((code, idx) => [code, idx]));
        return (days.value || [])
          .map((day) => {
            const exercises = day.day_exercises || [];
            const completedCount = exercises.filter((ex) => ex.completed).length;
            return {
              id: day.id,
              week: Number(day.week || 0),
              code: day.day_code?.toUpperCase() || '',
              total: exercises.length,
              completed: completedCount,
              trained: completedCount > 0,
              label: formatWeekDayTitleLabel(
                day.week || 1,
                day.day_code?.toUpperCase(),
                day.title,
              ),
            };
          })
          .sort((a, b) => {
            if (a.week !== b.week) return a.week - b.week;
            const aIdx = order.has(a.code) ? order.get(a.code) : 99;
            const bIdx = order.has(b.code) ? order.get(b.code) : 99;
            if (aIdx !== bIdx) return aIdx - bIdx;
            return a.label.localeCompare(b.label);
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
            name: plan.title || '',
            status: plan.status || planStatuses[0],
            starts_on: normalizeDateInput(plan.starts_on),
            notes: plan.notes || '',
          },
        };
      }

      function resolveDefaultPlanId() {
        const list = plans.value || [];
        if (!list.length) return null;
        const active = list.find(
          (plan) => (plan.status || '').toLowerCase() === 'active',
        );
        return (active || list[0]).id || null;
      }

      function resetPlanEdit(plan) {
        setPlanEdit(plan);
      }

      function ensureSelection(dayId) {
        if (!exerciseSelection.value[dayId]) {
          exerciseSelection.value = {
            ...exerciseSelection.value,
            [dayId]: { exercise: '', notes: '' },
          };
          return;
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
        await loadTraineeProgress();
        await loadDashboardNotes();
        if (users.value.length) {
          await selectUser(users.value[0]);
          await loadPlans(users.value[0]);
          await loadDays(users.value[0]);
          await loadPaymentHistory(users.value[0]);
        }
      }

      async function loadAccess() {
        const userId = user.value?.id;
        if (!userId) return;
        try {
          const { data: adminRow, error: adminError } = await supabase
            .from('admins')
            .select('id, name, can_assign_trainers')
            .eq('id', userId)
            .maybeSingle();
          if (adminError && adminError.code !== 'PGRST116') {
            throw new Error(adminError.message);
          }
          const { data: trainerRow, error: trainerError } = await supabase
            .from('trainers')
            .select('id, name')
            .eq('id', userId)
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
          'id, name, trainee_trainers ( trainer_id, trainers ( id, name ) )';
        let query = supabase.from('trainees').select(baseSelect);
        if (isTrainerOnly) {
          query = supabase
            .from('trainees')
            .select(
              'id, name, trainee_trainers!inner ( trainer_id, trainers ( id, name ) )',
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

        const traineeIds = (traineeRows || [])
          .map((row) => row.id)
          .filter(Boolean);
        const paidMap = new Map();
        if (traineeIds.length) {
          const monthStart = currentMonthStart();
          const { data: paymentRows, error: paymentError } = await supabase
            .from('trainee_monthly_payments')
            .select('trainee_id, paid')
            .eq('month_start', monthStart)
            .in('trainee_id', traineeIds);
          if (paymentError) {
            console.error(paymentError);
            alert(
              t('errors.loadPayments', {
                message: paymentError.message,
              }),
            );
          } else {
            (paymentRows || []).forEach((row) => {
              paidMap.set(row.trainee_id, Boolean(row.paid));
            });
          }
        }

        users.value = (traineeRows || []).map((row) => ({
          ...row,
          paid: paidMap.get(row.id) || false,
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
        paymentHistory.value = [];
        paymentsError.value = '';
        await loadMaxTests(u);
      }

      async function openTrainee(u) {
        activeSection.value = 'program';
        await selectUser(u);
        await Promise.all([loadDays(u), loadPlans(u), loadPaymentHistory(u)]);
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

      async function loadDays(u = current.value) {
        if (!u) return;
        const { data, error } = await supabase
          .from('days')
          .select(`
                id, week, day_code, title, notes,
                workout_plan_days (
                  id, position,
                  workout_plans ( id, title, starts_on, created_at )
                ),
                day_exercises (
                  id, position, notes, completed, exercise
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

      async function loadPaymentHistory(u = current.value) {
        if (!u) return;
        loadingPayments.value = true;
        paymentsError.value = '';
        try {
          const { data, error } = await supabase
            .from('trainee_monthly_payments')
            .select('id, month_start, paid, paid_at')
            .eq('trainee_id', u.id)
            .order('month_start', { ascending: false });
          if (error) {
            throw new Error(error.message);
          }
          paymentHistory.value = data || [];
        } catch (err) {
          console.error(err);
          paymentHistory.value = [];
          paymentsError.value = err.message || t('errors.loadPayments');
        } finally {
          loadingPayments.value = false;
        }
      }

      async function loadDashboardNotes() {
        dashboardNotesLoading.value = true;
        dashboardNotesError.value = '';
        const fetchNotes = (orderColumn) =>
          supabase
            .from('trainee_feedbacks')
            .select('id, message, created_at, read_at, trainee_id, trainees ( name )')
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
            message: row.message || '',
            traineeName: row.trainees?.name || shortId(row.trainee_id),
            statusLabel: row.read_at
              ? t('dashboard.feedbackRead')
              : t('dashboard.feedbackUnread'),
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
        const title = (newPlanName.value || '').trim();
        if (!title) {
          alert(t('errors.planNameRequired'));
          return;
        }
        savingPlan.value = true;
        try {
          const payload = {
            trainee_id: current.value.id,
            title,
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
          const { data, error } = await supabase
            .from('days')
            .insert({
              trainee_id: current.value.id,
              week: week,
              day_code: dayCode,
              title: newDayTitle.value.trim() || null,
              notes: newDayNotes.value.trim() || null,
            })
            .select('id')
            .single();
          if (error) {
            throw new Error('Create day failed: ' + error.message);
          }
          const planId = resolveDefaultPlanId();
          if (planId && data?.id) {
            const { data: positions, error: positionError } = await supabase
              .from('workout_plan_days')
              .select('position')
              .eq('plan_id', planId);
            if (positionError) {
              console.error(positionError);
              alert('Plan association failed: ' + positionError.message);
            } else {
              const numericPositions = (positions || [])
                .map((row) => Number(row.position || 0))
                .filter((value) => Number.isFinite(value));
              const nextPosition =
                (numericPositions.length ? Math.max(...numericPositions) : 0) + 1;
              const { error: linkError } = await supabase
                .from('workout_plan_days')
                .insert({
                  plan_id: planId,
                  day_id: data.id,
                  position: nextPosition,
                });
              if (linkError) {
                console.error(linkError);
                alert('Plan association failed: ' + linkError.message);
              }
            }
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
        const title = (form.name || '').trim();
        if (!title) {
          alert(t('errors.planNameRequired'));
          return;
        }
        savingPlan.value = true;
        try {
          const payload = {
            title,
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
        const exercise = (selection?.exercise || '').trim();
        if (!exercise) {
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
            exercise,
            notes: (selection.notes || '').trim() || null,
            position: nextPosition,
          });
          if (error) {
            throw new Error('Add exercise failed: ' + error.message);
          }
          exerciseSelection.value = {
            ...exerciseSelection.value,
            [day.id]: { exercise: '', notes: '' },
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
        exerciseSelection,
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
        savingPlan,
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
        paymentHistory,
        loadingPayments,
        paymentsError,
        trainingCalendar,
        progressFor,
        formatTestValue,
        formatDate,
        formatCount,
        dayCodeLabel,
        planStatusLabel,
        applyNextWeek,
        setDayCode,
        emailPasswordSignIn,
        signOut,
        selectUser,
        openTrainee,
        loadDays,
        loadMaxTests,
        loadPlans,
        loadPaymentHistory,
        loadDashboardNotes,
        addAnnouncement,
        removeAnnouncement,
        addPlan,
        addDay,
        resetDayForm,
        resetPlanForm,
        addExerciseToDay,
        assignTrainerToTrainee,
        removeTrainerAssignment,
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

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
  templateExerciseOptions,
  templateWeekOptions,
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
      const exercises = ref([]);
      const exerciseFilter = ref('');
      const exerciseForm = ref({
        name: '',
        slug: '',
        difficulty: 'beginner',
        sort_order: 1,
      });
      const exerciseEdits = ref({});
      const exerciseSaving = ref({});
      const creatingExercise = ref(false);
      const loadingExercises = ref(false);
      const exercisesError = ref('');

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
      const traineeWeekStatus = ref({});
      const loadingWeekStatus = ref(false);
      const weekStatusError = ref('');
      const maxTests = ref([]);
      const loadingMaxTests = ref(false);
      const maxTestsError = ref('');
      const coachTipDraft = ref('');
      const coachTipSaving = ref(false);
      const paymentSaving = ref({});
      const paymentAmountEdits = ref({});
      const paymentAmountSaving = ref({});
      const paymentHistory = ref([]);
      const loadingPayments = ref(false);
      const paymentsError = ref('');
      const completedExercises = ref([]);
      const loadingCompletedExercises = ref(false);
      const completedExercisesError = ref('');
      const dashboardNotes = ref([]);
      const dashboardNotesLoading = ref(false);
      const dashboardNotesError = ref('');
      const dashboardBurndown = ref({
        chartWidth: 760,
        chartHeight: 240,
        dates: [],
        lines: [],
        maxValue: 0,
        minDateLabel: '',
        maxDateLabel: '',
      });
      const dashboardBurndownLoading = ref(false);
      const dashboardBurndownError = ref('');
      const addingDay = ref(false);
      const addingExercise = ref(false);
      const savingPlan = ref(false);
      const newDayWeek = ref(1);
      const newDayCode = ref('A');
      const newDayTitle = ref('');
      const newDayNotes = ref('');
      const newPlanName = ref('');
      const newPlanStatus = ref(planStatuses[0]);
      const newPlanStartsAt = ref('');
      const newPlanEndsAt = ref('');
      const newPlanNotes = ref('');
      const templateDayCount = ref(3);
      const templateWeekCount = ref(templateWeekOptions[0] || 1);
      const templateSlotCount = ref(templateSlotsPerDay);
      const templatePlanName = ref('');
      const programTemplateDays = ref(
        buildTemplateDays(
          templateDayCount.value * templateWeekCount.value,
          templateSlotCount.value,
          [],
        ),
      );
      const selectedTemplateDay = ref(0);
      const selectedTemplateSlot = ref(0);
      const savingTemplatePlan = ref(false);
      watch(
        [templateDayCount, templateWeekCount, templateSlotCount],
        ([nextCount, nextWeeks, nextSlots]) => {
          const totalDays = nextCount * nextWeeks;
          programTemplateDays.value = buildTemplateDays(
            totalDays,
            nextSlots,
            programTemplateDays.value,
          );
        },
      );
      watch(programTemplateDays, (nextDays) => {
        if (selectedTemplateDay.value >= nextDays.length) {
          selectedTemplateDay.value = 0;
        }
        const nextSlots = nextDays[selectedTemplateDay.value]?.slots || [];
        if (selectedTemplateSlot.value >= nextSlots.length) {
          selectedTemplateSlot.value = 0;
        }
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
            title: previous?.title || '',
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

      const showLastWeekCard = computed(() => Boolean(currentTrainer.value));
      const exerciseDifficultyOptions = [
        'beginner',
        'intermediate',
        'advanced',
      ];

      const filteredExercises = computed(() => {
        const query = (exerciseFilter.value || '').trim().toLowerCase();
        const list = exercises.value || [];
        if (!query) return list;
        return list.filter((exercise) => {
          const name = (exercise.name || '').toLowerCase();
          const slug = (exercise.slug || '').toLowerCase();
          const difficulty = (exercise.difficulty || '').toLowerCase();
          return (
            name.includes(query) ||
            slug.includes(query) ||
            difficulty.includes(query)
          );
        });
      });

      const activeTemplateDay = computed(
        () =>
          programTemplateDays.value[selectedTemplateDay.value] ||
          programTemplateDays.value[0] ||
          { slots: [], title: '', id: 'template-empty' },
      );
      const activeTemplateSlots = computed(() => activeTemplateDay.value.slots || []);
      const activeTemplateSlot = computed(
        () =>
          activeTemplateSlots.value[selectedTemplateSlot.value] ||
          activeTemplateSlots.value[0] ||
          { exercise: '', sets: '', notes: '' },
      );

      const selectTemplateDay = (index) => {
        selectedTemplateDay.value = index;
        selectedTemplateSlot.value = 0;
      };

      const selectTemplateSlot = (index) => {
        selectedTemplateSlot.value = index;
      };

      const incrementTemplateDayCount = () => {
        const next = templateDayOptions.find(
          (option) => option > templateDayCount.value,
        );
        if (next) templateDayCount.value = next;
      };

      const incrementTemplateSlotCount = () => {
        const next = templateExerciseOptions.find(
          (option) => option > templateSlotCount.value,
        );
        if (next) templateSlotCount.value = next;
      };

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
        const amountTotals = (users.value || []).reduce(
          (totals, u) => {
            const numericAmount = Number(u.paymentAmount);
            const amount = Number.isNaN(numericAmount) ? 0 : numericAmount;
            totals.forecasted += amount;
            if (u.paid) {
              totals.received += amount;
            } else {
              totals.due += amount;
            }
            return totals;
          },
          { forecasted: 0, received: 0, due: 0 },
        );
        return {
          total,
          paid,
          overdue: total - paid,
          forecastedAmount: amountTotals.forecasted,
          receivedAmount: amountTotals.received,
          dueAmount: amountTotals.due,
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

      const completedExerciseLog = computed(() => {
        const order = new Map(dayCodeOptions.map((code, idx) => [code, idx]));
        return (completedExercises.value || [])
          .map((entry) => {
            const day = entry.days || {};
            const week = Number(day.week || 0);
            const code = day.day_code?.toUpperCase() || '';
            const dayLabel = formatWeekDayTitleLabel(
              day.week || 1,
              code,
              day.title,
            );
            const completedAt = parseCompletedAt(day.completed_at);
            const timestamp = completedAt ? completedAt.valueOf() : null;
            const notes = (entry.notes || '').trim();
            const traineeNotes = (entry.trainee_notes || '').trim();
            return {
              id: entry.id,
              exercise:
                (entry.exercise || '').trim() || t('labels.unknownExercise'),
              dayLabel,
              timeLabel: completedAt ? formatTime(completedAt) : '',
              notes,
              traineeNotes,
              sortValue:
                timestamp ??
                (week * 100 + (order.has(code) ? order.get(code) : 99)),
            };
          })
          .sort((a, b) => b.sortValue - a.sortValue);
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

      const dashboardTrainees = computed(() =>
        (filteredUsers.value || []).slice().sort((a, b) => {
          const nameA = (a.displayName || '').toLowerCase();
          const nameB = (b.displayName || '').toLowerCase();
          if (nameA && nameB) return nameA.localeCompare(nameB);
          return (a.id || '').localeCompare(b.id || '');
        }),
      );

      const lastWeekTrainees = computed(() => {
        const statusMap = traineeWeekStatus.value || {};
        return (filteredUsers.value || [])
          .filter((u) => statusMap[u.id]?.isLastWeek)
          .slice()
          .sort((a, b) => {
            const nameA = (a.displayName || '').toLowerCase();
            const nameB = (b.displayName || '').toLowerCase();
            if (nameA && nameB) return nameA.localeCompare(nameB);
            return (a.id || '').localeCompare(b.id || '');
          });
      });

      const weekStatusFor = (trainee) => {
        if (!trainee?.id) return '';
        const status = traineeWeekStatus.value?.[trainee.id];
        if (!status || !status.lastWeek) return '';
        return t('dashboard.lastWeekProgress', {
          current: status.currentWeek || 0,
          total: status.lastWeek,
        });
      };

      const shortId = (id) => (id ? id.toString().slice(0, 8) + '…' : '');

      const formatTestValue = (value) => {
        const numeric = Number(value || 0);
        return Number.isInteger(numeric) ? numeric.toFixed(0) : numeric.toFixed(1);
      };

      const formatAmount = (value) => {
        if (value === null || value === undefined || value === '') return '';
        const numeric = Number(value);
        if (Number.isNaN(numeric)) return String(value);
        const localeTag = locale.value === 'it' ? 'it-IT' : 'en-US';
        return new Intl.NumberFormat(localeTag, {
          minimumFractionDigits: 2,
          maximumFractionDigits: 2,
        }).format(numeric);
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

      const formatTime = (value) => {
        if (!value) return '';
        const parsed = value instanceof Date ? value : new Date(value);
        if (Number.isNaN(parsed.valueOf())) return '';
        const localeTag = locale.value === 'it' ? 'it-IT' : 'en-US';
        return parsed.toLocaleTimeString(localeTag, {
          hour: '2-digit',
          minute: '2-digit',
        });
      };

      const parseCompletedAt = (value) => {
        if (!value) return null;
        const direct = new Date(value);
        if (!Number.isNaN(direct.valueOf())) return direct;
        if (typeof value === 'string') {
          const withDate = value.includes('T')
            ? value
            : `1970-01-01T${value}`;
          const parsed = new Date(withDate);
          if (!Number.isNaN(parsed.valueOf())) return parsed;
        }
        return null;
      };

      const currentMonthStart = () => {
        const now = new Date();
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, '0');
        return `${year}-${month}-01`;
      };

      const dateKey = (value) => {
        const parsed = value instanceof Date ? value : new Date(value);
        if (Number.isNaN(parsed.valueOf())) return '';
        const year = parsed.getFullYear();
        const month = String(parsed.getMonth() + 1).padStart(2, '0');
        const day = String(parsed.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
      };

      const buildDateRange = (daysCount) => {
        const today = new Date();
        const end = new Date(
          today.getFullYear(),
          today.getMonth(),
          today.getDate(),
        );
        const start = new Date(end);
        start.setDate(start.getDate() - (daysCount - 1));
        const dates = [];
        for (let i = 0; i < daysCount; i += 1) {
          const next = new Date(start);
          next.setDate(start.getDate() + i);
          dates.push(next);
        }
        return { start, end, dates };
      };

      const normalizePaymentAmount = (value) => {
        if (value === null || value === undefined || value === '') return null;
        const numeric = Number(value);
        if (Number.isNaN(numeric)) return null;
        return numeric;
      };

      const templateDayLabel = (index) => {
        const daysPerWeek = templateDayCount.value || dayCodeOptions.length;
        const week = Math.floor(index / daysPerWeek) + 1;
        const dayCode = dayCodeOptions[index % daysPerWeek];
        return formatWeekDayLabel(week, dayCode);
      };

      function resetDayForm() {
        newDayWeek.value = 1;
        newDayCode.value = 'A';
        newDayTitle.value = '';
        newDayNotes.value = '';
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

      async function saveTemplatePlan() {
        if (!current.value) {
          alert(t('errors.selectTrainee'));
          return;
        }
        const planTitle = (templatePlanName.value || '').trim();
        if (!planTitle) {
          alert(t('errors.planNameRequired'));
          return;
        }
        savingTemplatePlan.value = true;
        try {
          const { data: planRow, error: planError } = await supabase
            .from('workout_plans')
            .insert({
              trainee_id: current.value.id,
              title: planTitle,
              status: planStatuses[0],
              starts_on: null,
              notes: null,
            })
            .select('id')
            .single();
          if (planError) {
            throw new Error('Create plan failed: ' + planError.message);
          }
          const dayPayloads = (programTemplateDays.value || []).map(
            (day, index) => ({
              week: Math.floor(index / templateDayCount.value) + 1,
              day_code: dayCodeOptions[index % templateDayCount.value],
              title: (day.title || '').trim() || null,
              notes: null,
            }),
          );
          console.log(dayPayloads);
          const { data: dayRows, error: dayError } = await supabase
            .from('days')
            .insert(dayPayloads)
            .select('id');
          if (dayError) {
            throw new Error('Create days failed: ' + dayError.message);
          }
          const planDayPayloads = (dayRows || []).map((row, index) => ({
            plan_id: planRow.id,
            day_id: row.id,
            position: index + 1,
          }));
          if (planDayPayloads.length) {
            const { error: linkError } = await supabase
              .from('workout_plan_days')
              .insert(planDayPayloads);
            if (linkError) {
              throw new Error(
                'Plan association failed: ' + linkError.message,
              );
            }
          }
          const exercisePayloads = [];
          (dayRows || []).forEach((row, dayIndex) => {
            const slots = programTemplateDays.value?.[dayIndex]?.slots || [];
            slots.forEach((slot, slotIndex) => {
              const exercise = (slot.exercise || '').trim();
              if (!exercise) return;
              exercisePayloads.push({
                day_id: row.id,
                position: slotIndex + 1,
                notes: null,
                completed: false,
                exercise,
              });
            });
          });
          if (exercisePayloads.length) {
            const { error: exerciseError } = await supabase
              .from('day_exercises')
              .insert(exercisePayloads);
            if (exerciseError) {
              throw new Error('Create exercises failed: ' + exerciseError.message);
            }
          }
          await loadDays();
          await loadPlans();
          templateDayCount.value = templateDayOptions[0] || 1;
          templateWeekCount.value = templateWeekOptions[0] || 1;
          templateSlotCount.value = templateSlotsPerDay;
          templatePlanName.value = '';
          programTemplateDays.value = buildTemplateDays(
            templateDayCount.value * templateWeekCount.value,
            templateSlotCount.value,
            [],
          );
        } catch (err) {
          console.error(err);
          alert(err.message || t('errors.createDay'));
        } finally {
          savingTemplatePlan.value = false;
        }
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
        await loadDashboardBurndown();
        await loadDashboardNotes();
        if (users.value.length) {
          await selectUser(users.value[0]);
          await loadPlans(users.value[0]);
          await loadDays(users.value[0]);
          await loadPaymentHistory(users.value[0]);
          await loadCompletedExercises(users.value[0]);
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

      function setExerciseEdit(exercise) {
        if (!exercise?.id) return;
        exerciseEdits.value = {
          ...exerciseEdits.value,
          [exercise.id]: {
            name: exercise.name || '',
            slug: exercise.slug || '',
            difficulty: exercise.difficulty || 'beginner',
            sort_order: Number(exercise.sort_order ?? 1),
          },
        };
      }

      function normalizeExerciseSlug(value) {
        return (value || '')
          .toLowerCase()
          .trim()
          .replace(/[^a-z0-9]+/g, '-')
          .replace(/(^-|-$)+/g, '');
      }

      function formatDifficultyLabel(value) {
        const text = (value || '').trim();
        if (!text) return '';
        return text.charAt(0).toUpperCase() + text.slice(1);
      }

      function resetExerciseForm() {
        exerciseForm.value = {
          name: '',
          slug: '',
          difficulty: 'beginner',
          sort_order: 1,
        };
      }

      async function loadExercises(u = current.value) {
        loadingExercises.value = true;
        exercisesError.value = '';
        try {
          let data = [];
          let error = null;
          if (u?.id) {
            const response = await supabase
              .from('trainee_exercise_unlocks')
              .select(
                'exercises ( id, slug, name, difficulty, sort_order, created_at )',
              )
              .eq('trainee_id', u.id)
              .order('sort_order', {
                ascending: true,
                referencedTable: 'exercises',
              })
              .order('name', { ascending: true, referencedTable: 'exercises' });
            data = response.data;
            error = response.error;
          } else {
            const response = await supabase
              .from('exercises')
              .select('id, slug, name, difficulty, sort_order, created_at')
              .order('sort_order', { ascending: true })
              .order('name', { ascending: true });
            data = response.data;
            error = response.error;
          }
          if (error) {
            throw new Error(t('errors.loadExercises', { message: error.message }));
          }
          if (u?.id) {
            exercises.value = (data || [])
              .map((row) => row.exercises)
              .filter(Boolean);
          } else {
            exercises.value = data || [];
          }
          exerciseEdits.value = {};
          (exercises.value || []).forEach(setExerciseEdit);
        } catch (error) {
          console.error(error);
          exercises.value = [];
          exercisesError.value = error.message || t('errors.loadExercises');
        } finally {
          loadingExercises.value = false;
        }
      }

      async function createExercise() {
        if (creatingExercise.value) return;
        const name = (exerciseForm.value.name || '').trim();
        if (!name) {
          alert(t('errors.exerciseNameRequired'));
          return;
        }
        const slugInput = (exerciseForm.value.slug || '').trim();
        const slug = slugInput || normalizeExerciseSlug(name);
        if (!slug) {
          alert(t('errors.exerciseNameRequired'));
          return;
        }
        const difficulty =
          (exerciseForm.value.difficulty || '').trim() || 'beginner';
        const sortOrder = Number(exerciseForm.value.sort_order || 1);
        creatingExercise.value = true;
        try {
          const { error } = await supabase.from('exercises').insert({
            name,
            slug,
            difficulty,
            sort_order: Number.isFinite(sortOrder) ? sortOrder : 1,
          });
          if (error) {
            throw new Error('Create exercise failed: ' + error.message);
          }
          resetExerciseForm();
          await loadExercises();
        } catch (error) {
          console.error(error);
          alert(error.message || t('errors.createExercise'));
        } finally {
          creatingExercise.value = false;
        }
      }

      async function saveExercise(exercise) {
        if (!exercise?.id) return;
        if (exerciseSaving.value[exercise.id]) return;
        const form = exerciseEdits.value[exercise.id] || {};
        const name = (form.name || '').trim();
        if (!name) {
          alert(t('errors.exerciseNameRequired'));
          return;
        }
        const slugInput = (form.slug || '').trim();
        const slug = slugInput || normalizeExerciseSlug(name);
        if (!slug) {
          alert(t('errors.exerciseNameRequired'));
          return;
        }
        const difficulty = (form.difficulty || '').trim() || 'beginner';
        const sortOrder = Number(form.sort_order || 1);
        exerciseSaving.value = {
          ...exerciseSaving.value,
          [exercise.id]: true,
        };
        try {
          const { error } = await supabase
            .from('exercises')
            .update({
              name,
              slug,
              difficulty,
              sort_order: Number.isFinite(sortOrder) ? sortOrder : 1,
            })
            .eq('id', exercise.id);
          if (error) {
            throw new Error('Update exercise failed: ' + error.message);
          }
          await loadExercises();
        } catch (error) {
          console.error(error);
          alert(error.message || t('errors.updateExercise'));
        } finally {
          exerciseSaving.value = {
            ...exerciseSaving.value,
            [exercise.id]: false,
          };
        }
      }

      async function deleteExercise(exercise) {
        if (!exercise?.id) return;
        const confirmed = confirm(
          t('confirm.deleteExercise', {
            name: exercise.name || exercise.slug || exercise.id,
          }),
        );
        if (!confirmed) return;
        exerciseSaving.value = {
          ...exerciseSaving.value,
          [exercise.id]: true,
        };
        try {
          const { error } = await supabase
            .from('exercises')
            .delete()
            .eq('id', exercise.id);
          if (error) {
            throw new Error('Delete exercise failed: ' + error.message);
          }
          await loadExercises();
        } catch (error) {
          console.error(error);
          alert(error.message || t('errors.deleteExercise'));
        } finally {
          exerciseSaving.value = {
            ...exerciseSaving.value,
            [exercise.id]: false,
          };
        }
      }

      async function loadUsers() {
        const isTrainerOnly = Boolean(currentTrainer.value && !currentAdmin.value);
        const baseSelect =
          'id, name, trainee_trainers ( trainer_id, trainers ( id, name ) , coach_tip )';
        let query = supabase.from('trainees').select(baseSelect);
        if (isTrainerOnly) {
          query = supabase
            .from('trainees')
            .select(
              'id, name, trainee_trainers!inner ( trainer_id, trainers ( id, name ), coach_tip )',
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
        const amountMap = new Map();
        const paidAtMap = new Map();
        if (traineeIds.length) {
          const monthStart = currentMonthStart();
          const { data: paymentRows, error: paymentError } = await supabase
            .from('trainee_monthly_payments')
            .select('trainee_id, paid, paid_at, amount')
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
              amountMap.set(row.trainee_id, row.amount ?? null);
              paidAtMap.set(row.trainee_id, row.paid_at ?? null);
            });
          }
        }

        users.value = (traineeRows || []).map((row) => ({
          ...row,
          paid: paidMap.get(row.id) || false,
          paymentAmount: amountMap.get(row.id) ?? null,
          paymentPaidAt: paidAtMap.get(row.id) ?? null,
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
          if (paymentAmountEdits.value[trainee.id] === undefined) {
            paymentAmountEdits.value = {
              ...paymentAmountEdits.value,
              [trainee.id]:
                trainee.paymentAmount === null || trainee.paymentAmount === undefined
                  ? ''
                  : String(trainee.paymentAmount),
            };
          }
        });
        await loadTraineeWeekStatus();
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
        const previousPaidAt = u.paymentPaidAt;
        u.paid = nextPaid;
        paymentSaving.value = { ...paymentSaving.value, [u.id]: true };
        try {
          const monthStart = currentMonthStart();
          const nextAmount = normalizePaymentAmount(
            paymentAmountEdits.value[u.id] ?? u.paymentAmount,
          );
          const nextPaidAt = nextPaid ? new Date().toISOString() : null;
          const { error: monthlyError } = await supabase
            .from('trainee_monthly_payments')
            .upsert(
              {
                trainee_id: u.id,
                month_start: monthStart,
                paid: nextPaid,
                paid_at: nextPaidAt,
                amount: nextAmount,
              },
              { onConflict: 'trainee_id,month_start' },
            );
          if (monthlyError) {
            throw new Error('Update monthly payment failed: ' + monthlyError.message);
          }
          u.paymentAmount = nextAmount;
          u.paymentPaidAt = nextPaidAt;
        } catch (err) {
          console.error(err);
          u.paid = previousPaid;
          u.paymentPaidAt = previousPaidAt;
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

      async function savePaymentAmount(u) {
        if (!u?.id) return;
        if (paymentAmountSaving.value[u.id]) return;
        paymentAmountSaving.value = { ...paymentAmountSaving.value, [u.id]: true };
        try {
          const monthStart = currentMonthStart();
          const nextAmount = normalizePaymentAmount(paymentAmountEdits.value[u.id]);
          const nextPaidAt =
            u.paymentPaidAt || (u.paid ? new Date().toISOString() : null);
          const { error: monthlyError } = await supabase
            .from('trainee_monthly_payments')
            .upsert(
              {
                trainee_id: u.id,
                month_start: monthStart,
                paid: u.paid,
                paid_at: nextPaidAt,
                amount: nextAmount,
              },
              { onConflict: 'trainee_id,month_start' },
            );
          if (monthlyError) {
            throw new Error(
              'Update monthly payment amount failed: ' + monthlyError.message,
            );
          }
          u.paymentAmount = nextAmount;
          u.paymentPaidAt = nextPaidAt;
        } catch (err) {
          console.error(err);
          alert(err.message || t('errors.updatePayment'));
        } finally {
          paymentAmountSaving.value = {
            ...paymentAmountSaving.value,
            [u.id]: false,
          };
        }
      }

      async function selectUser(u) {
        current.value = u;
        days.value = [];
        plans.value = [];
        planEdits.value = {};
        expandedDays.value = {};
        maxTests.value = [];
        maxTestsError.value = '';
        completedExercises.value = [];
        completedExercisesError.value = '';
        paymentHistory.value = [];
        paymentsError.value = '';
        coachTipDraft.value = u?.coach_tip || '';
        await loadExercises(u);
        await loadMaxTests(u);
      }

      async function openTrainee(u) {
        activeSection.value = 'program';
        await selectUser(u);
        await Promise.all([
          loadDays(u),
          loadPlans(u),
          loadPaymentHistory(u),
          loadCompletedExercises(u),
        ]);
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
            .select(
              'id, completed, days!inner ( workout_plan_days!inner ( workout_plans!inner ( trainee_id ) ) )',
            );
          if (trainerOnly) {
            query = query.in(
              'days.workout_plan_days.workout_plans.trainee_id',
              visibleIds,
            );
          }
          const { data, error } = await query;
          if (error) {
            throw new Error(t('errors.loadProgress', { message: error.message }));
          }
          const progress = {};
          (data || []).forEach((row) => {
            const planEntries = row.days?.workout_plan_days || [];
            const traineeId = planEntries?.[0]?.workout_plans?.trainee_id;
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

      async function loadTraineeWeekStatus() {
        loadingWeekStatus.value = true;
        weekStatusError.value = '';
        try {
          const trainerOnly = Boolean(currentTrainer.value && !currentAdmin.value);
          const visibleIds = trainerOnly
            ? (users.value || []).map((u) => u.id).filter(Boolean)
            : [];
          if (trainerOnly && !visibleIds.length) {
            traineeWeekStatus.value = {};
            return;
          }
          let dayQuery = supabase
            .from('days')
            .select(
              'week, workout_plan_days!inner ( workout_plans!inner ( trainee_id ) )',
            );
          if (trainerOnly) {
            dayQuery = dayQuery.in(
              'workout_plan_days.workout_plans.trainee_id',
              visibleIds,
            );
          }
          const { data: dayRows, error: dayError } = await dayQuery;
          if (dayError) {
            throw new Error(dayError.message);
          }

          const maxWeekByTrainee = {};
          (dayRows || []).forEach((row) => {
            const planEntries = row.workout_plan_days || [];
            const traineeId = planEntries?.[0]?.workout_plans?.trainee_id;
            if (!traineeId) return;
            const week = Number(row.week || 0);
            const current = maxWeekByTrainee[traineeId] || 0;
            if (week > current) {
              maxWeekByTrainee[traineeId] = week;
            }
          });

          let completedQuery = supabase
            .from('day_exercises')
            .select(
              'id, completed, days!inner ( week, completed_at, workout_plan_days!inner ( workout_plans!inner ( trainee_id ) ) )',
            )
            .eq('completed', true);
          if (trainerOnly) {
            completedQuery = completedQuery.in(
              'days.workout_plan_days.workout_plans.trainee_id',
              visibleIds,
            );
          }
          const { data: completedRows, error: completedError } =
            await completedQuery;
          if (completedError) {
            throw new Error(completedError.message);
          }

          const latestByTrainee = {};
          (completedRows || []).forEach((row) => {
            const day = row.days || {};
            const planEntries = day.workout_plan_days || [];
            const traineeId = planEntries?.[0]?.workout_plans?.trainee_id;
            if (!traineeId) return;
            const week = Number(day.week || 0);
            const completedAt = day.completed_at
              ? Date.parse(day.completed_at)
              : null;
            const existing = latestByTrainee[traineeId];
            if (!existing) {
              latestByTrainee[traineeId] = {
                week,
                timestamp: completedAt || 0,
              };
              return;
            }
            const existingTime = existing.timestamp || 0;
            if (completedAt && completedAt >= existingTime) {
              latestByTrainee[traineeId] = { week, timestamp: completedAt };
              return;
            }
            if (!completedAt && week > existing.week) {
              latestByTrainee[traineeId] = { week, timestamp: existingTime };
            }
          });

          const nextStatus = {};
          (users.value || []).forEach((trainee) => {
            const lastWeek = maxWeekByTrainee[trainee.id] || 0;
            const currentEntry = latestByTrainee[trainee.id];
            const currentWeek = currentEntry?.week || (lastWeek ? 1 : 0);
            nextStatus[trainee.id] = {
              currentWeek,
              lastWeek,
              isLastWeek: Boolean(lastWeek && currentWeek >= lastWeek),
            };
          });
          traineeWeekStatus.value = nextStatus;
        } catch (err) {
          console.error(err);
          weekStatusError.value = err.message || t('errors.loadLastWeek');
          traineeWeekStatus.value = {};
        } finally {
          loadingWeekStatus.value = false;
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
                workout_plan_days!inner (
                  id, position,
                  workout_plans ( id, title, starts_on, created_at )
                ),
                day_exercises (
                  id, position, notes, completed, exercise
                )
              `)
          .eq('workout_plan_days.workout_plans.trainee_id', u.id)
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
            .select('id, month_start, paid, paid_at, amount')
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

      async function loadCompletedExercises(u = current.value) {
        if (!u) return;
        loadingCompletedExercises.value = true;
        completedExercisesError.value = '';
        try {
          const { data, error } = await supabase
            .from('day_exercises')
            .select(
              'id, exercise, notes, trainee_notes, completed, days!inner ( id, week, day_code, title, completed_at, workout_plan_days!inner ( workout_plans!inner ( trainee_id ) ) )',
            )
            .eq('completed', true)
            .eq('days.workout_plan_days.workout_plans.trainee_id', u.id);
          if (error) {
            throw new Error(error.message);
          }
          completedExercises.value = data || [];
        } catch (err) {
          console.error(err);
          completedExercises.value = [];
          completedExercisesError.value =
            err.message || t('errors.loadCompletedExercises');
        } finally {
          loadingCompletedExercises.value = false;
        }
      }

      async function saveCoachTip() {
        if (!current.value) {
          alert(t('errors.selectTrainee'));
          return;
        }
        coachTipSaving.value = true;
        try {
          const nextTip = coachTipDraft.value.trim();
          const { error } = await supabase
            .from('trainee_trainers')
            .update({ coach_tip: nextTip || null })
            .eq('trainee_id', current.value.id);
          if (error) {
            throw new Error(error.message);
          }
          current.value = {
            ...current.value,
            coach_tip: nextTip,
          };
          users.value = (users.value || []).map((u) =>
            u.id === current.value.id ? { ...u, coach_tip: nextTip } : u,
          );
        } catch (err) {
          console.error(err);
          alert(err.message || t('errors.updateCoachTip'));
        } finally {
          coachTipSaving.value = false;
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

      async function loadDashboardBurndown() {
        dashboardBurndownLoading.value = true;
        dashboardBurndownError.value = '';
        try {
          const trainees = users.value || [];
          if (!trainees.length) {
            dashboardBurndown.value = {
              ...dashboardBurndown.value,
              dates: [],
              lines: [],
              maxValue: 0,
              minDateLabel: '',
              maxDateLabel: '',
            };
            return;
          }

          const traineeIds = trainees.map((u) => u.id).filter(Boolean);
          if (!traineeIds.length) {
            return;
          }

          const { data: planRows, error: planError } = await supabase
            .from('workout_plans')
            .select('id, trainee_id, created_at, starts_on')
            .in('trainee_id', traineeIds)
            .order('created_at', { ascending: false });
          if (planError) {
            throw new Error(planError.message);
          }

          const latestPlanByTrainee = new Map();
          (planRows || []).forEach((row) => {
            if (!row?.trainee_id || !row?.id) return;
            const stamp = new Date(row.starts_on || row.created_at || 0).valueOf();
            const existing = latestPlanByTrainee.get(row.trainee_id);
            if (!existing || stamp > existing.stamp) {
              latestPlanByTrainee.set(row.trainee_id, {
                planId: row.id,
                stamp,
              });
            }
          });

          const planIds = Array.from(latestPlanByTrainee.values())
            .map((entry) => entry.planId)
            .filter(Boolean);
          if (!planIds.length) {
            dashboardBurndown.value = {
              ...dashboardBurndown.value,
              dates: [],
              lines: [],
              maxValue: 0,
              minDateLabel: '',
              maxDateLabel: '',
            };
            return;
          }

          const { data: exerciseRows, error: exerciseError } = await supabase
            .from('day_exercises')
            .select(
              'id, completed, days!inner ( completed_at, workout_plan_days!inner ( plan_id ) )',
            )
            .in('days.workout_plan_days.plan_id', planIds);
          if (exerciseError) {
            throw new Error(exerciseError.message);
          }

          const totalByPlan = new Map();
          const completedByPlanDate = new Map();
          const completedBeforeStart = new Map();
          const { start, dates } = buildDateRange(30);
          const startKey = dateKey(start);

          (exerciseRows || []).forEach((row) => {
            const day = row.days || {};
            const planEntries = day.workout_plan_days || [];
            const planId = planEntries?.[0]?.plan_id;
            if (!planId) return;
            totalByPlan.set(planId, (totalByPlan.get(planId) || 0) + 1);
            if (!row.completed || !day.completed_at) return;
            const completedKey = dateKey(day.completed_at);
            if (!completedKey) return;
            if (completedKey < startKey) {
              completedBeforeStart.set(
                planId,
                (completedBeforeStart.get(planId) || 0) + 1,
              );
              return;
            }
            const planMap =
              completedByPlanDate.get(planId) || new Map();
            planMap.set(completedKey, (planMap.get(completedKey) || 0) + 1);
            completedByPlanDate.set(planId, planMap);
          });

          const chartWidth = dashboardBurndown.value.chartWidth;
          const chartHeight = dashboardBurndown.value.chartHeight;
          const padding = 28;
          const colors = [
            '#2563eb',
            '#16a34a',
            '#f97316',
            '#db2777',
            '#0891b2',
            '#7c3aed',
            '#4b5563',
            '#65a30d',
          ];

          const lines = [];
          let maxValue = 0;
          trainees.forEach((trainee, index) => {
            const planEntry = latestPlanByTrainee.get(trainee.id);
            if (!planEntry?.planId) return;
            const planId = planEntry.planId;
            const total = totalByPlan.get(planId) || 0;
            if (!total) return;
            const startingCompleted = completedBeforeStart.get(planId) || 0;
            const planDates = completedByPlanDate.get(planId) || new Map();
            let completedCount = startingCompleted;
            const points = dates.map((dateItem, dayIndex) => {
              const key = dateKey(dateItem);
              completedCount += planDates.get(key) || 0;
              const remaining = Math.max(total - completedCount, 0);
              const x =
                dates.length === 1
                  ? padding
                  : padding +
                    (dayIndex / (dates.length - 1)) *
                      (chartWidth - padding * 2);
              const yRange = chartHeight - padding * 2;
              const y =
                chartHeight -
                padding -
                (remaining / total) * yRange;
              return {
                x: Number(x.toFixed(2)),
                y: Number(y.toFixed(2)),
                remaining,
              };
            });
            maxValue = Math.max(maxValue, total);
            lines.push({
              traineeId: trainee.id,
              traineeName: trainee.displayName || shortId(trainee.id),
              color: colors[index % colors.length],
              total,
              latestRemaining: points.length ? points[points.length - 1].remaining : total,
              points,
              polyline: points.map((point) => `${point.x},${point.y}`).join(' '),
            });
          });

          const minDateLabel = dates.length ? formatDate(dates[0]) : '';
          const maxDateLabel = dates.length
            ? formatDate(dates[dates.length - 1])
            : '';

          dashboardBurndown.value = {
            chartWidth,
            chartHeight,
            dates,
            lines,
            maxValue,
            minDateLabel,
            maxDateLabel,
          };
        } catch (err) {
          console.error(err);
          dashboardBurndownError.value =
            err.message || t('errors.loadProgress');
        } finally {
          dashboardBurndownLoading.value = false;
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
          const planId = resolveDefaultPlanId();
          if (!planId) {
            throw new Error(t('errors.missingPlan'));
          }
          const { data, error } = await supabase
            .from('days')
            .insert({
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
        dashboardTrainees,
        showLastWeekCard,
        lastWeekTrainees,
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
        exercises,
        exerciseFilter,
        exerciseForm,
        exerciseEdits,
        exerciseDifficultyOptions,
        filteredExercises,
        loadingExercises,
        exercisesError,
        creatingExercise,
        exerciseSaving,
        maxTests,
        maxTestHistory,
        completedExerciseLog,
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
        templateWeekCount,
        templateWeekOptions,
        templateSlotCount,
        templateExerciseOptions,
        templatePlanName,
        programTemplateDays,
        selectedTemplateDay,
        selectedTemplateSlot,
        activeTemplateDay,
        activeTemplateSlots,
        activeTemplateSlot,
        savingTemplatePlan,
        dashboardNotes,
        dashboardNotesLoading,
        dashboardNotesError,
        dashboardBurndown,
        dashboardBurndownLoading,
        dashboardBurndownError,
        loadingProgress,
        loadingWeekStatus,
        weekStatusError,
        loadingMaxTests,
        maxTestsError,
        coachTipDraft,
        coachTipSaving,
        paymentSaving,
        paymentAmountEdits,
        paymentAmountSaving,
        savePaymentAmount,
        paymentHistory,
        loadingPayments,
        paymentsError,
        loadingCompletedExercises,
        completedExercisesError,
        trainingCalendar,
        progressFor,
        weekStatusFor,
        formatTestValue,
        formatDate,
        formatTime,
        formatAmount,
        formatCount,
        dayCodeLabel,
        planStatusLabel,
        templateDayLabel,
        selectTemplateDay,
        selectTemplateSlot,
        incrementTemplateDayCount,
        incrementTemplateSlotCount,
        emailPasswordSignIn,
        signOut,
        selectUser,
        openTrainee,
        loadDays,
        loadMaxTests,
        loadPlans,
        loadPaymentHistory,
        loadCompletedExercises,
        loadDashboardNotes,
        addPlan,
        addDay,
        resetDayForm,
        resetPlanForm,
        addExerciseToDay,
        saveCoachTip,
        assignTrainerToTrainee,
        removeTrainerAssignment,
        loadExercises,
        createExercise,
        resetExerciseForm,
        saveExercise,
        deleteExercise,
        saveDay,
        deleteDay,
        resetPlanEdit,
        savePlan,
        deletePlan,
        saveTemplatePlan,
        saveDayExercise,
        deleteDayExercise,
        shortId,
        togglePayment,
        markPaymentPaid,
        formatDifficultyLabel,
      };
    },
  }).mount('#app');
})();

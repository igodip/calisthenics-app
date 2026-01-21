import 'package:calisync/model/workout_day.dart';
import 'package:calisync/pages/trainee_feedback.dart';
import 'package:calisync/pages/workout_plan_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late Future<List<WorkoutDay>> _daysFuture;
  late Future<List<_CoachPlanProgress>> _coachProgressFuture;

  @override
  void initState() {
    super.initState();
    _daysFuture = _loadWorkoutDays();
    _coachProgressFuture = _loadCoachPlanProgress();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<WorkoutDay>>(
          future: _daysFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 32),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 32),
                  Icon(
                    Icons.error_outline,
                    size: 56,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.homeLoadErrorTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _daysFuture = _loadWorkoutDays();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ),
                ],
              );
            }

            final days = snapshot.data ?? const <WorkoutDay>[];
            final scheduleSummary = _buildScheduleSummary(days, DateTime.now());
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _WorkoutScheduleSection(summary: scheduleSummary),
                const SizedBox(height: 24),
                FutureBuilder<List<_CoachPlanProgress>>(
                  future: _coachProgressFuture,
                  builder: (context, coachSnapshot) {
                    if (coachSnapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }

                    if (coachSnapshot.hasError) {
                      return const SizedBox.shrink();
                    }

                    final entries = coachSnapshot.data ?? const [];
                    if (entries.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return _CoachPlanProgressSection(entries: entries);
                  },
                ),
                const SizedBox(height: 24),
                _WorkoutPlanLinkSection(
                  onOpenPlan: _openWorkoutPlan,
                ),
                const SizedBox(height: 16),
                _TraineeFeedbackLinkSection(
                  onOpenFeedback: _openTraineeFeedback,
                ),
                const SizedBox(height: 16),
                const _CoachTipSection(),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _daysFuture = _loadWorkoutDays();
      _coachProgressFuture = _loadCoachPlanProgress();
    });
    await Future.wait([_daysFuture, _coachProgressFuture]);
  }

  Future<List<WorkoutDay>> _loadWorkoutDays() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception(AppLocalizations.of(context)!.unauthenticated);
    }

    final response = await client
        .from('days')
        .select('week, day_code, workout_plan_days ( workout_plans ( starts_on ) )')
        .eq('trainee_id', userId)
        .order('week', ascending: true)
        .order('day_code', ascending: true)
        .order('position', referencedTable: 'workout_plan_days', ascending: true);

    final data = (response as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    DateTime? parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return data.map((row) {
      final planEntries =
          (row['workout_plan_days'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
      final planDetails = planEntries.isNotEmpty
          ? (planEntries.first['workout_plans'] as Map<String, dynamic>?) ?? {}
          : <String, dynamic>{};
      final planStartedAt = parseDate(planDetails['starts_on']);

      return WorkoutDay(
        id: null,
        week: (row['week'] as num?)?.toInt() ?? 0,
        dayCode: (row['day_code'] as String? ?? '').trim(),
        title: null,
        notes: null,
        isCompleted: false,
        planId: null,
        planName: null,
        planStartedAt: planStartedAt,
        createdAt: null,
        exercises: const [],
      );
    }).toList();
  }

  Future<List<_CoachPlanProgress>> _loadCoachPlanProgress() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception(AppLocalizations.of(context)!.unauthenticated);
    }

    final trainerResponse = await client
        .from('trainers')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (trainerResponse == null) {
      return [];
    }

    final trainerId = trainerResponse['id'] as String?;
    if (trainerId == null || trainerId.isEmpty) {
      return [];
    }

    final assignments = await client
        .from('trainee_trainers')
        .select('trainee_id, trainees ( id, name )')
        .eq('trainer_id', trainerId);

    final assignmentData =
        (assignments as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    if (assignmentData.isEmpty) {
      return [];
    }

    final l10n = AppLocalizations.of(context)!;
    final trainees = assignmentData
        .map((row) {
          final traineeInfo =
              (row['trainees'] as Map<String, dynamic>?) ?? <String, dynamic>{};
          final traineeId = row['trainee_id'] as String? ?? '';
          final rawName = (traineeInfo['name'] as String? ?? '').trim();
          final displayName = rawName.isNotEmpty ? rawName : l10n.profileFallbackName;
          return _TraineeSummary(
            id: traineeId,
            name: displayName,
          );
        })
        .where((trainee) => trainee.id.isNotEmpty)
        .toList();

    if (trainees.isEmpty) {
      return [];
    }

    final traineeIds = trainees.map((trainee) => trainee.id).toList();
    final plansResponse = await client
        .from('workout_plans')
        .select('id, trainee_id, title, starts_on, created_at')
        .in_('trainee_id', traineeIds)
        .order('starts_on', ascending: false)
        .order('created_at', ascending: false);

    final plansData =
        (plansResponse as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    DateTime? parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    final latestPlanByTrainee = <String, _PlanDetails>{};
    for (final row in plansData) {
      final traineeId = row['trainee_id'] as String? ?? '';
      final planId = row['id'] as String? ?? '';
      if (traineeId.isEmpty || planId.isEmpty) continue;
      final planDate = parseDate(row['starts_on']) ?? parseDate(row['created_at']);
      final planTitle = (row['title'] as String? ?? '').trim();
      final existing = latestPlanByTrainee[traineeId];
      if (existing == null) {
        latestPlanByTrainee[traineeId] = _PlanDetails(
          id: planId,
          title: planTitle,
          date: planDate,
        );
        continue;
      }
      if (planDate != null &&
          (existing.date == null || planDate.isAfter(existing.date!))) {
        latestPlanByTrainee[traineeId] = _PlanDetails(
          id: planId,
          title: planTitle,
          date: planDate,
        );
      }
    }

    if (latestPlanByTrainee.isEmpty) {
      return [];
    }

    final planIds = latestPlanByTrainee.values.map((plan) => plan.id).toSet().toList();
    if (planIds.isEmpty) {
      return [];
    }

    final planDaysResponse = await client
        .from('workout_plan_days')
        .select('plan_id, days ( completed )')
        .in_('plan_id', planIds);

    final planDaysData =
        (planDaysResponse as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final completions = <String, _PlanCompletion>{};

    for (final row in planDaysData) {
      final planId = row['plan_id'] as String? ?? '';
      if (planId.isEmpty) continue;
      final day = row['days'] as Map<String, dynamic>?;
      if (day == null) continue;
      final completed = day['completed'] as bool? ?? false;
      final current = completions.putIfAbsent(planId, () => _PlanCompletion());
      current.total += 1;
      if (completed) {
        current.completed += 1;
      }
    }

    for (final planId in planIds) {
      completions.putIfAbsent(planId, () => _PlanCompletion());
    }

    final progressEntries = <_CoachPlanProgress>[];
    for (final trainee in trainees) {
      final plan = latestPlanByTrainee[trainee.id];
      if (plan == null) continue;
      final completion = completions[plan.id] ?? _PlanCompletion();
      final total = completion.total;
      final completed = completion.completed;
      final rate = total > 0 ? completed / total : 0.0;
      if (rate <= 0.75) continue;

      final resolvedTitle =
          plan.title.isNotEmpty ? plan.title : l10n.homePlanDefaultTitle;
      progressEntries.add(
        _CoachPlanProgress(
          traineeId: trainee.id,
          traineeName: trainee.name,
          planId: plan.id,
          planTitle: resolvedTitle,
          completionRate: rate,
          completedDays: completed,
          totalDays: total,
          planDate: plan.date,
        ),
      );
    }

    progressEntries.sort((a, b) {
      final rateCompare = b.completionRate.compareTo(a.completionRate);
      if (rateCompare != 0) return rateCompare;
      return a.traineeName.compareTo(b.traineeName);
    });

    return progressEntries;
  }

  Future<void> _openWorkoutPlan() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const WorkoutPlanPage()),
    );
  }

  Future<void> _openTraineeFeedback() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TraineeFeedbackPage()),
    );
  }

  _WorkoutScheduleSummary _buildScheduleSummary(
    List<WorkoutDay> days,
    DateTime now,
  ) {
    final dates = <DateTime>{};
    for (final day in days) {
      final computed = _resolveWorkoutDate(day);
      if (computed == null) continue;
      dates.add(_normalizeDate(computed));
    }

    final today = _normalizeDate(now);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final monthStart = DateTime(today.year, today.month, 1);
    final monthEnd = DateTime(today.year, today.month + 1, 0);

    final sortedDates = dates.toList()..sort();
    final nextWorkout = sortedDates.firstWhere(
      (date) => !date.isBefore(today),
      orElse: () => DateTime(0),
    );

    final workoutsThisWeek = dates
        .where((date) => !date.isBefore(weekStart) && !date.isAfter(weekEnd))
        .length;
    final workoutsThisMonth = dates
        .where((date) => !date.isBefore(monthStart) && !date.isAfter(monthEnd))
        .length;
    final upcomingWeek = sortedDates
        .where((date) => !date.isBefore(today) && !date.isAfter(weekEnd))
        .toList();

    return _WorkoutScheduleSummary(
      nextWorkout: nextWorkout.year == 0 ? null : nextWorkout,
      workoutsThisWeek: workoutsThisWeek,
      workoutsThisMonth: workoutsThisMonth,
      upcomingWeek: upcomingWeek,
    );
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime? _resolveWorkoutDate(WorkoutDay day) {
    final planStart = day.planStartedAt;
    final weekOffset = day.week > 0 ? day.week - 1 : 0;
    final dayOffset = _dayOffsetFromCode(day.dayCode);

    if (planStart != null && dayOffset != null) {
      final normalizedStart = _normalizeDate(planStart);
      return normalizedStart.add(
        Duration(days: (weekOffset * 7) + dayOffset),
      );
    }

    if (planStart != null) {
      final normalizedStart = _normalizeDate(planStart);
      return normalizedStart.add(Duration(days: weekOffset * 7));
    }

    return null;
  }

  int? _dayOffsetFromCode(String code) {
    final normalized = code.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    final numeric = int.tryParse(normalized);
    if (numeric != null && numeric > 0) {
      return numeric - 1;
    }

    final letter = normalized.length == 1 ? normalized.codeUnitAt(0) : null;
    if (letter != null && letter >= 97 && letter <= 103) {
      return letter - 97;
    }

    const weekdayMap = {
      'mon': 0,
      'monday': 0,
      'lun': 0,
      'lunedi': 0,
      'lunedì': 0,
      'tue': 1,
      'tues': 1,
      'tuesday': 1,
      'mar': 1,
      'martedi': 1,
      'martedì': 1,
      'wed': 2,
      'wednesday': 2,
      'mer': 2,
      'mercoledi': 2,
      'mercoledì': 2,
      'thu': 3,
      'thur': 3,
      'thurs': 3,
      'thursday': 3,
      'gio': 3,
      'giovedi': 3,
      'giovedì': 3,
      'fri': 4,
      'friday': 4,
      'ven': 4,
      'venerdi': 4,
      'venerdì': 4,
      'sat': 5,
      'saturday': 5,
      'sab': 5,
      'sabato': 5,
      'sun': 6,
      'sunday': 6,
      'dom': 6,
      'domenica': 6,
    };

    return weekdayMap[normalized];
  }
}

class _TraineeSummary {
  final String id;
  final String name;

  const _TraineeSummary({
    required this.id,
    required this.name,
  });
}

class _PlanDetails {
  final String id;
  final String title;
  final DateTime? date;

  const _PlanDetails({
    required this.id,
    required this.title,
    required this.date,
  });
}

class _PlanCompletion {
  int completed = 0;
  int total = 0;
}

class _CoachPlanProgress {
  final String traineeId;
  final String traineeName;
  final String planId;
  final String planTitle;
  final double completionRate;
  final int completedDays;
  final int totalDays;
  final DateTime? planDate;

  const _CoachPlanProgress({
    required this.traineeId,
    required this.traineeName,
    required this.planId,
    required this.planTitle,
    required this.completionRate,
    required this.completedDays,
    required this.totalDays,
    required this.planDate,
  });
}

class _WorkoutScheduleSummary {
  final DateTime? nextWorkout;
  final int workoutsThisWeek;
  final int workoutsThisMonth;
  final List<DateTime> upcomingWeek;

  const _WorkoutScheduleSummary({
    required this.nextWorkout,
    required this.workoutsThisWeek,
    required this.workoutsThisMonth,
    required this.upcomingWeek,
  });
}

class _CoachPlanProgressSection extends StatelessWidget {
  final List<_CoachPlanProgress> entries;

  const _CoachPlanProgressSection({
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeCoachProgressTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.homeCoachProgressSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        ...entries.map((entry) {
          final percent = (entry.completionRate * 100).round();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.traineeName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.homeCoachProgressPlanLabel(entry.planTitle),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: entry.completionRate.clamp(0, 1),
                              minHeight: 8,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.homeCoachProgressPercentLabel(percent),
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.homeCoachProgressCountLabel(
                        entry.completedDays,
                        entry.totalDays,
                      ),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _WorkoutScheduleSection extends StatelessWidget {
  final _WorkoutScheduleSummary summary;

  const _WorkoutScheduleSection({
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = DateFormat.EEEE(l10n.localeName).add_yMMMd();
    final compactDateFormat = DateFormat.MMMd(l10n.localeName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeScheduleTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.homeScheduleSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
          child: ListTile(
            leading: Icon(
              Icons.event_available,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              l10n.homeNextWorkoutTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              summary.nextWorkout == null
                  ? l10n.homeNextWorkoutEmpty
                  : dateFormat.format(summary.nextWorkout!),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.calendar_view_week,
                label: l10n.homeWorkoutsThisWeekTitle,
                value: '${summary.workoutsThisWeek}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.calendar_month,
                label: l10n.homeWorkoutsThisMonthTitle,
                value: '${summary.workoutsThisMonth}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          l10n.homeUpcomingWeekTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (summary.upcomingWeek.isEmpty)
          Text(
            l10n.homeUpcomingWeekEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: summary.upcomingWeek
                .map(
                  (date) => Chip(
                    label: Text(compactDateFormat.format(date)),
                    backgroundColor:
                        theme.colorScheme.surfaceContainerHighest,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutPlanLinkSection extends StatelessWidget {
  final VoidCallback onOpenPlan;

  const _WorkoutPlanLinkSection({
    required this.onOpenPlan,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.fitness_center,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          l10n.homeWorkoutPlanTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          l10n.homeWorkoutPlanSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onOpenPlan,
      ),
    );
  }
}

class _TraineeFeedbackLinkSection extends StatelessWidget {
  final VoidCallback onOpenFeedback;

  const _TraineeFeedbackLinkSection({
    required this.onOpenFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.rate_review,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          l10n.homeTraineeFeedbackTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          l10n.homeTraineeFeedbackSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onOpenFeedback,
      ),
    );
  }
}

class _CoachTipSection extends StatelessWidget {
  const _CoachTipSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.homeCoachTipTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.homeCoachTipPlaceholder,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

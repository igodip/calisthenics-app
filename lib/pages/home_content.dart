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

  @override
  void initState() {
    super.initState();
    _daysFuture = _loadWorkoutDays();
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
    });
    await _daysFuture;
  }

  Future<List<WorkoutDay>> _loadWorkoutDays() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception(AppLocalizations.of(context)!.unauthenticated);
    }

    final response = await client.from('days').select(
          'week, day_code, completed, '
          'workout_plan_days ( workout_plans ( id, title, starts_on, created_at ) )',
        )
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
      final planCreatedAt = parseDate(planDetails['created_at']);
      final planId = planDetails['id'] as String?;
      final planName = planDetails['title'] as String?;

      return WorkoutDay(
        id: null,
        week: (row['week'] as num?)?.toInt() ?? 0,
        dayCode: (row['day_code'] as String? ?? '').trim(),
        title: null,
        notes: null,
        isCompleted: row['completed'] as bool? ?? false,
        planId: planId,
        planName: planName,
        planStartedAt: planStartedAt,
        createdAt: planCreatedAt,
        exercises: const [],
      );
    }).toList();
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
      planProgress: _buildPlanProgressSummary(days),
    );
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  _PlanProgressSummary? _buildPlanProgressSummary(List<WorkoutDay> days) {
    if (days.isEmpty) return null;

    String planKey(WorkoutDay day) {
      if (day.planId != null && day.planId!.isNotEmpty) return day.planId!;
      if (day.planName != null && day.planName!.isNotEmpty) return day.planName!;
      if (day.planStartedAt != null) return 'start-${day.planStartedAt!.toIso8601String()}';
      if (day.createdAt != null) return 'created-${day.createdAt!.toIso8601String()}';
      return 'plan';
    }

    DateTime? latestPlanDate(Iterable<WorkoutDay> entries) {
      return entries
          .map((day) => day.planStartedAt ?? day.createdAt)
          .whereType<DateTime>()
          .fold<DateTime?>(null, (previous, element) {
        if (previous == null) return element;
        return element.isAfter(previous) ? element : previous;
      });
    }

    final Map<String, List<WorkoutDay>> grouped = {};
    for (final day in days) {
      grouped.putIfAbsent(planKey(day), () => []).add(day);
    }

    List<WorkoutDay>? selected;
    DateTime? selectedDate;
    for (final entry in grouped.entries) {
      final candidate = entry.value;
      final candidateDate = latestPlanDate(candidate);
      if (selected == null) {
        selected = candidate;
        selectedDate = candidateDate;
        continue;
      }
      if (candidateDate == null) {
        continue;
      }
      if (selectedDate == null || candidateDate.isAfter(selectedDate)) {
        selected = candidate;
        selectedDate = candidateDate;
      }
    }

    if (selected == null || selected.isEmpty) {
      return null;
    }

    final totalDays = selected.length;
    final completedDays = selected.where((day) => day.isCompleted).length;
    final representative = selected.first;
    return _PlanProgressSummary(
      totalDays: totalDays,
      completedDays: completedDays,
      planName: representative.planName,
    );
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

class _WorkoutScheduleSummary {
  final DateTime? nextWorkout;
  final int workoutsThisWeek;
  final int workoutsThisMonth;
  final List<DateTime> upcomingWeek;
  final _PlanProgressSummary? planProgress;

  const _WorkoutScheduleSummary({
    required this.nextWorkout,
    required this.workoutsThisWeek,
    required this.workoutsThisMonth,
    required this.upcomingWeek,
    required this.planProgress,
  });
}

class _PlanProgressSummary {
  final int totalDays;
  final int completedDays;
  final String? planName;

  const _PlanProgressSummary({
    required this.totalDays,
    required this.completedDays,
    required this.planName,
  });

  double get completionRatio {
    if (totalDays <= 0) return 0;
    return completedDays / totalDays;
  }

  int get completionPercent {
    return (completionRatio * 100).round();
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
        if (summary.planProgress == null)
          Text(
            l10n.homePlanProgressEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.assessment,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.homePlanProgressTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary.planProgress?.planName?.isNotEmpty == true
                        ? summary.planProgress!.planName!
                        : l10n.homePlanProgressCurrentPlan,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: summary.planProgress!.completionRatio,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.homePlanProgressValue(
                          summary.planProgress!.completedDays,
                          summary.planProgress!.totalDays,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        l10n.homePlanProgressPercent(
                          summary.planProgress!.completionPercent,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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

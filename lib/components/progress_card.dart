import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class ProgressCard extends StatefulWidget {
  const ProgressCard({super.key});

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  static const int _estimatedWorkoutMinutes = 45;
  late final Future<_ProgressOverview> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = _loadProgressStats();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = theme.extension<AppColors>();
    return FutureBuilder<_ProgressOverview>(
      future: _progressFuture,
      builder: (context, snapshot) {
        final overview = snapshot.data ?? const _ProgressOverview.empty();
        final dateFormatter = DateFormat.yMMMd(l10n.localeName);
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer.withValues(alpha: 0.82),
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.82),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.insights_rounded,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.homeProgressTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (overview.hasPlan) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.flag_outlined,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.homePlanLatestLabel,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              overview.planTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (overview.planStartedAt != null) ...[
                              const SizedBox(height: 5),
                              Text(
                                l10n.homePlanStartedLabel(
                                  dateFormatter.format(overview.planStartedAt!),
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      _ProgressRing(
                        progress: overview.planStats.completionRate,
                        percentage: overview.planStats.completionPercentage,
                        color: appColors?.success ?? colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final tileWidth = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: tileWidth,
                          child: _StatTile(
                            value: overview.monthlyStats.workoutsValue,
                            label: l10n.homeProgressWorkoutsLabel,
                            icon: Icons.fitness_center,
                          ),
                        ),
                        SizedBox(
                          width: tileWidth,
                          child: _StatTile(
                            value: l10n.homeProgressTimeValue(
                              overview.monthlyStats.hoursTrained,
                              overview.monthlyStats.minutesTrained,
                            ),
                            label: l10n.homeProgressTimeTrainedLabel,
                            icon: Icons.timer_outlined,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStatTile(
                        label: l10n.homePlanStatsDaysLabel,
                        value: overview.planStats.daysValue,
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniStatTile(
                        label: l10n.homePlanStatsExercisesLabel,
                        value: overview.planStats.exercisesValue,
                        icon: Icons.task_alt_outlined,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_note_outlined,
                        size: 42,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.homeProgressNoPlan,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<_ProgressOverview> _loadProgressStats() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      return const _ProgressOverview.empty();
    }

    final latestPlanResponse = await client
        .from('workout_plans')
        .select('id, title, starts_on, created_at')
        .eq('trainee_id', userId)
        .order('starts_on', ascending: false)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (latestPlanResponse == null) {
      return const _ProgressOverview.empty();
    }

    DateTime? parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    final planId = latestPlanResponse['id'] as String?;
    if (planId == null || planId.isEmpty) {
      return const _ProgressOverview.empty();
    }

    final response = await client
        .from('days')
        .select(
          'completed, completed_at, '
          'workout_plan_days!inner ( workout_plans!inner ( id ) ), '
          'day_exercises ( completed, duration_minutes )',
        )
        .eq('workout_plan_days.workout_plans.id', planId)
        .order('completed_at', ascending: false, nullsFirst: true);

    final rows = (response as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final nextMonthStart = DateTime(now.year, now.month + 1);

    var completedDays = 0;
    var totalDays = 0;
    var completedExercises = 0;
    var totalExercises = 0;
    var monthlyCompletedDays = 0;
    var monthlyTrainedMinutes = 0;

    for (final row in rows) {
      totalDays += 1;
      final isCompleted = row['completed'] as bool? ?? false;
      if (isCompleted) {
        completedDays += 1;
      }

      final dayExercises = (row['day_exercises'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      totalExercises += dayExercises.length;
      completedExercises += dayExercises
          .where((exercise) => exercise['completed'] as bool? ?? false)
          .length;

      final completedAt = parseDate(row['completed_at']);
      final completedAtLocal = completedAt?.toLocal();
      if (completedAtLocal != null &&
          !completedAtLocal.isBefore(monthStart) &&
          completedAtLocal.isBefore(nextMonthStart)) {
        monthlyCompletedDays += 1;
        monthlyTrainedMinutes += _estimateTrainedMinutes(dayExercises);
      }
    }

    return _ProgressOverview(
      planTitle:
          (latestPlanResponse['title'] as String? ?? '').trim().isNotEmpty
          ? (latestPlanResponse['title'] as String).trim()
          : '',
      planStartedAt:
          parseDate(latestPlanResponse['starts_on']) ??
          parseDate(latestPlanResponse['created_at']),
      monthlyStats: _MonthlyProgressStats(
        completedDays: monthlyCompletedDays,
        trainedMinutes: monthlyTrainedMinutes,
      ),
      planStats: _PlanStats(
        completedDays: completedDays,
        totalDays: totalDays,
        completedExercises: completedExercises,
        totalExercises: totalExercises,
      ),
    );
  }

  int _estimateTrainedMinutes(List<Map<String, dynamic>> dayExercises) {
    if (dayExercises.isEmpty) {
      return _estimatedWorkoutMinutes;
    }

    final explicitMinutes = dayExercises.fold<int>(0, (total, exercise) {
      final duration = (exercise['duration_minutes'] as num?)?.toInt() ?? 0;
      return total + duration;
    });
    if (explicitMinutes > 0) {
      return explicitMinutes;
    }

    final completedExercises = dayExercises
        .where((exercise) => exercise['completed'] as bool? ?? false)
        .length;
    if (completedExercises == 0) {
      return _estimatedWorkoutMinutes;
    }

    return (_estimatedWorkoutMinutes * completedExercises / dayExercises.length)
        .round();
  }
}

class _ProgressOverview {
  final String planTitle;
  final DateTime? planStartedAt;
  final _MonthlyProgressStats monthlyStats;
  final _PlanStats planStats;

  const _ProgressOverview({
    required this.planTitle,
    required this.planStartedAt,
    required this.monthlyStats,
    required this.planStats,
  });

  const _ProgressOverview.empty()
    : planTitle = '',
      planStartedAt = null,
      monthlyStats = const _MonthlyProgressStats(),
      planStats = const _PlanStats();

  bool get hasPlan => planTitle.isNotEmpty || planStats.totalDays > 0;
}

class _MonthlyProgressStats {
  final int completedDays;
  final int trainedMinutes;

  const _MonthlyProgressStats({
    this.completedDays = 0,
    this.trainedMinutes = 0,
  });

  String get workoutsValue => '$completedDays';

  int get hoursTrained => trainedMinutes ~/ 60;

  int get minutesTrained => trainedMinutes % 60;
}

class _PlanStats {
  final int completedDays;
  final int totalDays;
  final int completedExercises;
  final int totalExercises;

  const _PlanStats({
    this.completedDays = 0,
    this.totalDays = 0,
    this.completedExercises = 0,
    this.totalExercises = 0,
  });

  String get daysValue => '$completedDays/$totalDays';

  String get exercisesValue => '$completedExercises/$totalExercises';

  double get completionRate {
    if (totalDays == 0) {
      return 0;
    }
    return completedDays / totalDays;
  }

  int get completionPercentage => (completionRate * 100).round();
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatTile extends StatelessWidget {
  const _MiniStatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.percentage,
    required this.color,
  });

  final double progress;
  final int percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox.square(
      dimension: 78,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: 72,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          Text(
            '$percentage%',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

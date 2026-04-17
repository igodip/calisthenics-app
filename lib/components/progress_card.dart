import 'package:calisync/components/section_card.dart';
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
        return SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.homeProgressTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (overview.hasPlan) ...[
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  overview.planTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (overview.planStartedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.homePlanStartedLabel(
                      dateFormatter.format(overview.planStartedAt!),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        value: overview.monthlyStats.workoutsValue,
                        label: l10n.homeProgressWorkoutsLabel,
                        icon: Icons.fitness_center,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        value: l10n.homeProgressTimeValue(
                          overview.monthlyStats.hoursTrained,
                          overview.monthlyStats.minutesTrained,
                        ),
                        label: l10n.homeProgressTimeTrainedLabel,
                        icon: Icons.timer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homePlanStatsTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: overview.planStats.completionRate,
                          minHeight: 10,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            appColors?.success ?? colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.homePlanStatsCompletionValue(
                          overview.planStats.completionPercentage,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniStatTile(
                              label: l10n.homePlanStatsDaysLabel,
                              value: overview.planStats.daysValue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniStatTile(
                              label: l10n.homePlanStatsExercisesLabel,
                              value: overview.planStats.exercisesValue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  l10n.homeProgressNoPlan,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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
  const _MiniStatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

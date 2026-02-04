import 'package:calisync/components/section_card.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';

class ProgressCard extends StatefulWidget {
  const ProgressCard({
    super.key
  });

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  static const int _estimatedWorkoutMinutes = 45;
  late final Future<_ProgressStats> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = _loadProgressStats();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return FutureBuilder<_ProgressStats>(
      future: _progressFuture,
      builder: (context, snapshot) {
        final stats = snapshot.data ?? const _ProgressStats();
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      value: stats.workoutValue,
                      label: l10n.homeProgressWorkoutsLabel,
                      icon: Icons.fitness_center,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      value: l10n.homeProgressTimeValue(
                        stats.hoursTrained,
                        stats.minutesTrained,
                      ),
                      label: l10n.homeProgressTimeTrainedLabel,
                      icon: Icons.timer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<_ProgressStats> _loadProgressStats() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      return const _ProgressStats();
    }

    final response = await client
        .from('days')
        .select(
          'completed, completed_at, week, day_code, '
          'workout_plan_days!inner ( workout_plans!inner ( trainee_id ) ), '
          'day_exercises ( completed )',
        )
        .eq('workout_plan_days.workout_plans.trainee_id', userId)
        .order('completed_at', ascending: false, nullsFirst: true)
        .order('week', ascending: false)
        .order('day_code', ascending: false)
        .limit(1);

    final rows = (response as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    if (rows.isEmpty) {
      return const _ProgressStats();
    }

    final dayExercises =
        (rows.first['day_exercises'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
    final totalExercises = dayExercises.length;
    final completedExercises = dayExercises
        .where((exercise) => exercise['completed'] as bool? ?? false)
        .length;

    if (totalExercises == 0) {
      return const _ProgressStats();
    }

    final trainedMinutes =
        (_estimatedWorkoutMinutes * completedExercises / totalExercises)
            .round();
    return _ProgressStats(
      completedExercises: completedExercises,
      totalExercises: totalExercises,
      trainedMinutes: trainedMinutes,
    );
  }
}

class _ProgressStats {
  final int completedExercises;
  final int totalExercises;
  final int trainedMinutes;

  const _ProgressStats({
    this.completedExercises = 0,
    this.totalExercises = 0,
    this.trainedMinutes = 0,
  });

  String get workoutValue {
    if (totalExercises == 0) {
      return '0';
    }
    return '$completedExercises/$totalExercises';
  }

  int get hoursTrained => trainedMinutes ~/ 60;

  int get minutesTrained => trainedMinutes % 60;
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

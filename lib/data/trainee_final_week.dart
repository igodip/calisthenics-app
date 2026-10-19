import 'package:supabase_flutter/supabase_flutter.dart';

typedef TrainingDayProgress = ({int week, bool completed});

/// Progress, not dates: the next unfinished day must be in the last numbered
/// week. Skipped earlier days and fully completed plans do not qualify.
bool isFinalTrainingWeek(Iterable<TrainingDayProgress> days) {
  final numbered = days.where((day) => day.week > 0).toList();
  if (numbered.isEmpty) return false;
  final unfinished = numbered.where((day) => !day.completed).toList();
  if (unfinished.isEmpty) return false;
  final lastWeek = numbered
      .map((day) => day.week)
      .reduce((a, b) => a > b ? a : b);
  final nextWeek = unfinished
      .map((day) => day.week)
      .reduce((a, b) => a < b ? a : b);
  return nextWeek == lastWeek;
}

Future<bool> loadTraineeFinalWeek(
  SupabaseClient client,
  String traineeId,
) async {
  final plan = await client
      .from('workout_plans')
      .select('workout_plan_days(days(week, completed))')
      .eq('trainee_id', traineeId)
      .eq('status', 'active')
      .order('starts_on', ascending: false)
      .order('created_at', ascending: false)
      .limit(1)
      .maybeSingle();
  if (plan == null) return false;
  final days = <TrainingDayProgress>[];
  for (final link in plan['workout_plan_days'] as List? ?? []) {
    final day = link['days'];
    if (day is Map && day['week'] is num) {
      days.add((
        week: (day['week'] as num).toInt(),
        completed: day['completed'] == true,
      ));
    }
  }
  return isFinalTrainingWeek(days);
}

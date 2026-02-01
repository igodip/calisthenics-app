import 'package:supabase_flutter/supabase_flutter.dart';

class ExerciseUnlocks {
  ExerciseUnlocks._();

  static Future<Set<String>> loadUnlockedExerciseSlugs(String traineeId) async {
    final client = Supabase.instance.client;
    final response = await client
        .from('trainee_exercise_unlocks')
        .select('exercise_id, exercises ( slug )')
        .eq('trainee_id', traineeId);
    final rows = (response as List<dynamic>).cast<Map<String, dynamic>>();
    final slugs = <String>{};
    for (final row in rows) {
      final exercise = row['exercises'];
      if (exercise is Map) {
        final slug = exercise['slug']?.toString();
        if (slug != null && slug.isNotEmpty) {
          slugs.add(slug);
        }
      }
    }
    return slugs;
  }

  static Future<void> unlockExercise({
    required String traineeId,
    required String exerciseId,
  }) async {
    final client = Supabase.instance.client;
    await client.from('trainee_exercise_unlocks').insert({
      'trainee_id': traineeId,
      'exercise_id': exerciseId,
    });
  }
}

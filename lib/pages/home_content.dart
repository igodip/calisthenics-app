import 'package:calisync/model/workout_day.dart';
import 'package:calisync/pages/exercise_tracker.dart';
import 'package:calisync/pages/position_estimation.dart';
import 'package:calisync/components/cards/selection_card.dart';
import 'package:calisync/pages/training.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late Future<List<WorkoutDay>> _workoutDaysFuture;

  @override
  void initState() {
    super.initState();
    _workoutDaysFuture = _loadWorkoutDays();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<WorkoutDay>>(
          future: _workoutDaysFuture,
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
                          _workoutDaysFuture = _loadWorkoutDays();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ),
                ],
              );
            }

            final days = snapshot.data ?? [];
            if (days.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 32),
                  Icon(
                    Icons.fitness_center,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.homeEmptyTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.homeEmptyDescription,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: days.length + 2,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == days.length + 1) {
                  return SelectionCard(
                    title: l10n.exerciseTrackerTitle,
                    icon: Icons.checklist,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExerciseTrackerPage(),
                        ),
                      );
                    },
                  );
                }
                if (index == days.length) {
                  return SelectionCard(
                    title: l10n.poseEstimationTitle,
                    icon: Icons.man,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PoseCamPage(),
                        ),
                      );
                    },
                  );
                }

                final day = days[index];
                return SelectionCard(
                  title: day.formattedTitle(l10n),
                  icon: Icons.calendar_today,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Training(day: day),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _workoutDaysFuture = _loadWorkoutDays();
    });
    await _workoutDaysFuture;
  }

  Future<List<WorkoutDay>> _loadWorkoutDays() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception(AppLocalizations.of(context)!.unauthenticated);
    }

    final plan = await client
        .from('training_plans')
        .select('id, name, goal, weeks')
        .eq('owner', userId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (plan == null) {
      return [];
    }

    final planId = plan['id'] as String;

    final response = await client
        .from('plan_workouts')
        .select('''
            id, week, dow, position,
            workout_templates!plan_workouts_template_id_fkey (
              id, name, notes,
              template_exercises (
                id, position, default_sets, default_reps, rest_seconds,
                default_intensity, exercise_library ( id, name )
              )
            )
          ''')
        .eq('plan_id', planId)
        .order('week', ascending: true)
        .order('dow', ascending: true)
        .order('position', ascending: true);

    final data = (response as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    return data.map((row) {
      final template =
          (row['workout_templates'] as Map<String, dynamic>?) ?? {};
      final templateExercises =
      (template['template_exercises'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      final exercises = templateExercises.map((exercise) {
        final exerciseLibrary =
            (exercise['exercise_library'] as Map<String, dynamic>?) ?? {};
        return WorkoutExercise(
          id: exercise['id'] as String?,
          name: exerciseLibrary['name'] as String?,
          sets: (exercise['default_sets'] as num?)?.toInt(),
          reps: (exercise['default_reps'] as num?)?.toInt(),
          restSeconds: (exercise['rest_seconds'] as num?)?.toInt(),
          intensity: exercise['default_intensity'] as String?,
          notes: exercise['notes'] as String?,
        );
      }).toList();

      return WorkoutDay(
        id: row['id'] as String?,
        week: (row['week'] as num?)?.toInt() ?? 0,
        dow: (row['dow'] as num?)?.toInt() ?? 0,
        name: template['name'] as String?,
        notes: template['notes'] as String?,
        exercises: exercises,
      );
    }).toList();
  }

}

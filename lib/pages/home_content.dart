import 'package:calisync/model/workout_day.dart';
import 'package:calisync/pages/exercise_tracker.dart';
import 'package:calisync/components/cards/selection_card.dart';
import 'package:calisync/pages/training.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';

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
                  const SizedBox(height: 24),
                  SelectionCard(
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
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: days.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == days.length) {
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

    final response = await client
        .from('days')
        .select('''
            id, week, day_code, title, notes,
            day_exercises (
              id, position, notes,
              exercises ( id, name )
            )
          ''')
        .eq('trainee_id', userId)
        .order('week', ascending: true)
        .order('day_code', ascending: true)
        .order('position', referencedTable: 'day_exercises', ascending: true);

    final data = (response as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    return data.map((row) {
      final dayExercises =
          (row['day_exercises'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

      final exercises = dayExercises.map((exercise) {
        final exerciseDetails =
            (exercise['exercises'] as Map<String, dynamic>?) ?? {};
        return WorkoutExercise(
          id: exercise['id'] as String?,
          name: exerciseDetails['name'] as String?,
          position: (exercise['position'] as num?)?.toInt(),
          notes: exercise['notes'] as String?,
        );
      }).toList();

      return WorkoutDay(
        id: row['id'] as String?,
        week: (row['week'] as num?)?.toInt() ?? 0,
        dayCode: (row['day_code'] as String? ?? '').trim(),
        title: row['title'] as String?,
        notes: row['notes'] as String?,
        exercises: exercises,
      );
    }).toList();
  }

}

import 'package:calisync/model/workout_day.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/plan_expired_gate.dart';
import '../l10n/app_localizations.dart';

class Training extends StatefulWidget {
  final WorkoutDay day;

  const Training({super.key, required this.day});

  @override
  State<Training> createState() => _TrainingState();
}

class _TrainingState extends State<Training> {
  late final List<WorkoutExercise> _exercises;
  final Set<String> _togglingExerciseCompletion = {};
  late bool _isCompleted;
  bool _updatingCompletion = false;
  bool _completionChanged = false;

  @override
  void initState() {
    super.initState();
    _exercises = List<WorkoutExercise>.from(widget.day.exercises);
    _sortExercises();
    _isCompleted = widget.day.isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pop(_completionChanged);
          }
        });
      },
      child: PlanExpiredGate(
        child: Scaffold(
          backgroundColor: const Color(0xFF0D1626),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D1626),
            elevation: 0,
            foregroundColor: Colors.white,
            title: Text(l10n.trainingTodayTitle),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz),
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF202B3E), Color(0xFF151F33)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.day.formattedTitle(l10n),
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '45 min',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Color(0xFF4DA6FF),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_exercises.length} ${l10n.trainingHeaderExercise}${_exercises.length == 1 ? '' : 's'}',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (int index = 0; index < _exercises.length; index++)
                  _ExerciseCard(
                    exercise: _exercises[index],
                    detailText:
                        _exerciseDetailText(_exercises[index], l10n),
                    updatingCompletion: _togglingExerciseCompletion
                        .contains(_exercises[index].id),
                    onToggleCompletion: () => _toggleExerciseCompletion(index),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2B7BFF), Color(0xFF1A5DDB)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2B7BFF).withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FilledButton(
                onPressed: _updatingCompletion ? null : _toggleCompletion,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _updatingCompletion
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _isCompleted
                            ? l10n.trainingWorkoutCompleted
                            : l10n.trainingStartWorkout,
                        style: textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleExerciseCompletion(int index) async {
    final exercise = _exercises[index];
    final l10n = AppLocalizations.of(context)!;

    if (exercise.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.trainingExerciseCompletionUnavailable)),
      );
      return;
    }

    final newValue = !exercise.isCompleted;

    setState(() {
      _togglingExerciseCompletion.add(exercise.id!);
    });

    try {
      await Supabase.instance.client
          .from('day_exercises')
          .update({'completed': newValue})
          .eq('id', exercise.id!);

      if (!mounted) return;

      setState(() {
        _exercises[index] = WorkoutExercise(
          id: exercise.id,
          name: exercise.name,
          notes: exercise.notes,
          traineeNotes: exercise.traineeNotes,
          position: exercise.position,
          isCompleted: newValue,
        );
        _completionChanged = true;
        _sortExercises();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.trainingExerciseCompletionSaved)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.trainingExerciseCompletionError('$error'))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _togglingExerciseCompletion.remove(exercise.id);
        });
      }
    }
  }

  Future<void> _toggleCompletion() async {
    final dayId = widget.day.id;
    final l10n = AppLocalizations.of(context)!;

    if (dayId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.trainingCompletionUnavailable)),
      );
      return;
    }

    final newValue = !_isCompleted;

    setState(() {
      _updatingCompletion = true;
    });

    try {
      final completedAt = newValue ? DateTime.now().toUtc() : null;
      await Supabase.instance.client
          .from('days')
          .update({
            'completed': newValue,
            'completed_at': completedAt?.toIso8601String(),
          })
          .eq('id', dayId);

      if (!mounted) return;

      setState(() {
        _isCompleted = newValue;
        _completionChanged = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.trainingCompletionSaved)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.trainingCompletionError('$error'))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingCompletion = false;
        });
      }
    }
  }

  void _sortExercises() {
    _exercises.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return _exerciseOrderValue(a).compareTo(_exerciseOrderValue(b));
    });
  }

  int _exerciseOrderValue(WorkoutExercise exercise) {
    if (exercise.position != null) return exercise.position!;

    final matchIndex = widget.day.exercises.indexWhere(
      (original) => original.id != null && original.id == exercise.id,
    );
    if (matchIndex != -1) return matchIndex;

    final currentIndex = _exercises.indexOf(exercise);
    if (currentIndex != -1) return currentIndex;

    final fallbackIndex = widget.day.exercises.indexOf(exercise);
    return fallbackIndex < 0 ? 0 : fallbackIndex;
  }
}

class _ExerciseCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final String detailText;
  final bool updatingCompletion;
  final VoidCallback onToggleCompletion;

  const _ExerciseCard({
    required this.exercise,
    required this.detailText,
    required this.updatingCompletion,
    required this.onToggleCompletion,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exerciseName = exercise.name?.trim().isNotEmpty == true
        ? exercise.name!
        : l10n.defaultExerciseName;
    final isCompleted = exercise.isCompleted;
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: Colors.white,
      decoration: isCompleted ? TextDecoration.lineThrough : null,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121C2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: updatingCompletion ? null : onToggleCompletion,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF324158), Color(0xFF1A2438)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exerciseName, style: titleStyle),
                      const SizedBox(height: 4),
                      Text(
                        detailText,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                if (updatingCompletion)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.chevron_right,
                    color: isCompleted
                        ? const Color(0xFF4DA6FF)
                        : Colors.white38,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _exerciseDetailText(
  WorkoutExercise exercise,
  AppLocalizations l10n,
) {
  final notes = (exercise.notes ?? '').trim();
  if (notes.isNotEmpty) return notes;

  final traineeNotes = (exercise.traineeNotes ?? '').trim();
  if (traineeNotes.isNotEmpty) return traineeNotes;

  return '${l10n.trainingHeaderSets} · ${l10n.trainingHeaderReps}';
}

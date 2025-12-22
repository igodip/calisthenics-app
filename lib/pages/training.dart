import 'package:calisync/model/workout_day.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final Set<String> _visibleTraineeNotes = {};
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        Navigator.of(context).pop(_completionChanged);
        return;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.day.formattedTitle(l10n))),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if ((widget.day.notes ?? '').trim().isNotEmpty)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.generalNotes,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.day.notes!.trim()),
                    ],
                  ),
                ),
              ),
            for (int index = 0; index < _exercises.length; index++)
              _ExerciseCard(
                exercise: _exercises[index],
                showTraineeNotes: _visibleTraineeNotes
                    .contains(_exerciseKey(_exercises[index], index)),
                updatingCompletion: _togglingExerciseCompletion
                    .contains(_exercises[index].id),
                onToggleTraineeNotes: () => _toggleTraineeNotes(index),
                onToggleCompletion: () => _toggleExerciseCompletion(index),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _updatingCompletion ? null : _toggleCompletion,
              icon: _updatingCompletion
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _isCompleted ? Icons.undo : Icons.check_circle_outline,
                    ),
              label: Text(
                _isCompleted
                    ? l10n.trainingMarkIncomplete
                    : l10n.trainingMarkComplete,
              ),
            ),
          ],
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
      await Supabase.instance.client
          .from('days')
          .update({'completed': newValue})
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

  String _exerciseKey(WorkoutExercise exercise, int fallbackIndex) =>
      exercise.id ?? 'exercise-$fallbackIndex';

  void _toggleTraineeNotes(int index) {
    final key = _exerciseKey(_exercises[index], index);
    setState(() {
      if (_visibleTraineeNotes.contains(key)) {
        _visibleTraineeNotes.remove(key);
      } else {
        _visibleTraineeNotes.add(key);
      }
    });
  }
}

class _ExerciseCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final bool showTraineeNotes;
  final bool updatingCompletion;
  final VoidCallback onToggleTraineeNotes;
  final VoidCallback onToggleCompletion;

  const _ExerciseCard({
    required this.exercise,
    required this.showTraineeNotes,
    required this.updatingCompletion,
    required this.onToggleTraineeNotes,
    required this.onToggleCompletion,
  });

  void _showExerciseNotes(
    BuildContext context,
    String exerciseName,
    String notes,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exerciseName),
        content: Text(notes),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exerciseName = exercise.name?.trim().isNotEmpty == true
        ? exercise.name!
        : l10n.defaultExerciseName;
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = exercise.isCompleted;
    final cardColor =
        isCompleted ? colorScheme.primaryContainer : Theme.of(context).cardColor;
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          decoration:
              isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
          color: isCompleted ? colorScheme.onPrimaryContainer : null,
        );
    final traineeNotes = exercise.traineeNotes?.trim() ?? '';
    final hasTraineeNotes = traineeNotes.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    exerciseName,
                    style: titleStyle,
                  ),
                ),
                if (hasTraineeNotes)
                  IconButton(
                    onPressed: onToggleTraineeNotes,
                    tooltip: l10n.trainingNotesLabel,
                    icon: Icon(
                      showTraineeNotes
                          ? Icons.sticky_note_2
                          : Icons.sticky_note_2_outlined,
                    ),
                  ),
                IconButton(
                  onPressed: updatingCompletion ? null : onToggleCompletion,
                  tooltip: l10n.trainingExerciseCompletedLabel,
                  icon: updatingCompletion
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isCompleted
                              ? colorScheme.primary
                              : Theme.of(context).iconTheme.color,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if ((exercise.notes ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => _showExerciseNotes(
                    context,
                    exerciseName,
                    exercise.notes!.trim(),
                  ),
                  icon: const Icon(Icons.sticky_note_2_outlined, size: 18),
                  label: Text(l10n.trainingNotesLabel),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
            if (hasTraineeNotes && showTraineeNotes) ...[
              const SizedBox(height: 8),
              Text(
                traineeNotes,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

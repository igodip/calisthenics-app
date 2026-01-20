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
  late final Map<String, TextEditingController> _personalNoteControllers;
  final Set<String> _savingNotes = {};
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
    _personalNoteControllers = {};
    for (int i = 0; i < _exercises.length; i++) {
      final key = _controllerKey(_exercises[i], i);
      _personalNoteControllers[key] =
          TextEditingController(text: _exercises[i].traineeNotes ?? '');
    }
  }

  @override
  void dispose() {
    for (final controller in _personalNoteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  traineeNotesController: _personalNoteControllers.putIfAbsent(
                    _controllerKey(_exercises[index], index),
                    () => TextEditingController(
                      text: _exercises[index].traineeNotes ?? '',
                    ),
                  ),
                  saving: _savingNotes.contains(_exercises[index].id),
                  updatingCompletion: _togglingExerciseCompletion
                      .contains(_exercises[index].id),
                  onSaveNotes: () => _saveNotes(index),
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
      ),
    );
  }

  Future<void> _saveNotes(int index) async {
    final exercise = _exercises[index];
    final note = _personalNoteControllers[_controllerKey(exercise, index)]!
        .text
        .trim();
    final l10n = AppLocalizations.of(context)!;

    if (exercise.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.trainingNotesUnavailable)),
      );
      return;
    }

    setState(() => _savingNotes.add(exercise.id!));

    try {
      await Supabase.instance.client
          .from('day_exercises')
          .update({'trainee_notes': note.isEmpty ? null : note})
          .eq('id', exercise.id!);

      if (!mounted) return;

      setState(() {
        _exercises[index] = WorkoutExercise(
          id: exercise.id,
          name: exercise.name,
          notes: exercise.notes,
          traineeNotes: note.isEmpty ? null : note,
          position: exercise.position,
          isCompleted: exercise.isCompleted,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.trainingNotesSaved)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.trainingNotesError('$error'))),
      );
    } finally {
      if (mounted) {
        setState(() => _savingNotes.remove(exercise.id));
      }
    }
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

  String _controllerKey(WorkoutExercise exercise, int fallbackIndex) =>
      exercise.id ?? 'local-$fallbackIndex';
}

class _ExerciseCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final TextEditingController traineeNotesController;
  final bool saving;
  final bool updatingCompletion;
  final VoidCallback onSaveNotes;
  final VoidCallback onToggleCompletion;

  const _ExerciseCard({
    required this.exercise,
    required this.traineeNotesController,
    required this.saving,
    required this.updatingCompletion,
    required this.onSaveNotes,
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
            if ((exercise.traineeNotes ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => _showExerciseNotes(
                    context,
                    exerciseName,
                    exercise.traineeNotes!.trim(),
                  ),
                  icon: const Icon(Icons.notes_outlined, size: 18),
                  label: Text(l10n.trainingTraineeNotesLabel),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: traineeNotesController,
              maxLines: null,
              decoration: InputDecoration(
                labelText: l10n.trainingTraineeNotesLabel,
                hintText: l10n.trainingHeaderNotes,
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                suffixIcon: saving
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.save),
                        tooltip: l10n.trainingNotesSave,
                        onPressed: onSaveNotes,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

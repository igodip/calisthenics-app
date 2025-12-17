import 'package:calisync/model/workout_day.dart';
import 'package:calisync/pages/exercise_tracker.dart';
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
  late final Map<int, TextEditingController> _noteControllers;
  final Set<int> _savingNotes = {};
  late bool _isCompleted;
  bool _updatingCompletion = false;
  bool _completionChanged = false;

  @override
  void initState() {
    super.initState();
    _exercises = List<WorkoutExercise>.from(widget.day.exercises);
    _isCompleted = widget.day.isCompleted;
    _noteControllers = {
      for (int i = 0; i < _exercises.length; i++)
        i: TextEditingController(text: _exercises[i].notes ?? '')
    };
  }

  @override
  void dispose() {
    for (final controller in _noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_completionChanged);
        return false;
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
                notesController: _noteControllers[index]!,
                saving: _savingNotes.contains(index),
                onSaveNotes: () => _saveNotes(index),
                onOpenTracker: () =>
                    _openTools(context, _exercises[index]),
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

  Future<void> _saveNotes(int index) async {
    final exercise = _exercises[index];
    final note = _noteControllers[index]!.text.trim();
    final l10n = AppLocalizations.of(context)!;

    if (exercise.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.trainingNotesUnavailable)),
      );
      return;
    }

    setState(() => _savingNotes.add(index));

    try {
      await Supabase.instance.client
          .from('day_exercises')
          .update({'notes': note.isEmpty ? null : note})
          .eq('id', exercise.id!);

      if (!mounted) return;

      setState(() {
        _exercises[index] = WorkoutExercise(
          id: exercise.id,
          name: exercise.name,
          notes: note.isEmpty ? null : note,
          position: exercise.position,
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
        setState(() => _savingNotes.remove(index));
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

  void _openTools(BuildContext context, WorkoutExercise exercise) {
    final l10n = AppLocalizations.of(context)!;
    final exerciseName = exercise.name?.trim().isNotEmpty == true
        ? exercise.name!
        : l10n.defaultExerciseName;
    final quickAdds = <int>{1};
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExerciseTrackerPage(
          title: exerciseName,
          initialExercises: [
            ExerciseDefinition(
              name: exerciseName,
              color: Theme.of(context).colorScheme.primary,
              icon: Icons.fitness_center,
              quickAddValues: quickAdds.toList()..sort(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final TextEditingController notesController;
  final bool saving;
  final VoidCallback onSaveNotes;
  final VoidCallback onOpenTracker;

  const _ExerciseCard({
    required this.exercise,
    required this.notesController,
    required this.saving,
    required this.onSaveNotes,
    required this.onOpenTracker,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exerciseName = exercise.name?.trim().isNotEmpty == true
        ? exercise.name!
        : l10n.defaultExerciseName;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    exerciseName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onOpenTracker,
                  icon: const Icon(Icons.fitness_center),
                  tooltip: l10n.trainingOpenTracker,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: null,
              decoration: InputDecoration(
                labelText: l10n.trainingNotesLabel,
                hintText: l10n.trainingHeaderNotes,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: saving ? null : onSaveNotes,
                icon: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(l10n.trainingNotesSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:calisync/model/workout_day.dart';
import 'package:calisync/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../components/plan_expired_gate.dart';
import '../data/exercise_translations.dart';
import '../data/terminology_translations.dart';
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
  final Set<String> _expandedExercises = {};
  final Map<String, TextEditingController> _noteControllers = {};
  final Set<String> _savingNotes = {};
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
    for (final controller in _noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final appColors = theme.extension<AppColors>();
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
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor:
                theme.appBarTheme.backgroundColor ?? colorScheme.surface,
            elevation: 0,
            foregroundColor:
                theme.appBarTheme.foregroundColor ?? colorScheme.onSurface,
            title: Text(l10n.trainingTodayTitle),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz),
                    color: colorScheme.onSurfaceVariant,
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
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.surfaceContainerHighest,
                        colorScheme.surface,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                    ),
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
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            l10n.trainingDurationMinutes(45),
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_exercises.length} ${_exercises.length == 1 ? l10n.trainingHeaderExercise : l10n.trainingHeaderExercises}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
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
                    isExpanded:
                        _expandedExercises.contains(_exerciseKey(index)),
                    updatingCompletion: _togglingExerciseCompletion
                        .contains(_exercises[index].id),
                    isSavingNotes:
                        _savingNotes.contains(_exerciseKey(index)),
                    notesController:
                        _notesControllerFor(_exercises[index], index),
                    onToggleCompletion: () => _toggleExerciseCompletion(index),
                    onToggleExpanded: () => _toggleExpanded(index),
                    onSaveNotes: () => _saveExerciseNotes(index),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: appColors?.primaryGradient ??
                    LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.35),
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
                          color: colorScheme.onPrimary,
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
          terminology: exercise.terminology,
          skills: exercise.skills,
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

  Future<void> _saveExerciseNotes(int index) async {
    final exercise = _exercises[index];
    final l10n = AppLocalizations.of(context)!;
    final exerciseId = exercise.id;

    if (exerciseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.trainingExerciseCompletionUnavailable)),
      );
      return;
    }

    final key = _exerciseKey(index);
    final controller = _noteControllers[key];
    if (controller == null) return;

    setState(() {
      _savingNotes.add(key);
    });

    try {
      final newNotes = controller.text.trim();
      await Supabase.instance.client
          .from('day_exercises')
          .update({'trainee_notes': newNotes})
          .eq('id', exerciseId);

      if (!mounted) return;

      setState(() {
        _exercises[index] = WorkoutExercise(
          id: exercise.id,
          name: exercise.name,
          notes: exercise.notes,
          traineeNotes: newNotes,
          position: exercise.position,
          terminology: exercise.terminology,
          skills: exercise.skills,
          isCompleted: exercise.isCompleted,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.trainingExerciseNotesSaved)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.trainingExerciseNotesError('$error'))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingNotes.remove(key);
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

  String _exerciseKey(int index) {
    final exercise = _exercises[index];
    return exercise.id ?? 'index-$index';
  }

  void _toggleExpanded(int index) {
    final key = _exerciseKey(index);
    setState(() {
      if (_expandedExercises.contains(key)) {
        _expandedExercises.remove(key);
      } else {
        _expandedExercises.add(key);
      }
    });
  }

  TextEditingController _notesControllerFor(
    WorkoutExercise exercise,
    int index,
  ) {
    final key = _exerciseKey(index);
    final existing = _noteControllers[key];
    if (existing != null) return existing;
    final controller = TextEditingController(
      text: (exercise.traineeNotes ?? '').trim(),
    );
    _noteControllers[key] = controller;
    return controller;
  }
}

class _ExerciseCard extends StatelessWidget {
  final WorkoutExercise exercise;
  final String detailText;
  final bool isExpanded;
  final bool updatingCompletion;
  final bool isSavingNotes;
  final TextEditingController notesController;
  final VoidCallback onToggleCompletion;
  final VoidCallback onToggleExpanded;
  final VoidCallback onSaveNotes;

  const _ExerciseCard({
    required this.exercise,
    required this.detailText,
    required this.isExpanded,
    required this.updatingCompletion,
    required this.isSavingNotes,
    required this.notesController,
    required this.onToggleCompletion,
    required this.onToggleExpanded,
    required this.onSaveNotes,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exerciseName = exercise.name?.trim().isNotEmpty == true
        ? exercise.name!
        : l10n.defaultExerciseName;
    final isCompleted = exercise.isCompleted;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final titleStyle = textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
      decoration: isCompleted ? TextDecoration.lineThrough : null,
    );

    final localizedTerminology = exercise.terminology
        .map(
          (term) =>
              TerminologyTranslations.lookup(term, l10n.localeName)?.title ??
              term,
        )
        .toList();
    final localizedSkills = exercise.skills
        .map(
          (skill) =>
              ExerciseGuideTranslations.nameForSlug(skill, l10n.localeName) ??
              skill,
        )
        .toList();

    final hasTerminology = localizedTerminology.isNotEmpty;
    final hasSkills = localizedSkills.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            InkWell(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              onTap: onToggleExpanded,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primaryContainer,
                            colorScheme.surfaceContainerHighest,
                          ],
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
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (hasTerminology || hasSkills) ...[
                            const SizedBox(height: 10),
                            if (hasTerminology)
                              _InfoChips(
                                title: l10n.terminologyTitle,
                                items: localizedTerminology,
                              ),
                            if (hasTerminology && hasSkills)
                              const SizedBox(height: 8),
                            if (hasSkills)
                              _InfoChips(
                                title: l10n.guidesTitle,
                                items: localizedSkills,
                              ),
                          ],
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
                        isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.6),
                      ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.trainingExerciseCoachNotesTitle,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      (exercise.notes ?? '').trim().isNotEmpty
                          ? (exercise.notes ?? '').trim()
                          : l10n.trainingExerciseNoCoachNotes,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: l10n.trainingExerciseYourNotesLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        fillColor: colorScheme.surface,
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed:
                                isSavingNotes ? null : onSaveNotes,
                            icon: isSavingNotes
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label:
                                Text(l10n.trainingExerciseSaveNotes),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CheckboxListTile(
                              value: isCompleted,
                              onChanged: updatingCompletion
                                  ? null
                                  : (_) => onToggleCompletion(),
                              title: Text(
                                l10n.trainingExerciseResolvedLabel,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoChips extends StatelessWidget {
  final String title;
  final List<String> items;

  const _InfoChips({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items
              .map(
                (item) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Text(
                      item,
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
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

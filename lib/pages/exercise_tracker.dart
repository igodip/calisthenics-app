import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Definition of a trackable exercise.
///
/// The [quickAddValues] list controls which preset buttons are displayed for
/// quickly logging repetitions.  Additional exercises can be provided when
/// constructing [ExerciseTrackerPage], making the tracker extensible without
/// modifying the widget itself.
@immutable
class ExerciseDefinition {
  const ExerciseDefinition({
    required this.name,
    this.icon = Icons.fitness_center,
    this.color = Colors.blueAccent,
    this.quickAddValues = const [1, 5, 10],
    this.restDuration,
    this.targetReps,
  });

  final String name;
  final IconData icon;
  final Color color;
  final List<int> quickAddValues;
  final Duration? restDuration;
  final int? targetReps;
}

class ExerciseTrackerPage extends StatefulWidget {
  const ExerciseTrackerPage({
    super.key,
    this.title = 'Exercise tracker',
    List<ExerciseDefinition>? initialExercises,
  }) : initialExercises = initialExercises ?? const [
          ExerciseDefinition(
            name: 'Push ups',
            icon: Icons.front_hand,
            color: Colors.orangeAccent,
            quickAddValues: [1, 5, 10, 15],
          ),
          ExerciseDefinition(
            name: 'Pull ups',
            icon: Icons.fitness_center,
            color: Colors.lightBlueAccent,
            quickAddValues: [1, 3, 5, 8],
          ),
          ExerciseDefinition(
            name: 'Chin ups',
            icon: Icons.accessibility_new,
            color: Colors.purpleAccent,
            quickAddValues: [1, 3, 5, 8],
          ),
        ];

  final String title;
  final List<ExerciseDefinition> initialExercises;

  @override
  State<ExerciseTrackerPage> createState() => _ExerciseTrackerPageState();
}

class _ExerciseTrackerPageState extends State<ExerciseTrackerPage> {
  late List<_TrackedExercise> _exercises;
  int _colorIndex = 0;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final definitions = widget.initialExercises;
      _exercises = definitions.map((definition) => _TrackedExercise(definition)).toList();
      _colorIndex = definitions.length;
      _initialized = true;
    }
  }

  void _addExercise(ExerciseDefinition definition) {
    setState(() {
      _exercises.add(_TrackedExercise(definition));
    });
  }

  void _showAddExerciseDialog() {
    final nameController = TextEditingController();
    final quickAddsController = TextEditingController(text: '1,5,10');
    final l10n = AppLocalizations.of(context)!;
    final restController = TextEditingController();
    final targetController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.exerciseAddDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.exerciseNameLabel,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quickAddsController,
                decoration: InputDecoration(
                  labelText: l10n.quickAddValuesLabel,
                  helperText: l10n.quickAddValuesHelper,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetController,
                decoration: const InputDecoration(
                  labelText: 'Target reps',
                  helperText: 'Optional total goal for the session',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: restController,
                decoration: const InputDecoration(
                  labelText: 'Rest duration (seconds)',
                  helperText: 'Optional countdown timer preset',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.exerciseNameMissing)),
                  );
                  return;
                }
                final values = quickAddsController.text
                    .split(',')
                    .map((s) => int.tryParse(s.trim()))
                    .where((value) => value != null && value > 0)
                    .map((value) => value!)
                    .toList();
                final targetReps = int.tryParse(targetController.text.trim());
                final restSeconds = int.tryParse(restController.text.trim());
                final restDuration =
                    restSeconds != null && restSeconds > 0 ? Duration(seconds: restSeconds) : null;
                Navigator.of(context).pop();
                final palette = Colors.primaries;
                final color = palette[_colorIndex % palette.length];
                _colorIndex += 1;
                _addExercise(
                  ExerciseDefinition(
                    name: name,
                    icon: Icons.fitness_center,
                    color: color.shade300,
                    quickAddValues: values.isNotEmpty ? values : const [1, 5, 10],
                    targetReps: targetReps != null && targetReps > 0 ? targetReps : null,
                    restDuration: restDuration,
                  ),
                );
              },
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _exercises.isEmpty
          ? Center(
              child: Text(l10n.exerciseTrackerEmpty),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) => _ExerciseCard(
                tracked: _exercises[index],
                onUpdated: () => setState(() {}),
              ),
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemCount: _exercises.length,
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExerciseDialog,
        icon: const Icon(Icons.add),
        label: Text(l10n.exerciseAddButton),
      ),
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  const _ExerciseCard({
    required this.tracked,
    required this.onUpdated,
  });

  final _TrackedExercise tracked;
  final VoidCallback onUpdated;

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  late Duration _initialDuration;
  late Duration _remaining;
  Timer? _timer;

  bool get _isTimerRunning => _timer != null;

  @override
  void initState() {
    super.initState();
    _initialDuration = widget.tracked.restDuration ?? const Duration(minutes: 2);
    _remaining = _initialDuration;
  }

  @override
  void didUpdateWidget(covariant _ExerciseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tracked != widget.tracked) {
      _initialDuration = widget.tracked.restDuration ?? _initialDuration;
      if (!_isTimerRunning) {
        _remaining = _initialDuration;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isTimerRunning) return;
    if (_remaining <= Duration.zero) {
      setState(() {
        _remaining = _initialDuration;
      });
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remaining <= const Duration(seconds: 1)) {
        setState(() {
          _remaining = Duration.zero;
          _timer?.cancel();
          _timer = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rest finished for ${widget.tracked.definition.name}!')),
        );
      } else {
        setState(() {
          _remaining -= const Duration(seconds: 1);
        });
      }
    });
    setState(() {});
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _timer = null;
    });
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() {
      _remaining = _initialDuration;
    });
  }

  Future<void> _setTimerDuration() async {
    final controller = TextEditingController(text: _initialDuration.inSeconds.toString());
    final duration = await showDialog<Duration>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set rest duration'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Duration (seconds)',
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final seconds = int.tryParse(controller.text.trim());
                if (seconds == null || seconds <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a positive number.')),
                  );
                  return;
                }
                Navigator.of(context).pop(Duration(seconds: seconds));
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (duration != null) {
      setState(() {
        _initialDuration = duration;
        _remaining = duration;
        widget.tracked.restDuration = duration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final definition = widget.tracked.definition;
    final color = definition.color.withValues(alpha: 0.15);
    final goal = definition.targetReps;
    final totalReps = widget.tracked.totalReps;
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: definition.color.withValues(alpha: 0.2),
                  foregroundColor: definition.color.darken(),
                  child: Icon(definition.icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        definition.name,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        goal != null
                            ? '$totalReps / $goal reps logged'
                            : l10n.exerciseTotalReps(widget.tracked.totalReps),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Undo last set',
                  onPressed: widget.tracked.canUndo
                      ? () {
                          widget.tracked.undoLast();
                          widget.onUpdated();
                        }
                      : null,
                  icon: const Icon(Icons.undo),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in definition.quickAddValues)
                  FilledButton.tonal(
                    onPressed: () {
                      widget.tracked.logSet(value);
                      widget.onUpdated();
                    },
                    child: Text('+$value'),
                  ),
                FilledButton.icon(
                  onPressed: () async {
                    final reps = await _showCustomRepsDialog(context);
                    if (reps != null) {
                      widget.tracked.logSet(reps);
                      widget.onUpdated();
                    }
                  },
                  icon: const Icon(Icons.more_time),
                  label: Text(l10n.custom),
                ),
                if (widget.tracked.totalReps > 0)
                  OutlinedButton(
                    onPressed: () {
                      widget.tracked.reset();
                      widget.onUpdated();
                    },
                    child: Text(l10n.reset),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _TimerControls(
              remaining: _remaining,
              isRunning: _isTimerRunning,
              onStart: _startTimer,
              onPause: _pauseTimer,
              onReset: _resetTimer,
              onSetDuration: _setTimerDuration,
            ),
            if (widget.tracked.sets.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final set in widget.tracked.sets.reversed)
                    Chip(
                      avatar: const Icon(Icons.check, size: 18),
                      label: Text(l10n.repsChip(set.reps)),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () {
                        widget.tracked.removeSet(set);
                        widget.onUpdated();
                      },
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<int?> _showCustomRepsDialog(BuildContext context) async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.logRepsTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: l10n.repetitionsLabel,
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value == null || value <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.positiveNumberError)),
                  );
                  return;
                }
                Navigator.of(context).pop(value);
              },
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }
}

class _TimerControls extends StatelessWidget {
  const _TimerControls({
    required this.remaining,
    required this.isRunning,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    required this.onSetDuration,
  });

  final Duration remaining;
  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onSetDuration;

  String get _formattedTime {
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rest timer',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formattedTime,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: isRunning ? 'Pause' : 'Start',
              onPressed: isRunning ? onPause : onStart,
              icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
            ),
            IconButton(
              tooltip: 'Reset',
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: onSetDuration,
          icon: const Icon(Icons.timer_outlined),
          label: const Text('Set duration'),
        ),
      ],
    );
  }
}

class _TrackedExercise {
  _TrackedExercise(this.definition) : restDuration = definition.restDuration;

  final ExerciseDefinition definition;
  final List<_ExerciseSet> sets = [];
  Duration? restDuration;

  int get totalReps => sets.fold<int>(0, (sum, set) => sum + set.reps);

  bool get canUndo => sets.isNotEmpty;

  void logSet(int reps) {
    sets.add(_ExerciseSet(reps: reps, timestamp: DateTime.now()));
  }

  void undoLast() {
    if (sets.isNotEmpty) {
      sets.removeLast();
    }
  }

  void removeSet(_ExerciseSet set) {
    sets.remove(set);
  }

  void reset() {
    sets.clear();
  }
}

class _ExerciseSet {
  _ExerciseSet({required this.reps, required this.timestamp});

  final int reps;
  final DateTime timestamp;
}

extension on Color {
  Color darken([double amount = 0.2]) {
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}

import 'package:flutter/material.dart';

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
  });

  final String name;
  final IconData icon;
  final Color color;
  final List<int> quickAddValues;
}

class ExerciseTrackerPage extends StatefulWidget {
  const ExerciseTrackerPage({super.key, List<ExerciseDefinition>? initialExercises})
      : initialExercises = initialExercises ?? const [
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

  final List<ExerciseDefinition> initialExercises;

  @override
  State<ExerciseTrackerPage> createState() => _ExerciseTrackerPageState();
}

class _ExerciseTrackerPageState extends State<ExerciseTrackerPage> {
  late final List<_TrackedExercise> _exercises;
  int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _exercises = widget.initialExercises
        .map((definition) => _TrackedExercise(definition))
        .toList();
    _colorIndex = widget.initialExercises.length;
  }

  void _addExercise(ExerciseDefinition definition) {
    setState(() {
      _exercises.add(_TrackedExercise(definition));
    });
  }

  void _showAddExerciseDialog() {
    final nameController = TextEditingController();
    final quickAddsController = TextEditingController(text: '1,5,10');
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add exercise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Exercise name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quickAddsController,
                decoration: const InputDecoration(
                  labelText: 'Quick add values',
                  helperText: 'Comma separated repetitions (e.g. 1,5,10)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a name.')),
                  );
                  return;
                }
                final values = quickAddsController.text
                    .split(',')
                    .map((s) => int.tryParse(s.trim()))
                    .where((value) => value != null && value! > 0)
                    .map((value) => value!)
                    .toList();
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
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise tracker'),
      ),
      body: _exercises.isEmpty
          ? const Center(
              child: Text('No exercises yet. Tap + to add one!'),
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
        label: const Text('Add exercise'),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.tracked,
    required this.onUpdated,
  });

  final _TrackedExercise tracked;
  final VoidCallback onUpdated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final definition = tracked.definition;
    final color = definition.color.withOpacity(0.15);
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
                  backgroundColor: definition.color.withOpacity(0.2),
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
                        '${tracked.totalReps} total reps',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Undo last set',
                  onPressed: tracked.canUndo
                      ? () {
                          tracked.undoLast();
                          onUpdated();
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
                      tracked.logSet(value);
                      onUpdated();
                    },
                    child: Text('+$value'),
                  ),
                FilledButton.icon(
                  onPressed: () async {
                    final reps = await _showCustomRepsDialog(context);
                    if (reps != null) {
                      tracked.logSet(reps);
                      onUpdated();
                    }
                  },
                  icon: const Icon(Icons.more_time),
                  label: const Text('Custom'),
                ),
                if (tracked.totalReps > 0)
                  OutlinedButton(
                    onPressed: () {
                      tracked.reset();
                      onUpdated();
                    },
                    child: const Text('Reset'),
                  ),
              ],
            ),
            if (tracked.sets.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final set in tracked.sets.reversed)
                    Chip(
                      avatar: const Icon(Icons.check, size: 18),
                      label: Text('${set.reps} reps'),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: () {
                        tracked.removeSet(set);
                        onUpdated();
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
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log reps'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Repetitions',
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
                final value = int.tryParse(controller.text);
                if (value == null || value <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a positive number.')),
                  );
                  return;
                }
                Navigator.of(context).pop(value);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class _TrackedExercise {
  _TrackedExercise(this.definition);

  final ExerciseDefinition definition;
  final List<_ExerciseSet> sets = [];

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

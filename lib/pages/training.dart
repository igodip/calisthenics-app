import 'package:calisync/model/workout_day.dart';
import 'package:calisync/pages/rep_counter.dart';
import 'package:calisync/pages/rep_timer.dart';
import 'package:calisync/pages/timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Training extends StatelessWidget {
  final WorkoutDay day;

  const Training({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final exercises = day.exercises;
    final l10n = AppLocalizations.of(context)!;
    final headers = [
      l10n.trainingHeaderExercise,
      l10n.trainingHeaderSets,
      l10n.trainingHeaderReps,
      l10n.trainingHeaderRest,
      l10n.trainingHeaderIntensity,
      l10n.trainingHeaderNotes,
    ];

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(day.formattedTitle(l10n))),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((day.notes ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.generalNotes,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(day.notes!.trim()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.all(color: colorScheme.outline),
                columnWidths: {
                  for (int i = 0; i < headers.length; i++)
                    i: const IntrinsicColumnWidth(),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: colorScheme.primaryContainer),
                    children: headers.map((header) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          header,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }).toList(),
                  ),
                  ...exercises.map((exercise) {
                    final exerciseName =
                        exercise.name?.trim().isEmpty ?? true
                            ? l10n.defaultExerciseName
                            : exercise.name!;
                    return TableRow(
                      children: [
                        _cell(
                          context,
                          exerciseName,
                          onTap: () => _openTools(context, exercise),
                        ),
                        _cell(context, exercise.sets?.toString() ?? '-'),
                        _cell(context, exercise.reps?.toString() ?? '-'),
                        _cell(context, _formatRest(exercise)),
                        _cell(context, exercise.intensity ?? '-'),
                        _cell(context, exercise.notes ?? day.notes ?? ''),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTools(BuildContext context, WorkoutExercise exercise) {
    final l10n = AppLocalizations.of(context)!;
    final exerciseName = exercise.name?.trim().isEmpty ?? true
        ? l10n.defaultExerciseName
        : exercise.name!;
    final restDuration = exercise.restDuration;
    final reps = exercise.reps;
    if (restDuration != null && reps != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RepTimerWidget(
            title: exerciseName,
            countdownDuration: restDuration,
            initialRepCount: 0,
            targetRepCount: reps,
          ),
        ),
      );
    } else if (restDuration != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TimerPage(
            countdownDuration: restDuration,
          ),
        ),
      );
    } else if (reps != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RepCounter(
            title: exerciseName,
            timerType: '',
          ),
        ),
      );
    }
  }

  Widget _cell(BuildContext context, dynamic value, {VoidCallback? onTap}) {
    final display = value?.toString().trim();
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          (display == null || display.isEmpty) ? '-' : display,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }

  String _formatRest(WorkoutExercise exercise) {
    final restSeconds = exercise.restSeconds;
    if (restSeconds == null || restSeconds <= 0) {
      return '-';
    }
    final minutes = restSeconds ~/ 60;
    final seconds = restSeconds % 60;
    if (minutes > 0 && seconds > 0) {
      return '${minutes}m ${seconds}s';
    }
    if (minutes > 0) {
      return '${minutes}m';
    }
    return '${seconds}s';
  }
}

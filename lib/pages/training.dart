import 'package:calisync/model/workout_day.dart';
import 'package:calisync/pages/rep_counter.dart';
import 'package:calisync/pages/rep_timer.dart';
import 'package:calisync/pages/result.dart';
import 'package:calisync/pages/timer.dart';
import 'package:flutter/material.dart';

class Training extends StatelessWidget {
  final WorkoutDay day;

  const Training({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final exercises = day.exercises;
    final headers = const [
      'Esercizio',
      'Serie',
      'Ripetizioni',
      'Recupero',
      'Intensità',
      'Note',
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_buildTitle())),
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
                              'Note generali',
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
                border: TableBorder.all(color: Colors.grey),
                columnWidths: {
                  for (int i = 0; i < headers.length; i++)
                    i: const IntrinsicColumnWidth(),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.blue[300]),
                    children: headers.map((header) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          header,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }).toList(),
                  ),
                  ...exercises.map((exercise) {
                    return TableRow(
                      children: [
                        _cell(
                          exercise.name,
                          onTap: () => _openTools(context, exercise),
                        ),
                        _cell(exercise.sets?.toString() ?? '-'),
                        _cell(exercise.reps?.toString() ?? '-'),
                        _cell(_formatRest(exercise)),
                        _cell(exercise.intensity ?? '-'),
                        _cell(exercise.notes ?? day.notes ?? ''),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistogramChart()),
                  );
                },
                child: const Text('Check progress'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildTitle() {
    final parts = <String>[];
    if (day.week > 0) {
      parts.add('Settimana ${day.week}');
    }
    final dowName = _dowLabel(day.dow);
    if (dowName != null) {
      parts.add(dowName);
    }
    if (day.name != null && day.name!.isNotEmpty) {
      parts.add(day.name!);
    }
    return parts.isEmpty ? 'Allenamento' : parts.join(' · ');
  }

  void _openTools(BuildContext context, WorkoutExercise exercise) {
    final restDuration = exercise.restDuration;
    final reps = exercise.reps;
    if (restDuration != null && reps != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RepTimerWidget(
            title: exercise.name,
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
            title: exercise.name,
            timerType: '',
          ),
        ),
      );
    }
  }

  Widget _cell(dynamic value, {VoidCallback? onTap}) {
    final display = value?.toString().trim();
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          (display == null || display.isEmpty) ? '-' : display,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
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

  String? _dowLabel(int dow) {
    const labels = {
      1: 'Lunedì',
      2: 'Martedì',
      3: 'Mercoledì',
      4: 'Giovedì',
      5: 'Venerdì',
      6: 'Sabato',
      7: 'Domenica',
    };
    return labels[dow];
  }
}

class WorkoutExercise {
  final String? id;
  final String name;
  final int? sets;
  final int? reps;
  final int? restSeconds;
  final String? intensity;
  final String? notes;

  const WorkoutExercise({
    required this.name,
    this.id,
    this.sets,
    this.reps,
    this.restSeconds,
    this.intensity,
    this.notes,
  });

  Duration? get restDuration =>
      restSeconds != null ? Duration(seconds: restSeconds!) : null;
}

class WorkoutDay {
  final String? id;
  final int week;
  final int dow;
  final String? name;
  final String? notes;
  final List<WorkoutExercise> exercises;

  static const Map<int, String> _dowLabels = {
    1: 'Lunedì',
    2: 'Martedì',
    3: 'Mercoledì',
    4: 'Giovedì',
    5: 'Venerdì',
    6: 'Sabato',
    7: 'Domenica',
  };

  const WorkoutDay({
    required this.week,
    required this.dow,
    required this.exercises,
    this.id,
    this.name,
    this.notes,
  });

  String? get dowLabel => _dowLabels[dow];

  String formattedTitle({String fallback = 'Allenamento'}) {
    final parts = <String>[];
    if (week > 0) {
      parts.add('Settimana $week');
    }
    final dowName = dowLabel;
    if (dowName != null) {
      parts.add(dowName);
    }
    if (name != null && name!.isNotEmpty) {
      parts.add(name!);
    }
    return parts.isEmpty ? fallback : parts.join(' · ');
  }
}

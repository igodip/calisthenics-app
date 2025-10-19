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

  const WorkoutDay({
    required this.week,
    required this.dow,
    required this.exercises,
    this.id,
    this.name,
    this.notes,
  });
}

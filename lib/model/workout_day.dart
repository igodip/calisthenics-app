
import '../l10n/app_localizations.dart';

class WorkoutExercise {
  final String? id;
  final String? name;
  final String? notes;
  final String? traineeNotes;
  final int? position;

  const WorkoutExercise({
    this.name,
    this.id,
    this.notes,
    this.traineeNotes,
    this.position,
  });
}

class WorkoutDay {
  final String? id;
  final int week;
  final String dayCode;
  final String? title;
  final String? notes;
  final bool isCompleted;
  final List<WorkoutExercise> exercises;

  const WorkoutDay({
    required this.week,
    required this.dayCode,
    required this.exercises,
    this.id,
    this.title,
    this.notes,
    this.isCompleted = false,
  });

  String formattedTitle(AppLocalizations l10n, {String? fallback}) {
    final parts = <String>[];
    if (week > 0) {
      parts.add(l10n.weekNumber(week));
    }
    if (dayCode.isNotEmpty) {
      parts.add(dayCode.toUpperCase());
    }
    if (title != null && title!.isNotEmpty) {
      parts.add(title!);
    }
    final resolvedFallback = fallback ?? l10n.defaultWorkoutTitle;
    return parts.isEmpty ? resolvedFallback : parts.join(' · ');
  }
}

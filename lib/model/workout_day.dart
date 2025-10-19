import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkoutExercise {
  final String? id;
  final String? name;
  final int? sets;
  final int? reps;
  final int? restSeconds;
  final String? intensity;
  final String? notes;

  const WorkoutExercise({
    this.name,
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

  String? dowLabel(AppLocalizations l10n) {
    switch (dow) {
      case 1:
        return l10n.weekdayMonday;
      case 2:
        return l10n.weekdayTuesday;
      case 3:
        return l10n.weekdayWednesday;
      case 4:
        return l10n.weekdayThursday;
      case 5:
        return l10n.weekdayFriday;
      case 6:
        return l10n.weekdaySaturday;
      case 7:
        return l10n.weekdaySunday;
      default:
        return null;
    }
  }

  String formattedTitle(AppLocalizations l10n, {String? fallback}) {
    final parts = <String>[];
    if (week > 0) {
      parts.add(l10n.weekNumber(week));
    }
    final dowName = dowLabel(l10n);
    if (dowName != null) {
      parts.add(dowName);
    }
    if (name != null && name!.isNotEmpty) {
      parts.add(name!);
    }
    final resolvedFallback = fallback ?? l10n.defaultWorkoutTitle;
    return parts.isEmpty ? resolvedFallback : parts.join(' · ');
  }
}

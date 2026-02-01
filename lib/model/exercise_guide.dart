import '../l10n/app_localizations.dart';

enum Difficulty { beginner, intermediate, advanced }

extension DifficultyLabel on Difficulty {
  String label(AppLocalizations l10n) {
    switch (this) {
      case Difficulty.beginner:
        return l10n.difficultyBeginner;
      case Difficulty.intermediate:
        return l10n.difficultyIntermediate;
      case Difficulty.advanced:
        return l10n.difficultyAdvanced;
    }
  }
}

class ExerciseGuideTranslation {
  const ExerciseGuideTranslation({
    required this.exerciseId,
    required this.locale,
    required this.name,
    required this.focus,
    required this.tip,
    required this.description,
  });

  final String exerciseId;
  final String locale;
  final String name;
  final String focus;
  final String tip;
  final String description;

  factory ExerciseGuideTranslation.fromMap(Map<String, dynamic> data) {
    return ExerciseGuideTranslation(
      exerciseId: data['exercise_id']?.toString() ?? '',
      locale: data['locale']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      focus: data['focus']?.toString() ?? '',
      tip: data['tip']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
    );
  }
}

class ExerciseGuide {
  const ExerciseGuide({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.difficulty,
    required this.isUnlocked,
    required this.focus,
    required this.tip,
    required this.description,
  });

  final String id;
  final String exerciseId;
  final String name;
  final Difficulty difficulty;
  final bool isUnlocked;
  final String focus;
  final String tip;
  final String description;

  ExerciseGuide copyWith({bool? isUnlocked}) {
    return ExerciseGuide(
      id: id,
      exerciseId: exerciseId,
      name: name,
      difficulty: difficulty,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      focus: focus,
      tip: tip,
      description: description,
    );
  }

  static ExerciseGuide fromDatabase(
    Map<String, dynamic> row, {
    ExerciseGuideTranslation? translation,
    ExerciseGuideTranslation? fallbackTranslation,
  }) {
    final slug = row['slug']?.toString() ?? '';
    final fallbackName = row['name']?.toString() ?? slug;
    final resolvedName = (translation?.name ?? '').isNotEmpty
        ? translation!.name
        : (fallbackTranslation?.name ?? fallbackName);
    String resolveField(String? primary, String? fallback) {
      if (primary != null && primary.isNotEmpty) return primary;
      return fallback ?? '';
    }
    return ExerciseGuide(
      id: slug,
      exerciseId: row['id']?.toString() ?? '',
      name: resolvedName,
      difficulty: _difficultyFromString(row['difficulty'] as String?),
      isUnlocked: row['default_unlocked'] as bool? ?? false,
      focus: resolveField(
        translation?.focus,
        fallbackTranslation?.focus,
      ),
      tip: resolveField(
        translation?.tip,
        fallbackTranslation?.tip,
      ),
      description: resolveField(
        translation?.description,
        fallbackTranslation?.description,
      ),
    );
  }

  static Difficulty _difficultyFromString(String? value) {
    switch (value) {
      case 'intermediate':
        return Difficulty.intermediate;
      case 'advanced':
        return Difficulty.advanced;
      case 'beginner':
      default:
        return Difficulty.beginner;
    }
  }
}

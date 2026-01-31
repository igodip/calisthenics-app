import '../data/exercise_translations.dart';
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

class ExerciseGuide {
  const ExerciseGuide({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.isUnlocked,
    required this.focus,
    required this.tip,
    required this.description,
  });

  final String id;
  final String name;
  final Difficulty difficulty;
  final bool isUnlocked;
  final String focus;
  final String tip;
  final String description;

  ExerciseGuide copyWith({bool? isUnlocked}) {
    return ExerciseGuide(
      id: id,
      name: name,
      difficulty: difficulty,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      focus: focus,
      tip: tip,
      description: description,
    );
  }

  static ExerciseGuide fromDatabase(
    Map<String, dynamic> row,
    String localeName,
  ) {
    final slug = row['slug'] as String;
    final strings = ExerciseGuideTranslations.forSlug(slug, localeName);
    return ExerciseGuide(
      id: slug,
      name: strings.name,
      difficulty: _difficultyFromString(row['difficulty'] as String?),
      isUnlocked: row['default_unlocked'] as bool? ?? false,
      focus: strings.focus,
      tip: strings.tip,
      description: strings.description,
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

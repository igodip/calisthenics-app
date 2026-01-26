import 'package:flutter/material.dart';
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
    required this.accent,
  });

  final String id;
  final String name;
  final Difficulty difficulty;
  final bool isUnlocked;
  final String focus;
  final String tip;
  final String description;
  final Color accent;

  ExerciseGuide copyWith({bool? isUnlocked}) {
    return ExerciseGuide(
      id: id,
      name: name,
      difficulty: difficulty,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      focus: focus,
      tip: tip,
      description: description,
      accent: accent,
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
      accent: _accentFromHex(row['accent'] as String?),
    );
  }

  static List<ExerciseGuide> buildGuides(AppLocalizations l10n) {
    const guideSeeds = [
      ('pullup', 'intermediate', false, '#2196F3'),
      ('chinup', 'intermediate', false, '#03A9F4'),
      ('pushup', 'beginner', true, '#FF9800'),
      ('bodyweight-squat', 'beginner', true, '#4CAF50'),
      ('glute-bridge', 'beginner', true, '#8BC34A'),
      ('hanging-leg-raise', 'intermediate', false, '#9C27B0'),
      ('muscle-up', 'advanced', false, '#009688'),
      ('straight-bar-dip', 'intermediate', false, '#FF5722'),
      ('dips', 'intermediate', false, '#F44336'),
      ('australian-row', 'beginner', true, '#3F51B5'),
      ('pike-pushup', 'intermediate', false, '#FFC107'),
      ('hollow-hold', 'beginner', true, '#795548'),
      ('plank', 'beginner', true, '#607D8B'),
      ('l-sit', 'intermediate', false, '#03A9F4'),
      ('handstand', 'advanced', false, '#673AB7'),
    ];

    return guideSeeds.map((seed) {
      final strings = ExerciseGuideStrings.fromSlug(seed.$1, l10n);
      return ExerciseGuide(
        id: seed.$1,
        name: strings.name,
        difficulty: _difficultyFromString(seed.$2),
        isUnlocked: seed.$3,
        focus: strings.focus,
        tip: strings.tip,
        description: strings.description,
        accent: _accentFromHex(seed.$4),
      );
    }).toList();
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

  static Color _accentFromHex(String? value) {
    if (value == null || value.isEmpty) {
      return Colors.blueGrey;
    }
    final normalized = value.replaceAll('#', '').replaceAll('0x', '');
    final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
    final colorValue = int.tryParse(hex, radix: 16);
    if (colorValue == null) {
      return Colors.blueGrey;
    }
    return Color(colorValue);
  }
}

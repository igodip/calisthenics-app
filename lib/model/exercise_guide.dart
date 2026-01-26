import 'package:flutter/material.dart';
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
    AppLocalizations l10n,
  ) {
    final slug = row['slug'] as String;
    final strings = ExerciseGuideStrings.fromSlug(slug, l10n);
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

class ExerciseGuideStrings {
  const ExerciseGuideStrings({
    required this.name,
    required this.focus,
    required this.tip,
    required this.description,
  });

  final String name;
  final String focus;
  final String tip;
  final String description;

  static ExerciseGuideStrings fromSlug(
    String slug,
    AppLocalizations l10n,
  ) {
    switch (slug) {
      case 'pullup':
        return ExerciseGuideStrings(
          name: l10n.guidesPullupName,
          focus: l10n.guidesPullupFocus,
          tip: l10n.guidesPullupTip,
          description: l10n.guidesPullupDescription,
        );
      case 'chinup':
        return ExerciseGuideStrings(
          name: l10n.guidesChinUpName,
          focus: l10n.guidesChinUpFocus,
          tip: l10n.guidesChinUpTip,
          description: l10n.guidesChinUpDescription,
        );
      case 'pushup':
        return ExerciseGuideStrings(
          name: l10n.guidesPushupName,
          focus: l10n.guidesPushupFocus,
          tip: l10n.guidesPushupTip,
          description: l10n.guidesPushupDescription,
        );
      case 'bodyweight-squat':
        return ExerciseGuideStrings(
          name: l10n.guidesBodyweightSquatName,
          focus: l10n.guidesBodyweightSquatFocus,
          tip: l10n.guidesBodyweightSquatTip,
          description: l10n.guidesBodyweightSquatDescription,
        );
      case 'glute-bridge':
        return ExerciseGuideStrings(
          name: l10n.guidesGluteBridgeName,
          focus: l10n.guidesGluteBridgeFocus,
          tip: l10n.guidesGluteBridgeTip,
          description: l10n.guidesGluteBridgeDescription,
        );
      case 'hanging-leg-raise':
        return ExerciseGuideStrings(
          name: l10n.guidesHangingLegRaiseName,
          focus: l10n.guidesHangingLegRaiseFocus,
          tip: l10n.guidesHangingLegRaiseTip,
          description: l10n.guidesHangingLegRaiseDescription,
        );
      case 'muscle-up':
        return ExerciseGuideStrings(
          name: l10n.guidesMuscleUpName,
          focus: l10n.guidesMuscleUpFocus,
          tip: l10n.guidesMuscleUpTip,
          description: l10n.guidesMuscleUpDescription,
        );
      case 'straight-bar-dip':
        return ExerciseGuideStrings(
          name: l10n.guidesStraightBarDipName,
          focus: l10n.guidesStraightBarDipFocus,
          tip: l10n.guidesStraightBarDipTip,
          description: l10n.guidesStraightBarDipDescription,
        );
      case 'dips':
        return ExerciseGuideStrings(
          name: l10n.guidesDipsName,
          focus: l10n.guidesDipsFocus,
          tip: l10n.guidesDipsTip,
          description: l10n.guidesDipsDescription,
        );
      case 'australian-row':
        return ExerciseGuideStrings(
          name: l10n.guidesAustralianRowName,
          focus: l10n.guidesAustralianRowFocus,
          tip: l10n.guidesAustralianRowTip,
          description: l10n.guidesAustralianRowDescription,
        );
      case 'pike-pushup':
        return ExerciseGuideStrings(
          name: l10n.guidesPikePushUpName,
          focus: l10n.guidesPikePushUpFocus,
          tip: l10n.guidesPikePushUpTip,
          description: l10n.guidesPikePushUpDescription,
        );
      case 'hollow-hold':
        return ExerciseGuideStrings(
          name: l10n.guidesHollowHoldName,
          focus: l10n.guidesHollowHoldFocus,
          tip: l10n.guidesHollowHoldTip,
          description: l10n.guidesHollowHoldDescription,
        );
      case 'plank':
        return ExerciseGuideStrings(
          name: l10n.guidesPlankName,
          focus: l10n.guidesPlankFocus,
          tip: l10n.guidesPlankTip,
          description: l10n.guidesPlankDescription,
        );
      case 'l-sit':
        return ExerciseGuideStrings(
          name: l10n.guidesLSitName,
          focus: l10n.guidesLSitFocus,
          tip: l10n.guidesLSitTip,
          description: l10n.guidesLSitDescription,
        );
      case 'handstand':
        return ExerciseGuideStrings(
          name: l10n.guidesHandstandName,
          focus: l10n.guidesHandstandFocus,
          tip: l10n.guidesHandstandTip,
          description: l10n.guidesHandstandDescription,
        );
      default:
        return ExerciseGuideStrings(
          name: slug,
          focus: '',
          tip: '',
          description: '',
        );
    }
  }
}

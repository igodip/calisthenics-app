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

  static List<ExerciseGuide> buildGuides(AppLocalizations l10n) => [
        ExerciseGuide(
          id: 'pullup',
          name: l10n.guidesPullupName,
          difficulty: Difficulty.intermediate,
          isUnlocked: false,
          focus: l10n.guidesPullupFocus,
          tip: l10n.guidesPullupTip,
          description: l10n.guidesPullupDescription,
          accent: Colors.blue,
        ),
        ExerciseGuide(
          id: 'chinup',
          name: l10n.guidesChinUpName,
          difficulty: Difficulty.intermediate,
          isUnlocked: false,
          focus: l10n.guidesChinUpFocus,
          tip: l10n.guidesChinUpTip,
          description: l10n.guidesChinUpDescription,
          accent: Colors.lightBlue,
        ),
        ExerciseGuide(
          id: 'pushup',
          name: l10n.guidesPushupName,
          difficulty: Difficulty.beginner,
          isUnlocked: true,
          focus: l10n.guidesPushupFocus,
          tip: l10n.guidesPushupTip,
          description: l10n.guidesPushupDescription,
          accent: Colors.orange,
        ),
        ExerciseGuide(
          id: 'bodyweight-squat',
          name: l10n.guidesBodyweightSquatName,
          difficulty: Difficulty.beginner,
          isUnlocked: true,
          focus: l10n.guidesBodyweightSquatFocus,
          tip: l10n.guidesBodyweightSquatTip,
          description: l10n.guidesBodyweightSquatDescription,
          accent: Colors.green,
        ),
        ExerciseGuide(
          id: 'glute-bridge',
          name: l10n.guidesGluteBridgeName,
          difficulty: Difficulty.beginner,
          isUnlocked: true,
          focus: l10n.guidesGluteBridgeFocus,
          tip: l10n.guidesGluteBridgeTip,
          description: l10n.guidesGluteBridgeDescription,
          accent: Colors.lightGreen,
        ),
        ExerciseGuide(
          id: 'hanging-leg-raise',
          name: l10n.guidesHangingLegRaiseName,
          difficulty: Difficulty.intermediate,
          isUnlocked: false,
          focus: l10n.guidesHangingLegRaiseFocus,
          tip: l10n.guidesHangingLegRaiseTip,
          description: l10n.guidesHangingLegRaiseDescription,
          accent: Colors.purple,
        ),
        ExerciseGuide(
          id: 'muscle-up',
          name: l10n.guidesMuscleUpName,
          difficulty: Difficulty.advanced,
          isUnlocked: false,
          focus: l10n.guidesMuscleUpFocus,
          tip: l10n.guidesMuscleUpTip,
          description: l10n.guidesMuscleUpDescription,
          accent: Colors.teal,
        ),
        ExerciseGuide(
          id: 'straight-bar-dip',
          name: l10n.guidesStraightBarDipName,
          difficulty: Difficulty.intermediate,
          isUnlocked: false,
          focus: l10n.guidesStraightBarDipFocus,
          tip: l10n.guidesStraightBarDipTip,
          description: l10n.guidesStraightBarDipDescription,
          accent: Colors.deepOrange,
        ),
        ExerciseGuide(
          id: 'dips',
          name: l10n.guidesDipsName,
          difficulty: Difficulty.intermediate,
          isUnlocked: false,
          focus: l10n.guidesDipsFocus,
          tip: l10n.guidesDipsTip,
          description: l10n.guidesDipsDescription,
          accent: Colors.red,
        ),
        ExerciseGuide(
          id: 'australian-row',
          name: l10n.guidesAustralianRowName,
          difficulty: Difficulty.beginner,
          isUnlocked: true,
          focus: l10n.guidesAustralianRowFocus,
          tip: l10n.guidesAustralianRowTip,
          description: l10n.guidesAustralianRowDescription,
          accent: Colors.indigo,
        ),
        ExerciseGuide(
          id: 'pike-pushup',
          name: l10n.guidesPikePushUpName,
          difficulty: Difficulty.intermediate,
          isUnlocked: false,
          focus: l10n.guidesPikePushUpFocus,
          tip: l10n.guidesPikePushUpTip,
          description: l10n.guidesPikePushUpDescription,
          accent: Colors.amber,
        ),
        ExerciseGuide(
          id: 'hollow-hold',
          name: l10n.guidesHollowHoldName,
          difficulty: Difficulty.beginner,
          isUnlocked: true,
          focus: l10n.guidesHollowHoldFocus,
          tip: l10n.guidesHollowHoldTip,
          description: l10n.guidesHollowHoldDescription,
          accent: Colors.brown,
        ),
        ExerciseGuide(
          id: 'plank',
          name: l10n.guidesPlankName,
          difficulty: Difficulty.beginner,
          isUnlocked: true,
          focus: l10n.guidesPlankFocus,
          tip: l10n.guidesPlankTip,
          description: l10n.guidesPlankDescription,
          accent: Colors.blueGrey,
        ),
        ExerciseGuide(
          id: 'l-sit',
          name: l10n.guidesLSitName,
          difficulty: Difficulty.intermediate,
          isUnlocked: false,
          focus: l10n.guidesLSitFocus,
          tip: l10n.guidesLSitTip,
          description: l10n.guidesLSitDescription,
          accent: Colors.lightBlue,
        ),
        ExerciseGuide(
          id: 'handstand',
          name: l10n.guidesHandstandName,
          difficulty: Difficulty.advanced,
          isUnlocked: false,
          focus: l10n.guidesHandstandFocus,
          tip: l10n.guidesHandstandTip,
          description: l10n.guidesHandstandDescription,
          accent: Colors.deepPurple,
        ),
      ];
}

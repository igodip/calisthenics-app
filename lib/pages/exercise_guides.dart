import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ExerciseGuidesPage extends StatefulWidget {
  const ExerciseGuidesPage({super.key});

  @override
  State<ExerciseGuidesPage> createState() => _ExerciseGuidesPageState();
}

class _ExerciseGuidesPageState extends State<ExerciseGuidesPage> {
  _Difficulty _selectedDifficulty = _Difficulty.beginner;
  final Set<String> _unlockedSkills = {};

  static List<_ExerciseGuide> _buildGuides(AppLocalizations l10n) => [
    _ExerciseGuide(
      id: 'pullup',
      name: l10n.guidesPullupName,
      difficulty: _Difficulty.intermediate,
      isUnlocked: false,
      focus: l10n.guidesPullupFocus,
      tip: l10n.guidesPullupTip,
      description: l10n.guidesPullupDescription,
      accent: Colors.blue,
    ),
    _ExerciseGuide(
      id: 'chinup',
      name: l10n.guidesChinUpName,
      difficulty: _Difficulty.intermediate,
      isUnlocked: false,
      focus: l10n.guidesChinUpFocus,
      tip: l10n.guidesChinUpTip,
      description: l10n.guidesChinUpDescription,
      accent: Colors.lightBlue,
    ),
    _ExerciseGuide(
      id: 'pushup',
      name: l10n.guidesPushupName,
      difficulty: _Difficulty.beginner,
      isUnlocked: true,
      focus: l10n.guidesPushupFocus,
      tip: l10n.guidesPushupTip,
      description: l10n.guidesPushupDescription,
      accent: Colors.orange,
    ),
    _ExerciseGuide(
      id: 'bodyweight-squat',
      name: l10n.guidesBodyweightSquatName,
      difficulty: _Difficulty.beginner,
      isUnlocked: true,
      focus: l10n.guidesBodyweightSquatFocus,
      tip: l10n.guidesBodyweightSquatTip,
      description: l10n.guidesBodyweightSquatDescription,
      accent: Colors.green,
    ),
    _ExerciseGuide(
      id: 'glute-bridge',
      name: l10n.guidesGluteBridgeName,
      difficulty: _Difficulty.beginner,
      isUnlocked: true,
      focus: l10n.guidesGluteBridgeFocus,
      tip: l10n.guidesGluteBridgeTip,
      description: l10n.guidesGluteBridgeDescription,
      accent: Colors.lightGreen,
    ),
    _ExerciseGuide(
      id: 'hanging-leg-raise',
      name: l10n.guidesHangingLegRaiseName,
      difficulty: _Difficulty.intermediate,
      isUnlocked: false,
      focus: l10n.guidesHangingLegRaiseFocus,
      tip: l10n.guidesHangingLegRaiseTip,
      description: l10n.guidesHangingLegRaiseDescription,
      accent: Colors.purple,
    ),
    _ExerciseGuide(
      id: 'muscle-up',
      name: l10n.guidesMuscleUpName,
      difficulty: _Difficulty.advanced,
      isUnlocked: false,
      focus: l10n.guidesMuscleUpFocus,
      tip: l10n.guidesMuscleUpTip,
      description: l10n.guidesMuscleUpDescription,
      accent: Colors.teal,
    ),
    _ExerciseGuide(
      id: 'straight-bar-dip',
      name: l10n.guidesStraightBarDipName,
      difficulty: _Difficulty.intermediate,
      isUnlocked: false,
      focus: l10n.guidesStraightBarDipFocus,
      tip: l10n.guidesStraightBarDipTip,
      description: l10n.guidesStraightBarDipDescription,
      accent: Colors.deepOrange,
    ),
    _ExerciseGuide(
      id: 'dips',
      name: l10n.guidesDipsName,
      difficulty: _Difficulty.intermediate,
      isUnlocked: false,
      focus: l10n.guidesDipsFocus,
      tip: l10n.guidesDipsTip,
      description: l10n.guidesDipsDescription,
      accent: Colors.red,
    ),
    _ExerciseGuide(
      id: 'australian-row',
      name: l10n.guidesAustralianRowName,
      difficulty: _Difficulty.beginner,
      isUnlocked: true,
      focus: l10n.guidesAustralianRowFocus,
      tip: l10n.guidesAustralianRowTip,
      description: l10n.guidesAustralianRowDescription,
      accent: Colors.indigo,
    ),
    _ExerciseGuide(
      id: 'pike-pushup',
      name: l10n.guidesPikePushUpName,
      difficulty: _Difficulty.intermediate,
      isUnlocked: false,
      focus: l10n.guidesPikePushUpFocus,
      tip: l10n.guidesPikePushUpTip,
      description: l10n.guidesPikePushUpDescription,
      accent: Colors.amber,
    ),
    _ExerciseGuide(
      id: 'hollow-hold',
      name: l10n.guidesHollowHoldName,
      difficulty: _Difficulty.beginner,
      isUnlocked: true,
      focus: l10n.guidesHollowHoldFocus,
      tip: l10n.guidesHollowHoldTip,
      description: l10n.guidesHollowHoldDescription,
      accent: Colors.brown,
    ),
    _ExerciseGuide(
      id: 'plank',
      name: l10n.guidesPlankName,
      difficulty: _Difficulty.beginner,
      isUnlocked: true,
      focus: l10n.guidesPlankFocus,
      tip: l10n.guidesPlankTip,
      description: l10n.guidesPlankDescription,
      accent: Colors.blueGrey,
    ),
    _ExerciseGuide(
      id: 'l-sit',
      name: l10n.guidesLSitName,
      difficulty: _Difficulty.intermediate,
      isUnlocked: false,
      focus: l10n.guidesLSitFocus,
      tip: l10n.guidesLSitTip,
      description: l10n.guidesLSitDescription,
      accent: Colors.lightBlue,
    ),
    _ExerciseGuide(
      id: 'handstand',
      name: l10n.guidesHandstandName,
      difficulty: _Difficulty.advanced,
      isUnlocked: false,
      focus: l10n.guidesHandstandFocus,
      tip: l10n.guidesHandstandTip,
      description: l10n.guidesHandstandDescription,
      accent: Colors.deepPurple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final guides = _buildGuides(l10n)
        .map(
          (guide) => guide.copyWith(
            isUnlocked:
                guide.isUnlocked || _unlockedSkills.contains(guide.id),
          ),
        )
        .toList();
    final filteredGuides = guides
        .where((guide) => guide.difficulty == _selectedDifficulty)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _PageHeader(
          title: l10n.guidesTitle,
          description: l10n.guidesSubtitle,
        ),
        const SizedBox(height: 16),
        _DifficultySelector(
          selected: _selectedDifficulty,
          l10n: l10n,
          onChanged: (difficulty) {
            setState(() {
              _selectedDifficulty = difficulty;
            });
          },
        ),
        const SizedBox(height: 16),
        for (final guide in filteredGuides)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ExerciseGuideCard(
              guide: guide,
              l10n: l10n,
              onUnlock: guide.isUnlocked
                  ? null
                  : () {
                      setState(() {
                        _unlockedSkills.add(guide.id);
                      });
                    },
            ),
          ),
      ],
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.75),
            colorScheme.secondaryContainer.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseGuideCard extends StatelessWidget {
  const _ExerciseGuideCard({
    required this.guide,
    required this.l10n,
    this.onUnlock,
  });

  final _ExerciseGuide guide;
  final AppLocalizations l10n;
  final VoidCallback? onUnlock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUnlocked = guide.isUnlocked;
    final accent = isUnlocked ? guide.accent : colorScheme.outline;
    final statusBackground = isUnlocked
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final statusForeground =
        isUnlocked ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant;

    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      color: isUnlocked
          ? colorScheme.surface
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    guide.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isUnlocked
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUnlocked ? Icons.lock_open : Icons.lock,
                            size: 14,
                            color: statusForeground,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isUnlocked
                                ? l10n.skillsUnlockedLabel
                                : l10n.skillsLockedLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: statusForeground,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        guide.difficulty.label(l10n),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              guide.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isUnlocked
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            if (isUnlocked) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.center_focus_strong, color: accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.guidesPrimaryFocus,
                          style: theme.textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          guide.focus,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.tips_and_updates, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.guidesCoachTip,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            guide.tip,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.skillsLockedHint,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: onUnlock,
                        icon: const Icon(Icons.lock_open),
                        label: Text(l10n.skillsUnlockAction),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseGuide {
  const _ExerciseGuide({
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
  final _Difficulty difficulty;
  final bool isUnlocked;
  final String focus;
  final String tip;
  final String description;
  final Color accent;

  _ExerciseGuide copyWith({bool? isUnlocked}) {
    return _ExerciseGuide(
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
}

enum _Difficulty { beginner, intermediate, advanced }

extension _DifficultyLabel on _Difficulty {
  String label(AppLocalizations l10n) {
    switch (this) {
      case _Difficulty.beginner:
        return l10n.difficultyBeginner;
      case _Difficulty.intermediate:
        return l10n.difficultyIntermediate;
      case _Difficulty.advanced:
        return l10n.difficultyAdvanced;
    }
  }
}

class _DifficultySelector extends StatelessWidget {
  const _DifficultySelector({
    required this.selected,
    required this.l10n,
    required this.onChanged,
  });

  final _Difficulty selected;
  final AppLocalizations l10n;
  final ValueChanged<_Difficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: _Difficulty.values.map((difficulty) {
        return ChoiceChip(
          label: Text(difficulty.label(l10n)),
          selected: selected == difficulty,
          selectedColor: theme.colorScheme.primaryContainer,
          onSelected: (_) => onChanged(difficulty),
        );
      }).toList(),
    );
  }
}

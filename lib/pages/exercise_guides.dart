import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ExerciseGuidesPage extends StatelessWidget {
  const ExerciseGuidesPage({super.key});

  static List<_ExerciseGuide> _buildGuides(AppLocalizations l10n) => [
    _ExerciseGuide(
      name: l10n.guidesPullupName,
      difficulty: l10n.difficultyIntermediate,
      focus: l10n.guidesPullupFocus,
      tip: l10n.guidesPullupTip,
      description: l10n.guidesPullupDescription,
      accent: Colors.blue,
    ),
    _ExerciseGuide(
      name: l10n.guidesPushupName,
      difficulty: l10n.difficultyBeginner,
      focus: l10n.guidesPushupFocus,
      tip: l10n.guidesPushupTip,
      description: l10n.guidesPushupDescription,
      accent: Colors.orange,
    ),
    _ExerciseGuide(
      name: l10n.guidesBodyweightSquatName,
      difficulty: l10n.difficultyBeginner,
      focus: l10n.guidesBodyweightSquatFocus,
      tip: l10n.guidesBodyweightSquatTip,
      description: l10n.guidesBodyweightSquatDescription,
      accent: Colors.green,
    ),
    _ExerciseGuide(
      name: l10n.guidesHangingLegRaiseName,
      difficulty: l10n.difficultyIntermediate,
      focus: l10n.guidesHangingLegRaiseFocus,
      tip: l10n.guidesHangingLegRaiseTip,
      description: l10n.guidesHangingLegRaiseDescription,
      accent: Colors.purple,
    ),
    _ExerciseGuide(
      name: l10n.guidesMuscleUpName,
      difficulty: l10n.difficultyAdvanced,
      focus: l10n.guidesMuscleUpFocus,
      tip: l10n.guidesMuscleUpTip,
      description: l10n.guidesMuscleUpDescription,
      accent: Colors.teal,
    ),
    _ExerciseGuide(
      name: l10n.guidesStraightBarDipName,
      difficulty: l10n.difficultyIntermediate,
      focus: l10n.guidesStraightBarDipFocus,
      tip: l10n.guidesStraightBarDipTip,
      description: l10n.guidesStraightBarDipDescription,
      accent: Colors.deepOrange,
    ),
    _ExerciseGuide(
      name: l10n.guidesDipsName,
      difficulty: l10n.difficultyIntermediate,
      focus: l10n.guidesDipsFocus,
      tip: l10n.guidesDipsTip,
      description: l10n.guidesDipsDescription,
      accent: Colors.red,
    ),
    _ExerciseGuide(
      name: l10n.guidesAustralianRowName,
      difficulty: l10n.difficultyBeginner,
      focus: l10n.guidesAustralianRowFocus,
      tip: l10n.guidesAustralianRowTip,
      description: l10n.guidesAustralianRowDescription,
      accent: Colors.indigo,
    ),
    _ExerciseGuide(
      name: l10n.guidesPikePushUpName,
      difficulty: l10n.difficultyIntermediate,
      focus: l10n.guidesPikePushUpFocus,
      tip: l10n.guidesPikePushUpTip,
      description: l10n.guidesPikePushUpDescription,
      accent: Colors.amber,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _PageHeader(
          title: l10n.guidesTitle,
          description: l10n.guidesSubtitle,
        ),
        const SizedBox(height: 12),
        for (final guide in _buildGuides(l10n))
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ExerciseGuideCard(guide: guide, l10n: l10n),
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
  const _ExerciseGuideCard({required this.guide, required this.l10n});

  final _ExerciseGuide guide;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
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
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: guide.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    guide.difficulty,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: guide.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              guide.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.center_focus_strong, color: guide.accent),
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
          ],
        ),
      ),
    );
  }
}

class _ExerciseGuide {
  const _ExerciseGuide({
    required this.name,
    required this.difficulty,
    required this.focus,
    required this.tip,
    required this.description,
    required this.accent,
  });

  final String name;
  final String difficulty;
  final String focus;
  final String tip;
  final String description;
  final Color accent;
}

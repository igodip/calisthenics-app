import 'package:calisync/components/section_card.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class StrengthLevelCard extends StatelessWidget {
  const StrengthLevelCard({
    super.key,
    required this.unlockedSkills,
    required this.totalSkills,
  });

  final int unlockedSkills;
  final int totalSkills;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final progress = totalSkills == 0 ? 0.0 : unlockedSkills / totalSkills;
    final strengthLevel = progress >= 0.66
        ? _StrengthLevel.advanced
        : progress >= 0.33
            ? _StrengthLevel.intermediate
            : _StrengthLevel.beginner;
    final strengthLabel = switch (strengthLevel) {
      _StrengthLevel.beginner => l10n.difficultyBeginner,
      _StrengthLevel.intermediate => l10n.difficultyIntermediate,
      _StrengthLevel.advanced => l10n.difficultyAdvanced,
    };
    final strengthIcon = switch (strengthLevel) {
      _StrengthLevel.beginner => Icons.flag,
      _StrengthLevel.intermediate => Icons.trending_up,
      _StrengthLevel.advanced => Icons.arrow_circle_up,
    };
    return SectionCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeStrengthLevelTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      strengthIcon,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      strengthLabel,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.sports_gymnastics,
              color: theme.colorScheme.primary,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}

enum _StrengthLevel {
  beginner,
  intermediate,
  advanced,
}

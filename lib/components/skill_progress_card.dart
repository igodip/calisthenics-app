import 'package:calisync/components/section_card.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class SkillProgressCard extends StatelessWidget {
  const SkillProgressCard({
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
    final displayTotal = totalSkills < 0 ? 0 : totalSkills;
    final displayUnlocked = unlockedSkills < 0 ? 0 : unlockedSkills;
    final iconCount = displayTotal == 0 ? 0 : (displayTotal <= 8 ? displayTotal : 8);
    final filledIcons = iconCount == 0
        ? 0
        : ((displayUnlocked / displayTotal) * iconCount)
            .round()
            .clamp(0, iconCount);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeSkillProgressTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                l10n.homeSkillProgressValue(displayUnlocked, displayTotal),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.homeSkillProgressLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: List.generate(
              iconCount,
              (index) => Icon(
                Icons.fitness_center,
                size: 20,
                color: index < filledIcons
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

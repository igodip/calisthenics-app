import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class TerminologyPage extends StatelessWidget {
  const TerminologyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final termini = [
      {'termine': l10n.termRepsTitle, 'descrizione': l10n.termRepsDescription},
      {'termine': l10n.termSetTitle, 'descrizione': l10n.termSetDescription},
      {'termine': l10n.termRtTitle, 'descrizione': l10n.termRtDescription},
      {'termine': l10n.termAmrapTitle, 'descrizione': l10n.termAmrapDescription},
      {'termine': l10n.termEmomTitle, 'descrizione': l10n.termEmomDescription},
      {'termine': l10n.termRampingTitle, 'descrizione': l10n.termRampingDescription},
      {'termine': l10n.termMavTitle, 'descrizione': l10n.termMavDescription},
      {'termine': l10n.termIsocineticiTitle, 'descrizione': l10n.termIsocineticiDescription},
      {'termine': l10n.termTutTitle, 'descrizione': l10n.termTutDescription},
      {'termine': l10n.termIsoTitle, 'descrizione': l10n.termIsoDescription},
      {'termine': l10n.termSomTitle, 'descrizione': l10n.termSomDescription},
      {'termine': l10n.termScaricoTitle, 'descrizione': l10n.termScaricoDescription},
    ];
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.terminologyTitle,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList.separated(
            itemCount: termini.length,
            itemBuilder: (context, index) {
              final termine = termini[index];
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(
                              Icons.fitness_center,
                              size: 18,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              termine['termine']!,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        termine['descrizione']!,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),
        ),
      ],
    );
  }
}

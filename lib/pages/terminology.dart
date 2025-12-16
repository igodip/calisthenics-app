import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class TerminologiaPage extends StatelessWidget {
  const TerminologiaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: termini.length,
      itemBuilder: (context, index) {
        final termine = termini[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  termine['termine']!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  termine['descrizione']!,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

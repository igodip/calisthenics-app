import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TerminologiaPage extends StatelessWidget {
  const TerminologiaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final termini = [
      {
        'termine': l10n.terminologyRepsTerm,
        'descrizione': l10n.terminologyRepsDescription,
      },
      {
        'termine': l10n.terminologySetTerm,
        'descrizione': l10n.terminologySetDescription,
      },
      {
        'termine': l10n.terminologyRtTerm,
        'descrizione': l10n.terminologyRtDescription,
      },
      {
        'termine': l10n.terminologyAmrapTerm,
        'descrizione': l10n.terminologyAmrapDescription,
      },
      {
        'termine': l10n.terminologyEmomTerm,
        'descrizione': l10n.terminologyEmomDescription,
      },
      {
        'termine': l10n.terminologyRampingTerm,
        'descrizione': l10n.terminologyRampingDescription,
      },
      {
        'termine': l10n.terminologyMavTerm,
        'descrizione': l10n.terminologyMavDescription,
      },
      {
        'termine': l10n.terminologyIsocineticiTerm,
        'descrizione': l10n.terminologyIsocineticiDescription,
      },
      {
        'termine': l10n.terminologyTutTerm,
        'descrizione': l10n.terminologyTutDescription,
      },
      {
        'termine': l10n.terminologyIsoTerm,
        'descrizione': l10n.terminologyIsoDescription,
      },
      {
        'termine': l10n.terminologySomTerm,
        'descrizione': l10n.terminologySomDescription,
      },
      {
        'termine': l10n.terminologyScaricoTerm,
        'descrizione': l10n.terminologyScaricoDescription,
      },
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.terminologyTitle)),
      body: ListView.builder(
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
      ),
    );
  }
}

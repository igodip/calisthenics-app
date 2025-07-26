import 'package:flutter/material.dart';

class TerminologiaPage extends StatelessWidget {
  const TerminologiaPage({super.key});

  final List<Map<String, String>> termini = const [
    {
      'termine': 'Reps (Ripetizioni)',
      'descrizione': 'Numero di volte che esegui un esercizio consecutivamente.'
    },
    {
      'termine': 'Set (Serie)',
      'descrizione': 'Un gruppo di ripetizioni. Es: 3 serie da 10 reps significa 30 ripetizioni totali, divise in 3 gruppi.'
    },
    {
      'termine': 'RT',
      'descrizione': 'Ripetizioni Totali: indica che devi fare tutte quelle reps, con libera scelta di serie, ripetizioni e tempo (se non indicato).'
    },
    {
      'termine': 'AMRAP',
      'descrizione': 'As Many Reps As Possible: esegui quante più ripetizioni possibili in un tempo determinato.'
    },
    {
      'termine': 'EMOM',
      'descrizione': 'Every Minute On Minute: inizi un set ogni minuto. Il tempo restante serve per riposare.'
    },
    {
      'termine': 'Ramping',
      'descrizione': 'Metodo che prevede un incremento del peso ad ogni serie'
    },
    {
      'termine': 'MAV',
      'descrizione': 'Massima Alzata Veloce: Si riferisce a una metodologia in cui si cerca di eseguire il maggior numero di ripetizioni possibili con un carico, mantenendo sempre il controllo del movimento e una buona velocità di esecuzione.'
    },
    {
      'termine': 'Isocinetici',
      'descrizione': 'Esercizi svolti a velocità costante.'
    },
    {
      'termine': 'TUT',
      'descrizione': 'Indica quanto deve durare una ripetizione. Puoi gestire tu la durata di ogni fase della rep.'
    },
    {
      'termine': 'ISO',
      'descrizione': "Indica il fermo a un punto specifico dell'esecizione della rep"
    },
    {
      'termine': 'SOM',
      'descrizione': 'Indica la durata di ogni fase della ripetizione.'
    },
    {
      'termine': 'Scarico',
      'descrizione': 'Ultima settimana della scheda per prepararsi ai massimali.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terminologia')),
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

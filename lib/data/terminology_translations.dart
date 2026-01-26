class TerminologyTranslation {
  const TerminologyTranslation({
    required this.termKey,
    required this.title,
    required this.description,
    required this.sortOrder,
  });

  final String termKey;
  final String title;
  final String description;
  final int sortOrder;
}

class TerminologyTranslations {
  static const Map<String, List<TerminologyTranslation>> _translations = {
    'en': [
      TerminologyTranslation(
        termKey: 'reps',
        title: 'Reps',
        description: 'Number of times you perform an exercise consecutively.',
        sortOrder: 1,
      ),
      TerminologyTranslation(
        termKey: 'set',
        title: 'Set',
        description:
            'A group of repetitions. For example: 3 sets of 10 reps means 30 repetitions total divided into 3 groups.',
        sortOrder: 2,
      ),
      TerminologyTranslation(
        termKey: 'rt',
        title: 'RT',
        description:
            'Total Repetitions: perform all the reps with your preferred sets, reps, and tempo (if not specified).',
        sortOrder: 3,
      ),
      TerminologyTranslation(
        termKey: 'amrap',
        title: 'AMRAP',
        description:
            'As Many Reps As Possible: perform as many reps as you can in a given time.',
        sortOrder: 4,
      ),
      TerminologyTranslation(
        termKey: 'emom',
        title: 'EMOM',
        description:
            'Every Minute on the Minute: start a set every minute. Rest during the remaining time.',
        sortOrder: 5,
      ),
      TerminologyTranslation(
        termKey: 'ramping',
        title: 'Ramping',
        description: 'Method where the load increases with each set.',
        sortOrder: 6,
      ),
      TerminologyTranslation(
        termKey: 'mav',
        title: 'MAV',
        description:
            'Massima Alzata Veloce: perform as many reps as possible with a load while keeping control and good speed.',
        sortOrder: 7,
      ),
      TerminologyTranslation(
        termKey: 'isokinetic',
        title: 'Isokinetic',
        description: 'Exercises performed at a constant speed.',
        sortOrder: 8,
      ),
      TerminologyTranslation(
        termKey: 'tut',
        title: 'TUT',
        description:
            'Indicates how long a repetition should last. You can manage the duration of each phase.',
        sortOrder: 9,
      ),
      TerminologyTranslation(
        termKey: 'iso',
        title: 'ISO',
        description:
            'Indicates a pause at a specific point of the repetition.',
        sortOrder: 10,
      ),
      TerminologyTranslation(
        termKey: 'som',
        title: 'SOM',
        description: 'Indicates the duration of each phase of the repetition.',
        sortOrder: 11,
      ),
      TerminologyTranslation(
        termKey: 'deload',
        title: 'Deload',
        description: 'Last week of the program to prepare for max attempts.',
        sortOrder: 12,
      ),
    ],
    'it': [
      TerminologyTranslation(
        termKey: 'reps',
        title: 'Reps (Ripetizioni)',
        description: 'Numero di volte che esegui un esercizio consecutivamente.',
        sortOrder: 1,
      ),
      TerminologyTranslation(
        termKey: 'set',
        title: 'Set (Serie)',
        description:
            'Un gruppo di ripetizioni. Es: 3 serie da 10 reps significa 30 ripetizioni totali, divise in 3 gruppi.',
        sortOrder: 2,
      ),
      TerminologyTranslation(
        termKey: 'rt',
        title: 'RT',
        description:
            'Ripetizioni Totali: indica che devi fare tutte quelle reps, con libera scelta di serie, ripetizioni e tempo (se non indicato).',
        sortOrder: 3,
      ),
      TerminologyTranslation(
        termKey: 'amrap',
        title: 'AMRAP',
        description:
            'As Many Reps As Possible: esegui quante più ripetizioni possibili in un tempo determinato.',
        sortOrder: 4,
      ),
      TerminologyTranslation(
        termKey: 'emom',
        title: 'EMOM',
        description:
            'Every Minute On Minute: inizi un set ogni minuto. Il tempo restante serve per riposare.',
        sortOrder: 5,
      ),
      TerminologyTranslation(
        termKey: 'ramping',
        title: 'Ramping',
        description: 'Metodo che prevede un incremento del peso ad ogni serie',
        sortOrder: 6,
      ),
      TerminologyTranslation(
        termKey: 'mav',
        title: 'MAV',
        description:
            'Massima Alzata Veloce: si riferisce a una metodologia in cui si cerca di eseguire il maggior numero di ripetizioni possibili con un carico, mantenendo sempre il controllo del movimento e una buona velocità di esecuzione.',
        sortOrder: 7,
      ),
      TerminologyTranslation(
        termKey: 'isokinetic',
        title: 'Isocinetici',
        description: 'Esercizi svolti a velocità costante.',
        sortOrder: 8,
      ),
      TerminologyTranslation(
        termKey: 'tut',
        title: 'TUT',
        description:
            'Indica quanto deve durare una ripetizione. Puoi gestire tu la durata di ogni fase della rep.',
        sortOrder: 9,
      ),
      TerminologyTranslation(
        termKey: 'iso',
        title: 'ISO',
        description:
            "Indica il fermo a un punto specifico dell'esecuzione della rep",
        sortOrder: 10,
      ),
      TerminologyTranslation(
        termKey: 'som',
        title: 'SOM',
        description: 'Indica la durata di ogni fase della ripetizione.',
        sortOrder: 11,
      ),
      TerminologyTranslation(
        termKey: 'deload',
        title: 'Scarico',
        description: 'Ultima settimana della scheda per prepararsi ai massimali.',
        sortOrder: 12,
      ),
    ],
  };

  static String _normalizeLocale(String locale) {
    if (locale.isEmpty) return 'en';
    return locale.split('_').first.toLowerCase();
  }

  static List<TerminologyTranslation> listForLocale(String locale) {
    final normalized = _normalizeLocale(locale);
    return _translations[normalized] ?? _translations['en'] ?? const [];
  }

  static TerminologyTranslation? lookup(String termKey, String locale) {
    final normalizedKey = termKey.trim().toLowerCase();
    if (normalizedKey.isEmpty) return null;
    for (final entry in listForLocale(locale)) {
      if (entry.termKey == normalizedKey) {
        return entry;
      }
    }
    return null;
  }
}

class ExerciseGuideStrings {
  const ExerciseGuideStrings({
    required this.name,
    required this.focus,
    required this.tip,
    required this.description,
  });

  final String name;
  final String focus;
  final String tip;
  final String description;

  static ExerciseGuideStrings fallback(String slug) {
    return ExerciseGuideStrings(
      name: slug,
      focus: '',
      tip: '',
      description: '',
    );
  }
}

class ExerciseGuideTranslations {
  static const Map<String, Map<String, ExerciseGuideStrings>> _translations = {
    'en': {
      'pullup': ExerciseGuideStrings(
        name: 'Pull-up',
        focus: 'Lats, biceps, grip',
        tip: 'Drive elbows toward your ribs and keep your ribs tucked to avoid swinging.',
        description:
            'Start from a hollow body hang, then pull until your chin clears the bar. Control the descent for stronger reps.',
      ),
      'chinup': ExerciseGuideStrings(
        name: 'Chin-up',
        focus: 'Lats, biceps, grip',
        tip:
            'Keep your shoulders down and drive your elbows toward your ribs to stay strong at the top.',
        description:
            'Start from a dead hang with palms facing you, pull until your chin clears the bar, then lower under control.',
      ),
      'pushup': ExerciseGuideStrings(
        name: 'Push-up',
        focus: 'Chest, triceps, core',
        tip: 'Squeeze your glutes and keep a straight line from head to heels.',
        description:
            'Lower with elbows at roughly 45° to your torso, touch your chest lightly, then press back up without letting hips sag.',
      ),
      'bodyweight-squat': ExerciseGuideStrings(
        name: 'Bodyweight squat',
        focus: 'Quads, glutes, core',
        tip: 'Push your knees out as you descend and keep your heels planted.',
        description:
            'Sit the hips back and down until thighs are at least parallel. Drive evenly through the whole foot to stand tall.',
      ),
      'glute-bridge': ExerciseGuideStrings(
        name: 'Glute bridge',
        focus: 'Glutes, hamstrings, core',
        tip: 'Exhale as you lift and avoid arching your lower back at the top.',
        description:
            'Lie on your back with knees bent, drive through your heels to lift hips until thighs and torso align, then lower with control.',
      ),
      'hanging-leg-raise': ExerciseGuideStrings(
        name: 'Hanging leg raise',
        focus: 'Abdominals, hip flexors, grip',
        tip: 'Initiate each rep by engaging your lats to steady the torso.',
        description:
            'From a dead hang, lift your legs together until they reach hip height or higher. Lower slowly to keep tension.',
      ),
      'muscle-up': ExerciseGuideStrings(
        name: 'Muscle-up',
        focus: 'Lats, chest, triceps, transition strength',
        tip: 'Pull high to your upper chest and keep the bar close to reduce the swing.',
        description:
            'From a controlled hang, explode into a high pull, transition the wrists over the bar, and press to lockout.',
      ),
      'straight-bar-dip': ExerciseGuideStrings(
        name: 'Straight bar dip',
        focus: 'Chest, triceps, shoulders',
        tip: 'Keep elbows tucked and press down while leaning slightly forward.',
        description:
            'Start on top of the bar with locked elbows, lower under control until shoulders dip below elbows, then drive back up.',
      ),
      'dips': ExerciseGuideStrings(
        name: 'Dips',
        focus: 'Chest, triceps, shoulders',
        tip: 'Lean slightly forward and keep shoulders packed to protect the joints.',
        description:
            'Start locked out on parallel bars, lower until shoulders dip below elbows, then press back to a strong lockout.',
      ),
      'australian-row': ExerciseGuideStrings(
        name: 'Australian row',
        focus: 'Upper back, biceps, core',
        tip: 'Brace your core and keep a straight line from shoulders to heels.',
        description:
            'Set the bar at waist height, hang underneath, and row your chest to the bar with elbows tight.',
      ),
      'pike-pushup': ExerciseGuideStrings(
        name: 'Pike push-up',
        focus: 'Shoulders, triceps, core',
        tip: 'Keep hips high and lower your head to a spot just in front of your hands.',
        description:
            'From a pike position, bend elbows to bring the head down, then press back to a strong lockout.',
      ),
      'hollow-hold': ExerciseGuideStrings(
        name: 'Hollow body hold',
        focus: 'Core, hip flexors, posture',
        tip: 'Press your lower back into the floor and keep your ribs tucked.',
        description:
            'Lie on your back, lift shoulders and legs, and hold a banana shape with straight arms overhead.',
      ),
      'plank': ExerciseGuideStrings(
        name: 'Plank',
        focus: 'Core, shoulders, glutes',
        tip: "Squeeze glutes and keep your ribs tucked so the hips don't sag.",
        description:
            'Set forearms under shoulders, extend legs long, and hold a straight line from head to heels while breathing steadily.',
      ),
      'l-sit': ExerciseGuideStrings(
        name: 'L-sit',
        focus: 'Core, hip flexors, triceps',
        tip: 'Push the floor away, lock elbows, and keep knees straight.',
        description:
            'From parallel bars or the floor, lift your legs to hip height and hold a tight L position.',
      ),
      'handstand': ExerciseGuideStrings(
        name: 'Handstand hold',
        focus: 'Shoulders, core, balance',
        tip: 'Stack wrists, shoulders, and hips while squeezing your glutes.',
        description:
            'Kick or press up to a wall or free balance and hold a tall line with toes pointed.',
      ),
    },
    'it': {
      'pullup': ExerciseGuideStrings(
        name: 'Trazioni',
        focus: 'Dorsali, bicipiti, presa',
        tip:
            'Spingi i gomiti verso le costole e mantieni le costole in dentro per evitare oscillazioni.',
        description:
            'Parti da una posizione hollow in sospensione, poi tira fino a superare la sbarra con il mento. Controlla la discesa per ripetizioni più solide.',
      ),
      'chinup': ExerciseGuideStrings(
        name: 'Chin-up',
        focus: 'Dorsali, bicipiti, presa',
        tip:
            'Mantieni le spalle basse e spingi i gomiti verso le costole per restare forte in cima.',
        description:
            'Parti da sospensione con i palmi verso di te, tira fino a superare la sbarra con il mento, poi scendi in controllo.',
      ),
      'pushup': ExerciseGuideStrings(
        name: 'Piegamenti',
        focus: 'Petto, tricipiti, core',
        tip: 'Contrai i glutei e tieni una linea dritta dalla testa ai talloni.',
        description:
            'Scendi con gomiti a circa 45° rispetto al busto, tocca leggermente il petto e risali senza lasciare cadere i fianchi.',
      ),
      'bodyweight-squat': ExerciseGuideStrings(
        name: 'Squat a corpo libero',
        focus: 'Quadricipiti, glutei, core',
        tip: 'Spingi le ginocchia verso l’esterno mentre scendi e tieni i talloni a terra.',
        description:
            'Porta le anche indietro e in basso fino a quando le cosce sono almeno parallele. Spingi in modo uniforme su tutto il piede per risalire.',
      ),
      'glute-bridge': ExerciseGuideStrings(
        name: 'Ponte glutei',
        focus: 'Glutei, femorali, core',
        tip: 'Espira mentre sali ed evita di inarcare la schiena in alto.',
        description:
            'Sdraiati con ginocchia piegate, spingi sui talloni per sollevare le anche finché cosce e busto sono allineati, poi scendi in controllo.',
      ),
      'hanging-leg-raise': ExerciseGuideStrings(
        name: 'Sollevamento gambe alla sbarra',
        focus: 'Addome, flessori dell’anca, presa',
        tip: 'Inizia ogni ripetizione attivando i dorsali per stabilizzare il torso.',
        description:
            'Da sospensione, solleva le gambe unite fino all’altezza delle anche o più. Scendi lentamente per mantenere tensione.',
      ),
      'muscle-up': ExerciseGuideStrings(
        name: 'Muscle-up',
        focus: 'Dorsali, petto, tricipiti, forza di transizione',
        tip: 'Tira alto verso la parte alta del petto e tieni la sbarra vicina per ridurre l’oscillazione.',
        description:
            'Da una sospensione controllata esplodi in una tirata alta, passa con i polsi sopra la sbarra e spingi fino al blocco.',
      ),
      'straight-bar-dip': ExerciseGuideStrings(
        name: 'Dip alla sbarra',
        focus: 'Petto, tricipiti, spalle',
        tip: 'Tieni i gomiti stretti e spingi verso il basso inclinando leggermente il busto in avanti.',
        description:
            'Inizia sopra la sbarra con gomiti bloccati, scendi in controllo finché le spalle scendono sotto i gomiti, poi risali con decisione.',
      ),
      'dips': ExerciseGuideStrings(
        name: 'Dip alle parallele',
        focus: 'Petto, tricipiti, spalle',
        tip: 'Inclina leggermente il busto e tieni le spalle compatte per proteggere le articolazioni.',
        description:
            'Parti in posizione di blocco sulle parallele, scendi finché le spalle scendono sotto i gomiti, poi risali fino al blocco.',
      ),
      'australian-row': ExerciseGuideStrings(
        name: 'Rematore australiano',
        focus: 'Dorso alto, bicipiti, core',
        tip: 'Contrai il core e mantieni una linea dritta da spalle a talloni.',
        description:
            'Regola la sbarra all’altezza della vita, appenditi sotto e tira il petto verso la sbarra con gomiti stretti.',
      ),
      'pike-pushup': ExerciseGuideStrings(
        name: 'Piegamenti in pike',
        focus: 'Spalle, tricipiti, core',
        tip: 'Mantieni i fianchi alti e abbassa la testa verso un punto davanti alle mani.',
        description:
            'Da posizione pike, piega i gomiti per portare la testa verso il basso, poi risali fino al blocco.',
      ),
      'hollow-hold': ExerciseGuideStrings(
        name: 'Tenuta hollow body',
        focus: 'Core, flessori dell’anca, postura',
        tip: 'Premi la zona lombare a terra e tieni le costole in dentro.',
        description:
            'Sdraiati, solleva spalle e gambe e mantieni la posizione a banana con braccia tese sopra la testa.',
      ),
      'plank': ExerciseGuideStrings(
        name: 'Plank',
        focus: 'Core, spalle, glutei',
        tip: 'Contrai i glutei e tieni le costole in dentro per evitare il cedimento dei fianchi.',
        description:
            'Appoggia gli avambracci sotto le spalle, estendi le gambe e mantieni una linea dritta dalla testa ai talloni respirando in modo costante.',
      ),
      'l-sit': ExerciseGuideStrings(
        name: 'L-sit',
        focus: 'Core, flessori dell’anca, tricipiti',
        tip: 'Spingi il pavimento, blocca i gomiti e tieni le ginocchia tese.',
        description:
            'Da parallele o da terra, solleva le gambe all’altezza delle anche e mantieni una L compatta.',
      ),
      'handstand': ExerciseGuideStrings(
        name: 'Tenuta in verticale',
        focus: 'Spalle, core, equilibrio',
        tip: 'Allinea polsi, spalle e anche mentre contrai i glutei.',
        description:
            'Calcia o sali in verticale al muro o in equilibrio libero e mantieni una linea alta con le punte tese.',
      ),
    },
  };

  static String _normalizeLocale(String locale) {
    if (locale.isEmpty) return 'en';
    return locale.split('_').first.toLowerCase();
  }

  static ExerciseGuideStrings forSlug(String slug, String locale) {
    final normalizedLocale = _normalizeLocale(locale);
    final byLocale = _translations[normalizedLocale];
    final fallbackLocale = _translations['en'];
    return byLocale?[slug] ??
        fallbackLocale?[slug] ??
        ExerciseGuideStrings.fallback(slug);
  }

  static String? nameForSlug(String slug, String locale) {
    final normalizedLocale = _normalizeLocale(locale);
    return _translations[normalizedLocale]?[slug]?.name ??
        _translations['en']?[slug]?.name;
  }
}

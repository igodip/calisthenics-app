-- Exercise seed data for Supabase

INSERT INTO public.exercises (slug, name, difficulty, sort_order)
VALUES
  ('pull-up', 'Pull-up', 'intermediate', 1),
  ('chin-up', 'Chin-up', 'intermediate', 2),
  ('push-up', 'Push-up', 'beginner', 3),
  ('bodyweight-squat', 'Bodyweight squat', 'beginner', 4),
  ('glute-bridge', 'Glute bridge', 'beginner', 5),
  ('hanging-leg-raise', 'Hanging leg raise', 'intermediate', 6),
  ('muscle-up', 'Muscle-up', 'advanced', 7),
  ('straight-bar-dip', 'Straight bar dip', 'intermediate', 8),
  ('dips', 'Dips', 'intermediate', 9),
  ('australian-row', 'Australian row', 'beginner', 10),
  ('pike-push-up', 'Pike push-up', 'intermediate', 11),
  ('hollow-body-hold', 'Hollow body hold', 'beginner', 12),
  ('plank', 'Plank', 'beginner', 13),
  ('l-sit', 'L-sit', 'intermediate', 14),
  ('handstand-hold', 'Handstand hold', 'advanced', 15);

INSERT INTO public.exercise_translations (
  exercise_id,
  locale,
  name,
  focus,
  tip,
  description
)
SELECT
  exercises.id,
  translations.locale,
  translations.name,
  translations.focus,
  translations.tip,
  translations.description
FROM public.exercises
JOIN (
  VALUES
    ('pull-up', 'en', 'Pull-up', 'Lats, biceps, grip', 'Drive elbows toward your ribs and keep your ribs tucked to avoid swinging.', 'Start from a hollow body hang, then pull until your chin clears the bar. Control the descent for stronger reps.'),
    ('pull-up', 'it', 'Trazioni', 'Dorsali, bicipiti, presa', 'Spingi i gomiti verso le costole e tieni le costole chiuse per evitare oscillazioni.', 'Parti da una sospensione in hollow body, poi tira finché il mento supera la sbarra. Controlla la discesa per ripetizioni più forti.'),
    ('pull-up', 'es', 'Dominada', 'Dorsales, bíceps, agarre', 'Lleva los codos hacia las costillas y mantén las costillas recogidas para evitar el balanceo.', 'Empieza colgado con cuerpo en hollow, luego tira hasta que la barbilla supere la barra. Controla la bajada para repeticiones más fuertes.'),
    ('chin-up', 'en', 'Chin-up', 'Lats, biceps, grip', 'Keep your shoulders down and drive your elbows toward your ribs to stay strong at the top.', 'Start from a dead hang with palms facing you, pull until your chin clears the bar, then lower under control.'),
    ('chin-up', 'it', 'Chin-up', 'Dorsali, bicipiti, presa', 'Tieni le spalle depresse e spingi i gomiti verso le costole per restare forte in alto.', 'Parti da una sospensione con i palmi verso di te, tira finché il mento supera la sbarra, poi scendi con controllo.'),
    ('chin-up', 'es', 'Dominada supina', 'Dorsales, bíceps, agarre', 'Mantén los hombros abajo y lleva los codos hacia las costillas para mantener fuerza arriba.', 'Empieza colgado con las palmas hacia ti, tira hasta que la barbilla supere la barra y baja con control.'),
    ('push-up', 'en', 'Push-up', 'Chest, triceps, core', 'Squeeze your glutes and keep a straight line from head to heels.', 'Lower with elbows at roughly 45° to your torso, touch your chest lightly, then press back up without letting hips sag.'),
    ('push-up', 'it', 'Piegamenti', 'Petto, tricipiti, core', 'Contrai i glutei e mantieni una linea dritta dalla testa ai talloni.', 'Scendi con i gomiti a circa 45° rispetto al busto, sfiora il petto e risali senza lasciare che i fianchi cedano.'),
    ('push-up', 'es', 'Flexión', 'Pecho, tríceps, core', 'Aprieta los glúteos y mantén una línea recta de la cabeza a los talones.', 'Baja con los codos a unos 45° del torso, toca ligeramente el pecho y vuelve a subir sin que las caderas se hundan.'),
    ('bodyweight-squat', 'en', 'Bodyweight squat', 'Quads, glutes, core', 'Push your knees out as you descend and keep your heels planted.', 'Sit the hips back and down until thighs are at least parallel. Drive evenly through the whole foot to stand tall.'),
    ('bodyweight-squat', 'it', 'Squat a corpo libero', 'Quadricipiti, glutei, core', 'Spingi le ginocchia verso l''esterno durante la discesa e mantieni i talloni a terra.', 'Porta indietro e in basso le anche finché le cosce sono almeno parallele. Spingi uniformemente su tutto il piede per tornare in piedi.'),
    ('bodyweight-squat', 'es', 'Sentadilla con peso corporal', 'Cuádriceps, glúteos, core', 'Empuja las rodillas hacia afuera al bajar y mantén los talones apoyados.', 'Lleva las caderas atrás y abajo hasta que los muslos estén al menos paralelos. Empuja de forma uniforme con todo el pie para ponerte de pie.'),
    ('glute-bridge', 'en', 'Glute bridge', 'Glutes, hamstrings, core', 'Exhale as you lift and avoid arching your lower back at the top.', 'Lie on your back with knees bent, drive through your heels to lift hips until thighs and torso align, then lower with control.'),
    ('glute-bridge', 'it', 'Ponte glutei', 'Glutei, femorali, core', 'Espira mentre sali ed evita di inarcare troppo la zona lombare in alto.', 'Supino con ginocchia piegate, spingi sui talloni per sollevare il bacino finché cosce e busto sono allineati, poi scendi lentamente.'),
    ('glute-bridge', 'es', 'Puente de glúteos', 'Glúteos, isquiotibiales, core', 'Exhala al subir y evita arquear la espalda baja en la parte alta.', 'Túmbate boca arriba con rodillas flexionadas, empuja con los talones para elevar las caderas hasta alinear muslos y torso, y baja con control.'),
    ('hanging-leg-raise', 'en', 'Hanging leg raise', 'Abdominals, hip flexors, grip', 'Initiate each rep by engaging your lats to steady the torso.', 'From a dead hang, lift your legs together until they reach hip height or higher. Lower slowly to keep tension.'),
    ('hanging-leg-raise', 'it', 'Sollevamento gambe alla sbarra', 'Addominali, flessori dell''anca, presa', 'Inizia ogni ripetizione attivando i dorsali per stabilizzare il busto.', 'Da una sospensione completa, solleva le gambe unite fino all''altezza delle anche o più in alto. Scendi lentamente per mantenere tensione.'),
    ('hanging-leg-raise', 'es', 'Elevación de piernas colgado', 'Abdominales, flexores de cadera, agarre', 'Inicia cada repetición activando los dorsales para estabilizar el torso.', 'Desde un colgado muerto, eleva las piernas juntas hasta la altura de la cadera o más. Baja despacio para mantener tensión.'),
    ('muscle-up', 'en', 'Muscle-up', 'Lats, chest, triceps, transition strength', 'Pull high to your upper chest and keep the bar close to reduce the swing.', 'From a controlled hang, explode into a high pull, transition the wrists over the bar, and press to lockout.'),
    ('muscle-up', 'it', 'Muscle-up', 'Dorsali, petto, tricipiti, forza nella transizione', 'Tira in alto verso la parte alta del petto e tieni la sbarra vicina per ridurre l''oscillazione.', 'Da una sospensione controllata, esplodi in una trazione alta, porta i polsi sopra la sbarra e spingi fino al blocco.'),
    ('muscle-up', 'es', 'Muscle-up', 'Dorsales, pecho, tríceps, fuerza de transición', 'Tira alto hacia el pecho superior y mantén la barra cerca para reducir el balanceo.', 'Desde un colgado controlado, explota en un tirón alto, pasa las muñecas sobre la barra y presiona hasta el bloqueo.'),
    ('straight-bar-dip', 'en', 'Straight bar dip', 'Chest, triceps, shoulders', 'Keep elbows tucked and press down while leaning slightly forward.', 'Start on top of the bar with locked elbows, lower under control until shoulders dip below elbows, then drive back up.'),
    ('straight-bar-dip', 'it', 'Dip alla sbarra', 'Petto, tricipiti, spalle', 'Tieni i gomiti vicini al corpo e spingi verso il basso con una leggera inclinazione in avanti.', 'Parti sopra la sbarra con gomiti bloccati, scendi controllando finché le spalle scendono sotto i gomiti, poi risali.'),
    ('straight-bar-dip', 'es', 'Fondos en barra recta', 'Pecho, tríceps, hombros', 'Mantén los codos pegados y empuja hacia abajo inclinándote ligeramente hacia delante.', 'Empieza arriba de la barra con los codos bloqueados, baja con control hasta que los hombros queden por debajo de los codos y vuelve a subir.'),
    ('dips', 'en', 'Dips', 'Chest, triceps, shoulders', 'Lean slightly forward and keep shoulders packed to protect the joints.', 'Start locked out on parallel bars, lower until shoulders dip below elbows, then press back to a strong lockout.'),
    ('dips', 'it', 'Dip alle parallele', 'Petto, tricipiti, spalle', 'Inclina leggermente il busto in avanti e mantieni le spalle compatte per proteggere le articolazioni.', 'Parti in blocco sulle parallele, scendi finché le spalle vanno sotto i gomiti, poi risali fino a un blocco forte.'),
    ('dips', 'es', 'Fondos', 'Pecho, tríceps, hombros', 'Inclínate ligeramente hacia delante y mantén los hombros estables para proteger las articulaciones.', 'Empieza bloqueado en barras paralelas, baja hasta que los hombros queden por debajo de los codos y vuelve a subir con fuerza.'),
    ('australian-row', 'en', 'Australian row', 'Upper back, biceps, core', 'Brace your core and keep a straight line from shoulders to heels.', 'Set the bar at waist height, hang underneath, and row your chest to the bar with elbows tight.'),
    ('australian-row', 'it', 'Rematore australiano', 'Dorsali alti, bicipiti, core', 'Attiva il core e mantieni una linea dritta dalle spalle ai talloni.', 'Imposta la sbarra all''altezza della vita, appenditi sotto e tira il petto verso la sbarra con gomiti stretti.'),
    ('australian-row', 'es', 'Remo australiano', 'Espalda alta, bíceps, core', 'Activa el core y mantén una línea recta de los hombros a los talones.', 'Coloca la barra a la altura de la cintura, cuélgate debajo y rema el pecho hacia la barra con los codos cerrados.'),
    ('pike-push-up', 'en', 'Pike push-up', 'Shoulders, triceps, core', 'Keep hips high and lower your head to a spot just in front of your hands.', 'From a pike position, bend elbows to bring the head down, then press back to a strong lockout.'),
    ('pike-push-up', 'it', 'Piegamenti in pike', 'Spalle, tricipiti, core', 'Tieni i fianchi alti e abbassa la testa verso un punto appena davanti alle mani.', 'Da una posizione a pike, piega i gomiti per portare la testa in basso, poi spingi fino a un blocco forte.'),
    ('pike-push-up', 'es', 'Flexión pike', 'Hombros, tríceps, core', 'Mantén las caderas altas y baja la cabeza a un punto justo delante de las manos.', 'Desde la posición pike, flexiona los codos para bajar la cabeza y luego presiona hasta el bloqueo.'),
    ('hollow-body-hold', 'en', 'Hollow body hold', 'Core, hip flexors, posture', 'Press your lower back into the floor and keep your ribs tucked.', 'Lie on your back, lift shoulders and legs, and hold a banana shape with straight arms overhead.'),
    ('hollow-body-hold', 'it', 'Tenuta hollow body', 'Core, flessori dell''anca, postura', 'Spingi la zona lombare a terra e tieni le costole chiuse.', 'Sdraiati supino, solleva spalle e gambe e mantieni una forma a banana con braccia tese sopra la testa.'),
    ('hollow-body-hold', 'es', 'Hollow hold', 'Core, flexores de cadera, postura', 'Presiona la zona lumbar contra el suelo y mantén las costillas recogidas.', 'Túmbate boca arriba, eleva hombros y piernas y mantén una forma de banana con brazos rectos sobre la cabeza.'),
    ('plank', 'en', 'Plank', 'Core, shoulders, glutes', 'Squeeze glutes and keep your ribs tucked so the hips don''t sag.', 'Set forearms under shoulders, extend legs long, and hold a straight line from head to heels while breathing steadily.'),
    ('plank', 'it', 'Plank', 'Core, spalle, glutei', 'Contrai i glutei e tieni le costole chiuse per evitare che i fianchi cedano.', 'Posiziona gli avambracci sotto le spalle, allunga le gambe e mantieni una linea dritta dalla testa ai talloni respirando con calma.'),
    ('plank', 'es', 'Plancha', 'Core, hombros, glúteos', 'Aprieta los glúteos y mantén las costillas recogidas para que las caderas no se hundan.', 'Coloca antebrazos bajo los hombros, estira las piernas y mantén una línea recta de la cabeza a los talones mientras respiras.'),
    ('l-sit', 'en', 'L-sit', 'Core, hip flexors, triceps', 'Push the floor away, lock elbows, and keep knees straight.', 'From parallel bars or the floor, lift your legs to hip height and hold a tight L position.'),
    ('l-sit', 'it', 'L-sit', 'Core, flessori dell''anca, tricipiti', 'Spingi il pavimento, blocca i gomiti e tieni le ginocchia dritte.', 'Da parallele o a terra, solleva le gambe all''altezza delle anche e mantieni una L compatta.'),
    ('l-sit', 'es', 'L-sit', 'Core, flexores de cadera, tríceps', 'Empuja el suelo, bloquea los codos y mantén las rodillas rectas.', 'Desde barras paralelas o el suelo, eleva las piernas hasta la altura de la cadera y mantén una L firme.'),
    ('handstand-hold', 'en', 'Handstand hold', 'Shoulders, core, balance', 'Stack wrists, shoulders, and hips while squeezing your glutes.', 'Kick or press up to a wall or free balance and hold a tall line with toes pointed.'),
    ('handstand-hold', 'it', 'Tenuta in verticale', 'Spalle, core, equilibrio', 'Allinea polsi, spalle e anche e contrai i glutei.', 'Sali in verticale contro il muro o in equilibrio libero e mantieni una linea lunga con le punte tese.'),
    ('handstand-hold', 'es', 'Parada de manos', 'Hombros, core, equilibrio', 'Alinea muñecas, hombros y caderas mientras aprietas los glúteos.', 'Sube con impulso o empuje a una pared o equilibrio libre y mantén una línea alta con los dedos apuntando.')
) AS translations (slug, locale, name, focus, tip, description)
ON exercises.slug = translations.slug;

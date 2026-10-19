-- Bodyweight triceps extensions on a fixed bar. Preserve existing catalog
-- entries/translations if this migration is reapplied or the slug already exists.
begin;

insert into public.exercises (id, slug, name, difficulty, sort_order)
select
  gen_random_uuid(),
  'bodyweight-triceps-extension',
  'Bodyweight triceps extension',
  'beginner',
  coalesce(max(sort_order), 0) + 10
from public.exercises
on conflict (slug) do nothing;

insert into public.exercise_translations
  (exercise_id, locale, name, focus, tip, description)
select exercise.id, translation.locale, translation.name,
  translation.focus, translation.tip, translation.description
from public.exercises exercise
cross join (values
  (
    'it',
    'Estensioni tricipiti alla sbarra',
    'Tricipiti e stabilità del tronco',
    'Per facilitare il movimento usa una sbarra più alta o avvicina i piedi. Mantieni i gomiti rivolti in avanti e scegli un''ampiezza controllabile.',
    'Impugna una sbarra fissa e stabile circa alla larghezza delle spalle. Arretra con i piedi e inclina il corpo mantenendo addome e glutei attivi. Piega i gomiti per avvicinare la fronte alla sbarra, senza aprire i gomiti o inarcare la schiena. Distendi le braccia con controllo per tornare alla posizione iniziale. Adatta inclinazione e profondità alle indicazioni del trainer; interrompi in caso di dolore.'
  ),
  (
    'en',
    'Bodyweight triceps extension',
    'Triceps and trunk stability',
    'Use a higher bar or bring your feet closer to make the movement easier. Keep elbows pointing forward and use a range you can control.',
    'Grip a secure fixed bar with hands about shoulder-width apart. Step back and lean into a straight-body position with your abdomen and glutes engaged. Bend your elbows to bring your forehead toward the bar without flaring your elbows or arching your back. Extend your arms under control to return to the start. Adjust the angle and depth to your trainer''s instructions; stop if you feel pain.'
  ),
  (
    'es',
    'Extensiones de tríceps en barra',
    'Tríceps y estabilidad del tronco',
    'Utiliza una barra más alta o acerca los pies para facilitar el movimiento. Mantén los codos hacia delante y elige un recorrido que puedas controlar.',
    'Agarra una barra fija y estable con las manos aproximadamente al ancho de los hombros. Da un paso atrás e inclina el cuerpo manteniendo activos el abdomen y los glúteos. Flexiona los codos para acercar la frente a la barra, sin abrir los codos ni arquear la espalda. Extiende los brazos con control para volver al inicio. Adapta la inclinación y la profundidad a las indicaciones de tu entrenador; detente si sientes dolor.'
  )
) as translation(locale, name, focus, tip, description)
where exercise.slug = 'bodyweight-triceps-extension'
  and not exists (
    select 1 from public.exercise_translations existing
    where existing.exercise_id = exercise.id
      and existing.locale = translation.locale
  );

commit;

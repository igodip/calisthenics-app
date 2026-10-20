-- Add the guide without replacing existing catalog content when reapplied.
begin;

insert into public.exercises (id, slug, name, difficulty, sort_order)
select gen_random_uuid(), 'front-lever', 'Front lever', 'advanced',
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
    'Front lever',
    'Forza di tirata a braccia tese, dorsali e controllo del core',
    'Inizia dalla variante tuck e progredisci secondo le indicazioni del trainer. Mantieni i gomiti distesi, il bacino controllato e respira durante la tenuta.',
    'Usa una sbarra fissa e stabile con presa prona circa alla larghezza delle spalle. Dalla sospensione attiva, porta il corpo verso una posizione orizzontale con il viso rivolto in alto. Mantieni le braccia tese, le spalle attive e addome e glutei contratti, senza inarcare la zona lombare. Nella variante completa, spalle, bacino e piedi restano allineati. Scegli una progressione adatta al tuo livello, come tuck, advanced tuck o straddle, e una durata concordata con il trainer. Esci dalla posizione con controllo; interrompi in caso di dolore.'
  ),
  (
    'en',
    'Front lever',
    'Straight-arm pulling strength, lats and core control',
    'Start with a tuck progression and advance with your trainer. Keep your elbows straight, control your pelvis and breathe throughout the hold.',
    'Use a secure fixed bar with an overhand grip about shoulder-width apart. From an active hang, raise your body toward a horizontal, face-up position. Keep your arms straight, shoulders engaged, and abdomen and glutes tight without arching your lower back. In the full variation, shoulders, hips and feet stay aligned. Choose a suitable progression, such as tuck, advanced tuck or straddle, and a hold duration agreed with your trainer. Lower out of the position under control; stop if you feel pain.'
  ),
  (
    'es',
    'Front lever',
    'Fuerza de tracción con brazos rectos, dorsales y control del core',
    'Empieza con la progresión tuck y avanza con tu entrenador. Mantén los codos extendidos, controla la pelvis y respira durante la posición.',
    'Utiliza una barra fija y estable con agarre prono aproximadamente al ancho de los hombros. Desde una suspensión activa, eleva el cuerpo hacia una posición horizontal, boca arriba. Mantén los brazos rectos, los hombros activos y el abdomen y los glúteos contraídos, sin arquear la zona lumbar. En la variante completa, hombros, caderas y pies permanecen alineados. Elige una progresión adecuada, como tuck, advanced tuck o straddle, y una duración acordada con tu entrenador. Sal de la posición con control; detente si sientes dolor.'
  )
) as translation(locale, name, focus, tip, description)
where exercise.slug = 'front-lever'
  and not exists (
    select 1 from public.exercise_translations existing
    where existing.exercise_id = exercise.id
      and existing.locale = translation.locale
  );

commit;

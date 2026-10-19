-- Run after migrations against a development/test database.
begin;

do $$
declare
  guide_id uuid;
begin
  select id into strict guide_id from public.exercises
  where slug = 'bodyweight-triceps-extension' and difficulty = 'beginner';

  if (
    select count(*) from public.exercise_translations
    where exercise_id = guide_id and locale in ('it', 'en', 'es')
      and length(trim(name)) > 0 and length(trim(focus)) > 0
      and length(trim(tip)) > 0 and length(trim(description)) > 0
  ) <> 3 then
    raise exception 'Triceps extension guide requires complete IT/EN/ES translations';
  end if;
end $$;

rollback;

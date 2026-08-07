alter table public.day_exercises
add column if not exists exercise_feedback_feeling integer
check (
  exercise_feedback_feeling is null
  or exercise_feedback_feeling between 1 and 5
);

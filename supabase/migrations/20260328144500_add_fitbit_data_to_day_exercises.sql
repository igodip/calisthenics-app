alter table public.day_exercises
add column if not exists fitbit_data jsonb;

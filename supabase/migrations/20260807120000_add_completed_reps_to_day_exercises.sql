alter table public.day_exercises
add column if not exists completed_reps integer not null default 0
check (completed_reps >= 0);

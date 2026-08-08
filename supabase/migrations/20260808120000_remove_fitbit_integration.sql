drop table if exists public.timer_fitbit_sessions;
drop table if exists public.fitbit_connections;
drop function if exists public.tg_fitbit_connections_updated_at();

alter table if exists public.day_exercises
drop column if exists fitbit_data;

create table if not exists public.timer_fitbit_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  started_at timestamptz not null,
  ended_at timestamptz not null,
  detail_level_used text not null,
  sample_count integer not null default 0,
  heart_rate_samples jsonb not null default '[]'::jsonb,
  timer_config jsonb,
  summary jsonb,
  created_at timestamptz not null default timezone('utc'::text, now())
);

alter table public.timer_fitbit_sessions enable row level security;

drop policy if exists "timer_fitbit_sessions_select_own" on public.timer_fitbit_sessions;
create policy "timer_fitbit_sessions_select_own"
on public.timer_fitbit_sessions
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "timer_fitbit_sessions_insert_own" on public.timer_fitbit_sessions;
create policy "timer_fitbit_sessions_insert_own"
on public.timer_fitbit_sessions
for insert
to authenticated
with check (auth.uid() = user_id);

create index if not exists timer_fitbit_sessions_user_started_idx
on public.timer_fitbit_sessions (user_id, started_at desc);

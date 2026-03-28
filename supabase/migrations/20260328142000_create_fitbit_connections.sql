create table if not exists public.fitbit_connections (
  user_id uuid primary key references auth.users(id) on delete cascade,
  fitbit_user_id text,
  scope text,
  access_token text not null,
  refresh_token text not null,
  token_type text default 'Bearer',
  expires_at timestamptz,
  linked_at timestamptz default timezone('utc'::text, now()) not null,
  last_sync_at timestamptz,
  created_at timestamptz default timezone('utc'::text, now()) not null,
  updated_at timestamptz default timezone('utc'::text, now()) not null
);

alter table public.fitbit_connections enable row level security;

drop policy if exists "fitbit_connections_select_own" on public.fitbit_connections;
create policy "fitbit_connections_select_own"
on public.fitbit_connections
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "fitbit_connections_insert_own" on public.fitbit_connections;
create policy "fitbit_connections_insert_own"
on public.fitbit_connections
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "fitbit_connections_update_own" on public.fitbit_connections;
create policy "fitbit_connections_update_own"
on public.fitbit_connections
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create or replace function public.tg_fitbit_connections_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc'::text, now());
  return new;
end;
$$;

drop trigger if exists fitbit_connections_set_updated_at on public.fitbit_connections;
create trigger fitbit_connections_set_updated_at
before update on public.fitbit_connections
for each row
execute function public.tg_fitbit_connections_updated_at();

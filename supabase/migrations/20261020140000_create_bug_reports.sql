create table if not exists public.bug_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (btrim(title) <> ''),
  description text not null check (btrim(description) <> ''),
  reproduction_steps text,
  expected_behavior text,
  actual_behavior text,
  platform text,
  app_version text,
  status text not null default 'open',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists bug_reports_created_at_idx
  on public.bug_reports (created_at desc);

alter table public.bug_reports enable row level security;
alter table public.bug_reports force row level security;

revoke all on table public.bug_reports from anon;
revoke all on table public.bug_reports from authenticated;
grant select, insert, update, delete on table public.bug_reports to authenticated;
grant all on table public.bug_reports to service_role;

drop policy if exists bug_reports_select_admin on public.bug_reports;
drop policy if exists bug_reports_insert_reporter on public.bug_reports;
drop policy if exists bug_reports_update_admin on public.bug_reports;
drop policy if exists bug_reports_delete_admin on public.bug_reports;

create policy bug_reports_select_admin
on public.bug_reports
for select
to authenticated
using (public.is_admin(auth.uid()));

create policy bug_reports_insert_reporter
on public.bug_reports
for insert
to authenticated
with check (
  (reporter_id = auth.uid() and status = 'open')
  or public.is_admin(auth.uid())
);

create policy bug_reports_update_admin
on public.bug_reports
for update
to authenticated
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));

create policy bug_reports_delete_admin
on public.bug_reports
for delete
to authenticated
using (public.is_admin(auth.uid()));

create or replace function public.tg_bug_reports_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists bug_reports_set_updated_at on public.bug_reports;
create trigger bug_reports_set_updated_at
before update on public.bug_reports
for each row
execute function public.tg_bug_reports_updated_at();

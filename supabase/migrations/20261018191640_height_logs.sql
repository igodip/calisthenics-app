create table if not exists public.trainee_height_logs (
    id uuid primary key default gen_random_uuid(),
    trainee_id uuid not null references public.trainees(id) on delete cascade,
    height numeric(5, 2) not null check (height > 0),
    recorded_at date not null,
    notes text,
    created_at timestamptz not null default now()
);

create index if not exists trainee_height_logs_trainee_id_recorded_at_idx
    on public.trainee_height_logs (trainee_id, recorded_at desc);

alter table public.trainee_height_logs enable row level security;
alter table public.trainee_height_logs force row level security;

revoke all on table public.trainee_height_logs from anon;
revoke all on table public.trainee_height_logs from authenticated;
grant select, insert, update, delete on table public.trainee_height_logs to authenticated;
grant all on table public.trainee_height_logs to service_role;

drop policy if exists trainee_height_logs_select_access on public.trainee_height_logs;
drop policy if exists trainee_height_logs_insert_self on public.trainee_height_logs;
drop policy if exists trainee_height_logs_insert_admin on public.trainee_height_logs;
drop policy if exists trainee_height_logs_update_admin on public.trainee_height_logs;
drop policy if exists trainee_height_logs_delete_admin on public.trainee_height_logs;

create policy trainee_height_logs_select_access
on public.trainee_height_logs
for select
to authenticated
using (
  public.is_admin(auth.uid())
  or auth.uid() = trainee_id
  or public.is_assigned_trainer(auth.uid(), trainee_id)
);

create policy trainee_height_logs_insert_self
on public.trainee_height_logs
for insert
to authenticated
with check (
  auth.uid() = trainee_id
);

create policy trainee_height_logs_insert_admin
on public.trainee_height_logs
for insert
to authenticated
with check (
  public.is_admin(auth.uid())
);

create policy trainee_height_logs_update_admin
on public.trainee_height_logs
for update
to authenticated
using (
  public.is_admin(auth.uid())
)
with check (
  public.is_admin(auth.uid())
);

create policy trainee_height_logs_delete_admin
on public.trainee_height_logs
for delete
to authenticated
using (
  public.is_admin(auth.uid())
);
create table if not exists public.max_test_trainer_notes (
  max_test_id uuid primary key references public.max_tests(id) on delete cascade,
  notes text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint max_test_trainer_notes_not_blank check (length(btrim(notes)) > 0),
  constraint max_test_trainer_notes_length_check check (char_length(notes) <= 2000)
);

alter table public.max_test_trainer_notes enable row level security;
alter table public.max_test_trainer_notes force row level security;

drop policy if exists max_test_trainer_notes_select_assigned_trainer
  on public.max_test_trainer_notes;
drop policy if exists max_test_trainer_notes_insert_assigned_trainer
  on public.max_test_trainer_notes;
drop policy if exists max_test_trainer_notes_update_assigned_trainer
  on public.max_test_trainer_notes;
drop policy if exists max_test_trainer_notes_delete_assigned_trainer
  on public.max_test_trainer_notes;

create policy max_test_trainer_notes_select_assigned_trainer
on public.max_test_trainer_notes
for select
to authenticated
using (
  exists (
    select 1
    from public.max_tests mt
    where mt.id = max_test_id
      and public.is_assigned_trainer(auth.uid(), mt.trainee_id)
  )
);

create policy max_test_trainer_notes_insert_assigned_trainer
on public.max_test_trainer_notes
for insert
to authenticated
with check (
  exists (
    select 1
    from public.max_tests mt
    where mt.id = max_test_id
      and public.is_assigned_trainer(auth.uid(), mt.trainee_id)
  )
);

create policy max_test_trainer_notes_update_assigned_trainer
on public.max_test_trainer_notes
for update
to authenticated
using (
  exists (
    select 1
    from public.max_tests mt
    where mt.id = max_test_id
      and public.is_assigned_trainer(auth.uid(), mt.trainee_id)
  )
)
with check (
  exists (
    select 1
    from public.max_tests mt
    where mt.id = max_test_id
      and public.is_assigned_trainer(auth.uid(), mt.trainee_id)
  )
);

create policy max_test_trainer_notes_delete_assigned_trainer
on public.max_test_trainer_notes
for delete
to authenticated
using (
  exists (
    select 1
    from public.max_tests mt
    where mt.id = max_test_id
      and public.is_assigned_trainer(auth.uid(), mt.trainee_id)
  )
);

revoke all on table public.max_test_trainer_notes from anon;
revoke all on table public.max_test_trainer_notes from authenticated;
grant select, insert, update, delete
  on table public.max_test_trainer_notes to authenticated;
grant all on table public.max_test_trainer_notes to service_role;

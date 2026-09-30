alter table public.max_tests
  add column if not exists exercise_id uuid references public.exercises(id) on update cascade on delete restrict,
  add column if not exists created_at timestamptz not null default now();

update public.max_tests mt
set exercise_id = e.id
from public.exercises e
where mt.exercise_id is null
  and (
    lower(btrim(mt.exercise)) = lower(btrim(e.slug))
    or lower(btrim(mt.exercise)) = lower(btrim(e.name))
  );

update public.max_tests
set exercise = btrim(exercise),
    unit = lower(btrim(unit));

alter table public.max_tests
  alter column value set not null,
  alter column unit set not null,
  alter column recorded_at set default current_date,
  alter column recorded_at set not null;

alter table public.max_tests
  drop constraint if exists max_tests_exercise_not_blank,
  add constraint max_tests_exercise_not_blank check (length(btrim(exercise)) > 0),
  drop constraint if exists max_tests_value_positive,
  add constraint max_tests_value_positive check (value > 0),
  drop constraint if exists max_tests_unit_valid,
  add constraint max_tests_unit_valid check (unit in ('kg', 'reps', 'seconds', 'minutes'));

create index if not exists idx_max_tests_trainee_date
  on public.max_tests (trainee_id, recorded_at desc, created_at desc, id desc);

create index if not exists idx_max_tests_exercise_id
  on public.max_tests (exercise_id)
  where exercise_id is not null;

alter table public.max_tests enable row level security;
alter table public.max_tests force row level security;

drop policy if exists max_tests_modify_access on public.max_tests;
drop policy if exists max_tests_select_access on public.max_tests;
drop policy if exists max_tests_insert_assigned_trainer on public.max_tests;
drop policy if exists max_tests_delete_assigned_trainer on public.max_tests;

create policy max_tests_select_access
on public.max_tests
for select
to authenticated
using (
  trainee_id = auth.uid()
  or public.is_assigned_trainer(auth.uid(), trainee_id)
  or public.is_admin(auth.uid())
);

create policy max_tests_insert_assigned_trainer
on public.max_tests
for insert
to authenticated
with check (public.is_assigned_trainer(auth.uid(), trainee_id));

create policy max_tests_delete_assigned_trainer
on public.max_tests
for delete
to authenticated
using (public.is_assigned_trainer(auth.uid(), trainee_id));

revoke all on table public.max_tests from anon;
revoke all on table public.max_tests from authenticated;
grant select, insert, delete on table public.max_tests to authenticated;
grant all on table public.max_tests to service_role;

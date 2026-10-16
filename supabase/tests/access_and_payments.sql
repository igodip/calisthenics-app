-- Run against the linked database AFTER applying the migration.
-- All fixtures and changes are rolled back, including on any failed assertion.
begin;
-- Production currently enforces one plan per day. Temporarily relax it only
-- within this rolled-back test to verify deletion also survives shared legacy data.
alter table public.workout_plan_days drop constraint if exists workout_plan_days_day_id_unique;
create temporary table access_fixture (label text primary key, id uuid default gen_random_uuid());
insert into access_fixture(label) values ('trainer'), ('outsider'), ('trainee'), ('other'), ('admin'),
  ('plan'), ('shared_plan'), ('day'), ('shared_day'), ('exercise'), ('shared_exercise');
grant select on access_fixture to authenticated;
create function pg_temp.fixture(text) returns uuid language sql as
  'select id from access_fixture where label = $1';
create function pg_temp.assert_true(value boolean, message text) returns void language plpgsql as $$
begin if value is distinct from true then raise exception 'Assertion failed: %', message; end if; end $$;
create function pg_temp.denied(statement text) returns void language plpgsql as $$
begin
  begin execute statement;
  exception when insufficient_privilege then return; end;
  raise exception 'Expected permission denial: %', statement;
end $$;
create function pg_temp.invalid_payment(amount numeric) returns void language plpgsql as $$
begin
  begin perform public.save_monthly_payment(pg_temp.fixture('trainee'),true,amount,null);
  exception when raise_exception then
    if sqlerrm = 'Invalid payment' then return; end if;
    raise;
  end;
  raise exception 'Invalid amount accepted: %', amount;
end $$;
insert into auth.users(id, email, created_at, updated_at)
  select id, id::text || '@example.invalid', now(), now() from access_fixture
  where label in ('trainer','outsider','trainee','other','admin');
insert into public.trainers(id,name) values
  (pg_temp.fixture('trainer'),'Test trainer'), (pg_temp.fixture('outsider'),'Test outsider')
  on conflict (id) do nothing;
insert into public.admins(id) values (pg_temp.fixture('admin')) on conflict do nothing;
insert into public.trainees(id,name) values
  (pg_temp.fixture('trainee'),'Test trainee'), (pg_temp.fixture('other'),'Test other')
  on conflict (id) do nothing;
insert into public.trainee_trainers(trainee_id,trainer_id)
  values (pg_temp.fixture('trainee'),pg_temp.fixture('trainer'));
insert into public.workout_plans(id,trainee_id,title) values
  (pg_temp.fixture('plan'),pg_temp.fixture('trainee'),'Test plan'),
  (pg_temp.fixture('shared_plan'),pg_temp.fixture('other'),'Shared plan');
insert into public.days(id,week,day_code,title) values
  (pg_temp.fixture('day'),1,'A','Only this plan'),
  (pg_temp.fixture('shared_day'),1,'B','Shared day');
insert into public.workout_plan_days(plan_id,day_id) values
  (pg_temp.fixture('plan'),pg_temp.fixture('day')),
  (pg_temp.fixture('plan'),pg_temp.fixture('shared_day')),
  (pg_temp.fixture('shared_plan'),pg_temp.fixture('shared_day'));
insert into public.day_exercises(id,day_id,exercise) values
  (pg_temp.fixture('exercise'),pg_temp.fixture('day'),'Test exercise'),
  (pg_temp.fixture('shared_exercise'),pg_temp.fixture('shared_day'),'Shared exercise');
insert into public.trainee_monthly_payments(trainee_id,month_start,paid)
  values (pg_temp.fixture('trainee'), (public.current_payment_month() - interval '1 month')::date, true);

set local role authenticated;
select set_config('request.jwt.claim.sub',pg_temp.fixture('trainee')::text,true);
select pg_temp.assert_true(not (public.current_account_access()->>'is_paid')::boolean,
  'last month payment must not grant current access');
select pg_temp.denied('insert into public.admins(id) values (auth.uid())');
select pg_temp.denied('insert into public.trainers(id,name) values (auth.uid(), ''Escalated'')');
select pg_temp.denied('update public.days set title = ''Changed'' where id = pg_temp.fixture(''day'')');
update public.days set completed = true, completed_at = now() where id = pg_temp.fixture('day');
select pg_temp.assert_true((select completed from public.days where id=pg_temp.fixture('day')),
  'trainee can log completion');

select set_config('request.jwt.claim.sub',pg_temp.fixture('outsider')::text,true);
select pg_temp.assert_true(not exists(select 1 from public.days where id=pg_temp.fixture('day')),
  'unassigned trainer cannot read day');
select pg_temp.denied('select public.delete_workout_plan(pg_temp.fixture(''plan''))');
select pg_temp.denied('select public.save_monthly_payment(pg_temp.fixture(''trainee''),true,10,null)');

select set_config('request.jwt.claim.sub',pg_temp.fixture('trainer')::text,true);
select pg_temp.assert_true((public.current_account_access()->>'is_trainer')::boolean,
  'trainer role works without trainee profile/payment');
insert into public.days(week,day_code,title) values (1,'C','New trainer day') returning id;
update public.days set title='Trainer edit' where id=pg_temp.fixture('day');
select pg_temp.assert_true((select title='Trainer edit' from public.days where id=pg_temp.fixture('day')),
  'assigned trainer can edit');
select public.save_monthly_payment(pg_temp.fixture('trainee'),true,50,'First note');
select pg_temp.invalid_payment(-1);
select pg_temp.invalid_payment('NaN');
select pg_temp.invalid_payment('Infinity');
reset role;
-- Seed an earlier timestamp to distinguish preservation from overwriting with now().
alter table public.trainee_monthly_payments disable trigger preserve_payment_date;
update public.trainee_monthly_payments set paid_at='2020-01-01T00:00:00Z'
  where trainee_id=pg_temp.fixture('trainee') and month_start=public.current_payment_month();
alter table public.trainee_monthly_payments enable trigger preserve_payment_date;
set local role authenticated;
select public.save_monthly_payment(pg_temp.fixture('trainee'),true,null,'Updated note');
select pg_temp.assert_true((select amount is null and notes='Updated note' and paid_at='2020-01-01T00:00:00Z'
  from public.trainee_monthly_payments where trainee_id=pg_temp.fixture('trainee')
  and month_start=public.current_payment_month()), 'note/amount edits preserve original paid_at and allow clearing');
select set_config('request.jwt.claim.sub',pg_temp.fixture('trainee')::text,true);
select pg_temp.assert_true((public.current_account_access()->>'is_paid')::boolean,'current paid grants access');
select set_config('request.jwt.claim.sub',pg_temp.fixture('trainer')::text,true);
select public.delete_workout_plan(pg_temp.fixture('plan'));
reset role;
select pg_temp.assert_true(not exists(select 1 from public.workout_plans where id=pg_temp.fixture('plan')),
  'trainer deletes assigned plan');
select pg_temp.assert_true(not exists(select 1 from public.days where id=pg_temp.fixture('day')),
  'unshared day deleted');
select pg_temp.assert_true(not exists(select 1 from public.day_exercises where id=pg_temp.fixture('exercise')),
  'unshared exercises deleted');
select pg_temp.assert_true(exists(select 1 from public.days where id=pg_temp.fixture('shared_day'))
  and exists(select 1 from public.day_exercises where id=pg_temp.fixture('shared_exercise')),
  'shared day and exercises preserved');
select pg_temp.assert_true(public.current_payment_month() = date_trunc('month',timezone('Europe/Rome',now()))::date,
  'canonical Rome payment month');
select 'All access/payment assertions passed; rolling back fixtures' as result;
rollback;

create or replace function public.keep_latest_workout_plan_active()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.status = 'active' then
    update public.workout_plans
    set status = 'inactive'
    where trainee_id = new.trainee_id
      and id <> new.id
      and status = 'active';
  end if;
  return new;
end;
$$;

revoke all on function public.keep_latest_workout_plan_active()
  from public, anon, authenticated;

create trigger keep_latest_workout_plan_active
before insert on public.workout_plans
for each row execute function public.keep_latest_workout_plan_active();

create or replace function public.delete_workout_plan(p_plan_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_trainee uuid;
  v_days uuid[];
  v_latest_plan uuid;
begin
  select trainee_id into v_trainee
  from public.workout_plans
  where id = p_plan_id
  for update;

  if v_trainee is null or auth.uid() is null or not (
    public.is_admin()
    or public.is_assigned_trainer(auth.uid(), v_trainee)
    or v_trainee = auth.uid()
  ) then
    raise exception 'Plan not found or access denied' using errcode = '42501';
  end if;

  perform d.id
  from public.days d
  join public.workout_plan_days wpd on wpd.day_id = d.id
  where wpd.plan_id = p_plan_id
  order by d.id
  for update of d;

  select array_agg(day_id) into v_days
  from public.workout_plan_days
  where plan_id = p_plan_id;

  delete from public.workout_plans where id = p_plan_id;
  delete from public.days d
  where d.id = any(coalesce(v_days, array[]::uuid[]))
    and not exists (
      select 1 from public.workout_plan_days where day_id = d.id
    );

  update public.workout_plans
  set status = 'inactive'
  where trainee_id = v_trainee;

  select id into v_latest_plan
  from public.workout_plans
  where trainee_id = v_trainee
  order by created_at desc, id desc
  limit 1;

  if v_latest_plan is not null then
    update public.workout_plans
    set status = 'active'
    where id = v_latest_plan;
  end if;
end;
$$;

revoke all on function public.delete_workout_plan(uuid) from public, anon;
grant execute on function public.delete_workout_plan(uuid) to authenticated;

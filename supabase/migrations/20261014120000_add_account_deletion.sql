-- Called only by the authenticated deletion Edge Function after file removal.
create or replace function public.delete_account_data(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_day_ids uuid[];
begin
  if p_user_id is null then
    raise exception 'User ID required';
  end if;
  select array_agg(distinct wpd.day_id) into v_day_ids
  from public.workout_plan_days wpd
  join public.workout_plans wp on wp.id = wpd.plan_id
  where wp.trainee_id = p_user_id;

  -- This legacy FK does not cascade when a trainee is removed.
  delete from public.trainee_exercise_unlocks where trainee_id = p_user_id;
  -- Cascades remove profiles, roles, assignments, feedback, payments,
  -- weight logs, max tests/private notes, plans and push tokens.
  delete from auth.users where id = p_user_id;
  -- Preserve days still shared with somebody else's plan.
  delete from public.days d
  where d.id = any(coalesce(v_day_ids, array[]::uuid[]))
    and not exists (
      select 1 from public.workout_plan_days wpd where wpd.day_id = d.id
    );
end;
$$;

revoke all on function public.delete_account_data(uuid) from public, anon, authenticated;
grant execute on function public.delete_account_data(uuid) to service_role;

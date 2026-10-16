-- Roles are granted by privileged admin RPCs, never by inserting one's own ID.
do $$ declare p record; begin
  for p in select tablename, policyname from pg_policies
    where schemaname = 'public' and tablename in ('admins', 'trainers', 'days')
  loop execute format('drop policy %I on public.%I', p.policyname, p.tablename); end loop;
end $$;
revoke all on public.admins, public.trainers from anon, authenticated;
grant select on public.admins, public.trainers to authenticated;
grant update(name) on public.trainers to authenticated;
create policy admins_read on public.admins for select to authenticated
  using (id = auth.uid() or public.is_admin());
create policy trainers_read on public.trainers for select to authenticated
  using (id = auth.uid() or public.is_admin() or public.is_assigned_trainer(id, auth.uid()));
create policy trainers_update_name on public.trainers for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

create or replace function public.current_payment_month() returns date
language sql stable set search_path = '' as $$
  select date_trunc('month', timezone('Europe/Rome', now()))::date;
$$;

create or replace function public.current_account_access() returns jsonb
language plpgsql stable security definer set search_path = public, auth as $$
declare u auth.users; trainer public.trainers; trainee public.trainees;
  v_admin boolean; v_paid boolean;
begin
  select * into u from auth.users where id = auth.uid();
  if u.id is null then raise exception 'Authentication required' using errcode = '42501'; end if;
  select * into trainer from public.trainers where id = u.id;
  select * into trainee from public.trainees where id = u.id;
  v_admin := public.is_admin(u.id);
  select coalesce(bool_or(paid), false) into v_paid from public.trainee_monthly_payments
    where trainee_id = u.id and month_start = public.current_payment_month();
  return jsonb_build_object('is_trainer', trainer.id is not null, 'is_admin', v_admin,
    'is_trainee', trainee.id is not null, 'is_paid', v_paid,
    'is_active', u.banned_until is null or u.banned_until <= now(),
    'name', coalesce(nullif(trainee.name, ''), nullif(trainer.name, ''), split_part(u.email, '@', 1)),
    'month_start', public.current_payment_month());
end $$;
revoke all on function public.current_account_access() from public, anon;
grant execute on function public.current_account_access() to authenticated;

alter table public.days add column if not exists created_by uuid default auth.uid();
create or replace function public.can_manage_day(p_day_id uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select public.is_admin() or (
    public.is_trainer() and (
      (exists (select 1 from public.workout_plan_days where day_id = p_day_id)
       and not exists (
         select 1 from public.workout_plan_days wpd join public.workout_plans wp on wp.id = wpd.plan_id
         where wpd.day_id = p_day_id and not public.is_assigned_trainer(auth.uid(), wp.trainee_id)
       )) or (
        not exists (select 1 from public.workout_plan_days where day_id = p_day_id)
        and exists (select 1 from public.days where id = p_day_id and created_by = auth.uid())
      )
    )
  );
$$;
revoke all on function public.can_manage_day(uuid) from public, anon;
grant execute on function public.can_manage_day(uuid) to authenticated;
-- Separate link lookup works during INSERT ... RETURNING, before the new day
-- is visible to a function querying days. SECURITY DEFINER sees all links,
-- including plans no longer assigned to the creator.
create or replace function public.day_has_plan(p_day_id uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.workout_plan_days where day_id = p_day_id);
$$;
revoke all on function public.day_has_plan(uuid) from public, anon;
grant execute on function public.day_has_plan(uuid) to authenticated;
revoke all on public.days from anon;
create policy days_read on public.days for select to authenticated
  using (public.can_access_day(id) or (public.is_trainer() and created_by = auth.uid()
    and not public.day_has_plan(id)));
create policy days_insert on public.days for insert to authenticated
  with check (public.is_admin() or (public.is_trainer() and created_by = auth.uid()));
create policy days_update on public.days for update to authenticated
  using (public.can_access_day(id) or public.can_manage_day(id))
  with check (public.can_access_day(id) or public.can_manage_day(id));
create policy days_delete on public.days for delete to authenticated using (public.can_manage_day(id));

-- Trainees may log completion, but may not rewrite the trainer's day content.
create or replace function public.guard_day_content() returns trigger
language plpgsql set search_path = public as $$
begin
  if current_user in ('postgres', 'service_role', 'supabase_admin') then return new; end if;
  if not public.can_manage_day(old.id) and
    (to_jsonb(new) - 'completed' - 'completed_at') is distinct from
    (to_jsonb(old) - 'completed' - 'completed_at') then
    raise exception 'Only assigned trainers can edit day content' using errcode = '42501';
  end if;
  return new;
end $$;
create trigger guard_day_content before update on public.days
  for each row execute function public.guard_day_content();

create or replace function public.delete_workout_plan(p_plan_id uuid) returns void
language plpgsql security definer set search_path = public as $$
declare v_trainee uuid; v_days uuid[];
begin
  select trainee_id into v_trainee from public.workout_plans where id = p_plan_id for update;
  if v_trainee is null or auth.uid() is null or not (
    public.is_admin() or public.is_assigned_trainer(auth.uid(), v_trainee) or v_trainee = auth.uid()
  ) then raise exception 'Plan not found or access denied' using errcode = '42501'; end if;
  perform d.id from public.days d join public.workout_plan_days wpd on wpd.day_id = d.id
    where wpd.plan_id = p_plan_id order by d.id for update of d;
  select array_agg(day_id) into v_days from public.workout_plan_days where plan_id = p_plan_id;
  delete from public.workout_plans where id = p_plan_id;
  delete from public.days d where d.id = any(coalesce(v_days, array[]::uuid[]))
    and not exists (select 1 from public.workout_plan_days where day_id = d.id);
end $$;
revoke all on function public.delete_workout_plan(uuid) from public, anon;
grant execute on function public.delete_workout_plan(uuid) to authenticated;

create or replace function public.preserve_payment_date() returns trigger
language plpgsql set search_path = public as $$
begin
  if not new.paid then new.paid_at := null;
  elsif tg_op = 'UPDATE' then
    new.paid_at := case when old.paid then coalesce(old.paid_at, now()) else now() end;
  else new.paid_at := coalesce(new.paid_at, now()); end if;
  return new;
end $$;
create trigger preserve_payment_date before insert or update on public.trainee_monthly_payments
  for each row execute function public.preserve_payment_date();
alter table public.trainee_monthly_payments add constraint payment_amount_valid
  check (amount is null or (amount >= 0 and amount::text not in ('NaN', 'Infinity', '-Infinity'))) not valid;

create or replace function public.save_monthly_payment(
  p_trainee_id uuid, p_paid boolean, p_amount numeric, p_notes text
) returns uuid language plpgsql security definer set search_path = public as $$
declare v_id uuid;
begin
  if auth.uid() is null or not (public.is_admin() or public.is_assigned_trainer(auth.uid(), p_trainee_id)) then
    raise exception 'Trainer access required' using errcode = '42501';
  end if;
  if p_paid is null or (p_amount is not null and (p_amount < 0 or p_amount::text in ('NaN','Infinity','-Infinity')))
    or length(coalesce(p_notes, '')) > 2000 then raise exception 'Invalid payment'; end if;
  insert into public.trainee_monthly_payments (trainee_id, month_start, paid, amount, notes)
    values (p_trainee_id, public.current_payment_month(), p_paid, p_amount, nullif(btrim(p_notes), ''))
    on conflict (trainee_id, month_start) do update set paid = excluded.paid,
      amount = excluded.amount, notes = excluded.notes
    returning id into v_id;
  return v_id;
end $$;
revoke all on function public.save_monthly_payment(uuid, boolean, numeric, text) from public, anon;
grant execute on function public.save_monthly_payment(uuid, boolean, numeric, text) to authenticated;

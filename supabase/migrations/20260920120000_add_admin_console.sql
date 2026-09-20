create or replace function public.admin_list_users()
returns table (
  user_id uuid,
  email text,
  name text,
  is_trainee boolean,
  is_trainer boolean,
  is_admin boolean,
  is_suspended boolean,
  created_at timestamptz
)
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  if not public.is_admin() then
    raise exception 'Administrator access required' using errcode = '42501';
  end if;

  return query
  select
    u.id,
    coalesce(u.email, ''),
    coalesce(nullif(trim(tr.name), ''), nullif(trim(te.name), ''), split_part(coalesce(u.email, ''), '@', 1), 'User'),
    te.id is not null,
    tr.id is not null,
    ad.user_id is not null,
    u.banned_until is not null and u.banned_until > now(),
    u.created_at
  from auth.users u
  left join public.trainees te on te.id = u.id
  left join public.trainers tr on tr.id = u.id
  left join public.admins ad on ad.id = u.id
  order by u.created_at desc;
end;
$$;

create or replace function public.admin_set_trainer(
  p_user_id uuid,
  p_enabled boolean,
  p_name text default null
)
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_name text;
begin
  if not public.is_admin() then
    raise exception 'Administrator access required' using errcode = '42501';
  end if;
  if not exists (select 1 from auth.users where id = p_user_id) then
    raise exception 'User not found';
  end if;

  if p_enabled then
    select coalesce(
      nullif(trim(p_name), ''),
      (select nullif(trim(name), '') from public.trainees where id = p_user_id),
      (select split_part(coalesce(email, ''), '@', 1) from auth.users where id = p_user_id),
      'Trainer'
    ) into v_name;
    insert into public.trainers (id, name)
    values (p_user_id, v_name)
    on conflict (id) do update set name = excluded.name;
  else
    delete from public.trainers where id = p_user_id;
  end if;
end;
$$;

create or replace function public.admin_set_user_suspended(
  p_user_id uuid,
  p_suspended boolean
)
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  if not public.is_admin() then
    raise exception 'Administrator access required' using errcode = '42501';
  end if;
  if p_user_id = auth.uid() then
    raise exception 'You cannot suspend your own account';
  end if;
  if not exists (select 1 from auth.users where id = p_user_id) then
    raise exception 'User not found';
  end if;

  update auth.users
  set banned_until = case
    when p_suspended then now() + interval '100 years'
    else null
  end,
  updated_at = now()
  where id = p_user_id;
end;
$$;

create or replace function public.admin_list_assignments()
returns table (
  trainee_id uuid,
  trainee_name text,
  trainer_id uuid,
  trainer_name text
)
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Administrator access required' using errcode = '42501';
  end if;

  return query
  select
    tt.trainee_id,
    coalesce(nullif(trim(te.name), ''), 'Trainee'),
    tt.trainer_id,
    coalesce(nullif(trim(tr.name), ''), 'Trainer')
  from public.trainee_trainers tt
  join public.trainees te on te.id = tt.trainee_id
  join public.trainers tr on tr.id = tt.trainer_id
  order by tr.name, te.name;
end;
$$;

create or replace function public.admin_set_assignment(
  p_trainee_id uuid,
  p_trainer_id uuid,
  p_assigned boolean
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Administrator access required' using errcode = '42501';
  end if;
  if not exists (select 1 from public.trainees where id = p_trainee_id) then
    raise exception 'Trainee not found';
  end if;
  if not exists (select 1 from public.trainers where id = p_trainer_id) then
    raise exception 'Trainer not found';
  end if;

  if p_assigned then
    insert into public.trainee_trainers (trainee_id, trainer_id)
    values (p_trainee_id, p_trainer_id)
    on conflict (trainee_id, trainer_id) do nothing;
  else
    delete from public.trainee_trainers
    where trainee_id = p_trainee_id and trainer_id = p_trainer_id;
  end if;
end;
$$;

revoke all on function public.admin_list_users() from public;
revoke all on function public.admin_set_trainer(uuid, boolean, text) from public;
revoke all on function public.admin_set_user_suspended(uuid, boolean) from public;
revoke all on function public.admin_list_assignments() from public;
revoke all on function public.admin_set_assignment(uuid, uuid, boolean) from public;

grant execute on function public.admin_list_users() to authenticated;
grant execute on function public.admin_set_trainer(uuid, boolean, text) to authenticated;
grant execute on function public.admin_set_user_suspended(uuid, boolean) to authenticated;
grant execute on function public.admin_list_assignments() to authenticated;
grant execute on function public.admin_set_assignment(uuid, uuid, boolean) to authenticated;

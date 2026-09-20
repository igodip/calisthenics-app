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
    coalesce(u.email, '')::text,
    coalesce(nullif(trim(tr.name), ''), nullif(trim(te.name), ''), split_part(coalesce(u.email, ''), '@', 1), 'User'),
    te.id is not null,
    tr.id is not null,
    ad.id is not null,
    u.banned_until is not null and u.banned_until > now(),
    u.created_at
  from auth.users u
  left join public.trainees te on te.id = u.id
  left join public.trainers tr on tr.id = u.id
  left join public.admins ad on ad.id = u.id
  order by u.created_at desc;
end;
$$;

revoke all on function public.admin_list_users() from public;
grant execute on function public.admin_list_users() to authenticated;

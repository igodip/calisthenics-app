-- Disposable development/test database only. All fixture changes roll back.
begin;
create temporary table tutorial_fixture (label text primary key, id uuid default gen_random_uuid());
insert into tutorial_fixture(label) values ('owner'), ('other');
grant select on tutorial_fixture to authenticated;
insert into auth.users(id, email, created_at, updated_at)
  select id, id::text || '@example.invalid', now(), now() from tutorial_fixture;
set local role authenticated;
select set_config('request.jwt.claim.sub', (select id::text from tutorial_fixture where label='owner'), true);
insert into public.account_tutorials(user_id, skipped) values (auth.uid(), true);
insert into public.account_tutorials(user_id, skipped) values (auth.uid(), false)
  on conflict (user_id) do nothing;
do $$ begin
  if not (select skipped from public.account_tutorials where user_id=auth.uid()) then
    raise exception 'Duplicate completion must preserve the original receipt';
  end if;
  begin
    insert into public.account_tutorials(user_id)
      select id from tutorial_fixture where label='other';
    raise exception 'Cross-account completion unexpectedly allowed';
  exception when insufficient_privilege then null; end;
  begin
    update public.account_tutorials set skipped=false;
    raise exception 'Receipt updates unexpectedly allowed';
  exception when insufficient_privilege then null; end;
  begin
    delete from public.account_tutorials;
    raise exception 'Receipt deletion unexpectedly allowed';
  exception when insufficient_privilege then null; end;
end $$;
select set_config('request.jwt.claim.sub', (select id::text from tutorial_fixture where label='other'), true);
do $$ begin
  if exists (select 1 from public.account_tutorials) then
    raise exception 'Another account can read completion receipts';
  end if;
end $$;
reset role;
delete from auth.users where id=(select id from tutorial_fixture where label='owner');
do $$ begin
  if exists (select 1 from public.account_tutorials where user_id in (select id from tutorial_fixture)) then
    raise exception 'Account deletion did not remove tutorial receipt';
  end if;
end $$;
rollback;

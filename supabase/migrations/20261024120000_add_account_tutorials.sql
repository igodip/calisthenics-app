-- One completion receipt per authenticated account, independent of roles/payment.
begin;
create table if not exists public.account_tutorials (
  user_id uuid primary key references auth.users(id) on delete cascade,
  completed_at timestamptz not null default now(),
  skipped boolean not null default false
);
alter table public.account_tutorials enable row level security;
alter table public.account_tutorials force row level security;
revoke all on public.account_tutorials from anon, authenticated;
grant select, insert on public.account_tutorials to authenticated;
grant all on public.account_tutorials to service_role;
drop policy if exists account_tutorials_read_own on public.account_tutorials;
drop policy if exists account_tutorials_insert_own on public.account_tutorials;
create policy account_tutorials_read_own on public.account_tutorials
  for select to authenticated using (user_id = auth.uid());
create policy account_tutorials_insert_own on public.account_tutorials
  for insert to authenticated with check (user_id = auth.uid());
comment on table public.account_tutorials is
  'First post-login tutorial completion/skip receipt; account owner only.';
commit;

alter table public.workout_plans
  add column if not exists pdf_storage_path text;

alter table public.workout_plans
  drop constraint if exists workout_plans_pdf_storage_path_matches_plan;
alter table public.workout_plans
  add constraint workout_plans_pdf_storage_path_matches_plan
  check (
    pdf_storage_path is null
    or pdf_storage_path = trainee_id::text || '/' || id::text || '.pdf'
  );

insert into storage.buckets (
  id, name, public, file_size_limit, allowed_mime_types
) values (
  'workout-plan-pdfs', 'workout-plan-pdfs', false, 26214400,
  array['application/pdf']::text[]
)
on conflict (id) do update set
  name = excluded.name,
  public = false,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists workout_plan_pdfs_read on storage.objects;
create policy workout_plan_pdfs_read
  on storage.objects for select to authenticated
  using (
    bucket_id = 'workout-plan-pdfs'
    and exists (
      select 1
      from public.workout_plans wp
      where name = wp.trainee_id::text || '/' || wp.id::text || '.pdf'
        and wp.pdf_storage_path = name
        and (
          wp.trainee_id = auth.uid()
          or public.is_assigned_trainer(auth.uid(), wp.trainee_id)
          or public.is_admin()
        )
    )
  );

drop policy if exists workout_plan_pdfs_upload on storage.objects;
create policy workout_plan_pdfs_upload
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'workout-plan-pdfs'
    and exists (
      select 1
      from public.workout_plans wp
      where name = wp.trainee_id::text || '/' || wp.id::text || '.pdf'
        and wp.pdf_storage_path = name
        and (
          public.is_assigned_trainer(auth.uid(), wp.trainee_id)
          or public.is_admin()
        )
    )
  );

drop policy if exists workout_plan_pdfs_delete on storage.objects;
create policy workout_plan_pdfs_delete
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'workout-plan-pdfs'
    and exists (
      select 1
      from public.workout_plans wp
      where name = wp.trainee_id::text || '/' || wp.id::text || '.pdf'
        and wp.pdf_storage_path = name
        and (
          public.is_assigned_trainer(auth.uid(), wp.trainee_id)
          or public.is_admin()
        )
    )
  );

create or replace function public.set_workout_plan_pdf_path(
  p_plan_id uuid,
  p_pdf_path text
) returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_trainee_id uuid;
begin
  select trainee_id into v_trainee_id
  from public.workout_plans
  where id = p_plan_id
  for update;

  if v_trainee_id is null or auth.uid() is null or not (
    public.is_admin()
    or public.is_assigned_trainer(auth.uid(), v_trainee_id)
  ) then
    raise exception 'Plan not found or access denied' using errcode = '42501';
  end if;

  if p_pdf_path is distinct from
    v_trainee_id::text || '/' || p_plan_id::text || '.pdf' then
    raise exception 'Invalid workout PDF path';
  end if;

  update public.workout_plans
  set pdf_storage_path = p_pdf_path
  where id = p_plan_id;
end;
$$;

revoke all on function public.set_workout_plan_pdf_path(uuid, text)
  from public, anon;
grant execute on function public.set_workout_plan_pdf_path(uuid, text)
  to authenticated;

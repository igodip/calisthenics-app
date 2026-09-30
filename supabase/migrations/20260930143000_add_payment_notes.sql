alter table public.trainee_monthly_payments
  add column if not exists notes text;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.trainee_monthly_payments'::regclass
      and conname = 'trainee_monthly_payments_notes_length_check'
  ) then
    alter table public.trainee_monthly_payments
      add constraint trainee_monthly_payments_notes_length_check
      check (notes is null or char_length(notes) <= 2000);
  end if;
end
$$;

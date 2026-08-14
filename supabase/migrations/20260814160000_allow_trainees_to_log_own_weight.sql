drop policy if exists trainee_weight_logs_insert_self
on public.trainee_weight_logs;

create policy trainee_weight_logs_insert_self
on public.trainee_weight_logs
for insert
to authenticated
with check (auth.uid() = trainee_id);

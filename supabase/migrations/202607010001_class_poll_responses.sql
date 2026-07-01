-- Structured class polling for the five-chart dashboard.

create table public.class_poll_responses (
  id uuid primary key default gen_random_uuid(),
  submitted_by uuid not null references public.profiles(user_id) on delete cascade,
  respondent_name text not null check (char_length(trim(respondent_name)) between 1 and 80),
  weight_kg numeric(5, 2) not null check (weight_kg between 30 and 180),
  height_cm numeric(5, 2) not null check (height_cm between 120 and 220),
  shirt_size text not null check (shirt_size in ('S', 'M', 'L', 'XL')),
  shoe_size numeric(4, 1) not null check (shoe_size between 30 and 50),
  blood_type text not null check (blood_type in ('A', 'B', 'AB', 'O')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index class_poll_responses_created_at_idx
on public.class_poll_responses (created_at);

create trigger class_poll_responses_set_updated_at
before update on public.class_poll_responses
for each row execute function public.set_updated_at();

alter table public.class_poll_responses enable row level security;

create policy "polling users read class responses"
on public.class_poll_responses
for select to authenticated
using (public.has_feature('polling'));

create policy "polling users add class responses"
on public.class_poll_responses
for insert to authenticated
with check (
  submitted_by = auth.uid() and public.has_feature('polling')
);

create policy "admins update class responses"
on public.class_poll_responses
for update to authenticated
using (public.has_feature('access_control'))
with check (public.has_feature('access_control'));

create policy "admins delete class responses"
on public.class_poll_responses
for delete to authenticated
using (public.has_feature('access_control'));

alter publication supabase_realtime add table public.class_poll_responses;

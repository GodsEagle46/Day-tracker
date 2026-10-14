-- Successful Day Tracker: run this once in Supabase (SQL Editor > New query > Run).

-- Each person's plan: roles, weekly schedule, days off, start and end dates.
create table if not exists public.plans (
  user_id    uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  data       jsonb not null,
  updated_at timestamptz not null default now()
);

-- One row per person per day: ticked slots, reflection, carry-over notes.
create table if not exists public.days (
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  day        date not null,
  done       jsonb not null default '{}'::jsonb,
  reflection text not null default '',
  notes      text not null default '',
  updated_at timestamptz not null default now(),
  primary key (user_id, day)
);

-- Row-level security: people can only see and change their own rows.
alter table public.plans enable row level security;
alter table public.days  enable row level security;

drop policy if exists "own plan" on public.plans;
create policy "own plan" on public.plans
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "own days" on public.days;
create policy "own days" on public.days
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

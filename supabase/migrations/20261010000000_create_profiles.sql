-- Applied to Supabase project fbzcrdorydkqixohebvs (OPCC) as migration "create_profiles".
-- One profile per signed-in user.
create table public.profiles (
  id           uuid primary key references auth.users (id) on delete cascade,
  full_name    text not null check (char_length(btrim(full_name)) between 1 and 100),
  address      text not null check (char_length(btrim(address)) between 1 and 300),
  email        text not null check (char_length(email) <= 254 and email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  intended_use text not null check (intended_use in (
                 'personal', 'content_creation', 'music_production',
                 'education', 'business', 'other')),
  use_details  text check (use_details is null or char_length(use_details) <= 500),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

comment on table public.profiles is 'User profile collected after email sign-in.';

-- Keep updated_at current on every edit.
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

-- Row Level Security: users can only see and change their own profile.
alter table public.profiles enable row level security;

create policy "Users can view their own profile"
  on public.profiles for select to authenticated
  using ((select auth.uid()) = id);

create policy "Users can create their own profile"
  on public.profiles for insert to authenticated
  with check ((select auth.uid()) = id);

create policy "Users can update their own profile"
  on public.profiles for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- Only signed-in users may touch the table; no deletes from the app.
revoke all on public.profiles from anon, authenticated;
grant select, insert, update on public.profiles to authenticated;

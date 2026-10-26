create table if not exists public."user" (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text check (char_length(full_name) <= 200),
  mobile_number text check (char_length(mobile_number) <= 20),
  email text,
  delivery_address text check (char_length(delivery_address) <= 500),
  created_at timestamptz not null default now()
);

alter table public."user"
  add column if not exists full_name text,
  add column if not exists mobile_number text,
  add column if not exists email text,
  add column if not exists delivery_address text,
  add column if not exists created_at timestamptz not null default now();

do $$
begin
  if not exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'user'
      and column_name = 'id'
      and data_type = 'uuid'
  ) then
    raise exception
      'public."user" has no uuid "id" column. Review the existing table before linking it to auth.users.';
  end if;
end;
$$;


alter table public."user" enable row level security;

revoke all on table public."user" from anon, authenticated;
grant select on table public."user" to authenticated;
grant update (full_name, mobile_number, delivery_address)
  on table public."user" to authenticated;

create policy "Users can view their own profile"
  on public."user"
  for select
  to authenticated
  using ((select auth.uid()) = id);

create policy "Users can update their own profile"
  on public."user"
  for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);


create or replace function public.create_user_profile_for_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public."user" (id, full_name, mobile_number, email, delivery_address)
  values (
    new.id,
    nullif(btrim(new.raw_user_meta_data ->> 'full_name'), ''),
    nullif(btrim(new.raw_user_meta_data ->> 'mobile_number'), ''),
    new.email,
    nullif(btrim(new.raw_user_meta_data ->> 'delivery_address'), '')
  );

  return new;
end;
$$;

create trigger create_user_profile_after_signup
  after insert on auth.users
  for each row
  execute function public.create_user_profile_for_new_auth_user();

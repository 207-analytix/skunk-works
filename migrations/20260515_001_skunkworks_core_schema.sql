-- Migration: 20260515_001_skunkworks_core_schema
-- Applied: 2026-05-15
-- Description: Create core public schema tables for Skunk Works
--   profiles, customers, engagements, tasks
--   RLS enabled on all tables

-- PROFILES
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  display_name text,
  role text not null check (role in (
    'admin',
    'sales_agent',
    'operator_agent',
    'analyst_agent',
    'delivery_agent',
    'client',
    'viewer'
  )),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Authenticated users can view all profiles"
  on public.profiles for select
  to authenticated
  using (true);

-- CUSTOMERS
create table if not exists public.customers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  contact_email text,
  status text not null default 'active' check (status in ('active','inactive','prospect','churned')),
  source text check (source in ('inbound','referral','outbound','event','other')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.customers enable row level security;

create policy "Authenticated users can read customers"
  on public.customers for select
  to authenticated
  using (true);

create policy "Authenticated users can insert customers"
  on public.customers for insert
  to authenticated
  with check (true);

create policy "Authenticated users can update customers"
  on public.customers for update
  to authenticated
  using (true);

-- ENGAGEMENTS
create table if not exists public.engagements (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.customers(id) on delete cascade,
  product_type text not null check (product_type in (
    'analytics_starter',
    'analytics_pro',
    'analytics_enterprise',
    'data_engineering',
    'fractional_analytics'
  )),
  stage text not null default 'intake' check (stage in (
    'intake','scoping','proposal','active','review','complete','closed'
  )),
  revenue numeric(12,2),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.engagements enable row level security;

create policy "Authenticated users can read engagements"
  on public.engagements for select
  to authenticated
  using (true);

create policy "Authenticated users can insert engagements"
  on public.engagements for insert
  to authenticated
  with check (true);

create policy "Authenticated users can update engagements"
  on public.engagements for update
  to authenticated
  using (true);

-- TASKS
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  type text not null,
  assigned_to uuid references public.profiles(id),
  customer_id uuid references public.customers(id),
  engagement_id uuid references public.engagements(id),
  status text not null default 'open' check (status in ('open','in_progress','blocked','done')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.tasks enable row level security;

create policy "Authenticated users can read tasks"
  on public.tasks for select
  to authenticated
  using (true);

create policy "Authenticated users can insert tasks"
  on public.tasks for insert
  to authenticated
  with check (true);

create policy "Authenticated users can update tasks"
  on public.tasks for update
  to authenticated
  using (true);

-- TRIGGER: updated_at
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger set_customers_updated_at
  before update on public.customers
  for each row execute function public.set_updated_at();

create trigger set_engagements_updated_at
  before update on public.engagements
  for each row execute function public.set_updated_at();

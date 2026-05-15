-- Migration: 20260515_002_update_profiles_role_constraint
-- Applied: 2026-05-15
-- Purpose: Replace initial role constraint with canonical 7-role set
-- DO NOT re-run — already applied to production

ALTER TABLE public.profiles DROP CONSTRAINT profiles_role_check;
ALTER TABLE public.profiles ADD CONSTRAINT profiles_role_check
  CHECK (role = ANY (ARRAY[
    'admin',
    'sales_agent',
    'operator_agent',
    'analyst_agent',
    'delivery_agent',
    'client',
    'viewer'
  ]));

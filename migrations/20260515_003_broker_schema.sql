-- Migration: 20260515_003_broker_schema
-- Applied: 2026-05-15
-- Purpose: Create broker schema with credentials table and RLS
-- DO NOT re-run — already applied to production

CREATE SCHEMA IF NOT EXISTS broker;

-- Credentials registry (secrets live in Vault, referenced here)
CREATE TABLE broker.credentials (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name            text NOT NULL UNIQUE,
  description     text,
  vault_secret_id uuid NOT NULL,           -- references vault.secrets.id
  required_role   text NOT NULL,           -- minimum role required to access
  scope           text NOT NULL,           -- e.g. 'read', 'write', 'admin'
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE broker.credentials
  ADD CONSTRAINT credentials_required_role_check
  CHECK (required_role = ANY (ARRAY[
    'admin',
    'sales_agent',
    'operator_agent',
    'analyst_agent',
    'delivery_agent',
    'client',
    'viewer'
  ]));

ALTER TABLE broker.credentials ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admins_full_access" ON broker.credentials
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role = 'admin'
    )
  );

CREATE POLICY "role_based_read" ON broker.credentials
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
      AND role = broker.credentials.required_role
    )
  );

CREATE OR REPLACE FUNCTION broker.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON broker.credentials
  FOR EACH ROW EXECUTE FUNCTION broker.set_updated_at();

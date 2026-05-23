#!/usr/bin/env bash
# Seed local PostgreSQL with Joliet Jaguars test org, team, roster, and users.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

SEED_SQL="${ROOT_DIR}/scripts/seed/seed.sql"
DATABASE_HOST="${DATABASE_HOST:-localhost}"
DATABASE_PORT="${DATABASE_PORT:-54322}"
DATABASE_USER="${DATABASE_USER:-postgres}"
DATABASE_NAME="${DATABASE_NAME:-postgres}"

db_exec() {
  if command -v psql >/dev/null 2>&1; then
    PGPASSWORD="${PGPASSWORD:-postgres}" psql -h "$DATABASE_HOST" -p "$DATABASE_PORT" -U "$DATABASE_USER" -d "$DATABASE_NAME" "$@"
  else
    docker compose exec -T db psql -U "$DATABASE_USER" -d "$DATABASE_NAME" "$@"
  fi
}

echo "=== Seeding test data ==="

if ! docker compose ps --status running db >/dev/null 2>&1 && ! command -v psql >/dev/null 2>&1; then
  echo "ERROR: Database is not running. Start with: make dev"
  exit 1
fi

echo "Ensuring auth schema and test users..."
db_exec -v ON_ERROR_STOP=1 <<'SQL'
CREATE SCHEMA IF NOT EXISTS auth;

CREATE TABLE IF NOT EXISTS auth.users (
  id                 uuid PRIMARY KEY,
  email              text UNIQUE,
  encrypted_password text,
  created_at         timestamptz DEFAULT now(),
  updated_at         timestamptz DEFAULT now()
);

INSERT INTO auth.users (id, email, encrypted_password) VALUES
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'admin@jolietjaguars.org',  '$dev'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'coach@jolietjaguars.org',  '$dev'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'parent@jolietjaguars.org', '$dev'),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'viewer@jolietjaguars.org', '$dev')
ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email;

-- Stub Supabase auth helpers for plain PostgreSQL (RLS policies reference these)
CREATE OR REPLACE FUNCTION auth.uid()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(
    NULLIF(current_setting('request.jwt.claim.sub', true), '')::uuid,
    '00000000-0000-0000-0000-000000000000'::uuid
  );
$$;

CREATE OR REPLACE FUNCTION auth.role()
RETURNS text
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(NULLIF(current_setting('request.jwt.claim.role', true), ''), 'anon');
$$;
SQL

echo "Applying migrations..."
make db-migrate

echo "Loading seed SQL..."
if command -v psql >/dev/null 2>&1; then
  PGPASSWORD="${PGPASSWORD:-postgres}" psql -h "$DATABASE_HOST" -p "$DATABASE_PORT" -U "$DATABASE_USER" -d "$DATABASE_NAME" -v ON_ERROR_STOP=1 -f "$SEED_SQL"
else
  docker compose exec -T db psql -U "$DATABASE_USER" -d "$DATABASE_NAME" -v ON_ERROR_STOP=1 -f - < "$SEED_SQL"
fi

echo ""
echo "Seed complete. Test accounts (password: password123):"
echo "  admin@jolietjaguars.org   — org admin"
echo "  coach@jolietjaguars.org   — team admin (coach)"
echo "  parent@jolietjaguars.org  — parent / guardian"
echo "  viewer@jolietjaguars.org  — read-only viewer"
echo ""
echo "Set DEV_AUTH_ENABLED=true in .env for local login without Supabase."

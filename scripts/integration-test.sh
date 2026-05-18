#!/usr/bin/env bash
# Platform integration tests — verifies the full local stack (DB + API + frontend).
# Prerequisites: services running (make dev) and migrations applied (make db-migrate).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

BACKEND_URL="${BACKEND_URL:-${API_URL:-http://localhost:8080}}"
FRONTEND_URL="${FRONTEND_URL:-http://localhost:3000}"
DATABASE_HOST="${DATABASE_HOST:-localhost}"
DATABASE_PORT="${DATABASE_PORT:-54322}"
DATABASE_USER="${DATABASE_USER:-postgres}"
DATABASE_NAME="${DATABASE_NAME:-postgres}"

BACKEND_URL="${BACKEND_URL%/}"
FRONTEND_URL="${FRONTEND_URL%/}"

PASS=0
FAIL=0
RESULTS=()

record() {
  local ok="$1" name="$2" detail="$3"
  if [ "$ok" = true ]; then
    RESULTS+=("PASS | $name | $detail")
    PASS=$((PASS + 1))
  else
    RESULTS+=("FAIL | $name | $detail")
    FAIL=$((FAIL + 1))
  fi
}

check_http() {
  local name="$1" method="$2" url="$3" expect_status="$4"
  shift 4
  local expect_body="${1:-}"
  local extra_header="${2:-}"

  local curl_args=(-s -o /tmp/zice_integration_body -w '%{http_code}' -X "$method")
  [ -n "$extra_header" ] && curl_args+=(-H "$extra_header")

  local status
  status=$(curl "${curl_args[@]}" "$url" 2>/dev/null) || status="000"

  local ok=true
  if [[ "$expect_status" == *","* ]]; then
    local found=false
    IFS=',' read -ra codes <<< "$expect_status"
    for code in "${codes[@]}"; do
      [ "$status" = "$code" ] && found=true
    done
    $found || ok=false
  else
    [ "$status" = "$expect_status" ] || ok=false
  fi

  if [ -n "$expect_body" ] && $ok; then
    grep -q "$expect_body" /tmp/zice_integration_body 2>/dev/null || ok=false
  fi

  record "$ok" "$name" "HTTP $status (expected $expect_status)"
}

echo "=== Zice Platform Integration Tests ==="
echo "Database: ${DATABASE_HOST}:${DATABASE_PORT}"
echo "Backend:  $BACKEND_URL"
echo "Frontend: $FRONTEND_URL"
echo ""

# --- Database ---
db_exec() {
  if command -v psql >/dev/null 2>&1; then
    PGPASSWORD="${PGPASSWORD:-postgres}" psql -h "$DATABASE_HOST" -p "$DATABASE_PORT" -U "$DATABASE_USER" -d "$DATABASE_NAME" "$@"
  elif docker compose ps --status running db >/dev/null 2>&1; then
    docker compose exec -T db psql -U "$DATABASE_USER" -d "$DATABASE_NAME" "$@"
  else
    return 127
  fi
}

if command -v pg_isready >/dev/null 2>&1; then
  if pg_isready -h "$DATABASE_HOST" -p "$DATABASE_PORT" -U "$DATABASE_USER" >/dev/null 2>&1; then
    record true "PostgreSQL reachable" "pg_isready OK"
  else
    record false "PostgreSQL reachable" "pg_isready failed"
  fi
elif docker compose ps --status running db >/dev/null 2>&1; then
  if docker compose exec -T db pg_isready -U "$DATABASE_USER" >/dev/null 2>&1; then
    record true "PostgreSQL reachable" "docker compose db healthy"
  else
    record false "PostgreSQL reachable" "docker compose db not ready"
  fi
else
  record false "PostgreSQL reachable" "database not running (make dev)"
fi

if db_exec -tAc "SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='organizations' LIMIT 1" 2>/dev/null | grep -q 1; then
  record true "Database schema" "public.organizations exists"
else
  record false "Database schema" "public.organizations not found (run make db-migrate)"
fi

# --- Backend API ---
check_http "Backend health" GET "${BACKEND_URL}/api/v1/health" "200" '"status"'
check_http "Auth guard (no token)" GET "${BACKEND_URL}/api/v1/players" "401" ""
check_http "Tenant resolve (unknown)" GET "${BACKEND_URL}/api/v1/tenants/resolve?domain=unknown.example" "404" ""

curl -s -o /tmp/zice_integration_cors_body -D /tmp/zice_integration_cors_headers \
  -X OPTIONS \
  -H "Origin: ${FRONTEND_URL}" \
  -H "Access-Control-Request-Method: GET" \
  "${BACKEND_URL}/api/v1/health" 2>/dev/null || true

if grep -qi "access-control-allow-origin" /tmp/zice_integration_cors_headers 2>/dev/null; then
  record true "CORS (frontend origin)" "Access-Control-Allow-Origin present for ${FRONTEND_URL}"
else
  record false "CORS (frontend origin)" "missing Access-Control-Allow-Origin for ${FRONTEND_URL}"
fi

# --- Frontend ---
check_http "Frontend home" GET "${FRONTEND_URL}/" "200,307,308"
check_http "Frontend login" GET "${FRONTEND_URL}/login" "200,307,308"

# --- Configuration wiring ---
if [ -n "${NEXT_PUBLIC_API_URL:-}" ]; then
  normalized_api="${NEXT_PUBLIC_API_URL%/}"
  if [ "$normalized_api" = "$BACKEND_URL" ]; then
    record true "Env: NEXT_PUBLIC_API_URL" "matches backend ($BACKEND_URL)"
  else
    record false "Env: NEXT_PUBLIC_API_URL" "expected $BACKEND_URL, got $normalized_api"
  fi
else
  record false "Env: NEXT_PUBLIC_API_URL" "not set in environment"
fi

if [ -n "${SUPABASE_JWT_SECRET:-}" ]; then
  record true "Env: SUPABASE_JWT_SECRET" "set"
else
  record false "Env: SUPABASE_JWT_SECRET" "not set (backend will not start)"
fi

# --- Summary ---
echo "-------------------------------------------"
printf "%-6s | %-32s | %s\n" "Result" "Test" "Detail"
echo "-------------------------------------------"
for r in "${RESULTS[@]}"; do
  IFS='|' read -r result test detail <<< "$r"
  printf "%-6s |%-32s |%s\n" "$result" "$test" "$detail"
done
echo "-------------------------------------------"
echo "Total: $((PASS + FAIL)) | Passed: $PASS | Failed: $FAIL"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "INTEGRATION TESTS FAILED"
  echo "Tip: make dev && make db-migrate, or run make integration-ci for a full bootstrap."
  exit 1
fi

echo "ALL INTEGRATION TESTS PASSED"

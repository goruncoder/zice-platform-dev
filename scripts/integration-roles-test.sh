#!/usr/bin/env bash
# Role-based integration tests — login as each test user and verify API access.
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
BACKEND_URL="${BACKEND_URL%/}"
TEST_USERS="${ROOT_DIR}/scripts/seed/test-users.json"
PASSWORD="${TEST_PASSWORD:-password123}"

IFS='|' read -r ORG_ID ORG_SLUG TEAM SEASON < <(python3 -c "import json; d=json.load(open('$TEST_USERS')); print(f\"{d['organization']['id']}|{d['organization']['slug']}|{d['team']['designation']}|{d['team']['season']}\")")
TENANT_HEADER="x-org-slug: ${ORG_SLUG}"

PASS=0
FAIL=0
RESULTS=()

record() {
  local ok="$1" persona="$2" step="$3" detail="$4"
  if [ "$ok" = true ]; then
    RESULTS+=("PASS | $persona | $step | $detail")
    PASS=$((PASS + 1))
  else
    RESULTS+=("FAIL | $persona | $step | $detail")
    FAIL=$((FAIL + 1))
  fi
}

login() {
  local email="$1" password="$2"
  curl -s -o /tmp/zice_role_login.json -w '%{http_code}' \
    -X POST "${BACKEND_URL}/api/v1/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"${email}\",\"password\":\"${password}\"}"
}

extract_token() {
  python3 -c "import json; d=json.load(open('/tmp/zice_role_login.json')); print(d['data']['access_token'])" 2>/dev/null
}

api() {
  local method="$1" path="$2" token="$3"
  local extra_header="${4:-}"
  local curl_args=(-s -o /tmp/zice_role_api.json -w '%{http_code}' -X "$method")
  curl_args+=(-H "Authorization: Bearer ${token}")
  [ -n "$extra_header" ] && curl_args+=(-H "$extra_header")
  curl "${curl_args[@]}" "${BACKEND_URL}${path}" 2>/dev/null || echo "000"
}

api_post_json() {
  local path="$1" token="$2" body="$3" extra_header="${4:-}"
  local curl_args=(-s -o /tmp/zice_role_api.json -w '%{http_code}' -X POST)
  curl_args+=(-H "Authorization: Bearer ${token}" -H "Content-Type: application/json")
  [ -n "$extra_header" ] && curl_args+=(-H "$extra_header")
  curl "${curl_args[@]}" -d "$body" "${BACKEND_URL}${path}" 2>/dev/null || echo "000"
}

expect_status() {
  local got="$1" expected="$2"
  if [[ "$expected" == *","* ]]; then
    IFS=',' read -ra codes <<< "$expected"
    for code in "${codes[@]}"; do
      [ "$got" = "$code" ] && return 0
    done
    return 1
  fi
  [ "$got" = "$expected" ]
}

check_status() {
  local persona="$1" step="$2" status="$3" expected="$4"
  if expect_status "$status" "$expected"; then
    record true "$persona" "$step" "HTTP $status"
  else
    record false "$persona" "$step" "HTTP $status (expected $expected)"
  fi
}

test_persona() {
  local email="$1" label="$2" role="$3"
  local token status

  status=$(login "$email" "$PASSWORD")
  check_status "$label" "login" "$status" "200"
  if ! expect_status "$status" "200"; then
    return
  fi

  token=$(extract_token) || true
  if [ -z "${token:-}" ]; then
    record false "$label" "token" "missing access_token"
    return
  fi
  record true "$label" "token" "received"

  status=$(api GET "/api/v1/auth/me" "$token")
  check_status "$label" "GET /auth/me" "$status" "200"

  case "$role" in
    admin)
      status=$(api GET "/api/v1/organizations" "$token")
      check_status "$label" "GET /organizations" "$status" "200"

      status=$(api_post_json "/api/v1/rosters" "$token" \
        "{\"player_id\":\"00000001-0001-0001-0001-000000000006\",\"team_designation\":\"${TEAM}\",\"season\":\"${SEASON}\",\"jersey_number\":\"99\",\"status\":\"active\"}" \
        "$TENANT_HEADER")
      check_status "$label" "POST /rosters" "$status" "200,201"
      ;;
    coach)
      status=$(api GET "/api/v1/rosters" "$token" "$TENANT_HEADER")
      check_status "$label" "GET /rosters" "$status" "200"

      status=$(api_post_json "/api/v1/rosters" "$token" \
        "{\"player_id\":\"00000001-0001-0001-0001-000000000007\",\"team_designation\":\"${TEAM}\",\"season\":\"${SEASON}\",\"jersey_number\":\"98\",\"status\":\"active\"}" \
        "$TENANT_HEADER")
      check_status "$label" "POST /rosters" "$status" "200,201"
      ;;
    parent)
      status=$(api GET "/api/v1/players" "$token")
      check_status "$label" "GET /players" "$status" "200"

      status=$(api GET "/api/v1/memberships" "$token")
      check_status "$label" "GET /memberships" "$status" "200"

      status=$(api GET "/api/v1/rosters" "$token" "$TENANT_HEADER")
      check_status "$label" "GET /rosters" "$status" "200"
      ;;
    viewer)
      status=$(api GET "/api/v1/memberships" "$token")
      check_status "$label" "GET /memberships" "$status" "200"

      status=$(api GET "/api/v1/players" "$token")
      check_status "$label" "GET /players" "$status" "200,403"
      ;;
    *)
      record false "$label" "role" "unknown role $role"
      ;;
  esac
}

echo "=== Role Integration Tests ==="
echo "Backend: $BACKEND_URL"
echo "Org:     $ORG_SLUG ($ORG_ID)"
echo ""

if [ "${DEV_AUTH_ENABLED:-}" != "true" ]; then
  echo "WARN: DEV_AUTH_ENABLED is not true — login may fail without Supabase on :54321"
fi

while IFS='|' read -r email label role; do
  test_persona "$email" "$label" "$role"
done < <(python3 -c "import json; [print(f\"{u['email']}|{u['label']}|{u['role']}\") for u in json.load(open('$TEST_USERS'))['users']]")

echo "-------------------------------------------"
printf "%-6s | %-22s | %-24s | %s\n" "Result" "Persona" "Step" "Detail"
echo "-------------------------------------------"
for r in "${RESULTS[@]}"; do
  IFS='|' read -r result persona step detail <<< "$r"
  printf "%-6s |%-22s |%-24s |%s\n" "$result" "$persona" "$step" "$detail"
done
echo "-------------------------------------------"
echo "Total: $((PASS + FAIL)) | Passed: $PASS | Failed: $FAIL"

if [ "$FAIL" -gt 0 ]; then
  echo "ROLE INTEGRATION TESTS FAILED"
  exit 1
fi
echo "ALL ROLE INTEGRATION TESTS PASSED"

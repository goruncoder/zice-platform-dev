#!/usr/bin/env bash
# Bootstrap the local stack, run integration tests, then shut down.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ ! -f .env ]; then
  echo "Copying .env.example → .env"
  cp .env.example .env
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

cleanup() {
  echo ""
  echo "Stopping integration test stack..."
  make stop >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "=== Integration CI: starting stack ==="
make stop >/dev/null 2>&1 || true
docker compose up -d --wait
make db-migrate
./scripts/seed.sh

echo "Starting backend and frontend..."
mkdir -p .logs
(cd repos/zice-core && exec go run ./cmd/server) > .logs/backend.log 2>&1 &
echo $! > .logs/backend.pid
(cd repos/zice-frontend && exec npm run dev) > .logs/frontend.log 2>&1 &
echo $! > .logs/frontend.pid

wait_for_url() {
  local name="$1" url="$2" max="${3:-90}"
  local i=0
  while [ "$i" -lt "$max" ]; do
    if curl -sf "$url" >/dev/null 2>&1; then
      echo "$name is up ($url)"
      return 0
    fi
    sleep 2
    ((i += 2))
  done
  echo "ERROR: $name did not become ready within ${max}s"
  echo "--- backend log (tail) ---"
  tail -30 .logs/backend.log 2>/dev/null || true
  echo "--- frontend log (tail) ---"
  tail -30 .logs/frontend.log 2>/dev/null || true
  return 1
}

BACKEND_URL="${API_URL:-http://localhost:8080}"
FRONTEND_URL="${FRONTEND_URL:-http://localhost:3000}"
BACKEND_URL="${BACKEND_URL%/}"
FRONTEND_URL="${FRONTEND_URL%/}"

wait_for_url "Backend" "${BACKEND_URL}/api/v1/health"
# Frontend may redirect; any HTTP response means the server is listening.
wait_for_url "Frontend" "${FRONTEND_URL}/"

echo ""
echo "=== Integration CI: running tests ==="
export BACKEND_URL FRONTEND_URL DEV_AUTH_ENABLED=true
./scripts/integration-test.sh
echo ""
./scripts/integration-roles-test.sh

#!/bin/bash
# =============================================================================
# smoke-test.sh — Post-deployment health checks for testcloud24.com
# =============================================================================
set -euo pipefail

BASE_URL="${1:-https://testcloud24.com}"
AUTH_URL="${2:-https://auth.testcloud24.com}"
AUTH_API_URL="${3:-https://auth-api.testcloud24.com}"

PASS=0
FAIL=0

check() {
  local NAME="$1"
  local URL="$2"
  local EXPECTED_STATUS="${3:-200}"
  local ACTUAL_STATUS

  ACTUAL_STATUS=$(curl -o /dev/null -s -w "%{http_code}" --max-time 10 "$URL" || echo "000")

  if [ "$ACTUAL_STATUS" = "$EXPECTED_STATUS" ] || [[ "$ACTUAL_STATUS" =~ ^[23] ]]; then
    echo "  ✓ $NAME ($ACTUAL_STATUS)"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $NAME (expected $EXPECTED_STATUS, got $ACTUAL_STATUS)"
    FAIL=$((FAIL + 1))
  fi
}

echo ""
echo "============================================================"
echo "  SunFlowCRM — Smoke test"
echo "============================================================"
echo ""
echo "→ App: $BASE_URL"
echo "→ Auth Dashboard: $AUTH_URL"
echo "→ Auth API: $AUTH_API_URL"
echo ""

echo "--- Application ---"
check "Homepage" "$BASE_URL"
check "Sign-in page" "$BASE_URL/auth/sign-in"
check "API: auth route" "$BASE_URL/api/auth/signout"

echo ""
echo "--- Stack Auth ---"
check "Dashboard homepage" "$AUTH_URL"
check "API endpoint" "$AUTH_API_URL"

echo ""
echo "--- Internal containers ---"
CONTAINERS=("sunflow-postgres" "sunflow-redis" "sunflow-stack-postgres" "sunflow-clickhouse" "sunflow-stack-server" "sunflow-app" "sunflow-worker")
for c in "${CONTAINERS[@]}"; do
  STATUS=$(docker inspect --format='{{.State.Status}}' "$c" 2>/dev/null || echo "not found")
  HEALTH=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' "$c" 2>/dev/null || echo "")
  if [ "$STATUS" = "running" ]; then
    echo "  ✓ $c ($STATUS / $HEALTH)"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $c ($STATUS / $HEALTH)"
    FAIL=$((FAIL + 1))
  fi
done

echo ""
echo "--- Redis queue check ---"
REDIS_PING=$(docker exec sunflow-redis redis-cli -a "$(grep '^REDIS_PASSWORD=' /opt/sunflow/.env.prod 2>/dev/null | cut -d= -f2 | tr -d '"')" ping 2>/dev/null || echo "ERROR")
if [ "$REDIS_PING" = "PONG" ]; then
  echo "  ✓ Redis responds PONG"
  PASS=$((PASS + 1))
else
  echo "  ✗ Redis ping failed: $REDIS_PING"
  FAIL=$((FAIL + 1))
fi

echo ""
echo "============================================================"
echo "  Results: $PASS passed, $FAIL failed"
echo "============================================================"
echo ""

[ "$FAIL" -eq 0 ] && exit 0 || exit 1

#!/bin/bash
# =============================================================================
# phase1-start-stackauth.sh — Phase 1 of two-phase deploy
# Starts Stack Auth infrastructure only (without the app).
# Must complete before you can get the Stack Auth project keys.
#
# Usage: ./deploy/phase1-start-stackauth.sh
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$APP_DIR/.env.prod"
COMPOSE_FILE="$APP_DIR/docker-compose.prod.yml"

echo ""
echo "============================================================"
echo "  SunFlowCRM — Phase 1: Stack Auth Bootstrap"
echo "============================================================"

# ── Guard: env file must exist ────────────────────────────────────────────────
if [ ! -f "$ENV_FILE" ]; then
  echo ""
  echo "  ERROR: $ENV_FILE not found!"
  echo "  Copy env.prod.example → .env.prod and fill in all <FILL_ME> values."
  exit 1
fi

# ── Guard: critical secrets must be filled ────────────────────────────────────
for VAR in POSTGRES_PASSWORD REDIS_PASSWORD STACK_DB_PASSWORD CLICKHOUSE_PASSWORD STACK_SERVER_SECRET INTERNAL_WORKER_SECRET; do
  VALUE=$(grep "^${VAR}=" "$ENV_FILE" | cut -d= -f2 | tr -d '"')
  if [ -z "$VALUE" ] || [ "$VALUE" = "<FILL_ME>" ]; then
    echo ""
    echo "  ERROR: $VAR is not set in .env.prod"
    echo "  Run:  ./deploy/gen-secrets.sh  to generate missing secrets."
    exit 1
  fi
done

echo ""
echo "[1/4] Building Docker images..."
cd "$APP_DIR"

# Build Stack Auth server image (patches stackauth/server:latest)
docker build -t sunflow-stack-server:latest -f Dockerfile.stack-auth .

# Build app image (needed for migrate service in phase 2)
docker build \
  --build-arg NEXT_PUBLIC_APP_URL="$(grep '^NEXT_PUBLIC_APP_URL=' "$ENV_FILE" | cut -d= -f2 | tr -d '"')" \
  --build-arg NEXT_PUBLIC_APP_NAME="SunFlowCRM" \
  --build-arg NEXT_PUBLIC_API_DOMAIN="$(grep '^NEXT_PUBLIC_APP_URL=' "$ENV_FILE" | cut -d= -f2 | tr -d '"')" \
  --build-arg NEXT_PUBLIC_AUTH_PROVIDER="stack" \
  -t sunflow-app:latest \
  -f Dockerfile .

echo ""
echo "[2/4] Starting Stack Auth infrastructure services..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" \
  up -d stack-postgres clickhouse stack-server

echo ""
echo "[3/4] Waiting for Stack Auth to complete migrations..."
echo "  This can take up to 90 seconds on first boot..."

TIMEOUT=120
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
  if docker logs sunflow-stack-server 2>&1 | grep -q "Server is running on port 8101"; then
    echo "  Stack Auth is ready!"
    break
  fi
  sleep 5
  ELAPSED=$((ELAPSED + 5))
  echo "  Waiting... ($ELAPSED/${TIMEOUT}s)"
done

if [ $ELAPSED -ge $TIMEOUT ]; then
  echo ""
  echo "  WARNING: Timeout. Check logs: docker logs sunflow-stack-server"
  echo "  If Stack Auth is still starting, wait and continue manually."
fi

echo ""
echo "[4/4] Reverse proxy check..."
# If Caddy is installed as a systemd service, start it.
# If you use a different proxy (Nginx Proxy Manager, Coolify, Traefik, etc.),
# ensure routes for the three domains are pointing to the correct ports:
#   testcloud24.com          → http://localhost:3000
#   auth.testcloud24.com     → http://localhost:8101
#   auth-api.testcloud24.com → http://localhost:8102
if command -v systemctl &>/dev/null && systemctl list-units --type=service 2>/dev/null | grep -q caddy; then
  systemctl start caddy && echo "  Caddy started." || echo "  Caddy already running."
else
  echo "  Caddy not found as systemd service — assuming external proxy is handling routing."
  echo "  Verify that auth.testcloud24.com proxies to localhost:8101"
  echo "  and auth-api.testcloud24.com proxies to localhost:8102"
fi

echo ""
echo "============================================================"
echo "  Phase 1 complete!"
echo ""
echo "  Stack Auth should now be accessible at:"
echo "    Dashboard:  https://auth.testcloud24.com"
echo "    API:        https://auth-api.testcloud24.com"
echo ""
echo "  NEXT: Run ./deploy/phase2-configure-stackauth.sh"
echo "  OR follow the manual steps in deploy/DEPLOY.md"
echo "============================================================"
echo ""

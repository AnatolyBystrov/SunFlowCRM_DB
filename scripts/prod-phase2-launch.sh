#!/bin/bash
# =============================================================================
# phase2-launch-app.sh — Phase 2: full stack launch
# Requires Stack Auth project keys to be filled in .env.prod first.
#
# Usage: ./deploy/phase2-launch-app.sh
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$APP_DIR/.env.prod"
COMPOSE_FILE="$APP_DIR/docker-compose.prod.yml"

echo ""
echo "============================================================"
echo "  SunFlowCRM — Phase 2: Full Stack Launch"
echo "============================================================"

# ── Guard: Stack Auth keys must be filled ─────────────────────────────────────
for VAR in NEXT_PUBLIC_STACK_PROJECT_ID NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY STACK_SECRET_SERVER_KEY; do
  VALUE=$(grep "^${VAR}=" "$ENV_FILE" | cut -d= -f2 | tr -d '"')
  if [ -z "$VALUE" ]; then
    echo ""
    echo "  ERROR: $VAR is not set in .env.prod"
    echo ""
    echo "  You must complete Phase 1 first:"
    echo "    1. Open https://auth.testcloud24.com"
    echo "    2. Create an admin account"
    echo "    3. Create project 'SunFlowCRM'"
    echo "    4. Copy the 3 keys into .env.prod"
    echo "    5. Re-run this script"
    exit 1
  fi
done

cd "$APP_DIR"

echo ""
echo "[1/3] Rebuilding app image with Stack Auth keys baked in..."
STACK_PROJECT_ID=$(grep '^NEXT_PUBLIC_STACK_PROJECT_ID=' "$ENV_FILE" | cut -d= -f2 | tr -d '"')
STACK_PUB_KEY=$(grep '^NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY=' "$ENV_FILE" | cut -d= -f2 | tr -d '"')
APP_URL=$(grep '^NEXT_PUBLIC_APP_URL=' "$ENV_FILE" | cut -d= -f2 | tr -d '"')
STACK_URL=$(grep '^NEXT_PUBLIC_STACK_URL=' "$ENV_FILE" | cut -d= -f2 | tr -d '"')
STACK_API_URL=$(grep '^NEXT_PUBLIC_STACK_API_URL=' "$ENV_FILE" | cut -d= -f2 | tr -d '"')

docker build \
  --build-arg NEXT_PUBLIC_APP_NAME="SunFlowCRM" \
  --build-arg NEXT_PUBLIC_APP_URL="$APP_URL" \
  --build-arg NEXT_PUBLIC_API_DOMAIN="$APP_URL" \
  --build-arg NEXT_PUBLIC_AUTH_PROVIDER="stack" \
  --build-arg NEXT_PUBLIC_STACK_PROJECT_ID="$STACK_PROJECT_ID" \
  --build-arg NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY="$STACK_PUB_KEY" \
  --build-arg NEXT_PUBLIC_STACK_URL="$STACK_URL" \
  --build-arg NEXT_PUBLIC_STACK_API_URL="$STACK_API_URL" \
  -t sunflow-app:latest \
  -f Dockerfile .

echo ""
echo "[2/3] Starting full stack (migrate → app → worker)..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d

echo ""
echo "[3/3] Waiting for services to become healthy..."
TIMEOUT=120
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
  APP_STATUS=$(docker inspect --format='{{.State.Health.Status}}' sunflow-app 2>/dev/null || echo "starting")
  if [ "$APP_STATUS" = "healthy" ] || [ "$APP_STATUS" = "running" ]; then
    echo "  App container is up!"
    break
  fi
  sleep 5
  ELAPSED=$((ELAPSED + 5))
  echo "  App status: $APP_STATUS ($ELAPSED/${TIMEOUT}s)"
done

echo ""
echo "============================================================"
echo "  Deployment complete!"
echo ""
echo "  docker compose -f docker-compose.prod.yml --env-file .env.prod ps"
echo "============================================================"
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" ps
echo ""

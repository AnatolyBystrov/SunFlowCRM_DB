#!/bin/bash
# =============================================================================
# update-app.sh — Zero-downtime app update (after initial deployment)
# Rebuilds the app image and restarts only app + worker containers.
#
# Usage: ./deploy/update-app.sh
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$APP_DIR/.env.prod"
COMPOSE_FILE="$APP_DIR/docker-compose.prod.yml"

echo ""
echo "============================================================"
echo "  SunFlowCRM — App update"
echo "============================================================"

cd "$APP_DIR"

echo "[1/3] Pulling latest code..."
git pull --ff-only

echo ""
echo "[2/3] Rebuilding app image..."
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
echo "[3/3] Restarting app and worker containers only..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" \
  up -d --no-deps app worker

echo ""
echo "  Update complete. Current status:"
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" ps
echo ""

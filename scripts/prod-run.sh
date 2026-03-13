#!/bin/bash
# =============================================================================
# run-on-server.sh — Полный запуск на VPS одной командой
# Запустить после того как:
#   1. Код и .env.prod скопированы на сервер
#   2. DNS A-записи настроены и распространились
#
# Использование: bash deploy/run-on-server.sh
# =============================================================================
set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo ""
echo "============================================================"
echo "  SunFlowCRM — Full Production Deploy"
echo "  $(date)"
echo "============================================================"

# ── PHASE 1: Stack Auth ───────────────────────────────────────────────────────
echo ""
echo ">>> PHASE 1: Starting Stack Auth infrastructure..."
bash "$APP_DIR/deploy/phase1-start-stackauth.sh"

# ── Wait for user to get keys ─────────────────────────────────────────────────
echo ""
echo "============================================================"
echo ""
echo "  Phase 1 complete! Stack Auth Dashboard is live at:"
echo "  https://auth.testcloud24.com"
echo ""
echo "  ACTION REQUIRED (manual steps):"
echo ""
echo "  1. Open https://auth.testcloud24.com in browser"
echo "  2. Create admin account (first registration)"
echo "  3. Create new project named 'SunFlowCRM'"
echo "     - Disable public sign-up"
echo "  4. Go to Project Settings → API Keys"
echo "  5. Copy the three keys and add to .env.prod:"
echo ""
echo "     NEXT_PUBLIC_STACK_PROJECT_ID=proj_..."
echo "     NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY=pck_..."
echo "     STACK_SECRET_SERVER_KEY=ssk_..."
echo ""
echo "  Also set redirect URL in Stack Auth project settings:"
echo "     Allowed callback URL: https://testcloud24.com/handler"
echo "     Trusted domain:       testcloud24.com"
echo ""
echo "  When done, press ENTER to continue with Phase 2..."
echo "============================================================"
read -r

# ── PHASE 2: Full stack ───────────────────────────────────────────────────────
echo ""
echo ">>> PHASE 2: Launching full application stack..."
bash "$APP_DIR/deploy/phase2-launch-app.sh"

# ── Smoke test ────────────────────────────────────────────────────────────────
echo ""
echo ">>> Running smoke test..."
sleep 10
bash "$APP_DIR/deploy/smoke-test.sh" || true

echo ""
echo "============================================================"
echo "  Deployment complete!"
echo ""
echo "  App:              https://testcloud24.com"
echo "  Stack Dashboard:  https://auth.testcloud24.com"
echo "  Stack API:        https://auth-api.testcloud24.com"
echo ""
echo "  NEXT: Configure webhooks (see deploy/DEPLOY.md Step 7)"
echo "============================================================"

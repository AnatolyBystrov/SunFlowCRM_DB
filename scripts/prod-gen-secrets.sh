#!/bin/bash
# =============================================================================
# gen-secrets.sh — Generate all required secrets for .env.prod
# Run this ONCE locally, then paste the values into .env.prod
# =============================================================================
set -euo pipefail

echo ""
echo "============================================================"
echo "  SunFlowCRM — Secret generator"
echo "  Copy these values into .env.prod (replace <FILL_ME> lines)"
echo "============================================================"
echo ""
echo "POSTGRES_PASSWORD=$(openssl rand -hex 24)"
echo "REDIS_PASSWORD=$(openssl rand -hex 24)"
echo "STACK_DB_PASSWORD=$(openssl rand -hex 24)"
echo "CLICKHOUSE_PASSWORD=$(openssl rand -hex 24)"
echo "STACK_SERVER_SECRET=$(openssl rand -hex 32)"
echo "INTERNAL_WORKER_SECRET=$(openssl rand -hex 32)"
echo ""
echo "# STACK_WEBHOOK_SECRET — generate after Phase 2 from Stack Auth Dashboard → Webhooks"
echo ""

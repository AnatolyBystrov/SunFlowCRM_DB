#!/bin/bash
# =============================================================================
# backup.sh — PostgreSQL backup for both app and Stack Auth databases
# Schedule with cron: 0 3 * * * /opt/sunflow/deploy/backup.sh >> /var/log/sunflow-backup.log 2>&1
# =============================================================================
set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$APP_DIR/.env.prod"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/sunflow}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=14

mkdir -p "$BACKUP_DIR"

# Load env
set -o allexport
source "$ENV_FILE"
set +o allexport

echo "[$TIMESTAMP] Starting backup..."

# ── App database ──────────────────────────────────────────────────────────────
echo "  Dumping app database (sun_uw)..."
docker exec sunflow-postgres pg_dump \
  -U "${POSTGRES_USER:-postgres}" \
  "${POSTGRES_DB:-sun_uw}" \
  | gzip > "$BACKUP_DIR/app_${TIMESTAMP}.sql.gz"
echo "  ✓ $BACKUP_DIR/app_${TIMESTAMP}.sql.gz"

# ── Stack Auth database ───────────────────────────────────────────────────────
echo "  Dumping Stack Auth database (stackauth)..."
docker exec sunflow-stack-postgres pg_dump \
  -U stackauth \
  stackauth \
  | gzip > "$BACKUP_DIR/stackauth_${TIMESTAMP}.sql.gz"
echo "  ✓ $BACKUP_DIR/stackauth_${TIMESTAMP}.sql.gz"

# ── Cleanup old backups ───────────────────────────────────────────────────────
echo "  Cleaning up backups older than ${RETENTION_DAYS} days..."
find "$BACKUP_DIR" -name "*.sql.gz" -mtime "+${RETENTION_DAYS}" -delete

echo "[$TIMESTAMP] Backup complete."
echo "  $(ls -lh "$BACKUP_DIR"/*.sql.gz | tail -6)"

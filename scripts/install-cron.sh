#!/bin/bash
# =============================================================================
# install-cron.sh — Install backup cron job and system watchdog
# Run once on the server after deployment.
# =============================================================================
set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CRON_USER="${SUDO_USER:-$(whoami)}"

echo ""
echo "[1/2] Installing daily backup cron job..."
CRON_LINE="0 3 * * * $APP_DIR/deploy/backup.sh >> /var/log/sunflow-backup.log 2>&1"

# Add to crontab if not already present
(crontab -u "$CRON_USER" -l 2>/dev/null | grep -v "sunflow.*backup"; echo "$CRON_LINE") \
  | crontab -u "$CRON_USER" -

echo "  ✓ Daily backup scheduled at 03:00"

echo ""
echo "[2/2] Creating backup log file..."
touch /var/log/sunflow-backup.log
chown "$CRON_USER:$CRON_USER" /var/log/sunflow-backup.log 2>/dev/null || true

echo ""
echo "  Backup cron installed. Verify with: crontab -l"
echo ""

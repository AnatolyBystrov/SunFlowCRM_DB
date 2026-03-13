#!/bin/bash
# =============================================================================
# server-setup.sh — One-time VPS bootstrap for SunFlowCRM
# Run once on a fresh Ubuntu 22.04/24.04 server as root or sudo user.
# =============================================================================
set -euo pipefail

APP_DIR="/opt/sunflow"
APP_USER="sunflow"

echo ""
echo "============================================================"
echo "  SunFlowCRM — VPS bootstrap"
echo "============================================================"
echo ""

# ── 1. System update ──────────────────────────────────────────────────────────
echo "[1/7] Updating system packages..."
apt-get update -qq
apt-get upgrade -y -qq
apt-get install -y -qq curl git openssl ufw ca-certificates gnupg lsb-release

# ── 2. Docker Engine ──────────────────────────────────────────────────────────
echo "[2/7] Installing Docker Engine..."
if ! command -v docker &>/dev/null; then
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    > /etc/apt/sources.list.d/docker.list
  apt-get update -qq
  apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable docker
  systemctl start docker
  echo "  Docker installed: $(docker --version)"
else
  echo "  Docker already installed: $(docker --version)"
fi

# ── 3. Caddy ──────────────────────────────────────────────────────────────────
echo "[3/7] Installing Caddy..."
if ! command -v caddy &>/dev/null; then
  curl -fsSL https://dl.cloudsmith.io/public/caddy/stable/gpg.key \
    | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/caddy-stable-archive-keyring.gpg] \
    https://dl.cloudsmith.io/public/caddy/stable/deb/debian any-version main" \
    > /etc/apt/sources.list.d/caddy-stable.list
  apt-get update -qq
  apt-get install -y -qq caddy
  echo "  Caddy installed: $(caddy version)"
else
  echo "  Caddy already installed: $(caddy version)"
fi

# ── 4. App user & directory ───────────────────────────────────────────────────
echo "[4/7] Creating app user and directory..."
if ! id "$APP_USER" &>/dev/null; then
  useradd -r -m -s /bin/bash "$APP_USER"
  usermod -aG docker "$APP_USER"
  echo "  Created user: $APP_USER"
fi

mkdir -p "$APP_DIR"
chown "$APP_USER:$APP_USER" "$APP_DIR"
mkdir -p /var/log/caddy
chown caddy:caddy /var/log/caddy

# ── 5. Firewall ───────────────────────────────────────────────────────────────
echo "[5/7] Configuring firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp   # HTTP  (Caddy + ACME challenge)
ufw allow 443/tcp  # HTTPS (Caddy)
# Internal ports (3000, 8101, 8102) are NOT exposed — Caddy proxies them.
ufw --force enable
echo "  Firewall configured (SSH + 80 + 443 only)"

# ── 6. Clone / update repo ────────────────────────────────────────────────────
echo "[6/7] Cloning repository..."
if [ -d "$APP_DIR/.git" ]; then
  echo "  Repo already present, pulling latest main..."
  sudo -u "$APP_USER" git -C "$APP_DIR" pull --ff-only
else
  sudo -u "$APP_USER" git clone --config core.hooksPath=/dev/null \
    https://github.com/AnatolyBystrov/SunFlowCRM_DB.git "$APP_DIR"
fi

# ── 7. Caddy systemd & Caddyfile ──────────────────────────────────────────────
echo "[7/7] Installing Caddyfile..."
cp "$APP_DIR/deploy/Caddyfile" /etc/caddy/Caddyfile
systemctl enable caddy
# Note: Caddy starts only AFTER DNS is pointed and .env.prod is in place.

echo ""
echo "============================================================"
echo "  Bootstrap complete!"
echo ""
echo "  Next steps:"
echo "  1. Point DNS A-records to this server's IP:"
echo "       testcloud24.com          → <server-ip>"
echo "       auth.testcloud24.com     → <server-ip>"
echo "       auth-api.testcloud24.com → <server-ip>"
echo ""
echo "  2. Copy your .env.prod to $APP_DIR/.env.prod"
echo "     and fill in all secrets."
echo ""
echo "  3. Run:  $APP_DIR/deploy/phase1-start-stackauth.sh"
echo "============================================================"
echo ""

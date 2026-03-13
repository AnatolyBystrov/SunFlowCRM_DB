# SunFlowCRM — Production Deployment Guide
**Domain:** `testcloud24.com` | **Auth:** Stack Auth (self-hosted) | **Infra:** Docker Compose + Caddy

---

## Architecture Overview

```
Browser
  ├── testcloud24.com           → Caddy → localhost:3000  (Next.js app)
  ├── auth.testcloud24.com      → Caddy → localhost:8101  (Stack Auth Dashboard)
  └── auth-api.testcloud24.com  → Caddy → localhost:8102  (Stack Auth API)

Containers (Docker internal network):
  sunflow-app           → sunflow-postgres (main DB)
  sunflow-app           → sunflow-redis
  sunflow-app           → sunflow-stack-server:8102  (internal SDK calls via STACK_INTERNAL_API_URL)
  sunflow-worker        → sunflow-redis
  sunflow-worker        → sunflow-postgres
  sunflow-stack-server  → sunflow-stack-postgres
  sunflow-stack-server  → sunflow-clickhouse
```

---

## Prerequisites

| Requirement | Version |
|---|---|
| Ubuntu | 22.04 or 24.04 |
| RAM | minimum 4 GB (ClickHouse needs ~2 GB) |
| Disk | 20+ GB free |
| Docker Engine | 24+ |
| Docker Compose plugin | v2+ |
| Caddy | 2.x |
| Domain DNS | A-records pointing to server IP |

---

## Step 0 — Server bootstrap

Run once on a fresh server:

```bash
scp deploy/server-setup.sh root@<server-ip>:/tmp/server-setup.sh
ssh root@<server-ip> "bash /tmp/server-setup.sh"
```

This installs Docker, Caddy, creates the `sunflow` user, sets up a firewall (ports 22/80/443 only), and clones the repo to `/opt/sunflow`.

---

## Step 1 — DNS records

Add three **A-records** pointing to your server IP in your DNS provider:

| Hostname | Type | Value |
|---|---|---|
| `testcloud24.com` | A | `<server-ip>` |
| `auth.testcloud24.com` | A | `<server-ip>` |
| `auth-api.testcloud24.com` | A | `<server-ip>` |

Wait for DNS propagation before proceeding (check with `dig testcloud24.com`).

---

## Step 2 — Generate secrets

Run locally:

```bash
bash deploy/gen-secrets.sh
```

Copy the output values into `.env.prod`. Do not commit `.env.prod` to git.

---

## Step 3 — Fill in .env.prod

Copy the template and fill in all required values:

```bash
cp env.prod.example .env.prod
```

Required values to fill:

| Variable | How to get it |
|---|---|
| `POSTGRES_PASSWORD` | `gen-secrets.sh` output |
| `REDIS_PASSWORD` | `gen-secrets.sh` output |
| `STACK_DB_PASSWORD` | `gen-secrets.sh` output |
| `CLICKHOUSE_PASSWORD` | `gen-secrets.sh` output |
| `STACK_SERVER_SECRET` | `gen-secrets.sh` output |
| `INTERNAL_WORKER_SECRET` | `gen-secrets.sh` output |
| `STACK_EMAIL_HOST` | Your SMTP provider hostname |
| `STACK_EMAIL_USERNAME` | SMTP login |
| `STACK_EMAIL_PASSWORD` | SMTP password |
| `STACK_EMAIL_SENDER` | `noreply@testcloud24.com` |

**Leave Stack Auth project keys empty for now** — they are filled in Step 5.

Transfer `.env.prod` to the server:

```bash
scp .env.prod sunflow@<server-ip>:/opt/sunflow/.env.prod
```

---

## Step 4 — Phase 1: Start Stack Auth

SSH into the server and run:

```bash
ssh sunflow@<server-ip>
cd /opt/sunflow
bash deploy/phase1-start-stackauth.sh
```

This script will:
1. Build both Docker images (`sunflow-stack-server:latest` and `sunflow-app:latest`)
2. Start `stack-postgres`, `clickhouse`, `stack-server`
3. Wait for Stack Auth migrations to complete
4. Start Caddy (TLS certificates will be issued automatically via Let's Encrypt)

### Verify Phase 1

```bash
# All three should be running/healthy
docker compose -f docker-compose.prod.yml --env-file .env.prod ps

# Stack Auth logs — should show "Server is running on port 8101"
docker logs sunflow-stack-server --tail 30
```

Open `https://auth.testcloud24.com` in a browser — you should see the Stack Auth Dashboard.

---

## Step 5 — Create Stack Auth project (Phase 2 setup)

1. Open `https://auth.testcloud24.com`
2. **Register an admin account** (first registration is always allowed)
3. Click **"Create New Project"**:
   - Name: `SunFlowCRM`
   - Disable **"Allow public sign-up"** (invite-only platform)
4. Go to **Project Settings → API Keys** and copy three keys:
   - **Project ID** → `NEXT_PUBLIC_STACK_PROJECT_ID`
   - **Publishable Client Key** → `NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY`
   - **Secret Server Key** → `STACK_SECRET_SERVER_KEY`
5. Edit `.env.prod` on the server:
   ```bash
   nano /opt/sunflow/.env.prod
   # Paste the three keys
   ```
6. In Stack Auth Dashboard, set **Allowed Domains / Redirect URLs**:
   - Allowed callback URL: `https://testcloud24.com/handler`
   - Trusted domain: `testcloud24.com`

---

## Step 6 — Launch full stack

```bash
cd /opt/sunflow
bash deploy/phase2-launch-app.sh
```

This will:
1. Rebuild the app image with Stack Auth keys baked in as `NEXT_PUBLIC_*` build args
2. Start `postgres`, `redis`, `migrate`, `app`, `worker`
3. Run Prisma migrations automatically via `migrate` service
4. Wait for `app` to become healthy

### Verify full stack

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod ps
# Expected: all 8 services running/healthy (migrate exits 0)
```

Open `https://testcloud24.com` — you should see the CRM login page.

---

## Step 7 — Configure Stack Auth webhooks

Webhooks sync user events (created / updated / deleted) to the app database.

1. In Stack Auth Dashboard: **Project Settings → Webhooks → Add endpoint**
2. URL: `https://testcloud24.com/api/webhooks/stack`
3. Events: select `user.created`, `user.updated`, `user.deleted`
4. Copy the **Svix Signing Secret** shown after saving
5. Add it to `.env.prod`:
   ```
   STACK_WEBHOOK_SECRET=<svix-signing-secret>
   ```
6. Restart only the app container (no rebuild needed — it reads this at runtime):
   ```bash
   docker compose -f docker-compose.prod.yml --env-file .env.prod restart app
   ```

---

## Step 8 — Smoke test

```bash
bash deploy/smoke-test.sh
```

Manual checklist:

- [ ] `https://testcloud24.com` loads sign-in page
- [ ] `https://auth.testcloud24.com` loads Stack Auth Dashboard
- [ ] `https://auth-api.testcloud24.com` responds (JSON or 200)
- [ ] Sign in with admin account → lands on `/dashboard/overview`
- [ ] Sign out → redirects to sign-in
- [ ] Invite a second user (invite email arrives via SMTP)
- [ ] New user accepts invite and can sign in
- [ ] Create a Deal in CRM → appears in list
- [ ] `docker logs sunflow-worker` shows queue processing (no errors)

---

## Ongoing Operations

### Update the application

```bash
cd /opt/sunflow
bash deploy/update-app.sh
```

Rebuilds only the app image and restarts `app` + `worker` containers. Infrastructure (Postgres, Redis, Stack Auth) is not touched.

### Backup databases

Manual backup:

```bash
bash deploy/backup.sh
```

Automated daily backup (add to crontab):

```bash
crontab -e
# Add:
0 3 * * * /opt/sunflow/deploy/backup.sh >> /var/log/sunflow-backup.log 2>&1
```

Backups are stored in `/var/backups/sunflow/` and kept for 14 days.

### View logs

```bash
# App
docker logs sunflow-app -f --tail 100

# Worker
docker logs sunflow-worker -f --tail 100

# Stack Auth
docker logs sunflow-stack-server -f --tail 100

# Caddy
journalctl -u caddy -f
```

### Full restart

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod restart
```

---

## Security checklist

- [ ] Firewall: only ports 22, 80, 443 open (done by `server-setup.sh`)
- [ ] Ports 3000, 8101, 8102 NOT exposed to public (only Caddy proxies)
- [ ] `.env.prod` NOT committed to git (add to `.gitignore`)
- [ ] `STACK_WEBHOOK_SECRET` set (required in production by `route.ts`)
- [ ] SMTP configured (invite / reset flows will fail without it)
- [ ] Stack Auth public sign-up disabled (invite-only)
- [ ] Daily backups scheduled
- [ ] TLS certificates: Caddy renews automatically (check: `caddy list-certs`)

---

## Scripts reference

| Script | Purpose |
|---|---|
| `deploy/server-setup.sh` | One-time VPS bootstrap |
| `deploy/gen-secrets.sh` | Generate all required secrets |
| `deploy/phase1-start-stackauth.sh` | Phase 1: start Stack Auth only |
| `deploy/phase2-launch-app.sh` | Phase 2: launch full stack |
| `deploy/update-app.sh` | Update app after code changes |
| `deploy/backup.sh` | Dump both Postgres databases |
| `deploy/smoke-test.sh` | Post-deploy health check |
| `deploy/Caddyfile` | Caddy reverse proxy config |

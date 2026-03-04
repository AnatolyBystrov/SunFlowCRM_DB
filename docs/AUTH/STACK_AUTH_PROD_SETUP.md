# Stack Auth — Production Setup Guide

Stack Auth requires a **two-phase deployment** on first boot because the project keys
(`NEXT_PUBLIC_STACK_PROJECT_ID`, etc.) can only be obtained after the Stack Auth server
has started and you've created a project via its Dashboard.

---

## Prerequisites

- Docker & Docker Compose installed on the server
- Built application image: `docker build -t sunflow-app:latest .`
- A filled `.env.prod` file (copy from `.env.prod.example`)

---

## Phase 1 — Start infrastructure + Stack Auth server

Start only the infrastructure services (no app yet):

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod \
  up -d stack-postgres clickhouse stack-server
```

Wait ~30 seconds for Stack Auth to finish its migrations:

```bash
docker compose -f docker-compose.prod.yml logs -f stack-server
# Wait until you see: "Server is running on port 8101"
```

---

## Phase 2 — Create Stack Auth project & copy keys

1. Open the Stack Auth Dashboard in your browser:
   - Direct: `http://<your-server-ip>:8101`
   - Via reverse proxy: `https://auth.yourdomain.com`

2. Register an admin account (first user becomes admin).

3. Click **"Create New Project"**:
   - Name: `SunFlowCRM`
   - Disable public sign-up (users are invited only)

4. Go to **Project Settings → API Keys** and copy:
   - **Project ID** → `NEXT_PUBLIC_STACK_PROJECT_ID`
   - **Publishable Client Key** → `NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY`
   - **Secret Server Key** → `STACK_SECRET_SERVER_KEY`

5. Add the three keys to your `.env.prod`:

```bash
NEXT_PUBLIC_STACK_PROJECT_ID=proj_...
NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY=pck_...
STACK_SECRET_SERVER_KEY=ssk_...
```

---

## Phase 3 — Start the full stack

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d
```

Verify all services are healthy:

```bash
docker compose -f docker-compose.prod.yml ps
```

All services should show `healthy` or `running`.

---

## Reverse Proxy (Nginx / Caddy)

The Stack Auth server exposes two ports that should be accessible from users' browsers:

| Port | Purpose | Recommended public URL |
|------|---------|------------------------|
| 8101 | Dashboard (admin only) | `https://auth.yourdomain.com` |
| 8102 | API (used by the app) | `https://auth-api.yourdomain.com` |

### Caddy example

```caddy
auth.yourdomain.com {
    reverse_proxy localhost:8101
}

auth-api.yourdomain.com {
    reverse_proxy localhost:8102
}

crm.yourdomain.com {
    reverse_proxy localhost:3000
}
```

### Important: Update `.env.prod` URLs

Make sure these match your actual public URLs:

```bash
NEXT_PUBLIC_STACK_URL=https://auth.yourdomain.com
NEXT_PUBLIC_STACK_API_URL=https://auth-api.yourdomain.com
NEXT_PUBLIC_APP_URL=https://crm.yourdomain.com
```

---

## Secrets Generation Reference

```bash
# PostgreSQL password
openssl rand -hex 24

# Redis password
openssl rand -hex 24

# Stack DB password
openssl rand -hex 24

# ClickHouse password
openssl rand -hex 24

# Stack Server Secret
openssl rand -hex 32

# Internal Worker Secret
openssl rand -hex 32
```

---

## Subsequent Restarts

After the first setup, all keys are saved in `.env.prod`.
Normal restart:

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d
```

Update application:

```bash
docker build -t sunflow-app:latest .
docker compose -f docker-compose.prod.yml --env-file .env.prod up -d --no-deps app worker
```

---

## Local Development with Stack Auth

For local development, use `docker-compose.stack.yml`:

```bash
docker-compose -f docker-compose.stack.yml up -d
```

Then open http://localhost:8101, create a project, and fill in `.env`:

```bash
NEXT_PUBLIC_STACK_PROJECT_ID=proj_...
NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY=pck_...
STACK_SECRET_SERVER_KEY=ssk_...
```

Start the dev server:

```bash
npm run dev
```

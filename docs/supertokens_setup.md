# SuperTokens Setup Guide for Next.js App Router

> **Last Updated:** 2026-02-08  
> **SuperTokens Node SDK:** 24.0.1  
> **SuperTokens Core:** 9.4+

This guide documents the correct setup for SuperTokens with Next.js App Router, based on lessons learned from debugging common issues.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Docker Setup](#docker-setup)
4. [Backend Configuration](#backend-configuration)
5. [Frontend Configuration](#frontend-configuration)
6. [API Route Handler](#api-route-handler)
7. [Common Issues & Solutions](#common-issues--solutions)
8. [Verification Checklist](#verification-checklist)

---

## Prerequisites

- Node.js 18+
- Docker & Docker Compose
- Next.js 14+ with App Router

---

## Installation

```bash
# Install SuperTokens packages
npm install supertokens-node supertokens-auth-react supertokens-web-js
```

### ⚠️ Version Compatibility

**CRITICAL:** SuperTokens SDK versions must match Core version.

| Node SDK Version | Required Core Version | CDI Version |
|-----------------|----------------------|-------------|
| 24.0.x          | 9.4+                 | 5.4         |
| 23.x            | 9.2+                 | 5.2         |
| 22.x            | 9.0+                 | 5.0         |

Check your SDK CDI version:
```bash
cat node_modules/supertokens-node/lib/build/version.js | grep cdiSupported
```

---

## Docker Setup

### docker-compose.yml

```yaml
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      # Create BOTH databases: app DB and SuperTokens DB
      POSTGRES_DB: your_app_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      # Init script to create supertokens database
      - ./docker/init-supertokens-db.sql:/docker-entrypoint-initdb.d/init-supertokens.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  supertokens:
    # ⚠️ IMPORTANT: Pin to specific version matching your SDK
    image: registry.supertokens.io/supertokens/supertokens-postgresql:9.4
    ports:
      - "3567:3567"
    environment:
      POSTGRESQL_CONNECTION_URI: "postgresql://postgres:postgres@postgres:5432/supertokens"
      API_KEYS: ""  # Set in production!
    depends_on:
      postgres:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3567/hello"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

### docker/init-supertokens-db.sql

```sql
-- Create separate database for SuperTokens
CREATE DATABASE supertokens;
```

### Start Docker

```bash
docker-compose up -d

# Wait for healthy status
docker-compose ps
# Should show: sunappag-supertokens-1   Up X seconds (healthy)

# Verify SuperTokens responds
curl http://localhost:3567/hello
# Should return: Hello
```

---

## Backend Configuration

### src/lib/supertokens/config.ts

```typescript
import SuperTokens from 'supertokens-node';
import EmailPasswordNode from 'supertokens-node/recipe/emailpassword';
import SessionNode from 'supertokens-node/recipe/session';

const appInfo = {
    appName: process.env.NEXT_PUBLIC_APP_NAME || 'My App',
    apiDomain: process.env.NEXT_PUBLIC_API_DOMAIN || 'http://localhost:3000',
    websiteDomain: process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000',
    apiBasePath: '/api/auth',
    websiteBasePath: '/auth'
};

export const backendConfig = () => {
    return {
        framework: 'custom' as const,
        supertokens: {
            connectionURI: process.env.SUPERTOKENS_CONNECTION_URI || 'http://localhost:3567',
            apiKey: process.env.SUPERTOKENS_API_KEY
        },
        appInfo,
        recipeList: [
            EmailPasswordNode.init(),
            SessionNode.init({
                cookieSecure: process.env.NODE_ENV === 'production',
                cookieSameSite: 'lax',
                sessionExpiredStatusCode: 401,
                antiCsrf: 'VIA_TOKEN',
                // Optional: Add custom claims to session
                override: {
                    functions: (originalImplementation) => ({
                        ...originalImplementation,
                        createNewSession: async function (input) {
                            const user = await SuperTokens.getUser(input.userId, input.userContext);
                            const email = user?.loginMethods.find(
                                (lm) => lm.recipeId === 'emailpassword'
                            )?.email;

                            input.accessTokenPayload = {
                                ...input.accessTokenPayload,
                                ...(email ? { email } : {})
                            };

                            return originalImplementation.createNewSession(input);
                        }
                    })
                }
            })
        ],
        isInServerlessEnv: true
    };
};

// ⚠️ CRITICAL: Use module-level flag, NOT SuperTokens.isInitCalled
let superTokensInitialized = false;

export function ensureSuperTokensInit() {
    if (!superTokensInitialized) {
        SuperTokens.init(backendConfig());
        superTokensInitialized = true;
    }
}
```

### ❌ Common Mistake: Broken Init Check

```typescript
// ❌ WRONG - isInitCalled can be undefined
if ((SuperTokens as any).isInitCalled === false) {
    SuperTokens.init(backendConfig());
}

// ✅ CORRECT - Use module-level flag
let superTokensInitialized = false;
if (!superTokensInitialized) {
    SuperTokens.init(backendConfig());
    superTokensInitialized = true;
}
```

---

## Frontend Configuration

### src/lib/supertokens/frontend-config.ts

```typescript
import EmailPasswordReact from 'supertokens-auth-react/recipe/emailpassword';
import SessionReact from 'supertokens-auth-react/recipe/session';
import { SuperTokensConfig } from 'supertokens-auth-react/lib/build/types';

const appInfo = {
    appName: process.env.NEXT_PUBLIC_APP_NAME || 'My App',
    apiDomain: process.env.NEXT_PUBLIC_API_DOMAIN || 'http://localhost:3000',
    websiteDomain: process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000',
    apiBasePath: '/api/auth',
    websiteBasePath: '/auth'
};

export const frontendConfig = (): SuperTokensConfig => {
    return {
        appInfo,
        recipeList: [
            EmailPasswordReact.init(),
            SessionReact.init({
                tokenTransferMethod: 'cookie'
            })
        ]
    };
};
```

### src/components/auth/supertokens-provider.tsx

```typescript
'use client';

import React, { useEffect, useState } from 'react';
import SuperTokensReact from 'supertokens-auth-react';
import { SessionAuth } from 'supertokens-auth-react/recipe/session';
import { frontendConfig } from '@/lib/supertokens/frontend-config';

export function SuperTokensProvider({ children }: { children: React.ReactNode }) {
    const [initialized, setInitialized] = useState(false);

    useEffect(() => {
        if (typeof window !== 'undefined' && !initialized) {
            SuperTokensReact.init(frontendConfig());
            setInitialized(true);
        }
    }, [initialized]);

    if (!initialized) {
        return null;
    }

    // ⚠️ CRITICAL: SessionAuth wrapper is REQUIRED for useSessionContext
    return (
        <SessionAuth requireAuth={false}>
            {children}
        </SessionAuth>
    );
}
```

### ❌ Common Mistake: Missing SessionAuth

```typescript
// ❌ WRONG - useSessionContext won't work
return <>{children}</>;

// ✅ CORRECT - Wrap with SessionAuth
return (
    <SessionAuth requireAuth={false}>
        {children}
    </SessionAuth>
);
```

---

## API Route Handler

### src/app/api/auth/[[...path]]/route.ts

```typescript
import { NextRequest } from 'next/server';
import { ensureSuperTokensInit } from '@/lib/supertokens/config';
import { getAppDirRequestHandler } from 'supertokens-node/nextjs';

// Initialize before creating handler
ensureSuperTokensInit();

const handleRequest = getAppDirRequestHandler();

export async function GET(request: NextRequest) {
    return handleRequest(request);
}

export async function POST(request: NextRequest) {
    return handleRequest(request);
}

export async function DELETE(request: NextRequest) {
    return handleRequest(request);
}

export async function PUT(request: NextRequest) {
    return handleRequest(request);
}

export async function PATCH(request: NextRequest) {
    return handleRequest(request);
}
```

---

## Common Issues & Solutions

### Issue 1: "Initialisation not done"

**Error:** `Error: Initialisation not done. Did you forget to call the SuperTokens.init function?`

**Cause:** Broken initialization check using `isInitCalled`

**Solution:** Use module-level boolean flag (see Backend Configuration)

---

### Issue 2: "Core version not compatible"

**Error:** `Error: The running SuperTokens core version is not compatible with this NodeJS SDK`

**Cause:** SDK CDI version doesn't match Core version

**Solution:** 
1. Check SDK CDI version: `grep cdiSupported node_modules/supertokens-node/lib/build/version.js`
2. Update Core in docker-compose.yml to compatible version
3. Run: `docker-compose pull supertokens && docker-compose up -d supertokens`

---

### Issue 3: "Cannot use useSessionContext outside auth wrapper"

**Error:** `Cannot use useSessionContext outside auth wrapper components`

**Cause:** Missing `SessionAuth` wrapper in provider

**Solution:** Wrap children with `<SessionAuth requireAuth={false}>` (see Frontend Configuration)

---

### Issue 4: SuperTokens Core unhealthy

**Error:** Container status `unhealthy`, curl times out

**Cause:** PostgreSQL connection lost (after long idle time) or missing database

**Solution:**
```bash
# Restart containers
docker-compose restart postgres supertokens

# If "database does not exist" in logs:
docker exec -it <postgres-container> psql -U postgres -c "CREATE DATABASE supertokens;"
docker-compose restart supertokens
```

---

## Verification Checklist

Run these checks after setup:

```bash
# 1. Docker containers healthy
docker-compose ps
# Both should show: (healthy)

# 2. SuperTokens Core responds
curl http://localhost:3567/hello
# Should return: Hello

# 3. API route works
curl -X POST http://localhost:3000/api/auth/signup \
  -H "Content-Type: application/json" \
  -H "rid: emailpassword" \
  -d '{"formFields":[{"id":"email","value":"test@test.com"},{"id":"password","value":"Test123!"}]}'
# Should return: {"status":"OK","user":{...}}

# 4. Next.js server logs show 200
# POST /api/auth/signup 200
```

---

## Environment Variables

### .env.local (Development)

```env
NEXT_PUBLIC_APP_NAME="My App"
NEXT_PUBLIC_APP_URL="http://localhost:3000"
NEXT_PUBLIC_API_DOMAIN="http://localhost:3000"
NEXT_PUBLIC_API_BASE_PATH="/api/auth"

SUPERTOKENS_CONNECTION_URI="http://localhost:3567"
SUPERTOKENS_API_KEY=""
```

### .env.production

```env
NEXT_PUBLIC_APP_NAME="My App"
NEXT_PUBLIC_APP_URL="https://myapp.com"
NEXT_PUBLIC_API_DOMAIN="https://api.myapp.com"
NEXT_PUBLIC_API_BASE_PATH="/api/auth"

SUPERTOKENS_CONNECTION_URI="https://supertokens.myapp.com"
SUPERTOKENS_API_KEY="your-secure-api-key"
```

---

## Quick Start Summary

1. **Install packages:** `npm install supertokens-node supertokens-auth-react supertokens-web-js`
2. **Check CDI version:** `grep cdiSupported node_modules/supertokens-node/lib/build/version.js`
3. **Set Docker Core version** to match CDI
4. **Create init script** for supertokens database
5. **Start Docker:** `docker-compose up -d`
6. **Wait for healthy:** `docker-compose ps`
7. **Create config files** (backend + frontend)
8. **Add SessionAuth wrapper** to provider
9. **Create API route** with `getAppDirRequestHandler`
10. **Test signup** with curl

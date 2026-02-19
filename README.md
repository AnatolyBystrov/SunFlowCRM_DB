# SunFlowCRM - Multi-Tenant Insurance Platform

A modern, multi-tenant CRM and insurance underwriting platform built with **Next.js 16**, **React 19**, **Prisma**, **PostgreSQL**, **Redis**, and **TypeScript**.

**Status:** Production-ready core systems (Authentication, Multi-tenancy, CRM, Notifications)

---

## 🎯 What Is This?

SunFlowCRM is an insurance platform designed for internal use with the following capabilities:

- **CRM Module** - Lead & deal management, sales pipeline, contact tracking
- **Authentication** - Self-hosted or cloud-based auth (SuperTokens/Stack Auth)
- **Multi-Tenancy** - Complete tenant isolation with RLS and audit logging
- **Notifications** - Real-time in-app notifications with event-driven architecture
- **Audit Trail** - Comprehensive logging of all critical business actions

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│              Next.js 16 Frontend (App Router)               │
│          React 19 + TypeScript + Shadcn/Tailwind            │
└───────────────────────┬─────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
    Features/        API Routes       Middleware
    Components       (REST)           (Auth/RLS)
        │               │               │
        └───────────────┼───────────────┘
                        │
                        ▼
        ┌──────────────────────────────┐
        │     Services Layer            │
        │   (BaseService + 14 CRM       │
        │    services: Deal, Lead,      │
        │    Activity, etc.)            │
        └───────────┬────────────────────┘
                    │
        ┌───────────┼────────────┐
        │           │            │
        ▼           ▼            ▼
    PostgreSQL  Redis       SuperTokens
    (Domain)    (BullMQ)    Auth Server
        │           │
        │           ▼
        │       Worker Process
        │       (Notifications)
        │
        └──→ Prisma RLS Extension
            (Tenant Isolation)
```

---

## 📦 Tech Stack

### Frontend
- **Next.js** 16.0.7 - React framework with App Router
- **React** 19.2.0 - UI library
- **TypeScript** 5.7.2 - Type safety
- **Tailwind CSS** 4.0.0 - Utility-first styling
- **Shadcn UI** - High-quality React components (Dialog, Select, Tabs, etc.)
- **React Hook Form** 7.71.1 - Form state management
- **Zod** 4.1.8 - Schema validation
- **TanStack Query** 5.90.20 - Server state management
- **Zustand** 5.0.2 - Client state management
- **TanStack Table** 8.21.2 - Data tables
- **DND Kit** 6.3.1 - Drag & drop
- **Recharts** 2.15.1 - Data visualization

### Backend & Database
- **Prisma** 7.4.0 - ORM for TypeScript
- **PostgreSQL** 16 - Relational database
- **Redis** 7 - In-memory data store (BullMQ)
- **BullMQ** 5.69.3 - Job queue
- **Pg** 8.18.0 - PostgreSQL client

### Authentication
- **SuperTokens** 24.0.1 - Self-hosted auth server (primary)
- **Stack Auth** 2.8.67 - Self-hosted or cloud auth (alternative)

### Infrastructure & DevOps
- **Docker** & **Docker Compose** - Containerization
- **Sentry** 9.19.0 - Error tracking
- **Husky** 9.1.7 - Git hooks
- **ESLint** & **Prettier** - Code quality
- **tsx** 4.21.0 - TypeScript execution

---

## 📂 Project Structure

```
SunFlowCRM/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── api/               # API routes (REST endpoints, 41 routes)
│   │   │   └── crm/          # CRM endpoints (deals, leads, activities, etc.)
│   │   ├── dashboard/         # Protected dashboard pages
│   │   ├── auth/             # Authentication pages
│   │   └── settings/         # Settings pages
│   │
│   ├── components/            # Shared React components (105 files)
│   │   ├── layout/           # Layout components (header, sidebar)
│   │   ├── ui/               # Shadcn UI components
│   │   ├── forms/            # Form components
│   │   └── modal/            # Modal dialogs
│   │
│   ├── features/             # Feature modules (92 files)
│   │   ├── crm/             # CRM UI (leads, deals, contacts, activities)
│   │   ├── notifications/    # Notification UI
│   │   ├── auth/            # Authentication UI
│   │   └── settings/        # Settings UI
│   │
│   ├── lib/                  # Core libraries & services (51 files)
│   │   ├── services/        # Business logic services (14 CRM services)
│   │   │   └── crm/        # CRM services (DealService, LeadService, etc.)
│   │   ├── db/             # Database utilities
│   │   │   ├── prisma.ts
│   │   │   └── prisma-rls-extension.ts  # Row-Level Security
│   │   ├── auth/           # Auth adapters & utilities
│   │   ├── errors/         # Custom error classes
│   │   └── utils/          # Utility functions
│   │
│   ├── server/              # Server-side utilities
│   │   └── notifications/   # Notification processing logic
│   │
│   ├── types/               # TypeScript type definitions
│   ├── hooks/               # Custom React hooks (7 files)
│   └── styles/              # Global styles
│
├── prisma/                  # Database schema
│   ├── schema.prisma        # 25 models (Deal, Lead, Activity, etc.)
│   └── migrations/          # Migration files
│
├── workers/                 # Background workers
│   └── notifications-worker.ts  # BullMQ worker for notifications
│
├── docker-compose.yml       # Infrastructure (PostgreSQL, Redis, SuperTokens)
├── package.json
├── tsconfig.json
├── next.config.ts
└── README.md
```

### Key Directories by Purpose

| Directory | Purpose | Files |
|-----------|---------|-------|
| `src/app/api/` | REST API endpoints | 53 files |
| `src/components/` | Reusable React components | 105 files |
| `src/features/` | Feature modules | 92 files |
| `src/lib/services/` | Business logic services | 14 CRM services |
| `src/lib/db/` | Database & RLS | Prisma + extension |
| `workers/` | Background jobs | BullMQ worker |
| `prisma/` | Database schema | 25 models |

---

## 🚀 Getting Started

### Prerequisites

- **Node.js** 18+ (verify: `node --version`)
- **npm** 8+ or **yarn** / **bun**
- **Docker & Docker Compose** (for infrastructure)
- **PostgreSQL** 16 (via Docker or local)
- **Redis** 7 (via Docker or local)

### Quick Start (5 minutes)

1. **Clone and Install**
   ```bash
   git clone https://github.com/your-org/SunFlowCRM.git
   cd SunFlowCRM
   npm install
   ```

2. **Start Infrastructure** (PostgreSQL, Redis, SuperTokens)
   ```bash
   docker-compose up -d
   # Wait for services to be healthy (check with: docker-compose ps)
   # Verify: docker-compose logs -f supertokens (wait for "API started")
   ```

3. **Setup Environment**
   ```bash
   cp .env.example .env.local
   # Edit .env.local with your settings (optional for local dev)
   # Key variables: DATABASE_URL, REDIS_URL, SUPERTOKENS_CONNECTION_URI, INTERNAL_WORKER_SECRET
   ```

4. **Database Migration & Setup**
   ```bash
   npx prisma migrate dev
   # Creates schema, runs migrations, generates Prisma client
   npx prisma generate
   ```

5. **Start Dev Servers** (in separate terminals)
   ```bash
   # Terminal 1: Next.js frontend + API routes
   npm run dev
   # Access: http://localhost:3000

   # Terminal 2: Notifications worker (background jobs)
   npm run worker:notifications
   # Monitors: Redis queue for notification events
   ```

6. **Access Application**
   - **Frontend**: http://localhost:3000
   - **SuperTokens Dashboard**: http://localhost:3567/auth (admin console)
   - **Prisma Studio**: `npx prisma studio` → http://localhost:5555 (database GUI)
   - **Redis**: localhost:6379 (command: `redis-cli`)
   - **PostgreSQL**: localhost:5432 (user: `postgres`, password: `postgres`)

   **Optional Tools** (start with `docker-compose up -d minio n8n`):
   - **MinIO Console**: http://localhost:9001 (S3 compatible storage)
   - **n8n Automation**: http://localhost:5678 (workflow automation)

---

## ⚙️ Development Scripts

```bash
# Start development server
npm run dev

# Start with specific auth provider
npm run dev:supertokens      # Use SuperTokens
npm run dev:stack           # Use Stack Auth

# Code quality
npm run lint                 # Run ESLint
npm run lint:fix            # Fix lint errors + format
npm run lint:strict         # ESLint with no warnings allowed
npm run format              # Format code with Prettier
npm run format:check        # Check if code is formatted

# Database
npx prisma migrate dev      # Run migrations + create new
npx prisma studio          # Open Prisma Studio
npx prisma generate        # Generate Prisma Client

# Workers
npm run worker:notifications    # Start notifications worker

# Production
npm run build               # Build Next.js app
npm start                   # Start production server
```

---

## 📋 Environment Variables

Create `.env.local` file with:

```bash
# Application
NEXT_PUBLIC_APP_NAME="SunFlowCRM"
NEXT_PUBLIC_APP_URL="http://localhost:3000"
NEXT_PUBLIC_API_DOMAIN="http://localhost:3000"

# Auth Provider (supertokens or stack)
AUTH_PROVIDER="supertokens"
NEXT_PUBLIC_AUTH_PROVIDER="supertokens"

# SuperTokens Configuration
SUPERTOKENS_CONNECTION_URI="http://localhost:3567"
SUPERTOKENS_API_KEY="<generate with: openssl rand -hex 32>"

# Database
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/sun_uw"

# Redis (for BullMQ)
REDIS_URL="redis://localhost:6379"

# Internal Worker Secret (for internal API calls)
INTERNAL_WORKER_SECRET="dev-worker-secret"

# Error Tracking (optional)
SENTRY_AUTH_TOKEN="<your-sentry-token>"
```

---

## 📊 Core Systems

### 1. CRM Module (14 Services, ~4,234 lines)

**Services:**
- **DealService** (702 lines) - Sales opportunities, pipeline progression
- **LeadService** (552 lines) - Lead management, conversion to deals
- **ActivityService** (628 lines) - Tasks, calls, meetings, emails
- **OrganizationService** (383 lines) - Company management
- **PersonService** (316 lines) - Contact management
- **EmailService** (282 lines) - Email tracking & integration
- Plus: TimelineService, DashboardService, StageService, PipelineService, NoteService, FieldDefinitionService, LabelServices

**Key Features:**
- Multi-tenanted with automatic tenant isolation
- Soft deletes (no permanent deletion)
- Audit logging on critical actions
- Activity date auto-computation
- Outbox event publishing for notifications

---

### 2. Multi-Tenancy & Security

**Implementation:**
- Prisma RLS Extension (`src/lib/db/prisma-rls-extension.ts`)
  - Automatic `tenantId` filtering on all queries
  - Relation validation (prevents cross-tenant links)
  - Bypass mechanism for admin operations
  
- BaseService Pattern
  - All services require `tenantId` and `userId` in constructor
  - `ensureTenantAccess()` guard on all entity access
  - Consistent `getTenantFilter()` helper

**Security Layers:**
1. Request authentication (JWT token)
2. Tenant context extraction (from token)
3. Row-level filtering (Prisma extension)
4. Entity access validation (BaseService)

---

### 3. Authentication

**Dual-Provider Support:**
- **SuperTokens** (default) - Self-hosted auth server
- **Stack Auth** (alternative) - Cloud or local deployment

**Features:**
- Invite-only registration (no public signup)
- Automatic user reconciliation
- RBAC support (Admin, Manager, Sales, etc.)
- Session management via cookies

**Flow:**
```
User → Frontend → Auth Provider → Auth Server
  ↓
  └─→ Domain User Created/Updated in PostgreSQL
```

---

### 4. Notifications (Event-Driven)

**Architecture:** Transactional Outbox Pattern

**Flow:**
```
1. Business action (e.g., deal won)
2. OutboxEvent created in same transaction
3. Transaction commits
4. Job enqueued to BullMQ queue (Redis)
5. Worker processes event asynchronously
6. Notifications created, SSE events broadcast
```

**Components:**
- `OutboxEvent` model - Event storage with retry logic
- `Notification` model - In-app notifications
- `NotificationPreference` model - User notification settings
- `workers/notifications-worker.ts` - BullMQ worker (async processing)
- `src/server/notifications/` - Event processing logic

**Reliability:**
- Automatic retries (up to 5 attempts, exponential backoff)
- Atomic claim pattern (only one worker processes each event)
- Error logging and tracking

---

### 5. Audit Logging

**Service:** `AuditService`

**Features:**
- Non-blocking fire-and-forget logging
- Structured action tracking (DEAL_CREATED, DEAL_WON, etc.)
- Entity correlation
- User & timestamp tracking
- JSON metadata storage

**Audit Actions (20+):**
- Auth: AUTH_LOGIN, AUTH_LOGOUT
- CRM: DEAL_CREATED, DEAL_WON, LEAD_CONVERTED, etc.
- Users: USER_INVITED, USER_ROLE_CHANGED

---

## 📊 API Reference

**41 REST Endpoints** organized by entity:

```
CRM Endpoints:
GET/POST    /api/crm/deals              (list, create)
PATCH       /api/crm/deals/[id]         (update)
DELETE      /api/crm/deals/[id]         (soft delete)
POST        /api/crm/deals/[id]/move    (move to stage)
POST        /api/crm/deals/[id]/won     (mark as won)
POST        /api/crm/deals/[id]/lost    (mark as lost)

GET/POST    /api/crm/leads              (+ convert, archive, restore)
GET/POST    /api/crm/activities         (+ bulk operations)
GET/POST    /api/crm/organizations
GET/POST    /api/crm/persons
GET/POST    /api/crm/pipelines
POST        /api/crm/stages
GET/POST    /api/crm/emails
GET/POST    /api/crm/field-definitions
GET/POST    /api/crm/notes
GET         /api/crm/dashboard/...
```

**Full API Documentation:** See [docs/CRM/CRM_API.md](docs/CRM/CRM_API.md)

---

## 🗄️ Database Schema

**25 Models:**
- **Contacts** (2) - Organization, Person
- **Sales** (6) - Pipeline, Stage, Deal, DealLabel, DealLabelLink, DealPermittedUser
- **Leads** (4) - Lead, LeadLabel, LeadLabelLink, LeadPermittedUser
- **Activities** (1) - Activity
- **Emails** (3) - Email, EmailAccount, EmailTrackingEvent
- **Notes** (1) - Note
- **Infrastructure** (7) - Tenant, User, AuditLog, OutboxEvent, Notification, NotificationPreference, EntityWatcher
- **Fields** (1) - FieldDefinition

**Multi-Tenancy:**
- All models include `tenantId` field
- Unique constraints are tenant-scoped
- Soft deletes with `deleted` + `deletedAt`

**Full Schema Reference:** See [docs/CRM/CRM_DATA_MODELS.md](docs/CRM/CRM_DATA_MODELS.md)

---

## 🔍 Documentation

- **[docs/CRM/CRM_README.md](docs/CRM/CRM_README.md)** - CRM module index
- **[docs/CRM/CRM_SERVICES_ARCHITECTURE.md](docs/CRM/CRM_SERVICES_ARCHITECTURE.md)** - 14 services documentation
- **[docs/CRM/CRM_API.md](docs/CRM/CRM_API.md)** - All 41 REST endpoints
- **[docs/CRM/CRM_DATA_MODELS.md](docs/CRM/CRM_DATA_MODELS.md)** - Prisma schema reference
- **[docs/CRM/CRM_INTEGRATIONS.md](docs/CRM/CRM_INTEGRATIONS.md)** - Notifications & event integration
- **[docs/NOTIFICATIONS/implementation_plan.md](docs/NOTIFICATIONS/implementation_plan.md)** - Notification system deep-dive
- **[docs/AUTH/AUTH_ARCHITECTURE_RU.md](docs/AUTH/AUTH_ARCHITECTURE_RU.md)** - Authentication architecture

---

## 🧪 Testing

Currently no automated tests in main repo. Testing guidance:

- **Unit Tests** - Consider Jest + React Testing Library for components
- **Integration Tests** - Prisma with test database
- **E2E Tests** - Playwright or Cypress for full workflows
- **API Tests** - Postman or automated testing framework

---

## 🚀 Deployment

### Local Development
```bash
# 1. Start infrastructure (PostgreSQL, Redis, SuperTokens)
docker-compose up -d

# 2. Wait for services to be healthy
docker-compose ps    # Check Status column
docker-compose logs -f supertokens  # Wait for "API started"

# 3. Install dependencies and run migrations
npm install
npx prisma migrate dev
npx prisma generate

# 4. Setup environment (optional for local dev)
cp .env.example .env.local

# 5. Start development servers (in separate terminals)
# Terminal 1: Frontend + API
npm run dev

# Terminal 2: Notifications worker
npm run worker:notifications

# 6. Access services
# Frontend: http://localhost:3000
# SuperTokens: http://localhost:3567/auth
# Prisma Studio: npx prisma studio → http://localhost:5555
# Redis: redis-cli -h localhost -p 6379
# PostgreSQL: psql -h localhost -U postgres -d sun_uw
```

### Production Checklist
- [ ] Set production environment variables
- [ ] Use strong `SUPERTOKENS_API_KEY` and `INTERNAL_WORKER_SECRET`
- [ ] Configure PostgreSQL backups
- [ ] Set up Redis persistence
- [ ] Enable HTTPS/SSL
- [ ] Configure Sentry for error tracking
- [ ] Run migrations: `npx prisma migrate deploy`
- [ ] Build application: `npm run build`
- [ ] Start server: `npm start`
- [ ] Run notifications worker separately

---

## 📞 Support & Contributing

For questions, bugs, or feature requests:
1. Check [documentation](docs/)
2. Review [existing issues](https://github.com/your-org/SunFlowCRM/issues)
3. Create a new issue with details

---

## 📄 License

Internal Use Only - SunFlowCRM

---

## 🎉 Getting Help

| Topic | Resource |
|-------|----------|
| CRM Features | [docs/CRM/CRM_README.md](docs/CRM/CRM_README.md) |
| API Endpoints | [docs/CRM/CRM_API.md](docs/CRM/CRM_API.md) |
| Services | [docs/CRM/CRM_SERVICES_ARCHITECTURE.md](docs/CRM/CRM_SERVICES_ARCHITECTURE.md) |
| Database Schema | [docs/CRM/CRM_DATA_MODELS.md](docs/CRM/CRM_DATA_MODELS.md) |
| Notifications | [docs/CRM/CRM_INTEGRATIONS.md](docs/CRM/CRM_INTEGRATIONS.md) |
| Authentication | [docs/AUTH/AUTH_ARCHITECTURE_RU.md](docs/AUTH/AUTH_ARCHITECTURE_RU.md) |

---

**Last Updated:** February 19, 2026  
**Current Version:** 1.0.0 (Production-Ready Core)  
**Next Milestone:** v2.0 (Advanced Permissions, Analytics, Workflow Automation)

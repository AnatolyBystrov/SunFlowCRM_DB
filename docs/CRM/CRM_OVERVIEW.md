# CRM Module - Overview

## What is CRM?

The CRM module is a comprehensive Sales & Relationship Management system integrated into SunApp AG platform. It enables teams to manage the complete sales lifecycle: from prospecting (leads) through deal closure and customer relationship management.

---

## Core Features

### 1. Contact Management
- **Organizations** - Company profiles with domain, industry, size, custom data
- **Persons** - Individual contacts with job titles, emails, auto-linking to orgs by domain

### 2. Sales Pipeline
- **Pipelines** - Multiple sales processes (e.g., "Enterprise Sales", "SMB Fast Track")
- **Stages** - Pipeline steps with win probability (0-100%)
- **Deals** - Opportunities progressing through stages, with values and close dates

### 3. Lead Management
- **Leads** - Pre-pipeline prospects with source tracking
- **Lead Conversion** - Atomic conversion to deals with automatic relationship creation
- **Lead Status** - OPEN, ARCHIVED, LOST, CONVERTED

### 4. Activity Tracking
- **Activities** - Tasks, calls, meetings, emails, deadlines
- **Auto-dating** - Parent entities track `lastActivityDate` and `nextActivityDate`
- **Bulk Operations** - Mark done, change owner, shift dates across multiple activities

### 5. Email Integration
- **Email Records** - Track incoming/outgoing emails
- **Auto-linking** - Link emails to deals, leads, persons, orgs
- **Tracking Events** - Open/click tracking support

### 6. Custom Fields
- **Dynamic Fields** - Add TEXT, NUMBER, DATE, SELECT, MULTI_SELECT fields to entities
- **Per-Entity Type** - Different schemas for Deals, Leads, Persons, Organizations

### 7. Real-Time Notifications
- **Event-Driven** - Notify team when activity assigned, deal won, lead converted
- **Smart Recipients** - Only notify relevant people (owner, watchers, team)
- **In-App + SSE** - Real-time updates via server-sent events

---

## Architecture

### Modular Service Layer

```
BaseService (tenant isolation, auth)
├── ActivityService       - Task/call/meeting/email management
├── DealService          - Deal CRUD + pipeline operations
├── LeadService          - Lead CRUD + conversion
├── OrganizationService  - Company management + auto-linking
├── PersonService        - Contact management
├── EmailService         - Email record tracking
├── PipelineService      - Sales process templates
├── StageService         - Pipeline stage configuration
├── NoteService          - Text notes on entities
├── DashboardService     - KPIs and metrics
└── (Label & Field services)
```

### REST API (41 Endpoints)

Organized by entity:
- 7 endpoints for **Deals** (list, create, read, update, move, won, lost)
- 8 endpoints for **Leads** (+ convert, archive, restore)
- 3 endpoints for **Activities** (+ bulk operations)
- 2 endpoints for **Persons**
- 3 endpoints for **Organizations**
- 3 endpoints for **Pipelines** (+ stages + deals grouped)
- 2 endpoints for **Stages**
- 2 endpoints for **Emails**
- 1 endpoint for **Notes**
- 2 endpoints for **Field Definitions**
- 2 endpoints for **Dashboard**

### Data Model

15+ Prisma models with:
- **Multi-tenancy** - All data isolated by `tenantId`
- **Soft deletes** - No permanent deletion; `deleted: true` + `deletedAt` timestamp
- **Relationships** - Owner, creator, linked entities, labels, custom fields
- **Audit trail** - `createdAt`, `updatedAt` on all entities
- **Automatic dates** - `lastActivityDate`, `nextActivityDate` computed from activities

---

## Data Flow

### 1. Creating a Deal
```
User → POST /api/crm/deals
↓
DealService.create()
├─ Validate pipeline/stage/person/org
├─ Create deal
└─ Publish ACTIVITY_ASSIGNED if owner specified
↓
Notification Worker
├─ Resolve recipients (deal owner + team)
├─ Create notification records
└─ Emit SSE event to UI
↓
UI updates bell icon + notification list
```

### 2. Moving Deal to Stage
```
User drags deal → PUT /api/crm/deals/[id]/move
↓
DealService.moveToStage()
├─ $transaction {
│  ├─ Update deal (stage, stageChangeTime)
│  ├─ Auto-set status: WON if 100% prob, LOST if 0%
│  └─ Publish DEAL_STAGE_CHANGED event
│  └─ Publish DEAL_WON/LOST if status changed
│}
├─ enqueueOutboxJob(outboxEventId)
└─ Audit log: DEAL_MOVED
↓
Notification Worker processes events (same flow as above)
```

### 3. Converting Lead to Deal
```
User → POST /api/crm/leads/[id]/convert
↓
LeadService.convertToDeal()
├─ $transaction {
│  ├─ Create deal (copy lead data)
│  ├─ Update lead: status=CONVERTED, convertedDealId=deal_id
│  └─ Publish LEAD_CONVERTED event
│}
├─ enqueueOutboxJob(outboxEventId)
└─ Audit log: LEAD_CONVERTED
↓
Notification + UI updates
```

---

## Notifications Integration

### Events Published by CRM

| Event | Trigger | Recipients |
|-------|---------|-----------|
| `ACTIVITY_ASSIGNED` | Activity created or owner changed | New owner + watchers |
| `DEAL_STAGE_CHANGED` | Deal moved to different stage | Deal owner + watchers + team |
| `DEAL_WON` | Deal marked won (manually or via 100% stage) | Deal owner + watchers + team |
| `DEAL_LOST` | Deal marked lost (manually or via 0% stage) | Deal owner + watchers + team |
| `LEAD_ASSIGNED` | Lead created or owner reassigned | New owner + watchers |
| `LEAD_CONVERTED` | Lead converted to deal | Lead owner/creator + watchers |

### Reliability Pattern

Uses **Transactional Outbox**:
1. Business event published inside DB transaction (atomic)
2. Job enqueued to BullMQ after transaction commits
3. Worker processes event with retries (exponential backoff)
4. Failed events logged with error details; operator can retry

---

## Multi-Tenancy & Security

### Tenant Isolation
- All queries filtered by `tenantId` automatically
- Services instantiated with tenant context
- Soft deletes scoped per tenant
- No cross-tenant data leakage

### Authentication
- Via JWT token in Authorization header
- User context extracted from token (userId, tenantId, roles)
- All endpoints require valid token

### Authorization
- Role-based access control (RBAC) planned
- Currently: owner/creator permissions + team visibility
- Roadmap: Custom permission models per entity

---

## Key Concepts

### Activity Dates

Auto-computed for Deal, Lead, Person, Organization:

```typescript
lastActivityDate = MAX(activity.completedAt)  // Most recent done activity
nextActivityDate = MIN(activity.dueAt)        // Earliest pending activity
```

Updated whenever activities change.

### Deal Status

Automatically transitioned based on stage probability:
- Stage probability ≥ 100% → Deal status = WON
- Stage probability ≤ 0% AND stage name contains "lost" → Deal status = LOST
- Otherwise → OPEN

Cannot be manually set; only changed via stage move or explicit `markAsWon`/`markAsLost`.

### Soft Deletes

All CRM entities support soft delete:
```sql
UPDATE deal SET deleted = true, deletedAt = now() WHERE id = '...';
```

Allows data recovery and compliance with retention policies.

---

## Performance & Scalability

### Indexing Strategy
- Tenant isolation: `@@index([tenantId])` on all models
- Business queries: `tenantId + status`, `tenantId + ownerId + dueAt`
- Soft delete efficiency: `tenantId + deleted`

### Pagination
- Cursor-based pagination for lists (efficient, stable)
- Default limit: 20, max: 100 per request
- Prevents full-table scans

### Caching Opportunities (v2)
- Pipelines & stages (low write frequency)
- User permissions/roles
- Custom field definitions
- Dashboard KPIs (pre-computed hourly)

---

## Common Workflows

### For Sales Rep
1. Create lead from prospect
2. Nurture via activities (calls, emails)
3. Convert to deal when ready to sell
4. Move deal through pipeline stages
5. Mark won or lost at closure

### For Sales Manager
1. View dashboard: pipeline summary, team performance
2. Monitor deals by stage, person, value
3. Generate reports on win rates, sales velocity
4. Manage pipelines and stage configurations
5. Set up team visibility and permissions

### For Administrator
1. Configure pipelines (B2B, SMB, Enterprise)
2. Define custom fields for tracking
3. Set up labels for categorization
4. Manage email integrations
5. Monitor audit logs for compliance

---

## Documentation Structure

Navigate documentation via:
- **[CRM_README.md](./CRM_README.md)** - Documentation index & quick links
- **[CRM_SERVICES_ARCHITECTURE.md](./CRM_SERVICES_ARCHITECTURE.md)** - 14 services, patterns, transactions
- **[CRM_API.md](./CRM_API.md)** - All 41 endpoints with examples
- **[CRM_DATA_MODELS.md](./CRM_DATA_MODELS.md)** - Prisma schema reference
- **[CRM_INTEGRATIONS.md](./CRM_INTEGRATIONS.md)** - Notifications, events, cross-domain logic

---

## Version History

**v1.0** (Current - Feb 2026)
- Contacts, Leads, Deals, Activities, Emails
- Multi-pipeline support with stages
- Soft delete & multi-tenancy
- Audit logging
- Notification integration (outbox pattern)
- Custom fields

**v2.0** (Planned)
- Advanced permission models (team/company visibility)
- Deal forecasting & analytics
- Pipeline analytics & health
- Calendar integration
- Workflow automation
- API webhooks

---

## Getting Started

1. **Read:** This overview + [CRM_README.md](./CRM_README.md)
2. **Explore:** [CRM_SERVICES_ARCHITECTURE.md](./CRM_SERVICES_ARCHITECTURE.md) to understand services
3. **Integrate:** [CRM_INTEGRATIONS.md](./CRM_INTEGRATIONS.md) for notification events
4. **API Reference:** [CRM_API.md](./CRM_API.md) for endpoint details
5. **Data Model:** [CRM_DATA_MODELS.md](./CRM_DATA_MODELS.md) for schema

---

## Support

For issues or questions:
1. Check relevant documentation files
2. Review service code in `src/lib/services/crm/`
3. Check API routes in `src/app/api/crm/`
4. Open GitHub issue with details

# CRM Services Architecture

## Overview

The CRM module consists of 14 service classes that handle all business logic for the sales pipeline. All services extend `BaseService` and follow a consistent pattern for tenant isolation, error handling, and audit logging.

**Total:** ~4,234 lines of code across 14 service files.

---

## Service Hierarchy

```
BaseService (provides tenantId, userId, ensureTenantAccess, getTenantFilter)
├── ActivityService (628 lines)
├── DealService (702 lines)
├── LeadService (552 lines)
├── OrganizationService (383 lines)
├── PersonService (316 lines)
├── EmailService (282 lines)
├── TimelineService (241 lines)
├── DashboardService (207 lines)
├── StageService (197 lines)
├── PipelineService (195 lines)
├── FieldDefinitionService (195 lines)
├── NoteService (167 lines)
├── DealLabelService (85 lines)
└── LeadLabelService (84 lines)
```

---

## Core Service Descriptions

### 1. ActivityService (628 lines)

**Purpose:** Manages activities (calls, meetings, tasks, emails, deadlines, lunch).

**Key Methods:**
- `list(filters)` - List activities with pagination and filtering
- `getById(id)` - Get activity with relations (Deal, Lead, Person, Org)
- `create(input)` - Create activity and trigger `ACTIVITY_ASSIGNED` notification
- `update(id, input)` - Update activity, recompute parent dates
- `markDone(id)` - Mark activity as completed
- `markUndone(id)` - Reopen completed activity
- `bulkAction(ids, action, ...)` - Bulk operations (markDone, changeOwner, shiftDueDate, delete)
- `delete(id)` - Soft delete activity

**Notification Events:**
- `ACTIVITY_ASSIGNED` - When activity created or owner reassigned
  - Payload: `assigneeId`, `ownerId`, `activitySubject`, `activityType`, `dueAt`, `dealId`, `leadId`

**Special Feature: Activity Date Recomputation**
```typescript
recomputeActivityDates(entityKind, entityId) {
  // Updates lastActivityDate = max(completedAt) from done activities
  // Updates nextActivityDate = min(dueAt) from pending activities
  // Applied to: Deal, Lead, Person, Organization
}
```

**Validation:**
- Activity type must be valid enum (CALL, MEETING, TASK, EMAIL, DEADLINE, LUNCH)
- Parent entity (Deal/Lead/Person/Org) must exist and belong to tenant
- Due date cannot be in the past for pending activities

---

### 2. DealService (702 lines)

**Purpose:** Manages sales deals and pipeline progression.

**Key Methods:**
- `list(filters)` - List deals with pagination, pipeline/stage/status filters
- `getByPipeline(pipelineId)` - Get deals grouped by stage for pipeline view
- `getById(id)` - Get deal with full relations
- `create(input)` - Create deal, publish `ACTIVITY_ASSIGNED` if assigned to someone
- `update(id, input)` - Update deal fields (preserves stageChangeTime)
- `moveToStage(id, stageId)` - Move deal to stage, auto-update status based on probability, publish `DEAL_STAGE_CHANGED` + optional `DEAL_WON`/`DEAL_LOST`
- `markAsWon(id)` - Mark deal won, set `firstWonTime`, publish `DEAL_WON`
- `markAsLost(id, reason)` - Mark deal lost, publish `DEAL_LOST`
- `reopen(id)` - Reopen deal (WON/LOST → OPEN)
- `delete(id)` - Soft delete deal

**Notification Events:**
- `DEAL_STAGE_CHANGED` - When deal moves to different stage
  - Payload: `dealTitle`, `stageName`, `fromStageId`, `toStageId`, `ownerId`
- `DEAL_WON` - When deal marked as won or moved to 100% probability stage
  - Payload: `dealTitle`, `ownerId`, `value`, `currency`
- `DEAL_LOST` - When deal marked as lost or moved to lost stage
  - Payload: `dealTitle`, `ownerId`, `value`, `currency`

**Transaction Patterns:**
```typescript
// moveToStage: Multiple outbox events in single transaction
prisma.$transaction(async (tx) => {
  1. Update deal (stage + potential status change)
  2. Publish DEAL_STAGE_CHANGED outbox event
  3. If probability >= 100: Publish DEAL_WON event
  4. If probability <= 0: Publish DEAL_LOST event
}, { timeout: 10000 })
```

**Auto-Status Logic:**
- Stage probability >= 100 → Status becomes WON
- Stage probability <= 0 AND stage name contains "lost" → Status becomes LOST

**Validation:**
- Stage must belong to deal's pipeline
- Person/Org/Owner must belong to tenant
- Cannot move deal to stage in different pipeline

---

### 3. LeadService (552 lines)

**Purpose:** Manages sales leads and conversion to deals.

**Key Methods:**
- `list(filters)` - List leads with status, source, owner filters
- `getById(id)` - Get lead with full relations
- `create(input)` - Create lead, publish `LEAD_ASSIGNED` notification
- `update(id, input)` - Update lead, publish `LEAD_ASSIGNED` if owner changes
- `archive(id)` - Change status to ARCHIVED
- `restore(id)` - Restore from ARCHIVED to OPEN
- `markSeen(id)` - Mark lead as seen by user
- `convertToDeal(id, input)` - Convert lead to deal, publish `LEAD_CONVERTED`
- `delete(id)` - Soft delete lead

**Notification Events:**
- `LEAD_ASSIGNED` - When lead created or owner reassigned
  - Payload: `assigneeId`, `leadTitle`, `source`
- `LEAD_CONVERTED` - When lead converted to deal
  - Payload: `leadTitle`, `ownerId`, `dealId`, `dealTitle`

**Validation:**
- Lead must have at least Person OR Organization link
- Cannot archive already-converted lead
- Cannot convert lead that's already converted

---

### 4. OrganizationService (383 lines)

**Purpose:** Manages organizations (companies).

**Key Methods:**
- `list(filters)` - List organizations with search and pagination
- `getById(id)` - Get organization with activities, persons, deals
- `create(input)` - Create organization
- `update(id, input)` - Update organization fields
- `attachPersonsByDomain(id, domain)` - Auto-link persons by email domain
- `delete(id)` - Soft delete organization

**Relationships:**
- Owns multiple Persons
- Linked to multiple Deals
- Linked to multiple Activities

**Audit Actions:**
- ORGANIZATION_CREATED, ORGANIZATION_UPDATED, ORGANIZATION_DELETED

---

### 5. PersonService (316 lines)

**Purpose:** Manages persons (contacts).

**Key Methods:**
- `list(filters)` - List persons with organization and pagination
- `getById(id)` - Get person with relations
- `create(input)` - Create person
- `update(id, input)` - Update person
- `delete(id)` - Soft delete person

**Validation:**
- Email uniqueness within tenant (if provided)
- Organization must belong to tenant (if linked)

---

### 6. PipelineService (195 lines)

**Purpose:** Manages sales pipelines.

**Key Methods:**
- `list()` - List all pipelines for tenant
- `getById(id)` - Get pipeline with stages
- `create(input)` - Create pipeline, optionally set as default
- `update(id, input)` - Update pipeline name/default status (atomic)
- `delete(id)` - Soft delete pipeline
- `setAsDefault(id)` - Atomically set as default (unset others)

**Atomic Operations:**
```typescript
// setAsDefault: Atomic toggle
prisma.$transaction(async (tx) => {
  1. Update all other pipelines: isDefault = false
  2. Update this pipeline: isDefault = true
})
```

---

### 7. StageService (197 lines)

**Purpose:** Manages pipeline stages.

**Key Methods:**
- `list(pipelineId)` - List stages for pipeline ordered by sort order
- `getById(id)` - Get stage
- `create(input)` - Create stage with probability (0-100)
- `update(id, input)` - Update stage fields
- `reorder(stages)` - Batch reorder stages
- `delete(id)` - Soft delete stage

**Rotten Deal Detection:**
- `isRotten` flag and `rottenDays` threshold
- Logic: If deal in this stage > rottenDays → deal becomes "rotten"

---

### 8. NoteService (167 lines)

**Purpose:** Manages notes on deals, leads, persons, organizations.

**Key Methods:**
- `list(filters)` - List notes for entity (Deal/Lead/Person/Org)
- `getById(id)` - Get note
- `create(input)` - Create note
- `update(id, input)` - Update note body/pinned status
- `delete(id)` - Soft delete note

---

### 9. EmailService (282 lines)

**Purpose:** Manages email records and integration with email providers.

**Key Methods:**
- `list(filters)` - List emails with direction and date filters
- `getById(id)` - Get email with tracking events
- `create(input)` - Create email record
- `linkToEntity(emailId, entityKind, entityId)` - Link email to Deal/Lead/Person/Org
- `unlinkFromEntity(emailId)` - Unlink email
- `delete(id)` - Soft delete email

**Email Providers:**
- GMAIL, OUTLOOK, IMAP

**Auto-Linking:**
- Via `attachPersonsByDomain()` in OrganizationService
- Person → Organization matching by email domain

---

### 10. TimelineService (241 lines)

**Purpose:** Aggregates and fetches activity timeline for deals, leads, persons, organizations.

**Key Methods:**
- `getTimeline(entityKind, entityId, opts)` - Get mixed timeline (activities + notes) sorted by date

---

### 11. DashboardService (207 lines)

**Purpose:** Provides dashboard KPIs and metrics.

**Key Methods:**
- `getKPIs()` - Deal counts by status, pipeline, stage
- `getRecentActivities()` - Recent activities for current user
- `getDealsByStage(pipelineId)` - Deals grouped by stage with counts

---

### 12. FieldDefinitionService (195 lines)

**Purpose:** Manages custom field definitions for CRM entities.

**Key Methods:**
- `list(entityType)` - List fields for entity type (DEAL, LEAD, PERSON, ORGANIZATION)
- `getById(id)` - Get field definition
- `create(input)` - Create field (key must be alphanumeric+underscore)
- `update(id, input)` - Update field label/type/options
- `delete(id)` - Soft delete field

**Validation:**
- Key must match `/^[a-zA-Z0-9_]+$/`
- Key must be unique per entity type
- Only custom fields, not built-in

---

### 13-14. LabelServices (85 + 84 lines)

**Purpose:** Manage deal and lead labels for categorization.

**Key Methods:**
- `list()` - List labels
- `getById(id)` - Get label
- `create(input)` - Create label with color
- `update(id, input)` - Update label
- `delete(id)` - Soft delete label

---

## BaseService Pattern

All CRM services inherit from `BaseService` which provides:

```typescript
class BaseService {
  protected tenantId: string;
  protected userId: string;

  // Enforce tenant access; throws TenantAccessError if mismatched
  protected ensureTenantAccess<T extends { tenantId: string } | null>(entity: T): asserts entity is NonNullable<T>

  // Get Prisma filter for tenant isolation
  protected getTenantFilter(): { tenantId: string }

  // Get Prisma filter for active (non-deleted) entities
  protected getActiveFilter(): { deleted: false }
}
```

---

## Common Patterns

### 1. Error Handling

All services use custom error classes:

```typescript
throw new ValidationError('Field X is required');           // 400
throw new NotFoundError('Deal');                             // 404
throw new BusinessRuleError('Cannot convert already-converted lead'); // 422
throw new TenantAccessError();                               // 403
```

### 2. Audit Logging

Every business-critical action is logged:

```typescript
await AuditService.log({
  tenantId,
  userId,
  action: AuditActions.DEAL_WON,
  module: 'DEALS',
  entityId: deal.id,
  entityType: 'Deal',
  details: { title, value, currency }
});
```

### 3. Outbox Event Publishing

For events that trigger notifications:

```typescript
const outboxId = await publishOutboxEvent(tx, {
  tenantId,
  actorUserId: this.userId,
  type: NotificationEventType.DEAL_WON,
  entityKind: 'deal',
  entityId: dealId,
  payload: { dealTitle, ownerId, value, currency }
});
// After transaction commits:
enqueueOutboxJob(outboxId);
```

### 4. Transaction Patterns

For operations with side effects:

```typescript
await prisma.$transaction(async (tx) => {
  // 1. Update main entity
  const updated = await tx.deal.update({ ... });
  
  // 2. Publish outbox events inside transaction
  await publishOutboxEvent(tx, { ... });
  
  // 3. Return result
  return updated;
}, { timeout: 10000 });

// 4. Enqueue jobs after transaction commits
enqueueOutboxJob(outboxId);
```

### 5. Soft Delete Pattern

All entities support soft delete:

```typescript
// In Prisma schema:
deleted     Boolean   @default(false)
deletedAt   DateTime?

// In service queries:
where: {
  ...getTenantFilter(),
  deleted: false
}
```

---

## Activity Date Recomputation

When an activity is created, updated, or completed, parent entities must update their activity dates:

```typescript
// lastActivityDate = max(completedAt) from all done activities
// nextActivityDate = min(dueAt) from all pending (done=false) activities
// Applied to: Deal, Lead, Person, Organization
```

**Triggered On:**
- Activity created/updated/deleted
- Activity marked done/undone

**Benefits:**
- Quick access to when entities were last touched
- Planning view: see what's coming next
- No separate query needed for dashboard

---

## Tenant Isolation

Every service method:
1. Receives `user.tenantId` and `user.id` from API route
2. Passes to service constructor via `createService(tenantId, userId)`
3. All queries automatically filtered by `tenantId`
4. `ensureTenantAccess()` validates any fetched entity

```typescript
// In API route:
return await withCurrentUser(request, async (user) => {
  const service = new DealService(user.tenantId, user.id);
  const deal = await service.getById(dealId);
  // If deal.tenantId !== user.tenantId → TenantAccessError thrown
});
```

---

## Integration with Notifications

6 events are published by CRM services:

| Event | Service | Trigger |
|-------|---------|---------|
| `ACTIVITY_ASSIGNED` | ActivityService | Activity created or owner changed |
| `DEAL_STAGE_CHANGED` | DealService | Deal moved to different stage |
| `DEAL_WON` | DealService | Deal marked won or moved to 100% stage |
| `DEAL_LOST` | DealService | Deal marked lost or moved to lost stage |
| `LEAD_ASSIGNED` | LeadService | Lead created or owner changed |
| `LEAD_CONVERTED` | LeadService | Lead converted to deal |

Events are:
- Published inside transactions (atomic with business data)
- Enqueued to BullMQ queue after transaction commits
- Processed by notifications-worker
- Delivered via SSE to real-time UI

---

## Quality Metrics

| Metric | Value |
|--------|-------|
| Total Service Code | ~4,234 lines |
| Services Extending BaseService | 14 / 14 (100%) |
| Services with Audit Logging | 14 / 14 (100%) |
| Services Publishing Events | 3 / 14 (21%) |
| Soft Delete Pattern Usage | 14 / 14 (100%) |
| Tenant Isolation Pattern | 14 / 14 (100%) |
| Avg Lines per Service | 302 |
| Largest Service | DealService (702 lines) |
| Smallest Service | DealLabelService (85 lines) |

---

## Best Practices

1. **Always use `$transaction` for multi-step operations**
   - Ensures atomicity with outbox events
   - Set explicit `timeout` for operations with multiple outbox events

2. **Publish outbox events inside transaction**
   - Guarantees at-least-once delivery
   - Prevents orphaned events if business operation fails

3. **Enqueue jobs after transaction commits**
   - Avoids processing events for rolled-back operations
   - Improves reliability in failure scenarios

4. **Use `ensureTenantAccess()` for every fetched entity**
   - Prevents accidental cross-tenant data access
   - Converts to TenantAccessError with proper logging

5. **Validate entity relationships early**
   - Stage belongs to Deal's pipeline
   - Person/Org belong to same tenant
   - Reduces database calls and improves UX error messages

6. **Batch activity date recomputation**
   - Called after activity changes
   - Updates parent entities in single query
   - Essential for performance at scale

# CRM Integrations & Notifications

## Overview

The CRM module integrates with the Notifications system via the **Transactional Outbox Pattern**. Business events (deal moved, lead assigned, activity completed) trigger notifications to relevant users in real-time.

---

## Outbox Event Publishing in CRM

### Pattern Overview

```
1. Business action in service (e.g., deal.moveToStage)
   ↓
2. Wrap in Prisma transaction
   ├─ Update business data
   └─ Publish outbox event (inside transaction)
   ↓
3. Transaction commits
   ↓
4. Enqueue BullMQ job (after commit)
   ↓
5. Worker processes event
   ├─ Resolve recipients
   ├─ Check preferences
   ├─ Create notification rows
   └─ Emit SSE to clients
```

### Example: Deal Stage Change

```typescript
// In DealService.moveToStage()
const { deal, outboxIds } = await prisma.$transaction(
  async (tx) => {
    // 1. Update deal
    const updated = await tx.deal.update({
      where: { id },
      data: { stageId, stageChangeTime: new Date() }
    });

    const ids: string[] = [];

    // 2. Always publish DEAL_STAGE_CHANGED
    ids.push(await publishOutboxEvent(tx, {
      tenantId: this.tenantId,
      actorUserId: this.userId,
      type: NotificationEventType.DEAL_STAGE_CHANGED,
      entityKind: 'deal',
      entityId: id,
      payload: {
        dealTitle: existing.title,
        stageName: stage.name,
        fromStageId: existing.stageId,
        toStageId: stageId,
        ownerId: existing.ownerId,
      }
    }));

    // 3. If status auto-changes to WON, also publish DEAL_WON
    if (probability >= 100) {
      ids.push(await publishOutboxEvent(tx, {
        tenantId: this.tenantId,
        actorUserId: this.userId,
        type: NotificationEventType.DEAL_WON,
        entityKind: 'deal',
        entityId: id,
        payload: { dealTitle: existing.title, ownerId: existing.ownerId }
      }));
    }

    return { deal: updated, outboxIds: ids };
  },
  { timeout: 10000 } // Multiple operations need explicit timeout
);

// 4. After transaction commits, enqueue jobs
outboxIds.forEach((oid) => enqueueOutboxJob(oid));
```

---

## CRM Notification Events

### 1. ACTIVITY_ASSIGNED

**Trigger:** Activity created or owner reassigned

**Recipients:**
- New owner (assignee)
- Optionally: watchers on Deal/Lead/Person/Org if configured

**Payload:**
```typescript
{
  assigneeId: string;        // User receiving activity
  ownerId: string;           // Activity owner
  activitySubject: string;   // e.g., "Follow up on pricing"
  activityType: string;      // CALL, MEETING, TASK, EMAIL, DEADLINE, LUNCH
  dueAt: string | null;      // ISO date or null
  dealId?: string;           // Parent deal ID if linked
  leadId?: string;           // Parent lead ID if linked
}
```

**Template:**
```
Title:  "Activity assigned to you"
Body:   "{{actorName}} assigned you \"{{activitySubject}}\""
```

**When Published:**
```typescript
// ActivityService.create()
const outboxId = await publishOutboxEvent(tx, {
  type: NotificationEventType.ACTIVITY_ASSIGNED,
  payload: { assigneeId, ownerId, activitySubject, ... }
});

// ActivityService.update() - only if owner changed
if (input.ownerId && input.ownerId !== existing.ownerId) {
  await publishOutboxEvent(tx, { type: ACTIVITY_ASSIGNED, ... });
}
```

---

### 2. DEAL_STAGE_CHANGED

**Trigger:** Deal moved to different stage

**Recipients:**
- Deal owner
- Team members with deal visibility
- Watchers on deal

**Payload:**
```typescript
{
  dealTitle: string;        // Deal name
  stageName: string;        // Target stage name
  fromStageId: string;
  toStageId: string;
  ownerId: string;          // Deal owner
}
```

**Template:**
```
Title:  "Deal moved"
Body:   "{{actorName}} moved \"{{dealTitle}}\" to {{stageName}}"
```

**When Published:**
```typescript
// DealService.moveToStage()
// Always published when stage changes
ids.push(await publishOutboxEvent(tx, {
  type: NotificationEventType.DEAL_STAGE_CHANGED,
  payload: { dealTitle, stageName, fromStageId, toStageId, ownerId }
}));
```

---

### 3. DEAL_WON

**Trigger:** Deal marked as won OR moved to 100% probability stage

**Recipients:**
- Deal owner
- Team members
- Watchers

**Payload:**
```typescript
{
  dealTitle: string;
  ownerId: string;
  value?: string;           // Deal amount
  currency?: string;        // Currency code
}
```

**Template:**
```
Title:  "Deal won!"
Body:   "\"{{dealTitle}}\" was marked as won"
```

**When Published:**
```typescript
// DealService.markAsWon()
const outboxId = await publishOutboxEvent(tx, {
  type: NotificationEventType.DEAL_WON,
  payload: { dealTitle, ownerId, value, currency }
});

// DealService.moveToStage() - if probability >= 100
if (probability >= 100) {
  ids.push(await publishOutboxEvent(tx, {
    type: NotificationEventType.DEAL_WON,
    ...
  }));
}
```

---

### 4. DEAL_LOST

**Trigger:** Deal marked as lost OR moved to lost stage (0% probability)

**Recipients:**
- Deal owner
- Team members
- Watchers

**Payload:**
```typescript
{
  dealTitle: string;
  ownerId: string;
  value?: string;
  currency?: string;
}
```

**Template:**
```
Title:  "Deal lost"
Body:   "\"{{dealTitle}}\" was marked as lost"
```

---

### 5. LEAD_ASSIGNED

**Trigger:** Lead created or owner reassigned

**Recipients:**
- New owner (assignee)
- Watchers on lead

**Payload:**
```typescript
{
  assigneeId: string;       // User receiving lead
  leadTitle: string;
  source?: string;          // Lead source (e.g., "web_form", "email")
}
```

**Template:**
```
Title:  "Lead assigned to you"
Body:   "{{actorName}} assigned you lead \"{{leadTitle}}\""
```

**When Published:**
```typescript
// LeadService.update() - if owner changed
if (input.ownerId && input.ownerId !== existing.ownerId) {
  await publishOutboxEvent(tx, {
    type: NotificationEventType.LEAD_ASSIGNED,
    payload: { assigneeId: input.ownerId, leadTitle: updated.title, source: updated.source }
  });
}
```

---

### 6. LEAD_CONVERTED

**Trigger:** Lead converted to deal

**Recipients:**
- Lead owner
- Lead creator
- Watchers

**Payload:**
```typescript
{
  leadTitle: string;
  ownerId: string;
  dealId: string;           // Newly created deal ID
  dealTitle: string;        // Deal name
}
```

**Template:**
```
Title:  "Lead converted"
Body:   "\"{{leadTitle}}\" was converted to a deal"
```

**When Published:**
```typescript
// LeadService.convertToDeal()
const outboxId = await publishOutboxEvent(tx, {
  type: NotificationEventType.LEAD_CONVERTED,
  payload: { leadTitle, ownerId, dealId, dealTitle }
});
```

---

## Recipient Resolution in CRM

The `resolveRecipients()` function in notifications/recipients.ts determines who gets notified:

### ACTIVITY_ASSIGNED
- Recipient: Activity owner (assignee)
- Optional: Team members watching Deal/Lead/Person/Org

### DEAL_STAGE_CHANGED
- Recipients: Deal owner + watchers on deal
- Excludes: Actor who triggered the change (actor exclusion)

### DEAL_WON / DEAL_LOST
- Recipients: Deal owner + watchers on deal
- Excludes: Actor

### LEAD_ASSIGNED
- Recipient: Lead owner (new assignee)
- Excludes: Actor

### LEAD_CONVERTED
- Recipients: Lead owner + lead creator + watchers on lead
- Excludes: Actor

---

## Implementation Guide for New CRM Events

To add a new CRM notification event:

### Step 1: Add Event Type

```typescript
// src/server/notifications/types.ts
export const NotificationEventType = {
  // ... existing events
  DEAL_STAGE_CHANGED: 'crm.deal.stage_changed',
  NEW_EVENT_NAME: 'crm.domain.event_name',
};
```

### Step 2: Add Event Template

```typescript
// src/server/notifications/templates.ts
const templates: Record<string, NotificationTemplate> = {
  // ... existing templates
  [NotificationEventType.NEW_EVENT_NAME]: {
    title: 'Your notification title',
    body: '{{actorName}} did something with {{entityName}}',
  },
};
```

### Step 3: Add Recipient Resolution

```typescript
// src/server/notifications/recipients.ts
async function resolveRaw(type: string, ctx: RecipientContext) {
  switch (type) {
    case NotificationEventType.NEW_EVENT_NAME: {
      const owner = await getEntityOwner(ctx.entityKind, ctx.entityId);
      const watchers = await getWatcherIds(ctx.tenantId, ctx.entityKind, ctx.entityId);
      return owner ? [owner, ...watchers] : watchers;
    }
  }
}
```

### Step 4: Publish Event in Service

```typescript
// src/lib/services/crm/entity-service.ts
const outboxId = await publishOutboxEvent(tx, {
  tenantId: this.tenantId,
  actorUserId: this.userId,
  type: NotificationEventType.NEW_EVENT_NAME,
  entityKind: 'entity',
  entityId: entity.id,
  payload: {
    // Provide all placeholder variables for template
    actorName: actor.name,
    entityName: entity.name,
    // ... other context
  }
});

// After transaction:
enqueueOutboxJob(outboxId);
```

### Step 5: Log Audit Action (Optional)

```typescript
await AuditService.log({
  tenantId: this.tenantId,
  userId: this.userId,
  action: AuditActions.ENTITY_ACTION,
  module: 'ENTITIES',
  entityId: entity.id,
  details: { ... }
});
```

---

## Cross-Service Dependencies

### Activity → Deal / Lead / Person / Organization

When activity changes:
1. Update `lastActivityDate` = max(completedAt) from done activities
2. Update `nextActivityDate` = min(dueAt) from pending activities

```typescript
// ActivityService.create() / update() / delete()
await recomputeActivityDates(dealId);
await recomputeActivityDates(leadId);
await recomputeActivityDates(personId);
await recomputeActivityDates(orgId);
```

### Deal → Pipeline / Stage

1. Validate stage belongs to deal's pipeline
2. On stage change: Auto-update status based on stage probability
3. Stage probability >= 100 → WON
4. Stage probability <= 0 → LOST

### Lead → Deal

When lead converts:
1. Create deal with lead's value/person/org
2. Update lead status to CONVERTED
3. Publish LEAD_CONVERTED event
4. All in one transaction

### Person → Organization

Auto-linking by email domain:
```typescript
// OrganizationService.attachPersonsByDomain()
1. Get organization domain
2. Find all persons with emails matching domain
3. Link persons to organization
4. Batch operation
```

### Email → Person / Organization / Deal / Lead

Auto-detection via email address:
```typescript
// EmailService integration
1. Extract sender/recipient email
2. Match to Person by email
3. If person linked to Org → use that
4. If email matches deal person → link to deal
```

---

## Outbox Event Flow Diagram

```
User Action (API POST)
    ↓
Route Handler (withCurrentUser)
    ↓
Service Method (DealService.moveToStage)
    ↓
prisma.$transaction(
    ├─ Update Deal table
    └─ publishOutboxEvent(tx, { type: DEAL_STAGE_CHANGED, ... })
        └─ INSERT into OutboxEvent table (status='PENDING')
)
    ↓
Transaction Commits
    ↓
enqueueOutboxJob(outboxEventId)
    ├─ Add to BullMQ queue
    └─ Redis stores job with deduplication ID
    ↓
Worker polls BullMQ
    ├─ Claim job (atomic: PENDING → PROCESSING)
    ├─ Fetch OutboxEvent from DB
    ├─ Call processEvent()
    │   ├─ resolveRecipients() → [user1, user2]
    │   ├─ renderTemplate() → title + body
    │   ├─ createMany(Notification) → 2 rows created
    │   └─ return { count: 2, recipientIds: [...] }
    ├─ Update OutboxEvent (status='PROCESSED')
    └─ POST /api/notifications/internal-push
        ├─ SSE broadcaster.emitToUsers(tenantId, [user1, user2], event)
        └─ All connected SSE clients receive notification
    ↓
Clients see notification (bell icon + dropdown list)
    ↓
User marks as read
    └─ PATCH /api/notifications/[id]/read
```

---

## Best Practices

1. **Always publish events inside transaction**
   - Ensures atomicity: if business operation fails, event isn't created
   - Prevents orphaned outbox events

2. **Set explicit timeout for multi-event transactions**
   - Default Prisma timeout is 5 seconds
   - Operations with 2+ outbox events need `{ timeout: 10000 }`

3. **Enqueue jobs after transaction commits**
   - Avoid processing events for rolled-back operations
   - Use separate `enqueueOutboxJob()` call outside transaction

4. **Provide all template variables in payload**
   - Templates use `{{placeholder}}` syntax
   - Missing placeholders render as empty string
   - Common: `actorName`, `entityName`, `entityTitle`, `value`, `currency`

5. **Test recipient resolution**
   - Verify actor exclusion (triggering user doesn't get notified)
   - Verify watchers included if applicable
   - Verify tenant isolation (cross-tenant leaks)

6. **Monitor outbox queue**
   - Failed events stay in DB (status='FAILED')
   - Check `outboxEvent.lastError` for debugging
   - Implement alerting for high failure rates

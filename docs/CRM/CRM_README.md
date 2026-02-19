# CRM Module Documentation

Complete reference for the SunApp AG CRM (Customer Relationship Management) module.

---

## Quick Navigation

### For Developers

**Understanding the Architecture:**
1. **[CRM_SERVICES_ARCHITECTURE.md](./CRM_SERVICES_ARCHITECTURE.md)** - Service layer overview
   - 14 service classes and their responsibilities
   - BaseService inheritance pattern
   - Transaction patterns and activity date recomputation
   - Audit logging and error handling

2. **[CRM_DATA_MODELS.md](./CRM_DATA_MODELS.md)** - Database schema reference
   - All 15+ Prisma models with field descriptions
   - Relationships and cascade rules
   - Multi-tenancy and soft delete patterns
   - Indexing strategy

3. **[CRM_INTEGRATIONS.md](./CRM_INTEGRATIONS.md)** - Integration with Notifications
   - Transactional Outbox pattern usage
   - 6 CRM notification events (ACTIVITY_ASSIGNED, DEAL_WON, LEAD_CONVERTED, etc.)
   - Recipient resolution rules
   - Guide for adding new events
   - Cross-service dependencies

4. **[CRM_API.md](./CRM_API.md)** - REST API reference
   - All 41 endpoints organized by entity
   - Request/response formats and error handling
   - Validation rules for each entity
   - Query parameters and pagination
   - SDK examples (TypeScript, Python)

---

### For Product & Managers

- **[CRM_OVERVIEW.md](./CRM_OVERVIEW.md)** - High-level overview of CRM capabilities
- **[SALES_CRM.md](./SALES_CRM.md)** - Sales workflow and CRM features

---

## Module Statistics

| Metric | Count |
|--------|-------|
| Service Files | 14 |
| Lines of Service Code | ~4,234 |
| API Routes | 41 |
| Data Models | 15+ |
| Notification Events | 6 |
| Audit Actions | 20+ |

---

## Architecture Overview

### Service Hierarchy

```
BaseService
├── ActivityService (628 lines) - Tasks, calls, meetings, emails
├── DealService (702 lines) - Sales opportunities & pipeline
├── LeadService (552 lines) - Prospective opportunities
├── OrganizationService (383 lines) - Companies
├── PersonService (316 lines) - Individual contacts
├── EmailService (282 lines) - Email integration
├── TimelineService (241 lines) - Activity aggregation
├── DashboardService (207 lines) - KPIs & metrics
├── StageService (197 lines) - Pipeline stages
├── PipelineService (195 lines) - Sales processes
├── FieldDefinitionService (195 lines) - Custom fields
├── NoteService (167 lines) - Text notes
├── DealLabelService (85 lines) - Deal categorization
└── LeadLabelService (84 lines) - Lead categorization
```

### API Route Structure

```
/api/crm
├── /deals (7 routes) - Deal CRUD + operations
├── /leads (8 routes) - Lead CRUD + conversion
├── /activities (3 routes) - Activity management
├── /persons (2 routes) - Person CRUD
├── /organizations (3 routes) - Org CRUD + auto-linking
├── /pipelines (3 routes) - Pipeline + stages
├── /stages (2 routes) - Stage operations
├── /emails (2 routes) - Email records
├── /notes (1 route) - Note management
├── /field-definitions (2 routes) - Custom fields
└── /dashboard (2 routes) - KPIs & summaries
```

---

## Core Concepts

### Multi-Tenancy

- Every CRM model includes `tenantId` field
- Services instantiated with tenant context
- Automatic filtering at query level via BaseService
- Soft deletes scoped by tenant

### Soft Deletes

- No permanent deletion; records marked `deleted: true`
- `deletedAt` timestamp recorded
- All queries exclude `deleted: true` by default
- Supports data recovery if needed

### Activity Dates

Automatically computed for Deal, Lead, Person, Organization:

```typescript
lastActivityDate = most recent completedAt from activities
nextActivityDate = earliest dueAt from pending activities
```

Updated when activities are created, completed, or deleted.

### Notifications Integration

CRM events trigger real-time notifications:

- `ACTIVITY_ASSIGNED` - Activity owner or reassigned
- `DEAL_STAGE_CHANGED` - Deal moved to different stage
- `DEAL_WON` - Deal marked as won
- `DEAL_LOST` - Deal marked as lost
- `LEAD_ASSIGNED` - Lead created or owner changed
- `LEAD_CONVERTED` - Lead converted to deal

All events follow the Transactional Outbox pattern for reliability.

### Custom Fields

Dynamic field definitions per entity type (DEAL, LEAD, PERSON, ORGANIZATION):

- TEXT, NUMBER, DATE, SELECT, MULTI_SELECT types
- Extensible `customData` JSON field on all models
- Field validation and uniqueness constraints

---

## Common Workflows

### Creating a Deal

```typescript
// Service method
const deal = await dealService.create({
  title: "Enterprise Package",
  value: 150000,
  currency: "USD",
  pipelineId: "pipeline_123",
  stageId: "stage_456",
  ownerId: "user_789",
  personId: "person_123",
  orgId: "org_456"
});
// Triggers: ACTIVITY_ASSIGNED notification
```

### Moving Deal Through Pipeline

```typescript
// Service method
const deal = await dealService.moveToStage(dealId, newStageId);
// Triggers: DEAL_STAGE_CHANGED notification
// Auto-triggers: DEAL_WON if probability >= 100%
// Auto-triggers: DEAL_LOST if probability <= 0%
```

### Converting Lead to Deal

```typescript
// Service method
const { deal, lead } = await leadService.convertToDeal(leadId, {
  pipelineId: "pipeline_123",
  stageId: "stage_123",
  dealValue: 50000
});
// Triggers: LEAD_CONVERTED notification
```

### Auto-Linking Persons to Organization

```typescript
// Service method
await orgService.attachPersonsByDomain(orgId, "acme.com");
// Finds all persons with @acme.com email
// Links them to organization
```

---

## Error Handling

All services use custom error classes:

```typescript
ValidationError      // 400 - Invalid input
NotFoundError        // 404 - Resource not found
BusinessRuleError    // 422 - Business logic violation
TenantAccessError    // 403 - Cross-tenant access attempt
UnauthorizedError    // 401 - Authentication failure
```

Errors include structured `details` for client-side validation feedback.

---

## Best Practices

1. **Always use transactions for multi-step operations**
   ```typescript
   await prisma.$transaction(async (tx) => {
     const deal = await tx.deal.update({ ... });
     await publishOutboxEvent(tx, { ... });
   });
   ```

2. **Publish notification events inside transactions**
   - Ensures atomicity: if business op fails, event isn't created
   - Prevents orphaned outbox events

3. **Check tenant access on all entity fetches**
   ```typescript
   ensureTenantAccess(deal);  // Throws if tenantId doesn't match
   ```

4. **Validate relationships belong to same tenant**
   ```typescript
   const person = await prisma.person.findUnique({ ... });
   ensureTenantAccess(person);  // Verify before linking to deal
   ```

5. **Recompute activity dates after activity changes**
   ```typescript
   await recomputeActivityDates(dealId);
   ```

6. **Use Zod for API input validation**
   ```typescript
   const input = CommonSchemas.createDeal.parse(body);
   ```

7. **Always enqueue outbox jobs after transaction commits**
   ```typescript
   enqueueOutboxJob(outboxId);  // Outside $transaction
   ```

---

## Performance Considerations

| Operation | Complexity | Notes |
|-----------|-----------|-------|
| List deals | O(n) with pagination | Use `limit` and `offset` |
| Get deal with relations | O(1) | Multiple includes in query |
| Move deal to stage | O(1) | Transaction safe |
| Convert lead to deal | O(1) | Atomic operation |
| Recompute activity dates | O(m) | m = # of parent entities |
| Auto-link persons by domain | O(n) | n = # of persons in domain |

---

## Monitoring & Observability

### Audit Logging

All business-critical actions logged:
```
DEAL_CREATED, DEAL_UPDATED, DEAL_MOVED, DEAL_WON, DEAL_LOST, DEAL_REOPENED, DEAL_DELETED
LEAD_CREATED, LEAD_UPDATED, LEAD_ARCHIVED, LEAD_RESTORED, LEAD_CONVERTED, LEAD_DELETED
ACTIVITY_CREATED, ACTIVITY_UPDATED, ACTIVITY_COMPLETED, ACTIVITY_DELETED, ACTIVITY_BULK_ACTION
```

Access via `/api/audit-logs` with filters.

### Event Tracking

Outbox events logged and tracked:
- Status: PENDING → PROCESSING → PROCESSED/FAILED
- Attempts and retry count
- Error details on failure
- Last processed timestamp

---

## Version History

**v1.0** (Current)
- Core CRM entities (Deals, Leads, Activities)
- Sales pipeline with stages
- Soft delete & multi-tenancy
- Audit logging
- Notification integration
- Custom fields

**v2.0** (Planned)
- Advanced permission models
- Deal forecasting
- Pipeline analytics
- Email sync
- Calendar integration
- Workflow automation

---

## Related Documentation

- [Authentication Architecture](../AUTH/AUTH_ARCHITECTURE_RU.md)
- [Notifications Implementation](../NOTIFICATIONS/implementation_plan.md)
- [Database Schema](../DATABASE.md)

---

## Contact & Support

For questions or issues:
1. Check relevant `.md` file in this directory
2. Review service implementation in `src/lib/services/crm/`
3. Check API routes in `src/app/api/crm/`
4. Open an issue in the repository

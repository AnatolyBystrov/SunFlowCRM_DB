# CRM Data Models & Database Schema

## Overview

The CRM module uses 15+ Prisma models organized by domain. All models support:
- **Multi-tenancy**: `tenantId` field with automatic filtering
- **Soft deletes**: `deleted` (boolean) and `deletedAt` (DateTime?)
- **Audit trail**: `createdAt`, `updatedAt` timestamps
- **Relationships**: Cascade delete, referential integrity

---

## Core Models

### Organization

Represents companies or business entities.

```prisma
model Organization {
  id              String    @id @default(cuid())
  tenantId        String
  name            String    @db.VarChar(200)
  domain          String?   @db.VarChar(255)
  ownerId         String?
  countryCode     String?   @db.Char(2)
  city            String?   @db.VarChar(100)
  address         String?   @db.Text
  industry        String?   @db.VarChar(100)
  size            String?   @db.VarChar(50)
  website         String?   @db.VarChar(500)
  phone           String?   @db.VarChar(50)
  
  // Activity dates (auto-computed from Activities)
  lastActivityDate  DateTime?
  nextActivityDate  DateTime?
  
  customData      Json      @default("{}")
  
  deleted         Boolean   @default(false)
  deletedAt       DateTime?
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt
  
  // Relationships
  tenant          Tenant    @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  owner           User?     @relation(fields: [ownerId], references: [id], onDelete: SetNull)
  persons         Person[]
  deals           Deal[]
  leads           Lead[]
  activities      Activity[]
  emails          Email[]
  notes           Note[]
  
  @@index([tenantId])
  @@index([tenantId, deleted])
  @@index([domain])
  @@index([ownerId])
  @@index([countryCode])
  @@index([city])
}
```

**Key Fields:**
- `domain` - Company domain (e.g., "acme.com") for auto-linking persons by email
- `lastActivityDate` - Most recent activity linked to this organization (auto-updated)
- `nextActivityDate` - Next pending activity (auto-updated)
- `customData` - JSON field for extensible attributes

---

### Person

Represents individual contacts (employees, decision-makers).

```prisma
model Person {
  id              String    @id @default(cuid())
  tenantId        String
  orgId           String?
  firstName       String    @db.VarChar(100)
  lastName        String    @db.VarChar(100)
  email           String?   @db.VarChar(255)
  phone           String?   @db.VarChar(50)
  jobTitle        String?   @db.VarChar(100)
  
  // Activity dates (auto-computed)
  lastActivityDate  DateTime?
  nextActivityDate  DateTime?
  
  customData      Json      @default("{}")
  
  deleted         Boolean   @default(false)
  deletedAt       DateTime?
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt
  
  // Relationships
  tenant          Tenant    @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  organization    Organization? @relation(fields: [orgId], references: [id], onDelete: SetNull)
  deals           Deal[]
  leads           Lead[]
  activities      Activity[]
  emails          Email[]
  notes           Note[]
  
  @@unique([tenantId, email], where: { deleted: false })
  @@index([tenantId])
  @@index([tenantId, deleted])
  @@index([email])
}
```

**Key Fields:**
- `email` - Unique per tenant (can be null, but if present must be unique)
- `jobTitle` - Job position or role
- `lastActivityDate`, `nextActivityDate` - Auto-updated when activities change

---

### Pipeline

Represents sales process templates (e.g., "B2B Sales", "Enterprise Deals").

```prisma
model Pipeline {
  id              String    @id @default(cuid())
  tenantId        String
  name            String    @db.VarChar(100)
  isDefault       Boolean   @default(false)
  sortOrder       Int       @default(0)
  
  deleted         Boolean   @default(false)
  deletedAt       DateTime?
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt
  
  // Relationships
  tenant          Tenant    @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  stages          Stage[]
  deals           Deal[]
  
  @@index([tenantId])
  @@index([tenantId, isDefault])
  @@index([tenantId, deleted])
}
```

**Key Fields:**
- `isDefault` - Only one pipeline per tenant can be default
- `sortOrder` - Order of display in UI (ascending)

---

### Stage

Represents steps in a sales pipeline (e.g., "Prospect", "Proposal", "Close").

```prisma
model Stage {
  id              String    @id @default(cuid())
  tenantId        String
  pipelineId      String
  name            String    @db.VarChar(100)
  probability     Decimal   @db.Decimal(3,0)  // 0-100
  sortOrder       Int       @default(0)
  
  // Rotten deal detection
  isRotten        Boolean   @default(false)
  rottenDays      Int?
  
  deleted         Boolean   @default(false)
  deletedAt       DateTime?
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt
  
  // Relationships
  tenant          Tenant    @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  pipeline        Pipeline  @relation(fields: [pipelineId], references: [id], onDelete: Cascade)
  deals           Deal[]
  
  @@index([pipelineId, sortOrder])
  @@index([tenantId])
  @@index([tenantId, deleted])
}
```

**Key Fields:**
- `probability` - 0-100, represents win likelihood
  - 100% = deal won (auto-status WON)
  - 0% = deal lost (auto-status LOST)
- `isRotten` - If true, deals in this stage > rottenDays become "stale"
- `rottenDays` - Threshold for marking deals as rotten

---

### Deal

Represents sales opportunities progressing through pipeline.

```prisma
model Deal {
  id              String    @id @default(cuid())
  tenantId        String
  pipelineId      String
  stageId         String
  ownerId         String    // Current owner/sales rep
  creatorId       String    // Who created the deal
  personId        String?   // Primary contact
  orgId           String?   // Related organization
  
  // Basic info
  title           String    @db.VarChar(200)
  value           Decimal   @db.Decimal(15,2)
  currency        String    @db.Char(3)  // ISO 4217
  status          DealStatus @default(OPEN)  // OPEN | WON | LOST
  expectedCloseDate DateTime?
  
  // Status tracking
  wonAt           DateTime?
  lostAt          DateTime?
  lostReason      String?   @db.Text
  
  // V2 fields (PR-1)
  probability     Decimal?  @db.Decimal(3,0)  // Manual override
  stageChangeTime DateTime? // When moved to current stage
  firstWonTime    DateTime? // First time marked WON
  source          String?   @db.VarChar(100)  // e.g., "inbound_call", "email", "partner"
  externalSourceId String?  @db.VarChar(255)
  visibility      DealVisibility @default(COMPANY)
  priority        DealPriority @default(NORMAL)
  rottenFlag      Boolean   @default(false)
  rottenTime      DateTime?
  renewalType     String?   @db.VarChar(50)   // one_time | renewal | new_business
  
  // Activity dates (auto-computed)
  lastActivityDate  DateTime?
  nextActivityDate  DateTime?
  
  customData      Json      @default("{}")
  
  deleted         Boolean   @default(false)
  deletedAt       DateTime?
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt
  
  // Relationships
  tenant          Tenant    @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  pipeline        Pipeline  @relation(fields: [pipelineId], references: [id], onDelete: Restrict)
  stage           Stage     @relation(fields: [stageId], references: [id], onDelete: Restrict)
  owner           User      @relation("DealOwner", fields: [ownerId], references: [id])
  creator         User      @relation("DealCreator", fields: [creatorId], references: [id])
  person          Person?   @relation(fields: [personId], references: [id], onDelete: SetNull)
  organization    Organization? @relation(fields: [orgId], references: [id], onDelete: SetNull)
  activities      Activity[]
  emails          Email[]
  notes           Note[]
  convertedFrom   Lead?     @relation("LeadToDeal", fields: [id], references: [convertedDealId])
  labels          DealLabelLink[]
  permittedUsers  DealPermittedUser[]
  
  @@index([tenantId])
  @@index([status])
  @@index([pipelineId, stageId])
  @@index([ownerId])
  @@index([creatorId])
  @@index([visibility])
  @@index([priority])
  @@index([source])
  @@index([stageChangeTime])
  @@index([rottenFlag])
  @@index([tenantId, deleted])
}
```

**Status Transitions:**
- OPEN → WON: via `markAsWon()` or stage move to 100% probability
- OPEN → LOST: via `markAsLost()` or stage move to lost stage (0%)
- WON/LOST → OPEN: via `reopen()`

**Key Fields:**
- `probability` - Override of stage's probability for specific deal
- `stageChangeTime` - When deal last moved to current stage (for "stuck" detection)
- `firstWonTime` - First time ever marked WON (even if reopened later)
- `visibility` - OWNER (only owner), TEAM (team members), COMPANY (all)

---

### Lead

Represents prospective opportunities not yet in formal sales pipeline.

```prisma
model Lead {
  id              String    @id @default(cuid())
  tenantId        String
  ownerId         String
  creatorId       String
  personId        String?
  orgId           String?
  
  title           String    @db.VarChar(200)
  description     String?   @db.Text
  source          String?   @db.VarChar(100)
  origin          String?   @db.VarChar(100)
  inboxChannel    String?   @db.VarChar(100)
  externalSourceId String?  @db.VarChar(255)
  status          LeadStatus @default(OPEN)  // OPEN | LOST | ARCHIVED | CONVERTED
  valueAmount     Decimal?  @db.Decimal(15,2)
  valueCurrency   String?   @db.Char(3)
  expectedCloseDate DateTime?
  
  wasSeen         Boolean   @default(false)
  visibility      LeadVisibility @default(COMPANY)
  convertedDealId String?   // FK to Deal if converted
  
  // Activity dates (auto-computed)
  lastActivityDate  DateTime?
  nextActivityDate  DateTime?
  
  customData      Json      @default("{}")
  
  deleted         Boolean   @default(false)
  deletedAt       DateTime?
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt
  
  // Relationships
  tenant          Tenant    @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  owner           User      @relation("LeadOwner", fields: [ownerId], references: [id])
  creator         User      @relation("LeadCreator", fields: [creatorId], references: [id])
  person          Person?   @relation(fields: [personId], references: [id], onDelete: SetNull)
  organization    Organization? @relation(fields: [orgId], references: [id], onDelete: SetNull)
  convertedToDeal Deal?     @relation("LeadToDeal", fields: [convertedDealId], references: [id])
  labels          LeadLabelLink[]
  permittedUsers  LeadPermittedUser[]
  activities      Activity[]
  emails          Email[]
  notes           Note[]
  
  @@index([tenantId])
  @@index([tenantId, status])
  @@index([tenantId, deleted])
  @@index([tenantId, wasSeen])
  @@index([ownerId])
  @@index([creatorId])
}
```

**Status:**
- OPEN - New or active lead
- LOST - Rejected or not interested
- ARCHIVED - Parked for later
- CONVERTED - Converted to deal (read-only, cannot change)

---

### Activity

Represents tasks, calls, meetings, emails related to deals/leads/persons/orgs.

```prisma
model Activity {
  id              String    @id @default(cuid())
  tenantId        String
  ownerId         String
  
  type            ActivityType  // CALL | MEETING | TASK | EMAIL | DEADLINE | LUNCH
  subject         String    @db.VarChar(200)
  dueAt           DateTime?
  hasTime         Boolean   @default(false)  // If false, just date
  durationMin     Int?      // Duration in minutes
  busyFlag        BusyFlag  @default(BUSY)   // FREE | BUSY
  done            Boolean   @default(false)
  completedAt     DateTime?
  note            String?   @db.Text
  
  // Link to parent entity
  dealId          String?
  leadId          String?
  personId        String?
  orgId           String?
  
  // Integration
  externalEventId String?   // For calendar sync
  calendarProvider String?  // GOOGLE | MICROSOFT | ICLOUD
  
  deleted         Boolean   @default(false)
  deletedAt       DateTime?
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt
  
  // Relationships
  tenant          Tenant    @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  owner           User      @relation(fields: [ownerId], references: [id])
  deal            Deal?     @relation(fields: [dealId], references: [id], onDelete: SetNull)
  lead            Lead?     @relation(fields: [leadId], references: [id], onDelete: SetNull)
  person          Person?   @relation(fields: [personId], references: [id], onDelete: SetNull)
  organization    Organization? @relation(fields: [orgId], references: [id], onDelete: SetNull)
  
  @@index([tenantId])
  @@index([tenantId, done, dueAt])
  @@index([tenantId, ownerId, done, dueAt])
  @@index([tenantId, deleted])
  @@index([dealId])
  @@index([leadId])
  @@index([personId])
  @@index([ownerId])
}
```

**Key Fields:**
- `hasTime` - If true, `dueAt` includes time; if false, it's date-only (all-day)
- `done` - Marks activity complete; `completedAt` is set when marked done
- Parent entity - must have at least one of dealId, leadId, personId, orgId

---

### Email

Represents email messages and integrations.

```prisma
model Email {
  id              String    @id @default(cuid())
  tenantId        String
  userId          String    // User who received/sent
  providerAccountId String? // External account ID
  
  direction       EmailDirection  // INCOMING | OUTGOING
  subject         String    @db.VarChar(500)
  from            String    @db.VarChar(255)
  to              String    @db.Text
  cc              String?   @db.Text
  bcc             String?   @db.Text
  messageId       String?   @db.VarChar(500)  // RFC message-id
  inReplyTo       String?   @db.VarChar(500)
  references      String?   @db.Text
  sentAt          DateTime?
  receivedAt      DateTime?
  bodyPreview     String?   @db.Text
  hasHtmlBody     Boolean   @default(false)
  hasTextBody     Boolean   @default(true)
  threadId        String?   @db.VarChar(500)
  
  // Links to CRM entities
  dealId          String?
  leadId          String?
  personId        String?
  orgId           String?
  isLinkedAutomatically Boolean @default(false)
  
  deleted         Boolean   @default(false)
  deletedAt       DateTime?
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt
  
  // Relationships
  tenant          Tenant    @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  user            User      @relation(fields: [userId], references: [id])
  emailAccount    EmailAccount? @relation(fields: [providerAccountId], references: [externalId])
  deal            Deal?     @relation(fields: [dealId], references: [id], onDelete: SetNull)
  lead            Lead?     @relation(fields: [leadId], references: [id], onDelete: SetNull)
  person          Person?   @relation(fields: [personId], references: [id], onDelete: SetNull)
  organization    Organization? @relation(fields: [orgId], references: [id], onDelete: SetNull)
  trackingEvents  EmailTrackingEvent[]
  
  @@index([tenantId])
  @@index([tenantId, direction])
  @@index([tenantId, deleted])
  @@index([threadId])
  @@index([dealId])
  @@index([leadId])
  @@index([personId])
  @@index([userId])
}
```

---

### Note

Represents text notes attached to deals, leads, persons, organizations.

```prisma
model Note {
  id              String    @id @default(cuid())
  tenantId        String
  authorId        String
  
  body            String    @db.Text
  pinned          Boolean   @default(false)
  
  // Parent entity
  leadId          String?
  dealId          String?
  personId        String?
  orgId           String?
  
  deleted         Boolean   @default(false)
  deletedAt       DateTime?
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt
  
  // Relationships
  tenant          Tenant    @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  author          User      @relation(fields: [authorId], references: [id])
  lead            Lead?     @relation(fields: [leadId], references: [id], onDelete: Cascade)
  deal            Deal?     @relation(fields: [dealId], references: [id], onDelete: Cascade)
  person          Person?   @relation(fields: [personId], references: [id], onDelete: Cascade)
  organization    Organization? @relation(fields: [orgId], references: [id], onDelete: Cascade)
  
  @@index([tenantId])
  @@index([tenantId, deleted])
  @@index([leadId])
  @@index([dealId])
  @@index([personId])
  @@index([authorId])
}
```

---

### Label Models

#### DealLabel / DealLabelLink

```prisma
model DealLabel {
  id              String    @id @default(cuid())
  tenantId        String
  name            String    @db.VarChar(50)
  color           String?   @db.Char(7)     // Hex color
  sortOrder       Int       @default(0)
  
  deleted         Boolean   @default(false)
  deletedAt       DateTime?
  createdAt       DateTime  @default(now())
  
  tenant          Tenant    @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  deals           DealLabelLink[]
  
  @@unique([tenantId, name], where: { deleted: false })
  @@index([tenantId])
}

model DealLabelLink {
  id              String    @id @default(cuid())
  dealId          String
  labelId         String
  
  deal            Deal      @relation(fields: [dealId], references: [id], onDelete: Cascade)
  label           DealLabel @relation(fields: [labelId], references: [id], onDelete: Cascade)
  
  @@unique([dealId, labelId])
}
```

#### LeadLabel / LeadLabelLink

Similar structure to DealLabel.

---

### FieldDefinition

Allows creating custom fields for CRM entities.

```prisma
model FieldDefinition {
  id              String    @id @default(cuid())
  tenantId        String
  entityType      FieldEntityType  // DEAL | LEAD | PERSON | ORGANIZATION
  key             String    @db.VarChar(50)
  label           String    @db.VarChar(100)
  fieldType       FieldType // TEXT | NUMBER | DATE | SELECT | MULTI_SELECT
  options         String[]  // For SELECT/MULTI_SELECT
  sortOrder       Int       @default(0)
  
  deleted         Boolean   @default(false)
  deletedAt       DateTime?
  createdAt       DateTime  @default(now())
  
  tenant          Tenant    @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  
  @@unique([tenantId, entityType, key], where: { deleted: false })
  @@index([tenantId, entityType])
  @@index([tenantId, deleted])
}
```

---

## Enums

```prisma
enum DealStatus {
  OPEN
  WON
  LOST
}

enum DealVisibility {
  OWNER
  TEAM
  COMPANY
}

enum DealPriority {
  LOW
  NORMAL
  HIGH
}

enum LeadStatus {
  OPEN
  LOST
  ARCHIVED
  CONVERTED
}

enum LeadVisibility {
  OWNER
  TEAM
  COMPANY
}

enum ActivityType {
  CALL
  MEETING
  TASK
  EMAIL
  DEADLINE
  LUNCH
}

enum BusyFlag {
  FREE
  BUSY
}

enum EmailDirection {
  INCOMING
  OUTGOING
}

enum EmailProvider {
  GMAIL
  OUTLOOK
  IMAP
}

enum TrackingEventType {
  OPEN
  CLICK
}

enum FieldEntityType {
  DEAL
  LEAD
  PERSON
  ORGANIZATION
}

enum FieldType {
  TEXT
  NUMBER
  DATE
  SELECT
  MULTI_SELECT
}
```

---

## Indexing Strategy

**Tenant Isolation:**
- All queries filter by `tenantId`
- Every model has `@@index([tenantId])`
- Composite indexes for common filters: `tenantId + status`, `tenantId + deleted`

**Business Queries:**
- Deal searches: `tenantId + status`, `tenantId + pipelineId + stageId`, `tenantId + ownerId`
- Activity queries: `tenantId + ownerId + done + dueAt` (for "my activities")
- Timeline: `dealId`, `leadId`, `personId`, `orgId`

**Soft Delete:**
- All models have `@@index([tenantId, deleted])` to exclude soft-deleted records

---

## Activity Date Recomputation

Three fields are auto-computed for Deal, Lead, Person, Organization:

```typescript
lastActivityDate = MAX(activity.completedAt) 
  where activity.done = true and activity.deletedAt IS NULL

nextActivityDate = MIN(activity.dueAt) 
  where activity.done = false and activity.deletedAt IS NULL and activity.dueAt IS NOT NULL
```

**When Updated:**
- Activity created (any parent entity)
- Activity marked done
- Activity marked undone
- Activity deleted
- Activity dueAt changed

---

## Relationships & Cascade Rules

| Relationship | Delete Policy | Reason |
|-------------|---------------|--------|
| Deal → Pipeline | RESTRICT | Cannot delete pipeline with open deals |
| Deal → Stage | RESTRICT | Cannot delete stage with deals |
| Activity → Parent | SET NULL | Keep activity even if parent deleted |
| Email → Parent | SET NULL | Keep email history even if parent deleted |
| Note → Parent | CASCADE | Delete notes when parent deleted |
| Label → Entity | CASCADE | Delete links when label deleted |

---

## Multi-Tenancy Pattern

Every CRM model includes:
```prisma
tenantId        String
tenant          Tenant    @relation(fields: [tenantId], references: [id], onDelete: Cascade)
@@index([tenantId])
```

All service queries automatically filter:
```typescript
where: {
  ...getTenantFilter(),  // Adds tenantId filter
  deleted: false         // Excludes soft-deleted
}
```

This ensures:
- No cross-tenant data leakage
- Soft deletions scoped by tenant
- Fast tenant-specific queries

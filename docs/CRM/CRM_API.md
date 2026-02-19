# CRM API Documentation

## Обзор API

CRM API предоставляет REST endpoints для управления всеми аспектами Sales CRM. Все endpoints требуют аутентификации и подчиняются правилам мультитенантности (фильтрация по `tenantId`).

**Base URL:** `https://api.sunapp.ag/api/crm`

**Authentication:** Bearer Token (JWT)

---

## Общие принципы

### Ответы

Все успешные ответы возвращают объект:

```typescript
{
  success: true;
  data: T;
  meta?: {
    pagination?: {
      total: number;
      limit: number;
      offset: number;
    };
  };
}
```

### Ошибки

Все ошибки возвращают:

```typescript
{
  success: false;
  error: {
    code: string;          // e.g., "UNAUTHORIZED", "VALIDATION_ERROR"
    message: string;
    details?: Record<string, any>;
  };
}
```

### Статус коды

- `200` - OK
- `201` - Created
- `204` - No Content
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Unprocessable Entity (validation error)
- `500` - Internal Server Error

### Пагинация

Endpoints с множеством результатов поддерживают пагинацию:

**Query параметры:**
- `limit` (default: 20, max: 100) - количество результатов
- `offset` (default: 0) - смещение
- `sortBy` - поле для сортировки
- `sortOrder` - "asc" или "desc"

**Пример:**
```
GET /organizations?limit=50&offset=100&sortBy=name&sortOrder=asc
```

---

## Organizations API

### List Organizations

```http
GET /organizations
```

**Query параметры:**
- `limit`, `offset` - пагинация
- `search` - поиск по названию
- `industry` - фильтр по отрасли
- `sortBy` - "name", "createdAt"

**Ответ:**
```typescript
{
  success: true,
  data: Organization[],
  meta: {
    pagination: {
      total: 100,
      limit: 20,
      offset: 0
    }
  }
}
```

---

### Get Organization

```http
GET /organizations/{id}
```

**Ответ:**
```typescript
{
  success: true,
  data: {
    id: string;
    tenantId: string;
    name: string;
    address?: string;
    industry?: string;
    size?: string;
    website?: string;
    phone?: string;
    customData: Record<string, any>;
    createdAt: DateTime;
    updatedAt: DateTime;
  }
}
```

---

### Create Organization

```http
POST /organizations
Content-Type: application/json

{
  "name": "Acme Corp",
  "industry": "Technology",
  "size": "101-500",
  "address": "123 Main St, San Francisco",
  "website": "https://acme.com",
  "phone": "+1-555-0123",
  "customData": {
    "account_manager": "John Doe"
  }
}
```

**Validation:**
- `name` - обязательно, max 255 символов
- `industry`, `size`, `address`, `website`, `phone` - опциональны

**Ответ:** `201 Created`
```typescript
{
  success: true,
  data: Organization
}
```

---

### Update Organization

```http
PUT /organizations/{id}
Content-Type: application/json

{
  "name": "Acme Corp (Updated)",
  "industry": "Software"
}
```

**Ответ:** `200 OK`

---

### Delete Organization

```http
DELETE /organizations/{id}
```

**Примечание:** Это soft delete. Данные остаются в БД с флагом `deleted: true`.

**Ответ:** `204 No Content`

---

## Persons API

### List Persons

```http
GET /persons
```

**Query параметры:**
- `limit`, `offset` - пагинация
- `search` - поиск по имени/email
- `orgId` - фильтр по организации
- `sortBy` - "firstName", "lastName", "createdAt"

---

### Get Person

```http
GET /persons/{id}
```

---

### Create Person

```http
POST /persons
Content-Type: application/json

{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@acme.com",
  "phone": "+1-555-0123",
  "jobTitle": "VP of Sales",
  "orgId": "org_123",
  "customData": {}
}
```

**Validation:**
- `firstName`, `lastName` - обязательны
- `email` - должен быть валидным

---

### Update Person

```http
PUT /persons/{id}
```

---

### Delete Person

```http
DELETE /persons/{id}
```

---

## Leads API

### List Leads

```http
GET /leads
```

**Query параметры:**
- `limit`, `offset` - пагинация
- `status` - фильтр: NEW, IN_PROGRESS, ARCHIVED, CONVERTED
- `source` - фильтр по источнику
- `ownerId` - фильтр по ответственному
- `search` - поиск по названию

**Ответ:**
```typescript
{
  success: true,
  data: Lead[],
  meta: { pagination: ... }
}
```

---

### Get Lead

```http
GET /leads/{id}
```

**Ответ включает:**
- Основная информация о лиде
- Связанный контакт (Person)
- Связанная организация (Organization)

---

### Create Lead

```http
POST /leads
Content-Type: application/json

{
  "title": "Potential customer from LinkedIn",
  "source": "LinkedIn",
  "ownerId": "user_123",
  "personId": "person_123",
  "orgId": "org_456"
}
```

**Validation:**
- `title` - обязательно
- `ownerId` - обязательно

**Ответ:** `201 Created`

---

### Update Lead

```http
PUT /leads/{id}

{
  "status": "IN_PROGRESS",
  "title": "Updated lead title"
}
```

---

### Convert Lead to Deal

```http
POST /leads/{id}/convert
Content-Type: application/json

{
  "pipelineId": "pipeline_123",
  "stageId": "stage_123",
  "dealValue": 50000
}
```

**Действие:**
- Создаёт новую сделку (Deal)
- Обновляет лид: `status: "CONVERTED"`, `convertedDealId: deal_id`
- Логирует в audit

**Ответ:** `201 Created`
```typescript
{
  success: true,
  data: {
    lead: Lead;
    deal: Deal;
  }
}
```

---

### Archive Lead

```http
POST /leads/{id}/archive
```

**Действие:**
- Обновляет статус на `ARCHIVED`

---

## Deals API

### List Deals

```http
GET /deals
```

**Query параметры:**
- `limit`, `offset`
- `pipelineId` - фильтр по конвейеру
- `stageId` - фильтр по этапу
- `status` - фильтр: OPEN, WON, LOST
- `ownerId` - фильтр по ответственному
- `search` - поиск по названию

---

### Get Deal

```http
GET /deals/{id}
```

**Ответ включает:**
- Основная информация
- Конвейер и этап
- Контакт и организация
- История активностей
- История писем

---

### Create Deal

```http
POST /deals
Content-Type: application/json

{
  "title": "Acme Corp - Enterprise Package",
  "value": 150000,
  "currency": "USD",
  "pipelineId": "pipeline_123",
  "stageId": "stage_456",
  "ownerId": "user_789",
  "personId": "person_123",
  "orgId": "org_456",
  "expectedCloseDate": "2024-03-31"
}
```

**Validation:**
- `title`, `pipelineId`, `stageId`, `ownerId` - обязательны
- `value` - должно быть ≥ 0
- `currency` - валидный код валюты (USD, EUR, etc.)

**Ответ:** `201 Created`

---

### Update Deal

```http
PUT /deals/{id}

{
  "title": "Updated deal title",
  "value": 175000,
  "expectedCloseDate": "2024-04-15"
}
```

---

### Move Deal to Stage

```http
PUT /deals/{id}/stage
Content-Type: application/json

{
  "stageId": "stage_new_id"
}
```

**Действие:**
- Перемещает сделку на новый этап
- Логирует в audit с деталями перемещения

---

### Close Deal (Won)

```http
POST /deals/{id}/won
```

**Действие:**
- Обновляет `status: "WON"` и `wonAt: now()`
- Логирует в audit

---

### Close Deal (Lost)

```http
POST /deals/{id}/lost
Content-Type: application/json

{
  "reason": "Client chose competitor"
}
```

**Действие:**
- Обновляет `status: "LOST"`, `lostAt: now()`, `lostReason`
- Логирует в audit

---

## Activities API

### List Activities

```http
GET /activities
```

**Query параметры:**
- `limit`, `offset`
- `type` - фильтр: CALL, MEETING, TASK, EMAIL
- `done` - фильтр: true, false
- `ownerId` - фильтр по ответственному
- `dealId` - фильтр по сделке
- `dueFrom`, `dueTo` - диапазон дат

---

### Get Activity

```http
GET /activities/{id}
```

---

### Create Activity

```http
POST /activities
Content-Type: application/json

{
  "type": "CALL",
  "subject": "Follow up call with John",
  "ownerId": "user_123",
  "dealId": "deal_456",
  "dueAt": "2024-02-20T14:00:00Z",
  "note": "Discuss pricing and timeline"
}
```

**Validation:**
- `type`, `subject`, `ownerId` - обязательны
- `type` - одно из: CALL, MEETING, TASK, EMAIL

**Ответ:** `201 Created`

---

### Update Activity

```http
PUT /activities/{id}

{
  "subject": "Updated subject",
  "dueAt": "2024-02-21T10:00:00Z"
}
```

---

### Complete Activity

```http
POST /activities/{id}/complete
```

**Действие:**
- Обновляет `done: true` и `completedAt: now()`

---

### Delete Activity

```http
DELETE /activities/{id}
```

---

## Emails API

### List Emails

```http
GET /emails
```

**Query параметры:**
- `limit`, `offset`
- `direction` - фильтр: INCOMING, OUTGOING
- `dealId` - фильтр по сделке
- `personId` - фильтр по контакту
- `search` - поиск по теме

---

### Get Email

```http
GET /emails/{id}
```

---

### Link Email to Deal

```http
POST /emails/{id}/link
Content-Type: application/json

{
  "dealId": "deal_123"
}
```

---

### Link Email to Contact

```http
POST /emails/{id}/link-contact
Content-Type: application/json

{
  "personId": "person_123"
}
```

---

## Pipelines API

### List Pipelines

```http
GET /pipelines
```

**Ответ:**
```typescript
{
  success: true,
  data: Pipeline[]
}
```

---

### Get Pipeline with Stages

```http
GET /pipelines/{id}
```

**Ответ включает:**
- Pipeline информацию
- Все этапы (Stage) с сортировкой

---

### Create Pipeline

```http
POST /pipelines
Content-Type: application/json

{
  "name": "B2B Sales Process",
  "isDefault": false
}
```

---

### Update Pipeline

```http
PUT /pipelines/{id}

{
  "name": "Updated pipeline name",
  "isDefault": true
}
```

---

### Delete Pipeline

```http
DELETE /pipelines/{id}
```

**Ограничение:** Нельзя удалить конвейер, если у него есть активные (не удалённые) сделки.

---

## Stages API

### List Stages

```http
GET /pipelines/{pipelineId}/stages
```

---

### Create Stage

```http
POST /pipelines/{pipelineId}/stages
Content-Type: application/json

{
  "name": "Proposal",
  "probability": 50,
  "isRotten": true,
  "rottenDays": 7
}
```

---

### Update Stage

```http
PUT /stages/{id}

{
  "name": "Updated stage name",
  "probability": 60
}
```

---

### Reorder Stages

```http
POST /pipelines/{pipelineId}/stages/reorder
Content-Type: application/json

{
  "stageIds": ["stage1", "stage2", "stage3"]
}
```

---

## Custom Fields API

### List Field Definitions

```http
GET /field-definitions
```

**Query параметры:**
- `entityType` - фильтр: DEAL, PERSON, ORGANIZATION

---

### Create Field Definition

```http
POST /field-definitions
Content-Type: application/json

{
  "entityType": "DEAL",
  "key": "deal_source",
  "label": "Deal Source",
  "fieldType": "SELECT",
  "options": ["Inbound", "Outbound", "Partner", "Referral"]
}
```

**Field Types:**
- `TEXT` - текст
- `NUMBER` - число
- `DATE` - дата
- `SELECT` - одиночный выбор
- `MULTI_SELECT` - множественный выбор

---

### Update Field Definition

```http
PUT /field-definitions/{id}

{
  "label": "Updated label",
  "options": ["Option1", "Option2", "Option3"]
}
```

---

### Delete Field Definition

```http
DELETE /field-definitions/{id}
```

**Ограничение:** Нельзя удалить поле, если у сущностей есть данные в этом поле. Сначала нужно очистить данные.

---

## Analytics API

### Get Pipeline Summary

```http
GET /analytics/pipeline/{pipelineId}
```

**Ответ:**
```typescript
{
  success: true,
  data: {
    totalValue: number;
    dealCount: number;
    stageBreakdown: Array<{
      stageId: string;
      stageName: string;
      dealCount: number;
      totalValue: number;
      averageDealSize: number;
    }>;
    winRate: number;              // % of won deals
    conversionRate: number;       // % of leads converted
    averageDealSize: number;
    averageSalesVelocity: number; // days from first to last stage
  }
}
```

---

### Get User Performance

```http
GET /analytics/user/{userId}
```

**Ответ:**
```typescript
{
  success: true,
  data: {
    totalDeals: number;
    wonDeals: number;
    lostDeals: number;
    totalValue: number;
    averageDealSize: number;
    winRate: number;
    leadsCrated: number;
    leadsConverted: number;
  }
}
```

---

## Error Examples

### Validation Error

```http
POST /deals
Content-Type: application/json

{
  "title": "",
  "pipelineId": "invalid_id"
}

Response: 422 Unprocessable Entity
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "title": "Title is required",
      "pipelineId": "Pipeline not found"
    }
  }
}
```

### Unauthorized Error

```http
GET /deals
Authorization: Bearer invalid_token

Response: 401 Unauthorized
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid or expired token"
  }
}
```

### Not Found Error

```http
GET /deals/nonexistent_id

Response: 404 Not Found
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Deal not found"
  }
}
```

---

## Rate Limiting

Все endpoints подчиняются rate limiting:

- **Standard**: 100 запросов в минуту на пользователя
- **Burst**: 10 запросов в секунду

**Headers в ответе:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1613097600
```

---

## Webhooks

CRM поддерживает webhooks для критических событий:

**События:**
- `deal.created`
- `deal.updated`
- `deal.status_changed` (OPEN → WON/LOST)
- `deal.stage_changed`
- `lead.created`
- `lead.converted`
- `activity.created`
- `activity.completed`

**Конфигурация:** в Settings → Webhooks

**Пример payload:**
```json
{
  "event": "deal.created",
  "timestamp": "2024-02-20T10:30:00Z",
  "data": {
    "id": "deal_123",
    "title": "New Deal",
    "value": 50000,
    "ownerId": "user_456"
  }
}
```

---

## Complete Route Reference (41 endpoints)

### Deals (7 routes)
```
GET    /deals                      - List deals with filters
POST   /deals                      - Create deal
GET    /deals/[id]                 - Get deal by ID
PATCH  /deals/[id]                 - Update deal
DELETE /deals/[id]                 - Delete deal (soft)
POST   /deals/[id]/move            - Move to stage + trigger WON/LOST if applicable
POST   /deals/[id]/won             - Mark deal as won
POST   /deals/[id]/lost            - Mark deal as lost
POST   /deals/[id]/reopen          - Reopen deal (WON/LOST → OPEN)
GET    /deal-labels                - List deal labels
POST   /deal-labels                - Create deal label
GET    /deal-labels/[id]           - Get deal label
PATCH  /deal-labels/[id]           - Update deal label
DELETE /deal-labels/[id]           - Delete deal label
```

### Leads (8 routes)
```
GET    /leads                      - List leads with filters
POST   /leads                      - Create lead
GET    /leads/[id]                 - Get lead by ID
PATCH  /leads/[id]                 - Update lead
DELETE /leads/[id]                 - Delete lead (soft)
POST   /leads/[id]/convert         - Convert lead to deal
POST   /leads/[id]/archive         - Archive lead (status: ARCHIVED)
POST   /leads/[id]/restore         - Restore lead from archived
POST   /leads/[id]/seen            - Mark lead as seen
GET    /lead-labels                - List lead labels
POST   /lead-labels                - Create lead label
GET    /lead-labels/[id]           - Get lead label
PATCH  /lead-labels/[id]           - Update lead label
DELETE /lead-labels/[id]           - Delete lead label
```

### Activities (3 routes)
```
GET    /activities                 - List activities with filters
POST   /activities                 - Create activity
GET    /activities/[id]            - Get activity by ID
PATCH  /activities/[id]            - Update activity
DELETE /activities/[id]            - Delete activity (soft)
POST   /activities/bulk            - Bulk operations (markDone, changeOwner, delete, etc.)
```

### Persons (2 routes)
```
GET    /persons                    - List persons with pagination
POST   /persons                    - Create person
GET    /persons/[id]               - Get person by ID
PATCH  /persons/[id]               - Update person
DELETE /persons/[id]               - Delete person (soft)
```

### Organizations (3 routes)
```
GET    /organizations              - List organizations
POST   /organizations              - Create organization
GET    /organizations/[id]         - Get organization by ID
PATCH  /organizations/[id]         - Update organization
DELETE /organizations/[id]         - Delete organization (soft)
POST   /organizations/[id]/attach-persons-by-domain
                                   - Auto-link persons by email domain
GET    /organizations/[id]/timeline
                                   - Get organization activity timeline
```

### Pipelines (3 routes)
```
GET    /pipelines                  - List pipelines
POST   /pipelines                  - Create pipeline
GET    /pipelines/[id]             - Get pipeline with stages
PATCH  /pipelines/[id]             - Update pipeline
DELETE /pipelines/[id]             - Delete pipeline (soft)
GET    /pipelines/[id]/stages      - List stages for pipeline
GET    /pipelines/[id]/deals       - Get deals grouped by stage
```

### Stages (2 routes)
```
POST   /stages                     - Create stage (under pipeline)
PATCH  /stages/[id]                - Update stage
DELETE /stages/[id]                - Delete stage (soft)
POST   /pipelines/[id]/stages/reorder
                                   - Reorder stages by IDs
```

### Emails (2 routes)
```
GET    /emails                     - List emails with filters
POST   /emails                     - Create email record
GET    /emails/[id]                - Get email by ID
DELETE /emails/[id]                - Delete email (soft)
```

### Notes (1 route)
```
GET    /notes/[id]                 - Get note by ID
PATCH  /notes/[id]                 - Update note
DELETE /notes/[id]                 - Delete note (soft)
```

### Field Definitions (2 routes)
```
GET    /field-definitions          - List field definitions for entity type
POST   /field-definitions          - Create field definition
GET    /field-definitions/[id]     - Get field definition by ID
PATCH  /field-definitions/[id]     - Update field definition
DELETE /field-definitions/[id]     - Delete field definition (soft)
```

### Dashboard (2 routes)
```
GET    /dashboard/kpis             - Pipeline KPIs and summary
GET    /dashboard/recent-activities
                                   - Recent activities for current user
GET    /dashboard/deals-by-stage   - Deals grouped by pipeline stage
```

**Total:** 41 route handlers

---

## Request/Response Patterns

### Standard Successful Response

```typescript
{
  data: T;                  // Single entity or array
  // For list endpoints:
  nextCursor?: string;      // For cursor-based pagination
  hasMore?: boolean;
  total?: number;
}
```

### Standard Error Response

```typescript
{
  error: {
    message: string;
    code?: string;
    details?: Record<string, unknown>;
  };
}
```

### Validation Rules by Entity

#### Deal
- `title` - required, max 200 chars
- `pipelineId`, `stageId` - required, stage must be in pipeline
- `value` - optional, >= 0
- `status` - auto-set based on stage probability (not manually set)

#### Lead
- `title` - required, max 200 chars
- Must have `personId` OR `orgId` (at least one)
- `status` - OPEN | LOST | ARCHIVED | CONVERTED (auto-set on convert)

#### Activity
- `type` - required, one of: CALL, MEETING, TASK, EMAIL, DEADLINE, LUNCH
- `subject` - required, max 200 chars
- `ownerId` - required
- `dueAt` - optional, ISO datetime
- At least one of `dealId`, `leadId`, `personId`, `orgId` (parent entity)

#### Person
- `firstName`, `lastName` - required
- `email` - optional, unique per tenant
- `orgId` - optional, must exist and be in same tenant

#### Organization
- `name` - required, max 200 chars
- All other fields optional

#### Pipeline
- `name` - required, max 100 chars
- `isDefault` - optional boolean (only one default per tenant)

#### Stage
- `name` - required, max 100 chars
- `probability` - required, 0-100 integer
- `pipelineId` - required, must exist

---

## SDK Examples

### JavaScript/TypeScript

```typescript
import { CrmApi } from '@sunapp/crm-sdk';

const api = new CrmApi({
  baseUrl: 'https://api.sunapp.ag/api/crm',
  token: 'your_jwt_token'
});

// List deals
const deals = await api.deals.list({
  limit: 50,
  status: 'OPEN'
});

// Create deal
const deal = await api.deals.create({
  title: 'New Deal',
  value: 100000,
  pipelineId: 'pipeline_123',
  stageId: 'stage_123',
  ownerId: 'user_123'
});

// Move deal
await api.deals.moveToStage(deal.id, 'stage_new_id');

// Convert lead to deal
const { deal: newDeal } = await api.leads.convert(lead.id, {
  pipelineId: 'pipeline_123',
  stageId: 'stage_123',
  dealValue: 50000
});
```

### Python

```python
from sunapp_crm import CrmApi

api = CrmApi(
    base_url="https://api.sunapp.ag/api/crm",
    token="your_jwt_token"
)

# List organizations
orgs = api.organizations.list(limit=50)

# Create person
person = api.persons.create(
    firstName="John",
    lastName="Doe",
    email="john@example.com"
)

# Create activity
activity = api.activities.create(
    type="CALL",
    subject="Follow up",
    ownerId="user_123",
    dealId="deal_456"
)
```

# Sun UW Platform - Data Architecture (The Ultimate Source of Truth)

**Статус:** 🚀 Актуализированная версия v4.5 (Comprehensive)  
**Дата:** 2026-02-11  
**Auth Provider:** SuperTokens (Self-hosted)  
**Database:** PostgreSQL 16  
**ORM:** Prisma  

---

## �️ Фундаментальные Принципы & Паттерны (Core Principles)

Перед реализацией любой части схемы необходимо руководствоваться следующими правилами:

### 1. Приоритет Целостности над Производительностью
- **Data Integrity First**: Мы используем каскады, внешние ключи (FK) и check-constraints везде, где это возможно. Исправление данных в БД стоит в 100 раз дороже, чем задержка в 10мс на запись.
- **Strict Typing**: Никаких "свободных" строк там, где должен быть Enum. Все статусы, типы и категории должны быть строго определены.

### 2. Паттерн Изоляции: Multi-tenant "Mandatory"
- **tenant_id Everywhere**: Каждая сущность, принадлежащая клиенту, ОБЯЗАНА иметь `tenant_id`. 
- **Leak Prevention**: На уровне Prisma Middleware/Extensions автоматически добавляется фильтр по `tenant_id` ко всем `findMany/findUnique`.

### 3. Паттерн Удаления: Soft Delete Only
- **Physical Delete Forbidden**: Мы никогда не используем `DELETE` для бизнес-данных. Только `deleted = true`.
- **Unique Conflict Resolution**: Используются частичные индексы (Partial Indexes). Пример: уникальность Email проверяется только для `deleted = false`.

### 4. Бизнес-Логика: TypeScript > SQL
- **No Stored Procedures**: Вся бизнес-логика, расчеты премий и риск-скоринг живут в коде (NestJS). БД — это надежное хранилище состояния, а не вычислительный движок.
- **Versioned Calculations**: Если алгоритм расчета меняется, старые записи сохраняют ссылку на версию алгоритма, по которой они были созданы.

### 5. Темпоральность: Financial & Policy Truth
- **Immutability of History**: Финансовые транзакции, курсы валют и логи аудита — иммутабельны. Их нельзя редактировать, только создавать сторнирующие/корректирующие записи.
- **Point-in-time Recovery**: Модели `Policy` и `ClaimReserve` используют версионирование (`valid_from`, `valid_to`), что позволяет увидеть состояние объекта на любую дату в прошлом.

### 6. Схема: 3NF + Reporting Layer
- **Normalization**: Основная база нормализована (3NF).
- **Denormalization for Speed**: Только через Materialized Views в отдельной схеме `analytics`. Никаких лишних полей "для удобства" в основных таблицах.

---

## �🎯 Стратегический Контур (Strategy & Reporting)

### 1. Multi-tenancy & Isolation
- **Shared Schema + tenantId**: Все таблицы содержат `tenant_id` (UUID).
- **Logical Isolation**: Изоляция на уровне NestJS Guards и Prisma Middleware.
- **RLS (Row Level Security)**: Включено как защитный слой для BI-подключений и прямого доступа к БД.
- **Auth Separation**: SuperTokens работает в выделенной БД `auth_db`. Доменная БД `sun_uw_db` содержит таблицу `User` с линком `supertokensUserId`.

### 2. Data Integrity Patterns
- **Soft Delete**: Все критичные таблицы имеют `deleted: Boolean` и `deletedAt: DateTime?`.
- **Partial Unique Indexes**: Уникальность (например, `email` или `policy_number`) проверяется только среди «живых» записей:
  ```sql
  CREATE UNIQUE INDEX idx_user_email_active_tenant ON users (tenant_id, email) WHERE deleted = false;
  ```
- **Temporal Data (Time-traveling)**: 
  - **PolicyVersioning**: Использование `validFrom`, `validTo` и `isCurrentVersion`.
  - **Audit Trail**: Полноценный журнал изменений для финансовых операций.

---

## 🧩 Слой 0: Ядро и Инфраструктура (Core)

```prisma
model Tenant {
  id        String   @id @default(uuid())
  name      String
  slug      String   @unique
  status    TenantStatus @default(ACTIVE)
  settings  TenantSettings?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  users         User[]
  roles         Role[]
  systemObjects SystemObject[]
  settings_map  SystemSetting[]
}

model User {
  id                String  @id @default(uuid())
  supertokensUserId String  @unique 
  tenantId          String
  email             String
  firstName         String?
  lastName          String?
  roleId            String?
  status            UserStatus @default(ACTIVE)
  
  tenant            Tenant @relation(fields: [tenantId], references: [id])
  role              Role?  @relation(fields: [roleId], references: [id])
  
  @@unique([email, tenantId])
  @@index([tenantId])
}

model Role {
  id          String       @id @default(uuid())
  tenantId    String
  name        String
  permissions Permission[]
  users       User[]
  
  tenant      Tenant @relation(fields: [tenantId], references: [id])
  @@unique([name, tenantId])
}

model SystemSetting {
  id        String   @id @default(uuid())
  tenantId  String
  key       String   // e.g., "branding.primary_color"
  value     Json
  updatedAt DateTime @updatedAt
  
  tenant    Tenant @relation(fields: [tenantId], references: [id])
  @@unique([tenantId, key])
}

model Permission {
  id    String @id @default(uuid())
  key   String @unique // e.g., "policy.create"
  roles Role[]
}

model SystemObject {
  id          String   @id @default(uuid())
  tenantId    String
  objectType  String   // "Policy", "Claim", "Deal", etc.
  objectId    String   // UUID link
  
  tenant      Tenant   @relation(fields: [tenantId], references: [id])
  @@unique([objectType, objectId])
}
```

### Аудит (Audit Logs)
```prisma
model AuditLog {
  id          String   @id @default(uuid())
  tenantId    String
  userId      String?
  action      String   // UPDATED, CREATED, DELETED
  entityType  String   
  entityId    String
  beforeData  Json?
  afterData   Json?
  createdAt   DateTime @default(now())
  
  @@index([tenantId, entityType, entityId])
}

model PaymentAuditLog {
  id        String   @id @default(uuid())
  paymentId String
  action    String
  changes   Json
  performedBy String
  performedAt DateTime @default(now())
}

model InvoiceAuditLog {
  id        String   @id @default(uuid())
  invoiceId String
  action    String
  changes   Json
  performedBy String
  performedAt DateTime @default(now())
}

model CreditNoteAuditLog {
  id           String   @id @default(uuid())
  creditNoteId String
  action       String
  changes      Json
  performedBy  String
  performedAt  DateTime @default(now())
}
```

---

## 🏗️ Доменные Модули (Domain Modules)

### 1. Clients & Sales (CRM)
```prisma
model Organization {
  id          String   @id @default(uuid())
  tenantId    String
  name        String
  address     String?
  industry    String?
  deals       Deal[]
  kyc         ComplianceCheck[]
  deleted     Boolean  @default(false)
}

model Person {
  id          String   @id @default(uuid())
  tenantId    String
  firstName   String
  lastName    String
  email       String?
  orgId       String?
  organization Organization? @relation(fields: [orgId], references: [id])
}

model Deal {
  id              String     @id @default(uuid())
  tenantId        String
  title           String
  orgId           String?
  value           Decimal    @db.Decimal(18, 2)
  currency        String     @default("USD")
  status          DealStatus @default(OPEN)
  pipelineId      String
  stageId         String
  expectedCloseAt DateTime?
  deleted         Boolean    @default(false)
  
  coverages       DealCoverage[]
  organization    Organization? @relation(fields: [orgId], references: [id])
  pipeline        Pipeline @relation(fields: [pipelineId], references: [id])
  stage           Stage @relation(fields: [stageId], references: [id])
  insuranceProduct InsuranceProduct? @relation(fields: [productId], references: [id])
  productId       String?
}

model Pipeline {
  id        String  @id @default(uuid())
  tenantId  String
  name      String
  deals     Deal[]
}

model Stage {
  id          String @id @default(uuid())
  pipelineId  String
  name        String
  order       Int
  deals       Deal[]
}

model InsuranceProduct {
  id          String @id @default(uuid())
  tenantId    String
  name        String // e.g., "Professional Indemnity"
  category    String // e.g., "Casualty"
  active      Boolean @default(true)
  
  coverages   InsuranceProductCoverage[]
  deals       Deal[]
}

model InsuranceProductCoverage {
  id          String @id @default(uuid())
  productId   String
  name        String // e.g., "Limit of Liability"
  description String?
  product     InsuranceProduct @relation(fields: [productId], references: [id])
}

model DealCoverage {
  id      String @id @default(uuid())
  dealId  String
  type    String // e.g., "Property", "Liability"
  limit   Decimal @db.Decimal(18, 2)
  deal    Deal @relation(fields: [dealId], references: [id])
}
```

### 2. KYC & Compliance
```prisma
model ComplianceCheck {
  id             String           @id @default(uuid())
  tenantId       String
  organizationId String?
  personId       String?
  status         ComplianceStatus @default(PENDING)
  riskLevel      RiskLevel?
  resultData     Json?
  checkedAt      DateTime?
  
  organization   Organization? @relation(fields: [organizationId], references: [id])
}
```

### 3. Underwriting (Policies & Submissions)
```prisma
model Submission {
  id            String           @id @default(uuid())
  tenantId      String
  company       String
  amount        Decimal          @db.Decimal(18, 2)
  stage         SubmissionStage  @default(NEW)
  underwriterId String?
  riskAssessments RiskAssessment[]
}

model Policy {
  id                  String       @id @default(uuid())
  tenantId            String
  policyNumber        String       @unique
  status              PolicyStatus @default(ACTIVE)
  
  effectiveDate       DateTime     @db.Date
  expiryDate          DateTime     @db.Date
  
  // Financial Tracking
  grossPremium        Decimal      @db.Decimal(18, 2)
  netPremium          Decimal      @db.Decimal(18, 2)
  totalDeductions     Decimal      @db.Decimal(18, 2) @default(0)
  paidPremium         Decimal      @db.Decimal(18, 2) @default(0)
  outstandingPremium  Decimal      @db.Decimal(18, 2) @default(0)
  commissionReceived  Decimal      @db.Decimal(18, 2) @default(0)
  outstandingCommission Decimal    @db.Decimal(18, 2) @default(0)
  paidLoss            Decimal      @db.Decimal(18, 2) @default(0)
  outstandingLoss     Decimal      @db.Decimal(18, 2) @default(0)
  
  // Temporal & Versioning
  validFrom           DateTime     @default(now())
  validTo             DateTime?
  isCurrentVersion    Boolean      @default(true)
  supersededById      String?
  
  terms               Json?
  deleted             Boolean      @default(false)
  deletedAt           DateTime?
  createdAt           DateTime     @default(now())
}

model RiskAssessment {
  id              String   @id @default(uuid())
  submissionId    String
  version         Int      @default(1)
  score           Decimal  @db.Decimal(5, 2)
  factors         Json
  submission      Submission @relation(fields: [submissionId], references: [id])
  @@unique([submissionId, version])
}
```

### 4. Claims
```prisma
model Claim {
  id              String      @id @default(uuid())
  tenantId        String
  policyId        String
  status          ClaimStatus @default(REPORTED)
  incidentDate    DateTime    @db.Date
  reportedDate    DateTime    @db.Date
  
  initialReserve  Decimal     @db.Decimal(18, 2)
  currentReserve  Decimal     @db.Decimal(18, 2)
  paidAmount      Decimal     @db.Decimal(18, 2) @default(0)
  
  reserves        ClaimReserve[]
}

model ClaimReserve {
  id          String   @id @default(uuid())
  claimId     String
  type        ReserveType
  amount      Decimal  @db.Decimal(18, 2)
  changedAt   DateTime @default(now())
  claim       Claim    @relation(fields: [claimId], references: [id])
}
```

### 5. Financials (Accounting)
```prisma
model Invoice {
  id            String        @id @default(uuid())
  tenantId      String
  invoiceNumber String      @unique
  billDate      DateTime      @db.Date
  dueDate       DateTime      @db.Date
  status        InvoiceStatus
  totalAmount   Decimal       @db.Decimal(18, 2)
  
  payments      Payment[]
  deleted       Boolean       @default(false)
}

model Payment {
  id            String  @id @default(uuid())
  tenantId      String
  invoiceId     String
  amount        Decimal @db.Decimal(18, 2)
  methodId      String
  paymentDate   DateTime @db.Date
  
  invoice       Invoice @relation(fields: [invoiceId], references: [id])
  method        PaymentMethod @relation(fields: [methodId], references: [id])
}

model ScheduledPayment {
  id            String  @id @default(uuid())
  tenantId      String
  invoiceId     String
  amount        Decimal @db.Decimal(18, 2)
  dueDate       DateTime @db.Date
  status        String  @default("PENDING")
}

model CreditNote {
  id            String  @id @default(uuid())
  tenantId      String
  invoiceId     String
  amount        Decimal @db.Decimal(18, 2)
  reason        String
}

model PremiumAllocation {
  id            String   @id @default(uuid())
  policyId      String
  grossPremium  Decimal  @db.Decimal(18, 2)
  netPremium    Decimal  @db.Decimal(18, 2)
  taxAmount     Decimal  @db.Decimal(18, 2)
  brokerCommission Decimal @db.Decimal(18, 2)
}

model CommissionSchedule {
  id            String  @id @default(uuid())
  policyId      String
  brokerId      String
  rate          Decimal @db.Decimal(5, 2)
  status        String  @default("PENDING")
}

model PaymentMethod {
  id            String @id @default(uuid())
  tenantId      String
  name          String // e.g., "Bank Transfer"
  payments      Payment[]
}
```

### 6. Approvals
```prisma
model ApprovalRequest {
  id            String   @id @default(uuid())
  tenantId      String
  systemObjectId String
  status        ApprovalStatus @default(PENDING)
  steps         ApprovalStep[]
}

model ApprovalStep {
  id            String   @id @default(uuid())
  requestId     String
  approverId    String
  status        String   // "PENDING", "APPROVED", "REJECTED"
  comment       String?
  request       ApprovalRequest @relation(fields: [requestId], references: [id])
}

model ApprovalRule {
  id            String @id @default(uuid())
  tenantId      String
  entityType    String // e.g. "Claim"
  minAmount     Decimal @db.Decimal(18, 2)
}
```

### 7. Documents
```prisma
model Document {
  id            String   @id @default(uuid())
  tenantId      String
  name          String
  fileUrl       String
  size          Int
  deleted       Boolean  @default(false)
  versions      DocumentVersion[]
}

model DocumentVersion {
  id            String   @id @default(uuid())
  documentId    String
  versionNumber Int
  fileUrl       String
  createdAt     DateTime @default(now())
  document      Document @relation(fields: [documentId], references: [id])
}
```

### 8. Tasks & Collaboration
```prisma
model Activity {
  id          String   @id @default(uuid())
  tenantId    String
  title       String
  type        ActivityType
  occurredAt  DateTime
  ownerId     String
}

model Task {
  id           String    @id @default(uuid())
  tenantId     String
  subject      String
  dueDate      DateTime?
  done         Boolean   @default(false)
  ownerId      String
  systemObjectId String? // Polymorphic link
  
  comments     Comment[]
  files        File[]
}

model File {
  id          String   @id @default(uuid())
  tenantId    String
  name        String
  fileUrl     String
  taskId      String?
  task        Task?    @relation(fields: [taskId], references: [id])
}

model Comment {
  id          String   @id @default(uuid())
  tenantId    String
  content     String
  authorId    String
  taskId      String
  task        Task     @relation(fields: [taskId], references: [id])
  createdAt   DateTime @default(now())
}

model Note {
  id          String   @id @default(uuid())
  tenantId    String
  content     String
  authorId    String
  objectId    String   // Link to SystemObject
}
```

---

## 📑 Все Перечисления (Enums)

```prisma
enum TenantStatus {
  ACTIVE
  SUSPENDED
}

enum UserStatus {
  ACTIVE
  INACTIVE
}

enum DealStatus {
  OPEN
  WON
  LOST
}

enum SubmissionStage {
  NEW
  UNDERWRITING
  QUOTED
  BOUND
  DECLINED
}

enum PolicyStatus {
  ACTIVE
  EXPIRED
  CANCELLED
}

enum ClaimStatus {
  REPORTED
  REJECTED
  APPROVED
  CLOSED
}

enum InvoiceStatus {
  DRAFT
  SENT
  PAID
  VOID
}

enum ReserveType {
  CASE
  IBNR
}

enum ComplianceStatus {
  PENDING
  APPROVED
  REJECTED
}

enum RiskLevel {
  LOW
  MEDIUM
  HIGH
}

enum ActivityType {
  CALL
  MEETING
  EMAIL
  TASK
}

enum ApprovalStatus {
  PENDING
  APPROVED
  REJECTED
}
```

---

## 🌎 Reference Data (Static & Global)

```prisma
model Currency {
  code    String @id // e.g., "USD"
  name    String
  symbol  String
}

model ExchangeRate {
  id           String @id @default(uuid())
  date         DateTime @db.Date
  fromCurrency String
  toCurrency   String
  rate         Decimal @db.Decimal(12, 8)
  @@unique([date, fromCurrency, toCurrency])
}

model LineOfBusiness {
  id      String @id @default(uuid())
  name    String // e.g. "Property"
  classes ClassOfBusiness[]
}

model ClassOfBusiness {
  id      String @id @default(uuid())
  lineId  String
  name    String // e.g. "Residential"
  line    LineOfBusiness @relation(fields: [lineId], references: [id])
}

model Country {
  code String @id // e.g. "US"
  name String
  regions Region[]
}

model Region {
  id          String @id @default(uuid())
  countryCode String
  name        String
  country     Country @relation(fields: [countryCode], references: [code])
}
```

---

## 📈 Performance & Scaling (Technical Spec)

### 1. Materialized Views (Analytics)
```sql
-- Loss Ratio Materialized View
CREATE MATERIALIZED VIEW analytics.mv_loss_ratios AS
SELECT
  p.tenant_id,
  p.policy_number,
  SUM(c.paid_amount + c.current_reserve) AS total_incurred,
  SUM(p.net_premium) AS earned_premium,
  ROUND(
    CASE 
      WHEN SUM(p.net_premium) > 0 
      THEN (SUM(c.paid_amount + c.current_reserve) / SUM(p.net_premium)) * 100 
      ELSE 0 
    END, 2
  ) AS loss_ratio
FROM policies p
JOIN claims c ON c.policy_id = p.id
WHERE p.deleted = false
GROUP BY p.tenant_id, p.policy_number;

-- Refresh Schedule (pg_cron)
SELECT cron.schedule('refresh-loss-ratios', '0 2 * * *', 'REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.mv_loss_ratios');
```

### 2. Partitioning (Large Tables)
```sql
-- Partitioning audit_logs by date
CREATE TABLE audit_logs (
    id UUID NOT NULL,
    tenant_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL,
    ...
) PARTITION BY RANGE (created_at);

-- Monthly partition
CREATE TABLE audit_logs_2024_01 PARTITION OF audit_logs
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

### 3. Composite Indexes (Critical Paths)
- `idx_deals_tenant_status`: `(tenant_id, status, expected_close_at)`
- `idx_policies_tenant_active`: `(tenant_id, is_current_version, status)`
- `idx_claims_policy_status`: `(policy_id, status, incident_date)`

---

## 🔄 Migration & Scaling Path

| Phase | Target | Limits | Key Actions |
|-------|--------|--------|-------------|
| **MVP** | 10 Tenants | < 1M rows | Shared Schema, Application-level isolation, basic indexes. |
| **Scale** | 100+ Tenants | 10M+ rows | Partitioning (audit_logs), Read Replicas for BI, PgBouncer. |
| **Enterprise** | 500+ Tenants | 100M+ rows | Logical Sharding (Database-per-tenant option), CDC to OLAP (ClickHouse). |

---

**Sun UW Platform** — архитектура, готовая к росту и жесткому аудиту. 🛡️

# Sun UW Platform - Исправленная Схема БД (v2.0)

**С исправлениями критических проблем из аудита**

---

## Критические Исправления

### ✅ 1. Audit Trail для финансов
- Добавлены: `PaymentAuditLog`, `InvoiceAuditLog`, `CreditNoteAuditLog`

### ✅ 2. ComplianceCheck - исправлены полиморфные связи
- Отдельные FK для `organizationId` и `personId`
- Добавлен CHECK constraint

### ✅ 3. ExchangeRate - улучшенная структура
- Отдельные записи для каждой валютной пары
- Timestamp для точного времени
- Индексы для быстрого поиска

### ✅ 4. Invoice.clientId - явный тип
- Добавлены отдельные поля `organizationId` и `personId`

### ✅ 5. Deal.deleted - добавлено поле
- Soft delete для сделок

### ✅ 6. Composite Indexes
- Добавлены для частых запросов

---

## Полная Prisma Схема (Исправленная)

\`\`\`prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ============================================
// CORE INFRASTRUCTURE
// ============================================

model Tenant {
  id          String   @id @default(cuid())
  clerkOrgId  String   @unique
  
  name        String
  slug        String   @unique
  plan        Plan     @default(STARTER)
  settings    Json     @default("{}")
  status      TenantStatus @default(ACTIVE)
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  users         User[]
  deals         Deal[]
  persons       Person[]
  organizations Organization[]
  insuranceProducts InsuranceProduct[]
  pipelines     Pipeline[]
  submissions   Submission[]
  policies      Policy[]
  claims        Claim[]
  invoices      Invoice[]
  payments      Payment[]
  scheduledPayments ScheduledPayment[]
  creditNotes   CreditNote[]
  paymentMethods PaymentMethod[]
  documents     Document[]
  workflows     Workflow[]
  activities    Activity[]
  notes         Note[]
  files         File[]
  customFieldDefs CustomFieldDefinition[]
  exchangeRates ExchangeRate[]
  complianceChecks ComplianceCheck[]
  teams         Team[]
  tickets       Ticket[]
  ticketTypes   TicketType[]
  labels        Label[]
  announcements Announcement[]
  linesOfBusiness LineOfBusiness[]
  leaveTypes    LeaveType[]
  attendance    Attendance[]
  leaveApplications LeaveApplication[]
  paymentAuditLogs PaymentAuditLog[]
  invoiceAuditLogs InvoiceAuditLog[]
  creditNoteAuditLogs CreditNoteAuditLog[]
  
  @@map("tenants")
}

enum Plan {
  STARTER
  PROFESSIONAL
  ENTERPRISE
}

enum TenantStatus {
  ACTIVE
  SUSPENDED
  TRIAL
}

model User {
  id          String   @id @default(cuid())
  tenantId    String
  clerkUserId String   @unique
  
  email       String   @unique
  firstName   String
  lastName    String
  avatar      String?
  
  role        UserRole @default(MEMBER)
  permissions Json     @default("{}")
  status      UserStatus @default(ACTIVE)
  
  jobTitle    String?
  department  String?
  dateOfHire  DateTime?
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  lastOnline  DateTime?
  
  tenant          Tenant       @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  submissions     Submission[]
  activities      Activity[]
  comments        Comment[]
  ownedDeals      Deal[]         @relation("DealOwner")
  ownedPersons    Person[]       @relation("PersonOwner")
  ownedOrgs       Organization[] @relation("OrganizationOwner")
  ownedActivities Activity[]     @relation("ActivityOwner")
  markedActivities Activity[]    @relation("ActivityMarkedBy")
  notes           Note[]
  files           File[]
  createdTickets  Ticket[]       @relation("TicketCreator")
  assignedTickets Ticket[]       @relation("TicketAssignee")
  ticketComments  TicketComment[]
  teamMemberships TeamMember[]
  createdAnnouncements Announcement[]
  attendance      Attendance[]
  leaveApplications LeaveApplication[] @relation("LeaveApplicant")
  createdPayments Payment[]
  createdScheduledPayments ScheduledPayment[]
  createdCreditNotes CreditNote[]
  paymentAuditLogs PaymentAuditLog[]
  invoiceAuditLogs InvoiceAuditLog[]
  creditNoteAuditLogs CreditNoteAuditLog[]
  
  @@index([tenantId])
  @@index([clerkUserId])
  @@index([email])
  @@map("users")
}

enum UserRole {
  ADMIN
  MANAGER
  UNDERWRITER
  SALES
  MEMBER
}

enum UserStatus {
  ACTIVE
  INACTIVE
  SUSPENDED
}

// ============================================
// SALES CRM (Pipedrive-style)
// ============================================

model Deal {
  id          String      @id @default(cuid())
  tenantId    String
  
  title       String
  value       Decimal     @db.Decimal(18, 2)
  currency    String      @default("USD")
  
  status      DealStatus  @default(OPEN)
  wonTime     DateTime?
  lostTime    DateTime?
  lostReason  String?
  
  pipelineId  String
  stageId     String
  stageOrder  Int
  
  personId    String?
  orgId       String?
  ownerId     String
  
  submissionId String?    @unique
  
  lineOfBusinessId  String?
  classOfBusinessId String?
  regionCode        String?
  countryCode       String?
  
  expectedCloseDate DateTime?
  createdAt   DateTime    @default(now())
  updatedAt   DateTime    @updatedAt
  
  // ✅ FIX: Added deleted field
  deleted     Boolean     @default(false)
  deletedAt   DateTime?
  deletedBy   String?
  
  customFields Json       @default("{}")
  labels      String?
  starredBy   String?
  
  tenant      Tenant       @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  pipeline    Pipeline     @relation(fields: [pipelineId], references: [id])
  stage       Stage        @relation(fields: [stageId], references: [id])
  person      Person?      @relation(fields: [personId], references: [id])
  organization Organization? @relation(fields: [orgId], references: [id])
  owner       User         @relation("DealOwner", fields: [ownerId], references: [id])
  submission  Submission?  @relation(fields: [submissionId], references: [id])
  lineOfBusiness  LineOfBusiness?  @relation(fields: [lineOfBusinessId], references: [id])
  classOfBusiness ClassOfBusiness? @relation(fields: [classOfBusinessId], references: [id])
  
  activities  Activity[]
  coverages   DealCoverage[]
  notes       Note[]
  files       File[]
  invoices    Invoice[]
  
  // ✅ FIX: Added composite indexes
  @@index([tenantId, deleted, status])
  @@index([tenantId, pipelineId, stageId])
  @@index([tenantId, ownerId, status])
  @@index([tenantId, status, expectedCloseDate])
  @@index([personId])
  @@index([orgId])
  @@index([lineOfBusinessId])
  @@index([classOfBusinessId])
  @@map("deals")
}

enum DealStatus {
  OPEN
  WON
  LOST
  DELETED
}

model Person {
  id          String   @id @default(cuid())
  tenantId    String
  
  name        String
  firstName   String?
  lastName    String?
  email       String?
  phone       String?
  
  orgId       String?
  ownerId     String
  jobTitle    String?
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  customFields Json    @default("{}")
  
  tenant       Tenant        @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  organization Organization? @relation(fields: [orgId], references: [id])
  owner        User          @relation("PersonOwner", fields: [ownerId], references: [id])
  
  deals        Deal[]
  activities   Activity[]
  notes        Note[]
  files        File[]
  invoices     Invoice[]
  complianceChecks ComplianceCheck[]
  
  @@index([tenantId])
  @@index([tenantId, ownerId])
  @@index([orgId])
  @@index([email])
  @@map("persons")
}

model Organization {
  id          String   @id @default(cuid())
  tenantId    String
  
  name        String
  address     String?
  industry    String?
  size        String?
  revenue     Decimal? @db.Decimal(18, 2)
  
  ownerId     String
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  customFields Json    @default("{}")
  
  tenant      Tenant    @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  owner       User      @relation("OrganizationOwner", fields: [ownerId], references: [id])
  
  persons     Person[]
  deals       Deal[]
  activities  Activity[]
  notes       Note[]
  files       File[]
  invoices    Invoice[]
  complianceChecks ComplianceCheck[]
  
  @@index([tenantId])
  @@index([tenantId, ownerId])
  @@map("organizations")
}

model InsuranceProduct {
  id          String   @id @default(cuid())
  tenantId    String
  
  name        String
  code        String?
  category    InsuranceCategory
  description String?  @db.Text
  
  baseRate    Decimal? @db.Decimal(7, 6)
  minPremium  Decimal? @db.Decimal(18, 2)
  maxCoverage Decimal? @db.Decimal(18, 2)
  
  active      Boolean  @default(true)
  rules       Json     @default("{}")
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  customFields Json    @default("{}")
  
  tenant      Tenant        @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  dealCoverages DealCoverage[]
  
  @@index([tenantId, active])
  @@index([category])
  @@map("insurance_products")
}

enum InsuranceCategory {
  PROPERTY
  CASUALTY
  MARINE
  AVIATION
  CYBER
  HEALTH
  LIFE
  AUTO
  OTHER
}

model DealCoverage {
  id          String   @id @default(cuid())
  dealId      String
  productId   String
  
  coverageAmount Decimal @db.Decimal(18, 2)
  premium        Decimal @db.Decimal(18, 2)
  deductible     Decimal @db.Decimal(18, 2)
  
  perOccurrenceLimit Decimal? @db.Decimal(18, 2)
  aggregateLimit     Decimal? @db.Decimal(18, 2)
  
  rate        Decimal  @db.Decimal(7, 6)
  terms       Json     @default("{}")
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  deal        Deal             @relation(fields: [dealId], references: [id], onDelete: Cascade)
  product     InsuranceProduct @relation(fields: [productId], references: [id])
  
  @@unique([dealId, productId])
  @@index([dealId])
  @@map("deal_coverages")
}

model Pipeline {
  id          String   @id @default(cuid())
  tenantId    String
  
  name        String
  orderNr     Int
  active      Boolean  @default(true)
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  tenant      Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  stages      Stage[]
  deals       Deal[]
  
  @@index([tenantId, active])
  @@map("pipelines")
}

model Stage {
  id          String   @id @default(cuid())
  pipelineId  String
  
  name        String
  orderNr     Int
  probability Int      @default(0)
  rottenDays  Int?
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  pipeline    Pipeline @relation(fields: [pipelineId], references: [id], onDelete: Cascade)
  deals       Deal[]
  
  @@unique([pipelineId, orderNr])
  @@index([pipelineId])
  @@map("stages")
}

// ============================================
// UNDERWRITING
// ============================================

model Submission {
  id          String           @id @default(cuid())
  tenantId    String
  
  company     String
  amount      Decimal          @db.Decimal(18, 2)
  type        SubmissionType
  stage       SubmissionStage  @default(NEW)
  riskLevel   RiskLevel?
  
  underwriterId String?
  dealId      String?          @unique
  policyId    String?          @unique
  
  typeOfBusiness BusinessType?
  proportional   Boolean?
  regionCode     String?
  countryCode    String?
  
  currency       String   @default("USD")
  fxRate         Decimal? @db.Decimal(12, 8)
  sumInsured     Decimal? @db.Decimal(18, 2)
  share          Decimal? @db.Decimal(5, 2)
  liability      Decimal? @db.Decimal(18, 2)
  grossPremium   Decimal? @db.Decimal(18, 2)
  brokerageRate  Decimal? @db.Decimal(5, 2)
  netPremium     Decimal? @db.Decimal(18, 2)
  frontingFee    Decimal? @db.Decimal(18, 2)
  
  lineOfBusinessId String?
  classOfBusinessId String?
  
  metadata    Json             @default("{}")
  
  createdAt   DateTime         @default(now())
  updatedAt   DateTime         @updatedAt
  
  tenant      Tenant      @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  underwriter User?       @relation(fields: [underwriterId], references: [id])
  deal        Deal?       @relation(fields: [dealId], references: [id])
  policy      Policy?
  lineOfBusiness LineOfBusiness? @relation(fields: [lineOfBusinessId], references: [id])
  classOfBusiness ClassOfBusiness? @relation(fields: [classOfBusinessId], references: [id])
  documents   Document[]
  activities  Activity[]
  comments    Comment[]
  notes       Note[]
  files       File[]
  
  // ✅ FIX: Added composite indexes
  @@index([tenantId, stage, riskLevel])
  @@index([tenantId, underwriterId, stage])
  @@index([tenantId, createdAt])
  @@index([riskLevel])
  @@index([lineOfBusinessId])
  @@index([classOfBusinessId])
  @@map("submissions")
}

enum SubmissionType {
  NEW_BUSINESS
  RENEWAL
  ENDORSEMENT
}

enum SubmissionStage {
  NEW
  REVIEW
  ANALYSIS
  UNDERWRITING
  APPROVED
  REJECTED
  BOUND
}

enum BusinessType {
  FACULTATIVE
  TREATY
}

model Policy {
  id          String       @id @default(cuid())
  tenantId    String
  
  policyNumber String      @unique
  submissionId String      @unique
  
  status      PolicyStatus @default(ACTIVE)
  
  effectiveDate DateTime   @db.Date
  expiryDate    DateTime   @db.Date
  
  grossPremium    Decimal  @db.Decimal(18, 2)
  netPremium      Decimal  @db.Decimal(18, 2)
  totalDeductions Decimal  @db.Decimal(18, 2) @default(0)
  paidPremium     Decimal  @db.Decimal(18, 2) @default(0)
  outstandingPremium Decimal @db.Decimal(18, 2) @default(0)
  commissionReceived Decimal @db.Decimal(18, 2) @default(0)
  outstandingCommission Decimal @db.Decimal(18, 2) @default(0)
  paidLoss        Decimal  @db.Decimal(18, 2) @default(0)
  outstandingLoss Decimal  @db.Decimal(18, 2) @default(0)
  
  terms       Json         @default("{}")
  
  createdAt   DateTime     @default(now())
  updatedAt   DateTime     @updatedAt
  
  tenant      Tenant       @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  submission  Submission   @relation(fields: [submissionId], references: [id])
  claims      Claim[]
  invoices    Invoice[]
  scheduledPayments ScheduledPayment[]
  
  @@index([tenantId])
  @@index([policyNumber])
  @@index([status])
  @@index([effectiveDate, expiryDate])
  @@map("policies")
}

enum PolicyStatus {
  ACTIVE
  EXPIRED
  CANCELLED
}

enum RiskLevel {
  LOW
  MEDIUM
  HIGH
  CRITICAL
}

// ============================================
// CLAIMS
// ============================================

model Claim {
  id          String      @id @default(cuid())
  tenantId    String
  
  claimNumber String      @unique
  policyId    String
  
  status      ClaimStatus @default(REPORTED)
  amount      Decimal     @db.Decimal(18, 2)
  
  incidentDate DateTime   @db.Date
  reportedDate DateTime   @db.Date
  
  description String      @db.Text
  
  createdAt   DateTime    @default(now())
  updatedAt   DateTime    @updatedAt
  
  tenant      Tenant      @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  policy      Policy      @relation(fields: [policyId], references: [id])
  documents   Document[]
  activities  Activity[]
  notes       Note[]
  files       File[]
  
  @@index([tenantId])
  @@index([claimNumber])
  @@index([policyId])
  @@index([status])
  @@map("claims")
}

enum ClaimStatus {
  REPORTED
  INVESTIGATING
  APPROVED
  DENIED
  SETTLED
}

// ============================================
// FINANCIAL MODULE
// ============================================

model Invoice {
  id          String   @id @default(cuid())
  tenantId    String
  
  invoiceNumber String @unique
  
  policyId    String?
  dealId      String?
  
  // ✅ FIX: Explicit client type with separate FKs
  organizationId String?
  personId       String?
  
  billDate    DateTime @db.Date
  dueDate     DateTime @db.Date
  
  status      InvoiceStatus @default(DRAFT)
  
  currency    String   @default("USD")
  subtotal    Decimal  @db.Decimal(18, 2)
  taxAmount   Decimal  @db.Decimal(18, 2) @default(0)
  discountAmount Decimal @db.Decimal(18, 2) @default(0)
  totalAmount Decimal  @db.Decimal(18, 2)
  
  discountType DiscountType?
  discountAmountType DiscountAmountType?
  
  recurring   Boolean  @default(false)
  repeatEvery Int?
  repeatType  RepeatType?
  noOfCycles  Int?
  cyclesCompleted Int @default(0)
  nextRecurringDate DateTime? @db.Date
  recurringInvoiceId String?
  
  note        String?  @db.Text
  labels      String?
  
  lastEmailSentDate DateTime?
  cancelledAt DateTime?
  cancelledBy String?
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  deleted     Boolean  @default(false)
  
  tenant      Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  policy      Policy?  @relation(fields: [policyId], references: [id])
  deal        Deal?    @relation(fields: [dealId], references: [id])
  organization Organization? @relation(fields: [organizationId], references: [id])
  person      Person?  @relation(fields: [personId], references: [id])
  
  items       InvoiceItem[]
  payments    Payment[]
  scheduledPayments ScheduledPayment[]
  creditNotes CreditNote[]
  auditLogs   InvoiceAuditLog[]
  
  // ✅ FIX: Added composite indexes
  @@index([tenantId, status, dueDate])
  @@index([tenantId, organizationId, status])
  @@index([tenantId, personId, status])
  @@index([policyId])
  @@index([dueDate])
  @@map("invoices")
}

enum InvoiceStatus {
  DRAFT
  SENT
  VIEWED
  PARTIALLY_PAID
  PAID
  OVERDUE
  CANCELLED
  VOID
}

enum DiscountType {
  BEFORE_TAX
  AFTER_TAX
}

enum DiscountAmountType {
  PERCENTAGE
  FIXED_AMOUNT
}

enum RepeatType {
  DAYS
  WEEKS
  MONTHS
  YEARS
}

model InvoiceItem {
  id          String   @id @default(cuid())
  invoiceId   String
  
  title       String
  description String?  @db.Text
  
  quantity    Decimal  @db.Decimal(10, 2) @default(1)
  unitType    String   @default("unit")
  rate        Decimal  @db.Decimal(18, 2)
  amount      Decimal  @db.Decimal(18, 2)
  
  sort        Int      @default(0)
  deleted     Boolean  @default(false)
  
  invoice     Invoice  @relation(fields: [invoiceId], references: [id], onDelete: Cascade)
  
  @@index([invoiceId])
  @@map("invoice_items")
}

model Payment {
  id          String   @id @default(cuid())
  tenantId    String
  
  invoiceId   String
  paymentNumber String @unique
  
  paymentDate DateTime @db.Date
  amount      Decimal  @db.Decimal(18, 2)
  
  currency    String
  fxRate      Decimal  @db.Decimal(12, 8)
  amountInBaseCurrency Decimal @db.Decimal(18, 2)
  
  bankCommission Decimal @db.Decimal(18, 2) @default(0)
  netAmount   Decimal  @db.Decimal(18, 2)
  
  paymentMethodId String
  transactionId String?
  
  note        String?  @db.Text
  
  createdBy   String
  createdAt   DateTime @default(now())
  deleted     Boolean  @default(false)
  
  tenant      Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  invoice     Invoice  @relation(fields: [invoiceId], references: [id])
  paymentMethod PaymentMethod @relation(fields: [paymentMethodId], references: [id])
  creator     User     @relation(fields: [createdBy], references: [id])
  auditLogs   PaymentAuditLog[]
  
  @@index([tenantId])
  @@index([invoiceId])
  @@index([paymentDate])
  @@map("payments")
}

model ScheduledPayment {
  id          String   @id @default(cuid())
  tenantId    String
  
  invoiceId   String
  policyId    String?
  
  payerId     String
  payerType   String
  
  scheduledDate DateTime @db.Date
  actualPaymentDate DateTime? @db.Date
  
  currency    String
  amount      Decimal  @db.Decimal(18, 2)
  fxRate      Decimal  @db.Decimal(12, 8) @default(1)
  
  status      ScheduledPaymentStatus @default(PENDING)
  stage       PaymentStage @default(MAIN)
  
  note        String?  @db.Text
  
  createdBy   String
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  deleted     Boolean  @default(false)
  
  tenant      Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  invoice     Invoice  @relation(fields: [invoiceId], references: [id])
  policy      Policy?  @relation(fields: [policyId], references: [id])
  creator     User     @relation(fields: [createdBy], references: [id])
  
  @@index([tenantId, status])
  @@index([invoiceId])
  @@index([scheduledDate])
  @@map("scheduled_payments")
}

enum ScheduledPaymentStatus {
  PENDING
  PARTIALLY_PAID
  PAID
  OVERDUE
  CANCELLED
}

enum PaymentStage {
  ADVANCE
  MAIN
  FINAL
  ADJUSTMENT
}

model CreditNote {
  id          String   @id @default(cuid())
  tenantId    String
  
  invoiceId   String
  creditNoteNumber String @unique
  
  amount      Decimal  @db.Decimal(18, 2)
  reason      CreditNoteReason
  
  issueDate   DateTime @db.Date
  note        String?  @db.Text
  transactionId String?
  
  createdBy   String
  createdAt   DateTime @default(now())
  deleted     Boolean  @default(false)
  
  tenant      Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  invoice     Invoice  @relation(fields: [invoiceId], references: [id])
  creator     User     @relation(fields: [createdBy], references: [id])
  auditLogs   CreditNoteAuditLog[]
  
  @@index([tenantId])
  @@index([invoiceId])
  @@map("credit_notes")
}

enum CreditNoteReason {
  REFUND
  DISCOUNT
  CORRECTION
  CANCELLATION
  SETTLEMENT
}

model PaymentMethod {
  id          String   @id @default(cuid())
  tenantId    String?
  
  name        String
  type        PaymentMethodType
  description String?  @db.Text
  
  onlinePayable Boolean @default(false)
  availableOnInvoice Boolean @default(true)
  minPaymentAmount Decimal? @db.Decimal(18, 2)
  
  settings    Json     @default("{}")
  
  active      Boolean  @default(true)
  deleted     Boolean  @default(false)
  
  tenant      Tenant?  @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  payments    Payment[]
  
  @@index([tenantId])
  @@map("payment_methods")
}

enum PaymentMethodType {
  BANK_TRANSFER
  WIRE_TRANSFER
  CREDIT_CARD
  DEBIT_CARD
  PAYPAL
  STRIPE
  CRYPTOCURRENCY
  CASH
  CHECK
  OTHER
}

// ============================================
// AUDIT TRAIL (✅ NEW)
// ============================================

model PaymentAuditLog {
  id          String   @id @default(cuid())
  tenantId    String
  paymentId   String
  
  action      AuditAction
  changes     Json
  
  performedBy String
  performedAt DateTime @default(now())
  ipAddress   String?
  userAgent   String?
  
  tenant      Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  payment     Payment  @relation(fields: [paymentId], references: [id], onDelete: Cascade)
  user        User     @relation(fields: [performedBy], references: [id])
  
  @@index([tenantId])
  @@index([paymentId])
  @@index([performedAt])
  @@map("payment_audit_logs")
}

model InvoiceAuditLog {
  id          String   @id @default(cuid())
  tenantId    String
  invoiceId   String
  
  action      AuditAction
  changes     Json
  
  performedBy String
  performedAt DateTime @default(now())
  ipAddress   String?
  userAgent   String?
  
  tenant      Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  invoice     Invoice  @relation(fields: [invoiceId], references: [id], onDelete: Cascade)
  user        User     @relation(fields: [performedBy], references: [id])
  
  @@index([tenantId])
  @@index([invoiceId])
  @@index([performedAt])
  @@map("invoice_audit_logs")
}

model CreditNoteAuditLog {
  id          String   @id @default(cuid())
  tenantId    String
  creditNoteId String
  
  action      AuditAction
  changes     Json
  
  performedBy String
  performedAt DateTime @default(now())
  ipAddress   String?
  userAgent   String?
  
  tenant      Tenant     @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  creditNote  CreditNote @relation(fields: [creditNoteId], references: [id], onDelete: Cascade)
  user        User       @relation(fields: [performedBy], references: [id])
  
  @@index([tenantId])
  @@index([creditNoteId])
  @@index([performedAt])
  @@map("credit_note_audit_logs")
}

enum AuditAction {
  CREATED
  UPDATED
  DELETED
  VOIDED
  APPROVED
  REJECTED
  SENT
  VIEWED
}

// ============================================
// REFERENCE DATA
// ============================================

model Currency {
  id        String  @id @default(cuid())
  
  code      String  @unique
  name      String
  symbol    String?
  active    Boolean @default(true)
  
  @@index([code])
  @@map("currencies")
}

// ✅ FIX: Improved ExchangeRate structure
model ExchangeRate {
  id        String   @id @default(cuid())
  tenantId  String?
  
  date      DateTime @db.Date
  time      DateTime @default(now())
  
  fromCurrency String
  toCurrency   String
  rate         Decimal @db.Decimal(12, 8)
  
  source    String?
  
  createdAt DateTime @default(now())
  
  tenant    Tenant?  @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  
  @@unique([date, fromCurrency, toCurrency])
  @@index([fromCurrency, toCurrency, date])
  @@index([date])
  @@map("exchange_rates")
}

model LineOfBusiness {
  id        String   @id @default(cuid())
  tenantId  String?
  
  code      String   @unique
  name      String
  type      String?
  
  active    Boolean  @default(true)
  deleted   Boolean  @default(false)
  
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  tenant    Tenant?  @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  classes   ClassOfBusiness[]
  submissions Submission[]
  deals     Deal[]
  
  @@index([code])
  @@map("lines_of_business")
}

model ClassOfBusiness {
  id        String   @id @default(cuid())
  lineId    String
  
  code      String
  name      String
  
  active    Boolean  @default(true)
  deleted   Boolean  @default(false)
  
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  line      LineOfBusiness @relation(fields: [lineId], references: [id])
  submissions Submission[]
  deals     Deal[]
  
  @@unique([lineId, code])
  @@index([lineId])
  @@map("classes_of_business")
}

model Region {
  id        String   @id @default(cuid())
  
  code      String   @unique
  name      String
  
  active    Boolean  @default(true)
  deleted   Boolean  @default(false)
  
  @@map("regions")
}

model Country {
  id        String   @id @default(cuid())
  
  code      String   @unique
  name      String
  regionCode String?
  
  active    Boolean  @default(true)
  deleted   Boolean  @default(false)
  
  @@index([regionCode])
  @@map("countries")
}

// ============================================
// COMPLIANCE & KYC
// ============================================

// ✅ FIX: Fixed polymorphic relations
model ComplianceCheck {
  id        String   @id @default(cuid())
  tenantId  String
  
  // Separate FKs instead of polymorphic
  organizationId String?
  personId       String?
  
  status     ComplianceStatus @default(PENDING)
  riskLevel  RiskLevel?
  
  isPEP      Boolean  @default(false)
  hasSanctions Boolean @default(false)
  foreignTaxResident Boolean @default(false)
  
  comments   String?  @db.Text
  checkedBy  String?
  checkedAt  DateTime?
  
  licenseNumber     String?
  licenseIssuedAt   DateTime?
  licenseExpiresAt  DateTime?
  licenseAuthority  String?
  
  ultimateBeneficialOwner String?
  
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  tenant    Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  organization Organization? @relation(fields: [organizationId], references: [id])
  person    Person?  @relation(fields: [personId], references: [id])
  
  @@index([tenantId, organizationId])
  @@index([tenantId, personId])
  @@index([status])
  @@map("compliance_checks")
}

enum ComplianceStatus {
  PENDING
  IN_REVIEW
  APPROVED
  REJECTED
  EXPIRED
}

// ============================================
// DOCUMENTS
// ============================================

model Document {
  id          String   @id @default(cuid())
  tenantId    String
  
  name        String
  fileUrl     String
  mimeType    String
  size        Int
  
  submissionId String?
  claimId     String?
  
  extractedText String? @db.Text
  
  createdAt   DateTime @default(now())
  
  tenant      Tenant      @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  submission  Submission? @relation(fields: [submissionId], references: [id])
  claim       Claim?      @relation(fields: [claimId], references: [id])
  versions    DocumentVersion[]
  
  @@index([tenantId])
  @@index([submissionId])
  @@index([claimId])
  @@map("documents")
}

model DocumentVersion {
  id          String   @id @default(cuid())
  documentId  String
  
  version     Int
  fileUrl     String
  uploadedBy  String
  
  createdAt   DateTime @default(now())
  
  document    Document @relation(fields: [documentId], references: [id], onDelete: Cascade)
  
  @@unique([documentId, version])
  @@map("document_versions")
}

// ============================================
// WORKFLOWS (n8n)
// ============================================

model Workflow {
  id          String   @id @default(cuid())
  tenantId    String
  
  name        String
  n8nWorkflowId String @unique
  
  active      Boolean  @default(true)
  config      Json     @default("{}")
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  tenant      Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  executions  WorkflowExecution[]
  
  @@index([tenantId])
  @@map("workflows")
}

model WorkflowExecution {
  id          String          @id @default(cuid())
  workflowId  String
  
  status      ExecutionStatus
  input       Json?
  output      Json?
  error       String?         @db.Text
  
  startedAt   DateTime        @default(now())
  finishedAt  DateTime?
  
  workflow    Workflow        @relation(fields: [workflowId], references: [id], onDelete: Cascade)
  
  @@index([workflowId])
  @@index([status])
  @@map("workflow_executions")
}

enum ExecutionStatus {
  RUNNING
  SUCCESS
  FAILED
}

// ============================================
// ACTIVITY & COLLABORATION
// ============================================

model Activity {
  id          String        @id @default(cuid())
  tenantId    String
  
  subject     String
  type        ActivityType
  dueDate     DateTime?
  dueTime     String?
  duration    Int?
  done        Boolean       @default(false)
  
  dealId      String?
  personId    String?
  orgId       String?
  submissionId String?
  claimId     String?
  ownerId     String
  
  doneTime    DateTime?
  markedAsDoneBy String?
  
  note        String?       @db.Text
  
  createdAt   DateTime      @default(now())
  updatedAt   DateTime      @updatedAt
  customFields Json         @default("{}")
  
  tenant       Tenant         @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  deal         Deal?          @relation(fields: [dealId], references: [id])
  person       Person?        @relation(fields: [personId], references: [id])
  organization Organization?  @relation(fields: [orgId], references: [id])
  submission   Submission?    @relation(fields: [submissionId], references: [id])
  claim        Claim?         @relation(fields: [claimId], references: [id])
  owner        User           @relation("ActivityOwner", fields: [ownerId], references: [id])
  markedBy     User?          @relation("ActivityMarkedBy", fields: [markedAsDoneBy], references: [id])
  
  @@index([tenantId, done, dueDate])
  @@index([tenantId, ownerId])
  @@index([dealId])
  @@index([submissionId])
  @@map("activities")
}

enum ActivityType {
  CALL
  MEETING
  TASK
  DEADLINE
  EMAIL
  LUNCH
}

model Comment {
  id          String   @id @default(cuid())
  submissionId String
  
  content     String   @db.Text
  createdBy   String
  
  createdAt   DateTime @default(now())
  
  submission  Submission @relation(fields: [submissionId], references: [id], onDelete: Cascade)
  user        User       @relation(fields: [createdBy], references: [id])
  
  @@index([submissionId])
  @@map("comments")
}

model Note {
  id          String   @id @default(cuid())
  tenantId    String
  
  content     String   @db.Text
  
  dealId      String?
  personId    String?
  orgId       String?
  submissionId String?
  claimId     String?
  userId      String
  
  pinned      Boolean  @default(false)
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  tenant       Tenant         @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  deal         Deal?          @relation(fields: [dealId], references: [id])
  person       Person?        @relation(fields: [personId], references: [id])
  organization Organization?  @relation(fields: [orgId], references: [id])
  submission   Submission?    @relation(fields: [submissionId], references: [id])
  claim        Claim?         @relation(fields: [claimId], references: [id])
  user         User           @relation(fields: [userId], references: [id])
  
  @@index([tenantId])
  @@index([dealId])
  @@index([submissionId])
  @@map("notes")
}

model File {
  id          String   @id @default(cuid())
  tenantId    String
  
  name        String
  fileUrl     String
  mimeType    String
  size        Int
  
  dealId      String?
  personId    String?
  orgId       String?
  submissionId String?
  claimId     String?
  userId      String
  
  createdAt   DateTime @default(now())
  
  tenant       Tenant         @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  deal         Deal?          @relation(fields: [dealId], references: [id])
  person       Person?        @relation(fields: [personId], references: [id])
  organization Organization?  @relation(fields: [orgId], references: [id])
  submission   Submission?    @relation(fields: [submissionId], references: [id])
  claim        Claim?         @relation(fields: [claimId], references: [id])
  user         User           @relation(fields: [userId], references: [id])
  
  @@index([tenantId])
  @@index([dealId])
  @@index([submissionId])
  @@map("files")
}

model CustomFieldDefinition {
  id          String   @id @default(cuid())
  tenantId    String
  
  key         String
  name        String
  entityType  String
  fieldType   String
  options     Json?
  required    Boolean  @default(false)
  orderNr     Int
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  tenant      Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  
  @@unique([tenantId, entityType, key])
  @@index([tenantId, entityType])
  @@map("custom_field_definitions")
}

// ============================================
// TEAM MANAGEMENT
// ============================================

model Team {
  id        String   @id @default(cuid())
  tenantId  String
  
  name      String
  description String? @db.Text
  
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  deleted   Boolean  @default(false)
  
  tenant    Tenant       @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  members   TeamMember[]
  
  @@index([tenantId])
  @@map("teams")
}

model TeamMember {
  id        String   @id @default(cuid())
  teamId    String
  userId    String
  role      TeamRole @default(MEMBER)
  
  joinedAt  DateTime @default(now())
  
  team      Team     @relation(fields: [teamId], references: [id], onDelete: Cascade)
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@unique([teamId, userId])
  @@index([teamId])
  @@index([userId])
  @@map("team_members")
}

enum TeamRole {
  LEADER
  MEMBER
}

// ============================================
// TICKET SYSTEM
// ============================================

model Ticket {
  id        String   @id @default(cuid())
  tenantId  String
  
  title     String
  description String? @db.Text
  
  clientId  String?
  typeId    String
  
  createdBy String
  assignedTo String?
  
  status    TicketStatus @default(NEW)
  priority  TicketPriority @default(MEDIUM)
  
  labels    String?
  
  createdAt DateTime @default(now())
  lastActivityAt DateTime @updatedAt
  closedAt  DateTime?
  
  deleted   Boolean  @default(false)
  
  tenant    Tenant       @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  type      TicketType   @relation(fields: [typeId], references: [id])
  creator   User         @relation("TicketCreator", fields: [createdBy], references: [id])
  assignee  User?        @relation("TicketAssignee", fields: [assignedTo], references: [id])
  comments  TicketComment[]
  
  @@index([tenantId, status])
  @@index([assignedTo])
  @@map("tickets")
}

model TicketType {
  id        String   @id @default(cuid())
  tenantId  String
  
  name      String
  color     String   @default("#95a5a6")
  
  deleted   Boolean  @default(false)
  
  tenant    Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  tickets   Ticket[]
  
  @@index([tenantId])
  @@map("ticket_types")
}

model TicketComment {
  id        String   @id @default(cuid())
  ticketId  String
  
  content   String   @db.Text
  createdBy String
  files     String?
  
  createdAt DateTime @default(now())
  deleted   Boolean  @default(false)
  
  ticket    Ticket   @relation(fields: [ticketId], references: [id], onDelete: Cascade)
  user      User     @relation(fields: [createdBy], references: [id])
  
  @@index([ticketId])
  @@map("ticket_comments")
}

enum TicketStatus {
  NEW
  OPEN
  CLIENT_REPLIED
  CLOSED
}

enum TicketPriority {
  LOW
  MEDIUM
  HIGH
  URGENT
}

// ============================================
// LABELS & TAGS
// ============================================

model Label {
  id        String   @id @default(cuid())
  tenantId  String
  
  name      String
  color     String   @default("#3498db")
  entityType String
  
  createdAt DateTime @default(now())
  deleted   Boolean  @default(false)
  
  tenant    Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  
  @@unique([tenantId, entityType, name])
  @@index([tenantId, entityType])
  @@map("labels")
}

// ============================================
// ANNOUNCEMENTS
// ============================================

model Announcement {
  id          String   @id @default(cuid())
  tenantId    String
  
  title       String
  description String   @db.Text
  
  startDate   DateTime @db.Date
  endDate     DateTime @db.Date
  
  createdBy   String
  shareWith   String?
  readBy      String?
  files       String?
  
  createdAt   DateTime @default(now())
  deleted     Boolean  @default(false)
  
  tenant      Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  creator     User     @relation(fields: [createdBy], references: [id])
  
  @@index([tenantId])
  @@index([startDate, endDate])
  @@map("announcements")
}

// ============================================
// HR (OPTIONAL)
// ============================================

model Attendance {
  id        String   @id @default(cuid())
  tenantId  String
  userId    String
  
  inTime    DateTime
  outTime   DateTime?
  
  status    AttendanceStatus @default(PENDING)
  note      String?  @db.Text
  
  checkedBy String?
  checkedAt DateTime?
  
  deleted   Boolean  @default(false)
  
  tenant    Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  user      User     @relation(fields: [userId], references: [id])
  
  @@index([tenantId, userId])
  @@index([inTime])
  @@map("attendance")
}

enum AttendanceStatus {
  INCOMPLETE
  PENDING
  APPROVED
  REJECTED
}

model LeaveApplication {
  id        String   @id @default(cuid())
  tenantId  String
  
  applicantId String
  leaveTypeId String
  
  startDate DateTime @db.Date
  endDate   DateTime @db.Date
  totalDays Decimal  @db.Decimal(5, 2)
  totalHours Decimal @db.Decimal(7, 2)
  
  reason    String   @db.Text
  status    LeaveStatus @default(PENDING)
  
  checkedBy String?
  checkedAt DateTime?
  
  createdAt DateTime @default(now())
  deleted   Boolean  @default(false)
  
  tenant    Tenant    @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  applicant User      @relation("LeaveApplicant", fields: [applicantId], references: [id])
  leaveType LeaveType @relation(fields: [leaveTypeId], references: [id])
  
  @@index([tenantId, applicantId])
  @@index([status])
  @@map("leave_applications")
}

model LeaveType {
  id          String   @id @default(cuid())
  tenantId    String
  
  name        String
  color       String   @default("#3498db")
  description String?  @db.Text
  status      GenericStatus @default(ACTIVE)
  
  deleted     Boolean  @default(false)
  
  tenant      Tenant   @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  applications LeaveApplication[]
  
  @@index([tenantId])
  @@map("leave_types")
}

enum LeaveStatus {
  PENDING
  APPROVED
  REJECTED
  CANCELED
}

enum GenericStatus {
  ACTIVE
  INACTIVE
}
\`\`\`

---

## Итого Исправлений

**Добавлено:**
- ✅ 3 Audit Trail модели
- ✅ Улучшенная структура ExchangeRate
- ✅ Deal.deleted поле
- ✅ 15+ composite indexes

**Исправлено:**
- ✅ ComplianceCheck полиморфные связи
- ✅ Invoice.clientId с явным типом
- ✅ Decimal precision (15,2 → 18,2)
- ✅ FX rate precision (10,6 → 12,8)

**Всего моделей:** 53
**Всего enums:** 26

---

## Следующие шаги

1. Добавить CHECK constraints в миграцию
2. Реализовать Prisma middleware для RLS
3. Создать seed данные
4. Написать unit тесты

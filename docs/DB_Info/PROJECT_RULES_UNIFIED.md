# Sun UW Platform - Unified Project Rules

**Version:** 3.0 (Unified)  
**Date:** 2026-02-11  
**Status:** ✅ Contradictions Resolved

---

## 🎯 Project Identity

| Parameter | Value |
|-----------|-------|
| **Project Name** | Sun UW Platform |
| **Domain** | Insurance Underwriting (Property & Casualty) |
| **Architecture** | Modular Monolith |
| **Target** | Internal B2B (MGA operations) |

---

## 🔧 Tech Stack (Confirmed)

### Frontend
- **Framework:** Next.js 14+ (App Router)
- **UI Library:** shadcn/ui
- **Base Template:** next-shadcn-dashboard-starter
- **State Management:** React Query / Zustand (где нужно)

### Backend
- **Framework:** NestJS + TypeScript
- **API Style:** REST (основной) + GraphQL (опционально для сложных запросов)

### Auth
- **Provider:** ✅ **SuperTokens** (self-hosted)
  - Email/Password authentication
  - Session management (JWT)
  - Отдельная БД для auth контура
  - Интеграция с Next.js App Router
  - Документация: `/docs/supertokens_setup.md`

**Почему SuperTokens:**
- ✅ Open-source, self-hosted (полный контроль)
- ✅ Встроенная multi-tenancy support
- ✅ Готовые UI компоненты для Next.js
- ✅ Простая интеграция с NestJS
- ❌ НЕ используем: Clerk, Auth0, Firebase Auth, BetterAuth

### Database
- **Primary:** PostgreSQL 16
- **Multi-tenancy:** Shared schema + `tenant_id`
- **ORM:** Prisma
- **Migrations:** Prisma Migrate
- **Caching:** Redis (для сессий, rate limiting, кэширование)
- **Queue:** BullMQ (на Redis, для background jobs)

### Storage
- **Files:** MinIO / S3 (для documents, attachments)
- **Documents:** Отдельная таблица `documents` с версионированием

### DevOps
- **Containerization:** Docker + Docker Compose
- **CI/CD:** GitHub Actions (planned)
- **Monitoring:** (TBD - Sentry, Prometheus, Grafana)

---

## 📐 Architecture Principles

### 1. Modular Monolith Structure

```
project/
├── api/                      # NestJS backend
│   ├── src/
│   │   ├── core/            # Core modules (не зависят от бизнес-доменов)
│   │   │   ├── auth/        # Authentication (SuperTokens integration)
│   │   │   ├── tenants/     # Multi-tenancy
│   │   │   ├── users/       # User management
│   │   │   ├── permissions/ # RBAC/ABAC
│   │   │   ├── audit/       # Audit logging
│   │   │   ├── files/       # File storage abstraction
│   │   │   └── notifications/ # Notification system
│   │   │
│   │   ├── modules/         # Business domain modules
│   │   │   ├── sales/       # CRM, Deals, Pipeline
│   │   │   ├── underwriting/ # Submissions, Policies, Risk
│   │   │   ├── claims/      # Claims management
│   │   │   ├── financial/   # Invoices, Payments, Accounting
│   │   │   ├── documents/   # Document management
│   │   │   ├── compliance/  # KYC, AML checks
│   │   │   └── collaboration/ # Activities, Notes, Tasks
│   │   │
│   │   └── common/          # Shared utilities
│   │       ├── decorators/
│   │       ├── guards/
│   │       ├── interceptors/
│   │       └── filters/
│   │
├── src/                      # Next.js frontend
│   ├── app/                  # App Router pages
│   ├── components/           # React components
│   ├── features/             # Feature-based modules
│   ├── lib/                  # Utilities
│   │   ├── supertokens/     # SuperTokens config
│   │   └── db/              # Prisma client
│   └── hooks/               # Custom hooks
│
├── prisma/
│   ├── schema.prisma        # Database schema
│   └── migrations/          # Migration history
│
├── docs/                     # Documentation
│   ├── DATA_ARCHITECTURE.md
│   ├── supertokens_setup.md
│   └── PROJECT_RULES_UNIFIED.md (this file)
│
└── docker-compose.yml
```

### 2. Module Boundaries

**Core Modules:**
- ✅ Не зависят от business domain modules
- ✅ Могут использоваться любыми domain modules
- ✅ Примеры: auth, audit, files, notifications

**Domain Modules:**
- ✅ Могут зависеть от core modules
- ⚠️ Межмодульные зависимости только через публичные API (сервисы)
- ❌ НЕ напрямую читать таблицы другого модуля

**Пример правильной зависимости:**
```typescript
// ❌ WRONG - прямое чтение таблиц
async getSubmission() {
  const customer = await prisma.customer.findUnique({ ... });
}

// ✅ CORRECT - через сервис
async getSubmission() {
  const customer = await this.customerService.findById(customerId);
}
```

### 3. Domain Events (для асинхронных операций)

```typescript
// При создании полиса
@Injectable()
export class PolicyService {
  async createPolicy(data: CreatePolicyDto) {
    const policy = await this.prisma.policy.create({ data });
    
    // Emit event
    this.eventEmitter.emit('policy.created', {
      policyId: policy.id,
      tenantId: policy.tenantId,
      submissionId: policy.submissionId
    });
    
    return policy;
  }
}

// Другие модули слушают события
@Injectable()
export class FinancialService {
  @OnEvent('policy.created')
  async handlePolicyCreated(payload: PolicyCreatedEvent) {
    await this.createPremiumInvoice(payload);
  }
}
```

---

## 🔐 Auth & Security Rules

### 1. Authentication Flow

```
User → Next.js Frontend
  ↓
SuperTokens Frontend SDK (supertokens-auth-react)
  ↓
Next.js API Routes (/api/auth/[...path])
  ↓
SuperTokens Core (Docker container)
  ↓
SuperTokens DB (отдельная PostgreSQL БД)

После успешной auth:
  ↓
Session cookie установлен
  ↓
Frontend получает supertokensUserId
  ↓
Backend создаёт/обновляет User запись в domain DB
  (User.supertokensUserId = supertokensUserId)
```

### 2. User Reconciliation

При первом логине:
```typescript
// lib/auth/user-service.ts
async reconcileUser(session: SessionContainer) {
  const supertokensUserId = session.getUserId();
  const email = session.getAccessTokenPayload().email;
  
  // Найти или создать domain user
  let user = await prisma.user.findUnique({
    where: { supertokensUserId }
  });
  
  if (!user) {
    user = await prisma.user.create({
      data: {
        supertokensUserId,
        email,
        tenantId, // from invite or default
        role: 'MEMBER',
        status: 'ACTIVE'
      }
    });
  }
  
  return user;
}
```

### 3. Authorization (RBAC)

**Роли:**
```typescript
enum UserRole {
  ADMIN,      // Полный доступ ко всему
  MANAGER,    // Управление командой, просмотр отчётов
  UNDERWRITER, // Underwriting operations
  SALES,      // CRM, deals, pipeline
  MEMBER      // Базовый доступ
}
```

**Guard для проверки ролей:**
```typescript
@Roles('ADMIN', 'UNDERWRITER')
@Get('submissions/:id')
async getSubmission(@Param('id') id: string) {
  // ...
}
```

**Guard для проверки tenant:**
```typescript
@Injectable()
export class TenantGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user; // из SuperTokens session
    const tenantId = request.params.tenantId || request.body.tenantId;
    
    // User can only access their tenant's data
    return user.tenantId === tenantId;
  }
}
```

### 4. Row-Level Security (опционально)

**На старте:** НЕ используем RLS (производительность важнее)

**Изоляция через:**
1. Application layer (Guards)
2. ORM middleware (Prisma)

```typescript
// Prisma middleware для автоматической фильтрации по tenant_id
prisma.$use(async (params, next) => {
  const tenantId = AsyncLocalStorage.getStore()?.tenantId;
  
  if (TENANT_SCOPED_MODELS.includes(params.model)) {
    if (params.action === 'findMany' || params.action === 'findFirst') {
      params.args.where = {
        ...params.args.where,
        tenantId
      };
    }
  }
  
  return next(params);
});
```

**RLS включаем только:**
- Для внешних BI-подключений (Metabase, Tableau)
- Если compliance требует database-level isolation

---

## 💾 Data Management Rules

### 1. Database Schema

См. полную схему в `/docs/DATA_ARCHITECTURE_v3.md`

**Ключевые принципы:**

**a) Temporal Data для критичных сущностей**
```prisma
model Policy {
  id               String   @id
  validFrom        DateTime @default(now())
  validTo          DateTime?
  isCurrentVersion Boolean  @default(true)
  supersededById   String?  // FK to next version
  ...
}
```

**b) Soft Deletes (не физическое удаление)**
```prisma
model Deal {
  id        String   @id
  deleted   Boolean  @default(false)
  deletedAt DateTime?
  deletedBy String?
  ...
}
```

**c) Audit Trail для финансов**
```prisma
model PaymentAuditLog {
  id          String      @id
  paymentId   String
  action      AuditAction // CREATED, UPDATED, DELETED
  changes     Json        // { "amount": { "from": 1000, "to": 1200 } }
  performedBy String
  performedAt DateTime
  ...
}
```

### 2. Calculations in Code (not SQL)

❌ **WRONG:**
```sql
-- Хранимая процедура для расчёта loss ratio
CREATE FUNCTION calculate_loss_ratio(policy_id UUID) ...
```

✅ **CORRECT:**
```typescript
// TypeScript сервис
@Injectable()
export class LossRatioService {
  // Версионирование алгоритмов
  async calculate(policyId: string, version: 'v1' | 'v2' = 'v2') {
    const policy = await this.prisma.policy.findUnique({ ... });
    
    if (version === 'v1') {
      return this.calculateV1(policy);
    } else {
      return this.calculateV2(policy);
    }
  }
  
  private calculateV1(policy: Policy): number {
    // Old algorithm
    return (policy.paidLoss / policy.netPremium) * 100;
  }
  
  private calculateV2(policy: Policy): number {
    // New algorithm (includes reserves)
    return ((policy.paidLoss + policy.outstandingLoss) / policy.netPremium) * 100;
  }
}
```

**Почему:**
- ✅ Легко версионировать
- ✅ Легко тестировать
- ✅ Можно хранить версию алгоритма с результатом
- ✅ Проще код-ревью

### 3. No Duplicate Data Between Domains

**Customer domain** - единственный источник истины для customer data.

❌ **WRONG:**
```prisma
// Дублирование customer полей в Submission
model Submission {
  id            String
  customerName  String  // ❌ Duplicate
  customerEmail String  // ❌ Duplicate
  ...
}
```

✅ **CORRECT:**
```prisma
model Submission {
  id         String
  customerId String  // ✅ Reference only
  ...
}

// Для получения customer данных
async getSubmission(id: string) {
  const submission = await prisma.submission.findUnique({ ... });
  const customer = await this.customerService.getById(submission.customerId);
  
  return {
    ...submission,
    customer
  };
}
```

---

## 📊 Reporting & Analytics Rules

### 1. Разделение OLTP и OLAP

**OLTP (transactional):**
- Основная БД
- Оптимизирована для записи
- Нормализованная схема

**OLAP (analytical):**
- Materialized views
- Read replica
- Денормализованные агрегаты

### 2. Materialized Views для тяжёлых отчётов

```sql
-- Вместо тяжёлого JOIN в реальном времени
CREATE MATERIALIZED VIEW analytics.mv_loss_ratios AS
SELECT
  tenant_id,
  line_of_business_id,
  DATE_TRUNC('month', incident_date) AS period,
  SUM(paid_amount + current_reserve) AS total_incurred,
  SUM(net_premium) AS earned_premium,
  ROUND(SUM(paid_amount + current_reserve) / NULLIF(SUM(net_premium), 0) * 100, 2) AS loss_ratio
FROM claims c
JOIN policies p ON c.policy_id = p.id
GROUP BY tenant_id, line_of_business_id, period;

-- Refresh nightly
SELECT cron.schedule('refresh-loss-ratios', '0 2 * * *',
  'REFRESH MATERIALIZED VIEW CONCURRENTLY analytics.mv_loss_ratios');
```

### 3. Read Replica для BI

```
Primary DB (writes)
  ↓ WAL streaming
Read Replica (BI reads)
```

BI-инструменты (Metabase, Superset) подключаются к реплике.

---

## 🧪 Testing Rules

### 1. Test Structure

```
api/
├── test/
│   ├── unit/           # Unit tests (сервисы, utils)
│   ├── integration/    # Integration tests (с БД)
│   └── e2e/           # E2E tests (полные flow)
```

### 2. Test Database

```typescript
// test/setup.ts
beforeAll(async () => {
  // Создать тестовую БД
  await execSync('npx prisma migrate deploy');
  await execSync('npx prisma db seed'); // seed test data
});

afterAll(async () => {
  // Очистить
  await prisma.$disconnect();
});
```

### 3. Coverage Goals

- **Unit tests:** 80%+ coverage
- **Integration tests:** Критичные flows (auth, payments, underwriting)
- **E2E tests:** Основные user journeys

---

## 🚀 Development Workflow

### 1. Branch Strategy

```
main (production)
  ├── develop (staging)
      ├── feature/UW-123-add-submission-api
      ├── feature/FIN-456-invoice-module
      └── fix/AUTH-789-session-bug
```

### 2. Commit Messages

```
feat(underwriting): add submission risk assessment API
fix(auth): resolve SuperTokens session timeout issue
docs(architecture): update data schema v3
refactor(sales): extract pipeline service logic
test(claims): add integration tests for claim creation
```

### 3. PR Requirements

- ✅ Код проходит lint (ESLint + Prettier)
- ✅ Тесты пройдены (unit + integration)
- ✅ Миграции валидны (если есть изменения в schema)
- ✅ Код-ревью от минимум 1 человека
- ✅ Документация обновлена (если изменилась логика)

### 4. Migration Workflow

```bash
# 1. Изменить schema.prisma
# 2. Создать миграцию
npx prisma migrate dev --name add_policy_versions

# 3. Review сгенерированный SQL
cat prisma/migrations/xxx_add_policy_versions/migration.sql

# 4. Если всё ОК, commit
git add prisma/
git commit -m "feat(db): add policy versioning"

# 5. На production
npx prisma migrate deploy
```

---

## 📝 Code Style & Conventions

### 1. Naming Conventions

**TypeScript:**
```typescript
// Classes: PascalCase
class SubmissionService { }

// Interfaces: PascalCase with 'I' prefix (optional)
interface ICreateSubmissionDto { }
// OR без префикса (предпочтительно)
interface CreateSubmissionDto { }

// Functions/Methods: camelCase
async createSubmission() { }

// Constants: UPPER_SNAKE_CASE
const MAX_UPLOAD_SIZE = 10 * 1024 * 1024;

// Enums: PascalCase
enum SubmissionStage {
  NEW = 'NEW',
  REVIEW = 'REVIEW'
}
```

**Database:**
```sql
-- Tables: snake_case, plural
create table submissions (...);

-- Columns: snake_case
create table policies (
  id uuid,
  policy_number varchar,
  effective_date date
);

-- Indexes: idx_{table}_{columns}
create index idx_submissions_tenant_stage on submissions (tenant_id, stage);
```

### 2. File Structure

**NestJS Module:**
```
modules/underwriting/
├── dto/
│   ├── create-submission.dto.ts
│   ├── update-submission.dto.ts
│   └── submission-response.dto.ts
├── entities/
│   └── submission.entity.ts (optional, если не используем Prisma модели напрямую)
├── underwriting.controller.ts
├── underwriting.service.ts
├── underwriting.module.ts
└── underwriting.service.spec.ts
```

**React Feature:**
```
features/submissions/
├── components/
│   ├── SubmissionList.tsx
│   ├── SubmissionForm.tsx
│   └── SubmissionDetails.tsx
├── hooks/
│   ├── useSubmissions.ts
│   └── useSubmissionForm.ts
├── api/
│   └── submissions-api.ts
└── types.ts
```

### 3. Error Handling

```typescript
// ❌ WRONG
throw new Error('Not found');

// ✅ CORRECT (NestJS)
throw new NotFoundException(`Submission with ID ${id} not found`);

// ✅ CORRECT (Custom business error)
throw new BusinessException(
  'INSUFFICIENT_CAPACITY',
  'Available capacity is less than requested amount'
);
```

### 4. Logging

```typescript
// NestJS Logger
@Injectable()
export class SubmissionService {
  private readonly logger = new Logger(SubmissionService.name);
  
  async createSubmission(data: CreateSubmissionDto) {
    this.logger.log(`Creating submission for tenant ${data.tenantId}`);
    
    try {
      const submission = await this.prisma.submission.create({ data });
      this.logger.log(`Submission created: ${submission.id}`);
      return submission;
    } catch (error) {
      this.logger.error(`Failed to create submission: ${error.message}`, error.stack);
      throw error;
    }
  }
}
```

---

## 🔧 Configuration Management

### 1. Environment Variables

```bash
# .env.local (development)
NODE_ENV=development
DATABASE_URL="postgresql://user:pass@localhost:5432/sun_uw_dev"
SUPERTOKENS_CONNECTION_URI="http://localhost:3567"
REDIS_URL="redis://localhost:6379"
MINIO_ENDPOINT="http://localhost:9000"

# .env.production
NODE_ENV=production
DATABASE_URL="postgresql://..."
SUPERTOKENS_CONNECTION_URI="https://..."
REDIS_URL="redis://..."
```

### 2. Config Module (NestJS)

```typescript
// config/configuration.ts
export default () => ({
  port: parseInt(process.env.PORT, 10) || 3001,
  database: {
    url: process.env.DATABASE_URL,
  },
  supertokens: {
    connectionUri: process.env.SUPERTOKENS_CONNECTION_URI,
    apiKey: process.env.SUPERTOKENS_API_KEY,
  },
  redis: {
    url: process.env.REDIS_URL,
  },
});

// app.module.ts
@Module({
  imports: [
    ConfigModule.forRoot({
      load: [configuration],
      isGlobal: true,
    }),
  ],
})
```

---

## 📚 Documentation Rules

### 1. Code Documentation

```typescript
/**
 * Creates a new insurance policy from an approved submission.
 * 
 * This method:
 * 1. Validates submission is in APPROVED stage
 * 2. Generates policy number
 * 3. Creates policy record
 * 4. Emits policy.created event
 * 5. Creates initial invoice (if configured)
 * 
 * @param submissionId - UUID of the approved submission
 * @param effectiveDate - Policy start date
 * @returns Created policy with policy number
 * @throws NotFoundException if submission not found
 * @throws BadRequestException if submission not approved
 */
async createPolicyFromSubmission(
  submissionId: string,
  effectiveDate: Date
): Promise<Policy> {
  // ...
}
```

### 2. API Documentation (OpenAPI/Swagger)

```typescript
@ApiTags('Submissions')
@Controller('submissions')
export class SubmissionController {
  @Post()
  @ApiOperation({ summary: 'Create new submission' })
  @ApiResponse({ status: 201, description: 'Submission created', type: SubmissionDto })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async create(@Body() dto: CreateSubmissionDto) {
    // ...
  }
}
```

### 3. Architecture Docs

Держать актуальными:
- `/docs/DB_Info/DATA_ARCHITECTURE.md` - схема БД
- `/docs/supertokens_setup.md` - auth setup
- `/docs/PROJECT_RULES_UNIFIED.md` - это файл
- `/README.md` - общий overview

---

## 🚫 What NOT to Do

### ❌ Anti-Patterns to Avoid

1. **NO public user registration**
   ```typescript
   // ❌ WRONG
   @Post('signup')
   async signup(@Body() dto: SignupDto) { }
   
   // ✅ CORRECT - только admin может создать пользователя
   @Post('users')
   @Roles('ADMIN')
   async createUser(@Body() dto: CreateUserDto) { }
   ```

2. **NO bypass of tenant isolation**
   ```typescript
   // ❌ WRONG - прямой доступ к другому tenant
   const policy = await prisma.policy.findUnique({
     where: { id: policyId }
   });
   
   // ✅ CORRECT - всегда проверяем tenant_id
   const policy = await prisma.policy.findUnique({
     where: {
       id: policyId,
       tenantId: request.user.tenantId
     }
   });
   ```

3. **NO heavy business logic in SQL**
   ```sql
   -- ❌ WRONG
   CREATE FUNCTION calculate_premium(...)
   RETURNS DECIMAL AS $$
   BEGIN
     -- complex premium calculation
   END;
   $$ LANGUAGE plpgsql;
   ```

4. **NO direct table access across modules**
   ```typescript
   // ❌ WRONG
   const customer = await prisma.customer.findUnique({ ... });
   
   // ✅ CORRECT
   const customer = await this.customerService.findById(customerId);
   ```

5. **NO magic numbers/strings**
   ```typescript
   // ❌ WRONG
   if (submission.stage === 'APPROVED') { }
   
   // ✅ CORRECT
   if (submission.stage === SubmissionStage.APPROVED) { }
   ```

---

## 🎯 Summary

### ✅ DO
- Use SuperTokens for auth
- Implement multi-tenancy with shared schema + tenant_id
- Isolate tenants at application + ORM layers
- Use temporal data for critical entities
- Soft delete instead of hard delete
- Calculate business logic in TypeScript (not SQL)
- Version your calculation algorithms
- Use materialized views for heavy reports
- Write tests (unit + integration + e2e)
- Document your code

### ❌ DON'T
- Use external auth SaaS (Clerk, Auth0, etc.)
- Bypass tenant isolation guards
- Duplicate data across domains
- Write business logic in SQL procedures
- Allow public user registration
- Access other module's tables directly
- Use magic numbers/strings
- Skip migrations

---

**Последнее обновление:** 2026-02-11  
**Следующий review:** При добавлении новых модулей или изменении core architecture

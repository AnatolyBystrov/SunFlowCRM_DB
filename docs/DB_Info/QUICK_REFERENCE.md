# Sun UW Platform - Quick Reference

**Быстрая шпаргалка для разработки**

---

## 🎯 Project Info

| Parameter | Value |
|-----------|-------|
| **Project** | Sun UW Platform |
| **Domain** | Insurance Underwriting (P&C) |
| **Auth** | SuperTokens (self-hosted) |
| **Database** | PostgreSQL 16 + Prisma |
| **Multi-tenancy** | Shared schema + tenant_id |
| **Backend** | NestJS + TypeScript |
| **Frontend** | Next.js 14 + shadcn/ui |

---

## 🔑 Key Commands

### Development

```bash
# Start all services (Postgres, SuperTokens, Redis, MinIO)
docker-compose up -d

# Backend (NestJS)
cd api
npm run start:dev

# Frontend (Next.js)
npm run dev

# Prisma
npx prisma studio                    # Open DB GUI
npx prisma migrate dev --name xxx    # Create migration
npx prisma migrate deploy            # Apply migrations (prod)
npx prisma generate                  # Regenerate client

# Tests
npm run test              # Unit tests
npm run test:e2e         # E2E tests
npm run test:cov         # Coverage
```

### Docker

```bash
# Health check
docker-compose ps
curl http://localhost:3567/hello  # SuperTokens

# Logs
docker-compose logs -f supertokens
docker-compose logs -f postgres

# Reset
docker-compose down -v  # Delete volumes
docker-compose up -d
```

---

## 🔐 Auth Flow

```
User → Next.js → SuperTokens SDK → SuperTokens Core → SuperTokens DB
                                ↓
                         Create/update User in domain DB
                         (User.supertokensUserId)
```

**Key files:**
- `src/lib/supertokens/backend.ts` - Backend config
- `src/lib/supertokens/frontend-config.ts` - Frontend config
- `src/app/api/auth/[[...path]]/route.ts` - API handler
- `docs/supertokens_setup.md` - Full setup guide

---

## 📊 Database Schema

**Core tables:**
- `tenants` - Organizations/clients
- `users` - Domain users (linked to SuperTokens)
- `roles`, `permissions` - RBAC
- `audit_logs` - Audit trail

**Domains:**
- **Sales:** `deals`, `persons`, `organizations`, `pipelines`, `stages`
- **Underwriting:** `submissions`, `policies`, `risk_assessments`
- **Claims:** `claims`, `claim_reserves`
- **Financial:** `invoices`, `payments`, `scheduled_payments`, `credit_notes`
- **Documents:** `documents`, `document_versions`
- **Compliance:** `compliance_checks`

**Full schema:** `/docs/DB_Info/DATA_ARCHITECTURE.md`

---

## 🏗️ Module Structure

### NestJS Module

```
modules/underwriting/
├── dto/
│   ├── create-submission.dto.ts
│   └── update-submission.dto.ts
├── underwriting.controller.ts
├── underwriting.service.ts
├── underwriting.module.ts
└── underwriting.service.spec.ts
```

### React Feature

```
features/submissions/
├── components/
│   ├── SubmissionList.tsx
│   └── SubmissionForm.tsx
├── hooks/
│   └── useSubmissions.ts
├── api/
│   └── submissions-api.ts
└── types.ts
```

---

## 🔒 Guards & Decorators

### Tenant Isolation (ОБЯЗАТЕЛЬНО)

```typescript
// NestJS Guard
@Injectable()
export class TenantGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;
    request.tenantId = user.tenantId;
    return true;
  }
}

// Usage
@UseGuards(TenantGuard)
@Get('submissions')
async getSubmissions(@Request() req) {
  const tenantId = req.tenantId; // Injected by guard
  // ...
}
```

### Role-Based Access

```typescript
// Custom decorator
export const Roles = (...roles: UserRole[]) => SetMetadata('roles', roles);

// Guard
@Injectable()
export class RolesGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.get<UserRole[]>('roles', context.getHandler());
    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.some(role => user.role === role);
  }
}

// Usage
@Roles('ADMIN', 'UNDERWRITER')
@Get('submissions/:id')
async getSubmission(@Param('id') id: string) {
  // ...
}
```

---

## 💾 Common Patterns

### 1. Create with Audit

```typescript
async createSubmission(dto: CreateSubmissionDto, userId: string) {
  const submission = await this.prisma.submission.create({
    data: {
      ...dto,
      createdBy: userId
    }
  });
  
  // Audit log
  await this.auditService.log({
    entityType: 'Submission',
    entityId: submission.id,
    action: 'CREATED',
    userId,
    afterData: submission
  });
  
  // Emit event
  this.eventEmitter.emit('submission.created', submission);
  
  return submission;
}
```

### 2. Update with Versioning

```typescript
async updatePolicy(id: string, dto: UpdatePolicyDto) {
  const current = await this.prisma.policy.findUnique({ where: { id } });
  
  // Create new version
  const newVersion = await this.prisma.policy.create({
    data: {
      ...current,
      ...dto,
      id: cuid(), // new ID
      validFrom: new Date(),
      validTo: null,
      isCurrentVersion: true,
      supersededById: null
    }
  });
  
  // Mark old version as superseded
  await this.prisma.policy.update({
    where: { id },
    data: {
      validTo: new Date(),
      isCurrentVersion: false,
      supersededById: newVersion.id
    }
  });
  
  return newVersion;
}
```

### 3. Soft Delete

```typescript
async deleteSubmission(id: string, userId: string) {
  const submission = await this.prisma.submission.update({
    where: { id },
    data: {
      deleted: true,
      deletedAt: new Date(),
      deletedBy: userId
    }
  });
  
  await this.auditService.log({
    entityType: 'Submission',
    entityId: id,
    action: 'DELETED',
    userId
  });
  
  return submission;
}
```

### 4. Cross-Module Call

```typescript
// ❌ WRONG
const customer = await this.prisma.customer.findUnique({ where: { id } });

// ✅ CORRECT
const customer = await this.customerService.findById(id);
```

### 5. Domain Event

```typescript
// Emit
this.eventEmitter.emit('policy.created', {
  policyId: policy.id,
  tenantId: policy.tenantId
});

// Listen
@OnEvent('policy.created')
async handlePolicyCreated(payload: PolicyCreatedEvent) {
  await this.createPremiumInvoice(payload);
}
```

---

## 🧪 Testing Patterns

### Unit Test (Service)

```typescript
describe('SubmissionService', () => {
  let service: SubmissionService;
  let prisma: PrismaService;
  
  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        SubmissionService,
        {
          provide: PrismaService,
          useValue: {
            submission: {
              create: jest.fn(),
              findUnique: jest.fn(),
            }
          }
        }
      ]
    }).compile();
    
    service = module.get<SubmissionService>(SubmissionService);
    prisma = module.get<PrismaService>(PrismaService);
  });
  
  it('should create submission', async () => {
    const dto = { /* ... */ };
    const expected = { id: 'xxx', ...dto };
    
    jest.spyOn(prisma.submission, 'create').mockResolvedValue(expected);
    
    const result = await service.create(dto);
    
    expect(result).toEqual(expected);
    expect(prisma.submission.create).toHaveBeenCalledWith({ data: dto });
  });
});
```

### E2E Test

```typescript
describe('Submissions (e2e)', () => {
  let app: INestApplication;
  let prisma: PrismaService;
  
  beforeAll(async () => {
    const moduleFixture = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    
    app = moduleFixture.createNestApplication();
    await app.init();
    
    prisma = app.get<PrismaService>(PrismaService);
  });
  
  afterAll(async () => {
    await prisma.$disconnect();
    await app.close();
  });
  
  it('/submissions (POST)', async () => {
    const dto = { /* ... */ };
    
    return request(app.getHttpServer())
      .post('/submissions')
      .send(dto)
      .expect(201)
      .expect((res) => {
        expect(res.body.id).toBeDefined();
        expect(res.body.company).toEqual(dto.company);
      });
  });
});
```

---

## 📝 Code Snippets

### TypeScript DTO

```typescript
import { IsString, IsNumber, IsEnum, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateSubmissionDto {
  @ApiProperty({ description: 'Company name' })
  @IsString()
  company: string;
  
  @ApiProperty({ description: 'Submission amount', example: 1000000 })
  @IsNumber()
  amount: number;
  
  @ApiProperty({ enum: SubmissionType })
  @IsEnum(SubmissionType)
  type: SubmissionType;
  
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  regionCode?: string;
}
```

### React Query Hook

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

export function useSubmissions() {
  return useQuery({
    queryKey: ['submissions'],
    queryFn: async () => {
      const res = await fetch('/api/submissions');
      return res.json();
    }
  });
}

export function useCreateSubmission() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (data: CreateSubmissionDto) => {
      const res = await fetch('/api/submissions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      });
      return res.json();
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['submissions'] });
    }
  });
}
```

### Prisma Query with Tenant Filter

```typescript
// Automatic tenant filter via middleware
const submissions = await this.prisma.submission.findMany({
  where: {
    stage: SubmissionStage.APPROVED,
    // tenantId автоматически добавляется middleware
  },
  include: {
    underwriter: true,
    lineOfBusiness: true
  }
});

// Manual tenant filter (если middleware disabled)
const submissions = await this.prisma.submission.findMany({
  where: {
    tenantId: request.tenantId,
    stage: SubmissionStage.APPROVED
  }
});
```

---

## ⚠️ Common Pitfalls

### 1. Забыли tenant_id фильтр
```typescript
// ❌ WRONG - может вернуть данные другого tenant
const policy = await prisma.policy.findUnique({ where: { id } });

// ✅ CORRECT
const policy = await prisma.policy.findUnique({
  where: { id, tenantId }
});
```

### 2. Не логировали audit
```typescript
// ❌ WRONG
await prisma.payment.create({ data });

// ✅ CORRECT
const payment = await prisma.payment.create({ data });
await auditService.log({
  action: 'CREATED',
  entityType: 'Payment',
  entityId: payment.id,
  userId
});
```

### 3. Прямой доступ к таблицам другого модуля
```typescript
// ❌ WRONG
const customer = await prisma.customer.findUnique({ ... });

// ✅ CORRECT
const customer = await this.customerService.findById(customerId);
```

### 4. Hard delete вместо soft
```typescript
// ❌ WRONG
await prisma.deal.delete({ where: { id } });

// ✅ CORRECT
await prisma.deal.update({
  where: { id },
  data: { deleted: true, deletedAt: new Date(), deletedBy: userId }
});
```

### 5. Бизнес-логика в SQL
```sql
-- ❌ WRONG
CREATE FUNCTION calculate_premium(...) RETURNS DECIMAL ...

-- ✅ CORRECT - в TypeScript
class PremiumService {
  calculate(policy: Policy): number {
    // ...
  }
}
```

---

## 🔗 Useful Links

- **Full Architecture:** `/docs/DB_Info/DATA_ARCHITECTURE.md`
- **Project Rules:** `/docs/PROJECT_RULES_UNIFIED.md`
- **Auth Setup:** `/docs/supertokens_setup.md`
- **Prisma Schema:** `/prisma/schema.prisma`
- **SuperTokens Docs:** https://supertokens.com/docs
- **NestJS Docs:** https://docs.nestjs.com
- **Prisma Docs:** https://www.prisma.io/docs

---

## 🚀 Workflow Cheatsheet

### New Feature

1. Create branch: `feature/MODULE-XXX-description`
2. Update Prisma schema (if needed)
3. Create migration: `npx prisma migrate dev --name xxx`
4. Implement NestJS service/controller
5. Write tests
6. Update docs (if needed)
7. Create PR
8. Code review
9. Merge to develop

### Bug Fix

1. Create branch: `fix/MODULE-XXX-description`
2. Write failing test
3. Fix the bug
4. Test passes
5. Create PR
6. Merge

### Database Change

1. Edit `prisma/schema.prisma`
2. Run `npx prisma migrate dev --name xxx`
3. Review generated SQL
4. Test locally
5. Commit migration
6. On prod: `npx prisma migrate deploy`

---

**Last updated:** 2026-02-11

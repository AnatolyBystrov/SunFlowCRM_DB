// ============================================
// PRISMA MIDDLEWARE - ROW-LEVEL SECURITY (RLS)
// ============================================
// Файл: src/common/prisma/prisma-rls.middleware.ts

import { Prisma } from '@prisma/client';
import { Logger } from '@nestjs/common';

const logger = new Logger('PrismaRLS');

/**
 * Модели, которые требуют tenant isolation
 */
const TENANT_MODELS = [
    'Deal',
    'Person',
    'Organization',
    'InsuranceProduct',
    'Pipeline',
    'Stage',
    'Submission',
    'Policy',
    'Claim',
    'Invoice',
    'InvoiceItem',
    'Payment',
    'ScheduledPayment',
    'CreditNote',
    'PaymentMethod',
    'ExchangeRate',
    'ComplianceCheck',
    'Document',
    'Workflow',
    'WorkflowExecution',
    'Activity',
    'Note',
    'File',
    'CustomFieldDefinition',
    'Team',
    'Ticket',
    'TicketType',
    'TicketComment',
    'Label',
    'Announcement',
    'LineOfBusiness',
    'LeaveType',
    'Attendance',
    'LeaveApplication',
    'PaymentAuditLog',
    'InvoiceAuditLog',
    'CreditNoteAuditLog',
];

/**
 * Глобальные модели (без tenant isolation)
 */
const GLOBAL_MODELS = [
    'Tenant',
    'User',
    'Currency',
    'Region',
    'Country',
    'ClassOfBusiness',
    'DocumentVersion',
    'Comment',
    'TeamMember',
];

/**
 * Интерфейс для контекста запроса
 */
export interface RequestContext {
    tenantId: string;
    userId: string;
}

/**
 * Создает middleware для RLS
 */
export function createRLSMiddleware(getContext: () => RequestContext | null) {
    return async (params: Prisma.MiddlewareParams, next: (params: Prisma.MiddlewareParams) => Promise<any>) => {
        const context = getContext();

        // Если нет контекста (например, seed скрипты), пропускаем
        if (!context) {
            logger.warn(`No context found for ${params.model}.${params.action}`);
            return next(params);
        }

        const { tenantId } = context;

        // Проверяем, нужна ли tenant isolation для этой модели
        if (!params.model || !TENANT_MODELS.includes(params.model)) {
            return next(params);
        }

        // Логируем для отладки
        logger.debug(`RLS: ${params.model}.${params.action} for tenant ${tenantId}`);

        // Обрабатываем разные типы операций
        switch (params.action) {
            case 'findUnique':
            case 'findUniqueOrThrow':
            case 'findFirst':
            case 'findFirstOrThrow':
                params.args.where = {
                    ...params.args.where,
                    tenantId,
                };
                break;

            case 'findMany':
                params.args.where = {
                    ...params.args.where,
                    tenantId,
                };
                break;

            case 'create':
                params.args.data = {
                    ...params.args.data,
                    tenantId,
                };
                break;

            case 'createMany':
                if (Array.isArray(params.args.data)) {
                    params.args.data = params.args.data.map((item: any) => ({
                        ...item,
                        tenantId,
                    }));
                } else {
                    params.args.data = {
                        ...params.args.data,
                        tenantId,
                    };
                }
                break;

            case 'update':
            case 'updateMany':
                params.args.where = {
                    ...params.args.where,
                    tenantId,
                };
                // Предотвращаем изменение tenantId
                if (params.args.data?.tenantId && params.args.data.tenantId !== tenantId) {
                    throw new Error('Cannot change tenantId');
                }
                break;

            case 'upsert':
                params.args.where = {
                    ...params.args.where,
                    tenantId,
                };
                params.args.create = {
                    ...params.args.create,
                    tenantId,
                };
                // Предотвращаем изменение tenantId в update
                if (params.args.update?.tenantId && params.args.update.tenantId !== tenantId) {
                    throw new Error('Cannot change tenantId');
                }
                break;

            case 'delete':
            case 'deleteMany':
                params.args.where = {
                    ...params.args.where,
                    tenantId,
                };
                break;

            case 'count':
            case 'aggregate':
            case 'groupBy':
                params.args.where = {
                    ...params.args.where,
                    tenantId,
                };
                break;

            default:
                logger.warn(`Unhandled action: ${params.action} for model ${params.model}`);
        }

        return next(params);
    };
}

/**
 * Пример использования в PrismaService
 */
export class PrismaServiceExample {
    private requestContext: RequestContext | null = null;

    constructor() {
        // Регистрируем middleware
        // this.$use(createRLSMiddleware(() => this.requestContext));
    }

    /**
     * Устанавливает контекст для текущего запроса
     */
    setRequestContext(context: RequestContext) {
        this.requestContext = context;
    }

    /**
     * Очищает контекст
     */
    clearRequestContext() {
        this.requestContext = null;
    }
}

// ============================================
// INTEGRATION WITH NESTJS
// ============================================

/**
 * Пример интеграции с NestJS Guard
 * Файл: src/common/guards/tenant.guard.ts
 */
/*
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class TenantGuard implements CanActivate {
  constructor(private prisma: PrismaService) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user; // Из Clerk JWT

    if (!user?.tenantId) {
      throw new Error('No tenant ID in user context');
    }

    // Устанавливаем контекст для Prisma
    this.prisma.setRequestContext({
      tenantId: user.tenantId,
      userId: user.id,
    });

    return true;
  }
}
*/

/**
 * Пример использования в контроллере
 */
/*
@Controller('deals')
@UseGuards(TenantGuard)
export class DealsController {
  constructor(private prisma: PrismaService) {}

  @Get()
  async findAll() {
    // tenantId автоматически добавится в where
    return this.prisma.deal.findMany();
  }

  @Post()
  async create(@Body() data: CreateDealDto) {
    // tenantId автоматически добавится в data
    return this.prisma.deal.create({ data });
  }
}
*/

/**
 * Пример для seed скриптов (без RLS)
 */
/*
async function seed() {
  const prisma = new PrismaClient();
  
  // Для seed скриптов можно отключить RLS
  // или явно указывать tenantId
  
  await prisma.tenant.create({
    data: {
      id: 'tenant-1',
      clerkOrgId: 'org_xxx',
      name: 'Demo Tenant',
      slug: 'demo',
    },
  });
  
  await prisma.deal.create({
    data: {
      tenantId: 'tenant-1', // Явно указываем
      title: 'Test Deal',
      value: 10000,
      // ...
    },
  });
}
*/

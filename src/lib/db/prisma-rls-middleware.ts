import type { Prisma } from '@prisma/client';
import { getRequestContext } from '@/lib/db/rls-context';

const TENANT_MODELS = new Set(['User']);

function ensureArgs(params: Prisma.MiddlewareParams) {
    if (!params.args) {
        params.args = {};
    }
    if (!params.args.where) {
        params.args.where = {};
    }
    return params.args;
}

export function createRlsMiddleware() {
    return async (
        params: Prisma.MiddlewareParams,
        next: (params: Prisma.MiddlewareParams) => Promise<unknown>
    ) => {
        const context = getRequestContext();

        if (!context || context.bypassRls) {
            return next(params);
        }

        if (!params.model || !TENANT_MODELS.has(params.model)) {
            return next(params);
        }

        const { tenantId } = context;

        switch (params.action) {
            case 'findMany':
            case 'findFirst':
            case 'findFirstOrThrow':
            case 'count':
            case 'aggregate':
            case 'groupBy': {
                const args = ensureArgs(params);
                args.where = {
                    ...args.where,
                    tenantId
                };
                break;
            }
            case 'findUnique':
            case 'findUniqueOrThrow': {
                params.action =
                    params.action === 'findUnique'
                        ? 'findFirst'
                        : 'findFirstOrThrow';
                const args = ensureArgs(params);
                args.where = {
                    ...args.where,
                    tenantId
                };
                break;
            }
            case 'create': {
                params.args = params.args ?? {};
                params.args.data = {
                    ...params.args.data,
                    tenantId
                };
                break;
            }
            case 'createMany': {
                params.args = params.args ?? {};
                if (Array.isArray(params.args.data)) {
                    params.args.data = params.args.data.map((item: unknown) =>
                        typeof item === 'object' && item !== null
                            ? { ...item, tenantId }
                            : item
                    );
                } else if (params.args.data) {
                    params.args.data = {
                        ...params.args.data,
                        tenantId
                    };
                }
                break;
            }
            default:
                break;
        }

        return next(params);
    };
}
import { Prisma } from '@prisma/client';

export interface RequestContext {
    tenantId: string;
    userId: string;
}

/**
 * Prisma middleware for Row-Level Security (RLS)
 * Automatically filters queries by tenantId to prevent cross-tenant data leakage
 * 
 * @param getContext - Function to retrieve current request context
 */
export function createRLSMiddleware(
    getContext: () => RequestContext | null
): Prisma.Middleware {
    return async (params, next) => {
        const context = getContext();

        // Skip RLS for models without tenantId
        const modelsWithTenant = [
            'User',
            'TradingAccount',
            'Transaction',
            'ComplianceCheck',
            'AuditLog',
            'Document'
        ];

        if (!context || !modelsWithTenant.includes(params.model || '')) {
            // No context or model doesn't have tenantId - proceed without filtering
            return next(params);
        }

        const { tenantId } = context;

        // Apply tenant isolation to all queries
        if (params.action === 'findUnique' || params.action === 'findFirst') {
            params.args.where = {
                ...params.args.where,
                tenantId
            };
        } else if (params.action === 'findMany') {
            if (!params.args.where) {
                params.args = { ...params.args, where: {} };
            }
            params.args.where = {
                ...params.args.where,
                tenantId
            };
        } else if (params.action === 'create') {
            // Inject tenantId on create
            params.args.data = {
                ...params.args.data,
                tenantId
            };
        } else if (params.action === 'update' || params.action === 'delete') {
            // Ensure operations only affect own tenant
            params.args.where = {
                ...params.args.where,
                tenantId
            };
        } else if (params.action === 'updateMany' || params.action === 'deleteMany') {
            if (!params.args.where) {
                params.args = { ...params.args, where: {} };
            }
            params.args.where = {
                ...params.args.where,
                tenantId
            };
        }

        return next(params);
    };
}

/**
 * Example Prisma service with RLS middleware
 * Use this pattern in your application
 */
export class PrismaServiceWithRLS {
    private requestContext: RequestContext | null = null;

    constructor(private prismaClient: any) {
        // Register RLS middleware
        this.prismaClient.$use(
            createRLSMiddleware(() => this.requestContext)
        );
    }

    /**
     * Set the current request context
     * Call this at the start of each API route
     */
    setContext(context: RequestContext) {
        this.requestContext = context;
    }

    /**
     * Clear the request context
     * Call this after the request completes
     */
    clearContext() {
        this.requestContext = null;
    }

    /**
     * Get the underlying Prisma client
     */
    getClient() {
        return this.prismaClient;
    }
}

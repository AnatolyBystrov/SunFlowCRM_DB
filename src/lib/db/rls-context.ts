import { AsyncLocalStorage } from 'async_hooks';

export interface RequestContext {
    tenantId: string;
    userId: string;
    bypassRls?: boolean;
}

const asyncLocalStorage = new AsyncLocalStorage<RequestContext>();

/**
 * Get the current request context
 */
export function getRequestContext(): RequestContext | undefined {
    return asyncLocalStorage.getStore();
}

/**
 * Enter a new request context
 * Call this when starting a new request with tenant/user info
 */
export function enterRequestContext(context: RequestContext): void {
    asyncLocalStorage.enterWith(context);
}

/**
 * Execute a function with RLS bypass enabled
 * Useful for operations that need to query across tenants
 */
export async function withRlsBypass<T>(fn: () => Promise<T>): Promise<T> {
    const currentContext = getRequestContext();

    // If no context, just run the function
    if (!currentContext) {
        return fn();
    }

    // Create new context with bypass flag
    const bypassContext: RequestContext = {
        ...currentContext,
        bypassRls: true,
    };

    return asyncLocalStorage.run(bypassContext, fn);
}

/**
 * Execute a function within a specific tenant context
 */
export async function withTenantContext<T>(
    context: RequestContext,
    fn: () => Promise<T>
): Promise<T> {
    return asyncLocalStorage.run(context, fn);
}

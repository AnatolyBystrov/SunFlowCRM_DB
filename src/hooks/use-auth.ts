'use client';

import { useSessionContext } from 'supertokens-auth-react/recipe/session';

/**
 * Custom hook for accessing user authentication data.
 * Provides tenantId, roles, and role-checking utilities.
 * 
 * @example
 * const { tenantId, roles, hasRole, isAdmin } = useAuth();
 * if (isAdmin()) { ... }
 * if (hasRole('UNDERWRITER')) { ... }
 */
export function useAuth() {
    const session = useSessionContext();

    // Loading state
    if (session.loading) {
        return {
            loading: true,
            authenticated: false,
            tenantId: undefined,
            roles: [] as string[],
            email: undefined,
            userId: undefined,
            hasRole: () => false,
            isAdmin: () => false,
            isManager: () => false,
        } as const;
    }

    // Not authenticated
    if (!session.doesSessionExist) {
        return {
            loading: false,
            authenticated: false,
            tenantId: undefined,
            roles: [] as string[],
            email: undefined,
            userId: undefined,
            hasRole: () => false,
            isAdmin: () => false,
            isManager: () => false,
        } as const;
    }

    // Authenticated - extract data from payload
    const tenantId = session.accessTokenPayload?.tenantId as string | undefined;
    const roles = (session.accessTokenPayload?.roles ?? []) as string[];
    const email = session.accessTokenPayload?.email as string | undefined;
    const userId = session.userId;

    // Role checking utilities
    const hasRole = (role: string) => roles.includes(role);
    const isAdmin = () => hasRole('ADMIN');
    const isManager = () => hasRole('MANAGER') || isAdmin();

    return {
        loading: false,
        authenticated: true,
        tenantId,
        roles,
        email,
        userId,
        hasRole,
        isAdmin,
        isManager,
    } as const;
}

export type AuthState = ReturnType<typeof useAuth>;

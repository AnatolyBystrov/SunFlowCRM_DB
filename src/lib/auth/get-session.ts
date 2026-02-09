import { getSession } from 'supertokens-node/recipe/session';
import { NextRequest, NextResponse } from 'next/server';
import { ensureSuperTokensInit } from '@/lib/supertokens/config';
import { enterRequestContext } from '@/lib/db/rls-context';

// Ensure SuperTokens is initialized
ensureSuperTokensInit();

/**
 * Session payload extracted from SuperTokens access token.
 * Contains user info including tenantId and roles for RBAC.
 */
export interface SessionPayload {
    userId: string;
    tenantId: string;
    roles: string[];
    email?: string;
}

/**
 * Get session payload from request.
 * Returns null if no valid session exists.
 * 
 * @example
 * const session = await getSessionPayload(request);
 * if (session) {
 *   const { tenantId, roles } = session;
 *   // Use tenantId for data isolation
 * }
 */
export async function getSessionPayload(request: NextRequest): Promise<SessionPayload | null> {
    try {
        // Note: Using 'as any' because Next.js types don't perfectly match
        const session = await getSession(request as any, undefined as any);
        if (!session) return null;

        const payload = session.getAccessTokenPayload();

        // Critical: Enforce tenantId presence
        // Empty tenantId would allow cross-tenant data leakage
        if (!payload.tenantId) {
            console.error('[Auth] Session missing tenantId:', {
                userId: session.getUserId(),
                email: payload.email
            });
            throw new Error('Invalid session: missing tenant context');
        }

        const sessionPayload: SessionPayload = {
            userId: session.getUserId(),
            tenantId: payload.tenantId,
            roles: Array.isArray(payload.roles) ? payload.roles : [],
            email: payload.email,
        };

        enterRequestContext({
            tenantId: payload.tenantId,
            userId: session.getUserId(),
        });

        return sessionPayload;
    } catch (error) {
        // Session doesn't exist or is invalid
        return null;
    }
}

/**
 * Require a valid session. Throws if no session exists.
 * Use in API routes that require authentication.
 * 
 * @example
 * export async function GET(request: NextRequest) {
 *   try {
 *     const session = await requireSession(request);
 *     // ... handle authenticated request
 *   } catch (error) {
 *     return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
 *   }
 * }
 */
export async function requireSession(request: NextRequest): Promise<SessionPayload> {
    const session = await getSessionPayload(request);
    if (!session) {
        throw new Error('Unauthorized: No valid session');
    }
    return session;
}

/**
 * Require a specific role. Throws if user doesn't have the role.
 * Use in API routes that require specific permissions.
 * 
 * @example
 * export async function DELETE(request: NextRequest) {
 *   try {
 *     const session = await requireRole(request, 'ADMIN');
 *     // ... handle admin-only request
 *   } catch (error) {
 *     return NextResponse.json({ error: error.message }, { status: 403 });
 *   }
 * }
 */
export async function requireRole(request: NextRequest, role: string): Promise<SessionPayload> {
    const session = await requireSession(request);
    if (!session.roles.includes(role)) {
        throw new Error(`Forbidden: Requires ${role} role`);
    }
    return session;
}

/**
 * Require any of the specified roles.
 */
export async function requireAnyRole(request: NextRequest, roles: string[]): Promise<SessionPayload> {
    const session = await requireSession(request);
    const hasAnyRole = roles.some(role => session.roles.includes(role));
    if (!hasAnyRole) {
        throw new Error(`Forbidden: Requires one of ${roles.join(', ')} roles`);
    }
    return session;
}

/**
 * Create an unauthorized response.
 */
export function unauthorizedResponse(message = 'Unauthorized') {
    return NextResponse.json({ error: message }, { status: 401 });
}

/**
 * Create a forbidden response.
 */
export function forbiddenResponse(message = 'Forbidden') {
    return NextResponse.json({ error: message }, { status: 403 });
}

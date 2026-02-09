import { NextRequest, NextResponse } from 'next/server';
import { ensureSuperTokensInit } from './config';
import Session from 'supertokens-node/recipe/session';
import { SessionContainer } from 'supertokens-node/recipe/session';

ensureSuperTokensInit();

/**
 * Verify session from request
 * @param request Next.js request object
 * @returns Session container or null if no valid session
 */
export async function getSession(request: NextRequest): Promise<SessionContainer | null> {
    try {
        const session = await Session.getSession(request, NextResponse.next(), {
            sessionRequired: false
        });
        return session || null;
    } catch (error) {
        console.error('Error getting session:', error);
        return null;
    }
}

/**
 * Verify session and require authentication
 * @param request Next.js request object
 * @throws Error if no valid session
 */
export async function requireAuth(
    request: NextRequest
): Promise<SessionContainer> {
    const session = await Session.getSession(request, NextResponse.next(), {
        sessionRequired: true
    });

    if (!session) {
        throw new Error('Unauthorized');
    }

    return session;
}

/**
 * Get user ID from session
 */
export async function getUserId(request: NextRequest): Promise<string | null> {
    const session = await getSession(request);
    return session?.getUserId() || null;
}

/**
 * Sign out user
 */
export async function signOut(session: SessionContainer): Promise<void> {
    await session.revokeSession();
}

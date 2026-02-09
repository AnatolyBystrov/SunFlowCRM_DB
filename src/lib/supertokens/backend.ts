import { NextRequest, NextResponse } from 'next/server';
import { ensureSuperTokensInit } from './config';
import { getSession as getAppDirSession } from 'supertokens-node/nextjs';
import { SessionContainer } from 'supertokens-node/recipe/session';

ensureSuperTokensInit();

/**
 * Verify session from request or current context (Server Component)
 * @param request Optional Next.js request object (required for Middleware/API)
 * @returns Session container or null if no valid session
 */
export async function getSession(request?: NextRequest): Promise<SessionContainer | null> {
    try {
        // use getAppDirSession which handles both Server Components and API/Middleware
        return await getAppDirSession(request);
    } catch (error) {
        console.error('Error getting session:', error);
        return null;
    }
}

/**
 * Verify session and require authentication
 * @param request Optional Next.js request object
 * @throws Error if no valid session
 */
export async function requireAuth(
    request?: NextRequest
): Promise<SessionContainer> {
    const session = await getSession(request);

    if (!session) {
        throw new Error('Unauthorized');
    }

    return session;
}

/**
 * Get user ID from session
 */
export async function getUserId(request?: NextRequest): Promise<string | null> {
    const session = await getSession(request);
    return session?.getUserId() || null;
}

/**
 * Sign out user
 */
export async function signOut(session: SessionContainer): Promise<void> {
    await session.revokeSession();
}

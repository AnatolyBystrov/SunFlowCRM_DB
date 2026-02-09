import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

/**
 * Middleware for SuperTokens
 * 
 * Note: SuperTokens handles authentication through its API routes.
 * For route protection, we use the SessionAuth component on the client side
 * and getSession/requireAuth utilities on the server side.
 * 
 * This middleware is kept minimal - add custom logic as needed.
 */
export function middleware(request: NextRequest) {
    // SuperTokens handles auth through API routes
    // No middleware needed for basic auth flow
    return NextResponse.next();
}

export const config = {
    matcher: [
        // Skip Next.js internals and all static files
        '/((?!_next|[^?]*\\.(?:html?|css|js(?!on)|jpe?g|webp|png|gif|svg|ttf|woff2?|ico|csv|docx?|xlsx?|zip|webmanifest)).*)',
        // Always run for API routes
        '/(api|trpc)(.*)'
    ]
};

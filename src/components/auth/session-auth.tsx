'use client';

import React from 'react';
import { SessionAuth as SuperTokensSessionAuth } from 'supertokens-auth-react/recipe/session';
import { useRouter } from 'next/navigation';

/**
 * Session authentication wrapper
 * Protects routes by requiring a valid SuperTokens session
 * Redirects to /auth/sign-in if no session exists
 */
export function SessionAuth({ children }: { children: React.ReactNode }) {
    const router = useRouter();

    return (
        <SuperTokensSessionAuth
            requireAuth={true}
            onSessionExpired={() => {
                router.push('/auth/sign-in');
            }}
        >
            {children}
        </SuperTokensSessionAuth>
    );
}

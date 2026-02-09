'use client';

import React, { useEffect, useState } from 'react';
import SuperTokensReact from 'supertokens-auth-react';
import { SessionAuth } from 'supertokens-auth-react/recipe/session';
import { frontendConfig } from '@/lib/supertokens/frontend-config';

/**
 * SuperTokens provider wrapper for Next.js App Router
 * Initializes SuperTokens on the client side and provides SessionAuth context
 */
export function SuperTokensProvider({ children }: { children: React.ReactNode }) {
    const [initialized, setInitialized] = useState(false);

    useEffect(() => {
        if (typeof window !== 'undefined' && !initialized) {
            SuperTokensReact.init(frontendConfig());
            setInitialized(true);
        }
    }, [initialized]);

    if (!initialized) {
        return null;
    }

    // SessionAuth wrapper enables useSessionContext hook in child components
    // requireAuth=false allows unauthenticated pages to render
    return (
        <SessionAuth requireAuth={false}>
            {children}
        </SessionAuth>
    );
}

'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

/**
 * Organization settings index - redirects to Users
 */
export default function OrganizationPage() {
    const router = useRouter();

    useEffect(() => {
        router.replace('/settings/organization/users');
    }, [router]);

    return null;
}

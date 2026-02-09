'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

/**
 * Settings index page - redirects to Profile
 */
export default function SettingsPage() {
    const router = useRouter();

    useEffect(() => {
        router.replace('/settings/profile');
    }, [router]);

    return null;
}

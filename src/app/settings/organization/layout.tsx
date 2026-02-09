'use client';

import { useAuth } from '@/hooks/use-auth';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';
import { Heading } from '@/components/ui/heading';
import { Button } from '@/components/ui/button';
import PageContainer from '@/components/layout/page-container';

export default function OrganizationSettingsLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    const { isAdmin, loading, authenticated } = useAuth();
    const router = useRouter();

    useEffect(() => {
        if (!loading && authenticated && !isAdmin()) {
            router.push('/settings/profile');
        }
    }, [loading, authenticated, isAdmin, router]);

    if (loading) return null;

    if (!isAdmin()) {
        return (
            <PageContainer>
                <div className="flex h-full flex-col items-center justify-center space-y-4 pt-16">
                    <Heading title="Access Denied" description="You do not have permission to view organization settings." />
                    <Button onClick={() => router.push('/settings/profile')}>Go to Profile</Button>
                </div>
            </PageContainer>
        );
    }

    return <>{children}</>;
}

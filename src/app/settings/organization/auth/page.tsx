'use client';

import PageContainer from '@/components/layout/page-container';
import { Heading } from '@/components/ui/heading';
import { Separator } from '@/components/ui/separator';
import { AuthSettingsForm } from '@/features/settings/components/auth/auth-settings-form';
import { useAuth } from '@/hooks/use-auth';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';
import { Button } from '@/components/ui/button';

export default function AuthSettingsPage() {
    const { isAdmin, loading, authenticated } = useAuth();
    const router = useRouter();

    useEffect(() => {
        if (!loading && authenticated && !isAdmin()) {
            router.push('/dashboard/overview');
        }
    }, [loading, authenticated, isAdmin, router]);

    if (loading) return null;

    if (!isAdmin()) {
        return (
            <PageContainer>
                <div className="flex h-full flex-col items-center justify-center space-y-4 pt-16">
                    <Heading title="Access Denied" description="You do not have permission to view this page." />
                    <Button onClick={() => router.push('/dashboard/overview')}>Go back</Button>
                </div>
            </PageContainer>
        );
    }

    return (
        <PageContainer>
            <div className="space-y-4 max-w-4xl">
                <div className="flex items-start justify-between">
                    <Heading
                        title="Auth & Security"
                        description="Configure authentication methods and security policies for your organization."
                    />
                </div>
                <Separator />

                <AuthSettingsForm />
            </div>
        </PageContainer>
    );
}

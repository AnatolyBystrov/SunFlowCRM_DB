'use client';

import PageContainer from '@/components/layout/page-container';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle
} from '@/components/ui/card';
import { BadgeCheck } from 'lucide-react';

export default function ExclusivePage() {
  return (
    <PageContainer>
      <div className='space-y-6'>
        <div>
          <h1 className='flex items-center gap-2 text-3xl font-bold tracking-tight'>
            <BadgeCheck className='h-7 w-7 text-green-600' />
            Exclusive Area
          </h1>
          <p className='text-muted-foreground'>
            This page demonstrates role-based access control.
          </p>
        </div>
        <Card>
          <CardHeader>
            <CardTitle>
              Welcome to the Exclusive Page
            </CardTitle>
            <CardDescription>
              Plan-based access control can be implemented using SuperTokens session claims
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p className='text-muted-foreground text-sm'>
              To implement plan-based access:
            </p>
            <ul className='text-muted-foreground mt-4 list-disc space-y-2 pl-6 text-sm'>
              <li>Store user plan in database</li>
              <li>Add plan to SuperTokens session claims</li>
              <li>Check plan in components and API routes</li>
              <li>Implement upgrade/downgrade flows</li>
            </ul>
          </CardContent>
        </Card>
      </div>
    </PageContainer>
  );
}

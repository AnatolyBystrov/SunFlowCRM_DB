'use client';

import PageContainer from '@/components/layout/page-container';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { workspacesInfoContent } from '@/config/infoconfig';
import { Button } from '@/components/ui/button';
import { Plus } from 'lucide-react';

export default function WorkspacesPage() {
  return (
    <PageContainer
      pageTitle='Workspaces'
      pageDescription='Manage your workspaces and switch between them'
      infoContent={workspacesInfoContent}
    >
      <Card>
        <CardHeader>
          <CardTitle>Organizations</CardTitle>
          <CardDescription>
            Multi-tenancy and organizations are not yet implemented with SuperTokens
          </CardDescription>
        </CardHeader>
        <CardContent className='space-y-4'>
          <p className='text-muted-foreground text-sm'>
            To implement organizations with SuperTokens:
          </p>
          <ul className='text-muted-foreground list-disc space-y-2 pl-6 text-sm'>
            <li>Create an organizations table in your database</li>
            <li>Implement organization management API endpoints</li>
            <li>Store organization ID in SuperTokens session claims</li>
            <li>Add organization switching UI</li>
          </ul>
          <Button disabled className='mt-4'>
            <Plus className='mr-2 h-4 w-4' />
            Create Organization (Coming Soon)
          </Button>
        </CardContent>
      </Card>
    </PageContainer>
  );
}

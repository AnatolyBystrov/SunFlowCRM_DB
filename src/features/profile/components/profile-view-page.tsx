'use client';

import { useSessionContext } from 'supertokens-auth-react/recipe/session';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

export default function ProfileViewPage() {
  const session = useSessionContext();

  if (session.loading) {
    return <div className='flex w-full flex-col p-4'>Loading...</div>;
  }

  const userEmail = session.accessTokenPayload?.email || 'user@example.com';
  const userName = session.accessTokenPayload?.name || userEmail.split('@')[0];

  return (
    <div className='flex w-full flex-col gap-4 p-4'>
      <Card>
        <CardHeader>
          <CardTitle>Profile</CardTitle>
          <CardDescription>Manage your account settings</CardDescription>
        </CardHeader>
        <CardContent className='space-y-4'>
          <div>
            <label className='text-sm font-medium'>Name</label>
            <p className='text-muted-foreground text-sm'>{userName}</p>
          </div>
          <div>
            <label className='text-sm font-medium'>Email</label>
            <p className='text-muted-foreground text-sm'>{userEmail}</p>
          </div>
          <div>
            <label className='text-sm font-medium'>User ID</label>
            <p className='text-muted-foreground text-sm font-mono text-xs'>
              {session.userId}
            </p>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Password</CardTitle>
          <CardDescription>Change your password</CardDescription>
        </CardHeader>
        <CardContent>
          <p className='text-muted-foreground text-sm'>
            Password management will be implemented in a future update.
          </p>
        </CardContent>
      </Card>
    </div>
  );
}

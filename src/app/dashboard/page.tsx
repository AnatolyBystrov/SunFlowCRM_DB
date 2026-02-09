import { redirect } from 'next/navigation';
import { getSession } from '@/lib/supertokens/backend';
import { NextRequest } from 'next/server';

export default async function Dashboard() {
  const session = await getSession(new NextRequest(new URL('http://localhost:3000')));

  if (!session) {
    return redirect('/auth/sign-in');
  } else {
    redirect('/dashboard/overview');
  }
}

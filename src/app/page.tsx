import { redirect } from 'next/navigation';
import { getSession } from '@/lib/supertokens/backend';

export default async function Page() {
  const session = await getSession();

  if (!session) {
    return redirect('/auth/sign-in');
  } else {
    redirect('/dashboard/overview');
  }
}

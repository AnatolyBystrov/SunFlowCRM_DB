import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Privacy Policy',
  description: 'Privacy policy for Sun MGA internal platform.'
};

export default function PrivacyPage() {
  return (
    <main className='container mx-auto max-w-3xl px-4 py-10'>
      <h1 className='text-3xl font-semibold tracking-tight'>Privacy Policy</h1>
      <p className='text-muted-foreground mt-4'>
        Sun MGA processes data for internal insurance operations under strict
        access control and audit requirements. Data usage, retention, and access
        are governed by internal policies and applicable regulations.
      </p>
    </main>
  );
}

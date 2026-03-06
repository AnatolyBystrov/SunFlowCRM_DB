import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Terms of Service',
  description: 'Terms of service for Sun MGA internal platform.'
};

export default function TermsPage() {
  return (
    <main className='container mx-auto max-w-3xl px-4 py-10'>
      <h1 className='text-3xl font-semibold tracking-tight'>Terms of Service</h1>
      <p className='text-muted-foreground mt-4'>
        This platform is for internal business use only. Access and usage are
        permitted exclusively for authorized personnel and are subject to
        company security and compliance policies.
      </p>
    </main>
  );
}

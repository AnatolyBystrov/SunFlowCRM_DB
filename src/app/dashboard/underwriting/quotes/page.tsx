'use client';

import { IconReportMoney, IconPlus } from '@tabler/icons-react';
import Link from 'next/link';

export default function QuotesPage() {
  return (
    <div className='flex-1 space-y-6 p-4 pt-6 md:p-8'>
      <div className='flex items-center justify-between'>
        <div>
          <h2 className='text-3xl font-bold tracking-tight'>Quotes</h2>
          <p className='text-muted-foreground'>
            Indication, firm and bound quotes
          </p>
        </div>
        <Link
          href='/dashboard/underwriting/new'
          className='flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700'
        >
          <IconPlus className='h-4 w-4' />
          New Quote
        </Link>
      </div>

      <div className='bg-card rounded-xl border'>
        <div className='flex flex-col items-center justify-center gap-3 py-24 text-center'>
          <div className='bg-muted rounded-xl p-4'>
            <IconReportMoney className='text-muted-foreground h-8 w-8' />
          </div>
          <p className='text-lg font-semibold'>No quotes yet</p>
          <p className='text-muted-foreground max-w-sm text-sm'>
            Quotes will appear here after you calculate your first premium.
          </p>
          <Link
            href='/dashboard/underwriting/new'
            className='mt-2 flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700'
          >
            <IconPlus className='h-4 w-4' />
            Calculate First Quote
          </Link>
        </div>
      </div>
    </div>
  );
}

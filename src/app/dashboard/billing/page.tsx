'use client';

import PageContainer from '@/components/layout/page-container';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle
} from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Info } from 'lucide-react';
import { billingInfoContent } from '@/config/infoconfig';

export default function BillingPage() {
  return (
    <PageContainer
      infoContent={billingInfoContent}
      pageTitle='Billing & Plans'
      pageDescription='Manage your subscription and usage limits'
    >
      <div className='space-y-6'>
        {/* Info Alert */}
        <Alert>
          <Info className='h-4 w-4' />
          <AlertDescription>
            Billing and subscription management will be implemented in a future update.
            Consider integrating Stripe, Paddle, or another payment provider.
          </AlertDescription>
        </Alert>

        {/* Placeholder Card */}
        <Card>
          <CardHeader>
            <CardTitle>Subscription Plans</CardTitle>
            <CardDescription>
              Choose a plan that fits your needs
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p className='text-muted-foreground text-sm'>
              Billing integration coming soon. You can integrate:
            </p>
            <ul className='text-muted-foreground mt-4 list-disc space-y-2 pl-6 text-sm'>
              <li>Stripe for payment processing</li>
              <li>Paddle for merchant of record</li>
              <li>LemonSqueezy for digital products</li>
            </ul>
          </CardContent>
        </Card>
      </div>
    </PageContainer>
  );
}

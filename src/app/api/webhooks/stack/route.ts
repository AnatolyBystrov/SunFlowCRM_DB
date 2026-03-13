import { Webhook, WebhookRequiredHeaders } from 'svix';
import { NextRequest, NextResponse } from 'next/server';
import { UserProvisioningService } from '@/lib/services/user-provisioning-service';

/**
 * POST /api/webhooks/stack
 *
 * Webhook handler for Stack Auth events.
 * Stack Auth sends POST requests with JSON payloads when users/teams change.
 *
 * Stack Auth docs reference:
 *   - user.created: { type: "user.created", data: { id, primary_email, display_name, ... } }
 *   - user.updated: { type: "user.updated", data: { ... } }
 *   - user.deleted: { type: "user.deleted", data: { id } }
 *
 * Webhook verification:
 *   Stack signs webhooks with Svix. Signature is verified using STACK_WEBHOOK_SECRET
 *   (the Svix signing secret from Stack Auth Dashboard → Webhooks).
 *
 * Setup: Configure webhook URL in Stack Auth Dashboard → Webhooks section.
 *   URL: https://testcloud24.com/api/webhooks/stack
 *   Events: user.created, user.updated, user.deleted
 */

interface StackWebhookPayload {
  type: string;
  data: {
    id: string;
    primary_email?: string;
    display_name?: string;
    server_metadata?: Record<string, unknown>;
    [key: string]: unknown;
  };
}

/**
 * Verify Svix webhook signature.
 * Throws if verification fails (caller should return 401).
 */
function verifyWebhookSignature(
  request: NextRequest,
  body: string
): StackWebhookPayload {
  const webhookSecret = process.env.STACK_WEBHOOK_SECRET;

  if (!webhookSecret) {
    if (process.env.NODE_ENV === 'production') {
      console.error(
        '[Webhook] STACK_WEBHOOK_SECRET not configured in production!'
      );
      throw new Error('Webhook secret not configured');
    }
    console.warn('[Webhook] Skipping signature verification (dev mode)');
    return JSON.parse(body) as StackWebhookPayload;
  }

  const svixId = request.headers.get('svix-id');
  const svixTimestamp = request.headers.get('svix-timestamp');
  const svixSignature = request.headers.get('svix-signature');

  if (!svixId || !svixTimestamp || !svixSignature) {
    console.error('[Webhook] Missing Svix headers');
    throw new Error('Missing required Svix headers');
  }

  const wh = new Webhook(webhookSecret);
  const headers: WebhookRequiredHeaders = {
    'svix-id': svixId,
    'svix-timestamp': svixTimestamp,
    'svix-signature': svixSignature
  };

  return wh.verify(body, headers) as StackWebhookPayload;
}

export async function POST(request: NextRequest) {
  try {
    const rawBody = await request.text();

    let payload: StackWebhookPayload;
    try {
      payload = verifyWebhookSignature(request, rawBody);
    } catch (verifyError) {
      console.error('[Webhook] Signature verification failed:', verifyError);
      return NextResponse.json(
        { error: 'Invalid webhook signature' },
        { status: 401 }
      );
    }

    console.info('[Webhook] Received:', payload.type, payload.data?.id);

    switch (payload.type) {
      case 'user.created':
        await handleUserCreated(payload.data);
        break;

      case 'user.updated':
        await handleUserUpdated(payload.data);
        break;

      case 'user.deleted':
        await handleUserDeleted(payload.data);
        break;

      default:
        console.info('[Webhook] Unhandled event type:', payload.type);
    }

    return NextResponse.json({ received: true });
  } catch (error) {
    console.error('[Webhook] Error processing webhook:', error);
    // Return 200 to prevent retries for malformed payloads
    // Return 500 only for transient errors
    if (error instanceof SyntaxError) {
      return NextResponse.json({ error: 'Invalid JSON' }, { status: 400 });
    }
    return NextResponse.json(
      { error: 'Webhook processing failed' },
      { status: 500 }
    );
  }
}

/**
 * Handle user.created webhook.
 * Syncs the new Stack Auth user into our Prisma DB.
 * If user was already provisioned via admin API, this is a no-op (idempotent).
 */
async function handleUserCreated(data: StackWebhookPayload['data']) {
  if (!data.id || !data.primary_email) {
    console.warn('[Webhook] user.created: missing id or email, skipping');
    return;
  }

  try {
    const result = await UserProvisioningService.syncFromAuthProvider({
      authUserId: data.id,
      email: data.primary_email,
      displayName: data.display_name || undefined
    });

    console.info(
      '[Webhook] user.created processed:',
      `authId=${data.id}`,
      `dbUserId=${result.user.id}`,
      `isNew=${result.isNew}`
    );
  } catch (error) {
    console.error('[Webhook] user.created processing failed:', error);
    throw error;
  }
}

/**
 * Handle user.updated webhook.
 * Updates email/display name if changed in Stack Auth Dashboard.
 */
async function handleUserUpdated(data: StackWebhookPayload['data']) {
  if (!data.id) return;

  try {
    const { prisma } = await import('@/lib/db/prisma');
    const { withRlsBypass } = await import('@/lib/db/rls-context');

    const dbUser = await withRlsBypass(() =>
      prisma.user.findFirst({
        where: { stackAuthUserId: data.id }
      })
    );

    if (!dbUser) {
      console.info(
        '[Webhook] user.updated: user not found in DB, skipping:',
        data.id
      );
      return;
    }

    const updateData: Record<string, unknown> = {};

    if (data.primary_email && data.primary_email !== dbUser.email) {
      updateData.email = data.primary_email;
    }

    if (data.display_name) {
      const parts = data.display_name.split(' ');
      const firstName = parts[0];
      const lastName = parts.slice(1).join(' ') || null;
      if (firstName !== dbUser.firstName) updateData.firstName = firstName;
      if (lastName !== dbUser.lastName) updateData.lastName = lastName;
    }

    if (Object.keys(updateData).length > 0) {
      await withRlsBypass(() =>
        prisma.user.update({
          where: { id: dbUser.id },
          data: updateData
        })
      );
      console.info('[Webhook] user.updated: synced changes for', data.id);
    }
  } catch (error) {
    console.error('[Webhook] user.updated failed:', error);
    throw error;
  }
}

/**
 * Handle user.deleted webhook.
 * Deactivates user in our DB (soft delete).
 */
async function handleUserDeleted(data: StackWebhookPayload['data']) {
  if (!data.id) return;

  try {
    const { prisma } = await import('@/lib/db/prisma');
    const { withRlsBypass } = await import('@/lib/db/rls-context');

    const dbUser = await withRlsBypass(() =>
      prisma.user.findFirst({
        where: { stackAuthUserId: data.id }
      })
    );

    if (!dbUser) {
      console.info('[Webhook] user.deleted: user not found in DB:', data.id);
      return;
    }

    await withRlsBypass(() =>
      prisma.user.update({
        where: { id: dbUser.id },
        data: { status: 'INACTIVE' }
      })
    );

    console.info('[Webhook] user.deleted: deactivated user', dbUser.id);
  } catch (error) {
    console.error('[Webhook] user.deleted failed:', error);
    throw error;
  }
}

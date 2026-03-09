import { NextRequest } from 'next/server';
import { withCurrentUser } from '@/lib/auth/get-current-user';
import { apiResponse, handleApiError } from '@/lib/api/response';
import { prisma } from '@/lib/db/prisma';

const ALLOWED_STATUSES = [
  'SUBMITTED',
  'REVIEW',
  'QUOTED',
  'BOUND',
  'DECLINED',
  'EXPIRED'
] as const;
const ALLOWED_UW_DECISIONS = [
  'APPROVE',
  'DECLINE',
  'REFER',
  'MORE_INFO'
] as const;

export async function GET(
  request: NextRequest,
  context: { params: Promise<{ id: string }> }
) {
  try {
    return await withCurrentUser(request, async (user) => {
      const { id } = await context.params;

      const submission = await prisma.submission.findFirst({
        where: { id, tenantId: user.tenantId, deleted: false },
        include: {
          quotes: { orderBy: { createdAt: 'desc' } }
        }
      });

      if (!submission) {
        return apiResponse({ error: 'Not found' }, 404 as never);
      }

      return apiResponse({ submission });
    });
  } catch (error) {
    return handleApiError(error);
  }
}

export async function PATCH(
  request: NextRequest,
  context: { params: Promise<{ id: string }> }
) {
  try {
    return await withCurrentUser(request, async (user) => {
      const { id } = await context.params;

      // Verify ownership before update
      const existing = await prisma.submission.findFirst({
        where: { id, tenantId: user.tenantId, deleted: false },
        select: { id: true }
      });

      if (!existing) {
        return apiResponse({ error: 'Not found' }, 404 as never);
      }

      const body = await request.json();
      const { status, uwNotes, uwDecision } = body;

      if (status && !ALLOWED_STATUSES.includes(status)) {
        return apiResponse({ error: 'Invalid status' }, 400 as never);
      }

      if (uwDecision && !ALLOWED_UW_DECISIONS.includes(uwDecision)) {
        return apiResponse({ error: 'Invalid uwDecision' }, 400 as never);
      }

      const submission = await prisma.submission.update({
        where: { id },
        data: {
          ...(status !== undefined && { status }),
          ...(uwNotes !== undefined && { uwNotes }),
          ...(uwDecision !== undefined && { uwDecision }),
          updatedAt: new Date()
        },
        include: {
          quotes: { orderBy: { createdAt: 'desc' } }
        }
      });

      return apiResponse({ submission });
    });
  } catch (error) {
    return handleApiError(error);
  }
}

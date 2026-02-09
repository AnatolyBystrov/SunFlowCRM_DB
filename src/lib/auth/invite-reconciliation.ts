import prisma from '@/lib/db/prisma';
import { withRlsBypass } from '@/lib/db/rls-context';
import type { AppUser } from '@/lib/auth/user-service';

export async function reconcileInvitedUser(
    supertokensUserId: string,
    email: string
): Promise<AppUser | null> {
    return withRlsBypass(async () => {
        const invitedUser = await prisma.user.findFirst({
            where: {
                email,
                status: 'INVITED'
            },
            orderBy: {
                createdAt: 'desc'
            },
            include: { tenant: true }
        });

        if (!invitedUser) {
            return null;
        }

        if (invitedUser.supertokensUserId === supertokensUserId) {
            return invitedUser;
        }

        const updatedUser = await prisma.user.update({
            where: { id: invitedUser.id },
            data: {
                supertokensUserId,
                status: 'ACTIVE'
            },
            include: { tenant: true }
        });

        return updatedUser;
    });
}

/**
 * Check if a user was invited
 */
export async function wasUserInvited(email: string, tenantId?: string): Promise<boolean> {
    return withRlsBypass(async () => {
        const where: any = {
            email,
            status: 'INVITED',
            supertokensUserId: {
                startsWith: 'invite:'
            }
        };

        if (tenantId) {
            where.tenantId = tenantId;
        }

        const count = await prisma.user.count({ where });
        return count > 0;
    });
}

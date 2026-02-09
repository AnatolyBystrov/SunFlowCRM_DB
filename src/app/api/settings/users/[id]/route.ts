import { NextRequest, NextResponse } from 'next/server';
import { requireRole } from '@/lib/auth/get-session';
import prisma from '@/lib/db/prisma';
import { UpdateUserSchema } from '@/features/settings/validation';
import { UserRole, UserStatus } from '@prisma/client';

/**
 * PUT /api/settings/users/[id]
 * Update user role or status.
 * Requires ADMIN role.
 */
export async function PUT(
    request: NextRequest,
    { params }: { params: Promise<{ id: string }> }
) {
    try {
        const session = await requireRole(request, 'ADMIN');
        const { id } = await params;
        const body = await request.json();
        const validation = UpdateUserSchema.safeParse(body);
        if (!validation.success) {
            return NextResponse.json(
                { error: 'Validation failed', details: validation.error.issues },
                { status: 400 }
            );
        }
        const updateData = validation.data;

        // Verify user belongs to the same tenant
        const targetUser = await prisma.user.findFirst({
            where: { id, tenantId: session.tenantId },
        });

        if (!targetUser) {
            return NextResponse.json({ error: 'User not found' }, { status: 404 });
        }

        // Prevent self-lockout if this is the last active admin
        if (targetUser.supertokensUserId === session.userId) {
            const nextRole = updateData.role ?? targetUser.role;
            const nextStatus = updateData.status ?? targetUser.status;
            const isDemotingOrDisabling =
                nextRole !== UserRole.ADMIN || nextStatus !== UserStatus.ACTIVE;

            if (isDemotingOrDisabling) {
                const activeAdminCount = await prisma.user.count({
                    where: {
                        tenantId: session.tenantId,
                        role: UserRole.ADMIN,
                        status: UserStatus.ACTIVE
                    }
                });

                if (activeAdminCount <= 1) {
                    return NextResponse.json(
                        { error: 'Cannot remove the last active admin.' },
                        { status: 400 }
                    );
                }
            }
        }

        // Perform update
        const updatedUser = await prisma.user.update({
            where: { id: targetUser.id },
            data: {
                ...(updateData.role && { role: updateData.role }),
                ...(updateData.status && { status: updateData.status }),
            },
        });

        return NextResponse.json(updatedUser);
    } catch (error: any) {
        if (error.message.startsWith('Unauthorized')) {
            return NextResponse.json({ error: error.message }, { status: 401 });
        }
        if (error.message.startsWith('Forbidden')) {
            return NextResponse.json({ error: error.message }, { status: 403 });
        }
        console.error('Error updating user:', error);
        return NextResponse.json(
            { error: 'Internal Server Error' },
            { status: 500 }
        );
    }
}

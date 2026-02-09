import { NextRequest, NextResponse } from 'next/server';
import { requireRole } from '@/lib/auth/get-session';
import prisma from '@/lib/db/prisma';
import { InviteUserSchema } from '@/features/settings/validation';
import { v4 as uuidv4 } from 'uuid';

/**
 * GET /api/settings/users
 * List users for the current tenant.
 * Requires ADMIN role.
 */
export async function GET(request: NextRequest) {
    try {
        const session = await requireRole(request, 'ADMIN');

        const users = await prisma.user.findMany({
            where: {
                tenantId: session.tenantId,
            },
            orderBy: {
                createdAt: 'desc',
            },
            select: {
                id: true,
                email: true,
                firstName: true,
                lastName: true,
                role: true,
                status: true,
                createdAt: true,
                lastOnline: true,
                avatar: true,
            },
        });

        return NextResponse.json(users);
    } catch (error: any) {
        if (error.message.startsWith('Unauthorized')) {
            return NextResponse.json({ error: error.message }, { status: 401 });
        }
        if (error.message.startsWith('Forbidden')) {
            return NextResponse.json({ error: error.message }, { status: 403 });
        }
        console.error('Error fetching users:', error);
        return NextResponse.json(
            { error: 'Internal Server Error' },
            { status: 500 }
        );
    }
}

/**
 * POST /api/settings/users
 * Invite a new user to the tenant.
 * Requires ADMIN role.
 */
export async function POST(request: NextRequest) {
    try {
        const session = await requireRole(request, 'ADMIN');
        const body = await request.json();

        // Validate request body with Zod
        const validation = InviteUserSchema.safeParse(body);
        if (!validation.success) {
            return NextResponse.json(
                { error: 'Validation failed', details: validation.error.issues },
                { status: 400 }
            );
        }

        const data = validation.data;

        // Check if user already exists in this tenant
        const existingUser = await prisma.user.findFirst({
            where: {
                email: data.email,
                tenantId: session.tenantId,
            },
        });

        if (existingUser) {
            return NextResponse.json(
                { error: 'User already exists in this organization' },
                { status: 409 }
            );
        }

        // Create invited user
        // Note: supertokensUserId is required and unique.
        // For invited users who haven't signed up yet, we'll generate a placeholder ID.
        // When they actually sign up, invite-reconciliation.ts will update this.
        const placeholderId = `invite:${uuidv4()}`;

        const newUser = await prisma.user.create({
            data: {
                email: data.email,
                role: data.role,
                firstName: data.firstName,
                lastName: data.lastName,
                tenantId: session.tenantId,
                status: 'INVITED',
                supertokensUserId: placeholderId,
            },
        });

        // TODO: Send invitation email integration here

        return NextResponse.json(newUser, { status: 201 });
    } catch (error: any) {
        if (error.message.startsWith('Unauthorized')) {
            return NextResponse.json({ error: error.message }, { status: 401 });
        }
        if (error.message.startsWith('Forbidden')) {
            return NextResponse.json({ error: error.message }, { status: 403 });
        }
        console.error('Error inviting user:', error);
        return NextResponse.json(
            { error: 'Internal Server Error' },
            { status: 500 }
        );
    }
}

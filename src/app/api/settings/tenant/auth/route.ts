import { NextRequest, NextResponse } from 'next/server';
import { requireRole } from '@/lib/auth/get-session';
import prisma from '@/lib/db/prisma';
import { TenantAuthSettings, DEFAULT_AUTH_SETTINGS } from '@/features/settings/types';

/**
 * GET /api/settings/tenant/auth
 * Get tenant auth settings.
 * Requires ADMIN role.
 */
export async function GET(request: NextRequest) {
    try {
        const session = await requireRole(request, 'ADMIN');

        const tenant = await prisma.tenant.findUnique({
            where: { id: session.tenantId },
            select: { settings: true },
        });

        if (!tenant) {
            return NextResponse.json({ error: 'Tenant not found' }, { status: 404 });
        }

        const settings = tenant.settings as any;
        const authSettings: TenantAuthSettings = {
            ...DEFAULT_AUTH_SETTINGS,
            ...(settings.auth || {}),
        };

        return NextResponse.json(authSettings);
    } catch (error: any) {
        if (error.message.startsWith('Unauthorized')) {
            return NextResponse.json({ error: error.message }, { status: 401 });
        }
        if (error.message.startsWith('Forbidden')) {
            return NextResponse.json({ error: error.message }, { status: 403 });
        }
        console.error('Error fetching auth settings:', error);
        return NextResponse.json(
            { error: 'Internal Server Error' },
            { status: 500 }
        );
    }
}

/**
 * PUT /api/settings/tenant/auth
 * Update tenant auth settings.
 * Requires ADMIN role.
 */
export async function PUT(request: NextRequest) {
    try {
        const session = await requireRole(request, 'ADMIN');
        const body: Partial<TenantAuthSettings> = await request.json();

        // Fetch current settings to merge
        const tenant = await prisma.tenant.findUnique({
            where: { id: session.tenantId },
            select: { settings: true },
        });

        if (!tenant) {
            return NextResponse.json({ error: 'Tenant not found' }, { status: 404 });
        }

        const currentSettings = tenant.settings as any;
        const currentAuth = currentSettings.auth || {};

        // Validate inputs (basic)
        if (body.passwordMinLength && body.passwordMinLength < 6) {
            return NextResponse.json({ error: 'Password length must be at least 6' }, { status: 400 });
        }

        // Merge new settings
        const newSettings = {
            ...currentSettings,
            auth: {
                ...DEFAULT_AUTH_SETTINGS,
                ...currentAuth,
                ...body,
            },
        };

        const updatedTenant = await prisma.tenant.update({
            where: { id: session.tenantId },
            data: { settings: newSettings },
        });

        return NextResponse.json(newSettings.auth);
    } catch (error: any) {
        if (error.message.startsWith('Unauthorized')) {
            return NextResponse.json({ error: error.message }, { status: 401 });
        }
        if (error.message.startsWith('Forbidden')) {
            return NextResponse.json({ error: error.message }, { status: 403 });
        }
        console.error('Error updating auth settings:', error);
        return NextResponse.json(
            { error: 'Internal Server Error' },
            { status: 500 }
        );
    }
}

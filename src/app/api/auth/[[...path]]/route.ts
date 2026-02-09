import { NextRequest, NextResponse } from 'next/server';
import { ensureSuperTokensInit } from '@/lib/supertokens/config';
import { getAppDirRequestHandler } from 'supertokens-node/nextjs';

ensureSuperTokensInit();

/**
 * SuperTokens API route handler for /api/auth/*
 * Handles all authentication endpoints (signin, signup, signout, session refresh, etc.)
 */
const handleRequest = getAppDirRequestHandler();

export async function GET(request: NextRequest) {
    return handleRequest(request);
}

export async function POST(request: NextRequest) {
    return handleRequest(request);
}

export async function DELETE(request: NextRequest) {
    return handleRequest(request);
}

export async function PUT(request: NextRequest) {
    return handleRequest(request);
}

export async function PATCH(request: NextRequest) {
    return handleRequest(request);
}

export async function HEAD(request: NextRequest) {
    return handleRequest(request);
}

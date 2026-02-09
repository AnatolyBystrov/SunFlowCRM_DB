# SunFlowCRM Authentication & Security Summary

This document provides a technical overview of the authentication and security implementation in SunFlowCRM, following the migration from Clerk to **SuperTokens**.

## 1. Core Architecture

SunFlowCRM uses a hybrid authentication model where **SuperTokens** handles session management and credentials, while a local **Prisma** database manages business logic, multi-tenancy (tenants), and roles.

### Key Components:
- **SuperTokens Core**: Handles secure session tokens, cookies, and password hashing.
- **Client-Side Protection**: Uses SuperTokens `SessionAuth` component for frontend route guarding.
- **Server-Side Protection**: Uses `requireAuth` and `getSession` utilities for API and Server Component protection.
- **Prisma RLS Middleware**: Automatically isolates data between tenants at the database level.

---

## 2. SuperTokens Configuration

Located in `src/lib/supertokens/config.ts`.

### Security Hardening:
- **Disabled Public Signup**: Public registration is blocked via `signUpPOST` override.
- **Session Payload**: The access token carries `tenantId` and `roles` to avoid redundant DB lookups.

```typescript
// Injection of custom data into session
createNewSession: async function (input) {
    // Reconcile invited user and fetch app-specific data
    const appUser = await reconcileInvitedUser(input.userId, email);
    
    input.accessTokenPayload = {
        ...input.accessTokenPayload,
        tenantId: appUser.tenantId,
        roles: [appUser.role], // ADMIN, MEMBER, or VIEWER
    };
    return originalImplementation.createNewSession(input);
}
```

---

## 3. Data Isolation (Row-Level Security)

Located in `src/lib/db/prisma-rls-middleware.ts`.

SunFlowCRM uses a custom Prisma middleware that enforces **Tenant Isolation**. Every query to the database is automatically scoped to the current user's `tenantId` for protected models.

### How it works:
1. Middleware extracts `tenantId` from `RequestContext` (populated via `AsyncLocalStorage` during the request).
2. It modifies the `where` clause of Prisma calls (currently active for the `User` model).

```typescript
// Active RLS Logic
if (params.model === 'User') {
    params.args.where = {
        ...params.args.where,
        tenantId 
    };
}
```

---

## 4. Invite-Only Flow

Registration is strictly controlled through an invitation system.

1. **Invite**: Admin creates a User record in the DB with `status: 'INVITED'` and a role/tenantId.
2. **Accept**: User registers via SuperTokens.
3. **Reconciliation**: On first login (during session creation), `reconcileInvitedUser` links the SuperTokens `supertokensUserId` to the existing DB record and activates the user.

---

## 5. Security & Validation

- **Zod Validation**: API routes (e.g., `/api/settings/users/*`) use Zod schemas for strict request body validation.
- **Minimal Middleware**: `src/middleware.ts` is kept minimal to avoid performance overhead; protection is handled closer to the logic (per route/component).
- **Self-Lockout Prevention**: System prevents the last Admin from being deleted or losing their role.

## 6. UI/UX Features

- **Inline Validation**: `react-hook-form` + `Zod` in `AuthForm` for real-time feedback (`onBlur` mode).
- **Password Toggle**: Custom `PasswordInput` component with visibility toggle.
- **WCAG 2.1 AA**: Accessible forms with high-quality ARIA labels and error announcements.

---

## Technical Documentation Links
- [Auth System Deep-Dive](docs/AUTH_SYSTEM.md)
- [SuperTokens Setup Guide](docs/supertokens_setup.md)
- [Project README](../README.md)

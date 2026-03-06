# ─── Stage 1: Install dependencies ──────────────────────────────────────────
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat openssl
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --legacy-peer-deps --ignore-scripts

# ─── Stage 2: Build the Next.js application ───────────────────────────────────
FROM node:20-alpine AS builder
RUN apk add --no-cache libc6-compat openssl
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Generate Prisma client
RUN npx prisma generate

# Disable Sentry telemetry and Next.js telemetry during build
ENV NEXT_TELEMETRY_DISABLED=1
ENV NEXT_PUBLIC_SENTRY_DISABLED=true
ENV NEXT_TURBOPACK_EXPERIMENTAL_USE_SYSTEM_TLS_CERTS=1

# Build-time public envs (required for correct client bundle behavior)
ARG NEXT_PUBLIC_APP_NAME=SunFlowCRM
ARG NEXT_PUBLIC_APP_URL=http://localhost:3000
ARG NEXT_PUBLIC_API_DOMAIN=http://localhost:3000
ARG NEXT_PUBLIC_AUTH_PROVIDER=supertokens
ARG NEXT_PUBLIC_STACK_PROJECT_ID=
ARG NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY=
ARG NEXT_PUBLIC_STACK_PUBLISHABLE_KEY=
ARG NEXT_PUBLIC_STACK_URL=
ARG NEXT_PUBLIC_STACK_API_URL=

ENV NEXT_PUBLIC_APP_NAME=$NEXT_PUBLIC_APP_NAME
ENV NEXT_PUBLIC_APP_URL=$NEXT_PUBLIC_APP_URL
ENV NEXT_PUBLIC_API_DOMAIN=$NEXT_PUBLIC_API_DOMAIN
ENV NEXT_PUBLIC_AUTH_PROVIDER=$NEXT_PUBLIC_AUTH_PROVIDER
ENV NEXT_PUBLIC_STACK_PROJECT_ID=$NEXT_PUBLIC_STACK_PROJECT_ID
ENV NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY=$NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY
ENV NEXT_PUBLIC_STACK_PUBLISHABLE_KEY=$NEXT_PUBLIC_STACK_PUBLISHABLE_KEY
ENV NEXT_PUBLIC_STACK_URL=$NEXT_PUBLIC_STACK_URL
ENV NEXT_PUBLIC_STACK_API_URL=$NEXT_PUBLIC_STACK_API_URL

RUN npm run build

# ─── Stage 3: Production runtime ──────────────────────────────────────────────
FROM node:20-alpine AS runner
RUN apk add --no-cache libc6-compat openssl
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy public assets
COPY --from=builder /app/public ./public

# Copy Next.js standalone output and static files
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Worker runtime assets (ts source + tsx + path aliases)
COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/workers ./workers
COPY --from=builder /app/src ./src
COPY --from=builder /app/scripts ./scripts
COPY --from=builder /app/tsconfig.json ./tsconfig.json
COPY --from=builder /app/package.json ./package.json

# Copy Prisma schema and migrations for runtime migrate/generate
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/node_modules/@prisma ./node_modules/@prisma

USER nextjs

EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]

import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import { createRlsMiddleware } from '@/lib/db/prisma-rls-middleware';

// PostgreSQL connection pool
const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
});

// Prisma adapter for PostgreSQL (required in Prisma 7)
const adapter = new PrismaPg(pool);

const globalForPrisma = globalThis as unknown as {
    prisma: PrismaClient;
};

export const prisma = globalForPrisma.prisma || (() => {
    const client = new PrismaClient({ adapter });
    client.$use(createRlsMiddleware());
    return client;
})();

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

export default prisma;


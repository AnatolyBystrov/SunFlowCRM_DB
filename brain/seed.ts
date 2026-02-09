// ============================================
// SEED DATA для базы данных
// ============================================
// Файл: prisma/seed.ts

import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    console.log('🌱 Starting database seeding...');

    // ============================================
    // 1. GLOBAL REFERENCE DATA
    // ============================================

    console.log('📊 Seeding currencies...');
    const currencies = await Promise.all([
        prisma.currency.upsert({
            where: { code: 'USD' },
            update: {},
            create: { code: 'USD', name: 'US Dollar', symbol: '$', active: true },
        }),
        prisma.currency.upsert({
            where: { code: 'EUR' },
            update: {},
            create: { code: 'EUR', name: 'Euro', symbol: '€', active: true },
        }),
        prisma.currency.upsert({
            where: { code: 'GBP' },
            update: {},
            create: { code: 'GBP', name: 'British Pound', symbol: '£', active: true },
        }),
        prisma.currency.upsert({
            where: { code: 'AED' },
            update: {},
            create: { code: 'AED', name: 'UAE Dirham', symbol: 'د.إ', active: true },
        }),
    ]);
    console.log(`✅ Created ${currencies.length} currencies`);

    console.log('🌍 Seeding regions...');
    const regions = await Promise.all([
        prisma.region.upsert({
            where: { code: 'MENA' },
            update: {},
            create: { code: 'MENA', name: 'Middle East & North Africa', active: true },
        }),
        prisma.region.upsert({
            where: { code: 'EU' },
            update: {},
            create: { code: 'EU', name: 'Europe', active: true },
        }),
        prisma.region.upsert({
            where: { code: 'NA' },
            update: {},
            create: { code: 'NA', name: 'North America', active: true },
        }),
        prisma.region.upsert({
            where: { code: 'APAC' },
            update: {},
            create: { code: 'APAC', name: 'Asia Pacific', active: true },
        }),
    ]);
    console.log(`✅ Created ${regions.length} regions`);

    console.log('🏳️ Seeding countries...');
    const countries = await Promise.all([
        prisma.country.upsert({
            where: { code: 'AE' },
            update: {},
            create: { code: 'AE', name: 'United Arab Emirates', regionCode: 'MENA', active: true },
        }),
        prisma.country.upsert({
            where: { code: 'US' },
            update: {},
            create: { code: 'US', name: 'United States', regionCode: 'NA', active: true },
        }),
        prisma.country.upsert({
            where: { code: 'GB' },
            update: {},
            create: { code: 'GB', name: 'United Kingdom', regionCode: 'EU', active: true },
        }),
        prisma.country.upsert({
            where: { code: 'SA' },
            update: {},
            create: { code: 'SA', name: 'Saudi Arabia', regionCode: 'MENA', active: true },
        }),
    ]);
    console.log(`✅ Created ${countries.length} countries`);

    // ============================================
    // 2. INSURANCE CLASSIFICATION
    // ============================================

    console.log('📋 Seeding lines of business...');
    const propertyLine = await prisma.lineOfBusiness.upsert({
        where: { code: 'PROP' },
        update: {},
        create: {
            code: 'PROP',
            name: 'Property',
            type: 'Non-Life',
            active: true,
        },
    });

    const casualtyLine = await prisma.lineOfBusiness.upsert({
        where: { code: 'CAS' },
        update: {},
        create: {
            code: 'CAS',
            name: 'Casualty',
            type: 'Non-Life',
            active: true,
        },
    });

    const marineLine = await prisma.lineOfBusiness.upsert({
        where: { code: 'MAR' },
        update: {},
        create: {
            code: 'MAR',
            name: 'Marine',
            type: 'Non-Life',
            active: true,
        },
    });

    console.log('✅ Created 3 lines of business');

    console.log('📝 Seeding classes of business...');
    await Promise.all([
        // Property classes
        prisma.classOfBusiness.upsert({
            where: { lineId_code: { lineId: propertyLine.id, code: 'FIRE' } },
            update: {},
            create: { lineId: propertyLine.id, code: 'FIRE', name: 'Fire', active: true },
        }),
        prisma.classOfBusiness.upsert({
            where: { lineId_code: { lineId: propertyLine.id, code: 'EQ' } },
            update: {},
            create: { lineId: propertyLine.id, code: 'EQ', name: 'Earthquake', active: true },
        }),
        // Casualty classes
        prisma.classOfBusiness.upsert({
            where: { lineId_code: { lineId: casualtyLine.id, code: 'GL' } },
            update: {},
            create: { lineId: casualtyLine.id, code: 'GL', name: 'General Liability', active: true },
        }),
        prisma.classOfBusiness.upsert({
            where: { lineId_code: { lineId: casualtyLine.id, code: 'WC' } },
            update: {},
            create: { lineId: casualtyLine.id, code: 'WC', name: 'Workers Compensation', active: true },
        }),
        // Marine classes
        prisma.classOfBusiness.upsert({
            where: { lineId_code: { lineId: marineLine.id, code: 'CARGO' } },
            update: {},
            create: { lineId: marineLine.id, code: 'CARGO', name: 'Cargo', active: true },
        }),
        prisma.classOfBusiness.upsert({
            where: { lineId_code: { lineId: marineLine.id, code: 'HULL' } },
            update: {},
            create: { lineId: marineLine.id, code: 'HULL', name: 'Hull', active: true },
        }),
    ]);
    console.log('✅ Created 6 classes of business');

    // ============================================
    // 3. SAMPLE TENANT
    // ============================================

    console.log('🏢 Creating demo tenant...');
    const tenant = await prisma.tenant.upsert({
        where: { clerkOrgId: 'org_demo_123' },
        update: {},
        create: {
            clerkOrgId: 'org_demo_123',
            name: 'Demo Reinsurance Company',
            slug: 'demo-re',
            plan: 'PROFESSIONAL',
            status: 'ACTIVE',
            settings: {
                baseCurrency: 'USD',
                timezone: 'Asia/Dubai',
                dateFormat: 'DD/MM/YYYY',
            },
        },
    });
    console.log(`✅ Created tenant: ${tenant.name}`);

    // ============================================
    // 4. SAMPLE USERS
    // ============================================

    console.log('👥 Creating demo users...');
    const adminUser = await prisma.user.upsert({
        where: { clerkUserId: 'user_admin_123' },
        update: {},
        create: {
            tenantId: tenant.id,
            clerkUserId: 'user_admin_123',
            email: 'admin@demo-re.com',
            firstName: 'John',
            lastName: 'Admin',
            role: 'ADMIN',
            status: 'ACTIVE',
            jobTitle: 'CEO',
            department: 'Management',
        },
    });

    const underwriter = await prisma.user.upsert({
        where: { clerkUserId: 'user_uw_123' },
        update: {},
        create: {
            tenantId: tenant.id,
            clerkUserId: 'user_uw_123',
            email: 'underwriter@demo-re.com',
            firstName: 'Sarah',
            lastName: 'Underwriter',
            role: 'UNDERWRITER',
            status: 'ACTIVE',
            jobTitle: 'Senior Underwriter',
            department: 'Underwriting',
        },
    });

    const salesUser = await prisma.user.upsert({
        where: { clerkUserId: 'user_sales_123' },
        update: {},
        create: {
            tenantId: tenant.id,
            clerkUserId: 'user_sales_123',
            email: 'sales@demo-re.com',
            firstName: 'Mike',
            lastName: 'Sales',
            role: 'SALES',
            status: 'ACTIVE',
            jobTitle: 'Sales Manager',
            department: 'Sales',
        },
    });

    console.log('✅ Created 3 demo users');

    // ============================================
    // 5. CRM PIPELINE
    // ============================================

    console.log('🔄 Creating sales pipeline...');
    const pipeline = await prisma.pipeline.create({
        data: {
            tenantId: tenant.id,
            name: 'Reinsurance Sales',
            orderNr: 1,
            active: true,
            stages: {
                create: [
                    { name: 'Lead', orderNr: 1, probability: 10 },
                    { name: 'Qualified', orderNr: 2, probability: 25 },
                    { name: 'Proposal', orderNr: 3, probability: 50 },
                    { name: 'Negotiation', orderNr: 4, probability: 75 },
                    { name: 'Won', orderNr: 5, probability: 100 },
                ],
            },
        },
        include: { stages: true },
    });
    console.log(`✅ Created pipeline with ${pipeline.stages.length} stages`);

    // ============================================
    // 6. INSURANCE PRODUCTS
    // ============================================

    console.log('🛡️ Creating insurance products...');
    await Promise.all([
        prisma.insuranceProduct.create({
            data: {
                tenantId: tenant.id,
                name: 'Property All Risk',
                code: 'PAR-001',
                category: 'PROPERTY',
                description: 'Comprehensive property insurance coverage',
                baseRate: 0.0025,
                minPremium: 10000,
                maxCoverage: 100000000,
                active: true,
            },
        }),
        prisma.insuranceProduct.create({
            data: {
                tenantId: tenant.id,
                name: 'Marine Cargo',
                code: 'MAR-001',
                category: 'MARINE',
                description: 'Marine cargo insurance',
                baseRate: 0.0015,
                minPremium: 5000,
                maxCoverage: 50000000,
                active: true,
            },
        }),
        prisma.insuranceProduct.create({
            data: {
                tenantId: tenant.id,
                name: 'General Liability',
                code: 'GL-001',
                category: 'CASUALTY',
                description: 'General liability coverage',
                baseRate: 0.003,
                minPremium: 15000,
                maxCoverage: 75000000,
                active: true,
            },
        }),
    ]);
    console.log('✅ Created 3 insurance products');

    // ============================================
    // 7. PAYMENT METHODS
    // ============================================

    console.log('💳 Creating payment methods...');
    await Promise.all([
        prisma.paymentMethod.create({
            data: {
                tenantId: tenant.id,
                name: 'Bank Transfer',
                type: 'BANK_TRANSFER',
                description: 'Direct bank transfer',
                onlinePayable: false,
                availableOnInvoice: true,
                active: true,
            },
        }),
        prisma.paymentMethod.create({
            data: {
                tenantId: tenant.id,
                name: 'Wire Transfer',
                type: 'WIRE_TRANSFER',
                description: 'International wire transfer',
                onlinePayable: false,
                availableOnInvoice: true,
                active: true,
            },
        }),
        prisma.paymentMethod.create({
            data: {
                tenantId: tenant.id,
                name: 'Check',
                type: 'CHECK',
                description: 'Payment by check',
                onlinePayable: false,
                availableOnInvoice: true,
                active: true,
            },
        }),
    ]);
    console.log('✅ Created 3 payment methods');

    // ============================================
    // 8. EXCHANGE RATES (Sample)
    // ============================================

    console.log('💱 Creating sample exchange rates...');
    const today = new Date();
    await Promise.all([
        prisma.exchangeRate.create({
            data: {
                tenantId: tenant.id,
                date: today,
                fromCurrency: 'USD',
                toCurrency: 'EUR',
                rate: 0.92,
                source: 'ECB',
            },
        }),
        prisma.exchangeRate.create({
            data: {
                tenantId: tenant.id,
                date: today,
                fromCurrency: 'USD',
                toCurrency: 'GBP',
                rate: 0.79,
                source: 'ECB',
            },
        }),
        prisma.exchangeRate.create({
            data: {
                tenantId: tenant.id,
                date: today,
                fromCurrency: 'USD',
                toCurrency: 'AED',
                rate: 3.67,
                source: 'Manual',
            },
        }),
    ]);
    console.log('✅ Created 3 exchange rates');

    console.log('');
    console.log('🎉 Database seeding completed successfully!');
    console.log('');
    console.log('📊 Summary:');
    console.log(`   - Tenant: ${tenant.name}`);
    console.log(`   - Users: 3 (Admin, Underwriter, Sales)`);
    console.log(`   - Pipeline: ${pipeline.name} with ${pipeline.stages.length} stages`);
    console.log(`   - Insurance Products: 3`);
    console.log(`   - Payment Methods: 3`);
    console.log('');
}

main()
    .catch((e) => {
        console.error('❌ Error during seeding:', e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });

-- Sun UW Database Schema
-- Exported for DrawSQL Import
-- PostgreSQL 16 Compatible

-- Enable Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ---------------------------------------------------------
-- ENUMS
-- ---------------------------------------------------------

CREATE TYPE "EntityStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'ARCHIVED', 'DELETED');
CREATE TYPE "KycStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');
CREATE TYPE "DealStage" AS ENUM ('NEW', 'QUALIFICATION', 'PROPOSAL', 'NEGOTIATION', 'WON', 'LOST');
CREATE TYPE "SubmissionStatus" AS ENUM ('DRAFT', 'SUBMITTED', 'UNDERWRITING', 'QUOTED', 'BOUND', 'DECLINED');
CREATE TYPE "PolicyStatus" AS ENUM ('ACTIVE', 'EXPIRED', 'CANCELLED');
CREATE TYPE "ClaimStatus" AS ENUM ('OPEN', 'INVESTIGATING', 'APPROVED', 'REJECTED', 'CLOSED');
CREATE TYPE "InvoiceStatus" AS ENUM ('DRAFT', 'SENT', 'PAID', 'OVERDUE', 'CANCELLED');
CREATE TYPE "TaskStatus" AS ENUM ('OPEN', 'IN_PROGRESS', 'DONE');
CREATE TYPE "ApprovalStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

CREATE TYPE "EntityType" AS ENUM (
    'CLIENT', 
    'CONTACT', 
    'DEAL', 
    'SUBMISSION', 
    'POLICY', 
    'CLAIM', 
    'INVOICE', 
    'DOCUMENT',
    'USER'
);

-- ---------------------------------------------------------
-- CORE TABLES
-- ---------------------------------------------------------

CREATE TABLE "tenants" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "name" VARCHAR(255) NOT NULL,
    "status" VARCHAR(50) DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE "users" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "email" VARCHAR(255) NOT NULL UNIQUE,
    "first_name" VARCHAR(100),
    "last_name" VARCHAR(100),
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE "roles" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "tenant_id" UUID REFERENCES "tenants"("id"),
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "permissions" TEXT[], -- Array of permission strings
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT "unique_role_name_per_tenant" UNIQUE ("tenant_id", "name")
);

CREATE TABLE "memberships" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "user_id" UUID NOT NULL REFERENCES "users"("id"),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id"),
    "role_id" UUID NOT NULL REFERENCES "roles"("id"),
    "status" VARCHAR(50) DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT "unique_user_tenant" UNIQUE ("user_id", "tenant_id")
);

CREATE TABLE "audit_logs" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id"),
    "actor_id" UUID REFERENCES "users"("id"),
    "action" VARCHAR(100) NOT NULL,
    "entity_type" VARCHAR(100) NOT NULL,
    "entity_id" VARCHAR(255) NOT NULL,
    "changes" JSONB,
    "ip_address" VARCHAR(45),
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ---------------------------------------------------------
-- SYSTEM OBJECT REGISTRY (Polymorphism)
-- ---------------------------------------------------------

CREATE TABLE "system_objects" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id"),
    "entity_type" "EntityType" NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX "idx_system_objects_tenant_type" ON "system_objects"("tenant_id", "entity_type");

-- ---------------------------------------------------------
-- CRM MODULE
-- ---------------------------------------------------------

CREATE TABLE "clients" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id"),
    "system_object_id" UUID NOT NULL UNIQUE REFERENCES "system_objects"("id"),
    "name" VARCHAR(255) NOT NULL,
    "industry" VARCHAR(100),
    "status" "EntityStatus" DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "deleted_at" TIMESTAMP WITH TIME ZONE
);

CREATE INDEX "idx_clients_tenant_name" ON "clients"("tenant_id", "name");

CREATE TABLE "contacts" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id"),
    "client_id" UUID NOT NULL REFERENCES "clients"("id"),
    "first_name" VARCHAR(100) NOT NULL,
    "last_name" VARCHAR(100) NOT NULL,
    "email" VARCHAR(255),
    "phone" VARCHAR(50),
    "role" VARCHAR(100),
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE "deals" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id"),
    "system_object_id" UUID NOT NULL UNIQUE REFERENCES "system_objects"("id"),
    "client_id" UUID NOT NULL REFERENCES "clients"("id"),
    "title" VARCHAR(255) NOT NULL,
    "stage" "DealStage" DEFAULT 'NEW',
    "amount" DECIMAL(15, 2) DEFAULT 0,
    "probability" INTEGER DEFAULT 0,
    "closed_at" TIMESTAMP WITH TIME ZONE,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX "idx_deals_tenant_stage" ON "deals"("tenant_id", "stage");

-- ---------------------------------------------------------
-- KYC MODULE
-- ---------------------------------------------------------

CREATE TABLE "kyc_profiles" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id"),
    "client_id" UUID NOT NULL UNIQUE REFERENCES "clients"("id"),
    "status" "KycStatus" DEFAULT 'PENDING',
    "risk_level" VARCHAR(20) DEFAULT 'LOW',
    "verified_at" TIMESTAMP WITH TIME ZONE
);

CREATE TABLE "kyc_checks" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "kyc_profile_id" UUID NOT NULL REFERENCES "kyc_profiles"("id"),
    "type" VARCHAR(50) NOT NULL, -- AML, PEP, IDENTITY
    "status" VARCHAR(50) NOT NULL, -- PASSED, FAILED
    "provider" VARCHAR(100),
    "raw_data" JSONB,
    "performed_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ---------------------------------------------------------
-- UNDERWRITING MODULE
-- ---------------------------------------------------------

CREATE TABLE "submissions" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id"),
    "system_object_id" UUID NOT NULL UNIQUE REFERENCES "system_objects"("id"),
    "deal_id" UUID NOT NULL UNIQUE REFERENCES "deals"("id"),
    "status" "SubmissionStatus" DEFAULT 'DRAFT',
    "risk_score" INTEGER,
    "underwriter_id" UUID REFERENCES "users"("id"),
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE "policies" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id"),
    "system_object_id" UUID NOT NULL UNIQUE REFERENCES "system_objects"("id"),
    "submission_id" UUID NOT NULL UNIQUE REFERENCES "submissions"("id"),
    "client_id" UUID NOT NULL REFERENCES "clients"("id"),
    "policy_number" VARCHAR(100) NOT NULL,
    "effective_date" TIMESTAMP WITH TIME ZONE NOT NULL,
    "expiry_date" TIMESTAMP WITH TIME ZONE NOT NULL,
    "premium_amount" DECIMAL(15, 2) NOT NULL,
    "coverage_limit" DECIMAL(15, 2) NOT NULL,
    "status" "PolicyStatus" DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT "unique_policy_number_per_tenant" UNIQUE ("tenant_id", "policy_number")
);

CREATE INDEX "idx_policies_expiry" ON "policies"("tenant_id", "expiry_date");

-- ---------------------------------------------------------
-- CLAIMS MODULE
-- ---------------------------------------------------------

CREATE TABLE "claims" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id"),
    "system_object_id" UUID NOT NULL UNIQUE REFERENCES "system_objects"("id"),
    "policy_id" UUID NOT NULL REFERENCES "policies"("id"),
    "loss_date" TIMESTAMP WITH TIME ZONE NOT NULL,
    "reported_date" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "description" TEXT NOT NULL,
    "status" "ClaimStatus" DEFAULT 'OPEN',
    "reserve_amount" DECIMAL(15, 2) DEFAULT 0,
    "paid_amount" DECIMAL(15, 2) DEFAULT 0,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE "claim_payouts" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id"),
    "claim_id" UUID NOT NULL REFERENCES "claims"("id"),
    "amount" DECIMAL(15, 2) NOT NULL,
    "status" VARCHAR(50) DEFAULT 'PENDING',
    "paid_at" TIMESTAMP WITH TIME ZONE
);

-- ---------------------------------------------------------
-- DOCUMENTS MODULE
-- ---------------------------------------------------------

CREATE TABLE "documents" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id"),
    "system_object_id" UUID NOT NULL UNIQUE REFERENCES "system_objects"("id"),
    "parent_object_id" UUID REFERENCES "system_objects"("id"), -- Polymorphic Link
    "title" VARCHAR(255) NOT NULL,
    "mime_type" VARCHAR(100) NOT NULL,
    "size_bytes" BIGINT NOT NULL,
    "s3_key" VARCHAR(512) NOT NULL,
    "s3_bucket" VARCHAR(100) NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ---------------------------------------------------------
-- ACCOUNTING MODULE
-- ---------------------------------------------------------

CREATE TABLE "invoices" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id"),
    "system_object_id" UUID NOT NULL UNIQUE REFERENCES "system_objects"("id"),
    "policy_id" UUID REFERENCES "policies"("id"),
    "invoice_number" VARCHAR(100) NOT NULL,
    "due_date" TIMESTAMP WITH TIME ZONE,
    "amount" DECIMAL(15, 2) NOT NULL,
    "status" "InvoiceStatus" DEFAULT 'DRAFT',
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT "unique_invoice_number_per_tenant" UNIQUE ("tenant_id", "invoice_number")
);

CREATE TABLE "transactions" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id"),
    "invoice_id" UUID REFERENCES "invoices"("id"),
    "amount" DECIMAL(15, 2) NOT NULL,
    "type" VARCHAR(50) NOT NULL, -- PAYMENT_IN, PAYMENT_OUT
    "reference" VARCHAR(255),
    "processed_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ---------------------------------------------------------
-- APPROVALS & TASKS (Polymorphic Children)
-- ---------------------------------------------------------

CREATE TABLE "approval_requests" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id"),
    "target_object_id" UUID NOT NULL REFERENCES "system_objects"("id"),
    "requester_id" UUID NOT NULL REFERENCES "users"("id"),
    "status" "ApprovalStatus" DEFAULT 'PENDING',
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE "approval_steps" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "approval_request_id" UUID NOT NULL REFERENCES "approval_requests"("id"),
    "approver_role_id" UUID REFERENCES "roles"("id"),
    "approver_user_id" UUID REFERENCES "users"("id"),
    "status" VARCHAR(50) DEFAULT 'PENDING',
    "comments" TEXT,
    "decided_at" TIMESTAMP WITH TIME ZONE
);

CREATE TABLE "tasks" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id"),
    "target_object_id" UUID REFERENCES "system_objects"("id"), -- Optional link
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "status" "TaskStatus" DEFAULT 'OPEN',
    "priority" VARCHAR(20) DEFAULT 'MEDIUM',
    "due_date" TIMESTAMP WITH TIME ZONE,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE "task_assignees" (
    "task_id" UUID NOT NULL REFERENCES "tasks"("id"),
    "user_id" UUID NOT NULL REFERENCES "users"("id"),
    PRIMARY KEY ("task_id", "user_id")
);

CREATE TABLE "notes" (
    "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    "tenant_id" UUID NOT NULL REFERENCES "tenants"("id"),
    "system_object_id" UUID NOT NULL REFERENCES "system_objects"("id"),
    "author_id" UUID NOT NULL REFERENCES "users"("id"),
    "content" TEXT NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

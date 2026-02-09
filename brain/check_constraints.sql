-- ============================================
-- CHECK CONSTRAINTS для бизнес-правил
-- ============================================
-- Этот файл нужно применить ПОСЛЕ основной миграции Prisma

-- Deal: value должен быть положительным
ALTER TABLE deals 
  ADD CONSTRAINT deal_value_positive 
  CHECK (value > 0);

-- Policy: expiryDate должен быть после effectiveDate
ALTER TABLE policies 
  ADD CONSTRAINT policy_dates_valid 
  CHECK (expiry_date > effective_date);

-- Policy: финансовые поля не могут быть отрицательными
ALTER TABLE policies 
  ADD CONSTRAINT policy_amounts_non_negative 
  CHECK (
    gross_premium >= 0 AND
    net_premium >= 0 AND
    total_deductions >= 0 AND
    paid_premium >= 0 AND
    outstanding_premium >= 0 AND
    commission_received >= 0 AND
    outstanding_commission >= 0 AND
    paid_loss >= 0 AND
    outstanding_loss >= 0
  );

-- Payment: netAmount = amount - bankCommission
ALTER TABLE payments 
  ADD CONSTRAINT payment_net_amount_calc 
  CHECK (net_amount = amount - bank_commission);

-- Payment: amount должен быть положительным
ALTER TABLE payments 
  ADD CONSTRAINT payment_amount_positive 
  CHECK (amount > 0);

-- Invoice: totalAmount должен быть положительным
ALTER TABLE invoices 
  ADD CONSTRAINT invoice_total_positive 
  CHECK (total_amount > 0);

-- Invoice: dueDate должен быть после или равен billDate
ALTER TABLE invoices 
  ADD CONSTRAINT invoice_dates_valid 
  CHECK (due_date >= bill_date);

-- Invoice: только один из organizationId или personId должен быть заполнен
ALTER TABLE invoices 
  ADD CONSTRAINT invoice_client_type_check 
  CHECK (
    (organization_id IS NOT NULL AND person_id IS NULL) OR
    (organization_id IS NULL AND person_id IS NOT NULL)
  );

-- ComplianceCheck: только один из organizationId или personId должен быть заполнен
ALTER TABLE compliance_checks 
  ADD CONSTRAINT compliance_entity_type_check 
  CHECK (
    (organization_id IS NOT NULL AND person_id IS NULL) OR
    (organization_id IS NULL AND person_id IS NOT NULL)
  );

-- ScheduledPayment: amount должен быть положительным
ALTER TABLE scheduled_payments 
  ADD CONSTRAINT scheduled_payment_amount_positive 
  CHECK (amount > 0);

-- CreditNote: amount должен быть положительным
ALTER TABLE credit_notes 
  ADD CONSTRAINT credit_note_amount_positive 
  CHECK (amount > 0);

-- Claim: amount должен быть положительным
ALTER TABLE claims 
  ADD CONSTRAINT claim_amount_positive 
  CHECK (amount > 0);

-- Claim: reportedDate должен быть после или равен incidentDate
ALTER TABLE claims 
  ADD CONSTRAINT claim_dates_valid 
  CHECK (reported_date >= incident_date);

-- Submission: amount должен быть положительным
ALTER TABLE submissions 
  ADD CONSTRAINT submission_amount_positive 
  CHECK (amount > 0);

-- DealCoverage: все суммы должны быть неотрицательными
ALTER TABLE deal_coverages 
  ADD CONSTRAINT deal_coverage_amounts_non_negative 
  CHECK (
    coverage_amount >= 0 AND
    premium >= 0 AND
    deductible >= 0
  );

-- InvoiceItem: amount должен быть положительным
ALTER TABLE invoice_items 
  ADD CONSTRAINT invoice_item_amount_positive 
  CHECK (amount > 0);

-- InvoiceItem: quantity должна быть положительной
ALTER TABLE invoice_items 
  ADD CONSTRAINT invoice_item_quantity_positive 
  CHECK (quantity > 0);

-- Stage: probability должен быть от 0 до 100
ALTER TABLE stages 
  ADD CONSTRAINT stage_probability_range 
  CHECK (probability >= 0 AND probability <= 100);

-- ExchangeRate: rate должен быть положительным
ALTER TABLE exchange_rates 
  ADD CONSTRAINT exchange_rate_positive 
  CHECK (rate > 0);

-- ExchangeRate: fromCurrency и toCurrency не должны быть одинаковыми
ALTER TABLE exchange_rates 
  ADD CONSTRAINT exchange_rate_different_currencies 
  CHECK (from_currency != to_currency);

-- LeaveApplication: endDate должен быть после или равен startDate
ALTER TABLE leave_applications 
  ADD CONSTRAINT leave_dates_valid 
  CHECK (end_date >= start_date);

-- LeaveApplication: totalDays и totalHours должны быть положительными
ALTER TABLE leave_applications 
  ADD CONSTRAINT leave_duration_positive 
  CHECK (total_days > 0 AND total_hours > 0);

-- Attendance: outTime должен быть после inTime (если заполнен)
ALTER TABLE attendance 
  ADD CONSTRAINT attendance_times_valid 
  CHECK (out_time IS NULL OR out_time > in_time);

-- ============================================
-- КОММЕНТАРИИ
-- ============================================

COMMENT ON CONSTRAINT deal_value_positive ON deals IS 
  'Ensures deal value is always positive';

COMMENT ON CONSTRAINT policy_dates_valid ON policies IS 
  'Ensures policy expiry date is after effective date';

COMMENT ON CONSTRAINT payment_net_amount_calc ON payments IS 
  'Ensures net amount equals amount minus bank commission';

COMMENT ON CONSTRAINT invoice_client_type_check ON invoices IS 
  'Ensures invoice has exactly one client (organization OR person)';

COMMENT ON CONSTRAINT compliance_entity_type_check ON compliance_checks IS 
  'Ensures compliance check is for exactly one entity (organization OR person)';

COMMENT ON CONSTRAINT exchange_rate_different_currencies ON exchange_rates IS 
  'Ensures exchange rate is between two different currencies';

-- =====================================================================
-- Healthcare Benefit Configuration Quality Assurance & Audit Domain
-- Target Schema: benefit_audit
-- Database: sqledu
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS benefit_audit;
SET search_path TO benefit_audit, public;

DROP TABLE IF EXISTS audit_defects CASCADE;
DROP TABLE IF EXISTS audit_cases_tracker CASCADE;
DROP TABLE IF EXISTS audit_auditors CASCADE;
DROP TABLE IF EXISTS claims_adjudicated CASCADE;
DROP TABLE IF EXISTS accumulators_ytd CASCADE;
DROP TABLE IF EXISTS members_eligibility CASCADE;
DROP TABLE IF EXISTS plan_build_config CASCADE;
DROP TABLE IF EXISTS plan_documents_spd CASCADE;

-- ---------------------------------------------------------------------
-- 1. Summary Plan Description (SPD) / Approved Benefit Matrix
-- Ground Truth specifications approved by underwriting / employer group.
-- ---------------------------------------------------------------------
CREATE TABLE plan_documents_spd (
    plan_id SERIAL PRIMARY KEY,
    plan_code VARCHAR(30) NOT NULL UNIQUE,
    plan_name VARCHAR(100) NOT NULL,
    line_of_business VARCHAR(20) NOT NULL CHECK (line_of_business IN ('Medical', 'Dental', 'Vision')),
    funding_type VARCHAR(30) NOT NULL CHECK (funding_type IN ('Self-Funded (ASO)', 'Fully-Insured')),
    network_tier VARCHAR(30) NOT NULL,
    deductible_indiv NUMERIC(10, 2) NOT NULL,
    deductible_family NUMERIC(10, 2) NOT NULL,
    oop_max_indiv NUMERIC(10, 2) NOT NULL,
    oop_max_family NUMERIC(10, 2) NOT NULL,
    coinsurance_member_pct NUMERIC(5, 2) NOT NULL,
    pcp_copay NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    specialist_copay NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    er_copay NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    rx_generic_copay NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    prior_auth_required BOOLEAN NOT NULL DEFAULT TRUE,
    effective_date DATE NOT NULL,
    term_date DATE NOT NULL
);

-- ---------------------------------------------------------------------
-- 2. System Plan Build Configuration (Platform Build)
-- The actual rules built in the core claims engine (Facets, CPBRE, PEX).
-- *NOTE: Contains intentional defects to be detected by audit queries.*
-- ---------------------------------------------------------------------
CREATE TABLE plan_build_config (
    config_id SERIAL PRIMARY KEY,
    plan_id INT NOT NULL REFERENCES plan_documents_spd(plan_id) ON DELETE CASCADE,
    plan_code VARCHAR(30) NOT NULL,
    build_version INT NOT NULL DEFAULT 1,
    configured_deductible_indiv NUMERIC(10, 2) NOT NULL,
    configured_deductible_family NUMERIC(10, 2) NOT NULL,
    configured_oop_max_indiv NUMERIC(10, 2) NOT NULL,
    configured_oop_max_family NUMERIC(10, 2) NOT NULL,
    configured_coinsurance_member_pct NUMERIC(5, 2) NOT NULL,
    configured_pcp_copay NUMERIC(10, 2) NOT NULL,
    configured_specialist_copay NUMERIC(10, 2) NOT NULL,
    configured_er_copay NUMERIC(10, 2) NOT NULL,
    configured_prior_auth_flag BOOLEAN NOT NULL,
    accumulator_rule_code VARCHAR(50) NOT NULL,
    builder_contractor VARCHAR(100) NOT NULL,
    build_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------
-- 3. Plan Build Auditors & Governance Team
-- Offshore audit contractor team + onshore quality leadership.
-- ---------------------------------------------------------------------
CREATE TABLE audit_auditors (
    auditor_id SERIAL PRIMARY KEY,
    auditor_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('Offshore Auditor', 'Senior Offshore Auditor', 'Onshore QA Lead')),
    vendor VARCHAR(50) NOT NULL,
    location VARCHAR(50) NOT NULL,
    tenure_months INT NOT NULL,
    active_status BOOLEAN NOT NULL DEFAULT TRUE
);

-- ---------------------------------------------------------------------
-- 4. Audit Queue & Cases Tracker
-- Workflow queue tracking audit cases, cycle times, SLAs, and First-Pass Yield.
-- ---------------------------------------------------------------------
CREATE TABLE audit_cases_tracker (
    audit_id SERIAL PRIMARY KEY,
    plan_id INT NOT NULL REFERENCES plan_documents_spd(plan_id),
    auditor_id INT NOT NULL REFERENCES audit_auditors(auditor_id),
    work_item_type VARCHAR(50) NOT NULL CHECK (work_item_type IN ('New Group Build', 'Annual Renewal', 'Benefit Amendment', 'Platform Conversion')),
    audit_stage VARCHAR(50) NOT NULL CHECK (audit_stage IN ('Under Review', 'Defects Pending Builder Fix', 'Retest in Progress', 'Approved & Signed Off')),
    audit_received_date DATE NOT NULL,
    audit_completed_date DATE,
    sla_target_days INT NOT NULL DEFAULT 5,
    actual_turnaround_days INT,
    first_pass_yield BOOLEAN NOT NULL DEFAULT TRUE
);

-- ---------------------------------------------------------------------
-- 5. Audit Defect Log & Root Cause Analytics
-- Tracks configuration defects found by auditors, severity, and root cause.
-- ---------------------------------------------------------------------
CREATE TABLE audit_defects (
    defect_id SERIAL PRIMARY KEY,
    audit_id INT NOT NULL REFERENCES audit_cases_tracker(audit_id) ON DELETE CASCADE,
    plan_id INT NOT NULL REFERENCES plan_documents_spd(plan_id),
    auditor_id INT NOT NULL REFERENCES audit_auditors(auditor_id),
    defect_category VARCHAR(60) NOT NULL,
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('Critical', 'Major', 'Minor')),
    root_cause VARCHAR(60) NOT NULL,
    defect_status VARCHAR(30) NOT NULL CHECK (defect_status IN ('Logged', 'Builder Fixing', 'Retest Passed', 'Closed')),
    rejection_count INT NOT NULL DEFAULT 1,
    logged_date DATE NOT NULL,
    resolved_date DATE
);

-- ---------------------------------------------------------------------
-- 6. Members & Eligibility Records
-- ---------------------------------------------------------------------
CREATE TABLE members_eligibility (
    member_id SERIAL PRIMARY KEY,
    subscriber_id VARCHAR(30) NOT NULL,
    family_id VARCHAR(30) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    relationship VARCHAR(20) NOT NULL CHECK (relationship IN ('Subscriber', 'Spouse', 'Dependent')),
    plan_id INT NOT NULL REFERENCES plan_documents_spd(plan_id),
    coverage_start DATE NOT NULL,
    coverage_end DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- ---------------------------------------------------------------------
-- 7. Adjudicated Claims
-- Claims processed against the configuration rules.
-- ---------------------------------------------------------------------
CREATE TABLE claims_adjudicated (
    claim_id SERIAL PRIMARY KEY,
    claim_number VARCHAR(30) NOT NULL UNIQUE,
    member_id INT NOT NULL REFERENCES members_eligibility(member_id),
    plan_id INT NOT NULL REFERENCES plan_documents_spd(plan_id),
    service_date DATE NOT NULL,
    claim_type VARCHAR(30) NOT NULL,
    network_status VARCHAR(20) NOT NULL CHECK (network_status IN ('In-Network', 'Out-of-Network')),
    billed_amount NUMERIC(10, 2) NOT NULL,
    allowed_amount NUMERIC(10, 2) NOT NULL,
    copay_applied NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    deductible_applied NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    coinsurance_applied NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    paid_by_plan NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    prior_auth_obtained BOOLEAN NOT NULL DEFAULT TRUE,
    adjudication_status VARCHAR(20) NOT NULL CHECK (adjudication_status IN ('Paid', 'Denied', 'Adjusted'))
);

-- ---------------------------------------------------------------------
-- 8. Accumulators (Year-to-Date Deductible & OOP Maximums)
-- ---------------------------------------------------------------------
CREATE TABLE accumulators_ytd (
    accum_id SERIAL PRIMARY KEY,
    member_id INT NOT NULL REFERENCES members_eligibility(member_id),
    benefit_year INT NOT NULL,
    accum_type VARCHAR(40) NOT NULL CHECK (accum_type IN ('Individual Deductible', 'Family Deductible', 'Individual OOP Max', 'Family OOP Max')),
    current_balance NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    target_limit NUMERIC(10, 2) NOT NULL,
    is_cap_reached BOOLEAN NOT NULL DEFAULT FALSE,
    last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================================================
-- SEED DATA
-- =====================================================================

-- 1. Summary Plan Descriptions (Approved Ground Truth)
INSERT INTO plan_documents_spd 
(plan_code, plan_name, line_of_business, funding_type, network_tier, deductible_indiv, deductible_family, oop_max_indiv, oop_max_family, coinsurance_member_pct, pcp_copay, specialist_copay, er_copay, rx_generic_copay, prior_auth_required, effective_date, term_date) 
VALUES
('MED-EPO-500', 'Premier Select EPO 500', 'Medical', 'Self-Funded (ASO)', 'Tier 1 In-Network', 500.00, 1000.00, 3000.00, 6000.00, 10.00, 20.00, 40.00, 150.00, 10.00, TRUE, '2026-01-01', '2026-12-31'),
('MED-PPO-1500-INN', 'Choice Plus PPO 1500 INN', 'Medical', 'Fully-Insured', 'Tier 1 In-Network', 1500.00, 3000.00, 6000.00, 12000.00, 20.00, 30.00, 60.00, 250.00, 15.00, TRUE, '2026-01-01', '2026-12-31'),
('MED-PPO-1500-OON', 'Choice Plus PPO 1500 OON', 'Medical', 'Fully-Insured', 'Tier 2 Out-of-Network', 3000.00, 6000.00, 10000.00, 20000.00, 40.00, 0.00, 0.00, 250.00, 0.00, TRUE, '2026-01-01', '2026-12-31'),
('MED-HDHP-3000', 'HSA Advantage HDHP 3000', 'Medical', 'Self-Funded (ASO)', 'Tier 1 In-Network', 3000.00, 6000.00, 5000.00, 10000.00, 20.00, 0.00, 0.00, 0.00, 0.00, TRUE, '2026-01-01', '2026-12-31'),
('MED-HMO-ZERO', 'Community Care HMO Zero', 'Medical', 'Fully-Insured', 'Tier 1 In-Network', 0.00, 0.00, 2500.00, 5000.00, 0.00, 10.00, 25.00, 100.00, 5.00, TRUE, '2026-01-01', '2026-12-31'),
('DEN-PREMIER-50', 'Delta Premier Dental 50', 'Dental', 'Self-Funded (ASO)', 'In-Network', 50.00, 150.00, 1500.00, 4500.00, 20.00, 0.00, 0.00, 0.00, 0.00, FALSE, '2026-01-01', '2026-12-31'),
('DEN-BASIC-100', 'Essential Dental 100', 'Dental', 'Fully-Insured', 'In-Network', 100.00, 300.00, 1000.00, 3000.00, 30.00, 0.00, 0.00, 0.00, 0.00, FALSE, '2026-01-01', '2026-12-31'),
('VIS-EXAM-PLUS', 'Vision Care Exam Plus', 'Vision', 'Fully-Insured', 'In-Network', 0.00, 0.00, 0.00, 0.00, 0.00, 10.00, 10.00, 0.00, 0.00, FALSE, '2026-01-01', '2026-12-31'),
('MED-EXEC-VIP', 'Executive Care VIP 250', 'Medical', 'Self-Funded (ASO)', 'Tier 1 In-Network', 250.00, 500.00, 1500.00, 3000.00, 10.00, 15.00, 30.00, 100.00, 5.00, TRUE, '2026-01-01', '2026-12-31'),
('MED-CATAST-6000', 'Bridge Catastrophic 6000', 'Medical', 'Fully-Insured', 'Tier 1 In-Network', 6000.00, 12000.00, 8550.00, 17100.00, 30.00, 0.00, 0.00, 0.00, 0.00, TRUE, '2026-01-01', '2026-12-31');

-- 2. System Plan Build Configuration (Platform Build)
-- Notice deliberate defects in plan 2 (specialist copay 75 vs 60), plan 4 (er_copay 150 vs 0), plan 6 (deductible 75 vs 50)
INSERT INTO plan_build_config 
(plan_id, plan_code, build_version, configured_deductible_indiv, configured_deductible_family, configured_oop_max_indiv, configured_oop_max_family, configured_coinsurance_member_pct, configured_pcp_copay, configured_specialist_copay, configured_er_copay, configured_prior_auth_flag, accumulator_rule_code, builder_contractor)
VALUES
(1, 'MED-EPO-500', 1, 500.00, 1000.00, 3000.00, 6000.00, 10.00, 20.00, 40.00, 150.00, TRUE, 'ACCUM_COMBINED_MED_RX', 'Builder-Team-A'),
(2, 'MED-PPO-1500-INN', 1, 1500.00, 3000.00, 6000.00, 12000.00, 20.00, 30.00, 75.00, 250.00, TRUE, 'ACCUM_EMBEDDED_DED', 'Builder-Team-B'),  -- DEFECT: Specialist copay $75 vs $60 SPD
(3, 'MED-PPO-1500-OON', 1, 3000.00, 6000.00, 10000.00, 20000.00, 40.00, 0.00, 0.00, 250.00, TRUE, 'ACCUM_CROSS_TIER_ROLLUP', 'Builder-Team-B'),
(4, 'MED-HDHP-3000', 1, 3000.00, 6000.00, 5000.00, 10000.00, 20.00, 0.00, 0.00, 150.00, TRUE, 'ACCUM_AGGREGATE_DED', 'Builder-Team-C'),      -- DEFECT: ER copay $150 vs $0 SPD
(5, 'MED-HMO-ZERO', 1, 0.00, 0.00, 2500.00, 5000.00, 0.00, 10.00, 25.00, 100.00, FALSE, 'ACCUM_ZERO_DED_STANDARD', 'Builder-Team-A'),         -- DEFECT: Prior auth flag FALSE vs TRUE SPD
(6, 'DEN-PREMIER-50', 1, 75.00, 150.00, 1500.00, 4500.00, 20.00, 0.00, 0.00, 0.00, FALSE, 'ACCUM_DENTAL_STANDARD', 'Builder-Team-D'),          -- DEFECT: Indiv Ded $75 vs $50 SPD
(7, 'DEN-BASIC-100', 1, 100.00, 300.00, 1000.00, 3000.00, 30.00, 0.00, 0.00, 0.00, FALSE, 'ACCUM_DENTAL_STANDARD', 'Builder-Team-D'),
(8, 'VIS-EXAM-PLUS', 1, 0.00, 0.00, 0.00, 0.00, 0.00, 10.00, 10.00, 0.00, FALSE, 'ACCUM_VISION_STANDARD', 'Builder-Team-D'),
(9, 'MED-EXEC-VIP', 1, 250.00, 500.00, 1500.00, 3000.00, 10.00, 15.00, 30.00, 100.00, TRUE, 'ACCUM_COMBINED_MED_RX', 'Builder-Team-A'),
(10, 'MED-CATAST-6000', 1, 6000.00, 12000.00, 8550.00, 17100.00, 30.00, 0.00, 0.00, 0.00, TRUE, 'ACCUM_EMBEDDED_DED', 'Builder-Team-C');

-- 3. Audit Team Directory (7 Offshore Contractors + 1 Lead)
INSERT INTO audit_auditors (auditor_name, role, vendor, location, tenure_months) VALUES
('Priya Sharma', 'Offshore Auditor', 'Cognizant', 'Hyderabad', 18),
('Rajesh Kumar', 'Senior Offshore Auditor', 'Cognizant', 'Hyderabad', 36),
('Ananya Patel', 'Offshore Auditor', 'Wipro', 'Chennai', 12),
('Deepak Verma', 'Offshore Auditor', 'Wipro', 'Chennai', 24),
('Siddharth Rao', 'Senior Offshore Auditor', 'Infosys', 'Bangalore', 42),
('Kavita Reddy', 'Offshore Auditor', 'Infosys', 'Bangalore', 9),
('Venkatesh Iyer', 'Offshore Auditor', 'Wipro', 'Chennai', 15),
('Jason Macialek', 'Onshore QA Lead', 'Enterprise QA Core', 'Chesterbrook PA', 60);

-- 4. Audit Cases Tracker (Audit queue & SLA turnaround)
INSERT INTO audit_cases_tracker 
(plan_id, auditor_id, work_item_type, audit_stage, audit_received_date, audit_completed_date, sla_target_days, actual_turnaround_days, first_pass_yield)
VALUES
(1, 1, 'New Group Build', 'Approved & Signed Off', '2026-01-05', '2026-01-08', 5, 3, TRUE),
(2, 2, 'Annual Renewal', 'Defects Pending Builder Fix', '2026-01-06', NULL, 5, 7, FALSE),
(3, 3, 'Annual Renewal', 'Approved & Signed Off', '2026-01-08', '2026-01-12', 5, 4, TRUE),
(4, 4, 'Benefit Amendment', 'Retest in Progress', '2026-01-10', NULL, 5, 6, FALSE),
(5, 5, 'New Group Build', 'Defects Pending Builder Fix', '2026-01-12', NULL, 5, 8, FALSE),
(6, 6, 'Annual Renewal', 'Retest in Progress', '2026-01-15', NULL, 5, 5, FALSE),
(7, 7, 'Platform Conversion', 'Approved & Signed Off', '2026-01-15', '2026-01-19', 5, 4, TRUE),
(8, 1, 'New Group Build', 'Approved & Signed Off', '2026-01-18', '2026-01-21', 5, 3, TRUE),
(9, 2, 'Benefit Amendment', 'Approved & Signed Off', '2026-01-20', '2026-01-24', 5, 4, TRUE),
(10, 3, 'Platform Conversion', 'Approved & Signed Off', '2026-01-22', '2026-01-28', 5, 6, FALSE),
(1, 4, 'Benefit Amendment', 'Approved & Signed Off', '2026-02-01', '2026-02-04', 5, 3, TRUE),
(2, 5, 'Benefit Amendment', 'Approved & Signed Off', '2026-02-03', '2026-02-07', 5, 4, TRUE),
(3, 6, 'Annual Renewal', 'Approved & Signed Off', '2026-02-05', '2026-02-09', 5, 4, TRUE),
(4, 7, 'Annual Renewal', 'Approved & Signed Off', '2026-02-08', '2026-02-12', 5, 4, TRUE),
(5, 1, 'Platform Conversion', 'Under Review', '2026-02-15', NULL, 5, 2, TRUE),
(6, 2, 'New Group Build', 'Approved & Signed Off', '2026-02-16', '2026-02-19', 5, 3, TRUE),
(7, 3, 'New Group Build', 'Approved & Signed Off', '2026-02-18', '2026-02-21', 5, 3, TRUE),
(8, 4, 'Annual Renewal', 'Approved & Signed Off', '2026-02-20', '2026-02-23', 5, 3, TRUE),
(9, 5, 'Annual Renewal', 'Under Review', '2026-02-25', NULL, 5, 1, TRUE),
(10, 6, 'Benefit Amendment', 'Defects Pending Builder Fix', '2026-02-26', NULL, 5, 4, FALSE);

-- 5. Audit Defects Log (Detailed Defect Themes & Root Causes)
INSERT INTO audit_defects 
(audit_id, plan_id, auditor_id, defect_category, severity, root_cause, defect_status, rejection_count, logged_date, resolved_date)
VALUES
(2, 2, 2, 'Copay & Coinsurance Matrix', 'Major', 'Builder Interpretation Error', 'Builder Fixing', 2, '2026-01-08', NULL),
(4, 4, 4, 'Copay & Coinsurance Matrix', 'Major', 'Builder Interpretation Error', 'Retest Passed', 1, '2026-01-12', '2026-01-16'),
(5, 5, 5, 'Authorization & Pre-Cert Rules', 'Critical', 'Specification Change Late Add', 'Builder Fixing', 3, '2026-01-14', NULL),
(6, 6, 6, 'Deductible & OOP Logic', 'Major', 'Matrix Coding Typo', 'Retest Passed', 1, '2026-01-18', '2026-01-21'),
(10, 10, 3, 'Accumulator Mapping & Cross-Accumulation', 'Critical', 'Ambiguous SPD / Document Gap', 'Closed', 2, '2026-01-24', '2026-01-28'),
(2, 2, 2, 'Network Tiering / Provider Network', 'Minor', 'Builder Interpretation Error', 'Closed', 1, '2026-01-09', '2026-01-11'),
(20, 10, 6, 'Deductible & OOP Logic', 'Critical', 'Ambiguous SPD / Document Gap', 'Builder Fixing', 1, '2026-02-27', NULL);

-- 6. Members & Eligibility Records
INSERT INTO members_eligibility 
(subscriber_id, family_id, first_name, last_name, relationship, plan_id, coverage_start, coverage_end, is_active)
VALUES
('SUB-1001', 'FAM-501', 'Robert', 'Miller', 'Subscriber', 1, '2026-01-01', NULL, TRUE),
('SUB-1001', 'FAM-501', 'Mary', 'Miller', 'Spouse', 1, '2026-01-01', NULL, TRUE),
('SUB-1001', 'FAM-501', 'Jacob', 'Miller', 'Dependent', 1, '2026-01-01', NULL, TRUE),
('SUB-1002', 'FAM-502', 'Jennifer', 'Davis', 'Subscriber', 2, '2026-01-01', '2026-02-15', FALSE),  -- Terminated Feb 15
('SUB-1002', 'FAM-502', 'William', 'Davis', 'Spouse', 2, '2026-01-01', '2026-02-15', FALSE),
('SUB-1003', 'FAM-503', 'Michael', 'Johnson', 'Subscriber', 4, '2026-01-01', NULL, TRUE),
('SUB-1003', 'FAM-503', 'Emily', 'Johnson', 'Spouse', 4, '2026-01-01', NULL, TRUE),
('SUB-1004', 'FAM-504', 'Alexander', 'Lee', 'Subscriber', 5, '2026-01-01', NULL, TRUE),
('SUB-1005', 'FAM-505', 'Stephanie', 'Martinez', 'Subscriber', 9, '2026-01-01', NULL, TRUE),
('SUB-1006', 'FAM-506', 'Daniel', 'Taylor', 'Subscriber', 3, '2026-01-01', NULL, TRUE);

-- 7. Adjudicated Claims
-- Notice Claim CLM-8004 is service date 2026-02-28 for Member 4 who was terminated 2026-02-15 (Eligibility Leakage!)
-- Notice Claim CLM-8006 has deductible exceeding individual deductible limit (Accumulator Breach!)
INSERT INTO claims_adjudicated
(claim_number, member_id, plan_id, service_date, claim_type, network_status, billed_amount, allowed_amount, copay_applied, deductible_applied, coinsurance_applied, paid_by_plan, prior_auth_obtained, adjudication_status)
VALUES
('CLM-8001', 1, 1, '2026-01-15', 'Professional', 'In-Network', 350.00, 200.00, 20.00, 0.00, 18.00, 162.00, TRUE, 'Paid'),
('CLM-8002', 1, 1, '2026-01-22', 'Facility Outpatient', 'In-Network', 2500.00, 1800.00, 0.00, 500.00, 130.00, 1170.00, TRUE, 'Paid'),
('CLM-8003', 2, 1, '2026-02-05', 'Professional', 'In-Network', 400.00, 250.00, 40.00, 0.00, 21.00, 189.00, TRUE, 'Paid'),
('CLM-8004', 4, 2, '2026-02-28', 'Professional', 'In-Network', 600.00, 450.00, 30.00, 0.00, 84.00, 336.00, TRUE, 'Paid'),   -- DEFECT: Service date after termination date!
('CLM-8005', 6, 4, '2026-01-18', 'Facility Inpatient', 'In-Network', 12000.00, 9500.00, 0.00, 3000.00, 1300.00, 5200.00, TRUE, 'Paid'),
('CLM-8006', 6, 4, '2026-02-10', 'Professional', 'In-Network', 800.00, 600.00, 0.00, 600.00, 0.00, 0.00, TRUE, 'Paid'),         -- DEFECT: Deductible applied $600 after $3000 max already met!
('CLM-8007', 8, 5, '2026-01-25', 'Professional', 'In-Network', 220.00, 150.00, 10.00, 0.00, 0.00, 140.00, TRUE, 'Paid'),
('CLM-8008', 9, 9, '2026-02-01', 'Facility Inpatient', 'In-Network', 15000.00, 11000.00, 0.00, 250.00, 1075.00, 9675.00, FALSE, 'Paid'); -- DEFECT: Inpatient surgery paid without Prior Auth!

-- 8. Accumulators (YTD)
INSERT INTO accumulators_ytd (member_id, benefit_year, accum_type, current_balance, target_limit, is_cap_reached) VALUES
(1, 2026, 'Individual Deductible', 500.00, 500.00, TRUE),
(1, 2026, 'Individual OOP Max', 668.00, 3000.00, FALSE),
(2, 2026, 'Individual Deductible', 0.00, 500.00, FALSE),
(2, 2026, 'Individual OOP Max', 61.00, 3000.00, FALSE),
(6, 2026, 'Individual Deductible', 3600.00, 3000.00, TRUE),   -- DEFECT: $3600 exceeds $3000 limit!
(6, 2026, 'Individual OOP Max', 4900.00, 5000.00, FALSE),
(8, 2026, 'Individual Deductible', 0.00, 0.00, TRUE),
(8, 2026, 'Individual OOP Max', 10.00, 2500.00, FALSE),
(9, 2026, 'Individual Deductible', 250.00, 250.00, TRUE),
(9, 2026, 'Individual OOP Max', 1325.00, 1500.00, FALSE);

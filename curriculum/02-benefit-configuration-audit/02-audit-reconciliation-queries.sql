-- =====================================================================
-- Healthcare QA: Configuration Validation & Claims Reconciliation Queries
-- Target Schema: benefit_audit
-- Database: sqledu
-- =====================================================================

SET search_path TO benefit_audit, public;

-- ---------------------------------------------------------------------
-- AUDIT 1: SPD Benefit Matrix vs System Configuration Discrepancy Audit
-- Compares the approved Summary Plan Description (ground truth) against
-- what the builder configured in the adjudication engine (Facets/CPBRE).
-- ---------------------------------------------------------------------
SELECT 
    spd.plan_code,
    spd.plan_name,
    cfg.builder_contractor,
    -- Copay Comparisons
    spd.specialist_copay AS spd_specialist_copay,
    cfg.configured_specialist_copay AS cfg_specialist_copay,
    CASE 
        WHEN spd.specialist_copay != cfg.configured_specialist_copay 
        THEN 'MISMATCH: Specialist Copay'
        ELSE 'MATCH' 
    END AS specialist_copay_status,
    -- Deductible Comparisons
    spd.deductible_indiv AS spd_indiv_deductible,
    cfg.configured_deductible_indiv AS cfg_indiv_deductible,
    CASE 
        WHEN spd.deductible_indiv != cfg.configured_deductible_indiv 
        THEN 'MISMATCH: Indiv Deductible'
        ELSE 'MATCH' 
    END AS deductible_status,
    -- Prior Auth Comparisons
    spd.prior_auth_required AS spd_prior_auth,
    cfg.configured_prior_auth_flag AS cfg_prior_auth,
    CASE 
        WHEN spd.prior_auth_required != cfg.configured_prior_auth_flag 
        THEN 'MISMATCH: Prior Auth Flag'
        ELSE 'MATCH' 
    END AS prior_auth_status
FROM plan_documents_spd spd
INNER JOIN plan_build_config cfg ON spd.plan_id = cfg.plan_id
WHERE spd.specialist_copay != cfg.configured_specialist_copay
   OR spd.deductible_indiv != cfg.configured_deductible_indiv
   OR spd.prior_auth_required != cfg.configured_prior_auth_flag
   OR spd.er_copay != cfg.configured_er_copay;

-- ---------------------------------------------------------------------
-- AUDIT 2: Accumulator Boundary Breach (Deductible / OOP Leakage)
-- Identifies member accumulators that exceeded their target plan limit,
-- which indicates a failure in accumulator capping logic.
-- ---------------------------------------------------------------------
SELECT 
    m.member_id,
    m.subscriber_id,
    m.first_name || ' ' || m.last_name AS member_name,
    p.plan_code,
    a.accum_type,
    a.current_balance,
    a.target_limit,
    (a.current_balance - a.target_limit) AS over_accumulated_amount,
    'CRITICAL: Deductible Capping Failure' AS audit_finding
FROM accumulators_ytd a
INNER JOIN members_eligibility m ON a.member_id = m.member_id
INNER JOIN plan_documents_spd p ON m.plan_id = p.plan_id
WHERE a.current_balance > a.target_limit;

-- ---------------------------------------------------------------------
-- AUDIT 3: Eligibility Coverage Leakage
-- Finds claims that were adjudicated and paid where the service date
-- occurred AFTER the member's coverage termination date.
-- ---------------------------------------------------------------------
SELECT 
    c.claim_number,
    m.subscriber_id,
    m.first_name || ' ' || m.last_name AS member_name,
    m.coverage_end AS termination_date,
    c.service_date,
    (c.service_date - m.coverage_end) AS days_after_termination,
    c.paid_by_plan AS financial_leakage_amount,
    c.adjudication_status
FROM claims_adjudicated c
INNER JOIN members_eligibility m ON c.member_id = m.member_id
WHERE m.coverage_end IS NOT NULL 
  AND c.service_date > m.coverage_end
  AND c.adjudication_status = 'Paid';

-- ---------------------------------------------------------------------
-- AUDIT 4: Inpatient Prior Authorization Compliance Leakage
-- Identifies high-cost facility claims that were paid despite missing
-- required pre-authorization.
-- ---------------------------------------------------------------------
SELECT 
    c.claim_number,
    p.plan_code,
    c.claim_type,
    c.service_date,
    c.billed_amount,
    c.paid_by_plan,
    c.prior_auth_obtained,
    spd.prior_auth_required,
    'VIOLATION: Paid Surgery/Inpatient without Pre-Cert' AS audit_flag
FROM claims_adjudicated c
INNER JOIN plan_documents_spd spd ON c.plan_id = spd.plan_id
INNER JOIN plan_build_config p ON c.plan_id = p.plan_id
WHERE spd.prior_auth_required = TRUE 
  AND c.prior_auth_obtained = FALSE 
  AND c.claim_type = 'Facility Inpatient'
  AND c.paid_by_plan > 0;

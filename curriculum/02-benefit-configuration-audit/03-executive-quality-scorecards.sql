-- =====================================================================
-- Healthcare QA: Executive Quality Reporting & Offshore Audit Scorecards
-- Target Schema: benefit_audit
-- Database: sqledu
-- =====================================================================

SET search_path TO benefit_audit, public;

-- ---------------------------------------------------------------------
-- SCORECARD 1: First-Pass Yield (FPY %) by Work Item Type
-- Measures the percentage of plan builds that pass QA on the first review
-- without builder rework or defects.
-- ---------------------------------------------------------------------
SELECT 
    work_item_type,
    COUNT(*) AS total_audits_received,
    COUNT(*) FILTER (WHERE first_pass_yield = TRUE) AS first_pass_clean_builds,
    COUNT(*) FILTER (WHERE first_pass_yield = FALSE) AS builds_with_defects,
    ROUND(
        (COUNT(*) FILTER (WHERE first_pass_yield = TRUE)::NUMERIC / COUNT(*)::NUMERIC) * 100, 
        1
    ) AS first_pass_yield_pct,
    ROUND(AVG(actual_turnaround_days), 1) AS avg_turnaround_days
FROM audit_cases_tracker
GROUP BY work_item_type
ORDER BY first_pass_yield_pct DESC;

-- ---------------------------------------------------------------------
-- SCORECARD 2: Offshore Audit Contractor Vendor Scorecard & SLA Adherence
-- Evaluates contractor productivity, SLA compliance (target <= 5 days),
-- and defect discovery effectiveness across Cognizant, Wipro, and Infosys.
-- ---------------------------------------------------------------------
SELECT 
    a.vendor,
    a.location,
    COUNT(DISTINCT a.auditor_id) AS active_contractors,
    COUNT(c.audit_id) AS total_cases_audited,
    ROUND(AVG(c.actual_turnaround_days), 1) AS avg_cycle_time_days,
    COUNT(*) FILTER (WHERE c.actual_turnaround_days <= c.sla_target_days) AS cases_within_sla,
    ROUND(
        (COUNT(*) FILTER (WHERE c.actual_turnaround_days <= c.sla_target_days)::NUMERIC / COUNT(*)::NUMERIC) * 100,
        1
    ) AS sla_adherence_pct,
    COUNT(d.defect_id) AS total_defects_identified
FROM audit_auditors a
INNER JOIN audit_cases_tracker c ON a.auditor_id = c.auditor_id
LEFT JOIN audit_defects d ON c.audit_id = d.audit_id
WHERE a.role LIKE '%Offshore%'
GROUP BY a.vendor, a.location
ORDER BY sla_adherence_pct DESC;

-- ---------------------------------------------------------------------
-- SCORECARD 3: Defect Theme & Root Cause Pareto Distribution
-- Identifies recurring configuration error categories and underlying
-- drivers to inform training, builder calibrations, and defect prevention.
-- ---------------------------------------------------------------------
SELECT 
    defect_category,
    root_cause,
    COUNT(*) AS defect_occurrence_count,
    COUNT(*) FILTER (WHERE severity = 'Critical') AS critical_severity_count,
    COUNT(*) FILTER (WHERE severity = 'Major') AS major_severity_count,
    COUNT(*) FILTER (WHERE severity = 'Minor') AS minor_severity_count,
    ROUND(AVG(rejection_count), 1) AS avg_rejection_cycles
FROM audit_defects
GROUP BY defect_category, root_cause
ORDER BY defect_occurrence_count DESC, critical_severity_count DESC;

-- ---------------------------------------------------------------------
-- SCORECARD 4: Audit Queue Status & WIP Backlog
-- Executive snapshot of active in-flight audits vs signed-off builds.
-- ---------------------------------------------------------------------
SELECT 
    audit_stage,
    COUNT(*) AS volume,
    ROUND(
        (COUNT(*)::NUMERIC / (SELECT COUNT(*) FROM audit_cases_tracker)::NUMERIC) * 100, 
        1
    ) AS pct_of_total_queue
FROM audit_cases_tracker
GROUP BY audit_stage
ORDER BY volume DESC;

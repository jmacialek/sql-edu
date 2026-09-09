-- =====================================================================
-- Phase 1, Lesson 3: Aggregate Functions, Grouping, and Filtering Buckets
-- Target Schema: foundations
-- =====================================================================

SET search_path TO foundations, public;

-- ---------------------------------------------------------------------
-- 1. Standard Aggregate Functions
-- ---------------------------------------------------------------------
-- Aggregate functions reduce multiple rows into a single summary value.

SELECT 
    COUNT(*) AS total_headcount,
    COUNT(department_id) AS assigned_headcount,        -- Ignores NULLs
    COUNT(DISTINCT department_id) AS distinct_depts,   -- Unique non-null departments
    MIN(salary) AS minimum_salary,
    MAX(salary) AS maximum_salary,
    ROUND(AVG(salary), 2) AS average_salary,
    SUM(salary) AS total_payroll
FROM employees;

-- ---------------------------------------------------------------------
-- 2. Grouping Rows (GROUP BY)
-- ---------------------------------------------------------------------
-- RULE: Any non-aggregate column in the SELECT list MUST appear in the GROUP BY clause.

-- Department-level headcount and payroll summary
SELECT 
    department_id,
    COUNT(*) AS employee_count,
    ROUND(AVG(salary), 2) AS avg_salary,
    SUM(salary) AS total_payroll,
    MIN(salary) AS lowest_salary,
    MAX(salary) AS highest_salary
FROM employees
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY total_payroll DESC;

-- Multi-column Grouping: Department and Active Status
SELECT 
    department_id,
    is_active,
    COUNT(*) AS count,
    ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY department_id, is_active
ORDER BY department_id, is_active;

-- ---------------------------------------------------------------------
-- 3. Filtering Aggregated Buckets (HAVING)
-- ---------------------------------------------------------------------
-- WHERE filters rows BEFORE aggregation.
-- HAVING filters groups AFTER aggregation.

-- Find departments that have at least 3 employees
SELECT 
    department_id,
    COUNT(*) AS headcount
FROM employees
WHERE department_id IS NOT NULL
GROUP BY department_id
HAVING COUNT(*) >= 3;

-- Find departments with an average salary exceeding $150,000
SELECT 
    department_id,
    ROUND(AVG(salary), 2) AS avg_salary,
    COUNT(*) AS staff_count
FROM employees
WHERE is_active = TRUE AND department_id IS NOT NULL
GROUP BY department_id
HAVING AVG(salary) > 150000.00
ORDER BY avg_salary DESC;

-- ---------------------------------------------------------------------
-- 4. Conditional Aggregation with FILTER (Modern PostgreSQL feature)
-- ---------------------------------------------------------------------
-- PostgreSQL supports the ANSI standard FILTER (WHERE ...) clause,
-- which is cleaner and faster than legacy CASE WHEN expressions.

SELECT 
    department_id,
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (WHERE salary >= 150000.00) AS high_earner_count,
    ROUND(AVG(salary) FILTER (WHERE is_active = TRUE), 2) AS active_avg_salary
FROM employees
WHERE department_id IS NOT NULL
GROUP BY department_id;

-- ---------------------------------------------------------------------
-- 📝 Practice Challenges
-- ---------------------------------------------------------------------
-- Challenge 1: Find the average project budget per department for projects
-- that started in the year 2024.
--
-- Challenge 2: Write a query that shows each department's total payroll,
-- but only include departments whose total payroll is greater than $300,000.

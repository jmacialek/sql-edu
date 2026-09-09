-- =====================================================================
-- Phase 1, Lesson 2: Projection, Filtering, and Sorting
-- Target Schema: foundations
-- =====================================================================

SET search_path TO foundations, public;

-- ---------------------------------------------------------------------
-- 1. Projection (SELECT) & Computed Columns
-- ---------------------------------------------------------------------

-- Basic projection of specific attributes
SELECT first_name, last_name, job_title, salary
FROM employees;

-- Column Aliasing & String Concatenation
-- In PostgreSQL, || concatenates strings.
SELECT 
    first_name || ' ' || last_name AS full_name,
    job_title,
    salary,
    ROUND(salary / 12, 2) AS monthly_gross_pay,
    ROUND(salary * 0.10, 2) AS bonus_estimate
FROM employees;

-- ---------------------------------------------------------------------
-- 2. Row Filtering (WHERE clause)
-- ---------------------------------------------------------------------

-- Comparison operators: =, != (<>), <, <=, >, >=
SELECT first_name, last_name, salary
FROM employees
WHERE salary >= 150000.00;

-- Logical Operators: AND, OR, NOT
-- Find active employees in Engineering (department_id = 1) earning over $130,000
SELECT first_name, last_name, job_title, salary
FROM employees
WHERE department_id = 1 
  AND is_active = TRUE 
  AND salary > 130000.00;

-- Range filtering: BETWEEN (inclusive)
SELECT name, budget
FROM departments
WHERE budget BETWEEN 500000.00 AND 1500000.00;

-- Membership checking: IN
-- Find employees who work in Data (2) or Product (3)
SELECT first_name, last_name, department_id, job_title
FROM employees
WHERE department_id IN (2, 3);

-- ---------------------------------------------------------------------
-- 3. Pattern Matching (LIKE and ILIKE)
-- ---------------------------------------------------------------------
-- % matches zero or more characters
-- _ matches exactly one character
-- ILIKE is PostgreSQL's case-insensitive pattern matching operator

-- Find all Engineers (case-insensitive)
SELECT first_name, last_name, job_title
FROM employees
WHERE job_title ILIKE '%engineer%';

-- Find emails matching a specific domain prefix
SELECT email
FROM employees
WHERE email LIKE 's%.com';

-- ---------------------------------------------------------------------
-- 4. Three-Valued Logic & Handling NULLs
-- ---------------------------------------------------------------------
-- CRITICAL RULE: In SQL, NULL = NULL evaluates to UNKNOWN, not TRUE.
-- Always use IS NULL or IS NOT NULL.

-- Find employees who do not have an assigned department
SELECT first_name, last_name, job_title, department_id
FROM employees
WHERE department_id IS NULL;

-- Find employees who do not have a manager (top-level executives)
SELECT first_name, last_name, job_title
FROM employees
WHERE manager_id IS NULL;

-- COALESCE: Returns the first non-null argument
SELECT 
    first_name, 
    last_name, 
    COALESCE(department_id::TEXT, 'Unassigned') AS dept_code
FROM employees;

-- ---------------------------------------------------------------------
-- 5. Sorting & Pagination (ORDER BY, LIMIT, OFFSET)
-- ---------------------------------------------------------------------

-- Top 5 highest-paid active employees
SELECT first_name, last_name, job_title, salary
FROM employees
WHERE is_active = TRUE
ORDER BY salary DESC
LIMIT 5;

-- Sort by multiple criteria: Department ascending, Salary descending
SELECT department_id, first_name, last_name, salary
FROM employees
ORDER BY department_id ASC NULLS LAST, salary DESC;

-- ---------------------------------------------------------------------
-- 📝 Practice Challenges
-- ---------------------------------------------------------------------
-- Challenge 1: Find all employees hired after '2023-01-01' earning at least $100,000,
-- sorted by hire date from newest to oldest.
--
-- Challenge 2: Write a query to list all projects that currently do not have
-- an end date (ongoing projects), displaying project name and budget.

-- =====================================================================
-- Lesson 2: Filtering Rows with WHERE
-- Target Schema: foundations
-- =====================================================================
-- Mental Model:
-- SELECT controls which COLUMNS appear on your screen (left to right).
-- WHERE  controls which ROWS are kept or discarded (top to bottom).
--
-- Think of WHERE as a bouncer at a club door:
-- "Only let in rows where this condition is TRUE."
-- =====================================================================

SET search_path TO foundations, public;

-- ---------------------------------------------------------------------
-- 1. Numeric Comparisons
-- ---------------------------------------------------------------------
-- Common Comparison Operators:
--   =   Equal to
--   !=  Not equal to (or <>)
--   >   Greater than
--   <   Less than
--   >=  Greater than or equal to
--   <=  Less than or equal to
--
-- Notice: Numbers DO NOT use quotation marks!

-- Find all employees earning over $150,000
SELECT first_name, last_name, job_title, salary
FROM employees
WHERE salary > 150000.00;

-- Find departments with a budget of at least $1,000,000
SELECT name, budget, location
FROM departments
WHERE budget >= 1000000.00;

-- Find employees whose department_id is NOT 1 (Engineering)
SELECT first_name, last_name, department_id, job_title
FROM employees
WHERE department_id != 1;

-- ---------------------------------------------------------------------
-- 2. Text / String Comparisons (The Single Quote Rule!)
-- ---------------------------------------------------------------------
-- ⚠️ CRITICAL RULE FOR BEGINNERS:
-- In SQL, text values MUST be wrapped in SINGLE QUOTES ('text').
-- Never use double quotes ("text") for data values! Double quotes are
-- reserved for database object names.
--
-- In PostgreSQL, text comparisons with '=' are CASE-SENSITIVE!
-- 'Engineering' is NOT the same as 'engineering'.

-- Find the department named 'Marketing'
SELECT *
FROM departments
WHERE name = 'Marketing';

-- Find active vs inactive employees using Boolean values (TRUE / FALSE)
SELECT first_name, last_name, job_title, is_active
FROM employees
WHERE is_active = FALSE;

-- ---------------------------------------------------------------------
-- 3. Date Comparisons
-- ---------------------------------------------------------------------
-- Dates are written as text strings in standard format: 'YYYY-MM-DD'.
-- You can compare dates just like numbers:
-- '>' means "after this date", '<' means "before this date".

-- Find employees hired on or after January 1, 2023
SELECT first_name, last_name, hire_date, job_title
FROM employees
WHERE hire_date >= '2023-01-01';

-- Find projects that started before 2024
SELECT name, budget, start_date
FROM projects
WHERE start_date < '2024-01-01';

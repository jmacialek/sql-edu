-- =====================================================================
-- Lesson 4: Sorting (ORDER BY), Limits (LIMIT), & The Mystery of NULL
-- Target Schema: foundations
-- =====================================================================
-- Mental Model:
-- Databases do NOT store data in any guaranteed order.
-- If you want your rows sorted, you MUST tell SQL using ORDER BY.
-- =====================================================================

SET search_path TO foundations, public;

-- ---------------------------------------------------------------------
-- 1. Sorting Rows with ORDER BY
-- ---------------------------------------------------------------------
-- ASC  = Ascending order (lowest to highest, A to Z, oldest date to newest)
--        ASC is the default if you don't specify!
-- DESC = Descending order (highest to lowest, Z to A, newest date to oldest)

-- Sort employees by salary from highest to lowest
SELECT first_name, last_name, job_title, salary
FROM employees
ORDER BY salary DESC;

-- Sort employees alphabetically by last name (A to Z)
SELECT last_name, first_name, job_title
FROM employees
ORDER BY last_name ASC;

-- Sorting by Multiple Columns:
-- First sort by department_id ascending; for people in the same department,
-- sort by salary descending (highest earners in each department first):
SELECT department_id, last_name, first_name, salary
FROM employees
ORDER BY department_id ASC, salary DESC;

-- ---------------------------------------------------------------------
-- 2. Slicing Output with LIMIT
-- ---------------------------------------------------------------------
-- LIMIT restricts the number of rows returned.
-- Combined with ORDER BY, it lets you answer questions like "Top 5" or "Bottom 3".

-- Who are the top 3 highest-paid employees in the entire company?
SELECT first_name, last_name, job_title, salary
FROM employees
ORDER BY salary DESC
LIMIT 3;

-- What are the 2 oldest projects by start date?
SELECT name, start_date, budget
FROM projects
ORDER BY start_date ASC
LIMIT 2;

-- ---------------------------------------------------------------------
-- 3. The Mystery of NULL (Missing Data)
-- ---------------------------------------------------------------------
-- 🧠 KEY CONCEPT:
-- NULL is NOT the number zero (0).
-- NULL is NOT an empty space or blank text ('').
-- NULL means: "UNKNOWN, UNASSIGNED, or MISSING".
--
-- Because NULL means "unknown", it CANNOT equal anything:
-- NULL = NULL is NOT TRUE; it evaluates to UNKNOWN!
--
-- ⚠️ NEVER write: WHERE column = NULL  (This returns 0 rows every time!)
-- ✅ ALWAYS write: WHERE column IS NULL or WHERE column IS NOT NULL

-- Find employees who do NOT have an assigned department:
SELECT first_name, last_name, job_title, department_id
FROM employees
WHERE department_id IS NULL;

-- Find employees who do NOT have a manager (Top-level leadership):
SELECT first_name, last_name, job_title, manager_id
FROM employees
WHERE manager_id IS NULL;

-- Find projects that are currently ONGOING (their end_date is NULL / not set):
SELECT name, budget, start_date, end_date
FROM projects
WHERE end_date IS NULL;

-- ---------------------------------------------------------------------
-- 4. Replacing NULLs with COALESCE
-- ---------------------------------------------------------------------
-- The COALESCE function checks a column and replaces any NULL with a fallback value.
-- This makes reports look clean and readable for humans.

SELECT 
    first_name, 
    last_name, 
    job_title,
    COALESCE(department_id::TEXT, 'Unassigned / Contractor') AS department_display,
    COALESCE(manager_id::TEXT, 'No Manager (Executive)') AS manager_status
FROM employees;

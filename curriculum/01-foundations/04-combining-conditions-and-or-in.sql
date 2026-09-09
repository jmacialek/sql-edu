-- =====================================================================
-- Lesson 3: Combining Conditions — AND, OR, IN, BETWEEN, & ILIKE
-- Target Schema: foundations
-- =====================================================================
-- Mental Model:
-- What happens when you want to filter on MULTIPLE rules at the same time?
--   AND = "Both rule 1 AND rule 2 must be true" (More restrictive)
--   OR  = "Either rule 1 OR rule 2 can be true" (More permissive)
-- =====================================================================

SET search_path TO foundations, public;

-- ---------------------------------------------------------------------
-- 1. Using AND (Strict Matching)
-- ---------------------------------------------------------------------
-- Find employees who are ACTIVE AND work in Department 1 (Engineering)
SELECT first_name, last_name, job_title, salary
FROM employees
WHERE is_active = TRUE 
  AND department_id = 1;

-- Find employees who earn at least $120,000 AND were hired in 2022
SELECT first_name, last_name, hire_date, salary
FROM employees
WHERE salary >= 120000.00 
  AND hire_date >= '2022-01-01' 
  AND hire_date <= '2022-12-31';

-- ---------------------------------------------------------------------
-- 2. Using OR (Flexible Matching)
-- ---------------------------------------------------------------------
-- Find departments located in 'New York' OR 'San Francisco'
SELECT name, budget, location
FROM departments
WHERE location = 'New York' 
   OR location = 'San Francisco';

-- ---------------------------------------------------------------------
-- 3. The Power of Parentheses () — Avoiding Logic Bugs
-- ---------------------------------------------------------------------
-- ⚠️ BIGGEST BEGINNER TRAP:
-- In SQL, AND is evaluated BEFORE OR (just like multiplication before addition).
-- Always wrap OR conditions in parentheses so SQL knows exactly what you mean!

-- Goal: Find all active employees who work in either Dept 1 OR Dept 2:
-- CORRECT:
SELECT first_name, last_name, department_id, is_active
FROM employees
WHERE is_active = TRUE 
  AND (department_id = 1 OR department_id = 2);

-- ---------------------------------------------------------------------
-- 4. Clean Shortcut #1: The IN Operator
-- ---------------------------------------------------------------------
-- Instead of writing: department_id = 1 OR department_id = 2 OR department_id = 4
-- You can write:      department_id IN (1, 2, 4)
-- This is much cleaner and easier to read.

SELECT first_name, last_name, department_id, job_title
FROM employees
WHERE department_id IN (1, 2, 4);

-- You can also use NOT IN to exclude a list:
SELECT first_name, last_name, department_id
FROM employees
WHERE department_id NOT IN (1, 2);

-- ---------------------------------------------------------------------
-- 5. Clean Shortcut #2: The BETWEEN Operator
-- ---------------------------------------------------------------------
-- BETWEEN checks if a number or date falls inside an inclusive range.
-- "salary BETWEEN 100000 AND 150000" means: salary >= 100000 AND salary <= 150000.

SELECT first_name, last_name, salary
FROM employees
WHERE salary BETWEEN 100000.00 AND 160000.00;

-- ---------------------------------------------------------------------
-- 6. Searching for Text Patterns: LIKE and ILIKE
-- ---------------------------------------------------------------------
-- What if you don't know the exact spelling, or want to search for keywords?
-- In SQL, '%' means "match any number of characters".
--
-- LIKE  = Case-sensitive pattern search
-- ILIKE = Case-insensitive pattern search (PostgreSQL feature)

-- Find all jobs with 'Engineer' anywhere in the title (case-insensitive)
SELECT first_name, last_name, job_title
FROM employees
WHERE job_title ILIKE '%engineer%';

-- Find all jobs that start with 'Lead' or 'Senior'
SELECT first_name, last_name, job_title
FROM employees
WHERE job_title ILIKE 'Lead%' 
   OR job_title ILIKE 'Senior%';

-- Find all email addresses that end with '@example.com'
SELECT first_name, last_name, email
FROM employees
WHERE email LIKE '%@example.com';

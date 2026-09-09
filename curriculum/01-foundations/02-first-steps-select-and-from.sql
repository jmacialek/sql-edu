-- =====================================================================
-- Lesson 1: Your First SQL Queries — SELECT & FROM
-- Target Schema: foundations
-- =====================================================================
-- Mental Model:
-- Think of a table as a spreadsheet tab.
-- Each row is a single record (e.g. one employee).
-- Each column is a specific attribute (e.g. first_name, salary).
--
-- In SQL:
--   SELECT tells the database: "Show me these columns"
--   FROM   tells the database: "Look in this table"
-- =====================================================================

-- Step 1: Tell PostgreSQL which schema to look in by default
SET search_path TO foundations, public;

-- ---------------------------------------------------------------------
-- 1. Exploring an Entire Table with SELECT *
-- ---------------------------------------------------------------------
-- The asterisk (*) is a wildcard that means "give me every column".
-- In school or when exploring a new database, this is the very first
-- command you run to see what the data looks like.

SELECT * 
FROM employees;

SELECT * 
FROM departments;

SELECT * 
FROM projects;

-- ---------------------------------------------------------------------
-- 2. Selecting Specific Columns (Projection)
-- ---------------------------------------------------------------------
-- In real work, tables might have 50+ columns and millions of rows.
-- Requesting only the columns you actually need is faster and cleaner.
-- Separate column names with commas.

SELECT first_name, last_name, job_title, salary
FROM employees;

-- You can change the order of columns in your SELECT statement:
SELECT job_title, salary, first_name, last_name
FROM employees;

-- ---------------------------------------------------------------------
-- 3. Renaming Columns in Your Output with "AS" (Aliasing)
-- ---------------------------------------------------------------------
-- Sometimes raw database column names are cryptic (e.g. "dept_id", "amt").
-- You can rename any column in the output using the "AS" keyword.
-- Note: This does NOT rename the column in the database; it only changes
-- how the header appears in your results.

SELECT 
    first_name AS employee_first_name,
    last_name AS employee_last_name,
    salary AS annual_salary
FROM employees;

-- ---------------------------------------------------------------------
-- 4. Simple Math / Computed Columns
-- ---------------------------------------------------------------------
-- You can perform calculations directly in the SELECT clause.
-- Common math operators: + (add), - (subtract), * (multiply), / (divide)

SELECT 
    first_name, 
    last_name, 
    salary,
    ROUND(salary / 12, 2) AS monthly_salary,
    ROUND(salary * 0.10, 2) AS ten_percent_bonus
FROM employees;

-- ---------------------------------------------------------------------
-- 💡 Beginner Tip: Semicolons and Capitalization
-- ---------------------------------------------------------------------
-- 1. Semicolon (;): Tells the database "this query is finished". Always
--    end your SQL queries with a semicolon.
-- 2. Capitalization: SQL keywords (SELECT, FROM, AS) are usually written
--    in UPPERCASE by convention, while column and table names are lowercase.
--    This makes your code much easier to read!

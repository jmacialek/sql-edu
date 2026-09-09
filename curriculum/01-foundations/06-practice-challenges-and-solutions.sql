-- =====================================================================
-- Phase 1: Hands-On Practice Challenges
-- Target Schema: foundations
-- =====================================================================
-- Instructions:
-- Try to write the query for each challenge on your own in DBeaver!
-- Once you have tried, scroll down to the bottom of this file to check
-- your answer against the official solution.
-- =====================================================================

SET search_path TO foundations, public;

-- ---------------------------------------------------------------------
-- 🎯 CHALLENGE 1: The High Earner Filter
-- Write a query to display the first name, last name, job title, and salary
-- for all employees who earn $140,000 or more per year.
-- ---------------------------------------------------------------------
-- YOUR CODE HERE:




-- ---------------------------------------------------------------------
-- 🎯 CHALLENGE 2: Finding Specific Locations
-- Write a query to find all departments located in either 'New York' OR 'Chicago'.
-- Display the department name and location. (Hint: Try using IN!)
-- ---------------------------------------------------------------------
-- YOUR CODE HERE:




-- ---------------------------------------------------------------------
-- 🎯 CHALLENGE 3: Recent Hires with High Compensation
-- Find all employees who were hired on or after '2023-01-01' AND earn
-- at least $100,000. Display first_name, last_name, hire_date, and salary.
-- Sort the result by hire_date from newest to oldest.
-- ---------------------------------------------------------------------
-- YOUR CODE HERE:




-- ---------------------------------------------------------------------
-- 🎯 CHALLENGE 4: The Keyword Search
-- Write a query to find all employees whose job title contains the word
-- 'Data' or 'Product' (case-insensitive).
-- ---------------------------------------------------------------------
-- YOUR CODE HERE:




-- ---------------------------------------------------------------------
-- 🎯 CHALLENGE 5: The Incomplete Project Audit
-- Write a query to list all projects that currently do not have an end date
-- (meaning they are actively ongoing).
-- Show the project name, budget, and start date.
-- Sort the results by budget from highest to lowest.
-- ---------------------------------------------------------------------
-- YOUR CODE HERE:




-- ---------------------------------------------------------------------
-- 🎯 CHALLENGE 6: The Executive Leaderboard
-- Find the top 3 highest-earning employees who have an assigned manager
-- (meaning exclude the top executives whose manager_id IS NULL).
-- ---------------------------------------------------------------------
-- YOUR CODE HERE:







-- =====================================================================
-- 📖 OFFICIAL SOLUTIONS KEY (Scroll down after attempting!)
-- =====================================================================

-- SOLUTION 1:
SELECT first_name, last_name, job_title, salary
FROM employees
WHERE salary >= 140000.00;

-- SOLUTION 2:
SELECT name, location
FROM departments
WHERE location IN ('New York', 'Chicago');

-- SOLUTION 3:
SELECT first_name, last_name, hire_date, salary
FROM employees
WHERE hire_date >= '2023-01-01' 
  AND salary >= 100000.00
ORDER BY hire_date DESC;

-- SOLUTION 4:
SELECT first_name, last_name, job_title
FROM employees
WHERE job_title ILIKE '%data%' 
   OR job_title ILIKE '%product%';

-- SOLUTION 5:
SELECT name, budget, start_date
FROM projects
WHERE end_date IS NULL
ORDER BY budget DESC;

-- SOLUTION 6:
SELECT first_name, last_name, job_title, salary
FROM employees
WHERE manager_id IS NOT NULL
ORDER BY salary DESC
LIMIT 3;

-- =====================================================================
-- Phase 1: SQL Foundations - Schema & Seed Script
-- Database: sqledu
-- Target Schema: foundations
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS foundations;
SET search_path TO foundations, public;

-- Clean slate within the schema
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS projects CASCADE;

-- 1. Departments Table
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    budget NUMERIC(12, 2) NOT NULL CHECK (budget >= 0),
    location VARCHAR(100) NOT NULL
);

-- 2. Employees Table
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    department_id INT REFERENCES departments(department_id) ON DELETE SET NULL,
    job_title VARCHAR(100) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL CHECK (salary > 0),
    hire_date DATE NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    manager_id INT REFERENCES employees(employee_id) ON DELETE SET NULL
);

-- 3. Projects Table
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    budget NUMERIC(12, 2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    department_id INT REFERENCES departments(department_id) ON DELETE CASCADE
);

-- =====================================================================
-- Seed Data
-- =====================================================================

INSERT INTO departments (name, budget, location) VALUES
('Engineering', 2500000.00, 'New York'),
('Data & Analytics', 1200000.00, 'San Francisco'),
('Product', 850000.00, 'New York'),
('Marketing', 600000.00, 'Austin'),
('Human Resources', 400000.00, 'Chicago');

-- Insert Leadership / Senior Employees (No Managers initially)
INSERT INTO employees (first_name, last_name, email, department_id, job_title, salary, hire_date, is_active, manager_id) VALUES
('Sarah', 'Connor', 'sarah.connor@example.com', 1, 'VP of Engineering', 240000.00, '2021-01-15', TRUE, NULL),
('Marcus', 'Vance', 'marcus.vance@example.com', 2, 'Head of Data', 210000.00, '2021-03-01', TRUE, NULL),
('Elena', 'Rostova', 'elena.rostova@example.com', 3, 'VP of Product', 195000.00, '2021-06-15', TRUE, NULL);

-- Insert Staff Employees (Referencing Managers)
INSERT INTO employees (first_name, last_name, email, department_id, job_title, salary, hire_date, is_active, manager_id) VALUES
('David', 'Chen', 'david.chen@example.com', 1, 'Principal Software Engineer', 185000.00, '2022-02-10', TRUE, 1),
('Aaliyah', 'Patel', 'aaliyah.patel@example.com', 1, 'Senior Backend Engineer', 155000.00, '2022-08-01', TRUE, 4),
('Liam', 'O''Connor', 'liam.oconnor@example.com', 1, 'Software Engineer', 125000.00, '2023-04-15', TRUE, 4),
('Maya', 'Lin', 'maya.lin@example.com', 2, 'Lead Data Engineer', 175000.00, '2022-05-12', TRUE, 2),
('Carlos', 'Mendoza', 'carlos.mendoza@example.com', 2, 'Senior Data Analyst', 135000.00, '2023-01-20', TRUE, 7),
('Zoe', 'Kaufman', 'zoe.kaufman@example.com', 2, 'Data Analyst', 98000.00, '2024-02-01', TRUE, 7),
('James', 'Wilson', 'james.wilson@example.com', 3, 'Senior Product Manager', 160000.00, '2022-11-01', TRUE, 3),
('Sophia', 'Taylor', 'sophia.taylor@example.com', 3, 'Product Designer', 115000.00, '2023-07-15', TRUE, 10),
('Lucas', 'Silva', 'lucas.silva@example.com', 4, 'Marketing Director', 145000.00, '2022-09-01', TRUE, NULL),
('Emma', 'Watson', 'emma.watson@example.com', 4, 'Growth Specialist', 88000.00, '2024-05-10', TRUE, 12),
('Benjamin', 'Wright', 'benjamin.wright@example.com', 5, 'HR Director', 130000.00, '2021-08-20', TRUE, NULL),
('Olivia', 'Davis', 'olivia.davis@example.com', NULL, 'Contract Consultant', 140000.00, '2025-01-10', FALSE, NULL);

-- Insert Projects
INSERT INTO projects (name, budget, start_date, end_date, department_id) VALUES
('Data Lakehouse Modernization', 450000.00, '2024-01-01', '2024-12-31', 2),
('Microservices Migration', 750000.00, '2023-06-01', '2024-09-30', 1),
('Self-Serve BI Portal', 200000.00, '2024-03-15', NULL, 2),
('Brand Re-platforming', 350000.00, '2024-04-01', '2024-11-15', 4),
('Mobile App Redesign', 500000.00, '2024-02-01', NULL, 3);

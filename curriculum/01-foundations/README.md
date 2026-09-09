# Phase 1: Absolute Beginner SQL Foundations — The Zero-Experience Primer

**Welcome to your first step in SQL!** 

This module is designed specifically for someone who has **never written a line of SQL before**. There are no assumptions of prior programming knowledge, no unnecessary jargon, and every concept is broken down with simple visual analogies.

---

## 🧠 Part 1: The Mental Model (Before Writing Any Code)

### What is a Database?
Think of a database as an **Excel Workbook**. 
* Inside an Excel workbook, you have multiple tabs or spreadsheets.
* In a relational database, each spreadsheet tab is called a **Table**.

```
Database: sqledu (Workbook)
├── Table: employees   (Sheet 1: 15 employee records)
├── Table: departments (Sheet 2: 5 department records)
└── Table: projects    (Sheet 3: 5 project records)
```

### Rows vs. Columns
Look at any table:
* **Rows (Records)**: Run horizontally (left to right). Each row represents **one single item** (e.g. one specific employee, one hospital claim).
* **Columns (Fields / Attributes)**: Run vertically (top to bottom). Each column represents **one piece of information** about that item (e.g. `first_name`, `salary`, `hire_date`).

```
           COLUMN: first_name      COLUMN: salary
                │                        │
                ▼                        ▼
┌──────────────┬────────────────────────┬─────────────┐
│ employee_id  │ first_name  last_name  │ salary      │
├──────────────┼────────────────────────┼─────────────┤
│ 1            │ Sarah       Connor     │ 240000.00   │ ◄── ROW 1 (One Person)
│ 2            │ Marcus      Vance      │ 210000.00   │ ◄── ROW 2 (Another Person)
│ 3            │ David       Chen       │ 185000.00   │ ◄── ROW 3 (Another Person)
└──────────────┴────────────────────────┴─────────────┘
```

### What is SQL?
**SQL** stands for *Structured Query Language*. 
Unlike programming languages like Python or C (which tell the computer step-by-step *how* to calculate something), SQL is **declarative**:
> **You simply tell the database WHAT you want, and the database engine figures out HOW to retrieve it.**

In plain English, every basic SQL query is just a sentence:
> *"Show me (`SELECT`) the names and salaries from (`FROM`) the employees table where (`WHERE`) they earn more than $100,000, sorted (`ORDER BY`) from highest to lowest."*

---

## 📚 Part 2: The Core SQL Vocabulary

### 1. `SELECT` (The "Show Me" command)
Tells the database which **columns** you want to display on your screen.
* `SELECT first_name, salary` = Only show me these two columns.
* `SELECT *` = The asterisk `*` is a wildcard meaning "Show me **every** column in the table".

### 2. `FROM` (The "Look in this table" command)
Tells the database which table holds the data.
* `FROM employees;` = Look in the table named `employees`.

### 3. `WHERE` (The Bouncer / Filter)
Tells the database to only keep **rows** that meet a specific condition.
* `WHERE salary > 100000` = Only keep people making more than $100k.
* `WHERE job_title = 'Software Engineer'` = Only keep exact matches.
* *Rule*: Text values **must** be inside single quotes (`'Engineering'`). Numbers do not use quotes (`100000`).

### 4. `ORDER BY` (The Organizer)
Sorts your output.
* `ORDER BY salary DESC` = Highest to lowest (Descending).
* `ORDER BY salary ASC`  = Lowest to highest (Ascending, the default).

### 5. `LIMIT` (The Cap)
Controls how many rows appear on your screen.
* `LIMIT 5` = Only give me the first 5 rows (great for "Top 5" lists).

---

## 📂 Step-by-Step Hands-on Lessons

Open DBeaver, press `Ctrl + O`, and open these lesson files directly from `~/repos/sql-edu/curriculum/01-foundations/`:

| Lesson | Script File | What You Will Learn |
| :---: | :--- | :--- |
| **Setup** | [**`01-schema-and-seed.sql`**](01-schema-and-seed.sql) | Creates the `foundations` schema and loads sample data. *(Already executed on your server!)* |
| **01** | [**`02-first-steps-select-and-from.sql`**](02-first-steps-select-and-from.sql) | Exploring tables with `SELECT *`, choosing specific columns, and renaming column headers with `AS`. |
| **02** | [**`03-filtering-rows-with-where.sql`**](03-filtering-rows-with-where.sql) | The `WHERE` filter: comparing numbers (`>`, `<`, `=`), matching text with `'single quotes'`, and filtering dates. |
| **03** | [**`04-combining-conditions-and-or-in.sql`**](04-combining-conditions-and-or-in.sql) | Multi-rule filtering with `AND`, `OR`, list matching with `IN`, range checking with `BETWEEN`, and text searching with `ILIKE`. |
| **04** | [**`05-sorting-limiting-and-nulls.sql`**](05-sorting-limiting-and-nulls.sql) | Sorting with `ORDER BY`, finding Top 3 with `LIMIT`, and understanding what `NULL` (missing data) really means. |
| **05** | [**`06-practice-challenges-and-solutions.sql`**](06-practice-challenges-and-solutions.sql) | 6 real practice challenges to test yourself, with full official solutions included at the bottom. |

---

## ⚠️ The 5 Most Common Beginner Mistakes (And How to Avoid Them)

1. **Using Double Quotes for Text**:
   * ❌ `WHERE job_title = "Engineer"` *(Double quotes mean table or column name in SQL!)*
   * ✅ `WHERE job_title = 'Engineer'` *(Single quotes are for data values!)*
2. **Missing Commas Between Columns**:
   * ❌ `SELECT first_name last_name salary FROM employees;` *(SQL thinks you are renaming `first_name`!)*
   * ✅ `SELECT first_name, last_name, salary FROM employees;` *(Always separate columns with commas!)*
3. **Trying to test `NULL` with an Equals Sign**:
   * ❌ `WHERE manager_id = NULL` *(This will ALWAYS return 0 rows because nothing equals unknown!)*
   * ✅ `WHERE manager_id IS NULL` *(Always use `IS NULL` or `IS NOT NULL`!)*
4. **Putting Clauses in the Wrong Order**:
   * SQL requires clauses in a strict grammar order:
     1. `SELECT`
     2. `FROM`
     3. `WHERE`
     4. `ORDER BY`
     5. `LIMIT`
5. **Forgetting the Semicolon `;`**:
   * Always end your queries with a semicolon `;` so the database knows you are done.

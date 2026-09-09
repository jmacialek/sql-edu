<div align="center">

# 🏛️ SQL-Edu: Relational Data Engineering & Healthcare QA Audit Laboratory

**A structured, hands-on SQL laboratory and executive portfolio specializing in database query design, data reconciliation, and healthcare benefit configuration audit governance.**

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18.x-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Metabase](https://img.shields.io/badge/Web%20BI-Metabase-509EE3?style=for-the-badge&logo=metabase&logoColor=white)](https://www.metabase.com/)
[![DBeaver](https://img.shields.io/badge/Desktop%20IDE-DBeaver%20CE-382923?style=for-the-badge&logo=dbeaver&logoColor=white)](https://dbeaver.io/)
[![Status](https://img.shields.io/badge/Status-Active%20Laboratory-success?style=for-the-badge)](#-curriculum-roadmap--portfolio-modules)

</div>

---

## 📖 Overview & Purpose

**`sql-edu`** documents the application of relational database engineering to real-world healthcare quality assurance, data reconciliation, and executive governance. 

This repository models complex benefit structures, audits claims adjudication logic, identifies accumulator leakage, and tracks offshore audit contractor performance scorecards using **PostgreSQL 18**, **Metabase BI**, and **DBeaver**.

---

## 🏗️ Architecture & Tooling Topology

```mermaid
graph LR
    subgraph Client ["Analytical Interfaces"]
        Browser["Web Browser (Metabase Executive Dashboards)"]
        DBeaver["DBeaver Community (Desktop IDE & ER Models)"]
        CLI["pgcli / psql (CLI REPL & Automated Scripts)"]
    end

    subgraph Engine ["PostgreSQL Relational Engine"]
        PG["PostgreSQL Cluster (:5432)"]
        
        subgraph Schemas ["Database: sqledu"]
            S1["foundations (Syntax, Projections, & Aggregations)"]
            S2["benefit_audit (Plan Build QA & Governance)"]
        end
        
        PG --> S1
        PG --> S2
    end

    Browser -->|"HTTP (:3000)"| Engine
    DBeaver -->|"JDBC (:5432)"| Engine
    CLI -->|"libpq (:5432)"| Engine
```

---

## 🚀 Quick Connect & Access

| Interface | Access Method | Documentation |
| :--- | :--- | :--- |
| **Metabase BI Portal** | Web Browser (`http://localhost:3000`) | [**`docs/02-metabase-setup.md`**](docs/02-metabase-setup.md) |
| **DBeaver Community** | Desktop GUI (JDBC) | [**`docs/01-connection-guide.md`**](docs/01-connection-guide.md) |
| **Interactive Terminal** | `pgcli -h <host> -U <user> -d sqledu` | [**`docs/01-connection-guide.md`**](docs/01-connection-guide.md) |

---

## 🗺️ Curriculum Roadmap & Portfolio Modules

| Phase | Module & Focus | Topics & Technical Capabilities | Status |
| :---: | :--- | :--- | :---: |
| **01** | [**SQL Foundations & Core Syntax**](curriculum/01-foundations/README.md) | Logical execution order, projection, `WHERE` filtering, 3VL `NULL` logic, `GROUP BY`, `HAVING`, and aggregate functions. | ![Complete](https://img.shields.io/badge/Complete-brightgreen) |
| **02** | [**Healthcare Plan Build Quality & Audit**](curriculum/02-benefit-configuration-audit/README.md) | SPD matrix validation, accumulator boundary over-accumulation, post-termination claims leakage, offshore vendor SLA tracking, and First-Pass Yield (FPY %). | ![Active](https://img.shields.io/badge/Active-brightgreen) |
| **03** | **Advanced Joins & Relational Integrity** | Multi-table joins, anti-joins for discrepancy detection, self-joins, cross joins for benefit tier matrix permutation. | ![Planned](https://img.shields.io/badge/Planned-lightgrey) |
| **04** | **Subqueries, CTEs & Recursive Hierarchies** | Correlated subqueries, Common Table Expressions, recursive hierarchy traversals (reporting trees, benefit riders). | ![Planned](https://img.shields.io/badge/Planned-lightgrey) |
| **05** | **Window Functions & Trend Analysis** | `OVER()`, `PARTITION BY`, `ROW_NUMBER()`, `RANK()`, `LEAD()`, `LAG()`, rolling 30-day defect trends, cumulative claims spend. | ![Planned](https://img.shields.io/badge/Planned-lightgrey) |
| **06** | **Performance Tuning & Query Execution Plans** | `EXPLAIN (ANALYZE, BUFFERS)`, indexing strategies (B-Tree, GIN, Partial Indexes), join cost optimization. | ![Planned](https://img.shields.io/badge/Planned-lightgrey) |

---

## 🏥 Healthcare QA Audit Scenarios Modeled

The [**`curriculum/02-benefit-configuration-audit/`**](curriculum/02-benefit-configuration-audit/) laboratory contains real-world audit SQL queries matching payer & TPA configuration QA:

1. **SPD vs System Configuration Discrepancy Audit**:
   Automated reconciliation comparing approved Summary Plan Descriptions against platform configuration (detecting specialist copay drifts, deductible mismatches, and disabled prior-auth flags).
2. **Accumulator Capping & Boundary Audits**:
   Identifying member claims adjudicating past their individual/family deductible or Out-of-Pocket (OOP) maximum.
3. **Eligibility Coverage Leakage Audits**:
   Detecting paid claims with service dates occurring after coverage termination dates.
4. **Offshore Vendor Governance & Scorecards**:
   Measuring First-Pass Yield (FPY %), average turnaround days, and SLA adherence across offshore audit contractors (Cognizant, Wipro, Infosys).

---

## 📂 Repository Layout

```
sql-edu/
├── README.md                                  # Executive laboratory & portfolio showcase
├── docs/                                      # Configuration & client connection guides
│   ├── 01-connection-guide.md                 # DBeaver, pgcli, and psql setup
│   └── 02-metabase-setup.md                   # Metabase BI Portal configuration
└── curriculum/                                # Progressive, hands-on SQL curriculum
    ├── 01-foundations/                        # Phase 1: Core syntax & aggregations
    │   ├── README.md
    │   ├── 01-schema-and-seed.sql
    │   ├── 02-queries-and-filtering.sql
    │   └── 03-aggregations-and-grouping.sql
    └── 02-benefit-configuration-audit/        # Phase 2: Healthcare Plan Build QA
        ├── README.md
        ├── 01-healthcare-schema-and-seed.sql  # Plan documents, claims, & audit tables
        ├── 02-audit-reconciliation-queries.sql# Mismatch audits & accumulator leakage
        └── 03-executive-quality-scorecards.sql# FPY %, SLA adherence, & Pareto root cause
```

---

## 📜 License & Standards

- Distributed under the **MIT License**.
- Follows standard **ANSI SQL** conventions and PostgreSQL best practices.

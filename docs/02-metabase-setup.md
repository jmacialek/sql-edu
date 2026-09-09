# Metabase Business Intelligence Portal Guide

Reference instructions for deploying and configuring Metabase as an executive quality dashboard for database analytics.

---

## 1. Accessing the Metabase Portal

* **URL**: `http://localhost:3000` (or `http://<server-host>:3000`)
* **Default Port**: `3000`
* **Application Storage**: PostgreSQL metadata repository

---

## 2. Initial Setup Walkthrough

When launching Metabase for the first time:

1. Click **Let's get started**.
2. **Set up the Administrator Account**:
   * Enter your name, email, and administrative password.
3. **Connect to Your Database**:
   * **Database type**: `PostgreSQL`
   * **Display name**: `sql-edu`
   * **Host**: `<database-host>` (or `localhost`)
   * **Port**: `5432`
   * **Database name**: `sqledu`
   * **Database username**: `<database-username>`
   * **Database password**: `<database-password>`
4. Click **Connect database** -> **Take me to Metabase**.

---

## 3. Creating Executive Quality & Audit Dashboards

To transform SQL validation queries into visual dashboard cards:

1. Click **+ New** -> **SQL query**.
2. Select the `sql-edu` database.
3. Paste any scorecard query from [`curriculum/02-benefit-configuration-audit/03-executive-quality-scorecards.sql`](../curriculum/02-benefit-configuration-audit/03-executive-quality-scorecards.sql):
   ```sql
   SELECT 
       work_item_type,
       ROUND((COUNT(*) FILTER (WHERE first_pass_yield = TRUE)::NUMERIC / COUNT(*)::NUMERIC) * 100, 1) AS fpy_pct,
       ROUND(AVG(actual_turnaround_days), 1) AS avg_turnaround_days
   FROM benefit_audit.audit_cases_tracker
   GROUP BY work_item_type
   ORDER BY fpy_pct DESC;
   ```
4. Execute the query and choose a visualization (e.g. **Bar chart**, **Progress / Gauge**, or **Data Table**).
5. Save the card to an executive dashboard titled **"Plan Build Quality & Defect Governance"**.

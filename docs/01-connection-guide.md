# Database Connection & Tooling Guide

Reference guide for connecting client interfaces (DBeaver, `pgcli`, `psql`) to the PostgreSQL database cluster.

---

## 1. Connection Parameters Template

| Parameter | Value / Template | Notes |
| :--- | :--- | :--- |
| **Host / IP** | `localhost` or `<database-host>` | Target server address |
| **Port** | `5432` | Standard PostgreSQL port |
| **Database** | `sqledu` | Primary learning and audit laboratory database |
| **Username** | `<your-username>` | Database user / owner |
| **Password** | `<your-password>` | Configured with `scram-sha-256` authentication |
| **Authentication** | SCRAM-SHA-256 | High-security password hashing |
| **PostgreSQL Version** | **18.x** | Modern PostgreSQL engine |

---

## 2. Desktop GUI: DBeaver Community Setup

DBeaver Community Edition provides universal database management, schema inspection, and visual execution plan analysis.

### Step-by-Step Connection Setup in DBeaver:

1. Launch DBeaver.
2. Click **Database** -> **New Database Connection** (or press `Ctrl + Shift + N`).
3. Select **PostgreSQL** and click **Next**.
4. Configure connection parameters:
   * **Host**: `<database-host>` (e.g. `localhost` or remote server IP)
   * **Port**: `5432`
   * **Database**: `sqledu`
   * **Authentication**: `Database Native`
   * **Username**: `<your-username>`
   * **Password**: `<your-password>`
5. Click **Test Connection ...**:
   * DBeaver will automatically download the PostgreSQL JDBC driver if not already cached.
6. Click **Finish**.

> [!TIP]
> Use distinct database schemas (`foundations`, `benefit_audit`) to organize different analytical modules cleanly.

---

## 3. Interactive CLI: `pgcli` (Recommended Terminal Client)

`pgcli` provides syntax highlighting, intelligent auto-completion of table and column names, and formatted tabular outputs.

### Connect with `pgcli`:
```bash
pgcli -h <database-host> -U <your-username> -d sqledu
```

### Useful Commands:
* `\dn` – List available schemas (`foundations`, `benefit_audit`, `public`)
* `\dt <schema>.*` – List tables in a specific schema
* `\d <table_name>` – Inspect table structure, columns, types, and constraints
* `\x` – Toggle expanded auto-formatting (ideal for wide healthcare claims rows)

---

## 4. Standard CLI: `psql`

```bash
# Connect using standard psql
psql -h <database-host> -U <your-username> -d sqledu

# Execute an audit script directly
psql -h <database-host> -U <your-username> -d sqledu -f curriculum/02-benefit-configuration-audit/02-audit-reconciliation-queries.sql
```

---

## 5. Non-Interactive Authentication (`~/.pgpass`)

For headless scripts and automated validation routines, store credentials in `~/.pgpass` with secure permissions (`0600`):

```text
# hostname:port:database:username:password
<database-host>:5432:*:username:password
```

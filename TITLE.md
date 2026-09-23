# Banking Customer, Transaction & Loan Analytics using SQL

**Domain**: Retail & Commercial Banking Analytics  
**Database**: MySQL 8.0+  
**Target Roles**: Data Analyst | Business Analyst | BI Analyst | SQL Developer  
**Author Level**: BBA Business Analytics Graduate / Fresher Portfolio Showcase  

---

## 📌 Project Quick Links

* 📖 **[Main Project README](README.md)**
* 🗄️ **[Database Schema & ER Diagram](documentation/database_schema.png)**
* 📚 **[Data Dictionary](documentation/data_dictionary.md)**
* 📈 **[Executive Business Insights](documentation/business_insights.md)**
* 💼 **[Resume Bullet Points](documentation/resume_description.md)**
* 📱 **[LinkedIn Showcase Post](documentation/linkedin_post.md)**
* 🎯 **[28 Interview Questions & Answers](documentation/interview_questions.md)**
* 📊 **[Sample Query Execution Results](screenshots/query_output_samples.md)**

---

## 🏗️ SQL Architecture & Scripts

### Database Setup
1. [`database/01_create_database.sql`](database/01_create_database.sql) — Database creation with utf8mb4 collation.
2. [`database/02_create_tables.sql`](database/02_create_tables.sql) — DDL table definitions, Primary Keys, Foreign Keys, Indexes.
3. [`database/03_insert_data.sql`](database/03_insert_data.sql) — High-speed CSV ingestion via `LOAD DATA LOCAL INFILE`.
4. [`database/04_data_quality_checks.sql`](database/04_data_quality_checks.sql) — 14 automated data quality & referential integrity checks.

### Analysis Modules
1. [`queries/01_customer_analysis.sql`](queries/01_customer_analysis.sql) — Customer demographics, tenure & multi-product penetration (Questions 1–10).
2. [`queries/02_account_analysis.sql`](queries/02_account_analysis.sql) — Deposit performance, balance ranges & top account holders (Questions 11–18).
3. [`queries/03_transaction_analysis.sql`](queries/03_transaction_analysis.sql) — Velocity, channels (UPI, ATM, NEFT), monthly flow (Questions 19–28).
4. [`queries/04_loan_analysis.sql`](queries/04_loan_analysis.sql) — Portfolio breakdown, delinquency & default rates (Questions 29–38).
5. [`queries/05_advanced_sql.sql`](queries/05_advanced_sql.sql) — CTEs, Window Functions (`DENSE_RANK`, `LAG`, Running Totals, Top N per Region).
6. [`queries/06_business_insights.sql`](queries/06_business_insights.sql) — Executive KPI queries for C-Suite reporting.

---

## 📊 Dataset Scale

* **Customers**: 5,000
* **Branches**: 50
* **Accounts**: 7,000
* **Transactions**: 105,000+
* **Loans**: 3,000
* **Loan Payments**: 79,000+
* **Cards**: 5,200

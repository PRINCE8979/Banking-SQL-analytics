# Technical & Business Interview Preparation Guide

**Project**: Banking Customer, Transaction & Loan Analytics using SQL (MySQL 8+)  
**Target Roles**: Data Analyst, Business Analyst, BI Analyst, SQL Developer  

This guide contains **28 comprehensive interview questions and model answers** designed to help you ace technical and behavioral rounds for analyst roles in financial services, consulting, and tech.

---

## Part 1: Project Motivation & System Architecture

### Q1. Why did you choose a Banking Customer, Transaction & Loan Analytics project for your portfolio?
**Answer**:  
Banking provides one of the richest domains for demonstrating relational database modeling and advanced SQL analytics. Real banking operations involve multi-entity relationships (customers, multi-product accounts, omnichannel transaction streams, lending books, payment installments, and revolving credit cards). This allowed me to solve complex, high-stakes business questions—such as calculating portfolio default rates, customer wealth segmentation, channel migration patterns, and deposit-to-loan ratios—rather than querying simple, single-table tutorial datasets.

---

### Q2. Why did you choose a Relational Database (MySQL 8+) instead of a NoSQL database?
**Answer**:  
Banking data requires strict **ACID compliance** (Atomicity, Consistency, Isolation, Durability) to ensure that financial ledgers, account balances, and transaction logs never fall out of sync. A relational database allows us to enforce:
1. **Referential Integrity**: Primary and Foreign Key constraints prevent orphaned transactions or payments against deleted loans.
2. **Data Integrity Constraints**: `CHECK` constraints prevent negative balances, impossible interest rates, or zero-amount transfers.
3. **Structured Analytical Power**: Modern relational SQL engines (MySQL 8.0+) support Common Table Expressions (CTEs), window functions (`DENSE_RANK`, `LAG`, `ROW_NUMBER`), and complex joins ideal for multi-dimensional financial reporting.

---

### Q3. Why did you normalize the database schema, and what normal form did you achieve?
**Answer**:  
The schema is normalized to **Third Normal Form (3NF)**:
* **1NF**: All column values are atomic (e.g., individual customer attributes, single-valued timestamps and amounts), and every table has a defined primary key.
* **2NF**: All non-key columns are fully functionally dependent on the entire primary key, eliminating partial dependencies.
* **3NF**: There are no transitive dependencies; non-key columns depend only on primary keys. For instance, Branch information (City, State, Region) is stored in the `Branches` table rather than being repeated redundantly across millions of rows in `Accounts` or `Transactions`.

**Business Benefit**: Eliminates update anomalies (e.g., updating a branch address in one place), prevents data duplication, and minimizes disk storage overhead.

---

### Q4. Can you walk me through your 7-table database schema and the relationships between them?
**Answer**:  
The schema consists of 7 core entities:
1. `Customers`: Master demographic profile (PK: `Customer_ID`).
2. `Branches`: Physical branch facilities and regions (PK: `Branch_ID`).
3. `Accounts`: Customer deposit products (PK: `Account_ID`, FK: `Customer_ID`, `Branch_ID`). (1 Customer : Many Accounts, 1 Branch : Many Accounts).
4. `Transactions`: Granular transaction log (PK: `Transaction_ID`, FK: `Account_ID`). (1 Account : Many Transactions).
5. `Loans`: Credit contracts (PK: `Loan_ID`, FK: `Customer_ID`, `Branch_ID`). (1 Customer : Many Loans, 1 Branch : Many Loans).
6. `Loan_Payments`: Installment collection records (PK: `Payment_ID`, FK: `Loan_ID`). (1 Loan : Many Payments).
7. `Cards`: Debit/Credit card instruments (PK: `Card_ID`, FK: `Customer_ID`). (1 Customer : Many Cards).

---

## Part 2: Advanced SQL Techniques & Query Mechanics

### Q5. What is the difference between `RANK()`, `DENSE_RANK()`, and `ROW_NUMBER()`? When would you use each in banking?
**Answer**:  
All three are window ranking functions that assign numerical positions based on an `ORDER BY` clause:
* **`ROW_NUMBER()`**: Assigns a unique sequential integer (1, 2, 3, 4) regardless of ties. Useful for pagination or selecting the top 1 most recent transaction per account.
* **`RANK()`**: Assigns identical ranks to tied values but skips subsequent numbers (e.g., 1, 2, 2, 4). Useful when absolute placement matters and gaps are acceptable.
* **`DENSE_RANK()`**: Assigns identical ranks to tied values without skipping subsequent numbers (e.g., 1, 2, 2, 3).

**Project Application**: I used `DENSE_RANK()` for customer balance rankings and branch deposit league tables because branches with identical deposit totals should share a rank without causing missing rank numbers.

---

### Q6. Why did you use Common Table Expressions (CTEs) extensively over subqueries?
**Answer**:  
1. **Readability & Modular Structure**: CTEs (`WITH` clauses) break complex multi-step financial logic (such as aggregating customer deposits, segmenting them, and then computing macro-level segment shares) into sequential, readable building blocks.
2. **Reusability**: A single CTE defined once can be referenced multiple times within the subsequent query, avoiding duplicate subquery evaluation.
3. **Debugging**: CTEs can be isolated and tested independently during query development.

---

### Q7. How does the `LAG()` window function work, and how did you use it to calculate Month-over-Month (MoM) transaction growth?
**Answer**:  
`LAG(column, offset)` accesses data from a previous row at a specified physical offset within the defined window partition.  
In Query 3 of `05_advanced_sql.sql`:
1. First CTE aggregates total transaction value grouped by `YYYY-MM`.
2. In the outer query, `LAG(Current_Month_Value, 1) OVER (ORDER BY Tx_Month)` retrieves the previous month's total value.
3. MoM growth is calculated using the formula:
   $$\text{MoM Growth \%} = \frac{\text{Current Month Value} - \text{Previous Month Value}}{\text{Previous Month Value}} \times 100$$

---

### Q8. What is the difference between `INNER JOIN` and `LEFT JOIN`, and where did you specifically choose one over the other?
**Answer**:  
* **`INNER JOIN`**: Returns only matching rows from both tables. I used `INNER JOIN` when analyzing customers who have actively executed transactions (`Customers` $\rightarrow$ `Accounts` $\rightarrow$ `Transactions`), where non-transacting customers were intentionally excluded.
* **`LEFT JOIN`**: Returns all rows from the left table and matched rows from the right table (filling with `NULL` if no match exists). I used `LEFT JOIN` in:
  1. **Branch 360-degree performance**: Ensuring branches that disbursed zero loans or had zero transactions were still included in the scorecard with `COALESCE(SUM(...), 0)`.
  2. **Data Quality Audits**: Identifying orphaned foreign keys or customers with zero accounts (`WHERE a.Account_ID IS NULL`).

---

### Q9. How did you calculate running cumulative transaction totals in SQL?
**Answer**:  
I utilized a window aggregate function:
```sql
SUM(Daily_Tx_Value) OVER (
    ORDER BY Transaction_Date 
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS Cumulative_Running_Tx_Value
```
This specifies a framing clause that accumulates all rows from the start of the temporal partition up to the current row, computing a continuous running total without expensive self-joins.

---

### Q10. What is the difference between `WHERE` and `HAVING` in SQL?
**Answer**:  
* **`WHERE`**: Filters individual rows *before* aggregation occurs. (e.g., filtering `WHERE Transaction_Status = 'Success'`).
* **`HAVING`**: Filters grouped summary rows *after* aggregation has been performed by `GROUP BY`. (e.g., filtering customers holding multiple accounts: `HAVING COUNT(Account_ID) > 1`).

---

## Part 3: Banking Domain & Business Metrics

### Q11. How did you define and calculate the Loan Default Rate and Non-Performing Asset (NPA) percentage?
**Answer**:  
I evaluated default rate across two key banking dimensions:
1. **Volume Default Rate**:
   $$\text{Volume Default \%} = \frac{\text{Count of Defaulted Loans}}{\text{Total Disbursed Loans}} \times 100$$
   *(Result in our dataset: **8.23%** = 247 defaulted loans out of 3,000).*
2. **Capital Default Rate (NPA Exposure)**:
   $$\text{Capital Default \%} = \frac{\text{Sum of Defaulted Disbursed Principal}}{\text{Total Disbursed Principal}} \times 100$$
   *(Result in our dataset: **7.76%** = ₹617.29M defaulted out of ₹7.96B disbursed).*

---

### Q12. How did you approach Customer Wealth Segmentation?
**Answer**:  
I grouped customers based on aggregate relationship balance across all their deposit and term accounts:
* **Premium**: Total Balance $\ge$ ₹1,000,000 (₹10 Lakhs)
* **Mass Affluent**: Total Balance between ₹250,000 and ₹1,000,000
* **Standard**: Total Balance $<$ ₹250,000

**Business Finding**: Premium customers account for only **25.38% of the customer count**, but control **71.93% of total bank deposits** (~₹2.66B), demonstrating substantial wealth concentration that warrants high-touch Relationship Managers.

---

### Q13. How did you calculate the Deposit-to-Loan Ratio, and why is it important for a bank?
**Answer**:  
The Deposit-to-Loan (or Credit-to-Deposit) Ratio evaluates liquidity balance:
$$\text{Deposit-to-Loan Ratio} = \frac{\text{Total Customer Deposits}}{\text{Total Customer Loans}}$$
* **Ratio $> 1.0$**: The customer is a **Net Liquidity Provider** (funds the bank's lending book).
* **Ratio $< 1.0$**: The customer is a **Net Borrower** (credit consumer).

For bank treasury, maintaining a healthy Credit-Deposit ratio ensures the bank has sufficient liquid deposits to fund lending operations without relying on expensive interbank borrowings.

---

### Q14. What were the key transaction channel insights you discovered?
**Answer**:  
There is an inverse relationship between channel volume and transaction value:
* **Volume Leader**: **UPI** accounted for **37.94% of total transaction volume** (39,832 txs), but only **5.87% of monetary value** (avg ticket: ₹5,500.66).
* **Value Leaders**: **NEFT** (28.54% value, ₹125k avg ticket) and **Branch** (28.47% value, ₹250k avg ticket) processed the highest monetary amounts.
* **Strategic Takeaway**: Retail micro-payments have migrated heavily to digital rails (UPI/Mobile), while corporate settlements and high-value transfers remain concentrated on NEFT and physical branches.

---

### Q15. Explain your Analytical Loan Risk Classification logic.
**Answer**:  
I created a multi-criteria risk indicator query (`05_advanced_sql.sql`):
* **High Risk**: Loans with `Loan_Status = 'Defaulted'` OR $\ge 2$ Failed EMI payments OR ($\ge 3$ Late payments with 'In Arrears' status).
* **Medium Risk**: Loans with status 'In Arrears' OR 1–2 Late payments OR high-interest unsecured loans ($>14\%$ rate on $>10\text{L}$ amount).
* **Low Risk**: Regular on-time repayment history with zero missed payments.

*(Note: In interviews, I clarify that this is an analytical portfolio indicator based on synthetic transactional history, not a full statistical probability-of-default credit scorecard).*

---

## Part 4: Data Quality, Integrity & Database Administration

### Q16. What data quality and integrity checks did you implement before running analysis?
**Answer**:  
I wrote a dedicated 14-check validation script (`04_data_quality_checks.sql`):
1. Checked for `NULL` values in primary and foreign key columns.
2. Verified primary key uniqueness.
3. Verified zero orphan records across foreign keys using `LEFT JOIN ... WHERE right.PK IS NULL`.
4. Checked for non-negative balances, transaction amounts, and loan disbursements.
5. Audited **temporal logic**:
   - `Open_Date >= Customer_Since`
   - `Transaction_Date >= Open_Date`
   - `Payment_Date >= Loan_Start_Date`
6. Verified enum domain constraints on account statuses, loan statuses, and transaction outcomes.
7. Flagged unrealistic interest rate outliers ($<1\%$ or $>40\%$).

---

### Q17. How did you optimize query performance across 100,000+ transaction rows?
**Answer**:  
I implemented B-Tree composite and single-column indexes on high-cardinality join and filter columns:
* `idx_transactions_account` on `Transactions(Account_ID)`
* `idx_transactions_date` on `Transactions(Transaction_Date)`
* `idx_transactions_channel` on `Transactions(Channel)`
* `idx_accounts_customer` on `Accounts(Customer_ID)`
* `idx_loans_customer` on `Loans(Customer_ID)`

These indexes reduced full table scans to indexed index-seeks during temporal range queries and multi-table join lookups.

---

### Q18. How do you handle `NULL` values in aggregate calculations?
**Answer**:  
* Aggregate functions like `SUM()`, `AVG()`, `COUNT(column)` ignore `NULL` values automatically, whereas `COUNT(*)` counts all rows including those with `NULL` attributes.
* When computing financial ratios (e.g., Debt-to-Income), I used `NULLIF(Income, 0)` in the denominator to avoid division-by-zero runtime exceptions, and wrapped outer expressions in `COALESCE(expression, 0)` to provide clean fallback values.

---

### Q19. What is the difference between `UNION` and `UNION ALL`?
**Answer**:  
* **`UNION`**: Combines result sets and performs an internal sorting/de-duplication pass to return only distinct rows.
* **`UNION ALL`**: Combines result sets without removing duplicates, making it faster and less memory-intensive.
* In this project, I used `UNION ALL` in data quality scripts and table count verifications because duplicate elimination was unnecessary.

---

### Q20. Can you explain what an `EXPLAIN` plan does in MySQL?
**Answer**:  
`EXPLAIN` or `EXPLAIN ANALYZE` provides the MySQL query execution plan. It reveals:
* Which indexes the optimizer selected (`key`, `possible_keys`).
* The join type (`ALL` for full table scan, `ref` or `eq_ref` for index lookups).
* The estimated number of rows examined (`rows`).
* Filter efficiency (`filtered` percentage).

It is an indispensable tool for diagnosing slow queries and optimizing join sequences.

---

## Part 5: Behavioral & Project Reflection

### Q21. What was the most challenging SQL query in this project, and how did you solve it?
**Answer**:  
The most complex query was the **360-Degree Branch Performance Matrix** (Query 9 in `05_advanced_sql.sql`).  
**The Challenge**: Joining `Accounts`, `Loans`, and `Transactions` directly against `Branches` caused a Cartesian product fan-out, multiplying balances and transaction amounts because one branch has many accounts, each account has many transactions, and the branch also has many loans.  
**The Solution**: I used independent CTEs to pre-aggregate account balances, loan disbursements, and transaction counts at the `Branch_ID` level *before* joining them together via `LEFT JOIN` and `COALESCE`.

---

### Q22. What are the key limitations of this project?
**Answer**:  
1. **Synthetic Data**: While the dataset mirrors realistic Indian banking distributions, real-world banking data includes complex edge cases such as chargebacks, split payments, revolving interest compounding, and currency conversions.
2. **Static Balances**: Account balances in the dataset represent current snapshot balances rather than continuously updated running daily ledger tables.
3. **No Credit Bureau Scores**: Risk classification is analytical based on simulated transaction/EMI records rather than external CIBIL/Experian credit bureau inputs.

---

### Q23. If you had 2 more weeks on this project, what would you improve?
**Answer**:  
1. **Automated Daily ETL Pipeline**: Write a Python/Airflow workflow to ingest daily incremental transaction files into MySQL.
2. **Stored Procedures & Triggers**: Implement database triggers to automatically adjust account balances upon insertion of deposit/withdrawal transactions.
3. **Data Quality Framework**: Implement automated Great Expectations or dbt test assertions to continuously audit data freshness and anomaly thresholds.

---

### Q24. How did your BBA Business Analytics background help you on this project?
**Answer**:  
My business background helped me connect technical SQL syntax with real-world commercial objectives. Rather than writing queries in isolation, I framed them around key banking metrics: Net Interest Margin indicators, Non-Performing Asset (NPA) ratios, CASA deposit mobilization, customer concentration risk, and channel cost optimization.

---

### Q25. How do you ensure your SQL code is readable and maintainable in a team environment?
**Answer**:  
1. **Consistent Uppercase Keywords**: Writing SQL keywords (`SELECT`, `FROM`, `WHERE`, `GROUP BY`) in uppercase and schema identifiers in camel/snake case.
2. **Explicit Column Names**: Avoiding `SELECT *` in analytical queries to prevent unexpected schema breaking.
3. **Descriptive Table Aliases**: Using meaningful aliases (`c` for Customers, `a` for Accounts, `lp` for Loan_Payments).
4. **Header Comments**: Documenting business intent, parameters, and author information at the top of every SQL script.

---

### Q26. What is the difference between `COUNT(1)`, `COUNT(*)`, and `COUNT(column)`?
**Answer**:  
* `COUNT(*)` counts all rows in the table/partition, including rows where all columns or specific columns are `NULL`.
* `COUNT(1)` is functionally identical to `COUNT(*)` in MySQL 8.0 and evaluates all rows.
* `COUNT(column)` counts only rows where the specified `column` contains a **non-NULL** value.

---

### Q27. What is a Correlated Subquery and how does it differ from a non-correlated subquery?
**Answer**:  
* **Non-correlated Subquery**: Executes independently of the outer query once, and its result is passed to the outer query.
* **Correlated Subquery**: References columns from the outer query table, executing once for every row processed by the outer query. While flexible, correlated subqueries can be slow on large datasets, which is why I refactored correlated lookups into CTEs and `JOIN` operations.

---

### Q28. How would you present these findings to the Chief Operating Officer (COO) or Head of Retail Banking?
**Answer**:  
I would structure the executive briefing into three action points:
1. **Customer Retention**: Alert leadership that 71.9% of bank deposits rely on just 1,269 Premium customers, recommending an immediate VIP concierge program to guard against attrition.
2. **Channel Cost Efficiency**: Highlight that 64.2% of transaction volume is already digital, recommending further automation of branch cash counters to reduce physical servicing overhead.
3. **Lending Guardrails**: Propose tighter underwriting filters on unsecured Personal Loans to reduce the 9.54% delinquency rate, while accelerating low-risk Home Loan growth.

# Data Dictionary — Banking Customer, Transaction & Loan Analytics

This document provides a comprehensive data dictionary for all 7 relational tables in the `banking_analytics_db` database schema.

---

## 1. Customers Table (`Customers`)

**Description**: Stores master demographic, geographic, and economic profiles of banking customers.

| Column Name | Data Type | Constraint | Description | Example | Business Meaning |
|---|---|---|---|---|---|
| `Customer_ID` | `VARCHAR(20)` | `PRIMARY KEY, NOT NULL` | Unique identifier for the customer | `CUST00142` | Master identifier linking accounts, loans, and cards. |
| `Customer_Name` | `VARCHAR(100)` | `NOT NULL` | Full legal name of the account holder | `Aarav Sharma` | Used for KYC compliance and personalized communication. |
| `Gender` | `ENUM('Male','Female','Other')` | `NOT NULL` | Customer gender classification | `Male` | Used for demographic analysis and targeted product campaigns. |
| `Date_of_Birth` | `DATE` | `NOT NULL` | Date of birth of the customer | `1988-04-12` | Determines customer age bracket, life stage, and credit eligibility. |
| `City` | `VARCHAR(50)` | `NOT NULL` | City of primary residence | `Bengaluru` | Geographic segmentation and branch proximity mapping. |
| `State` | `VARCHAR(50)` | `NOT NULL` | State of primary residence | `Karnataka` | Regional compliance and macro-economic distribution. |
| `Occupation` | `VARCHAR(80)` | `NOT NULL` | Primary professional employment category | `Software Engineer` | Income reliability assessment and retail banking segmentation. |
| `Income` | `DECIMAL(15,2)` | `NOT NULL, CHECK >= 0` | Stated gross annual income in INR | `1450000.00` | Debt-to-income (DTI) evaluation and credit limit determination. |
| `Customer_Since` | `DATE` | `NOT NULL` | Date customer opened their first relationship | `2017-03-15` | Measures customer lifetime tenure and loyalty cohort. |

---

## 2. Branches Table (`Branches`)

**Description**: Contains details of physical bank branches across regional zones.

| Column Name | Data Type | Constraint | Description | Example | Business Meaning |
|---|---|---|---|---|---|
| `Branch_ID` | `VARCHAR(20)` | `PRIMARY KEY, NOT NULL` | Unique code assigned to the branch | `BR011` | Unique branch identifier for operational and auditing tracking. |
| `Branch_Name` | `VARCHAR(100)` | `NOT NULL` | Full branch facility name | `Bengaluru South Ext Branch` | Branch operational identity. |
| `City` | `VARCHAR(50)` | `NOT NULL` | City where branch is located | `Bengaluru` | Local urban/rural market identification. |
| `State` | `VARCHAR(50)` | `NOT NULL` | State where branch operates | `Karnataka` | State-level banking operational oversight. |
| `Region` | `ENUM('North','South','East','West','Central')` | `NOT NULL` | Broad macro-geographical zone | `South` | Regional reporting, zonal targets, and balance sheet consolidation. |

---

## 3. Accounts Table (`Accounts`)

**Description**: Tracks deposit, savings, current, and term deposit accounts.

| Column Name | Data Type | Constraint | Description | Example | Business Meaning |
|---|---|---|---|---|---|
| `Account_ID` | `VARCHAR(20)` | `PRIMARY KEY, NOT NULL` | Unique account number | `ACC001045` | Unique ledger identifier for customer deposits and withdrawals. |
| `Customer_ID` | `VARCHAR(20)` | `FOREIGN KEY, NOT NULL` | Parent customer identifier | `CUST00142` | Maps deposit balances to individual customers. |
| `Branch_ID` | `VARCHAR(20)` | `FOREIGN KEY, NOT NULL` | Originating home branch | `BR011` | Credits branch for deposit mobilization performance. |
| `Account_Type` | `ENUM('Savings','Current','Salary','Fixed Deposit')` | `NOT NULL` | Category of deposit product | `Savings` | Distinguishes CASA (Current & Savings) from term liabilities. |
| `Open_Date` | `DATE` | `NOT NULL` | Date account was activated | `2018-06-20` | Account seasoning and vintage tracking. |
| `Balance` | `DECIMAL(15,2)` | `NOT NULL, CHECK >= 0` | Available ledger balance in INR | `245800.50` | Bank liability / customer liquidity pool. |
| `Account_Status` | `ENUM('Active','Inactive','Dormant','Closed')` | `NOT NULL` | Operational state of account | `Active` | Identifies churn, dormant balances, and operational accounts. |

---

## 4. Transactions Table (`Transactions`)

**Description**: Detailed transactional audit log across digital and physical banking channels.

| Column Name | Data Type | Constraint | Description | Example | Business Meaning |
|---|---|---|---|---|---|
| `Transaction_ID` | `VARCHAR(20)` | `PRIMARY KEY, NOT NULL` | Unique transaction reference string | `TXN0005421` | Idempotent transaction identification for reconciliation. |
| `Account_ID` | `VARCHAR(20)` | `FOREIGN KEY, NOT NULL` | Account debited or credited | `ACC001045` | Links fund movement to underlying account balance. |
| `Transaction_Date` | `DATE` | `NOT NULL` | Date transaction was executed | `2023-11-14` | Temporal tracking for daily, monthly, and seasonal velocity. |
| `Transaction_Type` | `ENUM('Deposit','Withdrawal','Transfer')` | `NOT NULL` | Movement classification | `Withdrawal` | Measures liquidity inflow vs outflow dynamics. |
| `Amount` | `DECIMAL(15,2)` | `NOT NULL, CHECK > 0` | Monetary value in INR | `4500.00` | Transaction ticket size. |
| `Channel` | `ENUM('UPI','ATM','Net Banking','Mobile Banking','NEFT','IMPS','Branch','POS / Debit Card')` | `NOT NULL` | Banking channel used | `UPI` | Identifies digital adoption and branch load distribution. |
| `Transaction_Status` | `ENUM('Success','Failed','Pending')` | `NOT NULL` | Final processing outcome | `Success` | Measures system availability and technical decline rates. |

---

## 5. Loans Table (`Loans`)

**Description**: Master loan portfolio capturing terms, principal, rate, and delinquency status.

| Column Name | Data Type | Constraint | Description | Example | Business Meaning |
|---|---|---|---|---|---|
| `Loan_ID` | `VARCHAR(20)` | `PRIMARY KEY, NOT NULL` | Unique loan agreement code | `LOAN00482` | Master contract identifier for credit exposure. |
| `Customer_ID` | `VARCHAR(20)` | `FOREIGN KEY, NOT NULL` | Borrower customer ID | `CUST00142` | Evaluates borrower-level debt exposure and leverage. |
| `Branch_ID` | `VARCHAR(20)` | `FOREIGN KEY, NOT NULL` | Sanctioning branch ID | `BR011` | Monitors branch credit disbursals and delinquency. |
| `Loan_Type` | `ENUM('Home Loan','Personal Loan','Auto Loan','Education Loan','Business Loan','Gold Loan')` | `NOT NULL` | Collateral and purpose category | `Home Loan` | Distinguishes secured mortgage from unsecured consumer credit. |
| `Loan_Amount` | `DECIMAL(15,2)` | `NOT NULL, CHECK > 0` | Total principal disbursed in INR | `4500000.00` | Asset book value deployed by the bank. |
| `Interest_Rate` | `DECIMAL(5,2)` | `NOT NULL, CHECK > 0` | Annual percentage interest rate (%) | `8.45` | Determines portfolio yield and interest income. |
| `Loan_Term` | `INT` | `NOT NULL, CHECK > 0` | Total duration in months | `240` | Amortization schedule length and duration risk. |
| `Loan_Status` | `ENUM('Active','Closed','Defaulted','In Arrears')` | `NOT NULL` | Current credit asset standing | `Active` | Tracks asset classification, non-performing assets (NPAs), and recoveries. |
| `Loan_Start_Date` | `DATE` | `NOT NULL` | Date loan was disbursed | `2021-04-10` | Disbursal vintage for cohort default curve analysis. |

---

## 6. Loan_Payments Table (`Loan_Payments`)

**Description**: Granular EMI repayment transaction records for active and closed loans.

| Column Name | Data Type | Constraint | Description | Example | Business Meaning |
|---|---|---|---|---|---|
| `Payment_ID` | `VARCHAR(20)` | `PRIMARY KEY, NOT NULL` | Unique payment transaction code | `PAY0034129` | Unique receipt identifier for installment collection. |
| `Loan_ID` | `VARCHAR(20)` | `FOREIGN KEY, NOT NULL` | Target loan contract | `LOAN00482` | Maps cash inflow against specific loan amortization. |
| `Payment_Date` | `DATE` | `NOT NULL` | Date installment was received | `2023-05-10` | Payment timeliness assessment against billing cycle. |
| `Payment_Amount` | `DECIMAL(15,2)` | `NOT NULL, CHECK > 0` | Amount collected in INR | `38950.00` | Cash inflow reducing loan exposure or interest dues. |
| `Payment_Status` | `ENUM('Paid','Late','Failed')` | `NOT NULL` | Repayment timeliness flag | `Paid` | Key indicator for behavioral delinquency and risk scoring. |

---

## 7. Cards Table (`Cards`)

**Description**: Payment card portfolio covering credit, debit, prepaid, and corporate cards.

| Column Name | Data Type | Constraint | Description | Example | Business Meaning |
|---|---|---|---|---|---|
| `Card_ID` | `VARCHAR(20)` | `PRIMARY KEY, NOT NULL` | Unique plastic card identifier | `CARD001854` | Master identifier for card payment instrument. |
| `Customer_ID` | `VARCHAR(20)` | `FOREIGN KEY, NOT NULL` | Cardholder customer ID | `CUST00142` | Cross-sell product mapping to customer profile. |
| `Card_Type` | `ENUM('Credit Card','Debit Card','Prepaid Card','Corporate Card')` | `NOT NULL` | Product category | `Credit Card` | Revolving credit line vs deposit-linked debit facility. |
| `Issue_Date` | `DATE` | `NOT NULL` | Date card was issued | `2020-08-15` | Card vintage and renewal schedule. |
| `Credit_Limit` | `DECIMAL(15,2)` | `NOT NULL, CHECK >= 0` | Approved credit line / spending cap in INR | `250000.00` | Maximum revolving liability exposure sanctioned. |
| `Card_Status` | `ENUM('Active','Blocked','Expired','Inactive')` | `NOT NULL` | Card operational status | `Active` | Active cardholder penetration and dormant card maintenance. |

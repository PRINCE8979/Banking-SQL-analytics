-- ============================================================================
-- Banking Customer, Transaction & Loan Analytics Project
-- Script 03: Data Ingestion Script
-- Database Engine: MySQL 8.0+
-- ============================================================================

USE banking_analytics_db;

-- ----------------------------------------------------------------------------
-- Instructions for Running via MySQL CLI or MySQL Workbench:
--
-- Method 1: Using MySQL Workbench Table Data Import Wizard
--   1. Right click on each table (in order: Branches -> Customers -> Accounts -> Loans -> Cards -> Transactions -> Loan_Payments)
--   2. Click 'Table Data Import Wizard'
--   3. Select the corresponding CSV from the `data/` folder.
--
-- Method 2: Using LOAD DATA INFILE (Direct SQL)
-- Ensure MySQL server variable `local_infile` is enabled:
--   SET GLOBAL local_infile = 1;
-- Update the file paths below to point to your absolute local directory.
-- ----------------------------------------------------------------------------

-- Note: Replace '/path/to/banking-sql-analytics/data/' with your actual absolute path.
-- Example Windows Path: 'C:/Users/Prince/New folder/banking-sql-analytics/data/'

-- 1. Ingest Branches
LOAD DATA LOCAL INFILE 'C:/Users/Prince/New folder/banking-sql-analytics/data/branches.csv'
INTO TABLE Branches
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Branch_ID, Branch_Name, City, State, Region);

-- 2. Ingest Customers
LOAD DATA LOCAL INFILE 'C:/Users/Prince/New folder/banking-sql-analytics/data/customers.csv'
INTO TABLE Customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Customer_ID, Customer_Name, Gender, Date_of_Birth, City, State, Occupation, Income, Customer_Since);

-- 3. Ingest Accounts
LOAD DATA LOCAL INFILE 'C:/Users/Prince/New folder/banking-sql-analytics/data/accounts.csv'
INTO TABLE Accounts
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Account_ID, Customer_ID, Branch_ID, Account_Type, Open_Date, Balance, Account_Status);

-- 4. Ingest Loans
LOAD DATA LOCAL INFILE 'C:/Users/Prince/New folder/banking-sql-analytics/data/loans.csv'
INTO TABLE Loans
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Loan_ID, Customer_ID, Branch_ID, Loan_Type, Loan_Amount, Interest_Rate, Loan_Term, Loan_Status, Loan_Start_Date);

-- 5. Ingest Cards
LOAD DATA LOCAL INFILE 'C:/Users/Prince/New folder/banking-sql-analytics/data/cards.csv'
INTO TABLE Cards
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Card_ID, Customer_ID, Card_Type, Issue_Date, Credit_Limit, Card_Status);

-- 6. Ingest Transactions
LOAD DATA LOCAL INFILE 'C:/Users/Prince/New folder/banking-sql-analytics/data/transactions.csv'
INTO TABLE Transactions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Transaction_ID, Account_ID, Transaction_Date, Transaction_Type, Amount, Channel, Transaction_Status);

-- 7. Ingest Loan_Payments
LOAD DATA LOCAL INFILE 'C:/Users/Prince/New folder/banking-sql-analytics/data/loan_payments.csv'
INTO TABLE Loan_Payments
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Payment_ID, Loan_ID, Payment_Date, Payment_Amount, Payment_Status);

-- ----------------------------------------------------------------------------
-- Verification: Record Counts Verification Query
-- ----------------------------------------------------------------------------
SELECT 'Branches' AS Table_Name, COUNT(*) AS Record_Count FROM Branches
UNION ALL
SELECT 'Customers', COUNT(*) FROM Customers
UNION ALL
SELECT 'Accounts', COUNT(*) FROM Accounts
UNION ALL
SELECT 'Loans', COUNT(*) FROM Loans
UNION ALL
SELECT 'Cards', COUNT(*) FROM Cards
UNION ALL
SELECT 'Transactions', COUNT(*) FROM Transactions
UNION ALL
SELECT 'Loan_Payments', COUNT(*) FROM Loan_Payments;

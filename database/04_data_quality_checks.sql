-- ============================================================================
-- Banking Customer, Transaction & Loan Analytics Project
-- Script 04: Comprehensive Data Quality & Integrity Checks
-- Database Engine: MySQL 8.0+
-- Description: Runs 14 distinct data verification and sanity validation queries.
-- Expected Result: Each check returns 0 offending rows or confirms validity.
-- ============================================================================

USE banking_analytics_db;

-- ----------------------------------------------------------------------------
-- 1. Check for NULL Values Across Critical Identifier & Metric Columns
-- ----------------------------------------------------------------------------
SELECT 
    'Customers NULL Check' AS Check_Name,
    SUM(CASE WHEN Customer_ID IS NULL OR Customer_Name IS NULL OR Income IS NULL THEN 1 ELSE 0 END) AS Null_Count
FROM Customers
UNION ALL
SELECT 
    'Accounts NULL Check',
    SUM(CASE WHEN Account_ID IS NULL OR Customer_ID IS NULL OR Branch_ID IS NULL OR Balance IS NULL THEN 1 ELSE 0 END)
FROM Accounts
UNION ALL
SELECT 
    'Transactions NULL Check',
    SUM(CASE WHEN Transaction_ID IS NULL OR Account_ID IS NULL OR Amount IS NULL OR Transaction_Date IS NULL THEN 1 ELSE 0 END)
FROM Transactions
UNION ALL
SELECT 
    'Loans NULL Check',
    SUM(CASE WHEN Loan_ID IS NULL OR Customer_ID IS NULL OR Loan_Amount IS NULL OR Interest_Rate IS NULL THEN 1 ELSE 0 END)
FROM Loans
UNION ALL
SELECT 
    'Loan_Payments NULL Check',
    SUM(CASE WHEN Payment_ID IS NULL OR Loan_ID IS NULL OR Payment_Amount IS NULL THEN 1 ELSE 0 END)
FROM Loan_Payments;

-- ----------------------------------------------------------------------------
-- 2. Check for Duplicate Primary Keys
-- ----------------------------------------------------------------------------
SELECT 'Duplicate Customer_ID' AS Table_Check, Customer_ID AS Duplicate_Key, COUNT(*) AS Occurrences
FROM Customers
GROUP BY Customer_ID
HAVING COUNT(*) > 1
UNION ALL
SELECT 'Duplicate Account_ID', Account_ID, COUNT(*)
FROM Accounts
GROUP BY Account_ID
HAVING COUNT(*) > 1
UNION ALL
SELECT 'Duplicate Transaction_ID', Transaction_ID, COUNT(*)
FROM Transactions
GROUP BY Transaction_ID
HAVING COUNT(*) > 1
UNION ALL
SELECT 'Duplicate Loan_ID', Loan_ID, COUNT(*)
FROM Loans
GROUP BY Loan_ID
HAVING COUNT(*) > 1
UNION ALL
SELECT 'Duplicate Payment_ID', Payment_ID, COUNT(*)
FROM Loan_Payments
GROUP BY Payment_ID
HAVING COUNT(*) > 1;

-- ----------------------------------------------------------------------------
-- 3. Check for Orphaned Records (Invalid Foreign Keys)
-- ----------------------------------------------------------------------------
-- Accounts with non-existent Customers
SELECT 'Accounts -> Orphan Customer' AS Integrity_Check, COUNT(*) AS Orphan_Count
FROM Accounts a
LEFT JOIN Customers c ON a.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL
UNION ALL
-- Accounts with non-existent Branches
SELECT 'Accounts -> Orphan Branch', COUNT(*)
FROM Accounts a
LEFT JOIN Branches b ON a.Branch_ID = b.Branch_ID
WHERE b.Branch_ID IS NULL
UNION ALL
-- Transactions with non-existent Accounts
SELECT 'Transactions -> Orphan Account', COUNT(*)
FROM Transactions t
LEFT JOIN Accounts a ON t.Account_ID = a.Account_ID
WHERE a.Account_ID IS NULL
UNION ALL
-- Loans with non-existent Customers
SELECT 'Loans -> Orphan Customer', COUNT(*)
FROM Loans l
LEFT JOIN Customers c ON l.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL
UNION ALL
-- Payments with non-existent Loans
SELECT 'Payments -> Orphan Loan', COUNT(*)
FROM Loan_Payments lp
LEFT JOIN Loans l ON lp.Loan_ID = l.Loan_ID
WHERE l.Loan_ID IS NULL;

-- ----------------------------------------------------------------------------
-- 4. Check for Negative or Zero Amounts in Transactions and Balances
-- ----------------------------------------------------------------------------
SELECT 
    'Negative or Zero Transaction Amounts' AS Issue_Type,
    COUNT(*) AS Violation_Count
FROM Transactions
WHERE Amount <= 0
UNION ALL
SELECT 
    'Negative Account Balances',
    COUNT(*)
FROM Accounts
WHERE Balance < 0
UNION ALL
SELECT 
    'Negative or Zero Loan Amounts',
    COUNT(*)
FROM Loans
WHERE Loan_Amount <= 0;

-- ----------------------------------------------------------------------------
-- 5. Check for Logical Date Anomalies (Temporal Integrity)
-- ----------------------------------------------------------------------------
-- Account Open_Date prior to Customer_Since
SELECT 
    'Account Open Before Customer Creation' AS Temporal_Anomaly,
    COUNT(*) AS Violation_Count
FROM Accounts a
JOIN Customers c ON a.Customer_ID = c.Customer_ID
WHERE a.Open_Date < c.Customer_Since
UNION ALL
-- Transaction Date prior to Account Open_Date
SELECT 
    'Transaction Date Prior to Account Open Date',
    COUNT(*)
FROM Transactions t
JOIN Accounts a ON t.Account_ID = a.Account_ID
WHERE t.Transaction_Date < a.Open_Date
UNION ALL
-- Loan Payment Date prior to Loan Start_Date
SELECT 
    'Payment Date Prior to Loan Start Date',
    COUNT(*)
FROM Loan_Payments lp
JOIN Loans l ON lp.Loan_ID = l.Loan_ID
WHERE lp.Payment_Date < l.Loan_Start_Date;

-- ----------------------------------------------------------------------------
-- 6. Check for Invalid Account Statuses
-- ----------------------------------------------------------------------------
SELECT 
    Account_Status,
    COUNT(*) AS Total_Count
FROM Accounts
GROUP BY Account_Status
HAVING Account_Status NOT IN ('Active', 'Inactive', 'Dormant', 'Closed');

-- ----------------------------------------------------------------------------
-- 7. Check for Invalid Loan Statuses
-- ----------------------------------------------------------------------------
SELECT 
    Loan_Status,
    COUNT(*) AS Total_Count
FROM Loans
GROUP BY Loan_Status
HAVING Loan_Status NOT IN ('Active', 'Closed', 'Defaulted', 'In Arrears');

-- ----------------------------------------------------------------------------
-- 8. Check for Invalid Transaction Statuses
-- ----------------------------------------------------------------------------
SELECT 
    Transaction_Status,
    COUNT(*) AS Total_Count
FROM Transactions
GROUP BY Transaction_Status
HAVING Transaction_Status NOT IN ('Success', 'Failed', 'Pending');

-- ----------------------------------------------------------------------------
-- 9. Check for Unrealistic Interest Rates (< 1% or > 40%)
-- ----------------------------------------------------------------------------
SELECT 
    Loan_ID,
    Loan_Type,
    Interest_Rate
FROM Loans
WHERE Interest_Rate < 1.0 OR Interest_Rate > 40.0;

-- ----------------------------------------------------------------------------
-- 10. Check for Potential Exact Duplicate Transactions
-- (Same Account, Date, Type, Amount, Channel occurring within identical timestamp)
-- ----------------------------------------------------------------------------
SELECT 
    Account_ID,
    Transaction_Date,
    Transaction_Type,
    Amount,
    Channel,
    COUNT(*) AS Duplicate_Transaction_Count
FROM Transactions
GROUP BY Account_ID, Transaction_Date, Transaction_Type, Amount, Channel
HAVING COUNT(*) > 1
LIMIT 10;

-- ----------------------------------------------------------------------------
-- 11. Check for Customers Without Any Accounts
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(c.Customer_ID) AS Customers_Without_Accounts
FROM Customers c
LEFT JOIN Accounts a ON c.Customer_ID = a.Customer_ID
WHERE a.Account_ID IS NULL;

-- ----------------------------------------------------------------------------
-- 12. Check for Accounts Without Any Transactions (Excluding Fixed Deposits)
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(a.Account_ID) AS Non_FD_Accounts_Without_Transactions
FROM Accounts a
LEFT JOIN Transactions t ON a.Account_ID = t.Account_ID
WHERE a.Account_Type != 'Fixed Deposit' 
  AND t.Transaction_ID IS NULL;

-- ----------------------------------------------------------------------------
-- 13. Check for Loans Without Customers
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(l.Loan_ID) AS Loans_Without_Valid_Customer
FROM Loans l
LEFT JOIN Customers c ON l.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL;

-- ----------------------------------------------------------------------------
-- 14. Check for Payments Without Loans
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(lp.Payment_ID) AS Payments_Without_Valid_Loan
FROM Loan_Payments lp
LEFT JOIN Loans l ON lp.Loan_ID = l.Loan_ID
WHERE l.Loan_ID IS NULL;

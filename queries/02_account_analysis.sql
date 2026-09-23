-- ============================================================================
-- Banking Customer, Transaction & Loan Analytics Project
-- Script 02: Account Performance & Deposit Balance Analysis
-- Questions Answered: 11 to 18
-- Database Engine: MySQL 8.0+
-- ============================================================================

USE banking_analytics_db;

-- ----------------------------------------------------------------------------
-- Question 11: Total Number of Accounts
-- Business Objective: Total volume of deposit/savings accounts serviced.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(Account_ID) AS Total_Accounts
FROM Accounts;

-- ----------------------------------------------------------------------------
-- Question 12: Account Distribution by Account Type
-- Business Objective: Composition of product book (Savings, Current, Salary, FD).
-- ----------------------------------------------------------------------------
SELECT 
    Account_Type,
    COUNT(Account_ID) AS Total_Accounts,
    ROUND(COUNT(Account_ID) * 100.0 / (SELECT COUNT(*) FROM Accounts), 2) AS Account_Share_Pct,
    ROUND(SUM(Balance), 2) AS Total_Balance,
    ROUND(SUM(Balance) * 100.0 / (SELECT SUM(Balance) FROM Accounts), 2) AS Balance_Share_Pct
FROM Accounts
GROUP BY Account_Type
ORDER BY Total_Balance DESC;

-- ----------------------------------------------------------------------------
-- Question 13: Active vs Inactive / Dormant Accounts
-- Business Objective: Monitor operational health and dormancy rates.
-- ----------------------------------------------------------------------------
SELECT 
    Account_Status,
    COUNT(Account_ID) AS Account_Count,
    ROUND(COUNT(Account_ID) * 100.0 / (SELECT COUNT(*) FROM Accounts), 2) AS Percentage_Share,
    ROUND(SUM(Balance), 2) AS Total_Balance_Locked
FROM Accounts
GROUP BY Account_Status
ORDER BY Account_Count DESC;

-- ----------------------------------------------------------------------------
-- Question 14: Average, Minimum, and Maximum Balance by Account Type
-- Business Objective: Gauge liquidity profile across account products.
-- ----------------------------------------------------------------------------
SELECT 
    Account_Type,
    COUNT(Account_ID) AS Number_Of_Accounts,
    ROUND(AVG(Balance), 2) AS Avg_Balance,
    ROUND(MIN(Balance), 2) AS Min_Balance,
    ROUND(MAX(Balance), 2) AS Max_Balance,
    ROUND(SUM(Balance), 2) AS Total_Balance
FROM Accounts
GROUP BY Account_Type
ORDER BY Avg_Balance DESC;

-- ----------------------------------------------------------------------------
-- Question 15: Total Bank Deposits Across Entire Network
-- Business Objective: Measure aggregate deposit liability base.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(Account_ID) AS Total_Accounts,
    ROUND(SUM(Balance), 2) AS Total_Bank_Deposits,
    ROUND(AVG(Balance), 2) AS Overall_Average_Balance
FROM Accounts;

-- ----------------------------------------------------------------------------
-- Question 16: Top 10 Customers by Aggregate Deposit Balance
-- Business Objective: Identify premier ultra-high-net-worth individual (HNI) accounts.
-- ----------------------------------------------------------------------------
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    c.City,
    c.Occupation,
    COUNT(a.Account_ID) AS Total_Accounts_Held,
    ROUND(SUM(a.Balance), 2) AS Total_Deposit_Balance
FROM Customers c
JOIN Accounts a ON c.Customer_ID = a.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name, c.City, c.Occupation
ORDER BY Total_Deposit_Balance DESC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- Question 17: Branch-Wise Deposit Performance
-- Business Objective: Evaluate branch deposit mobilization and liquidity contribution.
-- ----------------------------------------------------------------------------
SELECT 
    b.Branch_ID,
    b.Branch_Name,
    b.City,
    b.Region,
    COUNT(a.Account_ID) AS Total_Accounts,
    ROUND(SUM(a.Balance), 2) AS Total_Deposits,
    ROUND(AVG(a.Balance), 2) AS Avg_Deposit_Per_Account
FROM Branches b
LEFT JOIN Accounts a ON b.Branch_ID = a.Branch_ID
GROUP BY b.Branch_ID, b.Branch_Name, b.City, b.Region
ORDER BY Total_Deposits DESC;

-- ----------------------------------------------------------------------------
-- Question 18: Customers Holding Multiple Accounts (Detailed Distribution)
-- Business Objective: Profile relationship depth and multi-account ownership.
-- ----------------------------------------------------------------------------
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    COUNT(a.Account_ID) AS Total_Accounts_Owned,
    GROUP_CONCAT(DISTINCT a.Account_Type ORDER BY a.Account_Type SEPARATOR ', ') AS Held_Account_Types,
    ROUND(SUM(a.Balance), 2) AS Combined_Balance
FROM Customers c
JOIN Accounts a ON c.Customer_ID = a.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name
HAVING COUNT(a.Account_ID) > 1
ORDER BY Total_Accounts_Owned DESC, Combined_Balance DESC
LIMIT 15;

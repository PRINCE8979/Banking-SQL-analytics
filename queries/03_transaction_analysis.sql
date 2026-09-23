-- ============================================================================
-- Banking Customer, Transaction & Loan Analytics Project
-- Script 03: Transaction Activity, Channel Trends & Velocity Analysis
-- Questions Answered: 19 to 28
-- Database Engine: MySQL 8.0+
-- ============================================================================

USE banking_analytics_db;

-- ----------------------------------------------------------------------------
-- Question 19: Total Transaction Count
-- Business Objective: Determine overall operational processing volume.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(Transaction_ID) AS Total_Transactions,
    COUNT(DISTINCT Account_ID) AS Unique_Transacting_Accounts
FROM Transactions;

-- ----------------------------------------------------------------------------
-- Question 20: Total Transaction Value (Gross Value Processed)
-- Business Objective: Measure monetary flow handled through banking infrastructure.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(Transaction_ID) AS Total_Transactions,
    ROUND(SUM(Amount), 2) AS Total_Transaction_Value,
    ROUND(AVG(Amount), 2) AS Overall_Average_Transaction_Value
FROM Transactions;

-- ----------------------------------------------------------------------------
-- Question 21: Deposits vs Withdrawals vs Transfers (Type Comparison)
-- Business Objective: Compare inflows, outflows, and peer-to-peer transfers.
-- ----------------------------------------------------------------------------
SELECT 
    Transaction_Type,
    COUNT(Transaction_ID) AS Transaction_Count,
    ROUND(COUNT(Transaction_ID) * 100.0 / (SELECT COUNT(*) FROM Transactions), 2) AS Volume_Share_Pct,
    ROUND(SUM(Amount), 2) AS Total_Amount,
    ROUND(SUM(Amount) * 100.0 / (SELECT SUM(Amount) FROM Transactions), 2) AS Value_Share_Pct,
    ROUND(AVG(Amount), 2) AS Avg_Amount_Per_Tx
FROM Transactions
GROUP BY Transaction_Type
ORDER BY Total_Amount DESC;

-- ----------------------------------------------------------------------------
-- Question 22: Transaction Breakdown by Channel (Digital vs Physical)
-- Business Objective: Assess channel migration (UPI, Net Banking, ATM, Branch).
-- ----------------------------------------------------------------------------
SELECT 
    Channel,
    COUNT(Transaction_ID) AS Total_Volume,
    ROUND(COUNT(Transaction_ID) * 100.0 / (SELECT COUNT(*) FROM Transactions), 2) AS Volume_Share_Pct,
    ROUND(SUM(Amount), 2) AS Total_Value,
    ROUND(SUM(Amount) * 100.0 / (SELECT SUM(Amount) FROM Transactions), 2) AS Value_Share_Pct,
    ROUND(AVG(Amount), 2) AS Avg_Ticket_Size
FROM Transactions
GROUP BY Channel
ORDER BY Total_Volume DESC;

-- ----------------------------------------------------------------------------
-- Question 23: Monthly Transaction Trends (Volume & Value over Time)
-- Business Objective: Track temporal adoption, cyclical patterns, and seasonality.
-- ----------------------------------------------------------------------------
SELECT 
    DATE_FORMAT(Transaction_Date, '%Y-%m') AS Year_Month,
    COUNT(Transaction_ID) AS Monthly_Transaction_Count,
    ROUND(SUM(Amount), 2) AS Monthly_Transaction_Value,
    ROUND(AVG(Amount), 2) AS Avg_Transaction_Amount
FROM Transactions
GROUP BY DATE_FORMAT(Transaction_Date, '%Y-%m')
ORDER BY Year_Month ASC;

-- ----------------------------------------------------------------------------
-- Question 24: Regional Transaction Activity
-- Business Objective: Identify geographic economic hubs driving banking volume.
-- ----------------------------------------------------------------------------
SELECT 
    b.Region,
    COUNT(t.Transaction_ID) AS Transaction_Count,
    ROUND(SUM(t.Amount), 2) AS Total_Transaction_Value,
    ROUND(AVG(t.Amount), 2) AS Avg_Transaction_Value,
    COUNT(DISTINCT a.Customer_ID) AS Active_Transacting_Customers
FROM Transactions t
JOIN Accounts a ON t.Account_ID = a.Account_ID
JOIN Branches b ON a.Branch_ID = b.Branch_ID
GROUP BY b.Region
ORDER BY Total_Transaction_Value DESC;

-- ----------------------------------------------------------------------------
-- Question 25: Most Active Customers by Transaction Frequency (Top 10)
-- Business Objective: Identify power users and high-velocity transactional clients.
-- ----------------------------------------------------------------------------
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    c.Occupation,
    c.City,
    COUNT(t.Transaction_ID) AS Total_Transactions,
    ROUND(SUM(t.Amount), 2) AS Total_Transaction_Volume_INR,
    ROUND(AVG(t.Amount), 2) AS Avg_Ticket_Size
FROM Customers c
JOIN Accounts a ON c.Customer_ID = a.Customer_ID
JOIN Transactions t ON a.Account_ID = t.Account_ID
GROUP BY c.Customer_ID, c.Customer_Name, c.Occupation, c.City
ORDER BY Total_Transactions DESC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- Question 26: Highest Transaction-Value Customers (Top 10)
-- Business Objective: Identify clients generating largest gross throughput.
-- ----------------------------------------------------------------------------
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    c.Occupation,
    c.City,
    COUNT(t.Transaction_ID) AS Total_Transactions,
    ROUND(SUM(t.Amount), 2) AS Gross_Transaction_Value
FROM Customers c
JOIN Accounts a ON c.Customer_ID = a.Customer_ID
JOIN Transactions t ON a.Account_ID = t.Account_ID
GROUP BY c.Customer_ID, c.Customer_Name, c.Occupation, c.City
ORDER BY Gross_Transaction_Value DESC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- Question 27: Average Transaction Value by Product & Channel Matrix
-- Business Objective: Cross-tabulate ticket sizes across channels and account types.
-- ----------------------------------------------------------------------------
SELECT 
    a.Account_Type,
    t.Channel,
    COUNT(t.Transaction_ID) AS Transaction_Count,
    ROUND(AVG(t.Amount), 2) AS Avg_Transaction_Amount,
    ROUND(SUM(t.Amount), 2) AS Total_Channel_Value
FROM Accounts a
JOIN Transactions t ON a.Account_ID = t.Account_ID
GROUP BY a.Account_Type, t.Channel
ORDER BY a.Account_Type, Total_Channel_Value DESC;

-- ----------------------------------------------------------------------------
-- Question 28: Transaction Status Breakdown (Success vs Failed vs Pending)
-- Business Objective: Measure system uptime, network failures, and transaction friction.
-- ----------------------------------------------------------------------------
SELECT 
    Transaction_Status,
    COUNT(Transaction_ID) AS Total_Attempts,
    ROUND(COUNT(Transaction_ID) * 100.0 / (SELECT COUNT(*) FROM Transactions), 2) AS Status_Percentage,
    ROUND(SUM(Amount), 2) AS Gross_Amount
FROM Transactions
GROUP BY Transaction_Status
ORDER BY Total_Attempts DESC;

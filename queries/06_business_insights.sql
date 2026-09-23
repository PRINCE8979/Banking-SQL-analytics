-- ============================================================================
-- Banking Customer, Transaction & Loan Analytics Project
-- Script 06: Executive Business Insights & Strategic Portfolio Analytics
-- Database Engine: MySQL 8.0+
-- Description: Queries designed for Executive Dashboards, C-Suite reporting,
--              and data-driven banking strategy decisions.
-- ============================================================================

USE banking_analytics_db;

-- ----------------------------------------------------------------------------
-- INSIGHT 1: Wealth Concentration & Deposit Distribution Across Customer Segments
-- Question: Which customer segments hold the highest balances and average deposits?
-- ----------------------------------------------------------------------------
WITH Customer_Balances AS (
    SELECT 
        c.Customer_ID,
        c.Income,
        SUM(a.Balance) AS Total_Balance
    FROM Customers c
    JOIN Accounts a ON c.Customer_ID = a.Customer_ID
    GROUP BY c.Customer_ID, c.Income
),
Segmented AS (
    SELECT 
        Customer_ID,
        Income,
        Total_Balance,
        CASE 
            WHEN Total_Balance >= 1000000 THEN 'Premium (> 10L INR)'
            WHEN Total_Balance >= 250000 THEN 'Mass Affluent (2.5L - 10L INR)'
            ELSE 'Standard (< 2.5L INR)'
        END AS Tier
    FROM Customer_Balances
)
SELECT 
    Tier AS Customer_Segment,
    COUNT(Customer_ID) AS Total_Customers,
    ROUND(COUNT(Customer_ID) * 100.0 / (SELECT COUNT(*) FROM Customers), 2) AS Customer_Share_Pct,
    ROUND(SUM(Total_Balance), 2) AS Aggregate_Deposits_INR,
    ROUND(SUM(Total_Balance) * 100.0 / (SELECT SUM(Balance) FROM Accounts), 2) AS Deposit_Share_Pct,
    ROUND(AVG(Total_Balance), 2) AS Avg_Deposit_Per_Customer,
    ROUND(AVG(Income), 2) AS Avg_Annual_Income
FROM Segmented
GROUP BY Tier
ORDER BY Aggregate_Deposits_INR DESC;

-- ----------------------------------------------------------------------------
-- INSIGHT 2: Top Performing Branches by Deposit Mobilization & Regional Contribution
-- Question: Which branches and regions are the top drivers of bank liquidity?
-- ----------------------------------------------------------------------------
WITH Branch_Summary AS (
    SELECT 
        b.Branch_ID,
        b.Branch_Name,
        b.City,
        b.Region,
        COUNT(DISTINCT a.Customer_ID) AS Customer_Count,
        ROUND(SUM(a.Balance), 2) AS Total_Branch_Deposits
    FROM Branches b
    JOIN Accounts a ON b.Branch_ID = a.Branch_ID
    GROUP BY b.Branch_ID, b.Branch_Name, b.City, b.Region
)
SELECT 
    DENSE_RANK() OVER (ORDER BY Total_Branch_Deposits DESC) AS Deposit_Rank,
    Branch_Name,
    City,
    Region,
    Customer_Count,
    Total_Branch_Deposits,
    ROUND(Total_Branch_Deposits * 100.0 / SUM(Total_Branch_Deposits) OVER (), 2) AS Pct_Of_Bank_Total
FROM Branch_Summary
ORDER BY Deposit_Rank ASC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- INSIGHT 3: Channel Migration & Digital Adoption Analysis
-- Question: Which transaction channels handle the highest volume vs value?
-- ----------------------------------------------------------------------------
SELECT 
    Channel,
    COUNT(Transaction_ID) AS Total_Tx_Count,
    ROUND(COUNT(Transaction_ID) * 100.0 / (SELECT COUNT(*) FROM Transactions), 2) AS Volume_Share_Pct,
    ROUND(SUM(Amount), 2) AS Gross_Value_INR,
    ROUND(SUM(Amount) * 100.0 / (SELECT SUM(Amount) FROM Transactions), 2) AS Value_Share_Pct,
    ROUND(AVG(Amount), 2) AS Avg_Ticket_Size_INR,
    CASE 
        WHEN Channel IN ('UPI', 'Mobile Banking', 'Net Banking') THEN 'Digital Channel'
        WHEN Channel IN ('ATM', 'POS / Debit Card') THEN 'Self-Service Electronic'
        ELSE 'Physical / Branch Assisted'
    END AS Channel_Category
FROM Transactions
GROUP BY Channel
ORDER BY Total_Tx_Count DESC;

-- ----------------------------------------------------------------------------
-- INSIGHT 4: Loan Portfolio Asset Quality & Default Rates by Product Category
-- Question: Which loan categories represent the largest portfolio and highest risk?
-- ----------------------------------------------------------------------------
SELECT 
    Loan_Type,
    COUNT(Loan_ID) AS Total_Loans,
    ROUND(SUM(Loan_Amount), 2) AS Total_Disbursed_Principal,
    ROUND(SUM(Loan_Amount) * 100.0 / (SELECT SUM(Loan_Amount) FROM Loans), 2) AS Portfolio_Weight_Pct,
    COUNT(CASE WHEN Loan_Status = 'Defaulted' THEN 1 END) AS Default_Count,
    ROUND(COUNT(CASE WHEN Loan_Status = 'Defaulted' THEN 1 END) * 100.0 / COUNT(Loan_ID), 2) AS Default_Rate_Pct,
    ROUND(SUM(CASE WHEN Loan_Status = 'Defaulted' THEN Loan_Amount ELSE 0 END), 2) AS Defaulted_Capital_INR,
    ROUND(AVG(Interest_Rate), 2) AS Avg_Interest_Rate
FROM Loans
GROUP BY Loan_Type
ORDER BY Total_Disbursed_Principal DESC;

-- ----------------------------------------------------------------------------
-- INSIGHT 5: Geographic Region-Level 360-Degree Macro Performance
-- Question: How do different geographic regions compare across deposits, loans & transactions?
-- ----------------------------------------------------------------------------
WITH Regional_Branches AS (
    SELECT Region, COUNT(Branch_ID) AS Total_Branches FROM Branches GROUP BY Region
),
Regional_Deposits AS (
    SELECT b.Region, SUM(a.Balance) AS Total_Deposits, COUNT(DISTINCT a.Customer_ID) AS Customers
    FROM Branches b JOIN Accounts a ON b.Branch_ID = a.Branch_ID GROUP BY b.Region
),
Regional_Loans AS (
    SELECT b.Region, SUM(l.Loan_Amount) AS Total_Loans, COUNT(l.Loan_ID) AS Loan_Count,
           SUM(CASE WHEN l.Loan_Status = 'Defaulted' THEN l.Loan_Amount ELSE 0 END) AS Defaulted_Loans
    FROM Branches b JOIN Loans l ON b.Branch_ID = l.Branch_ID GROUP BY b.Region
),
Regional_Tx AS (
    SELECT b.Region, COUNT(t.Transaction_ID) AS Tx_Count, SUM(t.Amount) AS Tx_Value
    FROM Branches b
    JOIN Accounts a ON b.Branch_ID = a.Branch_ID
    JOIN Transactions t ON a.Account_ID = t.Account_ID
    GROUP BY b.Region
)
SELECT 
    rb.Region,
    rb.Total_Branches,
    rd.Customers AS Customer_Base,
    ROUND(rd.Total_Deposits, 2) AS Total_Deposits,
    ROUND(rl.Total_Loans, 2) AS Total_Loans,
    ROUND(rd.Total_Deposits / NULLIF(rl.Total_Loans, 0), 2) AS Credit_Deposit_Coverage_Ratio,
    ROUND(rl.Defaulted_Loans * 100.0 / NULLIF(rl.Total_Loans, 0), 2) AS Regional_Default_Rate_Pct,
    rt.Tx_Count AS Transaction_Volume,
    ROUND(rt.Tx_Value, 2) AS Transaction_Value
FROM Regional_Branches rb
JOIN Regional_Deposits rd ON rb.Region = rd.Region
JOIN Regional_Loans rl ON rb.Region = rl.Region
JOIN Regional_Tx rt ON rb.Region = rt.Region
ORDER BY Total_Deposits DESC;

-- ----------------------------------------------------------------------------
-- INSIGHT 6: High Deposit & High Loan Exposure Customers (Dual Concentration Risk)
-- Question: Which customers hold substantial balances and debt simultaneously?
-- ----------------------------------------------------------------------------
WITH Cust_Deposit AS (
    SELECT Customer_ID, SUM(Balance) AS Total_Deposits FROM Accounts GROUP BY Customer_ID
),
Cust_Loan AS (
    SELECT Customer_ID, SUM(Loan_Amount) AS Total_Loans FROM Loans GROUP BY Customer_ID
)
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    c.City,
    c.Occupation,
    ROUND(d.Total_Deposits, 2) AS Total_Deposits,
    ROUND(l.Total_Loans, 2) AS Total_Loans,
    ROUND(d.Total_Deposits - l.Total_Loans, 2) AS Net_Liquidity_Position
FROM Customers c
JOIN Cust_Deposit d ON c.Customer_ID = d.Customer_ID
JOIN Cust_Loan l ON c.Customer_ID = l.Customer_ID
WHERE d.Total_Deposits >= 500000 AND l.Total_Loans >= 1000000
ORDER BY Net_Liquidity_Position DESC
LIMIT 15;

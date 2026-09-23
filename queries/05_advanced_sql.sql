-- ============================================================================
-- Banking Customer, Transaction & Loan Analytics Project
-- Script 05: Advanced SQL Analytics & Window Functions
-- Demonstrates: CTEs, Window Functions (DENSE_RANK, ROW_NUMBER, LAG, SUM OVER),
--               Multi-table JOINs, Complex CASE logic, Running Totals, MoM Growth
-- Database Engine: MySQL 8.0+
-- ============================================================================

USE banking_analytics_db;

-- ----------------------------------------------------------------------------
-- ADVANCED QUERY 1: Customer Ranking Based on Total Account Balance
-- Technique: Aggregate JOIN + Window Function DENSE_RANK()
-- Business Purpose: Rank every customer across the institution without gaps.
-- ----------------------------------------------------------------------------
WITH Customer_Balance_CTE AS (
    SELECT 
        c.Customer_ID,
        c.Customer_Name,
        c.City,
        c.State,
        c.Occupation,
        ROUND(SUM(a.Balance), 2) AS Total_Balance,
        COUNT(a.Account_ID) AS Account_Count
    FROM Customers c
    JOIN Accounts a ON c.Customer_ID = a.Customer_ID
    GROUP BY c.Customer_ID, c.Customer_Name, c.City, c.State, c.Occupation
)
SELECT 
    DENSE_RANK() OVER (ORDER BY Total_Balance DESC) AS Balance_Rank,
    Customer_ID,
    Customer_Name,
    City,
    State,
    Occupation,
    Account_Count,
    Total_Balance
FROM Customer_Balance_CTE
ORDER BY Balance_Rank ASC
LIMIT 20;

-- ----------------------------------------------------------------------------
-- ADVANCED QUERY 2: Branch Ranking Based on Total Deposit Mobilization
-- Technique: Aggregation + DENSE_RANK() Window Function
-- Business Purpose: Compare branch performance across all geographical regions.
-- ----------------------------------------------------------------------------
WITH Branch_Deposits_CTE AS (
    SELECT 
        b.Branch_ID,
        b.Branch_Name,
        b.City,
        b.Region,
        COUNT(DISTINCT a.Customer_ID) AS Total_Customers,
        COUNT(a.Account_ID) AS Total_Accounts,
        ROUND(SUM(a.Balance), 2) AS Total_Deposits
    FROM Branches b
    JOIN Accounts a ON b.Branch_ID = a.Branch_ID
    GROUP BY b.Branch_ID, b.Branch_Name, b.City, b.Region
)
SELECT 
    DENSE_RANK() OVER (ORDER BY Total_Deposits DESC) AS Deposit_Rank,
    Branch_ID,
    Branch_Name,
    City,
    Region,
    Total_Customers,
    Total_Accounts,
    Total_Deposits,
    ROUND(Total_Deposits * 100.0 / SUM(Total_Deposits) OVER (), 2) AS Network_Deposit_Share_Pct
FROM Branch_Deposits_CTE
ORDER BY Deposit_Rank ASC;

-- ----------------------------------------------------------------------------
-- ADVANCED QUERY 3: Month-over-Month (MoM) Transaction Growth
-- Technique: CTE + LAG() Window Function + MoM Percentage Calculation
-- Business Purpose: Track monthly inflow/outflow trajectory and growth acceleration.
-- ----------------------------------------------------------------------------
WITH Monthly_Transaction_CTE AS (
    SELECT 
        DATE_FORMAT(Transaction_Date, '%Y-%m') AS Tx_Month,
        COUNT(Transaction_ID) AS Tx_Count,
        ROUND(SUM(Amount), 2) AS Current_Month_Value
    FROM Transactions
    WHERE Transaction_Status = 'Success'
    GROUP BY DATE_FORMAT(Transaction_Date, '%Y-%m')
)
SELECT 
    Tx_Month,
    Tx_Count,
    Current_Month_Value,
    LAG(Current_Month_Value, 1) OVER (ORDER BY Tx_Month) AS Previous_Month_Value,
    ROUND(
        (Current_Month_Value - LAG(Current_Month_Value, 1) OVER (ORDER BY Tx_Month)), 2
    ) AS Absolute_Growth,
    ROUND(
        ((Current_Month_Value - LAG(Current_Month_Value, 1) OVER (ORDER BY Tx_Month)) * 100.0) / 
        LAG(Current_Month_Value, 1) OVER (ORDER BY Tx_Month), 2
    ) AS MoM_Growth_Percentage
FROM Monthly_Transaction_CTE
ORDER BY Tx_Month ASC;

-- ----------------------------------------------------------------------------
-- ADVANCED QUERY 4: Top 3 Customers per Geographic Region
-- Technique: Multi-CTE + DENSE_RANK() with PARTITION BY Region
-- Business Purpose: Identify regional premier wealth management prospects.
-- ----------------------------------------------------------------------------
WITH Regional_Customer_Balance AS (
    SELECT 
        b.Region,
        c.Customer_ID,
        c.Customer_Name,
        c.City,
        c.Occupation,
        ROUND(SUM(a.Balance), 2) AS Total_Balance
    FROM Customers c
    JOIN Accounts a ON c.Customer_ID = a.Customer_ID
    JOIN Branches b ON a.Branch_ID = b.Branch_ID
    GROUP BY b.Region, c.Customer_ID, c.Customer_Name, c.City, c.Occupation
),
Ranked_Regional_Customers AS (
    SELECT 
        Region,
        Customer_ID,
        Customer_Name,
        City,
        Occupation,
        Total_Balance,
        DENSE_RANK() OVER (PARTITION BY Region ORDER BY Total_Balance DESC) AS Regional_Rank
    FROM Regional_Customer_Balance
)
SELECT 
    Region,
    Regional_Rank,
    Customer_ID,
    Customer_Name,
    City,
    Occupation,
    Total_Balance
FROM Ranked_Regional_Customers
WHERE Regional_Rank <= 3
ORDER BY Region, Regional_Rank;

-- ----------------------------------------------------------------------------
-- ADVANCED QUERY 5: Customer Tier Segmentation (Balance-Based Wealth Tiers)
-- Technique: Aggregation + Conditional CASE logic + Summary Profiling
-- Business Purpose: Segment customer base into actionable tiers for marketing/RM.
-- Tiers: Premium (> 1,000,000 INR), Mass Affluent (250,000 - 1,000,000), Standard (< 250,000)
-- ----------------------------------------------------------------------------
WITH Customer_Aggregates AS (
    SELECT 
        c.Customer_ID,
        c.Customer_Name,
        c.Income,
        ROUND(SUM(a.Balance), 2) AS Total_Balance,
        COUNT(a.Account_ID) AS Total_Accounts
    FROM Customers c
    JOIN Accounts a ON c.Customer_ID = a.Customer_ID
    GROUP BY c.Customer_ID, c.Customer_Name, c.Income
),
Segmented_Customers AS (
    SELECT 
        Customer_ID,
        Customer_Name,
        Income,
        Total_Balance,
        Total_Accounts,
        CASE 
            WHEN Total_Balance >= 1000000 THEN 'Premium'
            WHEN Total_Balance >= 250000 AND Total_Balance < 1000000 THEN 'Mass Affluent'
            ELSE 'Standard'
        END AS Customer_Segment
    FROM Customer_Aggregates
)
SELECT 
    Customer_Segment,
    COUNT(Customer_ID) AS Customer_Count,
    ROUND(COUNT(Customer_ID) * 100.0 / (SELECT COUNT(*) FROM Customers), 2) AS Segment_Share_Pct,
    ROUND(SUM(Total_Balance), 2) AS Total_Segment_Deposits,
    ROUND(AVG(Total_Balance), 2) AS Avg_Balance_Per_Customer,
    ROUND(AVG(Income), 2) AS Avg_Annual_Income
FROM Segmented_Customers
GROUP BY Customer_Segment
ORDER BY Total_Segment_Deposits DESC;

-- ----------------------------------------------------------------------------
-- ADVANCED QUERY 6: Analytical Loan Portfolio Risk Classification
-- Technique: Multi-table CTE + Multi-criteria CASE Risk Indicator
-- IMPORTANT: This is an analytical portfolio risk scoring query based on historical
--            repayment patterns & contract status for this synthetic dataset, not
--            a live underwriting model.
-- ----------------------------------------------------------------------------
WITH Loan_Risk_Indicators AS (
    SELECT 
        l.Loan_ID,
        l.Customer_ID,
        l.Loan_Type,
        l.Loan_Amount,
        l.Interest_Rate,
        l.Loan_Status,
        COUNT(lp.Payment_ID) AS Total_Installments_Logged,
        SUM(CASE WHEN lp.Payment_Status = 'Late' THEN 1 ELSE 0 END) AS Late_Payments,
        SUM(CASE WHEN lp.Payment_Status = 'Failed' THEN 1 ELSE 0 END) AS Failed_Payments
    FROM Loans l
    LEFT JOIN Loan_Payments lp ON l.Loan_ID = lp.Loan_ID
    GROUP BY l.Loan_ID, l.Customer_ID, l.Loan_Type, l.Loan_Amount, l.Interest_Rate, l.Loan_Status
),
Risk_Classified_Loans AS (
    SELECT 
        Loan_ID,
        Customer_ID,
        Loan_Type,
        Loan_Amount,
        Interest_Rate,
        Loan_Status,
        Late_Payments,
        Failed_Payments,
        CASE 
            WHEN Loan_Status = 'Defaulted' OR Failed_Payments >= 2 OR (Late_Payments >= 3 AND Loan_Status = 'In Arrears') THEN 'High Risk'
            WHEN Loan_Status = 'In Arrears' OR Late_Payments BETWEEN 1 AND 2 OR (Interest_Rate >= 14.0 AND Loan_Amount > 1000000) THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS Analytical_Risk_Tier
    FROM Loan_Risk_Indicators
)
SELECT 
    Analytical_Risk_Tier,
    COUNT(Loan_ID) AS Loan_Count,
    ROUND(COUNT(Loan_ID) * 100.0 / (SELECT COUNT(*) FROM Loans), 2) AS Portfolio_Volume_Pct,
    ROUND(SUM(Loan_Amount), 2) AS Total_Exposed_Principal,
    ROUND(SUM(Loan_Amount) * 100.0 / (SELECT SUM(Loan_Amount) FROM Loans), 2) AS Capital_Risk_Pct,
    ROUND(AVG(Interest_Rate), 2) AS Avg_Interest_Rate
FROM Risk_Classified_Loans
GROUP BY Analytical_Risk_Tier
ORDER BY Total_Exposed_Principal DESC;

-- ----------------------------------------------------------------------------
-- ADVANCED QUERY 7: Customer Aggregate Loan Exposure
-- Technique: Left Join aggregation + loan product cataloging
-- Business Purpose: Assess bank-wide debt exposure at individual customer level.
-- ----------------------------------------------------------------------------
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    c.City,
    c.Occupation,
    c.Income,
    COUNT(l.Loan_ID) AS Total_Loans_Held,
    ROUND(SUM(l.Loan_Amount), 2) AS Total_Loan_Exposure,
    ROUND(AVG(l.Interest_Rate), 2) AS Weighted_Avg_Interest_Rate,
    ROUND(SUM(l.Loan_Amount) / NULLIF(c.Income, 0), 2) AS Debt_to_Income_Ratio
FROM Customers c
JOIN Loans l ON c.Customer_ID = l.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name, c.City, c.Occupation, c.Income
ORDER BY Total_Loan_Exposure DESC
LIMIT 20;

-- ----------------------------------------------------------------------------
-- ADVANCED QUERY 8: Customer Deposit-to-Loan Ratio (Liquidity vs Exposure)
-- Technique: Multi-CTE Joining Deposit & Loan aggregations + COALESCE / Ratio logic
-- Business Purpose: Identify net lenders vs net borrowers among cross-sold customers.
-- ----------------------------------------------------------------------------
WITH Customer_Deposits AS (
    SELECT 
        Customer_ID,
        ROUND(SUM(Balance), 2) AS Total_Deposits
    FROM Accounts
    GROUP BY Customer_ID
),
Customer_Borrowings AS (
    SELECT 
        Customer_ID,
        ROUND(SUM(Loan_Amount), 2) AS Total_Loans
    FROM Loans
    GROUP BY Customer_ID
)
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    c.City,
    c.Occupation,
    d.Total_Deposits,
    b.Total_Loans,
    ROUND(d.Total_Deposits / b.Total_Loans, 4) AS Deposit_To_Loan_Ratio,
    CASE 
        WHEN d.Total_Deposits > b.Total_Loans THEN 'Net Depositor (Liquidity Provider)'
        WHEN d.Total_Deposits = b.Total_Loans THEN 'Balanced'
        ELSE 'Net Borrower (Credit Consumer)'
    END AS Customer_Financial_Profile
FROM Customers c
JOIN Customer_Deposits d ON c.Customer_ID = d.Customer_ID
JOIN Customer_Borrowings b ON c.Customer_ID = b.Customer_ID
ORDER BY Deposit_To_Loan_Ratio DESC
LIMIT 20;

-- ----------------------------------------------------------------------------
-- ADVANCED QUERY 9: 360-Degree Comprehensive Branch Performance Matrix
-- Technique: Multiple Subqueries / CTE Aggregations combined via JOIN
-- Business Purpose: Complete branch scorecard across customers, accounts, deposits,
--                   loans, transaction velocity and throughput.
-- ----------------------------------------------------------------------------
WITH Branch_Accounts_Summary AS (
    SELECT 
        Branch_ID,
        COUNT(DISTINCT Customer_ID) AS Total_Customers,
        COUNT(Account_ID) AS Total_Accounts,
        ROUND(SUM(Balance), 2) AS Total_Deposits
    FROM Accounts
    GROUP BY Branch_ID
),
Branch_Loans_Summary AS (
    SELECT 
        Branch_ID,
        COUNT(Loan_ID) AS Total_Loans,
        ROUND(SUM(Loan_Amount), 2) AS Total_Loans_Disbursed
    FROM Loans
    GROUP BY Branch_ID
),
Branch_Tx_Summary AS (
    SELECT 
        a.Branch_ID,
        COUNT(t.Transaction_ID) AS Total_Transactions,
        ROUND(SUM(t.Amount), 2) AS Total_Transaction_Value
    FROM Accounts a
    JOIN Transactions t ON a.Account_ID = t.Account_ID
    WHERE t.Transaction_Status = 'Success'
    GROUP BY a.Branch_ID
)
SELECT 
    b.Branch_ID,
    b.Branch_Name,
    b.City,
    b.Region,
    COALESCE(bas.Total_Customers, 0) AS Customer_Count,
    COALESCE(bas.Total_Accounts, 0) AS Account_Count,
    COALESCE(bas.Total_Deposits, 0) AS Total_Deposits,
    COALESCE(bls.Total_Loans, 0) AS Loan_Count,
    COALESCE(bls.Total_Loans_Disbursed, 0) AS Total_Loans_Disbursed,
    COALESCE(bts.Total_Transactions, 0) AS Transaction_Count,
    COALESCE(bts.Total_Transaction_Value, 0) AS Transaction_Value
FROM Branches b
LEFT JOIN Branch_Accounts_Summary bas ON b.Branch_ID = bas.Branch_ID
LEFT JOIN Branch_Loans_Summary bls ON b.Branch_ID = bls.Branch_ID
LEFT JOIN Branch_Tx_Summary bts ON b.Branch_ID = bts.Branch_ID
ORDER BY Total_Deposits DESC
LIMIT 15;

-- ----------------------------------------------------------------------------
-- ADVANCED QUERY 10: Cumulative Running Transaction Totals
-- Technique: Daily Aggregation + Window Function SUM() OVER (ORDER BY Date ROWS UNBOUNDED PRECEDING)
-- Business Purpose: Track continuous cumulative gross transactional throughput.
-- ----------------------------------------------------------------------------
WITH Daily_Tx_CTE AS (
    SELECT 
        Transaction_Date,
        COUNT(Transaction_ID) AS Daily_Tx_Count,
        ROUND(SUM(Amount), 2) AS Daily_Tx_Value
    FROM Transactions
    WHERE Transaction_Status = 'Success'
    GROUP BY Transaction_Date
)
SELECT 
    Transaction_Date,
    Daily_Tx_Count,
    Daily_Tx_Value,
    ROUND(
        SUM(Daily_Tx_Value) OVER (ORDER BY Transaction_Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2
    ) AS Cumulative_Running_Tx_Value,
    SUM(Daily_Tx_Count) OVER (ORDER BY Transaction_Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Cumulative_Running_Tx_Count
FROM Daily_Tx_CTE
ORDER BY Transaction_Date ASC
LIMIT 30;

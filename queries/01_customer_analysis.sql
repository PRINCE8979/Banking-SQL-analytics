-- ============================================================================
-- Banking Customer, Transaction & Loan Analytics Project
-- Script 01: Customer Demographics & Profile Analysis
-- Questions Answered: 1 to 10
-- Database Engine: MySQL 8.0+
-- ============================================================================

USE banking_analytics_db;

-- ----------------------------------------------------------------------------
-- Question 1: Total Number of Customers
-- Business Objective: Determine overall customer base size.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(Customer_ID) AS Total_Customers
FROM Customers;

-- ----------------------------------------------------------------------------
-- Question 2: Customer Distribution by Gender
-- Business Objective: Analyze gender diversity and percentage share.
-- ----------------------------------------------------------------------------
SELECT 
    Gender,
    COUNT(Customer_ID) AS Customer_Count,
    ROUND(COUNT(Customer_ID) * 100.0 / (SELECT COUNT(*) FROM Customers), 2) AS Percentage_Share
FROM Customers
GROUP BY Gender
ORDER BY Customer_Count DESC;

-- ----------------------------------------------------------------------------
-- Question 3: Customer Distribution by State
-- Business Objective: Identify top states with highest customer concentration.
-- ----------------------------------------------------------------------------
SELECT 
    State,
    COUNT(Customer_ID) AS Customer_Count,
    ROUND(COUNT(Customer_ID) * 100.0 / (SELECT COUNT(*) FROM Customers), 2) AS Percentage_Share
FROM Customers
GROUP BY State
ORDER BY Customer_Count DESC;

-- ----------------------------------------------------------------------------
-- Question 4: Customer Distribution by Geographic Region
-- Business Objective: Regional customer density through branch network mapping.
-- ----------------------------------------------------------------------------
SELECT 
    b.Region,
    COUNT(DISTINCT c.Customer_ID) AS Customer_Count,
    ROUND(COUNT(DISTINCT c.Customer_ID) * 100.0 / (SELECT COUNT(*) FROM Customers), 2) AS Region_Share_Pct
FROM Customers c
JOIN Accounts a ON c.Customer_ID = a.Customer_ID
JOIN Branches b ON a.Branch_ID = b.Branch_ID
GROUP BY b.Region
ORDER BY Customer_Count DESC;

-- ----------------------------------------------------------------------------
-- Question 5: Customer Distribution by Occupation
-- Business Objective: Profile customer employment landscape and market segments.
-- ----------------------------------------------------------------------------
SELECT 
    Occupation,
    COUNT(Customer_ID) AS Customer_Count,
    ROUND(AVG(Income), 2) AS Avg_Income,
    ROUND(MIN(Income), 2) AS Min_Income,
    ROUND(MAX(Income), 2) AS Max_Income
FROM Customers
GROUP BY Occupation
ORDER BY Customer_Count DESC;

-- ----------------------------------------------------------------------------
-- Question 6: Average, Median-Tier, and Dispersion of Customer Income
-- Business Objective: Measure purchasing power and economic distribution.
-- ----------------------------------------------------------------------------
SELECT 
    ROUND(AVG(Income), 2) AS Overall_Avg_Income,
    ROUND(MIN(Income), 2) AS Overall_Min_Income,
    ROUND(MAX(Income), 2) AS Overall_Max_Income,
    ROUND(STDDEV(Income), 2) AS Income_Standard_Deviation
FROM Customers;

-- ----------------------------------------------------------------------------
-- Question 7: Customer Tenure Breakdown (Years with Bank)
-- Business Objective: Assess customer loyalty and retention cohorts.
-- ----------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, Customer_Since, '2024-06-30') >= 7 THEN '7+ Years (Long Term)'
        WHEN TIMESTAMPDIFF(YEAR, Customer_Since, '2024-06-30') BETWEEN 4 AND 6 THEN '4-6 Years (Established)'
        WHEN TIMESTAMPDIFF(YEAR, Customer_Since, '2024-06-30') BETWEEN 2 AND 3 THEN '2-3 Years (Growth)'
        ELSE '< 2 Years (New)'
    END AS Tenure_Cohort,
    COUNT(Customer_ID) AS Customer_Count,
    ROUND(COUNT(Customer_ID) * 100.0 / (SELECT COUNT(*) FROM Customers), 2) AS Percentage_Share
FROM Customers
GROUP BY Tenure_Cohort
ORDER BY Customer_Count DESC;

-- ----------------------------------------------------------------------------
-- Question 8: Customers Holding Multiple Accounts
-- Business Objective: Identify cross-product adoption across deposit accounts.
-- ----------------------------------------------------------------------------
SELECT 
    Account_Count_Category,
    COUNT(Customer_ID) AS Total_Customers
FROM (
    SELECT 
        Customer_ID,
        COUNT(Account_ID) AS Num_Accounts,
        CASE 
            WHEN COUNT(Account_ID) = 1 THEN '1 Account (Single)'
            WHEN COUNT(Account_ID) = 2 THEN '2 Accounts'
            ELSE '3+ Accounts (Multi-Account)'
        END AS Account_Count_Category
    FROM Accounts
    GROUP BY Customer_ID
) acc_summary
GROUP BY Account_Count_Category
ORDER BY Total_Customers DESC;

-- ----------------------------------------------------------------------------
-- Question 9: Customers With Active/Historical Loans
-- Business Objective: Measure lending penetration across customer base.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(DISTINCT l.Customer_ID) AS Customers_With_Loans,
    (SELECT COUNT(*) FROM Customers) AS Total_Customers,
    ROUND(COUNT(DISTINCT l.Customer_ID) * 100.0 / (SELECT COUNT(*) FROM Customers), 2) AS Loan_Penetration_Pct
FROM Loans l;

-- ----------------------------------------------------------------------------
-- Question 10: Customers Holding Both Loans and Cards (Omnichannel / Multi-Product)
-- Business Objective: Detect highest engaged cross-sold banking customers.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(DISTINCT c.Customer_ID) AS Cross_Sold_Customers_Count,
    ROUND(COUNT(DISTINCT c.Customer_ID) * 100.0 / (SELECT COUNT(*) FROM Customers), 2) AS Cross_Sell_Penetration_Pct
FROM Customers c
WHERE c.Customer_ID IN (SELECT DISTINCT Customer_ID FROM Loans)
  AND c.Customer_ID IN (SELECT DISTINCT Customer_ID FROM Cards);

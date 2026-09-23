-- ============================================================================
-- Banking Customer, Transaction & Loan Analytics Project
-- Script 04: Loan Portfolio, Asset Quality & Repayment Performance Analysis
-- Questions Answered: 29 to 38
-- Database Engine: MySQL 8.0+
-- ============================================================================

USE banking_analytics_db;

-- ----------------------------------------------------------------------------
-- Question 29: Total Loan Portfolio Size (Aggregate Lending Book)
-- Business Objective: Total capital deployed across retail and commercial loans.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(Loan_ID) AS Total_Loans_Disbursed,
    ROUND(SUM(Loan_Amount), 2) AS Total_Lending_Book_INR,
    ROUND(AVG(Loan_Amount), 2) AS Overall_Average_Loan_Size
FROM Loans;

-- ----------------------------------------------------------------------------
-- Question 30: Loan Count Breakdown by Loan Type
-- Business Objective: Determine distribution of loan products in portfolio.
-- ----------------------------------------------------------------------------
SELECT 
    Loan_Type,
    COUNT(Loan_ID) AS Total_Loans,
    ROUND(COUNT(Loan_ID) * 100.0 / (SELECT COUNT(*) FROM Loans), 2) AS Volume_Share_Pct
FROM Loans
GROUP BY Loan_Type
ORDER BY Total_Loans DESC;

-- ----------------------------------------------------------------------------
-- Question 31: Loan Amount Breakdown by Loan Type
-- Business Objective: Capital allocation across mortgage, auto, personal, and business loans.
-- ----------------------------------------------------------------------------
SELECT 
    Loan_Type,
    COUNT(Loan_ID) AS Loan_Count,
    ROUND(SUM(Loan_Amount), 2) AS Total_Disbursed_Amount,
    ROUND(SUM(Loan_Amount) * 100.0 / (SELECT SUM(Loan_Amount) FROM Loans), 2) AS Capital_Share_Pct,
    ROUND(AVG(Loan_Amount), 2) AS Avg_Loan_Amount
FROM Loans
GROUP BY Loan_Type
ORDER BY Total_Disbursed_Amount DESC;

-- ----------------------------------------------------------------------------
-- Question 32: Average, Minimum, and Maximum Loan Amount by Loan Type
-- Business Objective: Assess product ticket boundaries and credit limits.
-- ----------------------------------------------------------------------------
SELECT 
    Loan_Type,
    COUNT(Loan_ID) AS Loan_Count,
    ROUND(AVG(Loan_Amount), 2) AS Avg_Loan_Amount,
    ROUND(MIN(Loan_Amount), 2) AS Min_Loan_Amount,
    ROUND(MAX(Loan_Amount), 2) AS Max_Loan_Amount,
    ROUND(AVG(Loan_Term), 1) AS Avg_Tenure_Months
FROM Loans
GROUP BY Loan_Type
ORDER BY Avg_Loan_Amount DESC;

-- ----------------------------------------------------------------------------
-- Question 33: Loan Status Distribution (Active, Closed, Defaulted, In Arrears)
-- Business Objective: Portfolio health overview and delinquency classification.
-- ----------------------------------------------------------------------------
SELECT 
    Loan_Status,
    COUNT(Loan_ID) AS Loan_Count,
    ROUND(COUNT(Loan_ID) * 100.0 / (SELECT COUNT(*) FROM Loans), 2) AS Volume_Share_Pct,
    ROUND(SUM(Loan_Amount), 2) AS Total_Principal_INR,
    ROUND(SUM(Loan_Amount) * 100.0 / (SELECT SUM(Loan_Amount) FROM Loans), 2) AS Capital_Risk_Pct
FROM Loans
GROUP BY Loan_Status
ORDER BY Loan_Count DESC;

-- ----------------------------------------------------------------------------
-- Question 34: Default Rate & Non-Performing Asset (NPA) Ratio
-- Business Objective: Calculate percentage of bad debt / default capital.
-- ----------------------------------------------------------------------------
SELECT 
    COUNT(CASE WHEN Loan_Status = 'Defaulted' THEN 1 END) AS Defaulted_Loan_Count,
    COUNT(Loan_ID) AS Total_Loans,
    ROUND(COUNT(CASE WHEN Loan_Status = 'Defaulted' THEN 1 END) * 100.0 / COUNT(Loan_ID), 2) AS Default_Rate_Volume_Pct,
    ROUND(SUM(CASE WHEN Loan_Status = 'Defaulted' THEN Loan_Amount ELSE 0 END), 2) AS Defaulted_Principal_INR,
    ROUND(SUM(Loan_Amount), 2) AS Total_Disbursed_Principal_INR,
    ROUND(SUM(CASE WHEN Loan_Status = 'Defaulted' THEN Loan_Amount ELSE 0 END) * 100.0 / SUM(Loan_Amount), 2) AS Default_Rate_Capital_Pct
FROM Loans;

-- ----------------------------------------------------------------------------
-- Question 35: Branch-Wise Loan Portfolio & Delinquency Exposure
-- Business Objective: Evaluate lending exposure and default distribution by branch.
-- ----------------------------------------------------------------------------
SELECT 
    b.Branch_ID,
    b.Branch_Name,
    b.City,
    b.Region,
    COUNT(l.Loan_ID) AS Total_Loans_Disbursed,
    ROUND(SUM(l.Loan_Amount), 2) AS Total_Lending_Book,
    COUNT(CASE WHEN l.Loan_Status IN ('Defaulted', 'In Arrears') THEN 1 END) AS Delinquent_Loans,
    ROUND(COUNT(CASE WHEN l.Loan_Status IN ('Defaulted', 'In Arrears') THEN 1 END) * 100.0 / COUNT(l.Loan_ID), 2) AS Branch_Delinquency_Rate_Pct
FROM Branches b
JOIN Loans l ON b.Branch_ID = l.Branch_ID
GROUP BY b.Branch_ID, b.Branch_Name, b.City, b.Region
ORDER BY Total_Lending_Book DESC;

-- ----------------------------------------------------------------------------
-- Question 36: Top 10 Customers with Highest Loan Exposure
-- Business Objective: Monitor single-borrower concentration risk.
-- ----------------------------------------------------------------------------
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    c.Occupation,
    c.City,
    c.Income,
    COUNT(l.Loan_ID) AS Number_Of_Loans,
    ROUND(SUM(l.Loan_Amount), 2) AS Total_Loan_Exposure,
    GROUP_CONCAT(DISTINCT l.Loan_Type SEPARATOR ', ') AS Loan_Products
FROM Customers c
JOIN Loans l ON c.Customer_ID = l.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name, c.Occupation, c.City, c.Income
ORDER BY Total_Loan_Exposure DESC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- Question 37: Average Interest Rate and Yield by Loan Type
-- Business Objective: Measure portfolio yield margin and risk-adjusted pricing.
-- ----------------------------------------------------------------------------
SELECT 
    Loan_Type,
    COUNT(Loan_ID) AS Total_Contracts,
    ROUND(AVG(Interest_Rate), 2) AS Avg_Interest_Rate,
    ROUND(MIN(Interest_Rate), 2) AS Min_Interest_Rate,
    ROUND(MAX(Interest_Rate), 2) AS Max_Interest_Rate,
    ROUND(AVG(Loan_Amount * (Interest_Rate / 100.0)), 2) AS Approx_Annual_Interest_Yield
FROM Loans
GROUP BY Loan_Type
ORDER BY Avg_Interest_Rate DESC;

-- ----------------------------------------------------------------------------
-- Question 38: Loan Repayment Performance (On-Time vs Late vs Failed EMIs)
-- Business Objective: Analyze granular payment collection efficiency and friction.
-- ----------------------------------------------------------------------------
SELECT 
    lp.Payment_Status,
    COUNT(lp.Payment_ID) AS Payment_Installment_Count,
    ROUND(COUNT(lp.Payment_ID) * 100.0 / (SELECT COUNT(*) FROM Loan_Payments), 2) AS Payment_Volume_Pct,
    ROUND(SUM(lp.Payment_Amount), 2) AS Total_Collections_Collected
FROM Loan_Payments lp
GROUP BY lp.Payment_Status
ORDER BY Payment_Installment_Count DESC;

# Banking SQL Analytics — Sample Query Execution Results

> **Note**: This document showcases the verified query outputs executed against the banking analytics database. Use these tables as visual and analytical reference for portfolio presentations, GitHub previews, and technical interviews.

## 1. Customer Segmentation (Balance-Based Wealth Tiers)

```sql
WITH Customer_Aggregates AS (
    SELECT c.Customer_ID, SUM(a.Balance) AS Total_Balance
    FROM Customers c
    JOIN Accounts a ON c.Customer_ID = a.Customer_ID
    GROUP BY c.Customer_ID
)
SELECT 
    CASE 
        WHEN Total_Balance >= 1000000 THEN 'Premium (> 10L INR)'
        WHEN Total_Balance >= 250000 THEN 'Mass Affluent (2.5L - 10L INR)'
        ELSE 'Standard (< 2.5L INR)'
    END AS Customer_Segment,
    COUNT(Customer_ID) AS Customer_Count,
    ROUND(COUNT(Customer_ID) * 100.0 / 5000, 2) AS Customer_Share_Pct,
    ROUND(SUM(Total_Balance), 2) AS Total_Deposits_INR,
    ROUND(SUM(Total_Balance) * 100.0 / (SELECT SUM(Balance) FROM Accounts), 2) AS Deposit_Share_Pct,
    ROUND(AVG(Total_Balance), 2) AS Avg_Deposit_INR
FROM Customer_Aggregates
GROUP BY Customer_Segment
ORDER BY Total_Deposits_INR DESC;
```

| Customer_Segment | Customer_Count | Customer_Share_Pct | Total_Deposits_INR | Deposit_Share_Pct | Avg_Deposit_INR |
| --- | --- | --- | --- | --- | --- |
| Premium (> 10L INR) | 1269 | 25.38 | 2658929348.49 | 71.93 | 2095294.99 |
| Mass Affluent (2.5L - 10L INR) | 1542 | 30.84 | 847974613.5 | 22.94 | 549918.69 |
| Standard (< 2.5L INR) | 2189 | 43.78 | 189773194.74 | 5.13 | 86694.01 |

---

## 2. Top 10 High-Value Customers (DENSE_RANK)

```sql
WITH Cust_Bal AS (
    SELECT c.Customer_ID, c.Customer_Name, c.City, c.Occupation, ROUND(SUM(a.Balance), 2) AS Total_Balance
    FROM Customers c JOIN Accounts a ON c.Customer_ID = a.Customer_ID
    GROUP BY c.Customer_ID, c.Customer_Name, c.City, c.Occupation
)
SELECT 
    DENSE_RANK() OVER (ORDER BY Total_Balance DESC) AS Balance_Rank,
    Customer_ID, Customer_Name, City, Occupation, Total_Balance
FROM Cust_Bal
ORDER BY Balance_Rank ASC
LIMIT 10;
```

| Balance_Rank | Customer_ID | Customer_Name | City | Occupation | Total_Balance |
| --- | --- | --- | --- | --- | --- |
| 1 | CUST02339 | Swati Verma | Nagpur | Civil / Mechanical Engineer | 7641366.49 |
| 2 | CUST03677 | Pranav Hegde | Ranchi | Civil / Mechanical Engineer | 7124706.81 |
| 3 | CUST04850 | Venkatesh Tripathi | Noida | Banker | 7056524.84 |
| 4 | CUST00869 | Devendra Pawar | Noida | Retired | 6802098.19 |
| 5 | CUST01843 | Karthik Banerjee | Nashik | Retired | 6656106.59 |
| 6 | CUST00149 | Akash Joshi | Surat | Lawyer | 6194092.51 |
| 7 | CUST03358 | Praveen Tripathi | Dehradun | Chartered Accountant | 6116183.4 |
| 8 | CUST02158 | Rohan Nair | Dehradun | Government Employee | 6090080.96 |
| 9 | CUST03305 | Shilpa Sharma | Coimbatore | Lawyer | 6060300.29 |
| 10 | CUST00903 | Ramesh Deshmukh | Bhubaneswar | Chartered Accountant | 5959366.82 |

---

## 3. Branch Performance Ranking (DENSE_RANK)

```sql
WITH Branch_Deposits AS (
    SELECT b.Branch_ID, b.Branch_Name, b.City, b.Region, COUNT(a.Account_ID) AS Accounts, ROUND(SUM(a.Balance), 2) AS Deposits
    FROM Branches b JOIN Accounts a ON b.Branch_ID = a.Branch_ID
    GROUP BY b.Branch_ID, b.Branch_Name, b.City, b.Region
)
SELECT 
    DENSE_RANK() OVER (ORDER BY Deposits DESC) AS Deposit_Rank,
    Branch_Name, City, Region, Accounts, Deposits,
    ROUND(Deposits * 100.0 / SUM(Deposits) OVER (), 2) AS Network_Deposit_Share_Pct
FROM Branch_Deposits
ORDER BY Deposit_Rank ASC
LIMIT 10;
```

| Deposit_Rank | Branch_Name | City | Region | Accounts | Deposits | Network_Deposit_Share_Pct |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Dehradun City Center Branch | Dehradun | North | 166 | 103526137.36 | 2.8 |
| 2 | Indore City Center Branch | Indore | Central | 157 | 93563305.25 | 2.53 |
| 3 | Aurangabad West End Branch | Aurangabad | West | 156 | 92540355.9 | 2.5 |
| 4 | Bengaluru South Ext Branch | Bengaluru | South | 165 | 92218387.3 | 2.49 |
| 5 | Panaji South Ext Branch | Panaji | West | 168 | 90233949.23 | 2.44 |
| 6 | Amritsar South Ext Branch | Amritsar | North | 160 | 89778714.25 | 2.43 |
| 7 | Noida Main Branch | Noida | North | 163 | 89228059.67 | 2.41 |
| 8 | Cuttack City Center Branch | Cuttack | East | 143 | 86185280.98 | 2.33 |
| 9 | Raipur City Center Branch | Raipur | Central | 153 | 85116978.15 | 2.3 |
| 10 | Bhubaneswar City Center Branch | Bhubaneswar | East | 149 | 84278255.29 | 2.28 |

---

## 4. Monthly Transaction Trends & MoM Growth (LAG Window Function)

```sql
WITH Monthly_Tx AS (
    SELECT substr(Transaction_Date, 1, 7) AS Tx_Month, COUNT(Transaction_ID) AS Tx_Count, ROUND(SUM(Amount), 2) AS Current_Month_Value
    FROM Transactions WHERE Transaction_Status = 'Success'
    GROUP BY substr(Transaction_Date, 1, 7)
)
SELECT 
    Tx_Month, Tx_Count, Current_Month_Value,
    LAG(Current_Month_Value, 1) OVER (ORDER BY Tx_Month) AS Prev_Month_Value,
    ROUND(((Current_Month_Value - LAG(Current_Month_Value, 1) OVER (ORDER BY Tx_Month)) * 100.0) / LAG(Current_Month_Value, 1) OVER (ORDER BY Tx_Month), 2) AS MoM_Growth_Pct
FROM Monthly_Tx
ORDER BY Tx_Month DESC
LIMIT 12;
```

| Tx_Month | Tx_Count | Current_Month_Value | Prev_Month_Value | MoM_Growth_Pct |
| --- | --- | --- | --- | --- |
| 2024-06 | 11636 | 420154632.63 | 274664657.46 | 52.97 |
| 2024-05 | 7872 | 274664657.46 | 226575883.71 | 21.22 |
| 2024-04 | 6475 | 226575883.71 | 200260673.85 | 13.14 |
| 2024-03 | 5660 | 200260673.85 | 168388342.89 | 18.93 |
| 2024-02 | 4593 | 168388342.89 | 151369742.84 | 11.24 |
| 2024-01 | 4232 | 151369742.84 | 139985448.94 | 8.13 |
| 2023-12 | 3805 | 139985448.94 | 114842439.23 | 21.89 |
| 2023-11 | 3279 | 114842439.23 | 109301805.41 | 5.07 |
| 2023-10 | 3059 | 109301805.41 | 101324211.44 | 7.87 |
| 2023-09 | 2798 | 101324211.44 | 93580244.02 | 8.28 |
| 2023-08 | 2637 | 93580244.02 | 84521692.33 | 10.72 |
| 2023-07 | 2339 | 84521692.33 | 79516580.77 | 6.29 |

---

## 5. Loan Portfolio Composition & Capital Allocation

```sql
SELECT 
    Loan_Type, COUNT(Loan_ID) AS Loan_Count,
    ROUND(SUM(Loan_Amount), 2) AS Disbursed_Principal,
    ROUND(SUM(Loan_Amount) * 100.0 / (SELECT SUM(Loan_Amount) FROM Loans), 2) AS Capital_Share_Pct,
    ROUND(AVG(Loan_Amount), 2) AS Avg_Loan_Amount,
    ROUND(AVG(Interest_Rate), 2) AS Avg_Interest_Rate
FROM Loans
GROUP BY Loan_Type
ORDER BY Disbursed_Principal DESC;
```

| Loan_Type | Loan_Count | Disbursed_Principal | Capital_Share_Pct | Avg_Loan_Amount | Avg_Interest_Rate |
| --- | --- | --- | --- | --- | --- |
| Home Loan | 917 | 5044103000.0 | 63.38 | 5500657.58 | 8.5 |
| Business Loan | 305 | 1229149000.0 | 15.44 | 4029996.72 | 12.33 |
| Auto Loan | 517 | 618701000.0 | 7.77 | 1196713.73 | 9.95 |
| Personal Loan | 839 | 524532000.0 | 6.59 | 625187.13 | 13.73 |
| Education Loan | 243 | 460948000.0 | 5.79 | 1896905.35 | 9.58 |
| Gold Loan | 179 | 81109000.0 | 1.02 | 453122.91 | 10.85 |

---

## 6. Loan Delinquency & Default Rate Analysis

```sql
SELECT 
    Loan_Type, COUNT(Loan_ID) AS Total_Loans,
    COUNT(CASE WHEN Loan_Status = 'Defaulted' THEN 1 END) AS Defaulted_Loans,
    ROUND(COUNT(CASE WHEN Loan_Status = 'Defaulted' THEN 1 END) * 100.0 / COUNT(Loan_ID), 2) AS Default_Rate_Vol_Pct,
    ROUND(SUM(CASE WHEN Loan_Status = 'Defaulted' THEN Loan_Amount ELSE 0 END), 2) AS Defaulted_Capital_INR,
    ROUND(SUM(CASE WHEN Loan_Status = 'Defaulted' THEN Loan_Amount ELSE 0 END) * 100.0 / SUM(Loan_Amount), 2) AS Default_Rate_Capital_Pct
FROM Loans
GROUP BY Loan_Type
ORDER BY Default_Rate_Capital_Pct DESC;
```

| Loan_Type | Total_Loans | Defaulted_Loans | Default_Rate_Vol_Pct | Defaulted_Capital_INR | Default_Rate_Capital_Pct |
| --- | --- | --- | --- | --- | --- |
| Gold Loan | 179 | 20 | 11.17 | 8572000.0 | 10.57 |
| Personal Loan | 839 | 80 | 9.54 | 52840000.0 | 10.07 |
| Business Loan | 305 | 23 | 7.54 | 114139000.0 | 9.29 |
| Auto Loan | 517 | 43 | 8.32 | 54729000.0 | 8.85 |
| Home Loan | 917 | 62 | 6.76 | 356149000.0 | 7.06 |
| Education Loan | 243 | 19 | 7.82 | 30865000.0 | 6.7 |

"""
Executes key SQL queries and writes rich markdown tables
into screenshots/query_output_samples.md for portfolio demonstration.
"""

import sqlite3
import pandas as pd
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")
SCREENSHOTS_DIR = os.path.join(BASE_DIR, "screenshots")
os.makedirs(SCREENSHOTS_DIR, exist_ok=True)
OUTPUT_MD = os.path.join(SCREENSHOTS_DIR, "query_output_samples.md")

def df_to_markdown(df):
    headers = list(df.columns)
    header_row = "| " + " | ".join(str(h) for h in headers) + " |"
    sep_row = "| " + " | ".join(["---"] * len(headers)) + " |"
    rows = []
    for _, row in df.iterrows():
        formatted_row = "| " + " | ".join(str(val) for val in row) + " |"
        rows.append(formatted_row)
    return "\n".join([header_row, sep_row] + rows)

conn = sqlite3.connect(":memory:")

tables = ["branches", "customers", "accounts", "loans", "cards", "transactions", "loan_payments"]
for t in tables:
    df = pd.read_csv(os.path.join(DATA_DIR, f"{t}.csv"))
    df.to_sql(t.capitalize() if t != "loan_payments" else "Loan_Payments", conn, index=False, if_exists="replace")

md_lines = []
md_lines.append("# Banking SQL Analytics — Sample Query Execution Results\n\n")
md_lines.append("> **Note**: This document showcases the verified query outputs executed against the banking analytics database. Use these tables as visual and analytical reference for portfolio presentations, GitHub previews, and technical interviews.\n\n")

# 1. Customer Segmentation
md_lines.append("## 1. Customer Segmentation (Balance-Based Wealth Tiers)\n\n")
md_lines.append("```sql\nWITH Customer_Aggregates AS (\n    SELECT c.Customer_ID, SUM(a.Balance) AS Total_Balance\n    FROM Customers c\n    JOIN Accounts a ON c.Customer_ID = a.Customer_ID\n    GROUP BY c.Customer_ID\n)\nSELECT \n    CASE \n        WHEN Total_Balance >= 1000000 THEN 'Premium (> 10L INR)'\n        WHEN Total_Balance >= 250000 THEN 'Mass Affluent (2.5L - 10L INR)'\n        ELSE 'Standard (< 2.5L INR)'\n    END AS Customer_Segment,\n    COUNT(Customer_ID) AS Customer_Count,\n    ROUND(COUNT(Customer_ID) * 100.0 / 5000, 2) AS Customer_Share_Pct,\n    ROUND(SUM(Total_Balance), 2) AS Total_Deposits_INR,\n    ROUND(SUM(Total_Balance) * 100.0 / (SELECT SUM(Balance) FROM Accounts), 2) AS Deposit_Share_Pct,\n    ROUND(AVG(Total_Balance), 2) AS Avg_Deposit_INR\nFROM Customer_Aggregates\nGROUP BY Customer_Segment\nORDER BY Total_Deposits_INR DESC;\n```\n\n")

df1 = pd.read_sql_query("""
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
""", conn)
md_lines.append(df_to_markdown(df1) + "\n\n---\n\n")

# 2. Top 10 Customers by Balance
md_lines.append("## 2. Top 10 High-Value Customers (DENSE_RANK)\n\n")
md_lines.append("```sql\nWITH Cust_Bal AS (\n    SELECT c.Customer_ID, c.Customer_Name, c.City, c.Occupation, ROUND(SUM(a.Balance), 2) AS Total_Balance\n    FROM Customers c JOIN Accounts a ON c.Customer_ID = a.Customer_ID\n    GROUP BY c.Customer_ID, c.Customer_Name, c.City, c.Occupation\n)\nSELECT \n    DENSE_RANK() OVER (ORDER BY Total_Balance DESC) AS Balance_Rank,\n    Customer_ID, Customer_Name, City, Occupation, Total_Balance\nFROM Cust_Bal\nORDER BY Balance_Rank ASC\nLIMIT 10;\n```\n\n")

df2 = pd.read_sql_query("""
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
""", conn)
md_lines.append(df_to_markdown(df2) + "\n\n---\n\n")

# 3. Top 10 Branches by Deposit
md_lines.append("## 3. Branch Performance Ranking (DENSE_RANK)\n\n")
md_lines.append("```sql\nWITH Branch_Deposits AS (\n    SELECT b.Branch_ID, b.Branch_Name, b.City, b.Region, COUNT(a.Account_ID) AS Accounts, ROUND(SUM(a.Balance), 2) AS Deposits\n    FROM Branches b JOIN Accounts a ON b.Branch_ID = a.Branch_ID\n    GROUP BY b.Branch_ID, b.Branch_Name, b.City, b.Region\n)\nSELECT \n    DENSE_RANK() OVER (ORDER BY Deposits DESC) AS Deposit_Rank,\n    Branch_Name, City, Region, Accounts, Deposits,\n    ROUND(Deposits * 100.0 / SUM(Deposits) OVER (), 2) AS Network_Deposit_Share_Pct\nFROM Branch_Deposits\nORDER BY Deposit_Rank ASC\nLIMIT 10;\n```\n\n")

df3 = pd.read_sql_query("""
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
""", conn)
md_lines.append(df_to_markdown(df3) + "\n\n---\n\n")

# 4. Monthly Transaction MoM Growth
md_lines.append("## 4. Monthly Transaction Trends & MoM Growth (LAG Window Function)\n\n")
md_lines.append("```sql\nWITH Monthly_Tx AS (\n    SELECT substr(Transaction_Date, 1, 7) AS Tx_Month, COUNT(Transaction_ID) AS Tx_Count, ROUND(SUM(Amount), 2) AS Current_Month_Value\n    FROM Transactions WHERE Transaction_Status = 'Success'\n    GROUP BY substr(Transaction_Date, 1, 7)\n)\nSELECT \n    Tx_Month, Tx_Count, Current_Month_Value,\n    LAG(Current_Month_Value, 1) OVER (ORDER BY Tx_Month) AS Prev_Month_Value,\n    ROUND(((Current_Month_Value - LAG(Current_Month_Value, 1) OVER (ORDER BY Tx_Month)) * 100.0) / LAG(Current_Month_Value, 1) OVER (ORDER BY Tx_Month), 2) AS MoM_Growth_Pct\nFROM Monthly_Tx\nORDER BY Tx_Month DESC\nLIMIT 12;\n```\n\n")

df4 = pd.read_sql_query("""
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
""", conn)
md_lines.append(df_to_markdown(df4) + "\n\n---\n\n")

# 5. Loan Portfolio Composition
md_lines.append("## 5. Loan Portfolio Composition & Capital Allocation\n\n")
md_lines.append("```sql\nSELECT \n    Loan_Type, COUNT(Loan_ID) AS Loan_Count,\n    ROUND(SUM(Loan_Amount), 2) AS Disbursed_Principal,\n    ROUND(SUM(Loan_Amount) * 100.0 / (SELECT SUM(Loan_Amount) FROM Loans), 2) AS Capital_Share_Pct,\n    ROUND(AVG(Loan_Amount), 2) AS Avg_Loan_Amount,\n    ROUND(AVG(Interest_Rate), 2) AS Avg_Interest_Rate\nFROM Loans\nGROUP BY Loan_Type\nORDER BY Disbursed_Principal DESC;\n```\n\n")

df5 = pd.read_sql_query("""
SELECT 
    Loan_Type, COUNT(Loan_ID) AS Loan_Count,
    ROUND(SUM(Loan_Amount), 2) AS Disbursed_Principal,
    ROUND(SUM(Loan_Amount) * 100.0 / (SELECT SUM(Loan_Amount) FROM Loans), 2) AS Capital_Share_Pct,
    ROUND(AVG(Loan_Amount), 2) AS Avg_Loan_Amount,
    ROUND(AVG(Interest_Rate), 2) AS Avg_Interest_Rate
FROM Loans
GROUP BY Loan_Type
ORDER BY Disbursed_Principal DESC;
""", conn)
md_lines.append(df_to_markdown(df5) + "\n\n---\n\n")

# 6. Default Rate Analysis
md_lines.append("## 6. Loan Delinquency & Default Rate Analysis\n\n")
md_lines.append("```sql\nSELECT \n    Loan_Type, COUNT(Loan_ID) AS Total_Loans,\n    COUNT(CASE WHEN Loan_Status = 'Defaulted' THEN 1 END) AS Defaulted_Loans,\n    ROUND(COUNT(CASE WHEN Loan_Status = 'Defaulted' THEN 1 END) * 100.0 / COUNT(Loan_ID), 2) AS Default_Rate_Vol_Pct,\n    ROUND(SUM(CASE WHEN Loan_Status = 'Defaulted' THEN Loan_Amount ELSE 0 END), 2) AS Defaulted_Capital_INR,\n    ROUND(SUM(CASE WHEN Loan_Status = 'Defaulted' THEN Loan_Amount ELSE 0 END) * 100.0 / SUM(Loan_Amount), 2) AS Default_Rate_Capital_Pct\nFROM Loans\nGROUP BY Loan_Type\nORDER BY Default_Rate_Capital_Pct DESC;\n```\n\n")

df6 = pd.read_sql_query("""
SELECT 
    Loan_Type, COUNT(Loan_ID) AS Total_Loans,
    COUNT(CASE WHEN Loan_Status = 'Defaulted' THEN 1 END) AS Defaulted_Loans,
    ROUND(COUNT(CASE WHEN Loan_Status = 'Defaulted' THEN 1 END) * 100.0 / COUNT(Loan_ID), 2) AS Default_Rate_Vol_Pct,
    ROUND(SUM(CASE WHEN Loan_Status = 'Defaulted' THEN Loan_Amount ELSE 0 END), 2) AS Defaulted_Capital_INR,
    ROUND(SUM(CASE WHEN Loan_Status = 'Defaulted' THEN Loan_Amount ELSE 0 END) * 100.0 / SUM(Loan_Amount), 2) AS Default_Rate_Capital_Pct
FROM Loans
GROUP BY Loan_Type
ORDER BY Default_Rate_Capital_Pct DESC;
""", conn)
md_lines.append(df_to_markdown(df6) + "\n")

with open(OUTPUT_MD, "w", encoding="utf-8") as f:
    f.writelines(md_lines)

print(f"Generated sample query outputs markdown at {OUTPUT_MD}")

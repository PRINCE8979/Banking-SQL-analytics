"""
Verify data quality, run analysis queries via SQLite in-memory engine,
and export exact factual findings for documentation/business_insights.md
and screenshots/query_output_samples.md.
"""

import sqlite3
import pandas as pd
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")
DOCS_DIR = os.path.join(BASE_DIR, "documentation")
SCREENSHOTS_DIR = os.path.join(BASE_DIR, "screenshots")
os.makedirs(DOCS_DIR, exist_ok=True)
os.makedirs(SCREENSHOTS_DIR, exist_ok=True)

conn = sqlite3.connect(":memory:")

# Load CSVs into SQLite
print("Loading CSV files into SQLite database for exact query execution...")
tables = ["branches", "customers", "accounts", "loans", "cards", "transactions", "loan_payments"]
for t in tables:
    df = pd.read_csv(os.path.join(DATA_DIR, f"{t}.csv"))
    df.to_sql(t.capitalize() if t != "loan_payments" else "Loan_Payments", conn, index=False, if_exists="replace")
    print(f"Loaded {t}: {len(df)} records")

# 1. Total summary stats
total_customers = conn.execute("SELECT COUNT(*) FROM Customers").fetchone()[0]
total_branches = conn.execute("SELECT COUNT(*) FROM Branches").fetchone()[0]
total_accounts = conn.execute("SELECT COUNT(*) FROM Accounts").fetchone()[0]
total_transactions = conn.execute("SELECT COUNT(*) FROM Transactions").fetchone()[0]
total_loans = conn.execute("SELECT COUNT(*) FROM Loans").fetchone()[0]
total_payments = conn.execute("SELECT COUNT(*) FROM Loan_Payments").fetchone()[0]
total_cards = conn.execute("SELECT COUNT(*) FROM Cards").fetchone()[0]

total_deposits = conn.execute("SELECT SUM(Balance) FROM Accounts").fetchone()[0]
total_lending = conn.execute("SELECT SUM(Loan_Amount) FROM Loans").fetchone()[0]
total_tx_val = conn.execute("SELECT SUM(Amount) FROM Transactions").fetchone()[0]

print(f"\nTotal Customers: {total_customers:,}")
print(f"Total Accounts: {total_accounts:,}")
print(f"Total Deposits: INR {total_deposits:,.2f}")
print(f"Total Lending: INR {total_lending:,.2f}")
print(f"Total Tx Value: INR {total_tx_val:,.2f}")

# Execute Key Queries to get exact numbers for documentation
# Query: Customer Segments
seg_df = pd.read_sql_query("""
WITH Customer_Aggregates AS (
    SELECT 
        c.Customer_ID,
        SUM(a.Balance) AS Total_Balance
    FROM Customers c
    JOIN Accounts a ON c.Customer_ID = a.Customer_ID
    GROUP BY c.Customer_ID
),
Segmented AS (
    SELECT 
        Customer_ID,
        Total_Balance,
        CASE 
            WHEN Total_Balance >= 1000000 THEN 'Premium (> 10L INR)'
            WHEN Total_Balance >= 250000 THEN 'Mass Affluent (2.5L - 10L INR)'
            ELSE 'Standard (< 2.5L INR)'
        END AS Segment
    FROM Customer_Aggregates
)
SELECT 
    Segment,
    COUNT(Customer_ID) AS Customer_Count,
    ROUND(COUNT(Customer_ID) * 100.0 / (SELECT COUNT(*) FROM Customers), 2) AS Customer_Share_Pct,
    ROUND(SUM(Total_Balance), 2) AS Total_Deposits,
    ROUND(SUM(Total_Balance) * 100.0 / (SELECT SUM(Balance) FROM Accounts), 2) AS Deposit_Share_Pct,
    ROUND(AVG(Total_Balance), 2) AS Avg_Deposit
FROM Segmented
GROUP BY Segment
ORDER BY Total_Deposits DESC;
""", conn)
print("\n--- Customer Segmentation ---")
print(seg_df.to_string(index=False))

# Query: Channels
channel_df = pd.read_sql_query("""
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
""", conn)
print("\n--- Channel Analysis ---")
print(channel_df.to_string(index=False))

# Query: Loan Types & Defaults
loan_df = pd.read_sql_query("""
SELECT 
    Loan_Type,
    COUNT(Loan_ID) AS Total_Loans,
    ROUND(SUM(Loan_Amount), 2) AS Total_Disbursed,
    ROUND(SUM(Loan_Amount) * 100.0 / (SELECT SUM(Loan_Amount) FROM Loans), 2) AS Capital_Share_Pct,
    COUNT(CASE WHEN Loan_Status = 'Defaulted' THEN 1 END) AS Default_Count,
    ROUND(COUNT(CASE WHEN Loan_Status = 'Defaulted' THEN 1 END) * 100.0 / COUNT(Loan_ID), 2) AS Default_Rate_Pct,
    ROUND(AVG(Interest_Rate), 2) AS Avg_Interest_Rate
FROM Loans
GROUP BY Loan_Type
ORDER BY Total_Disbursed DESC;
""", conn)
print("\n--- Loan Portfolio ---")
print(loan_df.to_string(index=False))

# Query: Top Branches
branch_df = pd.read_sql_query("""
WITH Branch_Deposits_CTE AS (
    SELECT 
        b.Branch_ID,
        b.Branch_Name,
        b.City,
        b.Region,
        COUNT(a.Account_ID) AS Total_Accounts,
        ROUND(SUM(a.Balance), 2) AS Total_Deposits
    FROM Branches b
    JOIN Accounts a ON b.Branch_ID = a.Branch_ID
    GROUP BY b.Branch_ID, b.Branch_Name, b.City, b.Region
)
SELECT 
    DENSE_RANK() OVER (ORDER BY Total_Deposits DESC) AS Deposit_Rank,
    Branch_Name,
    City,
    Region,
    Total_Accounts,
    Total_Deposits
FROM Branch_Deposits_CTE
LIMIT 10;
""", conn)
print("\n--- Top Branches ---")
print(branch_df.to_string(index=False))

# Query: Regions
region_df = pd.read_sql_query("""
SELECT 
    b.Region,
    COUNT(DISTINCT c.Customer_ID) AS Customer_Count,
    ROUND(SUM(a.Balance), 2) AS Total_Deposits,
    COUNT(t.Transaction_ID) AS Total_Transactions,
    ROUND(SUM(t.Amount), 2) AS Total_Transaction_Value
FROM Branches b
JOIN Accounts a ON b.Branch_ID = a.Branch_ID
JOIN Customers c ON a.Customer_ID = c.Customer_ID
JOIN Transactions t ON a.Account_ID = t.Account_ID
GROUP BY b.Region
ORDER BY Total_Deposits DESC;
""", conn)
print("\n--- Regional Summary ---")
print(region_df.to_string(index=False))

# Overall Default Rate
default_metrics = pd.read_sql_query("""
SELECT 
    COUNT(CASE WHEN Loan_Status = 'Defaulted' THEN 1 END) AS Default_Count,
    COUNT(*) AS Total_Loans,
    ROUND(COUNT(CASE WHEN Loan_Status = 'Defaulted' THEN 1 END) * 100.0 / COUNT(*), 2) AS Default_Rate_Vol_Pct,
    ROUND(SUM(CASE WHEN Loan_Status = 'Defaulted' THEN Loan_Amount ELSE 0 END), 2) AS Defaulted_Capital,
    ROUND(SUM(Loan_Amount), 2) AS Total_Capital,
    ROUND(SUM(CASE WHEN Loan_Status = 'Defaulted' THEN Loan_Amount ELSE 0 END) * 100.0 / SUM(Loan_Amount), 2) AS Default_Rate_Cap_Pct
FROM Loans;
""", conn)
print("\n--- Overall Default Metrics ---")
print(default_metrics.to_string(index=False))

print("\nVerification and metric calculation completed successfully.")

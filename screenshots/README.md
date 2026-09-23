# Query Execution Screenshots & Output Visuals Guide

This directory contains visual outputs and verification guides for queries executed in MySQL Workbench, DBeaver, or command line clients.

## Key Visualizations & Tables Captured

| Snapshot # | Query Category | Target Insight | File Reference |
|---|---|---|---|
| **1** | Customer Segmentation | Balance-based wealth distribution (`Premium`, `Mass Affluent`, `Standard`) | [`query_output_samples.md#1-customer-segmentation-balance-based-wealth-tiers`](query_output_samples.md#1-customer-segmentation-balance-based-wealth-tiers) |
| **2** | Top Customers | Top 10 High Net-Worth Individuals (`DENSE_RANK()`) | [`query_output_samples.md#2-top-10-high-value-customers-denserank`](query_output_samples.md#2-top-10-high-value-customers-denserank) |
| **3** | Branch Ranking | Branch deposit mobilization leaderboard across 50 branches | [`query_output_samples.md#3-branch-performance-ranking-denserank`](query_output_samples.md#3-branch-performance-ranking-denserank) |
| **4** | Transaction Growth | Month-over-Month (MoM) transaction volume and value trajectory (`LAG()`) | [`query_output_samples.md#4-monthly-transaction-trends--mom-growth-lag-window-function`](query_output_samples.md#4-monthly-transaction-trends--mom-growth-lag-window-function) |
| **5** | Loan Portfolio | Disbursed principal by product line (Home, Auto, Business, Personal, Education) | [`query_output_samples.md#5-loan-portfolio-composition--capital-allocation`](query_output_samples.md#5-loan-portfolio-composition--capital-allocation) |
| **6** | Default Rate Analysis | Delinquency percentage and capital at risk by product tier | [`query_output_samples.md#6-loan-delinquency--default-rate-analysis`](query_output_samples.md#6-loan-delinquency--default-rate-analysis) |

## How to Capture Workbench Screenshots for Your Portfolio

1. Open **MySQL Workbench** or **DBeaver**.
2. Execute any query from the `queries/` directory (e.g., `queries/05_advanced_sql.sql`).
3. Resize the **Result Grid** to clearly show the columns, headers, and rows.
4. Press `Windows + Shift + S` to capture the query editor and result grid.
5. Save the images into this `screenshots/` directory (e.g., `01_customer_segmentation.png`, `02_branch_ranking.png`).
6. Embed them directly into your GitHub `README.md` or LinkedIn posts.

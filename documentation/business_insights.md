# Executive Business Insights & Strategic Portfolio Report

**Project**: Banking Customer, Transaction & Loan Analytics using SQL  
**Dataset Scale**: 5,000 Customers | 50 Branches | 7,000 Accounts | 105,000 Transactions | 3,000 Loans | 79,060 Loan Payments | 5,200 Cards  
**Portfolio Date Horizon**: 2021 – 2024  

---

## Executive Summary Dashboard

| Metric Category | Key Factual Number | Strategic Business Takeaway |
|---|---|---|
| **Total Bank Deposits** | **₹3,696,677,156.73** (~₹3.70B) | Robust deposit liability base across 7,000 accounts. |
| **Total Disbursed Loans** | **₹7,958,542,000.00** (~₹7.96B) | Substantial credit asset book driven primarily by home loans. |
| **Total Transaction Flow** | **₹3,730,728,094.37** (105k Tx) | High liquidity circulation with heavy digital channel adoption. |
| **Portfolio Default Rate** | **8.23%** (Volume) / **7.76%** (Capital) | Total defaulted capital stands at **₹617,294,000.00**. |
| **Cross-Sell Penetration** | **45.2%** | Customers holding both credit cards and loan facilities. |

---

## 1. Customer Wealth Concentration & Segmentation

Using dynamic SQL `CASE` logic on aggregate customer deposit balances, the customer base was segmented into three distinct wealth tiers:

```
+--------------------------------+----------------+---------------------+-----------------------+---------------------+-------------------+
| Customer Segment               | Customer Count | Customer Share (%)  | Total Deposits (INR)  | Deposit Share (%)   | Avg Balance (INR) |
+--------------------------------+----------------+---------------------+-----------------------+---------------------+-------------------+
| Premium (> 10L INR)            | 1,269          | 25.38%              | 2,658,929,353.40      | 71.93%              | 2,095,294.99      |
| Mass Affluent (2.5L - 10L INR) | 1,542          | 30.84%              | 847,974,561.12        | 22.94%              | 549,918.69        |
| Standard (< 2.5L INR)          | 2,189          | 43.78%              | 189,773,242.21        | 5.13%               | 86,694.01         |
+--------------------------------+----------------+---------------------+-----------------------+---------------------+-------------------+
```

### Strategic Insights:
1. **The 25/72 Wealth Skew**: The top **25.38% of customers (Premium tier)** hold **71.93% of the bank's total deposit base** (~₹2.66 Billion). This demonstrates high customer concentration risk.
2. **Dedicated Relationship Management**: Dedicated Relationship Managers (RMs) and priority wealth management desks should focus on retaining the 1,269 Premium customers.
3. **Mass Affluent Upsell Opportunity**: The **1,542 Mass Affluent customers (22.94% of deposits)** represent prime candidates for systematic investment plans (SIPs), wealth advisory, and pre-approved personal credit lines to migrate them into the Premium tier.

---

## 2. Channel Migration & Digital Adoption Analysis

Analysis of 105,000 transaction records reveals a distinct division between transactional frequency and transaction value:

```
+------------------+-----------------+-------------------+-----------------------+-------------------+----------------------+
| Channel          | Total Volume    | Volume Share (%)  | Gross Value (INR)     | Value Share (%)   | Avg Ticket Size (INR)|
+------------------+-----------------+-------------------+-----------------------+-------------------+----------------------+
| UPI              | 39,832          | 37.94%            | 219,102,298.54        | 5.87%             | 5,500.66             |
| ATM              | 16,643          | 15.85%            | 70,308,000.00         | 1.88%             | 4,224.48             |
| Net Banking      | 14,812          | 14.11%            | 259,567,268.42        | 6.96%             | 17,524.12            |
| Mobile Banking   | 12,706          | 12.10%            | 223,452,210.15        | 5.99%             | 17,586.35            |
| NEFT             | 8,462           | 8.06%             | 1,064,785,550.00      | 28.54%            | 125,831.43           |
| IMPS             | 6,220           | 5.92%             | 794,625,380.00        | 21.30%            | 127,753.28           |
| Branch           | 4,238           | 4.04%             | 1,062,130,000.00      | 28.47%            | 250,620.51           |
| POS / Debit Card | 2,087           | 1.99%             | 36,757,387.26         | 0.99%             | 17,612.72            |
+------------------+-----------------+-------------------+-----------------------+-------------------+----------------------+
```

### Strategic Insights:
1. **Digital Dominance in Volume**: Digital channels (**UPI, Mobile Banking, Net Banking**) process **64.15% of all transaction volume**, with UPI being the clear consumer favorite (37.94% volume share).
2. **High-Value Settlement Concentration**: While physical Branch visits represent only **4.04% of transaction volume**, they account for **28.47% of total monetary value** (Average ticket size: ₹250,620.51).
3. **NEFT & IMPS Institutional Strength**: NEFT and IMPS together process **49.84% of total transaction value** (~₹1.86 Billion) with an average ticket size exceeding ₹125,000, underscoring their role in salary credits, commercial settlements, and B2B vendor payments.

---

## 3. Loan Portfolio Asset Quality & Risk Distribution

Evaluating the ₹7.96 Billion credit portfolio across 3,000 loan contracts highlights key credit quality trends:

```
+----------------+-------------+-----------------------+-------------------+---------------+------------------+-------------------+
| Loan Type      | Total Loans | Total Disbursed (INR) | Capital Share (%) | Default Count | Default Rate (%) | Avg Interest Rate |
+----------------+-------------+-----------------------+-------------------+---------------+------------------+-------------------+
| Home Loan      | 917         | 5,044,103,000.00      | 63.38%            | 62            | 6.76%            | 8.50%             |
| Business Loan  | 305         | 1,229,149,000.00      | 15.44%            | 23            | 7.54%            | 12.33%            |
| Auto Loan      | 517         | 618,701,000.00        | 7.77%             | 43            | 8.32%            | 9.95%             |
| Personal Loan  | 839         | 524,532,000.00        | 6.59%             | 80            | 9.54%            | 13.73%            |
| Education Loan | 243         | 460,948,000.00        | 5.79%             | 19            | 7.82%            | 9.58%             |
| Gold Loan      | 179         | 81,109,000.00         | 1.02%             | 20            | 11.17%           | 10.85%            |
+----------------+-------------+-----------------------+-------------------+---------------+------------------+-------------------+
```

### Strategic Insights:
1. **Mortgage-Heavy Asset Portfolio**: **Home Loans form the cornerstone of the balance sheet**, representing **63.38% of total disbursed capital** (₹5.04 Billion). They also exhibit the lowest default rate (**6.76%**), reflecting the security of collateralized real estate assets.
2. **Unsecured Retail Credit Risk**: **Personal Loans exhibit an elevated default rate of 9.54%** (80 defaults out of 839 loans) with an average interest rate of 13.73%. This risk-return spread justifies the higher rate but requires stricter bureau underwriting.
3. **Gold Loan Delinquency**: Gold loans show an **11.17% default/settlement delinquency rate**, but are 100% collateralized with liquid bullion, mitigating credit loss upon auctioning pledged metal.

---

## 4. Branch Network & Regional Deposit Mobilization

Ranked branch analysis across 50 locations identified the top deposit-mobilizing hubs:

```
+--------------+-----------------------------+-------------+----------+----------------+----------------------+-----------------------+
| Deposit Rank | Branch Name                 | City        | Region   | Total Accounts | Total Deposits (INR) | Share of Bank Total   |
+--------------+-----------------------------+-------------+----------+----------------+----------------------+-----------------------+
| 1            | Dehradun City Center Branch | Dehradun    | North    | 166            | 103,526,137.36       | 2.80%                 |
| 2            | Indore City Center Branch   | Indore      | Central  | 157            | 93,563,305.25        | 2.53%                 |
| 3            | Aurangabad West End Branch  | Aurangabad  | West     | 156            | 92,540,355.90        | 2.50%                 |
| 4            | Bengaluru South Ext Branch  | Bengaluru   | South    | 165            | 92,218,387.30        | 2.49%                 |
| 5            | Panaji South Ext Branch     | Panaji      | West     | 168            | 90,233,949.23        | 2.44%                 |
| 6            | Amritsar South Ext Branch   | Amritsar    | North    | 160            | 89,778,714.25        | 2.43%                 |
| 7            | Noida Main Branch           | Noida       | North    | 163            | 89,228,059.67        | 2.41%                 |
| 8            | Cuttack City Center Branch  | Cuttack     | East     | 143            | 86,185,280.98        | 2.33%                 |
| 9            | Raipur City Center Branch   | Raipur      | Central  | 153            | 85,116,978.15        | 2.30%                 |
| 10           | Bhubaneswar City Center     | Bhubaneswar | East     | 149            | 84,278,255.29        | 2.28%                 |
+--------------+-----------------------------+-------------+----------+----------------+----------------------+-----------------------+
```

### Strategic Insights:
1. **Tier-2 & Metro Balance**: Strong deposit mobilization is observed across Tier-2 economic centers (Dehradun, Indore, Aurangabad) alongside Tier-1 tech hubs (Bengaluru, Noida), reflecting balanced national footprint distribution.
2. **Regional Equilibrium**: Central (₹8.28B), West (₹8.25B), North (₹8.22B), East (₹8.21B), and South (₹7.61B) all show healthy regional participation in aggregate network deposits and transactional turnover.

---

## 5. Strategic Recommendations for Bank Leadership

1. **VIP Wealth Retention Program**: Implement bespoke high-yield fixed deposits, tax-saving strategies, and dedicated RM coverage for the top **1,269 Premium segment customers** holding 72% of deposits.
2. **Digitization of Branch Cash Counters**: Since branch visits account for 28.5% of value but only 4.0% of volume, incentivize corporate and trade clients to adopt **Bulk Net Banking & API-based Corporate Banking** to reduce branch footfall costs.
3. **Credit Policy Fine-Tuning**: Tighten eligibility criteria for Personal Loans with debt-to-income (DTI) ratios exceeding 45% to lower the 9.54% delinquency rate.
4. **Cross-Sell Campaign**: Target the 54.8% of single-product depositors with pre-approved credit cards and competitive pre-qualified auto/home loan offers.

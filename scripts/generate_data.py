"""
Banking Analytics Synthetic Data Generator
Generates realistic Indian banking dataset with 7 relational tables:
- Customers (5,000)
- Branches (50)
- Accounts (7,000)
- Transactions (100,000+)
- Loans (3,000)
- Loan_Payments (15,000+)
- Cards (5,000+)

Maintains strict referential integrity, realistic date timelines (2021-2024),
realistic balance/transaction distributions, and loan repayment behaviors.
"""

import os
import random
import datetime
from datetime import timedelta
import csv

# Set random seed for reproducibility
random.seed(42)

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(BASE_DIR, "data")
os.makedirs(DATA_DIR, exist_ok=True)

# -----------------------------------------------------------------------------
# 1. REFERENCE DATA (Indian Banking Context)
# -----------------------------------------------------------------------------
INDIAN_CITIES_REGIONS = [
    # North
    ("New Delhi", "Delhi", "North"),
    ("Noida", "Uttar Pradesh", "North"),
    ("Gurugram", "Haryana", "North"),
    ("Chandigarh", "Punjab", "North"),
    ("Jaipur", "Rajasthan", "North"),
    ("Lucknow", "Uttar Pradesh", "North"),
    ("Dehradun", "Uttarakhand", "North"),
    ("Kanpur", "Uttar Pradesh", "North"),
    ("Amritsar", "Punjab", "North"),
    ("Agra", "Uttar Pradesh", "North"),
    # South
    ("Bengaluru", "Karnataka", "South"),
    ("Chennai", "Tamil Nadu", "South"),
    ("Hyderabad", "Telangana", "South"),
    ("Kochi", "Kerala", "South"),
    ("Coimbatore", "Tamil Nadu", "South"),
    ("Visakhapatnam", "Andhra Pradesh", "South"),
    ("Mysuru", "Karnataka", "South"),
    ("Thiruvananthapuram", "Kerala", "South"),
    ("Madurai", "Tamil Nadu", "South"),
    ("Vijayawada", "Andhra Pradesh", "South"),
    # West
    ("Mumbai", "Maharashtra", "West"),
    ("Pune", "Maharashtra", "West"),
    ("Ahmedabad", "Gujarat", "West"),
    ("Surat", "Gujarat", "West"),
    ("Nagpur", "Maharashtra", "West"),
    ("Vadodara", "Gujarat", "West"),
    ("Nashik", "Maharashtra", "West"),
    ("Rajkot", "Gujarat", "West"),
    ("Panaji", "Goa", "West"),
    ("Aurangabad", "Maharashtra", "West"),
    # East
    ("Kolkata", "West Bengal", "East"),
    ("Bhubaneswar", "Odisha", "East"),
    ("Patna", "Bihar", "East"),
    ("Ranchi", "Jharkhand", "East"),
    ("Guwahati", "Assam", "East"),
    ("Siliguri", "West Bengal", "East"),
    ("Cuttack", "Odisha", "East"),
    ("Jamshedpur", "Jharkhand", "East"),
    ("Durgapur", "West Bengal", "East"),
    ("Shillong", "Meghalaya", "East"),
    # Central
    ("Bhopal", "Madhya Pradesh", "Central"),
    ("Indore", "Madhya Pradesh", "Central"),
    ("Raipur", "Chhattisgarh", "Central"),
    ("Jabalpur", "Madhya Pradesh", "Central"),
    ("Gwalior", "Madhya Pradesh", "Central"),
    ("Bilaspur", "Chhattisgarh", "Central"),
    ("Ujjain", "Madhya Pradesh", "Central"),
    ("Durg", "Chhattisgarh", "Central"),
    ("Kota", "Rajasthan", "Central"),
    ("Prayagraj", "Uttar Pradesh", "Central")
]

FIRST_NAMES_MALE = [
    "Aarav", "Vivaan", "Aditya", "Vihaan", "Arjun", "Sai", "Reyansh", "Ayaan", "Krishna", "Ishaan",
    "Shaurya", "Atharva", "Rohan", "Rahul", "Amit", "Vikram", "Suresh", "Ramesh", "Deepak", "Anand",
    "Manish", "Rajesh", "Sanjay", "Alok", "Praveen", "Karthik", "Venkatesh", "Naveen", "Abhishek", "Gaurav",
    "Pranav", "Nikhil", "Mayank", "Harsh", "Akash", "Kunal", "Varun", "Sumit", "Sachin", "Mohit",
    "Devendra", "Pankaj", "Tarun", "Sunil", "Dinesh", "Manoj", "Ajay", "Vijay", "Hemant", "Ashish"
]

FIRST_NAMES_FEMALE = [
    "Saanvi", "Aanya", "Aadhya", "Aarohi", "Ananya", "Pari", "Diya", "Riya", "Avani", "Ishita",
    "Pooja", "Priya", "Neha", "Anjali", "Kavita", "Sunita", "Deepika", "Shreya", "Sneha", "Tanvi",
    "Meera", "Swati", "Rashmi", "Divya", "Aditi", "Preeti", "Monika", "Meenakshi", "Lakshmi", "Bhavna",
    "Jyoti", "Komal", "Shikha", "Archana", "Nandini", "Payal", "Ritu", "Sonali", "Garima", "Prerna",
    "Nisha", "Pallavi", "Vandana", "Shilpa", "Radha", "Kalyani", "Sonal", "Simran", "Richa", "Aarti"
]

LAST_NAMES = [
    "Sharma", "Verma", "Patel", "Mehta", "Singh", "Kumar", "Gupta", "Deshmukh", "Joshi", "Kulkarni",
    "Nair", "Pillai", "Iyer", "Iyengar", "Reddy", "Rao", "Choudhury", "Das", "Banerjee", "Chatterjee",
    "Mishra", "Pandey", "Tripathi", "Shukla", "Bhat", "Hegde", "Shetty", "Gowda", "Menon", "Kapoor",
    "Malhotra", "Bhatia", "Bansal", "Agarwal", "Saxena", "Srivastava", "Chauhan", "Yadav", "Patil", "Pawar",
    "Ghosh", "Mukherjee", "Saha", "Dutta", "Mohanty", "Patnaik", "Pradhan", "Nayak", "Bora", "Saikia"
]

OCCUPATIONS = [
    ("Software Engineer", 600000, 2400000),
    ("Doctor", 800000, 3000000),
    ("Chartered Accountant", 700000, 2500000),
    ("Business Owner", 500000, 4000000),
    ("Government Employee", 400000, 1500000),
    ("Teacher / Professor", 350000, 1200000),
    ("Banker", 500000, 1800000),
    ("Sales & Marketing Manager", 450000, 1600000),
    ("Civil / Mechanical Engineer", 400000, 1400000),
    ("Consultant", 650000, 2200000),
    ("Lawyer", 500000, 2500000),
    ("Freelancer / Creator", 300000, 1200000),
    ("Retail Trader", 350000, 1500000),
    ("Healthcare Worker / Nurse", 300000, 900000),
    ("Retired", 300000, 800000)
]

START_DATE_SIM = datetime.date(2021, 1, 1)
END_DATE_SIM = datetime.date(2024, 6, 30)

def random_date(start, end):
    delta = end - start
    random_days = random.randint(0, max(0, delta.days))
    return start + timedelta(days=random_days)

print("Starting realistic data generation...")

# -----------------------------------------------------------------------------
# 2. GENERATE BRANCHES (50 Branches)
# -----------------------------------------------------------------------------
branches = []
for idx, (city, state, region) in enumerate(INDIAN_CITIES_REGIONS, start=1):
    branch_id = f"BR{idx:03d}"
    branch_name = f"{city} {random.choice(['Main', 'City Center', 'Commercial', 'Metro', 'West End', 'South Ext'])} Branch"
    branches.append({
        "Branch_ID": branch_id,
        "Branch_Name": branch_name,
        "City": city,
        "State": state,
        "Region": region
    })

branch_file = os.path.join(DATA_DIR, "branches.csv")
with open(branch_file, "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=["Branch_ID", "Branch_Name", "City", "State", "Region"])
    writer.writeheader()
    writer.writerows(branches)
print(f"Generated {len(branches)} branches -> {branch_file}")

# -----------------------------------------------------------------------------
# 3. GENERATE CUSTOMERS (5,000 Customers)
# -----------------------------------------------------------------------------
customers = []
NUM_CUSTOMERS = 5000

for i in range(1, NUM_CUSTOMERS + 1):
    cust_id = f"CUST{i:05d}"
    gender = random.choices(["Male", "Female"], weights=[0.58, 0.42])[0]
    if gender == "Male":
        first_name = random.choice(FIRST_NAMES_MALE)
    else:
        first_name = random.choice(FIRST_NAMES_FEMALE)
    last_name = random.choice(LAST_NAMES)
    full_name = f"{first_name} {last_name}"
    
    # Age between 21 and 68
    age_years = random.randint(21, 68)
    dob = END_DATE_SIM - timedelta(days=int(age_years * 365.25) + random.randint(0, 360))
    
    # Location
    city_info = random.choice(INDIAN_CITIES_REGIONS)
    city = city_info[0]
    state = city_info[1]
    
    # Occupation & Income
    occ_info = random.choice(OCCUPATIONS)
    occupation = occ_info[0]
    min_inc, max_inc = occ_info[1], occ_info[2]
    # Log-normal or skewed income distribution
    income = round(random.uniform(min_inc, max_inc), -2)
    
    # Customer Since: 2015 to 2023
    cust_since = random_date(datetime.date(2015, 1, 1), datetime.date(2023, 12, 31))
    
    customers.append({
        "Customer_ID": cust_id,
        "Customer_Name": full_name,
        "Gender": gender,
        "Date_of_Birth": dob.strftime("%Y-%m-%d"),
        "City": city,
        "State": state,
        "Occupation": occupation,
        "Income": f"{income:.2f}",
        "Customer_Since": cust_since.strftime("%Y-%m-%d")
    })

customer_file = os.path.join(DATA_DIR, "customers.csv")
with open(customer_file, "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=[
        "Customer_ID", "Customer_Name", "Gender", "Date_of_Birth", "City", 
        "State", "Occupation", "Income", "Customer_Since"
    ])
    writer.writeheader()
    writer.writerows(customers)
print(f"Generated {len(customers)} customers -> {customer_file}")

# -----------------------------------------------------------------------------
# 4. GENERATE ACCOUNTS (7,000 Accounts)
# -----------------------------------------------------------------------------
# Every customer gets at least 1 account, some get 2 or 3
accounts = []
account_types = ["Savings", "Current", "Salary", "Fixed Deposit"]
account_type_weights = [0.60, 0.15, 0.15, 0.10]
account_status_choices = ["Active", "Active", "Active", "Active", "Active", "Active", "Inactive", "Dormant"]

account_id_counter = 1

# Map customer to their primary branch (usually same city or nearby)
customer_branch_map = {}
for c in customers:
    matching_branches = [b for b in branches if b["City"] == c["City"]]
    if matching_branches:
        chosen_branch = random.choice(matching_branches)
    else:
        chosen_branch = random.choice(branches)
    customer_branch_map[c["Customer_ID"]] = chosen_branch["Branch_ID"]

customer_accounts = {}

# 1st pass: 1 account for each customer
for c in customers:
    c_id = c["Customer_ID"]
    acc_id = f"ACC{account_id_counter:06d}"
    account_id_counter += 1
    
    acc_type = random.choices(account_types, weights=account_type_weights)[0]
    b_id = customer_branch_map[c_id]
    
    c_since = datetime.datetime.strptime(c["Customer_Since"], "%Y-%m-%d").date()
    open_date = random_date(c_since, END_DATE_SIM)
    
    # Realistic balances
    if acc_type == "Savings":
        balance = round(random.choices(
            [random.uniform(2000, 25000), random.uniform(25000, 150000), random.uniform(150000, 1200000), random.uniform(1200000, 6000000)],
            weights=[0.35, 0.40, 0.20, 0.05]
        )[0], 2)
    elif acc_type == "Current":
        balance = round(random.choices(
            [random.uniform(25000, 150000), random.uniform(150000, 800000), random.uniform(800000, 4500000)],
            weights=[0.40, 0.45, 0.15]
        )[0], 2)
    elif acc_type == "Salary":
        balance = round(random.uniform(5000, 350000), 2)
    else: # Fixed Deposit
        balance = round(random.uniform(50000, 2000000), 2)
        
    status = random.choice(account_status_choices)
    
    acc_record = {
        "Account_ID": acc_id,
        "Customer_ID": c_id,
        "Branch_ID": b_id,
        "Account_Type": acc_type,
        "Open_Date": open_date.strftime("%Y-%m-%d"),
        "Balance": f"{balance:.2f}",
        "Account_Status": status
    }
    accounts.append(acc_record)
    customer_accounts[c_id] = [acc_record]

# 2nd pass: 2,000 additional accounts for customers holding multiple accounts
multi_account_custs = random.sample(customers, 2000)
for c in multi_account_custs:
    c_id = c["Customer_ID"]
    acc_id = f"ACC{account_id_counter:06d}"
    account_id_counter += 1
    
    # Pick different type if possible
    existing_types = [a["Account_Type"] for a in customer_accounts[c_id]]
    avail_types = [t for t in account_types if t not in existing_types]
    acc_type = random.choice(avail_types) if avail_types else random.choice(account_types)
    b_id = customer_branch_map[c_id]
    
    c_since = datetime.datetime.strptime(c["Customer_Since"], "%Y-%m-%d").date()
    open_date = random_date(c_since, END_DATE_SIM)
    
    if acc_type == "Fixed Deposit":
        balance = round(random.uniform(50000, 3000000), 2)
    elif acc_type == "Current":
        balance = round(random.uniform(30000, 1200000), 2)
    else:
        balance = round(random.uniform(5000, 400000), 2)
        
    status = random.choices(["Active", "Inactive"], weights=[0.90, 0.10])[0]
    
    acc_record = {
        "Account_ID": acc_id,
        "Customer_ID": c_id,
        "Branch_ID": b_id,
        "Account_Type": acc_type,
        "Open_Date": open_date.strftime("%Y-%m-%d"),
        "Balance": f"{balance:.2f}",
        "Account_Status": status
    }
    accounts.append(acc_record)
    customer_accounts[c_id].append(acc_record)

account_file = os.path.join(DATA_DIR, "accounts.csv")
with open(account_file, "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=[
        "Account_ID", "Customer_ID", "Branch_ID", "Account_Type", "Open_Date", "Balance", "Account_Status"
    ])
    writer.writeheader()
    writer.writerows(accounts)
print(f"Generated {len(accounts)} accounts -> {account_file}")

# -----------------------------------------------------------------------------
# 5. GENERATE TRANSACTIONS (100,000+ Transactions)
# -----------------------------------------------------------------------------
transactions = []
CHANNELS = ["UPI", "ATM", "Net Banking", "Mobile Banking", "NEFT", "IMPS", "Branch", "POS / Debit Card"]
CHANNEL_WEIGHTS = [0.38, 0.16, 0.14, 0.12, 0.08, 0.06, 0.04, 0.02]

TRANSACTION_TYPES = ["Deposit", "Withdrawal", "Transfer"]
TX_TYPE_WEIGHTS = [0.35, 0.55, 0.10]

STATUS_CHOICES = ["Success", "Success", "Success", "Success", "Success", "Success", "Success", "Success", "Failed", "Pending"]

NUM_TRANSACTIONS = 105000
tx_id_counter = 1

# Active accounts get transactions
active_accounts = [a for a in accounts if a["Account_Status"] == "Active" and a["Account_Type"] != "Fixed Deposit"]
# We also allow a few dormant/inactive accounts to have historical transactions before dormancy
all_eligible_accounts = [a for a in accounts if a["Account_Type"] != "Fixed Deposit"]

print("Generating 105,000 transactions across accounts and timeline (2021-2024)...")
for _ in range(NUM_TRANSACTIONS):
    tx_id = f"TXN{tx_id_counter:07d}"
    tx_id_counter += 1
    
    acc = random.choice(all_eligible_accounts)
    acc_id = acc["Account_ID"]
    acc_open = datetime.datetime.strptime(acc["Open_Date"], "%Y-%m-%d").date()
    
    # Tx date must be between open date and simulation end date
    if acc_open >= END_DATE_SIM:
        tx_date = END_DATE_SIM
    else:
        tx_date = random_date(acc_open, END_DATE_SIM)
        
    channel = random.choices(CHANNELS, weights=CHANNEL_WEIGHTS)[0]
    tx_type = random.choices(TRANSACTION_TYPES, weights=TX_TYPE_WEIGHTS)[0]
    
    # Realistic amount by channel
    if channel == "UPI":
        amount = round(random.choices(
            [random.uniform(50, 1000), random.uniform(1000, 10000), random.uniform(10000, 50000)],
            weights=[0.50, 0.40, 0.10]
        )[0], 2)
    elif channel == "ATM":
        amount = round(random.choice([500, 1000, 2000, 3000, 4500, 5000, 8000, 10000]), 2)
        tx_type = "Withdrawal"
    elif channel in ["NEFT", "IMPS"]:
        amount = round(random.uniform(2000, 250000), 2)
    elif channel == "Branch":
        amount = round(random.uniform(5000, 500000), 2)
    else:
        amount = round(random.uniform(200, 35000), 2)
        
    status = random.choices(["Success", "Failed", "Pending"], weights=[0.94, 0.05, 0.01])[0]
    
    transactions.append({
        "Transaction_ID": tx_id,
        "Account_ID": acc_id,
        "Transaction_Date": tx_date.strftime("%Y-%m-%d"),
        "Transaction_Type": tx_type,
        "Amount": f"{amount:.2f}",
        "Channel": channel,
        "Transaction_Status": status
    })

# Sort transactions by date for realistic flow
transactions.sort(key=lambda x: x["Transaction_Date"])

transaction_file = os.path.join(DATA_DIR, "transactions.csv")
with open(transaction_file, "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=[
        "Transaction_ID", "Account_ID", "Transaction_Date", "Transaction_Type", "Amount", "Channel", "Transaction_Status"
    ])
    writer.writeheader()
    writer.writerows(transactions)
print(f"Generated {len(transactions)} transactions -> {transaction_file}")

# -----------------------------------------------------------------------------
# 6. GENERATE LOANS (3,000 Loans)
# -----------------------------------------------------------------------------
loans = []
LOAN_TYPES = [
    ("Home Loan", 1500000, 9500000, 7.5, 9.5, [120, 180, 240, 300]),
    ("Personal Loan", 50000, 1200000, 11.0, 16.5, [12, 24, 36, 48, 60]),
    ("Auto Loan", 250000, 2200000, 8.5, 11.5, [36, 48, 60, 84]),
    ("Education Loan", 200000, 3500000, 8.0, 11.0, [60, 84, 120]),
    ("Business Loan", 500000, 7500000, 10.0, 15.0, [36, 60, 84, 120]),
    ("Gold Loan", 50000, 800000, 9.0, 12.5, [12, 24, 36])
]
LOAN_TYPE_WEIGHTS = [0.30, 0.28, 0.18, 0.08, 0.10, 0.06]

NUM_LOANS = 3000
# Pick 3000 distinct customers or allow multiple loans for some
loan_customers = random.choices(customers, k=NUM_LOANS)

for idx, c in enumerate(loan_customers, start=1):
    loan_id = f"LOAN{idx:05d}"
    c_id = c["Customer_ID"]
    b_id = customer_branch_map[c_id]
    
    l_type_info = random.choices(LOAN_TYPES, weights=LOAN_TYPE_WEIGHTS)[0]
    loan_type = l_type_info[0]
    min_amt, max_amt = l_type_info[1], l_type_info[2]
    min_rate, max_rate = l_type_info[3], l_type_info[4]
    term_choices = l_type_info[5]
    
    loan_amt = round(random.uniform(min_amt, max_amt), -3)
    interest_rate = round(random.uniform(min_rate, max_rate), 2)
    loan_term = random.choice(term_choices)
    
    c_since = datetime.datetime.strptime(c["Customer_Since"], "%Y-%m-%d").date()
    loan_start_date = random_date(c_since, datetime.date(2023, 12, 1))
    
    # Status: Active, Closed, Defaulted, In Arrears
    months_elapsed = (END_DATE_SIM.year - loan_start_date.year) * 12 + (END_DATE_SIM.month - loan_start_date.month)
    
    if months_elapsed >= loan_term:
        status = random.choices(["Closed", "Defaulted"], weights=[0.88, 0.12])[0]
    else:
        status = random.choices(["Active", "Closed", "Defaulted", "In Arrears"], weights=[0.80, 0.08, 0.07, 0.05])[0]
        
    loans.append({
        "Loan_ID": loan_id,
        "Customer_ID": c_id,
        "Branch_ID": b_id,
        "Loan_Type": loan_type,
        "Loan_Amount": f"{loan_amt:.2f}",
        "Interest_Rate": f"{interest_rate:.2f}",
        "Loan_Term": loan_term,
        "Loan_Status": status,
        "Loan_Start_Date": loan_start_date.strftime("%Y-%m-%d")
    })

loan_file = os.path.join(DATA_DIR, "loans.csv")
with open(loan_file, "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=[
        "Loan_ID", "Customer_ID", "Branch_ID", "Loan_Type", "Loan_Amount", 
        "Interest_Rate", "Loan_Term", "Loan_Status", "Loan_Start_Date"
    ])
    writer.writeheader()
    writer.writerows(loans)
print(f"Generated {len(loans)} loans -> {loan_file}")

# -----------------------------------------------------------------------------
# 7. GENERATE LOAN PAYMENTS (15,000+ Payments)
# -----------------------------------------------------------------------------
# Generate realistic EMI payments for loans based on status
loan_payments = []
payment_id_counter = 1

print("Generating realistic loan EMI payments (15,000+ records)...")
for l in loans:
    l_id = l["Loan_ID"]
    principal = float(l["Loan_Amount"])
    annual_rate = float(l["Interest_Rate"])
    term_months = int(l["Loan_Term"])
    start_date = datetime.datetime.strptime(l["Loan_Start_Date"], "%Y-%m-%d").date()
    status = l["Loan_Status"]
    
    # Calculate Standard EMI: P * r * (1+r)^n / ((1+r)^n - 1)
    monthly_rate = (annual_rate / 100) / 12
    if monthly_rate > 0:
        emi = principal * monthly_rate * ((1 + monthly_rate) ** term_months) / (((1 + monthly_rate) ** term_months) - 1)
    else:
        emi = principal / term_months
    emi = round(emi, 2)
    
    # Months elapsed up to simulation end
    months_elapsed = max(1, (END_DATE_SIM.year - start_date.year) * 12 + (END_DATE_SIM.month - start_date.month))
    months_to_simulate = min(months_elapsed, term_months)
    
    if status == "Closed":
        # Usually completed all payments or early settled
        num_payments = min(random.randint(6, 12) if months_to_simulate < 6 else months_to_simulate, term_months)
    elif status == "Defaulted":
        # Paid for a few months then stopped or missed
        num_payments = random.randint(1, min(6, months_to_simulate))
    elif status == "In Arrears":
        num_payments = max(1, months_to_simulate - random.randint(2, 4))
    else: # Active
        num_payments = max(1, months_to_simulate)
        
    for m in range(1, num_payments + 1):
        # Payment date ~ month m around start date day
        approx_day = min(start_date.day, 28)
        # Calculate payment month
        year = start_date.year + (start_date.month + m - 1) // 12
        month = (start_date.month + m - 1) % 12
        if month == 0:
            month = 12
            year -= 1
        pay_date = datetime.date(year, month, approx_day) + timedelta(days=random.randint(-2, 5))
        if pay_date > END_DATE_SIM:
            continue
            
        p_id = f"PAY{payment_id_counter:07d}"
        payment_id_counter += 1
        
        # Payment status: Paid, Late, Missed
        if status == "Defaulted" and m >= num_payments - 1:
            p_status = random.choice(["Late", "Failed"])
        elif status == "In Arrears" and m >= num_payments - 2:
            p_status = "Late"
        else:
            p_status = random.choices(["Paid", "Late"], weights=[0.92, 0.08])[0]
            
        # Amount variation (slight penalty for late or partial)
        if p_status == "Late":
            pay_amount = round(emi * random.uniform(1.02, 1.05), 2)
        else:
            pay_amount = emi
            
        loan_payments.append({
            "Payment_ID": p_id,
            "Loan_ID": l_id,
            "Payment_Date": pay_date.strftime("%Y-%m-%d"),
            "Payment_Amount": f"{pay_amount:.2f}",
            "Payment_Status": p_status
        })

loan_payments.sort(key=lambda x: x["Payment_Date"])

loan_payment_file = os.path.join(DATA_DIR, "loan_payments.csv")
with open(loan_payment_file, "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=[
        "Payment_ID", "Loan_ID", "Payment_Date", "Payment_Amount", "Payment_Status"
    ])
    writer.writeheader()
    writer.writerows(loan_payments)
print(f"Generated {len(loan_payments)} loan payments -> {loan_payment_file}")

# -----------------------------------------------------------------------------
# 8. GENERATE CARDS (5,000+ Cards)
# -----------------------------------------------------------------------------
cards = []
CARD_TYPES = [
    ("Credit Card", [50000, 100000, 150000, 250000, 500000, 1000000]),
    ("Debit Card", [25000, 50000, 100000, 200000]),
    ("Prepaid Card", [10000, 25000, 50000]),
    ("Corporate Card", [200000, 500000, 1500000])
]
CARD_TYPE_WEIGHTS = [0.45, 0.42, 0.08, 0.05]

NUM_CARDS = 5200
card_customers = random.choices(customers, k=NUM_CARDS)

for idx, c in enumerate(card_customers, start=1):
    card_id = f"CARD{idx:06d}"
    c_id = c["Customer_ID"]
    
    ctype_info = random.choices(CARD_TYPES, weights=CARD_TYPE_WEIGHTS)[0]
    card_type = ctype_info[0]
    credit_limit = random.choice(ctype_info[1])
    
    c_since = datetime.datetime.strptime(c["Customer_Since"], "%Y-%m-%d").date()
    issue_date = random_date(c_since, END_DATE_SIM)
    
    status = random.choices(["Active", "Blocked", "Expired", "Inactive"], weights=[0.85, 0.05, 0.06, 0.04])[0]
    
    cards.append({
        "Card_ID": card_id,
        "Customer_ID": c_id,
        "Card_Type": card_type,
        "Issue_Date": issue_date.strftime("%Y-%m-%d"),
        "Credit_Limit": f"{credit_limit:.2f}",
        "Card_Status": status
    })

cards.sort(key=lambda x: x["Issue_Date"])

card_file = os.path.join(DATA_DIR, "cards.csv")
with open(card_file, "w", newline="", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=[
        "Card_ID", "Customer_ID", "Card_Type", "Issue_Date", "Credit_Limit", "Card_Status"
    ])
    writer.writeheader()
    writer.writerows(cards)
print(f"Generated {len(cards)} cards -> {card_file}")

print("-------------------------------------------------------")
print("DATASET GENERATION SUMMARY:")
print(f"Customers:     {len(customers):,}")
print(f"Branches:      {len(branches):,}")
print(f"Accounts:      {len(accounts):,}")
print(f"Transactions:  {len(transactions):,}")
print(f"Loans:         {len(loans):,}")
print(f"Loan Payments: {len(loan_payments):,}")
print(f"Cards:         {len(cards):,}")
print("All files saved successfully into data/ directory.")

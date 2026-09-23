"""
Generates a professional, high-resolution Entity Relationship (ER) Diagram
for the Banking Customer, Transaction & Loan Analytics database.
Saves to documentation/database_schema.png
"""

import os
import matplotlib.pyplot as plt
import matplotlib.patches as patches

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOCS_DIR = os.path.join(BASE_DIR, "documentation")
os.makedirs(DOCS_DIR, exist_ok=True)
OUTPUT_PATH = os.path.join(DOCS_DIR, "database_schema.png")

# Set up matplotlib figure
fig, ax = plt.subplots(figsize=(19, 12), dpi=300)
ax.set_facecolor("#0F172A") # Modern deep slate/navy background
fig.patch.set_facecolor("#0F172A")

# Title and Header
plt.text(9.5, 11.5, "BANKING CUSTOMER, TRANSACTION & LOAN ANALYTICS", 
         fontsize=20, weight="bold", color="#F8FAFC", ha="center", fontfamily="sans-serif")
plt.text(9.5, 11.1, "Relational Database Schema (MySQL 8.0+) • Entity Relationship Diagram", 
         fontsize=12, color="#94A3B8", ha="center", fontfamily="sans-serif")

# Table Definitions
tables = [
    {
        "name": "CUSTOMERS",
        "pos": (0.8, 6.2),
        "width": 3.6,
        "height": 4.2,
        "header_color": "#1E3A8A", # Deep Blue
        "pk": ["Customer_ID [PK]"],
        "cols": [
            "Customer_Name (VARCHAR)",
            "Gender (ENUM)",
            "Date_of_Birth (DATE)",
            "City (VARCHAR)",
            "State (VARCHAR)",
            "Occupation (VARCHAR)",
            "Income (DECIMAL)",
            "Customer_Since (DATE)"
        ]
    },
    {
        "name": "BRANCHES",
        "pos": (7.7, 8.2),
        "width": 3.4,
        "height": 2.8,
        "header_color": "#065F46", # Emerald Green
        "pk": ["Branch_ID [PK]"],
        "cols": [
            "Branch_Name (VARCHAR)",
            "City (VARCHAR)",
            "State (VARCHAR)",
            "Region (ENUM)"
        ]
    },
    {
        "name": "ACCOUNTS",
        "pos": (7.7, 4.0),
        "width": 3.4,
        "height": 3.4,
        "header_color": "#0284C7", # Sky Blue
        "pk": ["Account_ID [PK]"],
        "cols": [
            "Customer_ID [FK] -> Customers",
            "Branch_ID [FK] -> Branches",
            "Account_Type (ENUM)",
            "Open_Date (DATE)",
            "Balance (DECIMAL)",
            "Account_Status (ENUM)"
        ]
    },
    {
        "name": "TRANSACTIONS",
        "pos": (14.2, 4.0),
        "width": 3.8,
        "height": 3.4,
        "header_color": "#D97706", # Amber
        "pk": ["Transaction_ID [PK]"],
        "cols": [
            "Account_ID [FK] -> Accounts",
            "Transaction_Date (DATE)",
            "Transaction_Type (ENUM)",
            "Amount (DECIMAL)",
            "Channel (ENUM)",
            "Transaction_Status (ENUM)"
        ]
    },
    {
        "name": "LOANS",
        "pos": (0.8, 0.6),
        "width": 3.6,
        "height": 4.4,
        "header_color": "#9333EA", # Purple
        "pk": ["Loan_ID [PK]"],
        "cols": [
            "Customer_ID [FK] -> Customers",
            "Branch_ID [FK] -> Branches",
            "Loan_Type (ENUM)",
            "Loan_Amount (DECIMAL)",
            "Interest_Rate (DECIMAL)",
            "Loan_Term (INT)",
            "Loan_Status (ENUM)",
            "Loan_Start_Date (DATE)"
        ]
    },
    {
        "name": "LOAN_PAYMENTS",
        "pos": (7.7, 0.6),
        "width": 3.4,
        "height": 2.8,
        "header_color": "#BE185D", # Pink/Rose
        "pk": ["Payment_ID [PK]"],
        "cols": [
            "Loan_ID [FK] -> Loans",
            "Payment_Date (DATE)",
            "Payment_Amount (DECIMAL)",
            "Payment_Status (ENUM)"
        ]
    },
    {
        "name": "CARDS",
        "pos": (14.2, 8.2),
        "width": 3.8,
        "height": 2.8,
        "header_color": "#4F46E5", # Indigo
        "pk": ["Card_ID [PK]"],
        "cols": [
            "Customer_ID [FK] -> Customers",
            "Card_Type (ENUM)",
            "Issue_Date (DATE)",
            "Credit_Limit (DECIMAL)",
            "Card_Status (ENUM)"
        ]
    }
]

# Draw Tables
for t in tables:
    x, y = t["pos"]
    w, h = t["width"], t["height"]
    
    # Body Box
    box = patches.FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.06,rounding_size=0.15",
                                 facecolor="#1E293B", edgecolor="#475569", linewidth=1.5, zorder=2)
    ax.add_patch(box)
    
    # Header Box
    header_h = 0.6
    header_box = patches.FancyBboxPatch((x, y + h - header_h), w, header_h, 
                                        boxstyle="round,pad=0.06,rounding_size=0.15",
                                        facecolor=t["header_color"], edgecolor="#475569", linewidth=1.5, zorder=3)
    ax.add_patch(header_box)
    
    # Header Text
    plt.text(x + w/2, y + h - 0.32, t["name"], fontsize=11, weight="bold", 
             color="#FFFFFF", ha="center", va="center", fontfamily="sans-serif", zorder=4)
    
    # Primary Key
    curr_y = y + h - header_h - 0.30
    for pk in t["pk"]:
        plt.text(x + 0.2, curr_y, pk, fontsize=9.5, weight="bold", color="#FACC15", fontfamily="monospace", zorder=4)
        curr_y -= 0.32
        
    # Divider line
    ax.plot([x + 0.1, x + w - 0.1], [curr_y + 0.1, curr_y + 0.1], color="#334155", lw=1.2, zorder=4)
    curr_y -= 0.08

    # Columns
    for col in t["cols"]:
        c_color = "#E2E8F0"
        if "[FK]" in col:
            c_color = "#38BDF8"
        plt.text(x + 0.2, curr_y, col, fontsize=8.5, color=c_color, fontfamily="monospace", zorder=4)
        curr_y -= 0.30

# Draw Connectors (Relationships)
connectors = [
    # Customers -> Accounts (1 : N)
    {"start": (4.4, 8.2), "end": (7.7, 6.2), "color": "#38BDF8", "label": "1 : N (Holds)"},
    # Customers -> Loans (1 : N)
    {"start": (2.6, 6.2), "end": (2.6, 5.0), "color": "#A855F7", "label": "1 : N (Borrows)"},
    # Customers -> Cards (1 : N)
    {"start": (4.4, 9.8), "end": (14.2, 9.8), "color": "#818CF8", "label": "1 : N (Owns)"},
    # Branches -> Accounts (1 : N)
    {"start": (9.4, 8.2), "end": (9.4, 7.4), "color": "#34D399", "label": "1 : N (Hosts)"},
    # Accounts -> Transactions (1 : N)
    {"start": (11.1, 5.7), "end": (14.2, 5.7), "color": "#FBBF24", "label": "1 : N (Executes)"},
    # Loans -> Loan_Payments (1 : N)
    {"start": (4.4, 2.0), "end": (7.7, 2.0), "color": "#F43F5E", "label": "1 : N (Repays)"},
    # Branches -> Loans (1 : N)
    {"start": (7.7, 9.2), "end": (5.0, 9.2), "mid": (5.0, 3.2), "end2": (4.4, 3.2), "color": "#10B981", "label": "1 : N (Disburses)"}
]

for conn_spec in connectors:
    if "mid" in conn_spec:
        # Multi-segment line
        ax.plot([conn_spec["start"][0], conn_spec["mid"][0], conn_spec["mid"][0], conn_spec["end2"][0]],
                [conn_spec["start"][1], conn_spec["start"][1], conn_spec["end2"][1], conn_spec["end2"][1]],
                color=conn_spec["color"], lw=1.8, linestyle="--", alpha=0.85, zorder=1)
    else:
        ax.annotate("",
                    xy=conn_spec["end"], xycoords='data',
                    xytext=conn_spec["start"], textcoords='data',
                    arrowprops=dict(arrowstyle="-|>", color=conn_spec["color"], lw=2.0, alpha=0.9, mutation_scale=15),
                    zorder=1)

# Footer legend
plt.text(9.5, 0.2, "Legend: [PK] Primary Key (Yellow)  |  [FK] Foreign Key Reference (Cyan)  |  Arrows indicate 1-to-Many Relational Cardinality",
         fontsize=10, color="#94A3B8", ha="center", fontfamily="sans-serif")

ax.set_xlim(0, 19)
ax.set_ylim(0, 12)
ax.axis("off")

plt.tight_layout()
plt.savefig(OUTPUT_PATH, dpi=300, facecolor=fig.get_facecolor(), bbox_inches="tight")
plt.close()
print(f"ER diagram created successfully at {OUTPUT_PATH}")

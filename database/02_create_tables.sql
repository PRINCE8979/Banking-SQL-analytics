-- ============================================================================
-- Banking Customer, Transaction & Loan Analytics Project
-- Script 02: Table Schema Definition (DDL)
-- Database Engine: MySQL 8.0+
-- ============================================================================

USE banking_analytics_db;

-- Drop child tables first, then parent tables to avoid foreign key reference errors
DROP TABLE IF EXISTS Loan_Payments;
DROP TABLE IF EXISTS Transactions;
DROP TABLE IF EXISTS Cards;
DROP TABLE IF EXISTS Loans;
DROP TABLE IF EXISTS Accounts;
DROP TABLE IF EXISTS Branches;
DROP TABLE IF EXISTS Customers;

-- ----------------------------------------------------------------------------
-- 1. Table: Customers
-- Description: Stores customer demographic, geographic, and employment profiles
-- ----------------------------------------------------------------------------
CREATE TABLE Customers (
    Customer_ID VARCHAR(20) NOT NULL,
    Customer_Name VARCHAR(100) NOT NULL,
    Gender ENUM('Male', 'Female', 'Other') NOT NULL,
    Date_of_Birth DATE NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL,
    Occupation VARCHAR(80) NOT NULL,
    Income DECIMAL(15, 2) NOT NULL CHECK (Income >= 0),
    Customer_Since DATE NOT NULL,
    CONSTRAINT PK_Customers PRIMARY KEY (Customer_ID)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 2. Table: Branches
-- Description: Stores physical branch locations, geographical coverage and regions
-- ----------------------------------------------------------------------------
CREATE TABLE Branches (
    Branch_ID VARCHAR(20) NOT NULL,
    Branch_Name VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL,
    Region ENUM('North', 'South', 'East', 'West', 'Central') NOT NULL,
    CONSTRAINT PK_Branches PRIMARY KEY (Branch_ID)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 3. Table: Accounts
-- Description: Stores deposit/savings/current accounts mapped to customers and branches
-- ----------------------------------------------------------------------------
CREATE TABLE Accounts (
    Account_ID VARCHAR(20) NOT NULL,
    Customer_ID VARCHAR(20) NOT NULL,
    Branch_ID VARCHAR(20) NOT NULL,
    Account_Type ENUM('Savings', 'Current', 'Salary', 'Fixed Deposit') NOT NULL,
    Open_Date DATE NOT NULL,
    Balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00 CHECK (Balance >= 0),
    Account_Status ENUM('Active', 'Inactive', 'Dormant', 'Closed') NOT NULL DEFAULT 'Active',
    CONSTRAINT PK_Accounts PRIMARY KEY (Account_ID),
    CONSTRAINT FK_Accounts_Customers FOREIGN KEY (Customer_ID) 
        REFERENCES Customers (Customer_ID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT FK_Accounts_Branches FOREIGN KEY (Branch_ID) 
        REFERENCES Branches (Branch_ID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 4. Table: Transactions
-- Description: Detailed transactional log across multiple banking channels
-- ----------------------------------------------------------------------------
CREATE TABLE Transactions (
    Transaction_ID VARCHAR(20) NOT NULL,
    Account_ID VARCHAR(20) NOT NULL,
    Transaction_Date DATE NOT NULL,
    Transaction_Type ENUM('Deposit', 'Withdrawal', 'Transfer') NOT NULL,
    Amount DECIMAL(15, 2) NOT NULL CHECK (Amount > 0),
    Channel ENUM('UPI', 'ATM', 'Net Banking', 'Mobile Banking', 'NEFT', 'IMPS', 'Branch', 'POS / Debit Card') NOT NULL,
    Transaction_Status ENUM('Success', 'Failed', 'Pending') NOT NULL DEFAULT 'Success',
    CONSTRAINT PK_Transactions PRIMARY KEY (Transaction_ID),
    CONSTRAINT FK_Transactions_Accounts FOREIGN KEY (Account_ID) 
        REFERENCES Accounts (Account_ID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 5. Table: Loans
-- Description: Lending portfolio records including term, principal, interest and risk status
-- ----------------------------------------------------------------------------
CREATE TABLE Loans (
    Loan_ID VARCHAR(20) NOT NULL,
    Customer_ID VARCHAR(20) NOT NULL,
    Branch_ID VARCHAR(20) NOT NULL,
    Loan_Type ENUM('Home Loan', 'Personal Loan', 'Auto Loan', 'Education Loan', 'Business Loan', 'Gold Loan') NOT NULL,
    Loan_Amount DECIMAL(15, 2) NOT NULL CHECK (Loan_Amount > 0),
    Interest_Rate DECIMAL(5, 2) NOT NULL CHECK (Interest_Rate > 0 AND Interest_Rate <= 40),
    Loan_Term INT NOT NULL CHECK (Loan_Term > 0), -- Duration in months
    Loan_Status ENUM('Active', 'Closed', 'Defaulted', 'In Arrears') NOT NULL DEFAULT 'Active',
    Loan_Start_Date DATE NOT NULL,
    CONSTRAINT PK_Loans PRIMARY KEY (Loan_ID),
    CONSTRAINT FK_Loans_Customers FOREIGN KEY (Customer_ID) 
        REFERENCES Customers (Customer_ID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT FK_Loans_Branches FOREIGN KEY (Branch_ID) 
        REFERENCES Branches (Branch_ID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 6. Table: Loan_Payments
-- Description: Granular installment/EMI repayment records for loans
-- ----------------------------------------------------------------------------
CREATE TABLE Loan_Payments (
    Payment_ID VARCHAR(20) NOT NULL,
    Loan_ID VARCHAR(20) NOT NULL,
    Payment_Date DATE NOT NULL,
    Payment_Amount DECIMAL(15, 2) NOT NULL CHECK (Payment_Amount > 0),
    Payment_Status ENUM('Paid', 'Late', 'Failed') NOT NULL DEFAULT 'Paid',
    CONSTRAINT PK_Loan_Payments PRIMARY KEY (Payment_ID),
    CONSTRAINT FK_Loan_Payments_Loans FOREIGN KEY (Loan_ID) 
        REFERENCES Loans (Loan_ID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 7. Table: Cards
-- Description: Credit, debit, and prepaid card issuance and credit limits
-- ----------------------------------------------------------------------------
CREATE TABLE Cards (
    Card_ID VARCHAR(20) NOT NULL,
    Customer_ID VARCHAR(20) NOT NULL,
    Card_Type ENUM('Credit Card', 'Debit Card', 'Prepaid Card', 'Corporate Card') NOT NULL,
    Issue_Date DATE NOT NULL,
    Credit_Limit DECIMAL(15, 2) NOT NULL CHECK (Credit_Limit >= 0),
    Card_Status ENUM('Active', 'Blocked', 'Expired', 'Inactive') NOT NULL DEFAULT 'Active',
    CONSTRAINT PK_Cards PRIMARY KEY (Card_ID),
    CONSTRAINT FK_Cards_Customers FOREIGN KEY (Customer_ID) 
        REFERENCES Customers (Customer_ID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 8. Performance Indexes for Query Optimization
-- ----------------------------------------------------------------------------
CREATE INDEX idx_customers_city_state ON Customers(City, State);
CREATE INDEX idx_accounts_customer ON Accounts(Customer_ID);
CREATE INDEX idx_accounts_branch ON Accounts(Branch_ID);
CREATE INDEX idx_transactions_account ON Transactions(Account_ID);
CREATE INDEX idx_transactions_date ON Transactions(Transaction_Date);
CREATE INDEX idx_transactions_channel ON Transactions(Channel);
CREATE INDEX idx_loans_customer ON Loans(Customer_ID);
CREATE INDEX idx_loans_branch ON Loans(Branch_ID);
CREATE INDEX idx_loans_status ON Loans(Loan_Status);
CREATE INDEX idx_loan_payments_loan ON Loan_Payments(Loan_ID);
CREATE INDEX idx_cards_customer ON Cards(Customer_ID);

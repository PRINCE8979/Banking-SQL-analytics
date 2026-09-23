-- ============================================================================
-- Banking Customer, Transaction & Loan Analytics Project
-- Script 01: Database Creation and Initialization
-- Database Engine: MySQL 8.0+
-- ============================================================================

-- Drop database if already exists to ensure a clean setup
DROP DATABASE IF EXISTS banking_analytics_db;

-- Create Database with modern UTF-8 support for names and special characters
CREATE DATABASE banking_analytics_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Switch to the newly created database context
USE banking_analytics_db;

-- Display verification
SELECT 
    DATABASE() AS Active_Database,
    VERSION() AS MySQL_Version,
    CURRENT_TIMESTAMP() AS Setup_Timestamp;

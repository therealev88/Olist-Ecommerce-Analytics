/*
===============================================================================
Project     : Olist E-commerce Analytics
File        : 01_Database_Inventory.sql
Phase       : Phase 2 - Data Profiling
Checklist   : 2.1 - Database Inventory

Author      : EV Adedotun
Database    : MySQL 8.0

Objective
---------
Create a complete inventory of the Olist database and verify
its structural integrity before beginning data profiling,
cleaning, and analysis.

Deliverables
------------
This checklist verifies:

• Database tables
• Row counts
• Column definitions
• Data types
• Primary Keys
• Foreign Keys
• Indexes
• General schema observations

===============================================================================
*/

/*
===============================================================================
Section 2.1 : Database Tables
Purpose : Verify that all expected tables exist in the database.
===============================================================================
*/
SHOW TABLES;

/*
===============================================================================
Section 2.2 : Row Count Verification
Purpose : Verify imported row counts against the source dataset.
===============================================================================
*/

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'sellers', COUNT(*)
FROM sellers

UNION ALL

SELECT 'order_payments', COUNT(*)
FROM order_payments

UNION ALL

SELECT 'order_reviews', COUNT(*)
FROM order_reviews

UNION ALL

SELECT 'geolocation', COUNT(*)
FROM geolocation

UNION ALL

SELECT 'product_category_name_translation', COUNT(*)
FROM product_category_name_translation

ORDER BY table_name;

/*
===============================================================================
Section 2.3 : Column Definitions
Purpose : Review all column names, data types and attributes.
===============================================================================
*/

SELECT
    TABLE_NAME,
    ORDINAL_POSITION,
    COLUMN_NAME,
    COLUMN_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME, ORDINAL_POSITION;

/*
===============================================================================
Section 2.4 : Primary Keys
Purpose : Identify the primary key(s) for each table.
===============================================================================
*/
SELECT
    TABLE_NAME,
    COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE()
  AND CONSTRAINT_NAME = 'PRIMARY'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

/*
===============================================================================
Section 2.5 : Foreign Keys
Purpose : Identify the foreign key relationships between tables.
===============================================================================
*/

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE()
    AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;

/*
===============================================================================
Section 2.6 : Index Review
Purpose : Review indexes defined on each table.
===============================================================================
*/

SELECT
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    NON_UNIQUE
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

/*
===============================================================================
Section 2.7 : Schema Summary
Purpose : End of Database Inventory checklist.
===============================================================================
*/
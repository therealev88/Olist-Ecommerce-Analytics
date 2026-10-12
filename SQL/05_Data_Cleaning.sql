/*
===============================================================================
Section 5.1.1 : Clean Orders Table
Purpose : Create a cleaned copy of the orders table for transformation.
===============================================================================
*/

CREATE TABLE orders_clean AS
SELECT *
FROM orders;

/*
===============================================================================
Section 5.1.2 : Convert Zero Dates
Purpose : Replace imported zero dates with NULL values.
===============================================================================
*/

UPDATE orders_clean
SET
    order_approved_at =
        NULLIF(order_approved_at, '0000-00-00 00:00:00'),
    order_delivered_carrier_date =
        NULLIF(order_delivered_carrier_date, '0000-00-00 00:00:00'),
    order_delivered_customer_date =
        NULLIF(order_delivered_customer_date, '0000-00-00 00:00:00');
        
        /*
===============================================================================
Section 5.1.3 : Validate Zero-Date Removal
Purpose : Confirm that zero dates were removed from cleaned order timestamps.
===============================================================================
*/

SELECT
    SUM(order_approved_at = '0000-00-00 00:00:00') AS zero_approved,
    SUM(order_delivered_carrier_date = '0000-00-00 00:00:00') AS zero_carrier,
    SUM(order_delivered_customer_date = '0000-00-00 00:00:00') AS zero_customer,
    SUM(order_approved_at IS NULL) AS null_approved,
    SUM(order_delivered_carrier_date IS NULL) AS null_carrier,
    SUM(order_delivered_customer_date IS NULL) AS null_customer
FROM orders_clean;

/*
===============================================================================
Section 5.2.1 : Clean Products Table
Purpose : Create a cleaned copy of the products table for transformation.
===============================================================================
*/

CREATE TABLE products_clean AS
SELECT *
FROM products;

/*
===============================================================================
Section 5.2.2 : Convert Imported Zeros
Purpose : Replace import-generated zero values with NULL.
===============================================================================
*/

UPDATE products_clean
SET
    product_name_lenght =
        NULLIF(product_name_lenght, 0),
    product_description_lenght =
        NULLIF(product_description_lenght, 0),
    product_photos_qty =
        NULLIF(product_photos_qty, 0);
        
        /*
===============================================================================
Section 5.2.3 : Validate Product Cleaning
Purpose : Confirm imported zero values were converted to NULL.
===============================================================================
*/

SELECT
    SUM(product_name_lenght = 0) AS zero_name_length,
    SUM(product_description_lenght = 0) AS zero_description_length,
    SUM(product_photos_qty = 0) AS zero_photo_quantity,
    SUM(product_name_lenght IS NULL) AS null_name_length,
    SUM(product_description_lenght IS NULL) AS null_description_length,
    SUM(product_photos_qty IS NULL) AS null_photo_quantity
FROM products_clean;

/*
===============================================================================
Section 5.3.1 : Clean Customers Table
Purpose : Create a cleaned copy of the customers table for transformation.
===============================================================================
*/

CREATE TABLE customers_clean AS
SELECT *
FROM customers;


/*
=======================================================================
Phase 5.3.2 — Standardize the suspected city inconsistency
=========================================================================
*/

UPDATE customers_clean
SET customer_city = 'embu das artes'
WHERE customer_city = 'embu'
  AND customer_zip_code_prefix IN ('06806', '06810', '06813', '06814', '06823')
  AND customer_state = 'SP';
  
  /*
===============================================================================
Section 5.3.3 : Validate Customers Cleaning
Purpose : Confirm the city standardization and preserve the expected row count.
===============================================================================
*/

SELECT
    SUM(customer_city = 'embu') AS remaining_embu,
    SUM(customer_city = 'embu das artes') AS embu_das_artes,
    COUNT(*) AS total_customers
FROM customers_clean;

/*
===============================================================================
Section 5.4.1 : Clean Sellers Table
Purpose : Create a cleaned copy of the sellers table for transformation.
===============================================================================
*/

/*
===============================================================================
Section 5.4.1 : Clean Order Items Table
Purpose : Create a cleaned copy of the order items table for consistency.
===============================================================================
*/

CREATE TABLE order_items_clean AS
SELECT *
FROM order_items;

/*
===============================================================================
Section 5.4.2 : Review Seller Geographic Inconsistencies
Purpose : Recheck ZIP prefixes associated with multiple seller states.
===============================================================================
*/

SELECT
    seller_zip_code_prefix,
    seller_city,
    seller_state,
    COUNT(*) AS seller_count
FROM sellers_clean
WHERE seller_zip_code_prefix IN (
    '21210', '22783', '31160', '36010', '37540',
    '37795', '44600', '80240', '81020', '81560',
    '83020', '83321', '85960', '88075', '88301',
    '89052', '95076'
)
GROUP BY
    seller_zip_code_prefix,
    seller_city,
    seller_state
ORDER BY
    seller_zip_code_prefix,
    seller_state,
    seller_city;
    
    /*
===============================================================================
Section 5.4.3 : Validate Sellers Cleaning
Purpose : Confirm seller records and identifiers were preserved unchanged.
===============================================================================
*/

SELECT
    COUNT(*) AS total_sellers,
    COUNT(DISTINCT seller_id) AS unique_seller_ids
FROM sellers_clean;

/*
===============================================================================
Section 5.5.1 : Clean Order Payments Table
Purpose : Create a cleaned copy of the order payments table for transformation.
===============================================================================
*/

CREATE TABLE order_payments_clean AS
SELECT *
FROM order_payments;

/*
===============================================================================
Section 5.5.2 : Clean Invalid Payment Installments
Purpose : Convert confirmed invalid zero installments for credit-card payments to NULL.
===============================================================================
*/

UPDATE order_payments_clean
SET payment_installments = NULL
WHERE payment_type = 'credit_card'
  AND payment_installments = 0
  AND payment_value > 0;
  
  /*
===============================================================================
Section 5.5.3 : Review Undefined Payment Types
Purpose : Inspect the source records with an undefined payment type.
===============================================================================
*/

SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM order_payments_clean
WHERE payment_type = 'not_defined';

/*
===============================================================================
Section 5.5.4 : Validate Order Payments Cleaning
Purpose : Confirm payment records were preserved and unresolved anomalies remain identifiable.
===============================================================================
*/

SELECT
    COUNT(*) AS total_payments,
    SUM(payment_type = 'not_defined') AS undefined_payments,
    SUM(payment_type = 'credit_card' AND payment_installments = 0) AS zero_installment_cards
FROM order_payments_clean;

/*
===============================================================================
Section 5.6.1 : Clean Order Reviews Table
Purpose : Create a cleaned copy of the order reviews table for transformation.
===============================================================================
*/

CREATE TABLE order_reviews_clean AS
SELECT *
FROM order_reviews;

/*
===============================================================================
Section 5.6.2 : Clean Blank Review Comments
Purpose : Convert blank review comments to NULL.
===============================================================================
*/

UPDATE order_reviews_clean
SET review_comment_message = NULL
WHERE TRIM(review_comment_message) = '';

/*
===============================================================================
Section 5.6.3 : Validate Order Reviews Cleaning
Purpose : Confirm blank comments were converted to NULL and review records preserved.
===============================================================================
*/

SELECT
    COUNT(*) AS total_reviews,
    SUM(review_comment_message IS NULL) AS null_comments,
    SUM(TRIM(review_comment_message) = '') AS blank_comments
FROM order_reviews_clean;

/*
===============================================================================
Section 5.7.1 : Clean Geolocation Table
Purpose : Create a cleaned copy of the geolocation table for consistency.
===============================================================================
*/

CREATE TABLE geolocation_clean AS
SELECT *
FROM geolocation;

/*
===============================================================================
Section 5.7.2 : Validate Geolocation Cleaning
Purpose : Confirm geolocation records and coordinate ranges were preserved.
===============================================================================
*/

SELECT
    COUNT(*) AS total_records,
    SUM(geolocation_lat < -90 OR geolocation_lat > 90) AS invalid_latitude,
    SUM(geolocation_lng < -180 OR geolocation_lng > 180) AS invalid_longitude
FROM geolocation_clean;

/*
===============================================================================
Section 5.8.1 : Clean Product Category Translation Table
Purpose : Create a cleaned copy of the category translation table.
===============================================================================
*/

CREATE TABLE product_category_name_translation_clean AS
SELECT *
FROM product_category_name_translation;

/*
===============================================================================
Section 5.8.2 : Validate Product Category Translation
Purpose : Confirm category mappings and uniqueness were preserved.
===============================================================================
*/

SELECT
    COUNT(*) AS total_mappings,
    COUNT(DISTINCT product_category_name) AS unique_portuguese,
    COUNT(DISTINCT product_category_name_english) AS unique_english,
    SUM(product_category_name IS NULL OR product_category_name = '') AS missing_portuguese,
    SUM(product_category_name_english IS NULL OR product_category_name_english = '') AS missing_english
FROM product_category_name_translation_clean;

/*
===============================================================================
Section 5.9 : Final Cleaning Review
Purpose : Confirm the cleaned tables exist and preserve the expected row counts.
===============================================================================
*/

SELECT 'customers_clean' AS table_name, COUNT(*) AS row_count
FROM customers_clean

UNION ALL

SELECT 'orders_clean', COUNT(*)
FROM orders_clean

UNION ALL

SELECT 'order_items_clean', COUNT(*)
FROM order_items_clean

UNION ALL

SELECT 'products_clean', COUNT(*)
FROM products_clean

UNION ALL

SELECT 'sellers_clean', COUNT(*)
FROM sellers_clean

UNION ALL

SELECT 'order_payments_clean', COUNT(*)
FROM order_payments_clean

UNION ALL

SELECT 'order_reviews_clean', COUNT(*)
FROM order_reviews_clean

UNION ALL

SELECT 'geolocation_clean', COUNT(*)
FROM geolocation_clean

UNION ALL

SELECT 'product_category_name_translation_clean', COUNT(*)
FROM product_category_name_translation_clean;

/*
===============================================================================
Section 5.9.2 : Validate Order Items Cleaning
Purpose : Confirm order-item records and the composite key were preserved.
===============================================================================
*/

SELECT
    COUNT(*) AS total_items,
    COUNT(DISTINCT order_id, order_item_id) AS unique_item_keys
FROM order_items_clean;

/*
===============================================================================
Section 5.10 : Final Cleaning Review
Purpose : Confirm all cleaned tables preserve their expected row counts.
===============================================================================
*/

SELECT 'customers_clean' AS table_name, COUNT(*) AS row_count
FROM customers_clean

UNION ALL

SELECT 'orders_clean', COUNT(*)
FROM orders_clean

UNION ALL

SELECT 'order_items_clean', COUNT(*)
FROM order_items_clean

UNION ALL

SELECT 'products_clean', COUNT(*)
FROM products_clean

UNION ALL

SELECT 'sellers_clean', COUNT(*)
FROM sellers_clean

UNION ALL

SELECT 'order_payments_clean', COUNT(*)
FROM order_payments_clean

UNION ALL

SELECT 'order_reviews_clean', COUNT(*)
FROM order_reviews_clean

UNION ALL

SELECT 'geolocation_clean', COUNT(*)
FROM geolocation_clean

UNION ALL

SELECT 'product_category_name_translation_clean', COUNT(*)
FROM product_category_name_translation_clean;
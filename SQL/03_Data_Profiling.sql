/*
===============================================================================
Project : Olist E-commerce Analytics
File    : 03_Data_Profiling.sql
Phase   : Phase 3 - Data Profiling

Objective:
Profile each table to understand its completeness,
uniqueness, consistency and overall quality before
data cleaning.
===============================================================================
*/

/*
===============================================================================
Table: Customers
Section 3.1.1 : Table Overview
Purpose : Determine the total number of customer records.
===============================================================================
*/

SELECT COUNT(*) AS total_customers
FROM customers;

/*
===============================================================================
Section 3.1.2 : NULL Value Analysis
Purpose : Identify missing values in the customers table.
===============================================================================
*/

SELECT
    SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(customer_unique_id IS NULL) AS customer_unique_id_nulls,
    SUM(customer_zip_code_prefix IS NULL) AS customer_zip_code_prefix_nulls,
    SUM(customer_city IS NULL) AS customer_city_nulls,
    SUM(customer_state IS NULL) AS customer_state_nulls
FROM customers;

/*
===============================================================================
Section 3.1.3 : Blank Value Analysis
Purpose : Identify blank values in text columns.
===============================================================================
*/

SELECT
    SUM(TRIM(customer_id) = '') AS customer_id_blanks,
    SUM(TRIM(customer_unique_id) = '') AS customer_unique_id_blanks,
    SUM(TRIM(customer_city) = '') AS customer_city_blanks,
    SUM(TRIM(customer_state) = '') AS customer_state_blanks
FROM customers;

/*
===============================================================================
Section 3.1.4 : Uniqueness Analysis
Purpose : Verify the uniqueness of customer identifiers.
===============================================================================
*/

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT customer_id) AS unique_customer_id,
    COUNT(DISTINCT customer_unique_id) AS unique_customer_unique_id
FROM customers;

/*
===============================================================================
Section 3.1.5 : Repeat Customer Analysis
Purpose : Identify customers with multiple customer IDs.
===============================================================================
*/

SELECT
    customer_unique_id,
    COUNT(customer_id) AS order_count
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(customer_id) > 1
ORDER BY order_count DESC;

/*
===============================================================================
Section 3.1.6 : Customer Distribution by State
Purpose : Analyze customer distribution across states.
===============================================================================
*/

SELECT
    customer_state,
    COUNT(*) AS customer_count
FROM customers
GROUP BY customer_state
ORDER BY customer_count DESC;

/*
===============================================================================
Section 3.1.7 : Customer Distribution by City
Purpose : Analyze customer distribution across cities.
===============================================================================
*/

SELECT
    customer_city,
    COUNT(*) AS customer_count
FROM customers
GROUP BY customer_city
ORDER BY customer_count DESC;

/*
===============================================================================
Section 3.1.8 : ZIP Code Validation
Purpose : Validate the customer ZIP code prefix values.
===============================================================================
*/

SELECT
    MIN(customer_zip_code_prefix) AS min_zip_code,
    MAX(customer_zip_code_prefix) AS max_zip_code,
    COUNT(DISTINCT customer_zip_code_prefix) AS unique_zip_codes
FROM customers;

/*
===============================================================================
Section 3.2.1 : Table Overview
Purpose : Determine the total number of orders.
===============================================================================
*/

SELECT COUNT(*) AS total_orders
FROM orders;

/*
===============================================================================
Section 3.2.2 : NULL Value Analysis
Purpose : Identify missing values across order attributes.
===============================================================================
*/

SELECT
    SUM(order_id IS NULL) AS order_id_nulls,
    SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(order_status IS NULL) AS order_status_nulls,
    SUM(order_purchase_timestamp IS NULL) AS purchase_timestamp_nulls,
    SUM(order_approved_at IS NULL) AS approved_at_nulls,
    SUM(order_delivered_carrier_date IS NULL) AS delivered_carrier_date_nulls,
    SUM(order_delivered_customer_date IS NULL) AS delivered_customer_date_nulls,
    SUM(order_estimated_delivery_date IS NULL) AS estimated_delivery_date_nulls
FROM orders;

/*
===============================================================================
Section 3.2.3 : Blank Value Analysis
Purpose : Identify blank order status values.
===============================================================================
*/

SELECT
    SUM(TRIM(order_status) = '') AS order_status_blanks
FROM orders;

/*
===============================================================================
Section 3.2.4 : Uniqueness Analysis
Purpose : Verify the uniqueness of order identifiers.
===============================================================================
*/

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT order_id) AS unique_order_ids
FROM orders;

/*
===============================================================================
Section 3.2.5 : Order Status Distribution
Purpose : Analyze the distribution of order statuses.
===============================================================================
*/

SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

/*
===============================================================================
Section 3.2.6 : Order Date Range
Purpose : Determine the date range covered by the orders.
===============================================================================
*/

SELECT
    MIN(order_purchase_timestamp) AS first_order,
    MAX(order_purchase_timestamp) AS last_order
FROM orders;

/*
===============================================================================
Section 3.2.7 : Delivery Date Completeness
Purpose : Identify invalid zero dates in delivery timestamps.
===============================================================================
*/

SELECT
    SUM(order_delivered_carrier_date = '0000-00-00 00:00:00') AS carrier_zero_dates,
    SUM(order_delivered_customer_date = '0000-00-00 00:00:00') AS customer_zero_dates
FROM orders;

/*
===============================================================================
Section 3.2.8 : Date Consistency
Purpose : Identify orders with inconsistent lifecycle timestamps.
===============================================================================
*/

SELECT
    COUNT(*) AS inconsistent_orders
FROM orders
WHERE order_approved_at < order_purchase_timestamp
   OR order_delivered_carrier_date < order_approved_at
   OR order_delivered_customer_date < order_delivered_carrier_date;
   
   /*
===============================================================================
Section 3.2.9 : Order Status and Delivery Date Consistency
Purpose : Identify mismatches between order status and delivery dates.
===============================================================================
*/

SELECT
    order_status,
    COUNT(*) AS order_count,
    SUM(order_delivered_customer_date = '0000-00-00 00:00:00') AS zero_delivery_dates
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

/*
===============================================================================
Section 3.3.1 : Table Overview
Purpose : Determine the total number of order items.
===============================================================================
*/

SELECT COUNT(*) AS total_order_items
FROM order_items;

/*
===============================================================================
Section 3.3.2 : NULL Value Analysis
Purpose : Identify missing values in the order items table.
===============================================================================
*/

SELECT
    SUM(order_id IS NULL) AS order_id_nulls,
    SUM(order_item_id IS NULL) AS order_item_id_nulls,
    SUM(product_id IS NULL) AS product_id_nulls,
    SUM(seller_id IS NULL) AS seller_id_nulls,
    SUM(shipping_limit_date IS NULL) AS shipping_limit_date_nulls,
    SUM(price IS NULL) AS price_nulls,
    SUM(freight_value IS NULL) AS freight_value_nulls
FROM order_items;

/*
===============================================================================
Section 3.3.3 : Composite Key Uniqueness
Purpose : Verify the uniqueness of order item identifiers.
===============================================================================
*/

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT order_id, order_item_id) AS unique_order_items
FROM order_items;

/*
===============================================================================
Section 3.3.4 : Date Range
Purpose : Determine the range of shipping limit dates.
===============================================================================
*/

SELECT
    MIN(shipping_limit_date) AS earliest_shipping_limit,
    MAX(shipping_limit_date) AS latest_shipping_limit
FROM order_items;

/*
===============================================================================
Section 3.3.5 : Price and Freight Value Profile
Purpose : Profile the range of item prices and freight values.
===============================================================================
*/

SELECT
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    MIN(freight_value) AS min_freight_value,
    MAX(freight_value) AS max_freight_value
FROM order_items;

/*
===============================================================================
Section 3.3.6 : Relationship Coverage
Purpose : Identify order items with missing parent records.
===============================================================================
*/

SELECT
    SUM(o.order_id IS NULL) AS missing_orders,
    SUM(p.product_id IS NULL) AS missing_products,
    SUM(s.seller_id IS NULL) AS missing_sellers
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
LEFT JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id;
    
    /*
===============================================================================
Section 3.4.1 : Table Overview
Purpose : Determine the total number of products.
===============================================================================
*/

SELECT COUNT(*) AS total_products
FROM products;

/*
===============================================================================
Section 3.4.2 : NULL Value Analysis
Purpose : Identify missing values in the products table.
===============================================================================
*/

SELECT
    SUM(product_id IS NULL) AS product_id_nulls,
    SUM(product_category_name IS NULL) AS category_name_nulls,
    SUM(product_name_lenght IS NULL) AS name_length_nulls,
    SUM(product_description_lenght IS NULL) AS description_length_nulls,
    SUM(product_photos_qty IS NULL) AS photos_qty_nulls,
    SUM(product_weight_g IS NULL) AS weight_nulls,
    SUM(product_length_cm IS NULL) AS length_nulls,
    SUM(product_height_cm IS NULL) AS height_nulls,
    SUM(product_width_cm IS NULL) AS width_nulls
FROM products;

/*
===============================================================================
Section 3.4.3 : Zero Value Analysis
Purpose : Identify zero values in fields affected by import warnings.
===============================================================================
*/

SELECT
    SUM(product_name_lenght = 0) AS name_length_zeros,
    SUM(product_description_lenght = 0) AS description_length_zeros,
    SUM(product_photos_qty = 0) AS photos_qty_zeros
FROM products;

/*
===============================================================================
Section 3.4.4 : Category Distribution
Purpose : Analyze the distribution of product categories.
===============================================================================
*/

SELECT
    product_category_name,
    COUNT(*) AS product_count
FROM products
GROUP BY product_category_name
ORDER BY product_count DESC;

/*
===============================================================================
Section 3.4.5 : Product Dimension Profile
Purpose : Profile the range of product weight and dimensions.
===============================================================================
*/

SELECT
    MIN(product_weight_g) AS min_weight_g,
    MAX(product_weight_g) AS max_weight_g,
    MIN(product_length_cm) AS min_length_cm,
    MAX(product_length_cm) AS max_length_cm,
    MIN(product_height_cm) AS min_height_cm,
    MAX(product_height_cm) AS max_height_cm,
    MIN(product_width_cm) AS min_width_cm,
    MAX(product_width_cm) AS max_width_cm
FROM products;

/*
===============================================================================
Section 3.4.6 : Product ID Uniqueness
Purpose : Verify the uniqueness of product identifiers.
===============================================================================
*/

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT product_id) AS unique_product_ids
FROM products;

/*
===============================================================================
Section 3.5.1 : Table Overview
Purpose : Determine the total number of sellers.
===============================================================================
*/

SELECT COUNT(*) AS total_sellers
FROM sellers;

/*
===============================================================================
Section 3.5.2 : NULL Value Analysis
Purpose : Identify missing values in the sellers table.
===============================================================================
*/

SELECT
    SUM(seller_id IS NULL) AS seller_id_nulls,
    SUM(seller_zip_code_prefix IS NULL) AS zip_code_nulls,
    SUM(seller_city IS NULL) AS city_nulls,
    SUM(seller_state IS NULL) AS state_nulls
FROM sellers;

/*
===============================================================================
Section 3.5.3 : Blank Value Analysis
Purpose : Identify blank seller city and state values.
===============================================================================
*/

SELECT
    SUM(TRIM(seller_city) = '') AS city_blanks,
    SUM(TRIM(seller_state) = '') AS state_blanks
FROM sellers;

/*
===============================================================================
Section 3.5.4 : Seller ID Uniqueness
Purpose : Verify the uniqueness of seller identifiers.
===============================================================================
*/

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT seller_id) AS unique_seller_ids
FROM sellers;

/*
===============================================================================
Section 3.5.5 : Seller Distribution by State
Purpose : Analyze seller distribution across states.
===============================================================================
*/

SELECT
    seller_state,
    COUNT(*) AS seller_count
FROM sellers
GROUP BY seller_state
ORDER BY seller_count DESC;

/*
===============================================================================
Section 3.5.6 : Seller Distribution by City
Purpose : Analyze seller distribution across cities.
===============================================================================
*/

SELECT
    seller_city,
    COUNT(*) AS seller_count
FROM sellers
GROUP BY seller_city
ORDER BY seller_count DESC;

/*
===============================================================================
Section 3.5.7 : ZIP Code Validation
Purpose : Validate the range and uniqueness of seller ZIP code prefixes.
===============================================================================
*/

SELECT
    MIN(seller_zip_code_prefix) AS min_zip_code,
    MAX(seller_zip_code_prefix) AS max_zip_code,
    COUNT(DISTINCT seller_zip_code_prefix) AS unique_zip_codes
FROM sellers;

/*
===============================================================================
Section 3.6.1 : Table Overview
Purpose : Determine the total number of payment records.
===============================================================================
*/

SELECT COUNT(*) AS total_payment_records
FROM order_payments;

/*
===============================================================================
Section 3.6.2 : NULL Value Analysis
Purpose : Identify missing values in the order payments table.
===============================================================================
*/

SELECT
    SUM(order_id IS NULL) AS order_id_nulls,
    SUM(payment_sequential IS NULL) AS payment_sequential_nulls,
    SUM(payment_type IS NULL) AS payment_type_nulls,
    SUM(payment_installments IS NULL) AS payment_installments_nulls,
    SUM(payment_value IS NULL) AS payment_value_nulls
FROM order_payments;

/*
===============================================================================
Section 3.6.3 : Payment Type Distribution
Purpose : Analyze the distribution of payment methods.
===============================================================================
*/

SELECT
    payment_type,
    COUNT(*) AS payment_count
FROM order_payments
GROUP BY payment_type
ORDER BY payment_count DESC;

/*
===============================================================================
Section 3.6.4 : Payment Value Profile
Purpose : Profile the range of payment values and installments.
===============================================================================
*/

SELECT
    MIN(payment_value) AS min_payment_value,
    MAX(payment_value) AS max_payment_value,
    MIN(payment_installments) AS min_installments,
    MAX(payment_installments) AS max_installments
FROM order_payments;

/*
===============================================================================
Section 3.6.5 : Payment Sequence Analysis
Purpose : Identify orders with multiple payment records.
===============================================================================
*/

SELECT
    order_id,
    COUNT(*) AS payment_count
FROM order_payments
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY payment_count DESC;

/*
===============================================================================
Section 3.6.6 : Order Coverage
Purpose : Verify that payment records reference existing orders.
===============================================================================
*/

SELECT
    COUNT(DISTINCT op.order_id) AS payment_orders,
    COUNT(DISTINCT o.order_id) AS matched_orders
FROM order_payments op
LEFT JOIN orders o
    ON op.order_id = o.order_id;
    
    /*
===============================================================================
Section 3.6.7 : Payment Value Validation
Purpose : Identify zero or negative payment values.
===============================================================================
*/

SELECT
    SUM(payment_value = 0) AS zero_payments,
    SUM(payment_value < 0) AS negative_payments
FROM order_payments;

/*
===============================================================================
Section 3.7.1 : Table Overview
Purpose : Determine the total number of review records.
===============================================================================
*/

SELECT COUNT(*) AS total_reviews
FROM order_reviews;

/*
===============================================================================
Section 3.7.2 : NULL Value Analysis
Purpose : Identify missing values in the order reviews table.
===============================================================================
*/

SELECT
    SUM(review_id IS NULL) AS review_id_nulls,
    SUM(order_id IS NULL) AS order_id_nulls,
    SUM(review_score IS NULL) AS review_score_nulls,
    SUM(review_comment_title IS NULL) AS comment_title_nulls,
    SUM(review_comment_message IS NULL) AS comment_message_nulls,
    SUM(review_creation_date IS NULL) AS creation_date_nulls,
    SUM(review_answer_timestamp IS NULL) AS answer_timestamp_nulls
FROM order_reviews;

/*
===============================================================================
Section 3.7.3 : Composite Key Uniqueness
Purpose : Verify the uniqueness of review identifiers.
===============================================================================
*/

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT review_id, order_id) AS unique_review_keys
FROM order_reviews;

/*
===============================================================================
Section 3.7.4 : Review Score Validation
Purpose : Validate the range and distribution of review scores.
===============================================================================
*/

SELECT
    MIN(review_score) AS min_score,
    MAX(review_score) AS max_score,
    COUNT(DISTINCT review_score) AS score_values
FROM order_reviews;

/*
===============================================================================
Section 3.7.5 : Review Comment Completeness
Purpose : Measure the presence of review comments.
===============================================================================
*/

SELECT
    SUM(review_comment_title IS NULL) AS title_nulls,
    SUM(review_comment_message IS NULL) AS message_nulls,
    SUM(TRIM(COALESCE(review_comment_title, '')) = '') AS title_blanks,
    SUM(TRIM(COALESCE(review_comment_message, '')) = '') AS message_blanks
FROM order_reviews;

/*
===============================================================================
Section 3.7.6 : Review Date Range
Purpose : Determine the period covered by review records.
===============================================================================
*/

SELECT
    MIN(review_creation_date) AS earliest_review,
    MAX(review_creation_date) AS latest_review
FROM order_reviews;

/*
===============================================================================
Section 3.7.7 : Date Consistency
Purpose : Identify reviews answered before they were created.
===============================================================================
*/

SELECT
    COUNT(*) AS inconsistent_reviews
FROM order_reviews
WHERE review_answer_timestamp < review_creation_date;

/*
===============================================================================
Section 3.8.1 : Table Overview
Purpose : Determine the total number of geolocation records.
===============================================================================
*/

SELECT COUNT(*) AS total_geolocation_records
FROM geolocation;

/*
===============================================================================
Section 3.8.2 : NULL Value Analysis
Purpose : Identify missing values in the geolocation table.
===============================================================================
*/

SELECT
    SUM(geolocation_zip_code_prefix IS NULL) AS zip_code_nulls,
    SUM(geolocation_lat IS NULL) AS latitude_nulls,
    SUM(geolocation_lng IS NULL) AS longitude_nulls,
    SUM(geolocation_city IS NULL) AS city_nulls,
    SUM(geolocation_state IS NULL) AS state_nulls
FROM geolocation;

/*
===============================================================================
Section 3.8.3 : Coordinate Range Validation
Purpose : Validate the range of latitude and longitude values.
===============================================================================
*/

SELECT
    MIN(geolocation_lat) AS min_latitude,
    MAX(geolocation_lat) AS max_latitude,
    MIN(geolocation_lng) AS min_longitude,
    MAX(geolocation_lng) AS max_longitude
FROM geolocation;

/*
===============================================================================
Section 3.8.4 : ZIP Code Coverage
Purpose : Determine the number of unique ZIP code prefixes represented.
===============================================================================
*/

SELECT
    COUNT(DISTINCT geolocation_zip_code_prefix) AS unique_zip_codes
FROM geolocation;

/*
===============================================================================
Section 3.8.5 : Location Combination Check
Purpose : Identify duplicate ZIP code, city and state combinations.
===============================================================================
*/

SELECT
    geolocation_zip_code_prefix,
    geolocation_city,
    geolocation_state,
    COUNT(*) AS location_count
FROM geolocation
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_city,
    geolocation_state
HAVING COUNT(*) > 1
ORDER BY location_count DESC;

/*
===============================================================================
Section 3.9.1 : Table Overview
Purpose : Determine the total number of category translations.
===============================================================================
*/

SELECT COUNT(*) AS total_translations
FROM product_category_name_translation;

/*
===============================================================================
Section 3.9.2 : NULL Value Analysis
Purpose : Identify missing values in the category translation table.
===============================================================================
*/

SELECT
    SUM(product_category_name IS NULL) AS category_name_nulls,
    SUM(product_category_name_english IS NULL) AS english_name_nulls
FROM product_category_name_translation;

/*
===============================================================================
Section 3.9.3 : Category Name Uniqueness
Purpose : Verify the uniqueness of category names in the translation table.
===============================================================================
*/

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT product_category_name) AS unique_category_names,
    COUNT(DISTINCT product_category_name_english) AS unique_english_names
FROM product_category_name_translation;

/*
===============================================================================
Section 3.9.4 : Blank Value Analysis
Purpose : Identify blank category names in the translation table.
===============================================================================
*/

SELECT
    SUM(TRIM(product_category_name) = '') AS category_name_blanks,
    SUM(TRIM(product_category_name_english) = '') AS english_name_blanks
FROM product_category_name_translation;


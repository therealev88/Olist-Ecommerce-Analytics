/*
===============================================================================
Section 4.1.1 : Customer Identifier Integrity
Purpose : Check customer identifiers for invalid or suspicious values.
===============================================================================
*/

SELECT
    COUNT(*) AS invalid_customer_ids
FROM customers
WHERE customer_id IS NULL
   OR customer_unique_id IS NULL
   OR customer_id = ''
   OR customer_unique_id = '';
   
   /*
===============================================================================
Section 4.1.2 : Geographic Consistency
Purpose : Identify customer ZIP prefixes linked to conflicting locations.
===============================================================================
*/

/*
===============================================================================
Section 4.1.3 : Conflicting Customer Locations
Purpose : Identify the cities associated with conflicting ZIP prefixes.
===============================================================================
*/

SELECT
    customer_zip_code_prefix,
    customer_city,
    customer_state,
    COUNT(*) AS customer_count
FROM customers
WHERE customer_zip_code_prefix IN ('06806', '06810', '06813', '06814', '06823')
GROUP BY
    customer_zip_code_prefix,
    customer_city,
    customer_state
ORDER BY
    customer_zip_code_prefix,
    customer_city;
    
    /*
===============================================================================
Section 4.1.4 : Geographic Anomaly
Purpose : Quantify records affected by the customer city inconsistency.
===============================================================================
*/

SELECT
    customer_city,
    COUNT(*) AS customer_count
FROM customers
WHERE customer_zip_code_prefix IN ('06806', '06810', '06813', '06814', '06823')
GROUP BY customer_city
ORDER BY customer_count DESC;

/*
===============================================================================
Section 4.2.1 : Zero-Date Assessment
Purpose : Quantify zero-date values in order timestamp columns.
===============================================================================
*/

SELECT
    SUM(order_purchase_timestamp = '0000-00-00 00:00:00') AS purchase_zero_dates,
    SUM(order_approved_at = '0000-00-00 00:00:00') AS approved_zero_dates,
    SUM(order_delivered_carrier_date = '0000-00-00 00:00:00') AS carrier_zero_dates,
    SUM(order_delivered_customer_date = '0000-00-00 00:00:00') AS customer_zero_dates,
    SUM(order_estimated_delivery_date = '0000-00-00 00:00:00') AS estimated_zero_dates
FROM orders;

/*
===============================================================================
Section 4.2.2 : Zero Dates vs Order Status
Purpose : Determine whether zero dates correspond to undelivered orders.
===============================================================================
*/

SELECT
    order_status,
    COUNT(*) AS order_count,
    SUM(order_approved_at = '0000-00-00 00:00:00') AS zero_approved,
    SUM(order_delivered_carrier_date = '0000-00-00 00:00:00') AS zero_carrier,
    SUM(order_delivered_customer_date = '0000-00-00 00:00:00') AS zero_customer
FROM orders
GROUP BY order_status
ORDER BY order_status;

/*
===============================================================================
Section 4.2.3 : Delivered Order Timestamp Integrity
Purpose : Identify delivered orders with missing lifecycle timestamps.
===============================================================================
*/

SELECT
    order_id,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date
FROM orders
WHERE order_status = 'delivered'
  AND (
        order_approved_at = '0000-00-00 00:00:00'
     OR order_delivered_carrier_date = '0000-00-00 00:00:00'
     OR order_delivered_customer_date = '0000-00-00 00:00:00'
  );
  
  /*
===============================================================================
Section 4.2.4 : Order Timeline Integrity
Purpose : Identify orders with impossible timestamp sequences.
===============================================================================
*/

SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date
FROM orders
WHERE
       (order_approved_at <> '0000-00-00 00:00:00'
        AND order_approved_at < order_purchase_timestamp)
    OR (order_delivered_carrier_date <> '0000-00-00 00:00:00'
        AND order_delivered_carrier_date < order_approved_at
        AND order_approved_at <> '0000-00-00 00:00:00')
    OR (order_delivered_customer_date <> '0000-00-00 00:00:00'
        AND order_delivered_carrier_date <> '0000-00-00 00:00:00'
        AND order_delivered_customer_date < order_delivered_carrier_date);
        
        /*
===============================================================================
Section 4.2.5 : Timeline Violation Breakdown
Purpose : Separate order timeline violations by timestamp relationship.
===============================================================================
*/

SELECT
    SUM(
        order_approved_at <> '0000-00-00 00:00:00'
        AND order_approved_at < order_purchase_timestamp
    ) AS approved_before_purchase,

    SUM(
        order_delivered_carrier_date <> '0000-00-00 00:00:00'
        AND order_approved_at <> '0000-00-00 00:00:00'
        AND order_delivered_carrier_date < order_approved_at
    ) AS carrier_before_approval,

    SUM(
        order_delivered_customer_date <> '0000-00-00 00:00:00'
        AND order_delivered_carrier_date <> '0000-00-00 00:00:00'
        AND order_delivered_customer_date < order_delivered_carrier_date
    ) AS customer_before_carrier
FROM orders;

/*
===============================================================================
Section 4.2.6 : Carrier Timestamp Violations
Purpose : Inspect orders where carrier delivery predates approval.
===============================================================================
*/

SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date
FROM orders
WHERE order_delivered_carrier_date <> '0000-00-00 00:00:00'
  AND order_approved_at <> '0000-00-00 00:00:00'
  AND order_delivered_carrier_date < order_approved_at
LIMIT 20;

/*
===============================================================================
Section 4.2.7 : Customer Delivery Before Carrier
Purpose : Identify orders where customer delivery predates carrier delivery.
===============================================================================
*/

SELECT
    order_id,
    order_status,
    order_delivered_carrier_date,
    order_delivered_customer_date
FROM orders
WHERE order_delivered_carrier_date <> '0000-00-00 00:00:00'
  AND order_delivered_customer_date <> '0000-00-00 00:00:00'
  AND order_delivered_customer_date < order_delivered_carrier_date
LIMIT 30;

/*
===============================================================================
Section 4.3.1 : Order Item Numeric Integrity
Purpose : Identify invalid price and freight values.
===============================================================================
*/

SELECT
    SUM(price <= 0) AS invalid_price,
    SUM(freight_value < 0) AS invalid_freight,
    MIN(price) AS min_price,
    MIN(freight_value) AS min_freight
FROM order_items;

/*
===============================================================================
Section 4.3.2 : Order Item Referential Integrity
Purpose : Identify order items without matching orders, products, or sellers.
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
Section 4.3.3 : Order Item Key Integrity
Purpose : Identify duplicate item sequence numbers within an order.
===============================================================================
*/

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_count
FROM order_items
GROUP BY
    order_id,
    order_item_id
HAVING COUNT(*) > 1
LIMIT 20;

/*
===============================================================================
Section 4.4.1 : Product Attribute Zero Assessment
Purpose : Determine the extent of zero values in imported product attributes.
===============================================================================
*/

SELECT
    SUM(product_name_lenght = 0) AS zero_name_length,
    SUM(product_description_lenght = 0) AS zero_description_length,
    SUM(product_photos_qty = 0) AS zero_photo_quantity
FROM products;

/*
===============================================================================
Section 4.4.2 : Product Attribute Consistency
Purpose : Determine whether zero attributes occur on the same product records.
===============================================================================
*/

SELECT
    COUNT(*) AS products_with_all_zero_attributes
FROM products
WHERE product_name_lenght = 0
  AND product_description_lenght = 0
  AND product_photos_qty = 0;
  
  /*
===============================================================================
Section 4.4.3 : Product Dimension Integrity
Purpose : Identify impossible negative product measurements.
===============================================================================
*/

SELECT
    SUM(product_weight_g < 0) AS negative_weight,
    SUM(product_length_cm < 0) AS negative_length,
    SUM(product_height_cm < 0) AS negative_height,
    SUM(product_width_cm < 0) AS negative_width
FROM products;

/*
===============================================================================
Section 4.5.1 : Seller Identifier Integrity
Purpose : Check seller identifiers for duplicates or invalid values.
===============================================================================
*/

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT seller_id) AS unique_seller_ids
FROM sellers;

/*
===============================================================================
Section 4.5.2 : Seller Geographic Consistency
Purpose : Identify seller ZIP prefixes linked to multiple states.
===============================================================================
*/

SELECT
    seller_zip_code_prefix,
    COUNT(DISTINCT seller_state) AS state_count
FROM sellers
GROUP BY seller_zip_code_prefix
HAVING COUNT(DISTINCT seller_state) > 1
ORDER BY seller_zip_code_prefix;

/*
===============================================================================
Section 4.5.3 : Seller Geographic Conflicts
Purpose : Identify the states associated with conflicting seller ZIP prefixes.
===============================================================================
*/

SELECT DISTINCT
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM sellers
WHERE seller_zip_code_prefix IN (
    '21210', '22783', '31160', '36010', '37540',
    '37795', '44600', '80240', '81020', '81560',
    '83020', '83321', '85960', '88075', '88301',
    '89052', '95076'
)
ORDER BY
    seller_zip_code_prefix,
    seller_state,
    seller_city;
    
    /*
===============================================================================
Section 4.5.4 : Affected Seller Records
Purpose : Quantify sellers linked to conflicting ZIP/state combinations.
===============================================================================
*/

SELECT
    COUNT(*) AS affected_sellers
FROM sellers
WHERE seller_zip_code_prefix IN (
    '21210', '22783', '31160', '36010', '37540',
    '37795', '44600', '80240', '81020', '81560',
    '83020', '83321', '85960', '88075', '88301',
    '89052', '95076'
);

/*
===============================================================================
Section 4.6.1 : Payment Value Integrity
Purpose : Identify invalid payment amounts and installment values.
===============================================================================
*/

SELECT
    SUM(payment_value <= 0) AS invalid_payment_values,
    SUM(payment_installments <= 0) AS invalid_installments,
    MIN(payment_value) AS min_payment_value,
    MIN(payment_installments) AS min_installments
FROM order_payments;

/*
===============================================================================
Section 4.6.2 : Invalid Payment Records
Purpose : Inspect payment records with non-positive values or installments.
===============================================================================
*/

SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM order_payments
WHERE payment_value <= 0
   OR payment_installments <= 0
ORDER BY payment_value, payment_installments;

/*
===============================================================================
Section 4.6.3 : Payment Type Assessment
Purpose : Identify payment types outside the expected categories.
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
Section 4.7.1 : Review Score Integrity
Purpose : Identify review scores outside the valid range.
===============================================================================
*/

SELECT
    COUNT(*) AS invalid_review_scores
FROM order_reviews
WHERE review_score < 1
   OR review_score > 5
   OR review_score IS NULL;
   
   /*
===============================================================================
Section 4.7.2 : Review Key Integrity
Purpose : Identify review IDs associated with multiple orders.
===============================================================================
*/

SELECT
    review_id,
    COUNT(DISTINCT order_id) AS order_count
FROM order_reviews
GROUP BY review_id
HAVING COUNT(DISTINCT order_id) > 1
ORDER BY order_count DESC;

/*
===============================================================================
Section 4.7.3 : Review ID Duplication
Purpose : Quantify review IDs associated with multiple orders.
===============================================================================
*/

SELECT
    COUNT(*) AS repeated_review_ids,
    MAX(order_count) AS max_orders_per_review_id
FROM (
    SELECT
        review_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM order_reviews
    GROUP BY review_id
    HAVING COUNT(DISTINCT order_id) > 1
) AS repeated_reviews;

/*
===============================================================================
Section 4.7.4 : Repeated Review ID Sample
Purpose : Inspect review IDs associated with multiple orders.
===============================================================================
*/

SELECT
    review_id,
    order_id,
    review_score,
    review_creation_date,
    review_answer_timestamp
FROM order_reviews
WHERE review_id IN (
    SELECT review_id
    FROM order_reviews
    GROUP BY review_id
    HAVING COUNT(DISTINCT order_id) > 1
)
ORDER BY review_id, order_id
LIMIT 20;

/*
===============================================================================
Section 4.7.5 : Review Comment Completeness
Purpose : Quantify missing and blank review comments.
===============================================================================
*/

SELECT
    SUM(review_comment_message IS NULL) AS null_comments,
    SUM(TRIM(review_comment_message) = '') AS blank_comments
FROM order_reviews;

/*
===============================================================================
Section 4.8.1 : ZIP/City Consistency
Purpose : Identify ZIP prefixes associated with multiple city names.
===============================================================================
*/

SELECT
    geolocation_zip_code_prefix,
    COUNT(DISTINCT geolocation_city) AS city_count
FROM geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(DISTINCT geolocation_city) > 1
ORDER BY city_count DESC;

/*
===============================================================================
Section 4.8.2 : ZIP/State/City Consistency
Purpose : Identify ZIP/state combinations linked to multiple city names.
===============================================================================
*/

SELECT
    geolocation_zip_code_prefix,
    geolocation_state,
    COUNT(DISTINCT geolocation_city) AS city_count
FROM geolocation
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_state
HAVING COUNT(DISTINCT geolocation_city) > 1
ORDER BY city_count DESC;

/*
===============================================================================
Section 4.8.3 : Potential City Naming Anomalies
Purpose : Identify ZIP/state combinations with a small number of city names.
===============================================================================
*/

SELECT
    geolocation_zip_code_prefix,
    geolocation_state,
    COUNT(DISTINCT geolocation_city) AS city_count
FROM geolocation
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_state
HAVING COUNT(DISTINCT geolocation_city) BETWEEN 2 AND 3
ORDER BY
    geolocation_zip_code_prefix;
    
    /*
===============================================================================
Section 4.8.3 : Coordinate Integrity
Purpose : Identify geolocation records with impossible coordinate values.
===============================================================================
*/

SELECT
    SUM(geolocation_lat < -90 OR geolocation_lat > 90) AS invalid_latitude,
    SUM(geolocation_lng < -180 OR geolocation_lng > 180) AS invalid_longitude
FROM geolocation;

/*
===============================================================================
Section 4.9.1 : Translation Mapping Integrity
Purpose : Identify duplicate or incomplete category translations.
===============================================================================
*/

SELECT
    COUNT(*) AS total_mappings,
    COUNT(DISTINCT product_category_name) AS unique_portuguese_names,
    COUNT(DISTINCT product_category_name_english) AS unique_english_names,
    SUM(product_category_name IS NULL OR product_category_name = '') AS missing_portuguese,
    SUM(product_category_name_english IS NULL OR product_category_name_english = '') AS missing_english
FROM product_category_name_translation;
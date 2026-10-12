/*
===============================================================================
Section 6.1.1 : Validate Customers
Purpose : Confirm customer identifiers and required fields remain valid.
===============================================================================
*/

SELECT
    COUNT(*) AS total_customers,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    SUM(customer_id IS NULL OR customer_id = '') AS invalid_customer_ids,
    SUM(customer_unique_id IS NULL OR customer_unique_id = '') AS invalid_unique_ids,
    SUM(customer_zip_code_prefix IS NULL) AS null_zip_prefix,
    SUM(customer_state IS NULL OR customer_state = '') AS invalid_states
FROM customers_clean;

/*
===============================================================================
Section 6.2.1 : Validate Order Timestamps
Purpose : Confirm cleaned order timestamps contain no zero dates or impossible
          purchase-to-approval chronology.
===============================================================================
*/

SELECT
    COUNT(*) AS total_orders,
    SUM(order_purchase_timestamp IS NULL) AS null_purchase,
    SUM(order_approved_at IS NULL) AS null_approved,
    SUM(order_delivered_carrier_date IS NULL) AS null_carrier,
    SUM(order_delivered_customer_date IS NULL) AS null_customer,
    SUM(
        order_approved_at IS NOT NULL
        AND order_approved_at < order_purchase_timestamp
    ) AS approval_before_purchase
FROM orders_clean;

/*
===============================================================================
Section 6.2.2 : Validate Delivery Chronology
Purpose : Confirm the cleaned order timestamps and identify remaining sequence
          inconsistencies.
===============================================================================
*/

SELECT
    SUM(
        order_delivered_carrier_date IS NOT NULL
        AND order_approved_at IS NOT NULL
        AND order_delivered_carrier_date < order_approved_at
    ) AS carrier_before_approval,
    SUM(
        order_delivered_customer_date IS NOT NULL
        AND order_delivered_carrier_date IS NOT NULL
        AND order_delivered_customer_date < order_delivered_carrier_date
    ) AS customer_before_carrier
FROM orders_clean;

/*
===============================================================================
Section 6.3.1 : Validate Order Items
Purpose : Confirm order-item keys and relationships to orders, products, and sellers.
===============================================================================
*/

SELECT
    COUNT(*) AS total_items,
    COUNT(DISTINCT oi.order_id, oi.order_item_id) AS unique_item_keys,
    SUM(o.order_id IS NULL) AS orphan_orders,
    SUM(p.product_id IS NULL) AS orphan_products,
    SUM(s.seller_id IS NULL) AS orphan_sellers
FROM order_items_clean oi
LEFT JOIN orders_clean o
    ON oi.order_id = o.order_id
LEFT JOIN products_clean p
    ON oi.product_id = p.product_id
LEFT JOIN sellers_clean s
    ON oi.seller_id = s.seller_id;
    
    /*
===============================================================================
Section 6.4.1 : Validate Products
Purpose : Confirm product identifiers and cleaned attributes remain valid.
===============================================================================
*/

SELECT
    COUNT(*) AS total_products,
    COUNT(DISTINCT product_id) AS unique_product_ids,
    SUM(product_id IS NULL OR product_id = '') AS invalid_product_ids,
    SUM(product_name_lenght = 0) AS zero_name_length,
    SUM(product_description_lenght = 0) AS zero_description_length,
    SUM(product_photos_qty = 0) AS zero_photo_quantity,
    SUM(product_weight_g IS NOT NULL AND product_weight_g < 0) AS negative_weight,
    SUM(product_length_cm IS NOT NULL AND product_length_cm < 0) AS negative_length,
    SUM(product_height_cm IS NOT NULL AND product_height_cm < 0) AS negative_height,
    SUM(product_width_cm IS NOT NULL AND product_width_cm < 0) AS negative_width
FROM products_clean;

/*
===============================================================================
Section 6.5.1 : Validate Sellers
Purpose : Confirm seller identifiers and order-item relationships remain valid.
===============================================================================
*/

SELECT
    COUNT(*) AS total_sellers,
    COUNT(DISTINCT s.seller_id) AS unique_seller_ids,
    SUM(s.seller_id IS NULL OR s.seller_id = '') AS invalid_seller_ids,
    SUM(oi.seller_id IS NULL) AS sellers_without_order_items
FROM sellers_clean s
LEFT JOIN (
    SELECT DISTINCT seller_id
    FROM order_items_clean
) oi
    ON s.seller_id = oi.seller_id;
    
    /*
===============================================================================
Section 6.6.1 : Validate Order Payments
Purpose : Confirm payment values and installments remain within valid ranges.
===============================================================================
*/

SELECT
    COUNT(*) AS total_payments,
    SUM(payment_value < 0) AS negative_values,
    SUM(payment_installments < 0) AS negative_installments,
    SUM(payment_type IS NULL OR payment_type = '') AS invalid_payment_types,
    SUM(payment_type = 'not_defined') AS undefined_payment_types,
    SUM(payment_type = 'credit_card' AND payment_installments = 0
        AND payment_value > 0) AS zero_installment_cards
FROM order_payments_clean;

/*
===============================================================================
Section 6.7.1 : Validate Order Reviews
Purpose : Confirm review identifiers, scores, timestamps, and cleaned comments.
===============================================================================
*/

SELECT
    COUNT(*) AS total_reviews,
    COUNT(DISTINCT review_id) AS unique_review_ids,
    SUM(review_score < 1 OR review_score > 5) AS invalid_scores,
    SUM(review_creation_date IS NULL) AS null_creation_dates,
    SUM(review_answer_timestamp IS NULL) AS null_answer_timestamps,
    SUM(review_comment_message IS NULL) AS null_comments,
    SUM(TRIM(review_comment_message) = '') AS blank_comments
FROM order_reviews_clean;

/*
===============================================================================
Section 6.8.1 : Validate Geolocation
Purpose : Confirm geolocation coordinates and ZIP prefixes remain valid.
===============================================================================
*/

SELECT
    COUNT(*) AS total_records,
    SUM(geolocation_zip_code_prefix IS NULL) AS null_zip_prefix,
    SUM(geolocation_lat IS NULL) AS null_latitude,
    SUM(geolocation_lng IS NULL) AS null_longitude,
    SUM(geolocation_lat < -90 OR geolocation_lat > 90) AS invalid_latitude,
    SUM(geolocation_lng < -180 OR geolocation_lng > 180) AS invalid_longitude
FROM geolocation_clean;

/*
===============================================================================
Section 6.9.1 : Validate Product Category Translation
Purpose : Confirm category mappings remain complete and unique.
===============================================================================
*/

SELECT
    COUNT(*) AS total_mappings,
    COUNT(DISTINCT product_category_name) AS unique_portuguese,
    COUNT(DISTINCT product_category_name_english) AS unique_english,
    SUM(product_category_name IS NULL OR product_category_name = '')
        AS missing_portuguese,
    SUM(product_category_name_english IS NULL OR product_category_name_english = '')
        AS missing_english
FROM product_category_name_translation_clean;

/*
===============================================================================
Section 6.10 : Final Cross-Table Validation
Purpose : Confirm referential integrity across the cleaned core tables.
===============================================================================
*/

SELECT
    (SELECT COUNT(*)
     FROM orders_clean o
     LEFT JOIN customers_clean c
        ON o.customer_id = c.customer_id
     WHERE c.customer_id IS NULL) AS orphan_orders,

    (SELECT COUNT(*)
     FROM order_items_clean oi
     LEFT JOIN orders_clean o
        ON oi.order_id = o.order_id
     WHERE o.order_id IS NULL) AS orphan_order_items,

    (SELECT COUNT(*)
     FROM order_items_clean oi
     LEFT JOIN products_clean p
        ON oi.product_id = p.product_id
     WHERE p.product_id IS NULL) AS orphan_products,

    (SELECT COUNT(*)
     FROM order_items_clean oi
     LEFT JOIN sellers_clean s
        ON oi.seller_id = s.seller_id
     WHERE s.seller_id IS NULL) AS orphan_sellers,

    (SELECT COUNT(*)
     FROM order_payments_clean op
     LEFT JOIN orders_clean o
        ON op.order_id = o.order_id
     WHERE o.order_id IS NULL) AS orphan_payments,

    (SELECT COUNT(*)
     FROM order_reviews_clean r
     LEFT JOIN orders_clean o
        ON r.order_id = o.order_id
     WHERE o.order_id IS NULL) AS orphan_reviews;
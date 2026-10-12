/*
===============================================================================
Section 7.1.1 : Dataset Overview
Purpose : Establish the size and basic coverage of the cleaned dataset.
===============================================================================
*/

SELECT
    (SELECT COUNT(*) FROM orders_clean) AS orders,
    (SELECT COUNT(*) FROM order_items_clean) AS order_items,
    (SELECT COUNT(*) FROM products_clean) AS products,
    (SELECT COUNT(*) FROM customers_clean) AS customers,
    (SELECT COUNT(*) FROM sellers_clean) AS sellers,
    (SELECT COUNT(*) FROM order_payments_clean) AS payments,
    (SELECT COUNT(*) FROM order_reviews_clean) AS reviews;
    
    /*
===============================================================================
Section 7.2.1 : Monthly Order and Payment Trend
Purpose : Analyze monthly order volume and total recorded payment value.
===============================================================================
*/

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(p.payment_value), 2) AS total_payment_value
FROM orders_clean o
JOIN order_payments_clean p
    ON o.order_id = p.order_id
GROUP BY
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY
    order_month;
    
    /*
===============================================================================
Section 7.2.2 : Monthly Average Order Value
Purpose : Compare average recorded payment value per order over time.
===============================================================================
*/

SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(p.payment_value), 2) AS total_payment_value,
    ROUND(
        SUM(p.payment_value) / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM orders_clean o
JOIN order_payments_clean p
    ON o.order_id = p.order_id
GROUP BY
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY
    order_month;
    
    /*
===============================================================================
Section 7.3.1 : Order Status Distribution
Purpose : Analyze the distribution of orders across lifecycle statuses.
===============================================================================
*/

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders_clean),
        2
    ) AS percentage_of_orders
FROM orders_clean
GROUP BY
    order_status
ORDER BY
    order_count DESC;
    
    /*
===============================================================================
Section 7.3.2 : Delivery Performance
Purpose : Measure delivery duration for completed orders.
===============================================================================
*/

SELECT
    COUNT(*) AS delivered_orders,
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                DAY,
                order_purchase_timestamp,
                order_delivered_customer_date
            )
        ),
        2
    ) AS average_delivery_days,
    MIN(
        TIMESTAMPDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        )
    ) AS minimum_delivery_days,
    MAX(
        TIMESTAMPDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        )
    ) AS maximum_delivery_days
FROM orders_clean
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;
  
  /*
===============================================================================
Section 7.3.3 : Delivery Performance vs Estimate
Purpose : Compare actual customer delivery dates with estimated delivery dates.
===============================================================================
*/

SELECT
    SUM(
        order_delivered_customer_date <= order_estimated_delivery_date
    ) AS delivered_on_or_before_estimate,
    SUM(
        order_delivered_customer_date > order_estimated_delivery_date
    ) AS delivered_after_estimate,
    ROUND(
        SUM(
            order_delivered_customer_date <= order_estimated_delivery_date
        ) * 100.0 / COUNT(*),
        2
    ) AS on_time_percentage,
    ROUND(
        SUM(
            order_delivered_customer_date > order_estimated_delivery_date
        ) * 100.0 / COUNT(*),
        2
    ) AS late_percentage
FROM orders_clean
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;
  
  /*
===============================================================================
Section 7.3.4 : Monthly Delivery Performance
Purpose : Analyze on-time and late delivery rates by order purchase month.
===============================================================================
*/

SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(*) AS delivered_orders,
    SUM(
        order_delivered_customer_date <= order_estimated_delivery_date
    ) AS on_time_orders,
    SUM(
        order_delivered_customer_date > order_estimated_delivery_date
    ) AS late_orders,
    ROUND(
        SUM(
            order_delivered_customer_date <= order_estimated_delivery_date
        ) * 100.0 / COUNT(*),
        2
    ) AS on_time_percentage
FROM orders_clean
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY
    order_month;
    
    /*
===============================================================================
Section 7.3.5 : Delivery Delay Magnitude
Purpose : Measure the severity of delays among orders delivered after the estimate.
===============================================================================
*/

SELECT
    COUNT(*) AS late_orders,
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                DAY,
                order_estimated_delivery_date,
                order_delivered_customer_date
            )
        ),
        2
    ) AS average_delay_days,
    MIN(
        TIMESTAMPDIFF(
            DAY,
            order_estimated_delivery_date,
            order_delivered_customer_date
        )
    ) AS minimum_delay_days,
    MAX(
        TIMESTAMPDIFF(
            DAY,
            order_estimated_delivery_date,
            order_delivered_customer_date
        )
    ) AS maximum_delay_days
FROM orders_clean
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_delivered_customer_date > order_estimated_delivery_date;
  
  /*
===============================================================================
Section 7.3.6 : Cancellation and Unavailability
Purpose : Measure orders that did not reach successful fulfillment.
===============================================================================
*/

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders_clean),
        2
    ) AS percentage_of_orders
FROM orders_clean
WHERE order_status IN ('canceled', 'unavailable')
GROUP BY
    order_status
ORDER BY
    order_count DESC;
    
    /*
===============================================================================
Section 7.3.7 : Monthly Fulfillment Failure Rate
Purpose : Analyze cancellation and unavailability rates over time.
===============================================================================
*/

SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(*) AS total_orders,
    SUM(order_status = 'canceled') AS canceled_orders,
    SUM(order_status = 'unavailable') AS unavailable_orders,
    ROUND(
        SUM(order_status IN ('canceled', 'unavailable')) * 100.0 / COUNT(*),
        2
    ) AS failure_rate
FROM orders_clean
GROUP BY
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m')
ORDER BY
    order_month;
    
    /*
===============================================================================
Section 7.4.1 : Customer Purchase Frequency
Purpose : Classify customers by the number of orders they placed.
===============================================================================
*/

SELECT
    CASE
        WHEN order_count = 1 THEN 'one-time'
        ELSE 'repeat'
    END AS customer_type,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_customers
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers_clean c
    JOIN orders_clean o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_unique_id
) customer_orders
GROUP BY
    customer_type
ORDER BY
    customer_count DESC;
    
    /*
===============================================================================
Section 7.4.2 : Repeat Customer Order Frequency
Purpose : Examine how many orders repeat customers place.
===============================================================================
*/

SELECT
    order_count,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_repeat_customers
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers_clean c
    JOIN orders_clean o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) > 1
) repeat_customers
GROUP BY
    order_count
ORDER BY
    order_count;
    
    /*
===============================================================================
Section 7.4.3 : Customer Order Distribution
Purpose : Show the distribution of orders placed per customer.
===============================================================================
*/

SELECT
    order_count,
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_customers
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers_clean c
    JOIN orders_clean o
        ON c.customer_id = o.customer_id
    GROUP BY
        c.customer_unique_id
) customer_orders
GROUP BY
    order_count
ORDER BY
    order_count;
    
    /*
===============================================================================
Section 7.4.4 : Customer Geographic Distribution
Purpose : Examine customer distribution across Brazilian states.
===============================================================================
*/

SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS customer_count,
    ROUND(
        COUNT(DISTINCT customer_unique_id) * 100.0 /
        SUM(COUNT(DISTINCT customer_unique_id)) OVER (),
        2
    ) AS percentage_of_customers
FROM customers_clean
GROUP BY
    customer_state
ORDER BY
    customer_count DESC;
    
    /*
===============================================================================
Section 7.4.5 : Customer Orders by State
Purpose : Compare customer concentration with order volume across states.
===============================================================================
*/

SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS customers,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id) * 100.0 /
        SUM(COUNT(DISTINCT o.order_id)) OVER (),
        2
    ) AS percentage_of_orders
FROM customers_clean c
JOIN orders_clean o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_state
ORDER BY
    orders DESC;
    
    /*
===============================================================================
Section 7.5.1 : Orders by Product Category
Purpose : Rank product categories by order volume.
===============================================================================
*/

SELECT
    COALESCE(t.product_category_name_english, p.product_category_name) AS category,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS items
FROM order_items_clean oi
JOIN products_clean p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation_clean t
    ON p.product_category_name = t.product_category_name
GROUP BY
    COALESCE(t.product_category_name_english, p.product_category_name)
ORDER BY
    orders DESC;
    
    /*
===============================================================================
Section 7.5.2 : Payment Value by Product Category
Purpose : Rank product categories by recorded payment value.
===============================================================================
*/

SELECT
    COALESCE(t.product_category_name_english, p.product_category_name) AS category,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS item_value,
    ROUND(
        SUM(oi.price + oi.freight_value) /
        COUNT(DISTINCT oi.order_id),
        2
    ) AS average_order_value
FROM order_items_clean oi
JOIN products_clean p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation_clean t
    ON p.product_category_name = t.product_category_name
GROUP BY
    COALESCE(t.product_category_name_english, p.product_category_name)
ORDER BY
    item_value DESC;
    
    /*
===============================================================================
Section 7.5.3 : Average Product Price by Category
Purpose : Compare average product prices across categories.
===============================================================================
*/

SELECT
    COALESCE(t.product_category_name_english, p.product_category_name) AS category,
    COUNT(*) AS items_sold,
    ROUND(AVG(oi.price), 2) AS average_product_price,
    ROUND(MIN(oi.price), 2) AS minimum_price,
    ROUND(MAX(oi.price), 2) AS maximum_price
FROM order_items_clean oi
JOIN products_clean p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation_clean t
    ON p.product_category_name = t.product_category_name
GROUP BY
    COALESCE(t.product_category_name_english, p.product_category_name)
HAVING COUNT(*) >= 50
ORDER BY
    average_product_price DESC;
    
    /*
===============================================================================
Section 7.5.4 : Top Products by Sales Volume
Purpose : Identify products with the highest number of items sold.
===============================================================================
*/

SELECT
    oi.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name) AS category,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS product_value,
    ROUND(AVG(oi.price), 2) AS average_price
FROM order_items_clean oi
JOIN products_clean p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation_clean t
    ON p.product_category_name = t.product_category_name
GROUP BY
    oi.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name)
ORDER BY
    items_sold DESC
LIMIT 20;

/*
===============================================================================
Section 7.5.5 : Top Products by Item Value
Purpose : Identify products with the highest total item value.
===============================================================================
*/

SELECT
    oi.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name) AS category,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS product_value,
    ROUND(AVG(oi.price), 2) AS average_price
FROM order_items_clean oi
JOIN products_clean p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation_clean t
    ON p.product_category_name = t.product_category_name
GROUP BY
    oi.product_id,
    COALESCE(t.product_category_name_english, p.product_category_name)
ORDER BY
    product_value DESC
LIMIT 20;

/*
===============================================================================
Section 7.6.1 : Seller Performance by Order Volume
Purpose : Rank sellers by orders handled and item value.
===============================================================================
*/

SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS item_value,
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT oi.order_id),
        2
    ) AS average_order_value
FROM order_items_clean oi
GROUP BY
    oi.seller_id
ORDER BY
    orders DESC
LIMIT 20;

/*
===============================================================================
Section 7.6.2 : Top Sellers by Item Value
Purpose : Rank sellers by total item value.
===============================================================================
*/

SELECT
    oi.seller_id,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS item_value,
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT oi.order_id),
        2
    ) AS average_order_value
FROM order_items_clean oi
GROUP BY
    oi.seller_id
ORDER BY
    item_value DESC
LIMIT 20;

/*
===============================================================================
Section 7.6.3 : Seller Geographic Distribution
Purpose : Examine seller concentration across Brazilian states.
===============================================================================
*/

SELECT
    s.seller_state,
    COUNT(DISTINCT s.seller_id) AS sellers,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price), 2) AS item_value
FROM sellers_clean s
JOIN order_items_clean oi
    ON s.seller_id = oi.seller_id
GROUP BY
    s.seller_state
ORDER BY
    sellers DESC;
    
    /*
===============================================================================
Section 7.6.4 : Seller Productivity by State
Purpose : Compare average seller output across states.
===============================================================================
*/

SELECT
    s.seller_state,
    COUNT(DISTINCT s.seller_id) AS sellers,
    ROUND(SUM(oi.price), 2) AS item_value,
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT s.seller_id),
        2
    ) AS value_per_seller
FROM sellers_clean s
JOIN order_items_clean oi
    ON s.seller_id = oi.seller_id
GROUP BY
    s.seller_state
HAVING COUNT(DISTINCT s.seller_id) >= 5
ORDER BY
    value_per_seller DESC;
    
    /*
===============================================================================
Section 7.7.1 : Payment Method Distribution
Purpose : Examine payment method usage and recorded payment value.
===============================================================================
*/

SELECT
    payment_type,
    COUNT(*) AS payment_records,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM order_payments_clean
GROUP BY
    payment_type
ORDER BY
    total_payment_value DESC;
    
    /*
===============================================================================
Section 7.7.2 : Payment Method by Order
Purpose : Compare payment methods by the number of orders using them.
===============================================================================
*/

SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(
        COUNT(DISTINCT order_id) * 100.0 /
        (SELECT COUNT(*) FROM orders_clean),
        2
    ) AS percentage_of_orders,
    ROUND(SUM(payment_value), 2) AS total_payment_value
FROM order_payments_clean
GROUP BY
    payment_type
ORDER BY
    orders DESC;
    
    /*
===============================================================================
Section 7.7.3 : Credit Card Installments
Purpose : Examine installment behavior for credit card payments.
===============================================================================
*/

SELECT
    payment_installments,
    COUNT(*) AS payment_records,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM order_payments_clean
WHERE payment_type = 'credit_card'
GROUP BY
    payment_installments
ORDER BY
    payment_installments;
    
    /*
===============================================================================
Section 7.7.4 : Payment Value by Installment Range
Purpose : Compare credit card payment behavior across installment ranges.
===============================================================================
*/

SELECT
    CASE
        WHEN payment_installments = 1 THEN '1'
        WHEN payment_installments BETWEEN 2 AND 3 THEN '2-3'
        WHEN payment_installments BETWEEN 4 AND 6 THEN '4-6'
        WHEN payment_installments BETWEEN 7 AND 9 THEN '7-9'
        WHEN payment_installments BETWEEN 10 AND 12 THEN '10-12'
        ELSE '13+'
    END AS installment_range,
    COUNT(*) AS payment_records,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM order_payments_clean
WHERE payment_type = 'credit_card'
GROUP BY
    installment_range
ORDER BY
    CASE installment_range
        WHEN '1' THEN 1
        WHEN '2-3' THEN 2
        WHEN '4-6' THEN 3
        WHEN '7-9' THEN 4
        WHEN '10-12' THEN 5
        WHEN '13+' THEN 6
    END;
    
    /*
===============================================================================
Section 7.8.1 : Review Score Distribution
Purpose : Examine the distribution of customer review scores.
===============================================================================
*/

SELECT
    review_score,
    COUNT(*) AS review_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_reviews
FROM order_reviews_clean
GROUP BY
    review_score
ORDER BY
    review_score DESC;
    
    /*
===============================================================================
Section 7.8.2 : Review Score by Delivery Performance
Purpose : Compare review scores for on-time and late deliveries.
===============================================================================
*/

SELECT
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
            THEN 'on_time'
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'late'
    END AS delivery_performance,
    COUNT(*) AS reviews,
    ROUND(AVG(r.review_score), 2) AS average_review_score,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_reviews
FROM order_reviews_clean r
JOIN orders_clean o
    ON r.order_id = o.order_id
WHERE
    o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY
    delivery_performance
ORDER BY
    delivery_performance;
    
    /*
===============================================================================
Section 7.8.3 : Review Score by Order Status
Purpose : Compare average review scores across order statuses.
===============================================================================
*/

SELECT
    o.order_status,
    COUNT(*) AS reviews,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM order_reviews_clean r
JOIN orders_clean o
    ON r.order_id = o.order_id
GROUP BY
    o.order_status
ORDER BY
    average_review_score DESC;
    
    /*
===============================================================================
Section 7.8.4 : Review Score by Payment Method
Purpose : Compare average review scores across payment methods.
===============================================================================
*/

SELECT
    p.payment_type,
    COUNT(DISTINCT r.review_id) AS reviews,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM order_reviews_clean r
JOIN order_payments_clean p
    ON r.order_id = p.order_id
GROUP BY
    p.payment_type
ORDER BY
    average_review_score DESC;
    
    /*
===============================================================================
Section 7.8.5 : Review Score vs. Delivery Delay
Purpose : Examine review scores across delivery-delay ranges.
===============================================================================
*/

SELECT
    CASE
        WHEN TIMESTAMPDIFF(DAY, o.order_estimated_delivery_date,
             o.order_delivered_customer_date) <= 0 THEN 'on_time'
        WHEN TIMESTAMPDIFF(DAY, o.order_estimated_delivery_date,
             o.order_delivered_customer_date) BETWEEN 1 AND 3 THEN '1-3_days_late'
        WHEN TIMESTAMPDIFF(DAY, o.order_estimated_delivery_date,
             o.order_delivered_customer_date) BETWEEN 4 AND 7 THEN '4-7_days_late'
        WHEN TIMESTAMPDIFF(DAY, o.order_estimated_delivery_date,
             o.order_delivered_customer_date) BETWEEN 8 AND 14 THEN '8-14_days_late'
        ELSE '15+_days_late'
    END AS delay_range,
    COUNT(*) AS reviews,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM order_reviews_clean r
JOIN orders_clean o
    ON r.order_id = o.order_id
WHERE
    o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY
    delay_range
ORDER BY
    CASE delay_range
        WHEN 'on_time' THEN 1
        WHEN '1-3_days_late' THEN 2
        WHEN '4-7_days_late' THEN 3
        WHEN '8-14_days_late' THEN 4
        WHEN '15+_days_late' THEN 5
    END;
    
    /*
===============================================================================
Section 7.8.6 : Review Comments by Score
Purpose : Compare comment availability across review scores.
===============================================================================
*/

SELECT
    review_score,
    COUNT(*) AS reviews,
    SUM(
        CASE
            WHEN review_comment_message IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS reviews_with_comments,
    ROUND(
        SUM(
            CASE
                WHEN review_comment_message IS NOT NULL THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS comment_rate
FROM order_reviews_clean
GROUP BY
    review_score
ORDER BY
    review_score DESC;
    
    /*
===============================================================================
Section 7.8.7 : Review Score by Order Value
Purpose : Compare customer review scores across order-value ranges.
===============================================================================
*/

SELECT
    CASE
        WHEN order_value < 50 THEN 'under_50'
        WHEN order_value < 100 THEN '50_99'
        WHEN order_value < 200 THEN '100_199'
        WHEN order_value < 500 THEN '200_499'
        ELSE '500_plus'
    END AS order_value_range,
    COUNT(*) AS orders,
    ROUND(AVG(review_score), 2) AS average_review_score
FROM (
    SELECT
        o.order_id,
        SUM(p.payment_value) AS order_value,
        AVG(r.review_score) AS review_score
    FROM orders_clean o
    JOIN order_payments_clean p
        ON o.order_id = p.order_id
    JOIN order_reviews_clean r
        ON o.order_id = r.order_id
    GROUP BY
        o.order_id
) order_reviews
GROUP BY
    order_value_range
ORDER BY
    CASE order_value_range
        WHEN 'under_50' THEN 1
        WHEN '50_99' THEN 2
        WHEN '100_199' THEN 3
        WHEN '200_499' THEN 4
        WHEN '500_plus' THEN 5
    END;
    
    /*
===============================================================================
Section 7.9.1 : Orders by Customer State
Purpose : Examine order volume across customer states.
===============================================================================
*/

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id) * 100.0 /
        SUM(COUNT(DISTINCT o.order_id)) OVER (),
        2
    ) AS percentage_of_orders
FROM customers_clean c
JOIN orders_clean o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_state
ORDER BY
    orders DESC;
    
    /*
===============================================================================
Section 7.9.1 : Seller-to-Customer Geographic Flow
Purpose : Examine order volume between seller and customer states.
===============================================================================
*/

SELECT
    s.seller_state,
    c.customer_state,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS item_value
FROM order_items_clean oi
JOIN sellers_clean s
    ON oi.seller_id = s.seller_id
JOIN orders_clean o
    ON oi.order_id = o.order_id
JOIN customers_clean c
    ON o.customer_id = c.customer_id
GROUP BY
    s.seller_state,
    c.customer_state
ORDER BY
    orders DESC
LIMIT 20;

/*
===============================================================================
Section 7.9.2 : In-State vs Interstate Orders
Purpose : Compare orders fulfilled within the same state versus across states.
===============================================================================
*/

SELECT
    CASE
        WHEN s.seller_state = c.customer_state THEN 'in_state'
        ELSE 'interstate'
    END AS order_type,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT oi.order_id) * 100.0 /
        SUM(COUNT(DISTINCT oi.order_id)) OVER (),
        2
    ) AS percentage_of_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS item_value
FROM order_items_clean oi
JOIN sellers_clean s
    ON oi.seller_id = s.seller_id
JOIN orders_clean o
    ON oi.order_id = o.order_id
JOIN customers_clean c
    ON o.customer_id = c.customer_id
GROUP BY
    order_type
ORDER BY
    orders DESC;
    
    /*
===============================================================================
Section 7.9.3 : Interstate vs In-State Order Value
Purpose : Compare average item value for local and interstate orders.
===============================================================================
*/

SELECT
    CASE
        WHEN s.seller_state = c.customer_state THEN 'in_state'
        ELSE 'interstate'
    END AS order_type,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS item_value,
    ROUND(
        SUM(oi.price + oi.freight_value) /
        COUNT(DISTINCT oi.order_id),
        2
    ) AS average_order_value
FROM order_items_clean oi
JOIN sellers_clean s
    ON oi.seller_id = s.seller_id
JOIN orders_clean o
    ON oi.order_id = o.order_id
JOIN customers_clean c
    ON o.customer_id = c.customer_id
GROUP BY
    order_type
ORDER BY
    order_type;
    
    
    /*
===============================================================================
Section 7.10.1 : Delivery Performance vs Order Value
Purpose : Compare order value between on-time and late deliveries.
===============================================================================
*/

SELECT
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
            THEN 'on_time'
        ELSE 'late'
    END AS delivery_performance,
    COUNT(*) AS orders,
    ROUND(SUM(o.order_value), 2) AS total_order_value,
    ROUND(AVG(o.order_value), 2) AS average_order_value
FROM (
    SELECT
        o.order_id,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        SUM(p.payment_value) AS order_value
    FROM orders_clean o
    JOIN order_payments_clean p
        ON o.order_id = p.order_id
    WHERE
        o.order_status = 'delivered'
        AND o.order_delivered_customer_date IS NOT NULL
        AND o.order_estimated_delivery_date IS NOT NULL
    GROUP BY
        o.order_id,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date
) o
GROUP BY
    delivery_performance
ORDER BY
    delivery_performance;
    
    /*
===============================================================================
Section 7.10.2 : Product Category vs Customer Satisfaction
Purpose : Compare review scores across major product categories.
===============================================================================
*/

SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name
    ) AS category,
    COUNT(DISTINCT r.review_id) AS reviews,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM order_reviews_clean r
JOIN orders_clean o
    ON r.order_id = o.order_id
JOIN order_items_clean oi
    ON o.order_id = oi.order_id
JOIN products_clean p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation_clean t
    ON p.product_category_name = t.product_category_name
GROUP BY
    COALESCE(
        t.product_category_name_english,
        p.product_category_name
    )
HAVING COUNT(DISTINCT r.review_id) >= 500
ORDER BY
    average_review_score DESC;
    
    /*
===============================================================================
Section 7.10.3 : Category Satisfaction vs Delivery Performance
Purpose : Compare category review scores with late-delivery rates.
===============================================================================
*/

SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name
    ) AS category,
    COUNT(DISTINCT r.review_id) AS reviews,
    ROUND(AVG(r.review_score), 2) AS average_review_score,
    COUNT(
        DISTINCT CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN o.order_id
        END
    ) AS late_orders,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN o.order_delivered_customer_date >
                     o.order_estimated_delivery_date
                THEN o.order_id
            END
        ) * 100.0 /
        COUNT(DISTINCT o.order_id),
        2
    ) AS late_rate
FROM order_reviews_clean r
JOIN orders_clean o
    ON r.order_id = o.order_id
JOIN order_items_clean oi
    ON o.order_id = oi.order_id
JOIN products_clean p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation_clean t
    ON p.product_category_name = t.product_category_name
WHERE
    o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY
    COALESCE(
        t.product_category_name_english,
        p.product_category_name
    )
HAVING COUNT(DISTINCT r.review_id) >= 500
ORDER BY
    average_review_score;
    
    /*
===============================================================================
Section 7.10.4 : Seller Volume vs Customer Satisfaction
Purpose : Compare review scores across seller order-volume groups.
===============================================================================
*/

SELECT
    CASE
        WHEN seller_orders < 50 THEN 'under_50'
        WHEN seller_orders < 200 THEN '50_199'
        WHEN seller_orders < 500 THEN '200_499'
        WHEN seller_orders < 1000 THEN '500_999'
        ELSE '1000_plus'
    END AS seller_volume_range,
    COUNT(DISTINCT seller_id) AS sellers,
    ROUND(AVG(average_review_score), 2) AS average_review_score
FROM (
    SELECT
        oi.seller_id,
        COUNT(DISTINCT oi.order_id) AS seller_orders,
        AVG(r.review_score) AS average_review_score
    FROM order_items_clean oi
    JOIN orders_clean o
        ON oi.order_id = o.order_id
    JOIN order_reviews_clean r
        ON o.order_id = r.order_id
    GROUP BY
        oi.seller_id
) seller_performance
GROUP BY
    seller_volume_range
ORDER BY
    CASE seller_volume_range
        WHEN 'under_50' THEN 1
        WHEN '50_199' THEN 2
        WHEN '200_499' THEN 3
        WHEN '500_999' THEN 4
        WHEN '1000_plus' THEN 5
    END;
/*
===============================================================================
Section 8.1 : Seller Ranking Within State
Purpose : Rank sellers by total item value within each seller state.
===============================================================================
*/

WITH seller_totals AS (
    SELECT
        oi.seller_id,
        s.seller_state,
        SUM(oi.price + oi.freight_value) AS total_value
    FROM order_items_clean oi
    JOIN sellers_clean s
        ON oi.seller_id = s.seller_id
    GROUP BY
        oi.seller_id,
        s.seller_state
)

SELECT
    seller_id,
    seller_state,
    total_value,
    RANK() OVER (
        PARTITION BY seller_state
        ORDER BY total_value DESC
    ) AS state_rank
FROM seller_totals
ORDER BY
    seller_state,
    state_rank;
    
    SELECT *
FROM (
    WITH seller_totals AS (
        SELECT
            oi.seller_id,
            s.seller_state,
            SUM(oi.price + oi.freight_value) AS total_value
        FROM order_items_clean oi
        JOIN sellers_clean s
            ON oi.seller_id = s.seller_id
        GROUP BY
            oi.seller_id,
            s.seller_state
    )

    SELECT
        seller_id,
        seller_state,
        total_value,
        RANK() OVER (
            PARTITION BY seller_state
            ORDER BY total_value DESC
        ) AS state_rank
    FROM seller_totals
) ranked_sellers
WHERE seller_state = 'SP'
ORDER BY state_rank
LIMIT 10;

WITH seller_totals AS (
    SELECT
        oi.seller_id,
        s.seller_state,
        SUM(oi.price + oi.freight_value) AS total_value
    FROM order_items_clean oi
    JOIN sellers_clean s
        ON oi.seller_id = s.seller_id
    GROUP BY
        oi.seller_id,
        s.seller_state
),

ranked_sellers AS (
    SELECT
        seller_id,
        seller_state,
        total_value,
        RANK() OVER (
            PARTITION BY seller_state
            ORDER BY total_value DESC
        ) AS state_rank
    FROM seller_totals
)

SELECT
    seller_id,
    seller_state,
    total_value,
    state_rank
FROM ranked_sellers
WHERE state_rank <= 3
ORDER BY
    state_rank,
    seller_state;
    
    /*
===============================================================================
Section 8.2 : Running Totals & Contribution to Total
Purpose : Calculate monthly payment value and cumulative contribution over time.
===============================================================================
*/

WITH monthly_payments AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        SUM(op.payment_value) AS monthly_value
    FROM orders_clean o
    JOIN order_payments_clean op
        ON o.order_id = op.order_id
    GROUP BY
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
)

SELECT
    order_month,
    monthly_value,
    SUM(monthly_value) OVER (
        ORDER BY order_month
    ) AS cumulative_value,
    ROUND(
        monthly_value /
        SUM(monthly_value) OVER () * 100,
        2
    ) AS pct_of_total
FROM monthly_payments
ORDER BY order_month;

/*
===============================================================================
Section 8.3 : Customer Purchase Sequence
Purpose : Sequence customer orders and compare each order with the previous one.
===============================================================================
*/

WITH customer_orders AS (
    SELECT
        o.order_id,
        c.customer_unique_id,
        o.order_purchase_timestamp,

        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS order_number,

        LAG(o.order_purchase_timestamp) OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS previous_order_timestamp

    FROM orders_clean o
    JOIN customers_clean c
        ON o.customer_id = c.customer_id
)

SELECT
    order_id,
    customer_unique_id,
    order_purchase_timestamp,
    order_number,
    previous_order_timestamp
FROM customer_orders
ORDER BY
    customer_unique_id,
    order_number;
    
WITH customer_orders AS (
    SELECT
        o.order_id,
        c.customer_unique_id,
        o.order_purchase_timestamp,

        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS order_number,

        LAG(o.order_purchase_timestamp) OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS previous_order_timestamp

    FROM orders_clean o
    JOIN customers_clean c
        ON o.customer_id = c.customer_id
)

SELECT
    order_id,
    customer_unique_id,
    order_purchase_timestamp,
    order_number,
    previous_order_timestamp,
    TIMESTAMPDIFF(
        DAY,
        previous_order_timestamp,
        order_purchase_timestamp
    ) AS days_since_previous_order
FROM customer_orders
ORDER BY
    customer_unique_id,
    order_number;
    
    /*
===============================================================================
Section 8.4 : Repeat Customer Retention
Purpose : Measure and classify the time between repeat customer purchases.
===============================================================================
*/

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,

        LAG(o.order_purchase_timestamp) OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS previous_order_timestamp

    FROM orders_clean o
    JOIN customers_clean c
        ON o.customer_id = c.customer_id
),

repeat_purchases AS (
    SELECT
        customer_unique_id,
        order_id,
        order_purchase_timestamp,
        previous_order_timestamp,

        TIMESTAMPDIFF(
            DAY,
            previous_order_timestamp,
            order_purchase_timestamp
        ) AS days_to_return

    FROM customer_orders
    WHERE previous_order_timestamp IS NOT NULL
),

retention_segments AS (
    SELECT
        customer_unique_id,
        order_id,
        days_to_return,

        CASE
            WHEN days_to_return <= 30 THEN '0-30 days'
            WHEN days_to_return <= 90 THEN '31-90 days'
            WHEN days_to_return <= 180 THEN '91-180 days'
            ELSE '181+ days'
        END AS retention_segment

    FROM repeat_purchases
)

SELECT
    retention_segment,
    COUNT(*) AS repeat_purchases,
    COUNT(DISTINCT customer_unique_id) AS repeat_customers,
    ROUND(
        COUNT(*) / SUM(COUNT(*)) OVER () * 100,
        2
    ) AS pct_of_repeat_purchases
FROM retention_segments
GROUP BY retention_segment
ORDER BY
    CASE retention_segment
        WHEN '0-30 days' THEN 1
        WHEN '31-90 days' THEN 2
        WHEN '91-180 days' THEN 3
        WHEN '181+ days' THEN 4
    END;
    
    /*
===============================================================================
Section 8.5 : Customer Segmentation
Purpose : Segment customers using recency, frequency, and monetary value.
===============================================================================
*/

WITH customer_metrics AS (
    SELECT
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS order_frequency,
        SUM(op.payment_value) AS monetary_value
    FROM customers_clean c
    JOIN orders_clean o
        ON c.customer_id = o.customer_id
    JOIN order_payments_clean op
        ON o.order_id = op.order_id
    GROUP BY
        c.customer_unique_id
),

rfm_scores AS (
    SELECT
        customer_unique_id,
        DATEDIFF(
            (SELECT MAX(order_purchase_timestamp)
             FROM orders_clean),
            last_order_date
        ) AS recency_days,
        order_frequency,
        monetary_value,

        NTILE(5) OVER (
            ORDER BY DATEDIFF(
                (SELECT MAX(order_purchase_timestamp)
                 FROM orders_clean),
                 last_order_date
            ) DESC
        ) AS recency_score,

        NTILE(5) OVER (
            ORDER BY order_frequency
        ) AS frequency_score,

        NTILE(5) OVER (
            ORDER BY monetary_value
        ) AS monetary_score

    FROM customer_metrics
),

customer_segments AS (
    SELECT
        customer_unique_id,
        recency_days,
        order_frequency,
        monetary_value,
        recency_score,
        frequency_score,
        monetary_score,

        CASE
            WHEN recency_score >= 4
                 AND frequency_score >= 4
                 AND monetary_score >= 4
                THEN 'High Value'

            WHEN frequency_score >= 4
                 OR monetary_score >= 4
                THEN 'Potential High Value'

            WHEN recency_score <= 2
                 AND frequency_score <= 2
                 AND monetary_score <= 2
                THEN 'Low Value'

            ELSE 'Mid Value'
        END AS customer_segment

    FROM rfm_scores
)

SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(
        COUNT(*) / SUM(COUNT(*)) OVER () * 100,
        2
    ) AS pct_of_customers,
    ROUND(AVG(order_frequency), 2) AS avg_orders,
    ROUND(AVG(monetary_value), 2) AS avg_value
FROM customer_segments
GROUP BY
    customer_segment
ORDER BY
    CASE customer_segment
        WHEN 'High Value' THEN 1
        WHEN 'Potential High Value' THEN 2
        WHEN 'Mid Value' THEN 3
        WHEN 'Low Value' THEN 4
    END;
    
    /*
===============================================================================
Section 8.6 : Category Contribution Analysis
Purpose : Calculate category contribution and cumulative share of item value.
===============================================================================
*/

WITH category_values AS (
    SELECT
        COALESCE(
            pct.product_category_name_english,
            'Unknown'
        ) AS category,
        SUM(oi.price + oi.freight_value) AS category_value
    FROM order_items_clean oi
    JOIN products_clean p
        ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation_clean pct
        ON p.product_category_name = pct.product_category_name
    GROUP BY
        COALESCE(
            pct.product_category_name_english,
            'Unknown'
        )
),

category_contribution AS (
    SELECT
        category,
        category_value,

        ROUND(
            category_value /
            SUM(category_value) OVER () * 100,
            2
        ) AS pct_of_total,

        SUM(category_value) OVER (
            ORDER BY category_value DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_value

    FROM category_values
)

SELECT
    category,
    category_value,
    pct_of_total,
    ROUND(
        cumulative_value /
        SUM(category_value) OVER () * 100,
        2
    ) AS cumulative_pct
FROM category_contribution
ORDER BY
    category_value DESC;
    
    /*
===============================================================================
Section 8.7 : Seller Performance Analysis
Purpose : Rank and segment sellers using value, order volume, and state position.
===============================================================================
*/

WITH seller_metrics AS (
    SELECT
        s.seller_id,
        s.seller_state,
        COUNT(DISTINCT oi.order_id) AS order_count,
        COUNT(*) AS item_count,
        SUM(oi.price + oi.freight_value) AS total_value,
        AVG(oi.price + oi.freight_value) AS avg_item_value
    FROM sellers_clean s
    JOIN order_items_clean oi
        ON s.seller_id = oi.seller_id
    GROUP BY
        s.seller_id,
        s.seller_state
),

seller_rankings AS (
    SELECT
        seller_id,
        seller_state,
        order_count,
        item_count,
        total_value,
        avg_item_value,

        RANK() OVER (
            PARTITION BY seller_state
            ORDER BY total_value DESC
        ) AS state_rank,

        NTILE(5) OVER (
            ORDER BY total_value
        ) AS value_quintile

    FROM seller_metrics
),

seller_segments AS (
    SELECT
        seller_id,
        seller_state,
        order_count,
        item_count,
        total_value,
        avg_item_value,
        state_rank,
        value_quintile,

        CASE
            WHEN value_quintile = 5 THEN 'Top Value'
            WHEN value_quintile = 4 THEN 'High Value'
            WHEN value_quintile = 3 THEN 'Mid Value'
            WHEN value_quintile = 2 THEN 'Low Value'
            ELSE 'Bottom Value'
        END AS seller_segment

    FROM seller_rankings
)

SELECT
    seller_id,
    seller_state,
    order_count,
    item_count,
    ROUND(total_value, 2) AS total_value,
    ROUND(avg_item_value, 2) AS avg_item_value,
    state_rank,
    seller_segment
FROM seller_segments
ORDER BY
    seller_state,
    state_rank;
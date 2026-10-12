/*
===============================================================================
Section 9.1 : Marketplace Growth Drivers
Purpose : Compare order volume and payment value across marketplace periods.
===============================================================================
*/

WITH monthly_metrics AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(op.payment_value) AS payment_value
    FROM orders_clean o
    JOIN order_payments_clean op
        ON o.order_id = op.order_id
    GROUP BY
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
),

period_metrics AS (
    SELECT
        CASE
            WHEN order_month BETWEEN '2017-01' AND '2017-03'
                THEN 'Early 2017'
            WHEN order_month BETWEEN '2018-01' AND '2018-03'
                THEN 'Early 2018'
        END AS period,
        AVG(order_count) AS avg_monthly_orders,
        AVG(payment_value) AS avg_monthly_value,
        AVG(payment_value / order_count) AS avg_order_value
    FROM monthly_metrics
    WHERE order_month BETWEEN '2017-01' AND '2017-03'
       OR order_month BETWEEN '2018-01' AND '2018-03'
    GROUP BY
        CASE
            WHEN order_month BETWEEN '2017-01' AND '2017-03'
                THEN 'Early 2017'
            WHEN order_month BETWEEN '2018-01' AND '2018-03'
                THEN 'Early 2018'
        END
)

SELECT
    period,
    ROUND(avg_monthly_orders, 2) AS avg_monthly_orders,
    ROUND(avg_monthly_value, 2) AS avg_monthly_payment_value,
    ROUND(avg_order_value, 2) AS avg_order_value
FROM period_metrics
ORDER BY period;

/*
===============================================================================
Section 9.2 : Category Value Concentration
Purpose : Measure how much item value is concentrated among leading categories.
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

ranked_categories AS (
    SELECT
        category,
        category_value,
        RANK() OVER (
            ORDER BY category_value DESC
        ) AS category_rank
    FROM category_values
),

concentration AS (
    SELECT
        CASE
            WHEN category_rank <= 5 THEN 'Top 5'
            WHEN category_rank <= 10 THEN 'Top 10'
            WHEN category_rank <= 20 THEN 'Top 20'
            ELSE 'Remaining Categories'
        END AS category_group,
        SUM(category_value) AS group_value
    FROM ranked_categories
    GROUP BY
        CASE
            WHEN category_rank <= 5 THEN 'Top 5'
            WHEN category_rank <= 10 THEN 'Top 10'
            WHEN category_rank <= 20 THEN 'Top 20'
            ELSE 'Remaining Categories'
        END
)

SELECT
    category_group,
    ROUND(group_value, 2) AS item_value,
    ROUND(
        group_value / SUM(group_value) OVER () * 100,
        2
    ) AS pct_of_total
FROM concentration
ORDER BY
    CASE category_group
        WHEN 'Top 5' THEN 1
        WHEN 'Top 10' THEN 2
        WHEN 'Top 20' THEN 3
        ELSE 4
    END;
    
    /*
===============================================================================
Section 9.3 : Customer Acquisition vs Retention
Purpose : Compare one-time and repeat customers by customers, orders, and value.
===============================================================================
*/

WITH customer_metrics AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(op.payment_value) AS customer_value
    FROM customers_clean c
    JOIN orders_clean o
        ON c.customer_id = o.customer_id
    JOIN order_payments_clean op
        ON o.order_id = op.order_id
    GROUP BY
        c.customer_unique_id
),

customer_groups AS (
    SELECT
        CASE
            WHEN order_count = 1 THEN 'One-time Customer'
            ELSE 'Repeat Customer'
        END AS customer_group,
        COUNT(*) AS customers,
        SUM(order_count) AS orders,
        SUM(customer_value) AS payment_value
    FROM customer_metrics
    GROUP BY
        CASE
            WHEN order_count = 1 THEN 'One-time Customer'
            ELSE 'Repeat Customer'
        END
)

SELECT
    customer_group,
    customers,
    ROUND(
        customers / SUM(customers) OVER () * 100,
        2
    ) AS pct_of_customers,
    orders,
    ROUND(
        orders / SUM(orders) OVER () * 100,
        2
    ) AS pct_of_orders,
    ROUND(payment_value, 2) AS payment_value,
    ROUND(
        payment_value / SUM(payment_value) OVER () * 100,
        2
    ) AS pct_of_payment_value
FROM customer_groups
ORDER BY
    CASE customer_group
        WHEN 'One-time Customer' THEN 1
        WHEN 'Repeat Customer' THEN 2
    END;
    
    /*
===============================================================================
Section 9.4 : Repeat Customer Value
Purpose : Compare the commercial value of one-time and repeat customers.
===============================================================================
*/

WITH customer_metrics AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(op.payment_value) AS customer_value
    FROM customers_clean c
    JOIN orders_clean o
        ON c.customer_id = o.customer_id
    JOIN order_payments_clean op
        ON o.order_id = op.order_id
    GROUP BY
        c.customer_unique_id
)

SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END AS customer_group,

    COUNT(*) AS customers,

    ROUND(
        AVG(order_count),
        2
    ) AS avg_orders_per_customer,

    ROUND(
        AVG(customer_value),
        2
    ) AS avg_customer_value,

    ROUND(
        SUM(customer_value),
        2
    ) AS total_customer_value

FROM customer_metrics
GROUP BY
    CASE
        WHEN order_count = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END

ORDER BY
    CASE
        WHEN order_count = 1 THEN 1
        ELSE 2
    END;
    
    /*
===============================================================================
Section 9.5 : Delivery Performance vs Customer Satisfaction
Purpose : Compare customer satisfaction between on-time and late deliveries.
===============================================================================
*/

WITH delivery_reviews AS (
    SELECT
        o.order_id,
        CASE
            WHEN o.order_delivered_customer_date
                 <= o.order_estimated_delivery_date
                THEN 'On Time'
            WHEN o.order_delivered_customer_date
                 > o.order_estimated_delivery_date
                THEN 'Late'
        END AS delivery_status,
        r.review_score
    FROM orders_clean o
    JOIN order_reviews_clean r
        ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)

SELECT
    delivery_status,
    COUNT(*) AS reviewed_orders,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(
        SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS pct_negative_reviews
FROM delivery_reviews
WHERE delivery_status IS NOT NULL
GROUP BY
    delivery_status
ORDER BY
    CASE delivery_status
        WHEN 'On Time' THEN 1
        WHEN 'Late' THEN 2
    END;
    
    /*
===============================================================================
Section 9.6 : Category Delivery & Satisfaction
Purpose : Identify categories with weaker satisfaction and higher late rates.
===============================================================================
*/

WITH category_performance AS (
    SELECT
        COALESCE(
            pct.product_category_name_english,
            'Unknown'
        ) AS category,

        COUNT(DISTINCT r.review_id) AS review_count,

        ROUND(
            AVG(r.review_score),
            2
        ) AS avg_review_score,

        COUNT(
            DISTINCT CASE
                WHEN o.order_delivered_customer_date
                     > o.order_estimated_delivery_date
                THEN o.order_id
            END
        ) AS late_orders,

        COUNT(
            DISTINCT CASE
                WHEN o.order_delivered_customer_date IS NOT NULL
                 AND o.order_estimated_delivery_date IS NOT NULL
                THEN o.order_id
            END
        ) AS delivered_orders

    FROM order_reviews_clean r

    JOIN orders_clean o
        ON r.order_id = o.order_id

    JOIN order_items_clean oi
        ON o.order_id = oi.order_id

    JOIN products_clean p
        ON oi.product_id = p.product_id

    LEFT JOIN product_category_name_translation_clean pct
        ON p.product_category_name = pct.product_category_name

    WHERE o.order_status = 'delivered'

    GROUP BY
        COALESCE(
            pct.product_category_name_english,
            'Unknown'
        )
)

SELECT
    category,
    review_count,
    avg_review_score,
    late_orders,
    delivered_orders,

    ROUND(
        late_orders / delivered_orders * 100,
        2
    ) AS late_rate

FROM category_performance

WHERE review_count >= 500

ORDER BY
    avg_review_score ASC,
    late_rate DESC;
    
    /*
===============================================================================
Section 9.7 : Seller Concentration & Scale
Purpose : Measure seller value concentration and compare seller scale with value.
===============================================================================
*/

WITH seller_metrics AS (
    SELECT
        oi.seller_id,
        COUNT(DISTINCT oi.order_id) AS order_count,
        SUM(oi.price + oi.freight_value) AS total_value
    FROM order_items_clean oi
    GROUP BY
        oi.seller_id
),

seller_ranked AS (
    SELECT
        seller_id,
        order_count,
        total_value,

        RANK() OVER (
            ORDER BY total_value DESC
        ) AS value_rank,

        NTILE(5) OVER (
            ORDER BY order_count
        ) AS volume_quintile

    FROM seller_metrics
),

concentration AS (
    SELECT
        CASE
            WHEN value_rank <= 10 THEN 'Top 10 Sellers'
            WHEN value_rank <= 50 THEN 'Top 50 Sellers'
            WHEN value_rank <= 100 THEN 'Top 100 Sellers'
            ELSE 'Remaining Sellers'
        END AS seller_group,
        SUM(total_value) AS group_value
    FROM seller_ranked
    GROUP BY
        CASE
            WHEN value_rank <= 10 THEN 'Top 10 Sellers'
            WHEN value_rank <= 50 THEN 'Top 50 Sellers'
            WHEN value_rank <= 100 THEN 'Top 100 Sellers'
            ELSE 'Remaining Sellers'
        END
),

volume_performance AS (
    SELECT
        volume_quintile,
        COUNT(*) AS sellers,
        AVG(order_count) AS avg_orders,
        AVG(total_value) AS avg_value
    FROM seller_ranked
    GROUP BY
        volume_quintile
)

SELECT
    'Concentration' AS analysis_type,
    seller_group AS category,
    NULL AS sellers,
    NULL AS avg_orders,
    ROUND(group_value, 2) AS value,
    ROUND(
        group_value /
        SUM(group_value) OVER () * 100,
        2
    ) AS pct_of_total
FROM concentration

UNION ALL

SELECT
    'Volume Scale' AS analysis_type,
    CONCAT('Volume Quintile ', volume_quintile) AS category,
    sellers,
    ROUND(avg_orders, 2),
    ROUND(avg_value, 2),
    NULL
FROM volume_performance

ORDER BY
    analysis_type,
    category;
    
    /*
===============================================================================
Section 9.8 : Interstate vs In-State Commercial Value
Purpose : Compare order value and volume between interstate and in-state trade.
===============================================================================
*/

WITH order_geography AS (
    SELECT
        o.order_id,
        s.seller_state,
        c.customer_state,
        CASE
            WHEN s.seller_state = c.customer_state
                THEN 'In-State'
            ELSE 'Interstate'
        END AS trade_type,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM orders_clean o
    JOIN customers_clean c
        ON o.customer_id = c.customer_id
    JOIN order_items_clean oi
        ON o.order_id = oi.order_id
    JOIN sellers_clean s
        ON oi.seller_id = s.seller_id
    GROUP BY
        o.order_id,
        s.seller_state,
        c.customer_state,
        CASE
            WHEN s.seller_state = c.customer_state
                THEN 'In-State'
            ELSE 'Interstate'
        END
)

SELECT
    trade_type,
    COUNT(*) AS orders,
    ROUND(
        COUNT(*) / SUM(COUNT(*)) OVER () * 100,
        2
    ) AS pct_of_orders,
    ROUND(
        SUM(order_value),
        2
    ) AS total_item_value,
    ROUND(
        SUM(order_value) / SUM(SUM(order_value)) OVER () * 100,
        2
    ) AS pct_of_value,
    ROUND(
        AVG(order_value),
        2
    ) AS avg_order_value
FROM order_geography
GROUP BY
    trade_type
ORDER BY
    CASE trade_type
        WHEN 'In-State' THEN 1
        WHEN 'Interstate' THEN 2
    END;
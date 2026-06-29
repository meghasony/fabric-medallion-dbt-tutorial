{{ config(materialized='table', tags=['gold', 'powerbi']) }}

WITH sales AS (
    SELECT
        o.*,
        p.standard_cost,
        CAST(o.quantity * o.unit_price AS DECIMAL(12,2)) AS gross_sales_amount,
        CAST(o.quantity * o.unit_price * o.discount_percent / 100.0 AS DECIMAL(12,2)) AS discount_amount,
        CAST(o.quantity * o.unit_price * (1 - o.discount_percent / 100.0) AS DECIMAL(12,2)) AS net_sales_amount,
        CAST(o.quantity * p.standard_cost AS DECIMAL(12,2)) AS product_cost_amount
    FROM {{ ref('silver_orders') }} o
    INNER JOIN {{ ref('silver_products') }} p
        ON o.product_id = p.product_id
    INNER JOIN {{ ref('silver_customers') }} c
        ON o.customer_id = c.customer_id
    WHERE o.order_status IN ('COMPLETED', 'RETURNED')
)

SELECT
    order_id,
    order_date AS date_key,
    customer_id,
    product_id,
    channel,
    payment_method,
    order_status,
    is_returned,
    return_reason,
    shipping_city,
    shipping_country,
    campaign_name,
    quantity,
    unit_price,
    discount_percent,
    gross_sales_amount,
    discount_amount,
    net_sales_amount,
    product_cost_amount,
    CAST(net_sales_amount - product_cost_amount AS DECIMAL(12,2)) AS gross_margin_amount,
    CASE WHEN order_status = 'RETURNED' OR is_returned = 1 THEN quantity ELSE 0 END AS returned_quantity,
    CASE WHEN order_status = 'RETURNED' OR is_returned = 1 THEN net_sales_amount ELSE CAST(0 AS DECIMAL(12,2)) END AS returned_sales_amount
FROM sales

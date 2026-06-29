{{ config(materialized='table', tags=['silver']) }}

WITH cleaned AS (
    SELECT
        TRY_CAST(order_id AS INT) AS order_id,
        TRY_CAST(order_date AS DATE) AS order_date,
        TRY_CAST(customer_id AS INT) AS customer_id,
        TRY_CAST(product_id AS INT) AS product_id,
        TRY_CAST(quantity AS INT) AS quantity,
        TRY_CAST(unit_price AS DECIMAL(10,2)) AS unit_price,
        TRY_CAST(discount_percent AS DECIMAL(5,2)) AS discount_percent,
        UPPER(LTRIM(RTRIM(channel))) AS channel,
        LTRIM(RTRIM(payment_method)) AS payment_method,
        UPPER(LTRIM(RTRIM(order_status))) AS order_status,
        UPPER(LTRIM(RTRIM(is_returned))) AS is_returned,
        NULLIF(LTRIM(RTRIM(return_reason)), '') AS return_reason,
        LTRIM(RTRIM(shipping_city)) AS shipping_city,
        COALESCE(NULLIF(UPPER(LTRIM(RTRIM(shipping_country))), ''), 'UNKNOWN') AS shipping_country,
        NULLIF(LTRIM(RTRIM(campaign_name)), '') AS campaign_name,
        TRY_CAST(source_updated_at AS DATETIME2) AS source_updated_at
    FROM {{ source('bronze', 'orders') }}
),

deduplicated AS (
    SELECT
        cleaned.*,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY source_updated_at DESC
        ) AS row_number
    FROM cleaned
    WHERE order_id IS NOT NULL
)

SELECT
    order_id,
    order_date,
    customer_id,
    product_id,
    quantity,
    unit_price,
    discount_percent,
    channel,
    payment_method,
    order_status,
    CASE WHEN is_returned IN ('Y', 'YES', 'TRUE', '1') THEN 1 ELSE 0 END AS is_returned,
    return_reason,
    shipping_city,
    shipping_country,
    campaign_name,
    source_updated_at
FROM deduplicated
WHERE row_number = 1
  AND order_date IS NOT NULL
  AND customer_id IS NOT NULL
  AND product_id IS NOT NULL
  AND quantity > 0
  AND unit_price >= 0
  AND discount_percent BETWEEN 0 AND 100

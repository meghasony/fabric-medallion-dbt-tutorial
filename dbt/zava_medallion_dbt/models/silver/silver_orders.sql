{{ config(materialized='table', tags=['silver']) }}

WITH ranked AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY order_date DESC
        ) AS rn
    FROM bronze_orders

)

SELECT *
FROM ranked
WHERE rn = 1
AND quantity IS NOT NULL

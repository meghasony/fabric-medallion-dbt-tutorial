{{ config(materialized='table', tags=['silver']) }}

WITH cleaned AS (
    SELECT
        TRY_CAST(product_id AS INT) AS product_id,
        LTRIM(RTRIM(product_name)) AS product_name,
        UPPER(LTRIM(RTRIM(category))) AS category,
        LTRIM(RTRIM(subcategory)) AS subcategory,
        LTRIM(RTRIM(brand)) AS brand,
        TRY_CAST(list_price AS DECIMAL(10,2)) AS list_price,
        TRY_CAST(standard_cost AS DECIMAL(10,2)) AS standard_cost,
        TRY_CAST(launch_date AS DATE) AS launch_date,
        UPPER(LTRIM(RTRIM(is_active))) AS is_active
    FROM {{ source('bronze', 'products') }}
)

SELECT
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    list_price,
    standard_cost,
    launch_date,
    CASE WHEN is_active IN ('Y', 'YES', 'TRUE', '1') THEN 1 ELSE 0 END AS is_active
FROM cleaned
WHERE product_id IS NOT NULL
  AND list_price > 0
  AND standard_cost >= 0

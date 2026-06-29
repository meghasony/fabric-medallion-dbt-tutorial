{{ config(materialized='table', tags=['gold', 'powerbi']) }}

SELECT
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    list_price,
    standard_cost,
    launch_date,
    is_active
FROM {{ ref('silver_products') }}

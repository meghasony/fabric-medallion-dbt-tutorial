{{ config(materialized='table', tags=['gold', 'powerbi']) }}

SELECT
    d.year_month,
    f.channel,
    p.category,
    COUNT(DISTINCT f.order_id) AS order_count,
    SUM(f.quantity) AS units_sold,
    SUM(f.net_sales_amount) AS net_sales_amount,
    SUM(f.gross_margin_amount) AS gross_margin_amount,
    SUM(f.returned_quantity) AS returned_quantity,
    SUM(f.returned_sales_amount) AS returned_sales_amount
FROM {{ ref('fact_sales') }} f
INNER JOIN {{ ref('dim_date') }} d
    ON f.date_key = d.date_key
INNER JOIN {{ ref('dim_product') }} p
    ON f.product_id = p.product_id
{{ dbt_utils.group_by(n=3) }}

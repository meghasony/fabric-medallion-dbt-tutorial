{{ config(materialized='table', tags=['gold']) }}

select
    d.year_month,
    f.channel,
    p.category,
    count(distinct f.order_id) as orders,
    sum(f.quantity) as units_sold,
    sum(f.net_sales_amount) as net_sales_amount,
    sum(f.gross_margin_amount) as gross_margin_amount,
    sum(f.returned_quantity) as returned_quantity

from {{ ref('fact_sales') }} f
join {{ ref('dim_date') }} d
    on f.date_key = d.date_key
join {{ ref('dim_product') }} p
    on f.product_id = p.product_id

group by
    d.year_month,
    f.channel,
    p.category

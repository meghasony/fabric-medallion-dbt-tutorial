{{ config(tags=['gold']) }}

select
    p.category,
    p.subcategory,
    p.brand,
    count(f.order_id) as total_orders,
    sum(f.recognized_units) as units_sold,
    sum(f.recognized_sales_amount) as total_sales
from {{ ref('fact_sales') }} f
left join {{ ref('dim_product') }} p
    on f.product_id = p.product_id
group by p.category, p.subcategory, p.brand

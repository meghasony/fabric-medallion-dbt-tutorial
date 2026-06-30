{{ config(tags=['gold']) }}

select
    c.country,
    c.customer_segment,
    c.loyalty_tier,
    count(f.order_id) as total_orders,
    sum(f.recognized_units) as units_sold,
    sum(f.recognized_sales_amount) as total_sales
from {{ ref('fact_sales') }} f
left join {{ ref('dim_customer') }} c
    on f.customer_id = c.customer_id
group by c.country, c.customer_segment, c.loyalty_tier

{{ config(materialized='table', tags=['gold']) }}

select
    o.order_id,
    o.order_date as date_key,
    o.customer_id,
    o.product_id,
    o.channel,
    o.order_status,
    o.quantity,
    o.unit_price,
    o.discount_percent,

    o.quantity * o.unit_price as gross_sales_amount,
    o.quantity * o.unit_price * (1 - o.discount_percent / 100.0) as net_sales_amount,
    o.quantity * p.standard_cost as product_cost_amount,
    (o.quantity * o.unit_price * (1 - o.discount_percent / 100.0)) - (o.quantity * p.standard_cost) as gross_margin_amount,

    case when o.order_status = 'RETURNED' then o.quantity else 0 end as returned_quantity

from {{ ref('silver_orders') }} o
join {{ ref('silver_products') }} p
    on o.product_id = p.product_id
join {{ ref('silver_customers') }} c
    on o.customer_id = c.customer_id

where o.order_status in ('COMPLETED', 'RETURNED')

{{ config(tags=['gold']) }}

select
    datefromparts(year(order_date), month(order_date), 1) as month_start_date,
    count(order_id) as total_orders,
    sum(recognized_units) as units_sold,
    sum(gross_sales_amount) as gross_sales_amount,
    sum(discount_amount) as discount_amount,
    sum(recognized_sales_amount) as total_sales
from {{ ref('fact_sales') }}
where order_date is not null
group by datefromparts(year(order_date), month(order_date), 1)

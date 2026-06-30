{{ config(tags=['gold']) }}

with deduped_orders as (
    select *,
        row_number() over (
            partition by order_id
            order by source_updated_at desc, order_date desc
        ) as row_num
    from {{ ref('stg_orders') }}
)

select
    order_key as sales_key,
    order_id,
    order_date,
    cast(convert(char(8), order_date, 112) as int) as order_date_key,
    customer_id,
    product_id,
    quantity,
    unit_price,
    coalesce(discount_percent, 0) as discount_percent,
    cast(quantity * unit_price as decimal(18, 2)) as gross_sales_amount,
    cast(quantity * unit_price * coalesce(discount_percent, 0) / 100 as decimal(18, 2)) as discount_amount,
    cast(quantity * unit_price * (1 - coalesce(discount_percent, 0) / 100) as decimal(18, 2)) as net_sales_amount,
    case when order_status = 'Completed' and is_returned = 'No'
         then cast(quantity * unit_price * (1 - coalesce(discount_percent, 0) / 100) as decimal(18, 2))
         else cast(0 as decimal(18, 2)) end as recognized_sales_amount,
    case when order_status = 'Completed' and is_returned = 'No' then quantity else 0 end as recognized_units,
    channel,
    payment_method,
    order_status,
    is_returned,
    return_reason,
    shipping_country,
    campaign_name
from deduped_orders
where row_num = 1

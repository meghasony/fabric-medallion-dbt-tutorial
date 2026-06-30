{{ config(materialized='table', tags=['silver']) }}

select
    order_id,
    order_date,
    customer_id,
    product_id,
    quantity,
    unit_price,
    discount_percent,
    discount_rate,
    channel,
    payment_method,
    order_status,
    is_returned,
    return_reason,
    shipping_city,
    shipping_country,
    campaign_name,
    source_updated_at

from (

    select
        cleaned.*,
        row_number() over (
            partition by order_id
            order by source_updated_at desc
        ) as row_number

    from (

        select
            try_cast(order_id as int) as order_id,
            try_cast(order_date as date) as order_date,
            try_cast(customer_id as int) as customer_id,
            try_cast(product_id as int) as product_id,
            try_cast(quantity as int) as quantity,
            try_cast(unit_price as decimal(10, 2)) as unit_price,
            try_cast(discount_percent as decimal(5, 2)) as discount_percent,
            {{ dbt_utils.safe_divide('try_cast(discount_percent as decimal(5, 2))', '100.0') }} as discount_rate,
            upper(trim(channel)) as channel,
            trim(payment_method) as payment_method,
            upper(trim(order_status)) as order_status,
            case when upper(trim(is_returned)) in ('Y', 'YES', 'TRUE', '1') then 1 else 0 end as is_returned,
            nullif(trim(return_reason), '') as return_reason,
            trim(shipping_city) as shipping_city,
            coalesce(upper(nullif(trim(shipping_country), '')), 'UNKNOWN') as shipping_country,
            nullif(trim(campaign_name), '') as campaign_name,
            try_cast(source_updated_at as datetime2(6)) as source_updated_at

        from {{ source('bronze', 'orders') }}

    ) as cleaned

    where order_id is not null
      and order_date is not null
      and customer_id is not null
      and product_id is not null
      and quantity > 0
      and unit_price >= 0
      and discount_percent between 0 and 100

) as deduplicated

where row_number = 1

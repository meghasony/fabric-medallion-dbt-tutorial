{{ config(materialized='table', tags=['silver']) }}

with cleaned as (

    select
        try_cast(order_id as int) as order_id,
        try_cast(order_date as date) as order_date,
        try_cast(customer_id as int) as customer_id,
        try_cast(product_id as int) as product_id,
        try_cast(quantity as int) as quantity,
        try_cast(unit_price as decimal(10, 2)) as unit_price,
        try_cast(discount_percent as decimal(5, 2)) as discount_percent,
        upper(trim(channel)) as channel,
        trim(payment_method) as payment_method,
        upper(trim(order_status)) as order_status,
        case when upper(trim(is_returned)) in ('Y', 'YES', 'TRUE', '1') then 1 else 0 end as is_returned,
        nullif(trim(return_reason), '') as return_reason,
        trim(shipping_city) as shipping_city,
        coalesce(upper(nullif(trim(shipping_country), '')), 'UNKNOWN') as shipping_country,
        nullif(trim(campaign_name), '') as campaign_name,
        try_cast(source_updated_at as datetime2) as source_updated_at

    from {{ source('bronze', 'orders') }}

    where try_cast(order_id as int) is not null
      and try_cast(order_date as date) is not null
      and try_cast(customer_id as int) is not null
      and try_cast(product_id as int) is not null
      and try_cast(quantity as int) > 0
      and try_cast(unit_price as decimal(10, 2)) >= 0
      and try_cast(discount_percent as decimal(5, 2)) between 0 and 100

)

{{
    dbt_utils.deduplicate(
        relation='cleaned',
        partition_by='order_id',
        order_by='source_updated_at desc'
    )
}}

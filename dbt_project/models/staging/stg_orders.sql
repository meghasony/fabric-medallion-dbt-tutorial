{{ config(tags=['silver']) }}

select
    {{ dbt_utils.generate_surrogate_key(['order_id']) }} as order_key,
    try_cast(order_id as int) as order_id,
    try_cast(order_date as date) as order_date,
    try_cast(customer_id as int) as customer_id,
    try_cast(product_id as int) as product_id,
    try_cast(nullif(ltrim(rtrim(quantity)), '') as int) as quantity,
    try_cast(nullif(ltrim(rtrim(unit_price)), '') as decimal(18, 2)) as unit_price,
    try_cast(nullif(ltrim(rtrim(discount_percent)), '') as decimal(9, 2)) as discount_percent,
    coalesce(nullif(ltrim(rtrim(channel)), ''), 'Unknown') as channel,
    coalesce(nullif(ltrim(rtrim(payment_method)), ''), 'Unknown') as payment_method,
    coalesce(nullif(ltrim(rtrim(order_status)), ''), 'Unknown') as order_status,
    case when upper(ltrim(rtrim(is_returned))) = 'Y' then 'Yes' else 'No' end as is_returned,
    coalesce(nullif(ltrim(rtrim(return_reason)), ''), 'Not returned') as return_reason,
    coalesce(nullif(ltrim(rtrim(shipping_country)), ''), 'Unknown') as shipping_country,
    coalesce(nullif(ltrim(rtrim(campaign_name)), ''), 'None') as campaign_name,
    try_cast(source_updated_at as date) as source_updated_at
from {{ source('bronze', 'orders') }}
where try_cast(order_id as int) is not null

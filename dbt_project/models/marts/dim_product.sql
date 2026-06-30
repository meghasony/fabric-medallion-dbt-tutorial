{{ config(tags=['gold']) }}

select
    product_key,
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    list_price,
    standard_cost,
    cast(list_price - standard_cost as decimal(18, 2)) as standard_margin_amount,
    launch_date,
    is_active
from {{ ref('stg_products') }}

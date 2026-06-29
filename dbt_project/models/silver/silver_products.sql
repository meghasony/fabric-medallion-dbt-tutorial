{{ config(materialized='table', tags=['silver']) }}
select
    try_cast(product_id as int) as product_id,
    trim(product_name) as product_name,
    upper(trim(category)) as category,
    trim(subcategory) as subcategory,
    trim(brand) as brand,
    try_cast(list_price as decimal(10, 2)) as list_price,
    try_cast(standard_cost as decimal(10, 2)) as standard_cost,
    try_cast(launch_date as date) as launch_date,
    case when upper(trim(is_active)) in ('Y', 'YES', 'TRUE', '1') then 1 else 0 end as is_active

from {{ source('bronze', 'products') }}

where try_cast(product_id as int) is not null
  and try_cast(list_price as decimal(10, 2)) > 0
  and try_cast(standard_cost as decimal(10, 2)) >= 0

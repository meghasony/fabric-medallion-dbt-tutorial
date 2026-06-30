{{ config(tags=['silver']) }}

select
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} as product_key,
    try_cast(product_id as int) as product_id,
    ltrim(rtrim(product_name)) as product_name,
    coalesce(nullif(upper(ltrim(rtrim(category))), ''), 'UNKNOWN') as category,
    coalesce(nullif(ltrim(rtrim(subcategory)), ''), 'Unknown') as subcategory,
    coalesce(nullif(ltrim(rtrim(brand)), ''), 'Unknown') as brand,
    try_cast(nullif(ltrim(rtrim(list_price)), '') as decimal(18, 2)) as list_price,
    try_cast(nullif(ltrim(rtrim(standard_cost)), '') as decimal(18, 2)) as standard_cost,
    try_cast(launch_date as date) as launch_date,
    case when upper(ltrim(rtrim(is_active))) = 'Y' then 'Yes'
         when upper(ltrim(rtrim(is_active))) = 'N' then 'No'
         else 'Unknown' end as is_active
from {{ source('bronze', 'products') }}
where try_cast(product_id as int) is not null

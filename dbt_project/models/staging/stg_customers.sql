{{ config(tags=['silver']) }}

select
    {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
    try_cast(customer_id as int) as customer_id,
    ltrim(rtrim(customer_name)) as customer_name,
    ltrim(rtrim(email)) as email,
    coalesce(nullif(upper(ltrim(rtrim(country))), ''), 'UNKNOWN') as country,
    coalesce(nullif(ltrim(rtrim(city)), ''), 'Unknown') as city,
    coalesce(nullif(upper(ltrim(rtrim(customer_segment))), ''), 'UNKNOWN') as customer_segment,
    coalesce(nullif(upper(ltrim(rtrim(loyalty_tier))), ''), 'UNKNOWN') as loyalty_tier,
    try_cast(signup_date as date) as signup_date,
    case when upper(ltrim(rtrim(marketing_opt_in))) in ('Y', 'YES') then 'Yes'
         when upper(ltrim(rtrim(marketing_opt_in))) in ('N', 'NO') then 'No'
         else 'Unknown' end as marketing_opt_in
from {{ source('bronze', 'customers') }}
where try_cast(customer_id as int) is not null

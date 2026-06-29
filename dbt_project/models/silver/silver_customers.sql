{{ config(materialized='table', tags=['silver']) }}

select
    try_cast(customer_id as int) as customer_id,
    trim(customer_name) as customer_name,
    lower(trim(email)) as email,
    coalesce(upper(nullif(trim(country), '')), 'UNKNOWN') as country,
    coalesce(trim(city), 'UNKNOWN') as city,
    upper(trim(customer_segment)) as customer_segment,
    upper(trim(loyalty_tier)) as loyalty_tier,
    try_cast(signup_date as date) as signup_date,
    case when upper(trim(marketing_opt_in)) in ('Y', 'YES') then 1 else 0 end as marketing_opt_in

from {{ source('bronze', 'customers') }}

where try_cast(customer_id as int) is not null

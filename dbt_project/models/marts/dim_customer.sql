{{ config(tags=['gold']) }}

select
    customer_key,
    customer_id,
    customer_name,
    country,
    city,
    customer_segment,
    loyalty_tier,
    signup_date,
    marketing_opt_in
from {{ ref('stg_customers') }}

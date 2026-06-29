{{ config(materialized='table', tags=['gold', 'powerbi']) }}

SELECT
    customer_id,
    customer_name,
    email,
    country,
    city,
    customer_segment,
    loyalty_tier,
    signup_date,
    marketing_opt_in
FROM {{ ref('silver_customers') }}

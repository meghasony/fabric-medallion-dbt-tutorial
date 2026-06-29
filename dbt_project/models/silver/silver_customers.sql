{{ config(materialized='table', tags=['silver']) }}

WITH cleaned AS (
    SELECT
        TRY_CAST(customer_id AS INT) AS customer_id,
        LTRIM(RTRIM(customer_name)) AS customer_name,
        LOWER(LTRIM(RTRIM(email))) AS email,
        COALESCE(NULLIF(UPPER(LTRIM(RTRIM(country))), ''), 'UNKNOWN') AS country,
        COALESCE(NULLIF(LTRIM(RTRIM(city)), ''), 'UNKNOWN') AS city,
        UPPER(LTRIM(RTRIM(customer_segment))) AS customer_segment,
        UPPER(LTRIM(RTRIM(loyalty_tier))) AS loyalty_tier,
        TRY_CAST(signup_date AS DATE) AS signup_date,
        UPPER(LTRIM(RTRIM(marketing_opt_in))) AS marketing_opt_in
    FROM {{ source('bronze', 'customers') }}
)

SELECT
    customer_id,
    customer_name,
    email,
    country,
    city,
    CASE WHEN customer_segment IN ('CONSUMER', 'CORPORATE', 'SMALL BUSINESS') THEN customer_segment ELSE 'UNKNOWN' END AS customer_segment,
    CASE WHEN loyalty_tier IN ('BRONZE', 'SILVER', 'GOLD', 'PLATINUM') THEN loyalty_tier ELSE 'UNKNOWN' END AS loyalty_tier,
    signup_date,
    CASE WHEN marketing_opt_in IN ('Y', 'YES') THEN 1 ELSE 0 END AS marketing_opt_in
FROM cleaned
WHERE customer_id IS NOT NULL

{{ config(materialized='table', tags=['silver']) }}

WITH cleaned AS (

    SELECT
        customer_id,
        INITCAP(customer_name) AS customer_name,
        COALESCE(UPPER(country), 'UNKNOWN') AS country
    FROM bronze_customers

)

SELECT DISTINCT * FROM cleaned

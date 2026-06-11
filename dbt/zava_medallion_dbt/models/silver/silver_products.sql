{{ config(materialized='table', tags=['silver']) }}

SELECT *
FROM {{ dbt_utils.safe_cast(
    relation='bronze_products',
    field='price',
    data_type='float'
) }}
WHERE price IS NOT NULL

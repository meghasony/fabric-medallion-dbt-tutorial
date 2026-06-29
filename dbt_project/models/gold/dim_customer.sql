{{ config(materialized='table', tags=['gold']) }}

select * from {{ ref('silver_customers') }}

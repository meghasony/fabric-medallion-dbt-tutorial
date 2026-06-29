{{ config(materialized='table', tags=['gold']) }}

select distinct
    order_date as date_key,
    year(order_date) as year,
    month(order_date) as month,
    concat(year(order_date), '-', right(concat('0', month(order_date)), 2)) as year_month

from {{ ref('silver_orders') }}

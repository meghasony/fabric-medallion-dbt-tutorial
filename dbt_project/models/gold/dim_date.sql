{{ config(materialized='table', tags=['gold', 'powerbi']) }}

SELECT DISTINCT
    order_date AS date_key,
    YEAR(order_date) AS calendar_year,
    MONTH(order_date) AS month_number,
    DATENAME(month, order_date) AS month_name,
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start_date,
    CONCAT(YEAR(order_date), '-', RIGHT(CONCAT('0', MONTH(order_date)), 2)) AS year_month,
    DATEPART(quarter, order_date) AS calendar_quarter
FROM {{ ref('silver_orders') }}

{{ config(tags=['gold']) }}

select distinct
    order_date as date_day,
    cast(convert(char(8), order_date, 112) as int) as date_key,
    year(order_date) as year_number,
    month(order_date) as month_number,
    cast(datename(month, order_date) as varchar(20)) as month_name,
    datefromparts(year(order_date), month(order_date), 1) as month_start_date
from {{ ref('stg_orders') }}
where order_date is not null

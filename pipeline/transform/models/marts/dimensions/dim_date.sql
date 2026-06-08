{{ config(materialized='table') }}

with date_spine as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="cast('2030-12-31' as date)"
    ) }}

),

final as (

    select
        gen_random_uuid() as date_key,
        date_day as full_date,
        extract(year from date_day) as year,
        extract(quarter from date_day) as quarter,
        extract(month from date_day) as month,
        to_char(date_day, 'Month') as month_name,
        extract(week from date_day) as week,
        extract(doy from date_day) as day_of_year,
        extract(dow from date_day) as day_of_week,
        to_char(date_day, 'Day') as day_name

    from date_spine

)

select * from final
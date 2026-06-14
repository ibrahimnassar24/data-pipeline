{{ config(
    materialized='table'
) }}

with date_spine as (

    {{
        dbt_utils.date_spine(
            datepart="day",
            start_date="cast('2024-01-01' as date)",
            end_date="cast('2050-01-01' as date)"
        )
    }}

)

select

    -- Surrogate Key
    cast(to_char(date_day, 'YYYYMMDD') as integer) as date_key,

    -- Date
    date_day as full_date,

    -- Year
    extract(year from date_day)::integer as year,

    -- Quarter
    extract(quarter from date_day)::integer as quarter_number,
    'Q' || extract(quarter from date_day)::integer as quarter_name,

    -- Month
    extract(month from date_day)::integer as month_number,
    trim(to_char(date_day, 'Month')) as month_name,
    trim(to_char(date_day, 'Mon')) as month_short_name,

    -- Week
    extract(week from date_day)::integer as week_of_year,

    -- Day
    extract(day from date_day)::integer as day_of_month,

    -- PostgreSQL:
    -- Sunday = 0
    -- Monday = 1
    -- ...
    -- Friday = 5
    -- Saturday = 6
    extract(dow from date_day)::integer as day_of_week_number,

    trim(to_char(date_day, 'Day')) as day_name,
    trim(to_char(date_day, 'Dy')) as day_short_name,

    -- Weekend Definition
    case
        when extract(dow from date_day) in (5, 6)
        then true
        else false
    end as is_weekend,

    -- Month Flags
    case
        when date_day =
             date_trunc('month', date_day)::date
        then true
        else false
    end as is_month_start,

    case
        when date_day =
             (
                 date_trunc('month', date_day)
                 + interval '1 month'
                 - interval '1 day'
             )::date
        then true
        else false
    end as is_month_end,

    -- Quarter Flags
    case
        when date_day =
             date_trunc('quarter', date_day)::date
        then true
        else false
    end as is_quarter_start,

    case
        when date_day =
             (
                 date_trunc('quarter', date_day)
                 + interval '3 month'
                 - interval '1 day'
             )::date
        then true
        else false
    end as is_quarter_end,

    -- Year Flags
    case
        when date_day =
             make_date(
                 extract(year from date_day)::integer,
                 1,
                 1
             )
        then true
        else false
    end as is_year_start,

    case
        when date_day =
             make_date(
                 extract(year from date_day)::integer,
                 12,
                 31
             )
        then true
        else false
    end as is_year_end

from date_spine
order by full_date
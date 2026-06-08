{{ config(materialized='table') }}

with stg_currencies as (

    select * from {{ ref('stg_currencies') }}

),

final as (

    select
        gen_random_uuid() as currency_key,
        currency_id,
        currency_code,
        currency_name,
        currency_symbol,
        decimal_places,
        is_enabled,
        created_at,
        updated_at,
        deleted_at

    from stg_currencies

)

select * from final
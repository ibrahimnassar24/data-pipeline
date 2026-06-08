{{ config(materialized='table') }}

with stg_categories as (

    select * from {{ ref('stg_categories') }}

),

final as (

    select
        gen_random_uuid() as category_key,
        category_id,
        user_id,
        category_name,
        is_encrypted,
        created_at,
        updated_at,
        deleted_at

    from stg_categories

)

select * from final
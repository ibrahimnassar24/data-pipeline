{{ config(materialized='table') }}

with stg_categories as (

    select * from {{ ref('stg_categories') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['category_id']) }} as category_key,
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
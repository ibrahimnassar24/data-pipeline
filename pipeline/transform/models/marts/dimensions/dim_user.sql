{{ config(materialized='table') }}

with stg_users as (

    select * from {{ ref('stg_users') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['user_id']) }} as user_key,
        user_id,
        group_name,
        role_name,
        email,
        is_blocked,
        created_at,
        updated_at

    from stg_users

)

select * from final
{{ config(materialized='table') }}

with stg_users as (

    select * from {{ ref('stg_users') }}

),

final as (

    select
        gen_random_uuid() as user_key,
        user_id,
        user_group_id,
        email,
        is_blocked,
        created_at,
        updated_at

    from stg_users

)

select * from final
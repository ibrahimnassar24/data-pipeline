{{ config(materialized='table') }}

with stg_budgets as (

    select * from {{ ref('stg_budgets') }}

),

final as (

    select
        gen_random_uuid() as budget_key,
        budget_id,
        user_id,
        budget_name,
        is_active,
        is_encrypted,
        created_at,
        updated_at,
        deleted_at

    from stg_budgets

)

select * from final
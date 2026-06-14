{{ config(materialized='table') }}

with stg_budgets as (

    select * from {{ ref('stg_budgets') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['budget_id']) }} as budget_key,
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
{{ config(materialized='table') }}

with bridge_source as (
    select * from {{ ref('stg_budget_transaction_journal') }}
),

budget_limits as (
    select * from {{ ref('stg_budget_limit') }}
),

fact_trans as (
    select 
      transaction_id,
      transaction_journal_id,
      transaction_key,
      dt.full_date as transaction_date
    from {{ ref('fact_transaction') }} ft
    join {{ ref('dim_date') }} dt
    on ft.date_key = dt.date_key
),

dim_budgets as (
    select budget_id, budget_key from {{ ref('dim_budget') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['ft.transaction_key', 'db.budget_key']) }} key,
    ft.transaction_key,
    db.budget_key,
    bl.limit_id,
    ft.transaction_date,
    bl.limit_start_date,
    bl.limit_end_date
from bridge_source bs
inner join fact_trans ft on bs.transaction_journal_id = ft.transaction_journal_id
inner join dim_budgets db on bs.budget_id = db.budget_id
left join budget_limits bl on bs.budget_id = bl.budget_id
and ft.transaction_date::date >= bl.limit_start_date::date
and ft.transaction_date::date <= bl.limit_end_date::date
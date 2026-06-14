{{ config(materialized='table') }}

with bridge_source as (
    select * from {{ ref('stg_category_transaction_journal') }}
),

fact_trans as (
    select transaction_id, transaction_journal_id, transaction_key from {{ ref('fact_transaction') }}
),

dim_categories as (
    select category_id, category_key from {{ ref('dim_category') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['ft.transaction_key', 'dc.category_key']) }} key,
    ft.transaction_key,
    dc.category_key


from bridge_source bs
inner join fact_trans ft on bs.transaction_journal_id = ft.transaction_journal_id
inner join dim_categories dc on bs.category_id = dc.category_id
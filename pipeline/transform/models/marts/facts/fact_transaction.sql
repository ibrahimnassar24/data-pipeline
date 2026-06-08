{{ config(materialized='table') }}

with transactions as (
    select * from {{ ref('stg_transactions') }}
),

journals as (
    select * from {{ ref('stg_transaction_journals') }}
),

-- Joins for dimension keys
dim_users as ( select user_id, user_key from {{ ref('dim_user') }} ),
dim_accounts as ( select account_id, account_key from {{ ref('dim_account') }} ),
dim_categories as ( select category_id, category_key from {{ ref('dim_category') }} ),
dim_currencies as ( select currency_id, currency_key from {{ ref('dim_currency') }} ),

final as (
    select
        gen_random_uuid() as transaction_key,
        
        -- Foreign Keys to Dimensions
        j.transaction_date::date as transaction_date, -- Need to convert to link to dim_date
        a.account_key,
        c.category_key,
        cur.currency_key,
        u.user_key,

        -- Transaction Metrics
        t.transaction_id,
        t.amount,
        t.native_amount,
        t.foreign_amount,
        t.is_reconciled,
        
        t.created_at,
        t.updated_at

    from transactions t
    left join journals j on t.transaction_journal_id = j.transaction_journal_id
    left join dim_users u on j.user_id = u.user_id
    left join dim_accounts a on t.account_id = a.account_id
    left join dim_categories c on t.transaction_id = c.category_id -- Assuming category mapping
    left join dim_currencies cur on t.transaction_currency_id = cur.currency_id
)

select * from final
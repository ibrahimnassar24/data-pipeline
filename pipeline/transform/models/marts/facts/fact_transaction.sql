{{ config(materialized='table') }}

with transactions as (
    select * from {{ ref('stg_transactions') }}
),

journals as (
    select * from {{ ref('stg_transaction_journals') }}
),

-- Joins for dimension keys
dim_users as ( select user_id, user_key from {{ ref('dim_user') }} ),
dim_accounts as ( select account_id, currency_id,  account_key from {{ ref('dim_account') }} ),
dim_types as ( select transaction_type_id, transaction_type_key from {{ ref('dim_transaction_type') }} ),
dim_currencies as ( select currency_id, currency_key from {{ ref('dim_currency') }} ),
dim_dates as ( select date_key, full_date from {{ ref('dim_date') }}),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['t.transaction_id']) }} as transaction_key,
        
        -- Foreign Keys to Dimensions
        d.date_key,
        dt.transaction_type_key,
        a.account_key,
        cur.currency_key,
        u.user_key,

        -- Transaction Metrics
        t.transaction_id,
        t.transaction_journal_id,
        t.amount,
        t.native_amount,
        t.foreign_amount,
        t.is_reconciled,

        t.created_at

    from transactions t
    left join journals j on t.transaction_journal_id = j.transaction_journal_id
    left join dim_users u on j.user_id = u.user_id
    left join dim_currencies cur on t.transaction_currency_id = cur.currency_id
    left join dim_accounts a on t.account_id = a.account_id and t.transaction_currency_id = a.currency_id
    left join dim_dates d on j.transaction_date::date = d.full_date::date
    left join dim_types dt on j.transaction_type_id = dt.transaction_type_id
)

select * from final
{{ config(materialized='table') }}

with daily_transactions as (
    select
        t.account_id,
        j.transaction_date,
        sum(t.amount) as total_change
    from {{ ref('stg_transactions') }} t
    join {{ ref('stg_transaction_journals') }} j 
        on t.transaction_journal_id = j.transaction_journal_id
    group by 1, 2
),

dim_accounts as ( select account_id, account_key from {{ ref('dim_account') }} ),
dim_dates as ( select full_date, date_key from {{ ref('dim_date') }} )

select
    gen_random_uuid() as balance_key,
    d.date_key,
    a.account_key,
    dt.total_change as daily_change,
    sum(dt.total_change) over (partition by a.account_key order by d.full_date) as running_balance

from daily_transactions dt
join dim_accounts a on dt.account_id = a.account_id
join dim_dates d on dt.transaction_date = d.full_date
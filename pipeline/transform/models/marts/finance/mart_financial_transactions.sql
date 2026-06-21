{{ config(
    materialized='table'
) }}

with transactions as (

    select *
    from {{ ref('fact_transaction') }}

),

accounts as (

    select *
    from {{ ref('dim_account') }}

),

dates as (

    select *
    from {{ ref('dim_date') }}

),

currencies as (

    select *
    from {{ ref('dim_currency') }}

),

transaction_types as (

    select *
    from {{ ref('dim_transaction_type') }}

),

categories as (

    select
        btc.transaction_key,
        c.category_name
    from {{ ref('bridge_transaction_category') }} btc
    left join {{ ref('dim_category') }} c
        on btc.category_key = c.category_key

),

final as (

    select

        t.transaction_key,
        t.transaction_id,
        t.transaction_journal_id,

        d.full_date,
        d.year,
        d.month_number,
        d.month_name,

        a.account_key,
        a.account_name,
        a.account_type,

        tt.type_name as transaction_type,

        c.category_name,

        dc.currency_code,

        t.amount as amount_original,

        case
            when upper(dc.currency_code) = 'USD' then 50
            else 1
        end as exchange_rate,

        case
            when upper(dc.currency_code) = 'USD'
                then t.amount * 50
            else t.amount
        end as amount_egp,

        case
            when lower(a.account_type) = 'revenue account'
                then true
            else false
        end as is_income,

        case
            when lower(a.account_type) = 'expense account'
                then true
            else false
        end as is_expense,

        case
            when lower(a.account_type) in (
                'cash account',
                'asset account'
            )
                then true
            else false
        end as is_asset,

        case
            when lower(a.account_type) in (
                'loan',
                'debt',
                'liability credit account'
            )
                then true
            else false
        end as is_liability

    from transactions t

    left join accounts a
        on t.account_key = a.account_key


    left join dates d
        on t.date_key = d.date_key

    left join currencies dc
        on t.currency_key = dc.currency_key

    left join transaction_types tt
        on t.transaction_type_key = tt.transaction_type_key

    left join categories c
        on t.transaction_key = c.transaction_key

)

select *
from final
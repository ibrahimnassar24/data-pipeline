{{ config(
    materialized = 'table'
) }}

-- ============================================================================
-- Model: mart_account_daily_balance
--
-- Grain:
--     One row per account per day.
--
-- Purpose:
--     Provides running balances for:
--
--     - Balance Sheet
--     - Net Worth Report
--     - Account Trend Analysis
--     - Runway Calculation
--
-- Reporting Currency:
--     EGP
--
-- Notes:
--
--     Daily Movement:
--         Sum of all transaction activity for an account on a date.
--
--     Closing Balance:
--         Running total of all movements up to and including the date.
--
-- ============================================================================

with transactions as (

    select
        account_key,
        account_name,
        account_type,
        full_date,
        amount_egp
    from {{ ref('mart_financial_transactions') }}

),

daily_movements as (

    select

        account_key,
        account_name,
        account_type,
        full_date,

        sum(amount_egp) as daily_movement_egp

    from transactions

    group by

        account_key,
        account_name,
        account_type,
        full_date

),

running_balances as (

    select

        account_key,
        account_name,
        account_type,
        full_date,

        daily_movement_egp,

        sum(daily_movement_egp)
            over (
                partition by account_key
                order by full_date
                rows between unbounded preceding
                and current row
            ) as closing_balance_egp

    from daily_movements

),

final as (

    select

        md5(
            concat(
                account_key,
                '|',
                full_date
            )
        ) as account_daily_balance_key,

        account_key,
        account_name,
        account_type,

        full_date,

        coalesce(
            lag(closing_balance_egp)
                over (
                    partition by account_key
                    order by full_date
                ),
            0
        ) as opening_balance_egp,

        daily_movement_egp,

        closing_balance_egp

    from running_balances

)

select *
from final
order by
    account_name,
    full_date

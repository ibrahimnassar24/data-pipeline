{{ config(
    materialized = 'table'
) }}

-- ============================================================================
-- Model: rpt_runway
--
-- Grain:
--     Single row.
--
-- Purpose:
--     Estimate how many months current cash reserves can support
--     spending based on historical expenses.
--
-- Formula:
--
--     Runway Months =
--         Current Cash Balance
--         /
--         Average Monthly Expenses
--
-- Reporting Currency:
--     EGP
--
-- Source Models:
--
--     rpt_balance_sheet
--     rpt_income_statement
--
-- Business Rules:
--
--     Available Cash:
--         Sum of balances in Cash Accounts only.
--
--     Burn Rate:
--         Average monthly expenses.
--
-- ============================================================================

with latest_balance_date as (

    select
        max(full_date) as latest_date
    from {{ ref('mart_account_daily_balance') }}

),

current_cash as (

    select

        sum(closing_balance_egp) as current_cash_balance_egp

    from {{ ref('mart_account_daily_balance') }}
    where account_type = 'Cash account'
      and full_date = (
            select latest_date
            from latest_balance_date
      )

),

average_expenses as (

    select

        avg(total_expenses_egp)
            as avg_monthly_expense_egp

    from {{ ref('rpt_income_statement') }}

),

final as (

    select

        current_date as report_date,

        c.current_cash_balance_egp,

        a.avg_monthly_expense_egp,

        case

            when a.avg_monthly_expense_egp is null
                then null

            when a.avg_monthly_expense_egp = 0
                then null

            else round(
                c.current_cash_balance_egp
                /
                a.avg_monthly_expense_egp,
                2
            )

        end as runway_months

    from current_cash c
    cross join average_expenses a

)

select *
from final
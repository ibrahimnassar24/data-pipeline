{{ config(
    materialized = 'table'
) }}

-- ============================================================================
-- Model: mart_monthly_financials
--
-- Grain:
--     One row per month.
--
-- Purpose:
--     Monthly financial summary used by:
--
--     - Income Statement (P&L)
--     - Burn Rate Report
--     - Executive Dashboard
--     - Income Trend Report
--     - Expense Trend Report
--
-- Reporting Currency:
--     EGP
--
-- Notes:
--     Revenue is derived from "Revenue account" transaction legs.
--     Expenses are derived from "Expense account" transaction legs.
--
--     Asset, Cash, Debt, Loan and Liability accounts are excluded because
--     they belong to Balance Sheet reporting rather than P&L reporting.
--
--     Burn Rate for this personal finance warehouse is defined as:
--
--         Burn Rate = Total Monthly Expenses
--
--     Net Savings is defined as:
--
--         Net Savings = Income - Expenses
--
-- ============================================================================

with financial_transactions as (

    select *
    from {{ ref('mart_financial_transactions') }}

),

monthly_aggregation as (

    select

        year,
        month_number,
        month_name,

        sum(
            case
                when is_income = true
                then abs(amount_egp)
                else 0
            end
        ) as income_egp,

        sum(
            case
                when is_expense = true
                then abs(amount_egp)
                else 0
            end
        ) as expense_egp,

        sum(
            case
                when is_liability = true
                then amount_egp
                else 0
            end
        ) as liability_egp,

        count(
            case
                when is_income = true
                then 1
            end
        ) as income_transaction_count,

        count(
            case
                when is_expense = true
                then 1
            end
        ) as expense_transaction_count,

        count(
            case
                when is_liability = true
                then 1
            end
        ) as liability_transaction_count

    from financial_transactions

    group by
        year,
        month_number,
        month_name

),

final as (

    select

        year,
        month_number,
        month_name,

        income_egp,

        expense_egp,

        liability_egp,

        income_egp - expense_egp
            as net_savings_egp,

        expense_egp
            as burn_rate_egp,

        income_transaction_count,

        expense_transaction_count,

        liability_transaction_count

    from monthly_aggregation

)

select *
from final
order by
    year,
    month_number

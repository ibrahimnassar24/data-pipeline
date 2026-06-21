{{ config(
    materialized = 'table'
) }}

-- ============================================================================
-- Model: rpt_income_statement
--
-- Grain:
--     One row per month.
--
-- Purpose:
--     Income Statement (Profit & Loss).
--
-- Business Definitions:
--
--     Total Income
--         Sum of all Revenue Account activity.
--
--     Total Expenses
--         Sum of all Expense Account activity.
--
--     Net Savings
--         Income - Expenses
--
--     Savings Rate
--         Net Savings / Income
--
-- Reporting Currency:
--     EGP
--
-- Consumers:
--
--     - Executive Dashboard
--     - Income Statement Report
--     - Burn Rate Report
--     - Personal Finance Analytics
--
-- ============================================================================

with monthly_financials as (

    select *
    from {{ ref('mart_monthly_financials') }}

),

final as (

    select

        md5(
            concat(
                year,
                '-',
                lpad(month_number::text, 2, '0')
            )
        ) as income_statement_key,

        year,

        month_number,

        month_name,

        income_egp
            as total_income_egp,

        expense_egp
            as total_expenses_egp,

        net_savings_egp,

        case
            when income_egp = 0 then null

            else round(
                (
                    net_savings_egp
                    /
                    income_egp
                ) * 100,
                2
            )
        end as savings_rate_pct,

        burn_rate_egp

    from monthly_financials

)

select *
from final
order by
    year,
    month_number

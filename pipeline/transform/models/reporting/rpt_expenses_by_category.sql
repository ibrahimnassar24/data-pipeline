{{ config(
    materialized = 'table'
) }}

-- ============================================================================
-- Model: rpt_expenses_by_category
--
-- Grain:
--     One row per category per month.
--
-- Purpose:
--     Expense analysis by category.
--
-- Business Rules:
--
--     Only transaction legs belonging to "Expense account"
--     are included.
--
--     Expense amounts are stored as positive values
--     using ABS(amount_egp).
--
-- Reporting Currency:
--     EGP
--
-- Consumers:
--
--     - Expense Dashboard
--     - Budget Analysis
--     - Category Trend Reports
--     - Top Spending Categories Report
--
-- ============================================================================

with expense_transactions as (

    select

        year,
        month_number,
        month_name,

        coalesce(
            category_name,
            'Uncategorized'
        ) as category_name,

        abs(amount_egp) as expense_amount_egp

    from {{ ref('mart_financial_transactions') }}

    where account_type = 'Expense account'

),

monthly_category_expenses as (

    select

        year,

        month_number,

        month_name,

        category_name,

        sum(expense_amount_egp)
            as total_expense_egp,

        count(*)
            as transaction_count

    from expense_transactions

    group by

        year,

        month_number,

        month_name,

        category_name

),

monthly_totals as (

    select

        year,

        month_number,

        sum(total_expense_egp)
            as monthly_total_expense_egp

    from monthly_category_expenses

    group by

        year,

        month_number

),

final as (

    select

        md5(
            concat(
                mce.year,
                '|',
                mce.month_number,
                '|',
                mce.category_name
            )
        ) as expense_category_key,

        mce.year,

        mce.month_number,

        mce.month_name,

        mce.category_name,

        mce.total_expense_egp,

        mce.transaction_count,

        round(
            (
                mce.total_expense_egp
                /
                nullif(mt.monthly_total_expense_egp, 0)
            ) * 100,
            2
        ) as expense_share_pct

    from monthly_category_expenses mce

    left join monthly_totals mt
        on mce.year = mt.year
       and mce.month_number = mt.month_number

)

select *
from final
order by

    year,

    month_number,

    total_expense_egp desc
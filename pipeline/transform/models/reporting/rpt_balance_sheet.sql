{{ config(
    materialized = 'table'
) }}

-- ============================================================================
-- Model: rpt_balance_sheet
--
-- Grain:
--     One row per reporting date.
--
-- Purpose:
--     Personal Finance Balance Sheet.
--
-- Formula:
--
--     Assets
--     - Liabilities
--     = Net Worth
--
-- Reporting Currency:
--     EGP
--
-- Source:
--     mart_account_daily_balance
--
-- Consumers:
--
--     - Executive Dashboard
--     - Net Worth Trend Report
--     - Financial Position Analysis
--
-- ============================================================================

with latest_account_balances as (

    select

        full_date,

        account_key,

        account_name,

        account_type,

        closing_balance_egp,

        row_number() over (
            partition by
                full_date,
                account_key
            order by
                full_date desc
        ) as rn

    from {{ ref('mart_account_daily_balance') }}

),

balances as (

    select *

    from latest_account_balances

    where rn = 1

),

daily_assets as (

    select

        full_date,

        sum(closing_balance_egp) as total_assets_egp

    from balances

    where account_type in (

        'Cash account',
        'Asset account'

    )

    group by full_date

),

daily_liabilities as (

    select

        full_date,

        sum(abs(closing_balance_egp)) as total_liabilities_egp

    from balances

    where account_type in (

        'Loan',
        'Debt',
        'Liability credit account'

    )

    group by full_date

),

final as (

    select

        md5(
            coalesce(a.full_date, l.full_date)::text
        ) as balance_sheet_key,

        coalesce(
            a.full_date,
            l.full_date
        ) as full_date,

        coalesce(
            a.total_assets_egp,
            0
        ) as total_assets_egp,

        coalesce(
            l.total_liabilities_egp,
            0
        ) as total_liabilities_egp,

        coalesce(
            a.total_assets_egp,
            0
        )
        -
        coalesce(
            l.total_liabilities_egp,
            0
        ) as net_worth_egp

    from daily_assets a

    full outer join daily_liabilities l
        on a.full_date = l.full_date

)

select *

from final

order by full_date
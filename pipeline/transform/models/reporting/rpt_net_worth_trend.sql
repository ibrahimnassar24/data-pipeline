{{ config(
    materialized = 'table'
) }}

-- ============================================================================
-- Model: rpt_net_worth_trend
--
-- Grain:
--     One row per reporting date.
--
-- Purpose:
--     Track net worth over time.
--
-- Formula:
--
--     Net Worth = Assets - Liabilities
--
--     Net Worth Change =
--         Current Net Worth - Previous Net Worth
--
--     Net Worth Change % =
--         Net Worth Change / Previous Net Worth
--
-- Reporting Currency:
--     EGP
--
-- Source:
--     rpt_balance_sheet
--
-- Consumers:
--
--     - Executive Dashboard
--     - Personal Wealth Tracking
--     - Financial Performance Analysis
--     - Runway Report
--
-- ============================================================================

with balance_sheet as (

    select *
    from {{ ref('rpt_balance_sheet') }}

),

trend as (

    select

        balance_sheet_key,

        full_date,

        total_assets_egp,

        total_liabilities_egp,

        net_worth_egp,

        lag(net_worth_egp) over (
            order by full_date
        ) as previous_net_worth_egp

    from balance_sheet

),

final as (

    select

        balance_sheet_key
            as net_worth_trend_key,

        full_date,

        total_assets_egp,

        total_liabilities_egp,

        net_worth_egp,

        net_worth_egp
            - coalesce(previous_net_worth_egp, net_worth_egp)
            as net_worth_change_egp,

        case
            when previous_net_worth_egp is null then null

            when previous_net_worth_egp = 0 then null

            else round(
                (
                    (net_worth_egp - previous_net_worth_egp)
                    / previous_net_worth_egp
                ) * 100,
                2
            )
        end as net_worth_change_pct

    from trend

)

select *

from final

order by full_date
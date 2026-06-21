{{ config(
    materialized = 'table'
) }}

-- ============================================================================
-- Model: rpt_cash_flow_statement
--
-- Grain:
--     One row per month.
--
-- Purpose:
--     Monthly Cash Flow Statement.
--
-- Business Rules:
--
--     Cash In:
--         Positive movements on Cash Accounts.
--
--     Cash Out:
--         Negative movements on Cash Accounts.
--
--     Net Cash Flow:
--         Cash In - Cash Out
--
-- Reporting Currency:
--     EGP
--
-- Consumers:
--
--     - Executive Dashboard
--     - Cash Flow Analysis
--     - Runway Calculation
--     - Net Worth Analysis
--
-- ============================================================================

with cash_transactions as (

    select

        year,
        month_number,
        month_name,

        amount_egp

    from {{ ref('mart_financial_transactions') }}

    where account_type = 'Cash account'

),

monthly_cash_flow as (

    select

        year,

        month_number,

        month_name,

        sum(
            case
                when amount_egp > 0
                then amount_egp
                else 0
            end
        ) as cash_in_egp,

        sum(
            case
                when amount_egp < 0
                then abs(amount_egp)
                else 0
            end
        ) as cash_out_egp

    from cash_transactions

    group by

        year,

        month_number,

        month_name

),

final as (

    select

        md5(
            concat(
                year,
                '-',
                lpad(month_number::text, 2, '0')
            )
        ) as cash_flow_key,

        year,

        month_number,

        month_name,

        cash_in_egp,

        cash_out_egp,

        cash_in_egp - cash_out_egp
            as net_cash_flow_egp

    from monthly_cash_flow

)

select *
from final
order by

    year,

    month_number
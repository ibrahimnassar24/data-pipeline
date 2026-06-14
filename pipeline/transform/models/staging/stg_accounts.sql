with source_accounts as (

    select *
    from {{ source('raw', 'accounts') }}

),

source_account_types as (

    select *
    from {{ source('raw', 'account_types') }}

),

source_transaction_currencies as (

    select distinct
        a1.id as account_id,
        tc1.id as currency_id,
        tc1.code as currency_code

    from {{ source('raw', 'transactions') }} t1

    join {{ source('raw', 'accounts') }} a1
        on t1.account_id = a1.id

    join {{ source('raw', 'transaction_currencies') }} tc1
        on t1.transaction_currency_id = tc1.id

),

enriched_accounts as (

    select

        a.id as account_id,
        a.user_id,
        a.user_group_id,
        a.account_type_id,
        tc.currency_id,

        a.name as account_name,
        a.iban,

        act.type as account_type,
        tc.currency_code,

        a.virtual_balance,
        a.native_virtual_balance,

        a.active as is_active,
        a.encrypted as is_encrypted,

        a.created_at,
        a.updated_at,
        a.deleted_at,

        a._sdc_extracted_at as extracted_at

    from source_accounts a

    left join source_account_types act
        on a.account_type_id = act.id

    left join source_transaction_currencies tc
        on a.id = tc.account_id

)

select *
from enriched_accounts
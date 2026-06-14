{{ config(materialized='table') }}

with stg_accounts as (

    select * from {{ ref('stg_accounts') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['account_id', 'currency_code']) }} as account_key,
        account_id,
        user_id,
        account_type_id,
        currency_id,
        account_name,
        account_type,
        currency_code,
        iban,
        is_active,
        is_encrypted,
        created_at,
        updated_at,
        deleted_at

    from stg_accounts

)

select * from final
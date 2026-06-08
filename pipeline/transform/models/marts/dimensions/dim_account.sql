{{ config(materialized='table') }}

with stg_accounts as (

    select * from {{ ref('stg_accounts') }}

),

final as (

    select
        gen_random_uuid() as account_key,
        account_id,
        user_id,
        account_type_id,
        account_name,
        iban,
        is_active,
        is_encrypted,
        created_at,
        updated_at,
        deleted_at

    from stg_accounts

)

select * from final
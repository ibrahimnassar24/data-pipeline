with source as (

    select * from {{ source('firefly', 'transactions') }}

),

renamed as (

    select
        id as transaction_id,
        transaction_journal_id,
        account_id,
        transaction_currency_id,
        foreign_currency_id,
        
        description,
        amount,
        foreign_amount,
        native_amount,
        native_foreign_amount,
        
        identifier,
        reconciled as is_reconciled,
        balance_before,
        balance_after,
        balance_dirty as is_balance_dirty,
        
        created_at,
        updated_at,
        deleted_at

    from source

)

select * from renamed
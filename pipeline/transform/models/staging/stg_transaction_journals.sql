with source as (

    select * from {{ source('raw', 'transaction_journals') }}

),

renamed as (

    select
        id as transaction_journal_id,
        user_id,
        transaction_type_id,
        bill_id,
        transaction_group_id,
        transaction_currency_id,

        description,
        date as transaction_date,
        interest_date,
        book_date,
        process_date,
        
        completed as is_completed,
        encrypted as is_encrypted,
        
        created_at,
        updated_at,
        deleted_at

    from source

)

select * from renamed
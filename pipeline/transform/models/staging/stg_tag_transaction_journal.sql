with source as (

    select * from {{ source('firefly', 'tag_transaction_journal') }}

),

renamed as (

    select
        id as tag_transaction_journal_id,
        tag_id,
        transaction_journal_id,
        date,
        amount,
        native_amount

    from source

)

select * from renamed
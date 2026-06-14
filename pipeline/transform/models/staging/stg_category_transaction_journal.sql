with source as (

    select * from {{ source('raw', 'category_transaction_journal') }}

),

renamed as (

    select
        id,
        category_id,
        transaction_journal_id
    from source

)

select * from renamed
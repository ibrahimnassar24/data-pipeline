with source as (

    select * from {{ source('raw', 'budget_transaction_journal') }}

),

renamed as (

    select
        id,
        budget_id,
        transaction_journal_id
    from source

)

select * from renamed
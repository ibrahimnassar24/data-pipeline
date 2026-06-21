with source as (

    select * from {{ source('raw', 'budget_limits') }}

),

renamed as (

    select
        s.id as limit_id,
        s.budget_id,
        s.created_at,
        s.updated_at,
        s.start_date as limit_start_date,
        s.end_date as limit_end_date,
        s.amount as limit_amount,
        s.transaction_currency_id,
        s.native_amount
    from source s

)

select * from renamed
with source as (

    select * from {{ source('raw', 'budgets') }}

),

limits as (

    select * from {{ source('raw', 'budget_limits') }}

),

renamed as (

    select
        s.id as budget_id,
        s.user_id,
        s.name as budget_name,
        s.active as is_active,
        s.encrypted as is_encrypted,
        s.created_at,
        s.updated_at,
        s.deleted_at,
        l.start_date as limit_start_date,
        l.end_date as limit_end_date,
        l.amount as limit_amount,
        l.transaction_currency_id

    from source s
    left join limits l
    on s.id = l.budget_id

)

select * from renamed
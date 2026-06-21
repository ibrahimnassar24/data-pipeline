with source as (

    select * from {{ source('raw', 'budgets') }}

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
        s.deleted_at
    from source s
)

select * from renamed
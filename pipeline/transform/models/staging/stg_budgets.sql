with source as (

    select * from {{ source('firefly', 'budgets') }}

),

renamed as (

    select
        id as budget_id,
        user_id,
        name as budget_name,
        active as is_active,
        encrypted as is_encrypted,
        created_at,
        updated_at,
        deleted_at

    from source

)

select * from renamed
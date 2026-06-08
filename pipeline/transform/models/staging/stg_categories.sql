with source as (

    select * from {{ source('firefly', 'categories') }}

),

renamed as (

    select
        id as category_id,
        user_id,
        name as category_name,
        encrypted as is_encrypted,
        created_at,
        updated_at,
        deleted_at

    from source

)

select * from renamed
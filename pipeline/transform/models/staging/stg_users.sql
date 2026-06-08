with source as (

    select * from {{ source('firefly', 'users') }}

),

renamed as (

    select
        id as user_id,
        user_group_id,
        email,
        blocked as is_blocked,
        created_at,
        updated_at

    from source

)

select * from renamed
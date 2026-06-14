with source as (

    select * from {{ source('raw', 'tags') }}

),

renamed as (

    select
        id as tag_id,
        user_id,
        tag as tag_name,
        description as tag_description,
        created_at,
        updated_at,
        deleted_at

    from source

)

select * from renamed
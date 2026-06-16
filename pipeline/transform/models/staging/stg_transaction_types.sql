with source as (

    select * from {{ source('raw', 'transaction_types') }}

),

renamed as (

    select
        id as transaction_type_id,
        type as type_name,
        created_at,
        updated_at,
        deleted_at

    from source

)

select * from renamed
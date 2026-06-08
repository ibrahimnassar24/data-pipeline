with source as (

    select * from {{ source('firefly', 'accounts') }}

),

renamed as (

    select
        id as account_id,
        user_id,
        account_type_id,
        name as account_name,
        iban,
        active as is_active,
        encrypted as is_encrypted,
        created_at,
        updated_at,
        deleted_at

    from source

)

select * from renamed
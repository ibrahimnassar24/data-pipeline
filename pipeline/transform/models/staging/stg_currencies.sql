with source as (

    select * from {{ source('firefly', 'transaction_currencies') }}

),

renamed as (

    select
        id as currency_id,
        code as currency_code
        name as currency_name,
	symbol as currency_symbol,
	decimal_places,
        enabled as is_enabled

    from source

)

select * from renamed
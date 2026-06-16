{{ config(materialized='table') }}

with stg_types as (

    select * from {{ ref('stg_transaction_types') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['transaction_type_id']) }} as transaction_type_key,
        transaction_type_id,
        type_name,
        created_at,
        updated_at,
        deleted_at

    from stg_types

)

select * from final
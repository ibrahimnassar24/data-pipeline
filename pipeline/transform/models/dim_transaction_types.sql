with transaction_types as (
    select transaction_type
    from {{ source('finance_raw', 'transactions') }}
    group by transaction_type
)

select gen_random_uuid() as id, transaction_type as transaction_types
from transaction_types
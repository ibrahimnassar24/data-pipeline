{{ config(materialized='table') }}

with bridge_source as (
    select * from {{ ref('stg_tag_transaction_journal') }}
),

fact_trans as (
    select transaction_id, transaction_key from {{ ref('fact_transaction') }}
),

dim_tags as (
    select tag_id, tag_key from {{ ref('dim_tag') }}
)

select
    gen_random_uuid() as bridge_key,
    ft.transaction_key,
    dt.tag_key,
    bs.amount,
    bs.native_amount

from bridge_source bs
inner join fact_trans ft on bs.transaction_journal_id = ft.transaction_id
inner join dim_tags dt on bs.tag_id = dt.tag_id
{{ config(materialized='table') }}

with stg_tags as (

    select * from {{ ref('stg_tags') }}

),

final as (

    select
        gen_random_uuid() as tag_key,
        tag_id,
        user_id,
        tag_name,
        tag_description,
        -- Placeholder for hierarchical logic
        1 as tag_level,
        null::integer as parent_tag_key,
        true as is_root,
        true as is_leaf,
        created_at,
        updated_at,
        deleted_at

    from stg_tags

)

select * from final
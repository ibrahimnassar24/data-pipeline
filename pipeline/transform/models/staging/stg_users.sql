with source_users as (
    select * from {{ source('raw', 'users') }}
),

source_user_groups as (
    select * from {{ source('raw', 'user_groups') }}
),

source_group_memberships as (
    select * from {{ source('raw', 'group_memberships') }}
),

source_user_roles as (
    select * from {{ source('raw', 'user_roles') }}
),

enriched_users as (
    select
        -- IDs
        u.id as user_id,
        u.user_group_id as user_group_id,

        -- Attributes
        u.email,
        u.domain,
        
        -- Enriched Group & Role Info
        ug.title as group_name,
        ur.title as role_name,

        -- Booleans / Flags
        (u.blocked <> 0) as is_blocked,

        -- Timestamps
        u.created_at,
        u.updated_at,
        
        -- Integration Metadata (Optional: keep one for freshness checks)
        u._sdc_extracted_at as extracted_at

    from source_users as u
       
    join source_group_memberships as gm
        on u.id = gm.user_id 

    join source_user_groups as ug
        on ug.id  = gm.user_group_id
        
    join source_user_roles as ur
        on gm.user_role_id = ur.id
)

select * from enriched_users
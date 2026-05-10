-- =============================================================================
-- stg__parts.sql
-- Parts catalog. Static enough for view; promote to table if query-heavy.
-- =============================================================================
with source as (

    select * from {{ source('landing', 'part') }}

),

renamed as (

    select
        p_partkey                           as part_key,
        p_name                              as part_name,
        p_mfgr                              as manufacturer,
        p_brand                             as brand,
        p_type                              as part_type,
        p_size                              as part_size,
        p_container                         as container_type,
        p_retailprice::number(15, 2)        as retail_price,
        p_comment                           as part_comment,

        -- Parsed attributes from the composite type string
        -- e.g. "SMALL BURNISHED COPPER" → size=SMALL, finish=BURNISHED, material=COPPER
        split_part(p_type, ' ', 1)          as part_size_category,
        split_part(p_type, ' ', 2)          as part_finish,
        split_part(p_type, ' ', 3)          as part_material

    from source

)

select * from renamed
-- =============================================================================
-- dim_parts
-- Layer : Marts / Core
-- Grain : One row per part.
-- =============================================================================

with parts as (
    select * from {{ ref('stg__parts') }}
),

final as (

    select
        part_key,
        part_name,
        manufacturer,
        brand,
        part_type,
        part_size,
        container_type,
        retail_price,
        part_comment,

        -- parsed sub-attributes
        part_size_category,
        part_finish,
        part_material,

        -- price band
        case
            when retail_price < 500  then 'Economy'
            when retail_price < 1000 then 'Standard'
            when retail_price < 1500 then 'Premium'
            else 'Luxury'
        end                         as price_band,

        current_timestamp()         as dbt_loaded_at

    from parts

)

select * from final
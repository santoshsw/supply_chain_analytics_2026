-- ===========================================================
-- stg__regions.sql
-- Reference table — 5 global regions.
-- ===========================================================

with source as (

    select * from {{ source('landing', 'region') }}

),

renamed as (

    select
        r_regionkey     as region_key,
        r_name          as region_name,
        r_comment       as region_comment

    from source

)

select * from renamed
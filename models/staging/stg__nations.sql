-- ====================================================================================
-- stg__nations.sql
-- Reference table — 25 nations. Static data, view materialization is fine.
-- ====================================================================================
with source as (

    select * from {{ source('landing', 'nation') }}

),

renamed as (

    select
        n_nationkey     as nation_key,
        n_name          as nation_name,
        n_regionkey     as region_key,
        n_comment       as nation_comment

    from source

)

select * from renamed
-- ====================================================================
-- stg__part_suppliers.sql
-- Part–supplier junction table with cost and availability info.
-- ====================================================================
with source as (

    select * from {{ source('landing', 'partsupp') }}

),

renamed as (

    select
        -- surrogate key
        {{ dbt_utils.generate_surrogate_key(['ps_partkey', 'ps_suppkey']) }} as part_supplier_key,
                                            
        -- natural keys
        ps_partkey                          as part_key,
        ps_suppkey                          as supplier_key,

        -- measures
        ps_availqty::int                    as available_quantity,
        ps_supplycost::number(15, 2)        as supply_cost,

        -- freeform
        ps_comment                          as part_supplier_comment

    from source

)

select * from renamed
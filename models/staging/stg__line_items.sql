-- =============================================================================
-- stg__line_items
-- Layer        : Staging
-- Purpose : Rename, cast, and lightly clean the LINEITEMS source table.
--           One row per line_items. No business logic here.
-- =============================================================================
with source as (

    select * from {{ source('landing', 'lineitem') }}

),

renamed as (

    select
        -- surrogate / composite key
        {{ dbt_utils.generate_surrogate_key(['l_orderkey', 'l_linenumber']) }} as order_item_key,
                                                    
        -- foreign keys
        l_orderkey                                  as order_key,
        l_partkey                                   as part_key,
        l_suppkey                                   as supplier_key,

        -- natural key component
        l_linenumber                                as line_number,

        -- measures
        l_quantity::number(10, 2)                   as quantity,
        l_extendedprice::number(15, 2)              as extended_price,
        l_discount::number(5, 4)                    as discount_pct,
        l_tax::number(5, 4)                         as tax_pct,

        -- derived measures
        round(l_extendedprice * (1 - l_discount), 2)        as net_price,
        round(l_extendedprice * (1 - l_discount) * (1 + l_tax), 2) as gross_price,

        -- status flags
        l_returnflag                                as return_flag,
        l_linestatus                                as line_status,

        -- boolean helpers
        (l_returnflag = 'R')::boolean               as is_returned,
        (l_linestatus = 'F')::boolean               as is_fulfilled,

        -- dates
        l_shipdate::date                            as ship_date,
        l_commitdate::date                          as commit_date,
        l_receiptdate::date                         as receipt_date,

        -- datediffs
        datediff('day', l_commitdate, l_receiptdate)  as days_to_receipt,
        datediff('day', l_shipdate,   l_receiptdate)  as days_in_transit,

        -- ship details
        l_shipmode                                  as ship_mode,
        l_shipinstruct                              as ship_instructions,
        l_comment                                   as line_item_comment

    from source

)

select * from renamed
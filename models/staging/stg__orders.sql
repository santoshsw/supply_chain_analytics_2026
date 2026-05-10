-- =============================================================================
-- stg__orders
-- Layer        : Staging
-- Purpose : Rename, cast, and lightly clean the ORDERS source table.
--           One row per orders. No business logic here. 
-- =============================================================================

with source as (

    select * from {{ source('landing', 'orders') }}

),

renamed as (

    select
        -- primary key
        o_orderkey                                  as order_key,

        -- foreign keys
        o_custkey                                   as customer_key,

        -- attributes
        o_orderstatus                               as order_status,
        upper(trim(o_orderpriority))                as order_priority,
        o_clerk                                     as clerk_id,
        o_shippriority                              as ship_priority,

        -- financials
        o_totalprice::number(15, 2)                 as total_price,

        -- dates
        o_orderdate::date                           as order_date,

        -- derived date parts (useful for partitioning/filtering downstream)
        year(o_orderdate)                           as order_year,
        month(o_orderdate)                          as order_month,
        quarter(o_orderdate)                        as order_quarter,
        dayofweek(o_orderdate)                      as order_day_of_week,

        -- status booleans
        (o_orderstatus = 'O')::boolean              as is_open,
        (o_orderstatus = 'F')::boolean              as is_fulfilled,
        (o_orderstatus = 'P')::boolean              as is_pending,

        -- metadata
        o_comment                                   as order_comment,
        current_timestamp()                         as updated_at

    from source

)

select * from renamed
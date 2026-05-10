-- =============================================================================
-- supply_chain__inventory_coverage
-- Layer : Marts / Supply Chain
-- Grain : One row per part–supplier combination.
-- Purpose: Surface parts with low supply or single-source risk.
-- =============================================================================

{{
    config(
        materialized = 'table',
        tags         = ['supply_chain']
    )
}}

with part_suppliers as (
    select * from {{ ref('stg__part_suppliers') }}
),

parts as (
    select * from {{ ref('dim_parts') }}
),

suppliers as (
    select * from {{ ref('dim_suppliers') }}
),

-- How much of each part was actually consumed in the last full year?
recent_demand as (

    select
        part_key,
        supplier_key,
        sum(quantity)                       as demanded_quantity_1y,
        count(distinct order_key)           as demand_order_count_1y
    from {{ ref('fct_line_items') }}
    where order_year = (select max(order_year) - 1 from {{ ref('fct_line_items') }})
    group by 1, 2

),

-- Count suppliers per part (for single-source risk flag)
supplier_count_per_part as (

    select
        part_key,
        count(distinct supplier_key)        as supplier_count
    from part_suppliers
    group by 1

),

final as (

    select
        ps.part_supplier_key,
        ps.part_key,
        ps.supplier_key,

        -- part attributes
        p.part_name,
        p.manufacturer,
        p.brand,
        p.part_type,
        p.price_band,
        p.retail_price,

        -- supplier attributes
        s.supplier_name,
        s.nation_name                       as supplier_nation,
        s.region_name                       as supplier_region,

        -- inventory
        ps.available_quantity,
        ps.supply_cost,

        -- demand context
        coalesce(d.demanded_quantity_1y, 0)   as demanded_quantity_1y,
        coalesce(d.demand_order_count_1y, 0)  as demand_order_count_1y,

        -- coverage ratio
        case
            when coalesce(d.demanded_quantity_1y, 0) = 0 then null
            else round(ps.available_quantity::float / d.demanded_quantity_1y, 2)
        end                                 as inventory_coverage_ratio,

        -- risk flags
        (sc.supplier_count = 1)::boolean    as is_single_sourced,

        case
            when coalesce(d.demanded_quantity_1y, 0) = 0 then 'No Demand'
            when ps.available_quantity::float / nullif(d.demanded_quantity_1y, 0) < 0.5
                then 'Critical Low Stock'
            when ps.available_quantity::float / nullif(d.demanded_quantity_1y, 0) < 1.0
                then 'Low Stock'
            when ps.available_quantity::float / nullif(d.demanded_quantity_1y, 0) < 2.0
                then 'Adequate'
            else 'Overstocked'
        end                                 as stock_status,

        -- value at cost
        round(ps.available_quantity * ps.supply_cost, 2) as inventory_value_at_cost

    from part_suppliers   ps
    left join parts       p   on ps.part_key    = p.part_key
    left join suppliers   s   on ps.supplier_key = s.supplier_key
    left join recent_demand d on ps.part_key = d.part_key
                              and ps.supplier_key = d.supplier_key
    left join supplier_count_per_part sc on ps.part_key = sc.part_key

)

select * from final
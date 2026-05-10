-- =============================================================================
-- supply_chain__supplier_performance
-- Layer : Marts / Supply Chain
-- Grain : Supplier × year-month
-- =============================================================================

{{
    config(
        materialized = 'table',
        cluster_by   = ['year_month'],
        tags         = ['supply_chain']
    )
}}

with line_items as (
    select * from {{ ref('fct_line_items') }}
),

suppliers as (
    select * from {{ ref('dim_suppliers') }}
),

aggregated as (

    select
        li.supplier_key,
        s.supplier_name,
        s.nation_name                               as supplier_nation,
        s.region_name                               as supplier_region,
        s.account_tier,

        -- time grain
        li.order_year                               as year,
        li.order_month                              as month,
        li.order_quarter,
        li.order_year || '-' || lpad(li.order_month::varchar, 2, '0')
                                                    as year_month,

        -- volume
        count(distinct li.order_key)                as orders_served,
        count(*)                                    as line_items_fulfilled,
        sum(li.quantity)                            as total_units_shipped,

        -- revenue booked through this supplier
        sum(li.net_price)                           as total_net_revenue,

        -- cost
        sum(li.supply_cost * li.quantity)           as total_supply_cost,

        -- margin
        sum(li.gross_margin)                        as total_gross_margin,
        round(
            sum(li.gross_margin) / nullif(sum(li.net_price), 0), 4
        )                                           as gross_margin_rate,

        -- returns attributed to supplier
        sum(case when li.is_returned then 1 else 0 end) as returned_units,
        round(
            sum(case when li.is_returned then 1 else 0 end)::float / count(*), 4
        )                                           as return_rate,

        -- delivery performance
        round(
            sum(case when li.is_on_time then 1 else 0 end)::float / count(*), 4
        )                                           as on_time_delivery_rate,

        avg(li.days_in_transit)                     as avg_days_in_transit,
        avg(li.days_to_receipt)                     as avg_days_to_receipt,

        -- parts diversity
        count(distinct li.part_key)                 as distinct_parts_supplied

    from line_items   li
    left join suppliers s on li.supplier_key = s.supplier_key
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9

),

scored as (

    select
        *,
        -- composite performance score (0–100)
        round(
            (on_time_delivery_rate   * 40)   -- 40% weight: timeliness
          + ((1 - return_rate)       * 30)   -- 30% weight: quality
          + (gross_margin_rate       * 30),  -- 30% weight: profitability
            2
        ) * 100                             as performance_score

    from aggregated

)

select * from scored
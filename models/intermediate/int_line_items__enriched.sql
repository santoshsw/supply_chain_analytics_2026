-- =============================================================================
-- int_line_items__enriched (ephemeral)
-- Line items joined to enriched orders, parts, and suppliers.
-- This is the atomic financial grain — one row per order line.
-- =============================================================================

with line_items as (
    select * from {{ ref('stg__line_items') }}
),

orders as (
    select * from {{ ref('int_orders__enriched') }}
),

parts as (
    select * from {{ ref('stg__parts') }}
),

suppliers as (
    select * from {{ ref('int_suppliers__with_geography') }}
),

part_suppliers as (
    select * from {{ ref('stg__part_suppliers') }}
),

final as (

    select
        -- ── Keys ──────────────────────────────────────────────────────────
        li.order_item_key,
        li.order_key,
        li.line_number,
        li.part_key,
        li.supplier_key,

        -- ── Order context ─────────────────────────────────────────────────
        o.order_date,
        o.order_year,
        o.order_month,
        o.order_quarter,
        o.order_priority,
        o.order_status,
        o.customer_key,
        o.customer_name,
        o.market_segment,
        o.customer_nation,
        o.customer_region,

        -- ── Line item measures ────────────────────────────────────────────
        li.quantity,
        li.extended_price,
        li.discount_pct,
        li.tax_pct,
        li.net_price,
        li.gross_price,

        -- discount and tax dollar amounts
        round(li.extended_price * li.discount_pct, 2)       as discount_amount,
        round(li.net_price * li.tax_pct, 2)                 as tax_amount,

        -- ── Status flags ─────────────────────────────────────────────────
        li.return_flag,
        li.line_status,
        li.is_returned,
        li.is_fulfilled,

        -- ── Dates ────────────────────────────────────────────────────────
        li.ship_date,
        li.commit_date,
        li.receipt_date,
        li.days_to_receipt,
        li.days_in_transit,
        li.ship_mode,
        li.ship_instructions,

        -- on-time delivery: receipt ≤ commit
        (li.receipt_date <= li.commit_date)::boolean        as is_on_time,

        -- ── Part attributes ───────────────────────────────────────────────
        p.part_name,
        p.manufacturer,
        p.brand,
        p.part_type,
        p.part_size,
        p.container_type,
        p.retail_price,
        p.part_size_category,
        p.part_finish,
        p.part_material,

        -- price vs retail delta
        round(li.extended_price / nullif(li.quantity, 0) - p.retail_price, 2)
                                                            as price_vs_retail_delta,

        -- ── Supplier attributes ───────────────────────────────────────────
        s.supplier_name,
        s.nation_name                                       as supplier_nation,
        s.region_name                                       as supplier_region,

        -- ── Supply cost context ───────────────────────────────────────────
        ps.supply_cost,
        round(li.net_price - (ps.supply_cost * li.quantity), 2) as gross_margin

    from line_items   li
    left join orders        o   on li.order_key                      = o.order_key
    left join parts         p   on li.part_key                       = p.part_key
    left join suppliers     s   on li.supplier_key                   = s.supplier_key
    left join part_suppliers ps on li.part_key = ps.part_key
                                and li.supplier_key = ps.supplier_key

)

select * from final
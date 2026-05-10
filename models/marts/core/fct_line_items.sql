-- =============================================================================
-- fct_line_items
-- Layer        : Marts / Core
-- Grain        : One row per order line item (atomic financial fact).
-- Materialization: INCREMENTAL — merge strategy on order_item_key
-- =============================================================================

{{
    config(
        materialized         = 'incremental',
        unique_key           = 'order_item_key',
        incremental_strategy = 'merge',
        cluster_by           = ['ship_date', 'order_key'],
        on_schema_change     = 'sync_all_columns',
        tags                 = ['fact', 'incremental', 'finance', 'large']
    )
}}

with enriched as (

    select * from {{ ref('int_line_items__enriched') }}

    {% if is_incremental() %}
        where ship_date >= (
            select dateadd('day', -3, coalesce(max(ship_date), '1992-01-01'::date))
            from {{ this }}
        )
    {% endif %}

),

final as (

    select
        -- ── Keys ──────────────────────────────────────────────────────────
        order_item_key,
        order_key,
        line_number,
        part_key,
        supplier_key,
        customer_key,

        -- ── Order context ─────────────────────────────────────────────────
        order_date,
        order_year,
        order_month,
        order_quarter,
        order_priority,
        order_status,
        market_segment,
        customer_nation,
        customer_region,

        -- ── Line item facts ───────────────────────────────────────────────
        quantity,
        extended_price,
        discount_pct,
        tax_pct,
        net_price,
        gross_price,
        discount_amount,
        tax_amount,
        gross_margin,

        -- ── Status ────────────────────────────────────────────────────────
        return_flag,
        line_status,
        is_returned,
        is_fulfilled,
        is_on_time,

        -- ── Ship / fulfillment ────────────────────────────────────────────
        ship_date,
        commit_date,
        receipt_date,
        days_to_receipt,
        days_in_transit,
        ship_mode,
        ship_instructions,

        -- ── Part context ──────────────────────────────────────────────────
        part_name,
        manufacturer,
        brand,
        part_type,
        part_material,
        part_finish,
        retail_price,
        price_vs_retail_delta,

        -- ── Supplier context ──────────────────────────────────────────────
        supplier_name,
        supplier_nation,
        supplier_region,
        supply_cost,

        -- ── Metadata ──────────────────────────────────────────────────────
        current_timestamp()         as dbt_loaded_at

    from enriched

)

select * from final
-- =============================================================================
-- fct_orders
-- Layer        : Marts / Core
-- Grain        : One row per order.
-- Materialization: INCREMENTAL — delete+insert strategy
--
-- Why delete+insert?
--   Orders change status (O→F). A merge updates in place but delete+insert is
--   simpler to reason about when many columns can change. We delete all rows
--   for the affected partition (order_date window) then re-insert.
--
--   Snowflake supports delete+insert natively via the `delete+insert` strategy.
-- =============================================================================

{{
    config(
        materialized         = 'incremental',
        unique_key           = 'order_key',
        incremental_strategy = 'delete+insert',
        cluster_by           = ['order_date'],
        on_schema_change     = 'sync_all_columns',
        tags                 = ['fact', 'incremental', 'finance']
    )
}}

with orders as (
    select * from {{ ref('int_orders__enriched') }}

    {% if is_incremental() %}
        where order_date >= (
            select dateadd('day', -7, coalesce(max(order_date), '1992-01-01'::date))
            from {{ this }}
        )
    {% endif %}

),

aggregated_items as (
    select * from {{ ref('int_order_items__aggregated') }}
),

final as (

    select
        -- ── Keys ──────────────────────────────────────────────────────────
        o.order_key,
        o.customer_key,

        -- ── Order attributes ──────────────────────────────────────────────
        o.order_status,
        o.order_priority,
        o.clerk_id,
        o.ship_priority,
        o.is_open,
        o.is_fulfilled,
        o.is_pending,

        -- ── Date ──────────────────────────────────────────────────────────
        o.order_date,
        o.order_year,
        o.order_month,
        o.order_quarter,
        o.order_day_of_week,

        -- ── Customer snapshot (denorm) ────────────────────────────────────
        o.customer_name,
        o.market_segment,
        o.customer_account_balance,
        o.customer_nation,
        o.customer_region,

        -- ── Financials from header ─────────────────────────────────────────
        o.total_price,

        -- ── Aggregated line item financials ────────────────────────────────
        coalesce(a.total_line_items, 0)         as total_line_items,
        coalesce(a.returned_line_items, 0)      as returned_line_items,
        coalesce(a.on_time_line_items, 0)       as on_time_line_items,
        coalesce(a.total_quantity, 0)           as total_quantity,
        coalesce(a.total_extended_price, 0)     as total_extended_price,
        coalesce(a.total_net_revenue, 0)        as total_net_revenue,
        coalesce(a.total_gross_revenue, 0)      as total_gross_revenue,
        coalesce(a.total_discount_amount, 0)    as total_discount_amount,
        coalesce(a.total_tax_amount, 0)         as total_tax_amount,
        coalesce(a.total_gross_margin, 0)       as total_gross_margin,
        coalesce(a.return_rate, 0)              as return_rate,
        coalesce(a.on_time_rate, 0)             as on_time_rate,
        coalesce(a.gross_margin_rate, 0)        as gross_margin_rate,

        -- ── Ship dates ────────────────────────────────────────────────────
        a.first_ship_date,
        a.last_receipt_date,
        a.ship_modes_used,

        -- ── Metadata ──────────────────────────────────────────────────────
        current_timestamp()                     as dbt_loaded_at

    from orders           o
    left join aggregated_items a on o.order_key = a.order_key

)

select * from final
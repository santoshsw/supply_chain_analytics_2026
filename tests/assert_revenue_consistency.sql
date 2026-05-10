-- =============================================================================
-- test_revenue_consistency — SINGULAR TEST
-- Verifies sum of line-item net_price reconciles with fct_orders total_net_revenue.
-- Tolerance: 0.01% (rounding from aggregation).
-- Result rows = FAILURE. No rows = PASS.
-- =============================================================================

with line_item_total as (
    select order_key, sum(net_price) as line_item_net_revenue
    from {{ ref('fct_line_items') }}
    group by 1
),
order_total as (
    select order_key, total_net_revenue as order_net_revenue
    from {{ ref('fct_orders') }}
),
comparison as (
    select
        l.order_key,
        l.line_item_net_revenue,
        o.order_net_revenue,
        abs(l.line_item_net_revenue - o.order_net_revenue)
            / nullif(o.order_net_revenue, 0)        as relative_diff
    from line_item_total l
    join order_total     o using (order_key)
)
select * from comparison where relative_diff > 0.0001
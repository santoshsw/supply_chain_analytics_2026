-- =============================================================================
-- test_no_orphaned_line_items — SINGULAR TEST
-- Every line item must have a matching order in fct_orders.
-- Orphaned line items indicate a pipeline bug.
-- =============================================================================

select li.order_key, count(*) as orphaned_line_item_count
from {{ ref('fct_line_items') }} li
left join {{ ref('fct_orders') }} o on li.order_key = o.order_key
where o.order_key is null
group by 1
-- =============================================================================
-- test_date_spine_completeness — SINGULAR TEST
-- Every order date in fct_orders must exist in dim_dates.
-- Missing dates = date spine doesn't cover full range.
-- =============================================================================

select distinct o.order_date
from {{ ref('fct_orders') }} o
left join {{ ref('dim_dates') }} d on o.order_date = d.date_key
where d.date_key is null
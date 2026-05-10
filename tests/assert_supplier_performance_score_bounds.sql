-- =============================================================================
-- test_supplier_performance_score_bounds — SINGULAR TEST
-- Performance scores must fall within [0, 100].
-- =============================================================================

select supplier_key, supplier_name, year_month, performance_score
from {{ ref('supply_chain__supplier_performance') }}
where performance_score < 0 or performance_score > 100
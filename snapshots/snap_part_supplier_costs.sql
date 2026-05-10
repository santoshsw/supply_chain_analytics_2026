-- =============================================================================
-- snp_part_supplier_costs  —  SCD Type-2 Snapshot
-- Tracks historical supply cost changes per part–supplier pair.
-- Critical for understanding margin evolution over time.
-- =============================================================================

{% snapshot snp_part_supplier_costs %}

{{
    config(
        target_schema  = 'snapshots',
        unique_key     = 'part_supplier_key',
        strategy       = 'check',
        check_cols     = ['supply_cost', 'available_quantity'],
        invalidate_hard_deletes = true
    )
}}

select
    part_supplier_key,
    part_key,
    supplier_key,
    available_quantity,
    supply_cost,
    current_timestamp()     as snapshot_captured_at
from {{ ref('stg__part_suppliers') }}

{% endsnapshot %}
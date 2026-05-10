-- =============================================================================
-- snp_suppliers  —  SCD Type-2 Snapshot
-- Tracks changes to supplier account balance, address, and nation over time.
-- =============================================================================

{% snapshot snp_suppliers %}

{{
    config(
        target_schema  = 'snapshots',
        unique_key     = 'supplier_key',
        strategy       = 'check',
        check_cols     = ['nation_key', 'account_balance', 'address', 'phone_number'],
        invalidate_hard_deletes = true
    )
}}

select
    supplier_key,
    supplier_surrogate_key,
    supplier_name,
    address,
    phone_number,
    account_balance,
    has_negative_balance,
    nation_key,
    supplier_comment,
    current_timestamp()     as snapshot_captured_at
from {{ ref('stg__suppliers') }}

{% endsnapshot %}
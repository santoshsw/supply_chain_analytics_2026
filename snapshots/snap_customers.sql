-- =============================================================================
-- snp_customers  —  SCD Type-2 Snapshot
-- Tracks historical changes to customer attributes over time.
--
-- dbt snapshot mechanics:
--   • updated_at strategy: compares the updated_at column to detect changes.
--   • invalidate_hard_deletes: marks rows deleted from source as expired.
--   • dbt adds: dbt_scd_id, dbt_updated_at, dbt_valid_from, dbt_valid_to.
--   • A NULL dbt_valid_to means the row is current.
-- =============================================================================

{% snapshot snp_customers %}

{{
    config(
        target_schema  = 'snapshots',
        unique_key     = 'customer_key',
        strategy       = 'check',
        check_cols     = ['market_segment', 'nation_key', 'account_balance', 'address', 'phone_number'],
        invalidate_hard_deletes = true
    )
}}

select
    customer_key,
    customer_surrogate_key,
    customer_name,
    address,
    phone_number,
    market_segment,
    account_balance,
    nation_key,
    customer_comment,
    current_timestamp()     as snapshot_captured_at
from {{ ref('stg__customers') }}

{% endsnapshot %}
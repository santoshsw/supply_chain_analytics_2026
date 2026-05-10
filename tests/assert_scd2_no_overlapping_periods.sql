-- =============================================================================
-- test_scd2_no_overlapping_periods — SINGULAR TEST
-- For each customer in the SCD2 snapshot, validity windows must not overlap.
-- Overlapping windows indicate a snapshot configuration or duplicate key bug.
-- =============================================================================

with snapshot_data as (
    select
        customer_key,
        dbt_valid_from,
        coalesce(dbt_valid_to, '9999-12-31'::timestamp) as valid_to_safe
    from {{ ref('snp_customers') }}
),
overlaps as (
    select
        a.customer_key,
        a.dbt_valid_from    as a_valid_from,
        a.valid_to_safe     as a_valid_to,
        b.dbt_valid_from    as b_valid_from,
        b.valid_to_safe     as b_valid_to
    from snapshot_data a
    join snapshot_data b
        on  a.customer_key   = b.customer_key
        and a.dbt_valid_from < b.valid_to_safe
        and a.valid_to_safe  > b.dbt_valid_from
        and a.dbt_valid_from <> b.dbt_valid_from
)
select * from overlaps
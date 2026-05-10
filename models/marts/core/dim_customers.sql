-- =============================================================================
-- dim_customers
-- Layer   : Marts / Core
-- Grain   : One row per customer (current state — SCD Type-1).
-- Note    : For historical tracking see snapshots/snp_customers.sql (SCD2).
-- =============================================================================

with customers as (
    select * from {{ ref('int_customers__with_geography') }}
),

-- Segment ranking by account balance (useful for BI filters)
with_segment_rank as (

    select
        *,
        ntile(5) over (
            partition by market_segment
            order by account_balance desc
        ) as balance_quintile_in_segment

    from customers

),

final as (

    select
        -- ── Keys ──────────────────────────────────────────────────────────
        customer_key,
        customer_surrogate_key,

        -- ── Descriptive ───────────────────────────────────────────────────
        customer_name,
        address,
        phone_number,
        market_segment,
        customer_comment,

        -- ── Financial ─────────────────────────────────────────────────────
        account_balance,
        balance_quintile_in_segment,

        case
            when account_balance < 0     then 'Negative'
            when account_balance < 1000  then 'Low'
            when account_balance < 5000  then 'Medium'
            when account_balance < 9000  then 'High'
            else 'Premium'
        end                                         as account_tier,

        -- ── Geography ─────────────────────────────────────────────────────
        nation_key,
        nation_name,
        region_key,
        region_name,

        -- ── Metadata ──────────────────────────────────────────────────────
        current_timestamp()                         as dbt_loaded_at

    from with_segment_rank

)

select * from final
-- =============================================================================
-- dim_suppliers
-- Layer : Marts / Core
-- Grain : One row per supplier.
-- =============================================================================

with suppliers as (
    select * from {{ ref('int_suppliers__with_geography') }}
),

final as (

    select
        supplier_key,
        supplier_surrogate_key,
        supplier_name,
        address,
        phone_number,
        account_balance,
        has_negative_balance,
        supplier_comment,

        -- tiers
        case
            when account_balance < 0    then 'Negative'
            when account_balance < 2000 then 'Low'
            when account_balance < 6000 then 'Medium'
            else 'High'
        end                             as account_tier,

        -- geography
        nation_key,
        nation_name,
        region_key,
        region_name,

        current_timestamp()             as dbt_loaded_at

    from suppliers

)

select * from final
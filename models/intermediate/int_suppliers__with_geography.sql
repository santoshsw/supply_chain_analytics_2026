-- =============================================================================
-- int_suppliers__with_geography (ephemeral)
-- Suppliers enriched with nation + region.
-- =============================================================================

with suppliers as (
    select * from {{ ref('stg__suppliers') }}
),

nations as (
    select * from {{ ref('stg__nations') }}
),

regions as (
    select * from {{ ref('stg__regions') }}
),

final as (

    select
        s.supplier_key,
        s.supplier_surrogate_key,
        s.supplier_name,
        s.address,
        s.phone_number,
        s.account_balance,
        s.has_negative_balance,
        s.supplier_comment,

        -- geography
        n.nation_key,
        n.nation_name,
        r.region_key,
        r.region_name

    from suppliers    s
    left join nations n  on s.nation_key = n.nation_key
    left join regions r  on n.region_key = r.region_key

)

select * from final
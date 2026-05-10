-- =============================================================================
-- int_customers__with_geography (ephemeral)
-- Customers enriched with nation + region dimension data.
-- =============================================================================

with customers as (
    select * from {{ ref('stg__customers') }}
),

nations as (
    select * from {{ ref('stg__nations') }}
),

regions as (
    select * from {{ ref('stg__regions') }}
),

final as (

    select
        -- customer keys
        c.customer_key,
        c.customer_surrogate_key,
        c.customer_name,
        c.address,
        c.phone_number,
        c.market_segment,
        c.account_balance,
        c.customer_comment,

        -- geography
        n.nation_key,
        n.nation_name,
        r.region_key,
        r.region_name

    from customers    c
    left join nations n  on c.nation_key  = n.nation_key
    left join regions r  on n.region_key  = r.region_key

)

select * from final
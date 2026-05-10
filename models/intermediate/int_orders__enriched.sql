-- =============================================================================
-- int_orders__enriched (ephemeral)
-- Orders joined to enriched customers. Foundation for order-centric marts.
-- =============================================================================

with orders as (
    select * from {{ ref('stg__orders') }}
),

customers as (
    select * from {{ ref('int_customers__with_geography') }}
),

final as (

    select
        -- order grain
        o.order_key,
        o.customer_key,
        o.order_status,
        o.order_priority,
        o.clerk_id,
        o.ship_priority,
        o.total_price,
        o.order_date,
        o.order_year,
        o.order_month,
        o.order_quarter,
        o.order_day_of_week,
        o.is_open,
        o.is_fulfilled,
        o.is_pending,
        o.order_comment,

        -- customer dimensions (denormalized for mart convenience)
        c.customer_name,
        c.market_segment,
        c.account_balance                   as customer_account_balance,
        c.nation_key,
        c.nation_name                       as customer_nation,
        c.region_key,
        c.region_name                       as customer_region

    from orders   o
    left join customers c on o.customer_key = c.customer_key

)

select * from final
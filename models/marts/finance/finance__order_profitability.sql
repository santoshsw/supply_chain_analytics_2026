-- =============================================================================
-- finance__order_profitability
-- Layer : Marts / Finance
-- Grain : One row per order with full profitability metrics.
-- =============================================================================

{{
    config(
        materialized = 'table',
        cluster_by   = ['order_date'],
        tags         = ['finance']
    )
}}

with orders as (
    select * from {{ ref('fct_orders') }}
),

final as (

    select
        order_key,
        customer_key,
        customer_name,
        market_segment,
        customer_nation,
        customer_region,

        order_date,
        order_year,
        order_month,
        order_quarter,
        order_status,
        order_priority,

        -- revenue
        total_price                         as header_total_price,
        total_net_revenue,
        total_gross_revenue,
        total_extended_price,

        -- cost & margin
        total_gross_margin,
        gross_margin_rate,

        -- discounts
        total_discount_amount,
        round(
            total_discount_amount / nullif(total_extended_price, 0), 4
        )                                   as effective_discount_rate,

        -- volume
        total_line_items,
        total_quantity,

        -- quality
        return_rate,
        on_time_rate,
        returned_line_items,

        -- classification
        case
            when gross_margin_rate >= 0.3  then 'High Margin'
            when gross_margin_rate >= 0.15 then 'Medium Margin'
            when gross_margin_rate >= 0    then 'Low Margin'
            else 'Unprofitable'
        end                                 as profitability_tier,

        case
            when total_net_revenue >= 200000 then 'Large'
            when total_net_revenue >= 50000  then 'Medium'
            else 'Small'
        end                                 as order_size_tier

    from orders

)

select * from final
-- =============================================================================
-- finance__revenue_by_segment
-- Layer : Marts / Finance
-- Grain : Year-month × market segment × region
-- =============================================================================

{{
    config(
        materialized = 'table',
        cluster_by   = ['year_month'],
        tags         = ['finance', 'aggregated']
    )
}}

with line_items as (
    select * from {{ ref('fct_line_items') }}
),

aggregated as (

    select
        -- time
        order_year                          as year,
        order_month                         as month,
        order_quarter                       as quarter,
        to_varchar(order_year)
            || '-'
            || lpad(to_varchar(order_month), 2, '0') as year_month,
                            
        -- dimensions
        market_segment,
        customer_region,
        customer_nation,
        ship_mode,

        -- volume
        count(distinct order_key)           as order_count,
        count(*)                            as line_item_count,
        sum(quantity)                       as total_quantity,

        -- revenue
        sum(extended_price)                 as total_extended_price,
        sum(net_price)                      as total_net_revenue,
        sum(gross_price)                    as total_gross_revenue,

        -- discounts and tax
        sum(discount_amount)                as total_discount_amount,
        sum(tax_amount)                     as total_tax_amount,

        -- profitability
        sum(gross_margin)                   as total_gross_margin,
        round(
            sum(gross_margin) / nullif(sum(net_price), 0), 4
        )                                   as gross_margin_rate,

        -- returns
        sum(case when is_returned then net_price else 0 end) as returned_revenue,
        round(
            sum(case when is_returned then 1 else 0 end)::float / count(*), 4
        )                                   as return_rate,

        -- on-time
        round(
            sum(case when is_on_time then 1 else 0 end)::float / count(*), 4
        )                                   as on_time_delivery_rate

    from line_items
    group by 1, 2, 3, 4, 5, 6, 7, 8

)

select * from aggregated
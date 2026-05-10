-- =============================================================================
-- int_order_items__aggregated (ephemeral)
-- Order-level aggregation of line items. Pre-computes stats reused by multiple
-- mart models to avoid redundant aggregation.
-- =============================================================================

with enriched as (
    select * from {{ ref('int_line_items__enriched') }}
),

aggregated as (

    select
        order_key,

        -- counts
        count(*)                            as total_line_items,
        count(case when is_returned then 1 end)     as returned_line_items,
        count(case when is_fulfilled then 1 end)    as fulfilled_line_items,
        count(case when is_on_time then 1 end)      as on_time_line_items,

        -- quantities
        sum(quantity)                       as total_quantity,

        -- revenue
        sum(extended_price)                 as total_extended_price,
        sum(net_price)                      as total_net_revenue,
        sum(gross_price)                    as total_gross_revenue,
        sum(discount_amount)                as total_discount_amount,
        sum(tax_amount)                     as total_tax_amount,
        sum(gross_margin)                   as total_gross_margin,

        -- rates
        round(
            count(case when is_returned then 1 end)::float
            / nullif(count(*), 0), 4
        )                                   as return_rate,

        round(
            count(case when is_on_time then 1 end)::float
            / nullif(count(*), 0), 4
        )                                   as on_time_rate,

        round(
            sum(gross_margin)
            / nullif(sum(net_price), 0), 4
        )                                   as gross_margin_rate,

        -- date extremes
        min(ship_date)                      as first_ship_date,
        max(receipt_date)                   as last_receipt_date,

        -- ship modes used in this order (array for advanced analytics)
        array_agg(distinct ship_mode)       as ship_modes_used

    from enriched
    group by 1

)

select * from aggregated
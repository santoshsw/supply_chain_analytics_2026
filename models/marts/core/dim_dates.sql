-- =============================================================================
-- dim_dates
-- Layer   : Marts / Core
-- Grain   : One row per calendar date.
-- Range   : 1992-01-01 → 1998-12-31 (TPC-H data window + buffer).
-- Generated via dbt_utils.date_spine — no source dependency.
-- =============================================================================

{{
    config(
        materialized = 'table',
        tags         = ['dimension', 'date']
    )
}}

with date_spine as (

    {{
        dbt_utils.date_spine(
            datepart   = "day",
            start_date = "cast('1992-01-01' as date)",
            end_date   = "cast('1999-01-01' as date)"
        )
    }}

),

final as (

    select
        -- ── Key ───────────────────────────────────────────────────────────
        cast(date_day as date)                      as date_key,

        -- ── Calendar ──────────────────────────────────────────────────────
        year(date_day)                              as year,
        quarter(date_day)                           as quarter_number,
        month(date_day)                             as month_number,
        day(date_day)                               as day_of_month,
        dayofweek(date_day)                         as day_of_week,      -- 0=Sun
        dayofyear(date_day)                         as day_of_year,
        weekofyear(date_day)                        as week_of_year,

        -- ── Labels ────────────────────────────────────────────────────────
        to_char(date_day, 'MMMM')                   as month_name,
        to_char(date_day, 'MON')                    as month_short,
        to_char(date_day, 'DY')                     as day_short,
        'Q' || quarter(date_day)                    as quarter_label,
        year(date_day) || '-Q' || quarter(date_day) as year_quarter,
        to_char(date_day, 'YYYY-MM')                as year_month,

        -- ── Boolean flags ─────────────────────────────────────────────────
        (dayofweek(date_day) in (0, 6))::boolean    as is_weekend,
        (dayofweek(date_day) not in (0, 6))::boolean as is_weekday,
        (month(date_day) = 12 and day(date_day) = 31)::boolean as is_year_end,
        (month(date_day) = 1  and day(date_day) = 1 )::boolean as is_year_start,

        -- ── Relative to "today" (useful for dbt tests) ────────────────────
        datediff('day', cast(date_day as date), current_date()) as days_from_today,

        -- ── ISO fields ────────────────────────────────────────────────────
        yearofweekiso(date_day)                     as iso_year,
        weekiso(date_day)                           as iso_week

    from date_spine

)

select * from final
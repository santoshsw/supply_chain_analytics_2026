-- =============================================================================
-- INCREMENTAL HELPER MACROS
-- =============================================================================

-- get_max_watermark: returns max watermark column from incremental table
-- Usage: where event_date > {{ get_max_watermark('event_date', '1992-01-01') }}
{% macro get_max_watermark(column_name, fallback='1900-01-01') %}
    {% if is_incremental() %}
        (select coalesce(max({{ column_name }}), '{{ fallback }}'::date) from {{ this }})
    {% else %}
        '{{ fallback }}'::date
    {% endif %}
{% endmacro %}

-- incremental_lookback: WHERE clause with lookback window for late data
-- Usage: {{ incremental_lookback('ship_date', lookback_days=3) }}
{% macro incremental_lookback(date_column, lookback_days=3, fallback='1992-01-01') %}
    {% if is_incremental() %}
        where {{ date_column }} >= (
            select dateadd('day', -{{ lookback_days }},
                coalesce(max({{ date_column }}), '{{ fallback }}'::date)
            )
            from {{ this }}
        )
    {% endif %}
{% endmacro %}
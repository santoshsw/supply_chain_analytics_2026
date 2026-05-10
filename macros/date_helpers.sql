-- =============================================================================
-- date_trunc_to_period
-- Truncates a date column to a given period (month, quarter, year, week).
-- Returns a consistent date type across databases.
-- Usage: {{ date_trunc_to_period('order_date', 'month') }}
-- =============================================================================

{% macro date_trunc_to_period(date_column, period) %}
    date_trunc('{{ period }}', {{ date_column }})::date
{% endmacro %}


-- =============================================================================
-- fiscal_year
-- Returns the fiscal year for a date given a fiscal year start month.
-- Default: fiscal year starts in January (calendar year).
-- Usage: {{ fiscal_year('order_date', start_month=4) }}   -- April FY start
-- =============================================================================

{% macro fiscal_year(date_column, start_month=1) %}
    {% if start_month == 1 %}
        year({{ date_column }})
    {% else %}
        case
            when month({{ date_column }}) >= {{ start_month }}
                then year({{ date_column }})
            else year({{ date_column }}) - 1
        end
    {% endif %}
{% endmacro %}
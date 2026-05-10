-- =============================================================================
-- cents_to_dollars
-- Converts an integer cent amount to a decimal dollar amount.
-- Usage: {{ cents_to_dollars('column_name') }}
--        {{ cents_to_dollars('column_name', scale=4) }}
-- =============================================================================

{% macro cents_to_dollars(column_name, scale=2) %}
    try_to_decimal({{ column_name }} / 100, 18, {{ scale }})
{% endmacro %}

 
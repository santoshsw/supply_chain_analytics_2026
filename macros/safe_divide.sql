-- safe_divide: division that returns null (or default) instead of /0 error
-- Usage: {{ safe_divide('revenue', 'orders') }}
--        {{ safe_divide('revenue', 'orders', default=0) }}
{% macro safe_divide(numerator, denominator, default='null') %}
    case
        when {{ denominator }} = 0 or {{ denominator }} is null then {{ default }}
        else {{ numerator }}::float / {{ denominator }}
    end
{% endmacro %}
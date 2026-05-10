-- =============================================================================
-- PIVOT / DYNAMIC COLUMN HELPERS
-- =============================================================================

-- get_market_segments: returns known segment list as Jinja list
{% macro get_market_segments() %}
    {% set segments = ['AUTOMOBILE','BUILDING','FURNITURE','HOUSEHOLD','MACHINERY'] %}
    {{ return(segments) }}
{% endmacro %}

-- pivot_revenue_by_segment: generates CASE expressions for pivoting revenue
-- Usage: {{ pivot_revenue_by_segment('net_price') }}
{% macro pivot_revenue_by_segment(revenue_column='net_price') %}
    {% set segments = get_market_segments() %}
    {% for seg in segments %}
        sum(case when market_segment = '{{ seg }}' then {{ revenue_column }} else 0 end)
            as revenue_{{ seg | lower }}
        {%- if not loop.last %},{% endif %}
    {% endfor %}
{% endmacro %}

-- union_relations: unions a list of relations
-- Usage: {{ union_relations([ref('a'), ref('b')]) }}
{% macro union_relations(relations) %}
    {% for relation in relations %}
        select * from {{ relation }}
        {%- if not loop.last %} union all {% endif %}
    {% endfor %}
{% endmacro %}
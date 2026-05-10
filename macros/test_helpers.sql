-- =============================================================================
-- CUSTOM GENERIC TEST MACROS
-- Usable as schema tests in .yml files via the test name.
-- =============================================================================

-- assert_column_is_positive: fails if any value <= 0
{% test assert_column_is_positive(model, column_name) %}
    select * from {{ model }} where {{ column_name }} <= 0
{% endtest %}

-- assert_no_future_dates: fails if any date is in the future
{% test assert_no_future_dates(model, column_name) %}
    select * from {{ model }} where {{ column_name }} > current_date()
{% endtest %}

-- assert_valid_percentage: fails if any value is outside [0, 1]
{% test assert_valid_percentage(model, column_name) %}
    select * from {{ model }}
    where {{ column_name }} < 0 or {{ column_name }} > 1
{% endtest %}

-- assert_referential_integrity: explicit FK check
-- Usage:
--   - assert_referential_integrity:
--       parent_model: ref('dim_customers')
--       parent_column: customer_key
{% test assert_referential_integrity(model, column_name, parent_model, parent_column) %}
    select child.*
    from {{ model }} child
    left join {{ parent_model }} parent
        on child.{{ column_name }} = parent.{{ parent_column }}
    where parent.{{ parent_column }} is null
{% endtest %}

-- assert_row_count_above_threshold: fails if model has fewer rows than expected
{% test assert_row_count_above_threshold(model, threshold) %}
    select count(*) as actual_count
    from {{ model }}
    having count(*) < {{ threshold }}
{% endtest %}

-- assert_column_not_constant: fails if all values in a column are identical
{% test assert_column_not_constant(model, column_name) %}
    select count(distinct {{ column_name }}) as distinct_count
    from {{ model }}
    having count(distinct {{ column_name }}) <= 1
{% endtest %}
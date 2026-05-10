
-- =============================================================================
-- generate_schema_name  (overrides dbt default)
--
-- Custom schema naming strategy:
--   • In production: use the configured schema name exactly as-is.
--   • In dev/ci:     prefix with the target name to isolate environments.
--
-- Result examples:
--   prod + schema=marts_core    → ANALYTICS.MARTS_CORE
--   dev  + schema=marts_core    → ANALYTICS.DEV_MARTS_CORE
--   ci   + schema=staging       → ANALYTICS.CI_12345_STAGING
-- =============================================================================

{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}

    {%- if custom_schema_name is none -%}
        {{ default_schema }}

    {%- else -%}
       {{ custom_schema_name | trim  }}

    {%- endif -%}

{%- endmacro %}
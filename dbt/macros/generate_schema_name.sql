{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set base = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ base }}
    {%- elif target.name == 'prod' -%}
        {{ custom_schema_name | trim }}
    {%- else -%}
        {{ base }}_{{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
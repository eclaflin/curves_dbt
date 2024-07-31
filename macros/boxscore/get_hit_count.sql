{% macro get_hit_count(event) %}

{% set hit_events = ["'single'", "'double'", "'triple'", "'home_run'"] %}

    case
        when {{ event }} in ( {{ hit_events | join(', ') }} )
        then 1
        else 0
    end

{% endmacro %}
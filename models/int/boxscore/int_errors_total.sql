{{ config(
    materialized="view"
    )
}}

with statcast_pitch as (
    select
        *
    from
        {{ ref('stg_statcast__statcast_pitch') }}
),

err_ttl as (
    select
        game_pk,
        inning_topbot,
        sum(
            case
                when events = 'field_error' then 1
                else 0
            end
        ) as team_errors
    from
        statcast_pitch
    group by
        game_pk,
        inning_topbot
)

select
    *
from
    err_ttl
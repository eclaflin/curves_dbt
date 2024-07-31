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

hit_ttl as (
    select
        game_pk,
        inning_topbot,
        sum({{ get_hit_count('events') }}) as team_hits
    from
        statcast_pitch
    group by
        game_pk,
        inning_topbot
)

select
    *
from
    hit_ttl
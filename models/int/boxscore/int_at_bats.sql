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

-- find the last pitch_id for each frame (half inning)
max_id_at_bat as (
    select
        sp.game_pk,
        sp.at_bat_number,
        max(sp.id) as max_id
    from
        statcast_pitch sp
    group by
        sp.game_pk,
        sp.at_bat_number
)

select
    sp.*
from
    max_id_at_bat mid_ab
        inner join
    statcast_pitch sp on sp.id = mid_ab.max_id
order by
    mid_ab.game_pk,
    mid_ab.max_id,
    sp.batter

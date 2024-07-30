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
max_id_frame as (
    select
        sp.game_pk,
        sp.inning,
        sp.inning_topbot,
        max(sp.id) as max_id
    from
        statcast_pitch sp
    group by
        sp.game_pk,
        sp.inning,
        sp.inning_topbot
)

select
    midf.game_pk,
    midf.inning,
    midf.inning_topbot,
    sp.post_home_score,
    sp.post_away_score
from
    max_id_frame midf
        inner join
    statcast_pitch sp on sp.id = midf.max_id
order by
    inning,
    inning_topbot desc
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
        -- TODO: this breaks if autoincrementing pk isn't consecutive
        max(sp.id) as max_id
    from
        statcast_pitch sp
    group by
        sp.game_pk,
        sp.inning,
        sp.inning_topbot
)

select
    midf.max_id as frame_ending_pitch_id,
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
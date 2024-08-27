{{ config(
    materialized="table"
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
),

lagd as (
    select
        midf.max_id as frame_ending_pitch_id,
        midf.game_pk,
        midf.inning,
        midf.inning_topbot,
        sp.post_home_score,
        sp.post_away_score,
        sp.post_home_score - lag(sp.post_home_score,1) over (
            partition by sp.game_pk, sp.inning_topbot order by sp.inning
        ) as home_runs_scored,
        sp.post_away_score - lag(sp.post_away_score,1) over (
            partition by sp.game_pk, sp.inning_topbot order by sp.inning
        ) as away_runs_scored
    from
        max_id_frame midf
            inner join
        statcast_pitch sp on sp.id = midf.max_id
    order by
        inning,
        inning_topbot desc
),

-- adjust to not count runs scored in an inning where the team wasn't at bat
adj as (
    select
        frame_ending_pitch_id,
        game_pk,
        inning,
        inning_topbot,
        case
            when inning_topbot = 'Top' then coalesce(away_runs_scored,0)
            else 0
        end as away_runs_scored,
        case
            when inning_topbot = 'Bot' then coalesce(home_runs_scored,0)
            else 0
        end as home_runs_scored
    from
        lagd
)

select *
from adj

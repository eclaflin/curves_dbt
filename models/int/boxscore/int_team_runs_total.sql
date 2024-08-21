{{ config(
    materialized="view"
    )
}}

with score_line as (
    select
        *
    from
        {{ ref("int_team_score_line") }}
),

run_totals as (
    select
        game_pk,
        sum(home_runs_scored) as home_runs_scored,
        sum(away_runs_scored) as away_runs_scored
    from
        score_line
    group by
        game_pk
)

select
    *
from
    run_totals
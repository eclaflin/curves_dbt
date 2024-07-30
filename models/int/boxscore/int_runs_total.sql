{{ config(
    materialized="view"
    )
}}

with score_line as (
    select
        *
    from
        {{ ref('int_score_line') }}
),

run_totals as (
    select
        game_pk,
        sum(post_home_score) as home_runs_scored,
        sum(post_away_score) as away_runs_scored
    from
        score_line
    group by
        game_pk
)

select
    *
from
    run_totals
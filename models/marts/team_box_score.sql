with scrln_top as (
    select
        game_pk,
        inning_topbot,
        {{ dbt_utils.pivot(
            'inning',
            dbt_utils.get_column_values(
                ref('int_team_score_line'),
                'inning'
            ),
            agg='sum',
            then_value='away_runs_scored'
        ) }}
    from
        {{ ref('int_team_score_line') }}
    where
        inning_topbot = 'Top'
    group by
        game_pk,
        inning_topbot
),

scrln_bottom as (
    select
        game_pk,
        inning_topbot,
        {{ dbt_utils.pivot(
            'inning',
            dbt_utils.get_column_values(
                ref('int_team_score_line'),
                'inning'
            ),
            agg='sum',
            then_value='home_runs_scored'
        ) }}
    from
        {{ ref('int_team_score_line') }}
    where
        inning_topbot = 'Bot'
    group by
        game_pk,
        inning_topbot
),

runs as (
    select
        *
    from
        {{ ref('int_team_runs_total') }}
),

hits as (
    select
        *
    from
        {{ ref('int_team_hits_total') }}
),

errs as (
    select
        *
    from
        {{ ref('int_team_errors_total') }}
),

unioned as (
    select
        *
    from
        scrln_top
            union all
    select
        *
    from
        scrln_bottom
),

joined as (
    select
        unioned.*,
        case
            when unioned.inning_topbot = 'Top' then runs.away_runs_scored
            when unioned.inning_topbot = 'Bot' then runs.home_runs_scored
            else null
        end as runs,
        hits.team_hits,
        errs.team_errors
    from
        unioned
            left join
        runs on runs.game_pk = unioned.game_pk
            left join
        hits on hits.game_pk = unioned.game_pk
                and hits.inning_topbot = unioned.inning_topbot
            left join
        errs on errs.game_pk = unioned.game_pk
                and errs.inning_topbot = unioned.inning_topbot
)

select * from joined
order by game_pk, inning_topbot desc
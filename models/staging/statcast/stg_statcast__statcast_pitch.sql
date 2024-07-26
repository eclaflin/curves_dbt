with pitch as (
    select
        *
    from
        {{ source('statcast','statcast_pitch') }}
)

select
    *
from
    pitch

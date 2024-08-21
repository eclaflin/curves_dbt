## Statcast Pitch ID

- `mydatabase.staging.statcast_pitch.id` is generated as auto-incrementing pk in the loader in `curves`:

```python
# curves/models/statcast_pitch_day_models.py
from sqlalchemy import Column, Integer, String, Date, Numeric
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()


class PitchDTO(Base):
    __tablename__ = 'statcast_pitch'
    
    id = Column(Integer, primary_key=True, autoincrement=True)

    pitch_type = Column(String)
    
# [...]
```

- However, this was loaded into staging db via cloning the data in `mydatabase.public`
  - In the public schema, can confirm it's a auto-incrementing pk per `mydatabase.information_schema`:
  
```sql
SELECT 
    table_schema, 
    table_name, 
    is_nullable, 
    data_type
FROM information_schema.columns
WHERE
    table_name = 'statcast_pitch'
        AND column_name = 'id';
```

| table\_schema | table\_name | is\_nullable | data\_type |
| :--- | :--- | :--- | :--- |
| staging | statcast\_pitch | YES | integer |
| public | statcast\_pitch | NO | integer |

- This context may or may not matter
- What does matter: it was assumed that rows of `statcast_pitch` would be loaded sequentially
  - In this way the primary key would be sequential from each pitch from first at-bat/first-inning to final out
- We can see that this is not the case:

```sql
select
    id,
    inning,
    inning_topbot,
    pitch_number,
    at_bat_number
from
    staging.statcast_pitch where game_pk = '745266'
order by id asc
limit 5
```

| id | inning | inning\_topbot | pitch\_number | at\_bat\_number |
| :--- | :--- | :--- | :--- | :--- |
| 140584 | 9 | Top | 5 | 62 |
| 140585 | 9 | Top | 4 | 62 |
| 140586 | 9 | Top | 3 | 62 |
| 140587 | 9 | Top | 2 | 62 |
| 140588 | 9 | Top | 1 | 62 |

- In this way, it's exactly the opposite of how it was assumed
- However, while we do see *instances* of it being ***exactly*** opposite of assumed, we can't validate that it is *always* the opposite (i.e. we can't just assume we can rely on the reverse)

<script src="https://gist.github.com/eclaflin/3521e24bd529550ec70d52d6696049bf.js"></script>

| count |
| :--- |
| 1381 |

- Leads us to believe that we need to fix this at the source and add to the extractor in `curves/extractor/extract_statcast_pitch_day.py` 
- This should to handle or ordering of Statcast pitch data to ensure that the ID being created is perfectly sequential, at least within any given game
  - There's probably value to doing to make sure that id is sequential by date (i.e. from one game_pk to the next)


select
    date_trunc('week', dates.d) as "weekStart"
from generate_series('2023-01-01'::date, '2043-12-31'::date, '1 week'::interval) as dates(d)
group by 1
order by 1
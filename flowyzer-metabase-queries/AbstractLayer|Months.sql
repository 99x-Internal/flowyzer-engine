select *, to_char(month, 'Month YYYY') as "displayMonth"
from (
    select
        date_trunc('month', dates.d) as "month"
    from generate_series('2023-01-01'::date, '2043-12-31'::date, '1 month'::interval) as dates(d)
    group by 1
    order by 1
) AS d
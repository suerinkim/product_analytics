
-- retained
WITH monthly_activity as (
    SELECT DISTINCT
        DATE_TRUNC('month', Reporting_Date) as month, uuid_hash
    FROM public.dish_activity 
    WHERE Reporting_Date > '2017-11-30')
SELECT
    DISTINCT this_month.month, count(distinct this_month.uuid_hash) as retained
FROM monthly_activity this_month
JOIN monthly_activity last_month
    ON this_month.uuid_hash = last_month.uuid_hash
    AND this_month.month = ADD_MONTHS(last_month.month, 1)
GROUP BY this_month.month
ORDER BY this_month.month

-- churned
WITH monthly_activity as (
    SELECT DISTINCT 
        DATE_TRUNC('month', reporting_date) as month, uuid_hash
    FROM public.dish_activity 
    WHERE reporting_date > '2017-11-30')
SELECT
  ADD_MONTHS(last_month.month,1),
  -1*count(distinct last_month.uuid_hash) as churned
FROM monthly_activity last_month
LEFT JOIN monthly_activity this_month
  ON this_month.uuid_hash = last_month.uuid_hash
  AND this_month.month = ADD_MONTHS(last_month.month,1)
WHERE this_month.UUID_HASH is null
GROUP BY 1
ORDER BY 1

-- resurrected
WITH monthly_activity AS (
    SELECT DISTINCT 
        DATE_TRUNC('month', reporting_date) as month, uuid_hash
    FROM public.dish_activity 
    WHERE reporting_date > '2017-10-31'
),
first_activity AS (
    SELECT DISTINCT uuid_hash, MIN(reporting_date) AS month
    FROM public.dish_activity
    WHERE reporting_date > '2017-11-30'
    GROUP BY 1
    ORDER BY 1
)
SELECT
  this_month.month as month,
  COUNT(distinct this_month.uuid_hash) AS new
FROM monthly_activity this_month
LEFT JOIN monthly_activity last_month
  ON this_month.uuid_hash = last_month.uuid_hash
  AND this_month.month = ADD_MONTHS(last_month.month,1)
JOIN first_activity
  ON this_month.uuid_hash = first_activity.uuid_hash
  AND first_activity.month = this_month.month
WHERE last_month.uuid_hash is null
GROUP BY 1
ORDER BY 1

-- new
WITH monthly_activity AS (
    SELECT DISTINCT 
        DATE_TRUNC('month', reporting_date) as month, uuid_hash
    FROM public.dish_activity 
    WHERE reporting_date > '2017-10-31'
),
first_activity AS (
    SELECT DISTINCT uuid_hash, min(reporting_date) as month
    FROM public.dish_activity
    WHERE reporting_date > '2017-11-30'
    GROUP BY 1
    ORDER BY 1
)
SELECT
  this_month.month AS month,
  COUNT(DISTINCT this_month.uuid_hash) AS new
FROM monthly_activity this_month
LEFT JOIN monthly_activity last_month
  ON this_month.uuid_hash = last_month.uuid_hash
  AND this_month.month = ADD_MONTHS(last_month.month,1)
JOIN first_activity
  ON this_month.uuid_hash = first_activity.uuid_hash
  AND first_activity.month = this_month.month
WHERE last_month.uuid_hash is null
GROUP BY 1
ORDER BY 1

/* 
SELECT
    COALESCE(a.month,b.month) as month_final,
    "New",
    Retained,
    Resurrected,
    Churned
FROM
    (
SELECT
        month,
        sum("new") AS "New",
        sum(retained) AS Retained,
        sum(resurrected) AS Resurrected
    FROM
        (
    SELECT
            uuid_hash,
            DATE_TRUNC('month', reporting_date) as month,
            extract(year from month) * 12 + extract(month from month) as YEAR_MONTH_INT,
            min(YEAR_MONTH_INT) over (partition by uuid_hash) as first_join,
            lag(YEAR_MONTH_INT) over (partition by uuid_hash order by YEAR_MONTH_INT) as month_before,
            case when first_join = YEAR_MONTH_INT then 1 else 0 end as "new",
            case when month_before + 1 = YEAR_MONTH_INT then 1 else 0 end as retained,
            1 - retained  -  "new" as resurrected
        FROM
            dish_activity
        WHERE  uuid_hash is not null
        GROUP BY 
    uuid_hash,
    YEAR_MONTH_INT,
    month
    ) d
    GROUP BY month
 ) a
    full join
    (
   SELECT
        month,
        sum(churned) as churned
    FROM
        (
    SELECT
            uuid_hash,
            ADD_MONTHS(DATE_TRUNC('month', reporting_date),1) as month,
            extract(year from reporting_date) * 12 + extract(month from reporting_date) as YEAR_MONTH_INT,
            lead(YEAR_MONTH_INT) over (partition by uuid_hash order by YEAR_MONTH_INT) as month_after,
            case when month_after - 1 = YEAR_MONTH_INT then 0 else 1 end as churned
        FROM
            dish_activity
        WHERE reporting_date > '2017-11-30' and uuid_hash is not null
        GROUP BY 
    uuid_hash,
    YEAR_MONTH_INT,
    month
    ) c
    GROUP BY month
) b
    on a.month=b.month

WHERE month_final BETWEEN '2017-12-31' AND '2020-01-31'
ORDER by month_final
*/
 

-- this number does not match new users in growth accounting

WITH cohort_dfn_by_month_first_activity AS (
    SELECT uuid_hash, DATE_TRUNC('month', MIN(reporting_date)) AS cohort
    FROM public.dish_activity                                          
    GROUP BY 1
    HAVING cohort > '2019-10-31'
    ),
    retention_by_user_by_month AS (
    SELECT uuid_hash, 
DATE_TRUNC('month', reporting_date) AS months_active,
COUNT(*) as visits
    FROM public.dish_activity
    WHERE reporting_date > '2019-10-31'
    GROUP BY 1,2
    )
SELECT cohort,
        m.months_active AS months_actual,
        RANK() OVER (PARTITION BY cohort ORDER BY months_active ASC)-1 
        AS month_rank,
        COUNT(DISTINCT(c.uuid_hash)) AS active_users
FROM cohort_dfn_by_month_first_activity c
JOIN retention_by_user_by_month m
ON c.uuid_hash = m.uuid_hash
GROUP BY 1,2
ORDER BY 1,2
                       
/* ALTERNATIVE 
SELECT
  cohort,
  actual_month,
  month_rank,
  COUNT( *)  as active_users
  FROM
    (
    SELECT 
    uuid_hash,
    DATE_TRUNC('month', reporting_date) AS actual_month,
    min(actual_month) over (partition by uuid_hash) as cohort,
    (extract( year from actual_month ) * 12 + extract( month from actual_month )) -
    (extract( year from cohort ) * 12 + extract( month from cohort ))   as month_rank
    FROM
        dish_activity
    GROUP BY 
    uuid_hash,
    actual_month
    ) a
  WHERE cohort > '2019-10-31'
  GROUP BY
  cohort,
  actual_month,
  month_rank
  ORDER BY
  cohort,
  actual_month */                  

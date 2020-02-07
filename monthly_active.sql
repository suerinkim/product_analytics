WITH dau_table AS (
  SELECT reporting_date:: DATE as dt, 
         count(distinct uuid_hash) AS dau
  FROM public.dish_activity
  WHERE reporting_date > '2019-12-31'
  GROUP BY 1
  )
SELECT a.dt, 
       a.dau ,
       count(distinct uuid_hash) as mau,
       count(distinct case when reporting_date:: DATE BETWEEN a.dt - 7 AND a.dt then uuid_hash end) as wau
        FROM public.dish_activity,
             dau_table a
        WHERE reporting_date:: DATE BETWEEN a.dt - 28 AND a.dt 
        GROUP BY a.dt, a.dau 

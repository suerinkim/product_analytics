## count of distinct users who were active segmented by # of months active in 2019
SELECT DISTINCT months_active_per_year, COUNT(DISTINCT uuid_hash)
FROM
(SELECT uuid_hash, SUM(active_status) AS months_active_per_year
FROM
(SELECT uuid_hash, 
    DATE_TRUNC('month', reporting_date) AS months_active,
    1 as active_status
FROM public.dish_activity
WHERE reporting_date BETWEEN '2019-01-01' AND '2019-12-31'
GROUP BY 1,2)
GROUP BY 1)
GROUP BY 1
ORDER BY 1

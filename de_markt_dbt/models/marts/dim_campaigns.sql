{{ config( materialized='table', schema='dm_marts') }}

SELECT
campaign_id,
channel,
campaign_name,
start_date,
end_date,
budget,
CASE
    WHEN end_date >= start_date THEN DATE_DIFF('day', start_date, end_date)
    ELSE NULL  -- or 0 if you prefer
END AS duration_days
FROM {{ ref('stg_campaigns') }}
{{ config( materialized='table', schema='dm_marts') }}

SELECT
campaign_id,
channel,
TRIM(campaign_name) AS campaign_name,  -- Clean whitespace
start_date,
end_date,
budget::DECIMAL(12,2) AS budget,  -- Ensure consistent numeric format
CASE
    WHEN end_date >= start_date THEN DATE_DIFF('day', start_date, end_date) + 1  -- Inclusive count
    ELSE NULL
END AS duration_days,
CASE
    WHEN end_date >= CURRENT_DATE THEN 'Active'
    WHEN end_date < CURRENT_DATE THEN 'Ended'
    ELSE 'Unknown'
END AS status,
EXTRACT(YEAR FROM start_date) AS start_year,
EXTRACT(QUARTER FROM start_date) AS start_quarter
FROM {{ ref('stg_campaigns') }}
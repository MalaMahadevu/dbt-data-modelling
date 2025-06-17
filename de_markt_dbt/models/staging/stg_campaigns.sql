{{ config(materialized='view', schema='dm_staging') }}


SELECT
    campaign_id,
    TRIM(channel) AS channel,
    TRIM(campaign_name) AS campaign_name,
    CASE 
        WHEN start_date ~ '^\d{4}-\d{2}-\d{2}$' THEN CAST(start_date AS DATE) 
        ELSE NULL 
    END AS start_date,
    CASE 
        WHEN end_date ~ '^\d{4}-\d{2}-\d{2}$' THEN CAST(end_date AS DATE) 
        ELSE NULL 
    END AS end_date,
    budget
FROM {{ source('main', 'campaigns') }}
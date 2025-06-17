{{ config(materialized='view', schema='dm_staging') }}


SELECT
    campaign_id,
    TRIM(channel) AS channel,
    TRIM(campaign_name) AS campaign_name,
    CASE 
        WHEN start_date ~ '^\d{2}\.\d{2}\.\d{4}' THEN 
            CAST(SUBSTRING(start_date, 7, 4) || '-' || 
                SUBSTRING(start_date, 4, 2) || '-' || 
                SUBSTRING(start_date, 1, 2) AS DATE)
        WHEN start_date ~ '^\d{4}-\d{2}-\d{2}$' THEN CAST(start_date AS DATE)
        ELSE NULL 
    END AS start_date,
    CASE 
        WHEN end_date ~ '^\d{2}\.\d{2}\.\d{4}' THEN 
            CAST(SUBSTRING(end_date, 7, 4) || '-' || 
                SUBSTRING(end_date, 4, 2) || '-' || 
                SUBSTRING(end_date, 1, 2) AS DATE)
        WHEN end_date ~ '^\d{4}-\d{2}-\d{2}$' THEN CAST(end_date AS DATE)
        ELSE NULL 
    END AS end_date,
    budget
FROM {{ source('main', 'campaigns') }}
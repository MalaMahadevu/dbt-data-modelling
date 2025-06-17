{{ config(materialized='view', schema='dm_staging') }}
SELECT
    lead_id,
    campaign_id,
    CASE 
        WHEN created_at ~ '^\d{2}\.\d{2}\.\d{4} \d{2}:\d{2}$' THEN 
            CAST(SUBSTRING(created_at, 7, 4) || '-' || 
            SUBSTRING(created_at, 4, 2) || '-' || 
            SUBSTRING(created_at, 1, 2) AS DATE)
        ELSE NULL 
    END AS created_at,
    TRIM(lead_type) AS lead_type
FROM {{ source('main', 'leads') }}
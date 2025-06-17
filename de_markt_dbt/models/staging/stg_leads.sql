{{ config(materialized='view', schema='dm_staging') }}
SELECT
    lead_id,
    campaign_id,
    CASE 
        WHEN created_at ~ '^\d{4}-\d{2}-\d{2}$' THEN CAST(created_at AS DATE) 
        ELSE NULL 
    END AS created_at,
    TRIM(lead_type) AS lead_type
FROM {{ source('main', 'leads') }}
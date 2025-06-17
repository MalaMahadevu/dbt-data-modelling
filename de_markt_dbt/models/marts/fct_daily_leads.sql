{{config( materialized='table', schema='dm_marts'  ) }}

SELECT
l.created_at AS date,
c.channel,
c.campaign_name,
COUNT(l.lead_id)::INTEGER AS lead_count,
COUNT(CASE WHEN l.lead_type = 'hot' THEN 1 END)::INTEGER AS hot_leads
FROM {{ ref('stg_leads') }} l
JOIN {{ ref('stg_campaigns') }} c
ON l.campaign_id = c.campaign_id
WHERE l.created_at IS NOT NULL
GROUP BY 1, 2, 3
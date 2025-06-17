{{config( materialized='table', schema='dm_marts'  ) }}

SELECT
DATE(l.created_at) AS date,
c.channel,
c.campaign_name,
COUNT(l.lead_id)::INTEGER AS lead_count,
COUNT(CASE WHEN l.lead_type IN ('phone_call', 'callback_form') THEN 1 END)::INTEGER AS hot_leads,
COUNT(CASE WHEN l.lead_type IN ('phone_call', 'callback_form') THEN 1 END)::FLOAT / NULLIF(COUNT(l.lead_id), 0) AS hot_lead_ratio
FROM {{ ref('stg_leads') }} l
JOIN {{ ref('stg_campaigns') }} c
ON l.campaign_id = c.campaign_id
WHERE l.created_at IS NOT NULL
GROUP BY 1, 2, 3
ORDER BY 1 DESC, 2, 3
{{ config( materialized='table', schema='dm_intermediate') }}

WITH campaign_stats AS (
SELECT
    c.campaign_id,
    c.channel,
    c.campaign_name,
    c.start_date,
    c.end_date,
    c.budget,
    COUNT(l.lead_id) AS total_leads,
    COUNT(CASE WHEN l.lead_type IN ('phone_call', 'callback_form') THEN 1 END) AS hot_leads
FROM {{ ref('stg_campaigns') }} c
LEFT JOIN {{ ref('stg_leads') }} l
    ON c.campaign_id = l.campaign_id
GROUP BY 1, 2, 3, 4, 5, 6
)

SELECT
  *,
CASE 
    WHEN budget > 0 THEN ROUND((total_leads * 10000.0) / budget)  -- Leads per $10k (integer)
    ELSE NULL 
END AS leads_per_10k,
CASE
    WHEN total_leads > 0 THEN ROUND(hot_leads * 100.0 / total_leads, 2)
    ELSE NULL
END AS hot_lead_pct
FROM campaign_stats
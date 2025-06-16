{{ config( materialized='view', schema='intermediate') }}

with campaigns as (
    select * from {{ ref('stg_campaigns') }}
),

leads as (
    select * from {{ ref('stg_leads') }}
),

campaign_metrics as (
    select
        c.campaign_id,
        c.campaign_name,
        c.channel,
        c.start_date,
        c.end_date,
        c.budget,
        c.campaign_duration_days,
        
        -- Lead metrics (no conversion data available)
        count(l.lead_id) as total_leads,
        0 as converted_leads,  -- No conversion data available
        count(l.lead_id) as open_leads,
        
        -- Lead type distribution
        count(case when l.lead_type = 'phone_call' then l.lead_id end) as phone_leads,
        count(case when l.lead_type = 'callback_form' then l.lead_id end) as callback_leads,
        count(case when l.lead_type = 'inbound_form' then l.lead_id end) as inbound_leads,
        
        -- Since no conversion data, focus on lead generation efficiency
        0 as conversion_rate_pct,  -- No conversion data
        0 as total_revenue,        -- No conversion data
        0 as avg_conversion_value, -- No conversion data
        
        -- Cost efficiency metrics
        case 
            when count(l.lead_id) > 0 
            then round(c.budget / count(l.lead_id), 2)
            else 0 
        end as cost_per_lead,
        
        -- Lead generation rate
        case 
            when c.campaign_duration_days > 0 
            then round(count(l.lead_id) / c.campaign_duration_days, 2)
            else 0 
        end as leads_per_day

    from campaigns c
    left join leads l on c.campaign_id = l.campaign_id
    group by 
        c.campaign_id,
        c.campaign_name,
        c.channel,
        c.start_date,
        c.end_date,
        c.budget,
        c.campaign_duration_days
)

select * from campaign_metrics
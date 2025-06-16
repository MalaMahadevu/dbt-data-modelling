{{ config( materialized='table', schema='marts')
}}

with leads as (
    select * from {{ ref('stg_leads') }}
),

campaigns as (
    select * from {{ ref('stg_campaigns') }}
),

daily_metrics as (
    select
        l.lead_date,
        c.channel,
        c.campaign_name,
        c.campaign_id,
        
        -- Daily lead counts by type
        count(l.lead_id) as leads_generated,
        count(case when l.lead_type = 'phone_call' then l.lead_id end) as phone_leads,
        count(case when l.lead_type = 'callback_form' then l.lead_id end) as callback_leads,
        count(case when l.lead_type = 'inbound_form' then l.lead_id end) as inbound_leads,
        
        -- Since no conversion data available, focus on lead generation patterns
        0 as leads_converted,
        count(l.lead_id) as leads_open,
        0 as daily_conversion_rate_pct,
        0 as daily_revenue,
        0 as avg_daily_conversion_value
        
    from leads l
    inner join campaigns c on l.campaign_id = c.campaign_id
    group by 
        l.lead_date,
        c.channel,
        c.campaign_name,
        c.campaign_id
),

-- Add cumulative metrics
daily_with_cumulative as (
    select
        *,
        sum(leads_generated) over (
            partition by channel 
            order by lead_date 
            rows unbounded preceding
        ) as cumulative_leads_by_channel
        
    from daily_metrics
)

select * from daily_with_cumulative
order by lead_date desc, channel, campaign_name
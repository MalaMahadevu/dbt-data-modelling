{{ config( materialized='table', schema='marts' )
}}

with campaign_performance as (
    select * from {{ ref('int_campaign_performance') }}
),

enhanced_campaigns as (
    select
        campaign_id,
        campaign_name,
        channel,
        start_date,
        end_date,
        budget,
        --campaign_status,
        campaign_duration_days,
        total_leads,
        converted_leads,
        open_leads,
        phone_leads,
        callback_leads,
        inbound_leads,
        conversion_rate_pct,
        total_revenue,
        avg_conversion_value,
        cost_per_lead,
        leads_per_day,
        
        -- Additional classifications
        case 
            when campaign_duration_days <= 7 then 'Short-term'
            when campaign_duration_days <= 30 then 'Medium-term'
            else 'Long-term'
        end as campaign_length_category,
        
        case 
            when budget < 5000 then 'Low Budget'
            when budget < 15000 then 'Medium Budget'
            else 'High Budget'
        end as budget_category,
        
        case 
            when total_leads >= 10 then 'High Volume'
            when total_leads >= 5 then 'Medium Volume'
            when total_leads > 0 then 'Low Volume'
            else 'No Leads'
        end as lead_volume_category,
        
        case 
            when cost_per_lead < 100 then 'High Efficiency'
            when cost_per_lead < 200 then 'Medium Efficiency'
            when cost_per_lead > 0 then 'Low Efficiency'
            else 'No Cost Data'
        end as efficiency_category,
        
        -- Date attributes
        extract(year from start_date) as start_year,
        extract(month from start_date) as start_month,
        extract(quarter from start_date) as start_quarter,
        
        current_timestamp as updated_at
        
    from campaign_performance
)

select * from enhanced_campaigns
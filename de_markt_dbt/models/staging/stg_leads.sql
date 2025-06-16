{{ config(materialized='view', schema='staging') }}


with source_data as (
    select * from {{ ref('leads') }}
),

-- Parse semicolon-separated data
parsed_data as (
    select
        cast(split_part("lead_id;campaign_id;created_at;lead_type", ';', 1) as integer) as lead_id,
        cast(split_part("lead_id;campaign_id;created_at;lead_type", ';', 2) as integer) as campaign_id,
        split_part("lead_id;campaign_id;created_at;lead_type", ';', 3) as created_at_str,
        trim(split_part("lead_id;campaign_id;created_at;lead_type", ';', 4)) as lead_type
    from source_data
    where "lead_id;campaign_id;created_at;lead_type" not like 'lead_id;%'  -- Skip header row
),

cleaned as (
    select
        lead_id,
        campaign_id,
        -- Generate email from lead_id for analysis
        'lead_' || lead_id || '@test.com' as lead_email,
        'Lead ' || lead_id as lead_name,
        -- Parse German datetime format DD.MM.YYYY HH:MM
        cast(strptime(created_at_str, '%d.%m.%Y %H:%M') as timestamp) as created_at,
        lower(trim(lead_type)) as lead_type,
        -- Set default status as 'lead' since conversion data not provided
        'lead' as status,
        null as converted_at,
        null as conversion_value,
        -- Add calculated fields
        null as time_to_conversion,
        cast(strptime(created_at_str, '%d.%m.%Y %H:%M') as date) as lead_date,
        current_timestamp as loaded_at
    from parsed_data
    where lead_id is not null
)

select * from cleaned
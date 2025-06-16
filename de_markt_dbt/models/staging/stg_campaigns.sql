{{ config(materialized='view', schema='staging') }}

with source_data as (
    select * from {{ ref('campaigns') }}
),

parsed_data as (
    select
        cast(split_part("campaign_id;channel;campaign_name;start_date;end_date;budget", ';', 1) as integer) as campaign_id,
        trim(split_part("campaign_id;channel;campaign_name;start_date;end_date;budget", ';', 2)) as channel,
        trim(split_part("campaign_id;channel;campaign_name;start_date;end_date;budget", ';', 3)) as campaign_name,
        split_part("campaign_id;channel;campaign_name;start_date;end_date;budget", ';', 4) as start_date_str,
        split_part("campaign_id;channel;campaign_name;start_date;end_date;budget", ';', 5) as end_date_str,
        cast(split_part("campaign_id;channel;campaign_name;start_date;end_date;budget", ';', 6) as decimal(10,2)) as budget
    from source_data
    where "campaign_id;channel;campaign_name;start_date;end_date;budget" not like 'campaign_id;%'  -- Skip header row
),

cleaned as (
    select
        campaign_id,
        trim(campaign_name) as campaign_name,
        lower(trim(channel)) as channel,
        -- Parse German date format DD.MM.YYYY
        cast(strptime(start_date_str, '%d.%m.%Y') as date) as start_date,
        cast(strptime(end_date_str, '%d.%m.%Y') as date) as end_date,
        budget,
        -- Add calculated fields
        cast(strptime(end_date_str, '%d.%m.%Y') as date) - cast(strptime(start_date_str, '%d.%m.%Y') as date) as campaign_duration_days,
        current_timestamp as loaded_at
    from parsed_data
    where campaign_id is not null
)

select * from cleaned
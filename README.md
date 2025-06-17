# Project Structure
### Leads and Campaigns dbt Project

## de_markt_dbt/
```markdown
├── models/
│   ├── staging/          # Raw data cleaning
|        ├──stg_leads.sql
|        ├──stg_campaigns.sql
│   ├── intermediate/     # Transformations
|        ├──int_campaign_performance.sql
│   ├── marts/           # Analytics-ready tables
|        ├──dim_campaigns.sql
|        ├──fct_daily_leads.sql
│   └── schema.yml        # Data documentation & tests
├── seeds/               # Source CSV files
├── dbt_project.yml      # Project config
└── dev.duckdb         # The Database
```

## Setup
## Installation
```bash
pip install dbt-core 
pip install dbt-duckdb
```
## Creates all needed project and folders
```bash
dbt init de_markt_dbt  

# Verify if all connections are appropriate
dbt debug
```
## Running the Project
```bash
#Load data, run models and test them
dbt seed
dbt run
dbt test
Run Specific Models
# Run only staging models
dbt run --select staging
#View Documentation
dbt docs generate
dbt docs serve
```

## Data Modeling
```markup
Staging: Data Preparation
Purpose: Initial data cleaning and standardization
Tables:

stg_campaigns: Source campaign data with standardized formats
stg_leads: Lead records with validated dates and trimmed values

Intermediate

int_campaign_performance: Joins campaigns with leads and calculates key metrics

Mart: Analytics Ready

dim_campaigns: Provides context for analysis
fct_daily_leads: Track performance over time
``` 

### Example Queries
#### Which campaigns had the highest conversion rate per channel
```sql

SELECT 
    c.channel,
    c.campaign_name,
    SUM(f.lead_count) AS total_leads_generated
FROM fct_daily_leads f
JOIN dim_campaigns c ON f.campaign_id = c.campaign_id
GROUP BY c.channel, c.campaign_name
ORDER BY c.channel, total_leads_generated DESC;
```

#### Which channels consistently drove high-quality leads
```sql
SELECT channel, SUM(lead_count) AS total_leads, ROUND(AVG(hot_lead_ratio)*100, 1) AS avg_hot_rate FROM main_dm_marts.fct_daily_leads GROUP BY channel ORDER BY avg_hot_rate DESC;
```

```markdown
┌───────────┬─────────────┬──────────────┐
│  channel  │ total_leads │ avg_hot_rate │
│  varchar  │   int128    │    double    │
├───────────┼─────────────┼──────────────┤
│ Facebook  │          13 │         76.9 │
│ LinkedIn  │          24 │         58.3 │
│ YouTube   │          10 │         50.0 │
│ Instagram │          30 │         46.7 │
│ Google    │          23 │         40.9 │
└───────────┴─────────────┴──────────────┘
```
#### Campaigns launched per quarter
```sql
SELECT start_quarter, COUNT(*) AS campaigns_launched, GROUP_CONCAT(campaign_name) AS campaign_list FROM main_dm_marts.dim_campaigns GROUP BY start_quarter ORDER BY start_quarter;
```
```markdown
┌───────────────┬────────────────────┬──────────────────────────────────────────────────────────────────────────────────────────┐
│ start_quarter │ campaigns_launched │                                      campaign_list                                       │
│     int64     │       int64        │                                         varchar                                          │
├───────────────┼────────────────────┼──────────────────────────────────────────────────────────────────────────────────────────┤
│             1 │                 65 │ Kampagne 2,Kampagne 3,Kampagne 5,Kampagne 6,Kampagne 7,Kampagne 8,Kampagne 9,Kampagne .  │
│             2 │                 35 │ Kampagne 0,Kampagne 1,Kampagne 4,Kampagne 10,Kampagne 11,Kampagne 15,Kampagne 16,Kampa.  │
└───────────────┴────────────────────┴──────────────────────────────────────────────────────────────────────────────────────────┘
```
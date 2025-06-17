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

#### How many leads were generated per day over time
```sql
SELECT 
    date,
    SUM(lead_count) AS total_leads_generated
FROM fct_daily_leads
GROUP BY date
ORDER BY date;
```
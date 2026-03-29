#Closed Loop Decision Intelligence Platform

The only analytics platform that tracks not just what the data shows — but what decision was made, what action was taken, and what outcome was produced.

🔗 Live Demo:
decision-intelligence.streamlit.app

The Problem with Existing BI Tools

Every major BI platform — Tableau, Power BI, Looker — has the same limitation: they show data but never track what happened after someone looked at it.

A typical analytics workflow today:

Dashboard shows Q3 revenue down 8% in Southeast region
Manager decides to run a promotions campaign
Campaign generates $340,000 in recovered revenue
Next quarter, the dashboard resets — with no memory of what decision was made or whether it worked

This platform closes that gap.

What "Closed Loop" Means
Stage	What Happens
1. Insight	Dashboard shows an anomaly — e.g. health beauty revenue up 23%
2. Decision	Analyst logs what decision they made in response
3. Action	Decision is assigned an owner and deadline
4. Outcome	30/60/90 days later, analyst logs what actually happened
5. Feedback	Outcome data flows back into Redshift for next prediction cycle

Most BI tools only cover Stage 1. This platform covers all five.

Architecture
S3 (Raw CSVs)
    ↓ COPY command
Redshift Staging Schema (8 tables)
    ↓ SQL transformation
Redshift Analytics Schema (fct_orders, fct_order_items, fct_decisions, fct_outcomes)
    ↓ Materialized views
Streamlit App (6 tabs) + QuickSight Dashboards
    ↓ Claude API
AI Insight Summaries → saved back to fct_decisions
Dataset

Built on the Olist Brazilian Ecommerce Dataset — 100,000+ real orders from a Brazilian marketplace.

Table	Rows
Customers	99,441
Orders	99,441
Order Items	112,650
Payments	103,886
Reviews	104,719
Products	32,951
Sellers	3,095
Category Translations	71
Tech Stack
Layer	Tool
Cloud	AWS (S3, Redshift Serverless, QuickSight)
Warehouse	Amazon Redshift Serverless (8 RPU)
Transformation	Redshift SQL + Materialized Views
App	Streamlit (Python)
AI	Anthropic Claude API (claude-sonnet-4-6)
BI	Amazon QuickSight
Deployment	Streamlit Community Cloud
Version Control	GitHub
App Tabs
Revenue — Revenue by category, state, and monthly trend
Delivery — Average delivery days and late/early delivery counts by state
Sellers — Revenue and order count by seller state
Decisions — Log a decision against an insight you saw in the dashboard
Outcomes — Log what actually happened at 30, 60, or 90 days
AI Insights — Claude API generates automated business recommendations
Local Setup
# 1. Clone the repo
git clone https://github.com/dhimanvivek0001/decision-intelligence-.git
cd decision-intelligence-

# 2. Install dependencies
pip install -r requirements.txt

# 3. Create secrets file
mkdir .streamlit
# Add your credentials to .streamlit/secrets.toml (see below)

# 4. Run the app
streamlit run app.py
secrets.toml format
REDSHIFT_HOST = "your-redshift-endpoint.redshift-serverless.amazonaws.com"
REDSHIFT_PASSWORD = "your-password"
CLAUDE_API_KEY = "sk-ant-..."
SQL Setup (Redshift)

Run these files in Redshift Query Editor v2 in this order:

sql/staging_tables.sql      — Create 8 staging tables
sql/copy_commands.sql      — Load data from S3
sql/analytics_tables.sql   — Create fact tables and star schema
sql/materialized_views.sql — Create 5 materialized views
Roadmap
 S3 data lake with all 8 Olist datasets
 Redshift staging and analytics schema
 5 materialized views
 Streamlit app with 6 tabs
 Decision logging to Redshift
 Outcome tracking at 30/60/90 days
 QuickSight dashboards
 Live deployment on Streamlit Cloud
 Claude API activation (requires paid API key)
 Outcome scoring stored procedure
 Slack notifications for outcome reminders
 BigQuery migration option
 LLM-powered outcome prediction
Author

Vivek Dhiman
MSc Business Analytics, University of Galway

GitHub

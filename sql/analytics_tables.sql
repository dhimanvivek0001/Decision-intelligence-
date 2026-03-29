-- ============================================================
-- CLOSED LOOP DECISION INTELLIGENCE PLATFORM
-- File: sql/analytics_tables.sql
-- Purpose: Create star schema fact tables in analytics schema
-- ============================================================
 
-- Main order fact table joining all core datasets
CREATE TABLE analytics.fct_orders AS
SELECT 
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    c.customer_city,
    c.customer_state,
    p.payment_type,
    p.payment_value,
    p.payment_installments,
    r.review_score,
    DATEDIFF(day, o.order_purchase_timestamp, o.order_delivered_customer_date) AS delivery_days,
    DATEDIFF(day, o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delivery_vs_estimate
FROM staging.orders o
LEFT JOIN staging.customers c ON o.customer_id = c.customer_id
LEFT JOIN staging.order_payments p ON o.order_id = p.order_id
LEFT JOIN staging.order_reviews r ON o.order_id = r.order_id;
 
-- Order items fact table with product and seller details
CREATE TABLE analytics.fct_order_items AS
SELECT
    oi.order_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    oi.price + oi.freight_value AS total_value,
    p.product_category_name,
    ct.product_category_name_english,
    s.seller_city,
    s.seller_state
FROM staging.order_items oi
LEFT JOIN staging.products p ON oi.product_id = p.product_id
LEFT JOIN staging.category_translation ct ON p.product_category_name = ct.product_category_name
LEFT JOIN staging.sellers s ON oi.seller_id = s.seller_id;
 
-- Decision tracking table (written by Streamlit app)
CREATE TABLE IF NOT EXISTS analytics.fct_decisions (
  decision_id VARCHAR(50),
  insight_text VARCHAR(1000),
  decision_text VARCHAR(1000),
  owner_name VARCHAR(100),
  created_at TIMESTAMP
);
 
-- Outcome tracking table (written by Streamlit app at 30/60/90 days)
CREATE TABLE IF NOT EXISTS analytics.fct_outcomes (
  outcome_id VARCHAR(50),
  decision_id VARCHAR(50),
  measured_at TIMESTAMP,
  day_marker INT,
  revenue_impact DECIMAL(12,2),
  accounts_saved INT,
  notes VARCHAR(1000)
);

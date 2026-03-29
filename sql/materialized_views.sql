-- ============================================================
-- CLOSED LOOP DECISION INTELLIGENCE PLATFORM
-- File: sql/materialized_views.sql
-- Purpose: Create 5 materialized views powering Streamlit dashboards
-- To refresh: REFRESH MATERIALIZED VIEW analytics.view_name;
-- ============================================================
 
-- Revenue by product category
CREATE MATERIALIZED VIEW analytics.mv_revenue_by_category AS
SELECT 
    ct.product_category_name_english,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_order_value,
    ROUND(SUM(oi.freight_value), 2) AS total_freight
FROM analytics.fct_order_items oi
LEFT JOIN staging.category_translation ct ON oi.product_category_name = ct.product_category_name
GROUP BY 1;
 
-- Revenue by customer state
CREATE MATERIALIZED VIEW analytics.mv_revenue_by_state AS
SELECT
    customer_state,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS total_revenue,
    ROUND(AVG(payment_value), 2) AS avg_order_value,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM analytics.fct_orders
GROUP BY 1;
 
-- Monthly revenue trend
CREATE MATERIALIZED VIEW analytics.mv_monthly_revenue AS
SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS total_revenue,
    ROUND(AVG(payment_value), 2) AS avg_order_value,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM analytics.fct_orders
GROUP BY 1;
 
-- Delivery performance by state
CREATE MATERIALIZED VIEW analytics.mv_delivery_performance AS
SELECT
    customer_state,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(delivery_days), 1) AS avg_delivery_days,
    ROUND(AVG(delivery_vs_estimate), 1) AS avg_vs_estimate,
    SUM(CASE WHEN delivery_vs_estimate < 0 THEN 1 ELSE 0 END) AS delivered_early,
    SUM(CASE WHEN delivery_vs_estimate > 0 THEN 1 ELSE 0 END) AS delivered_late
FROM analytics.fct_orders
WHERE delivery_days IS NOT NULL
GROUP BY 1;
 
-- Seller performance by state
CREATE MATERIALIZED VIEW analytics.mv_seller_performance AS
SELECT
    seller_state,
    COUNT(DISTINCT oi.seller_id) AS total_sellers,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM analytics.fct_order_items oi
GROUP BY 1;
 
-- Refresh all views (run after any data update)
-- REFRESH MATERIALIZED VIEW analytics.mv_revenue_by_category;
-- REFRESH MATERIALIZED VIEW analytics.mv_revenue_by_state;
-- REFRESH MATERIALIZED VIEW analytics.mv_monthly_revenue;
-- REFRESH MATERIALIZED VIEW analytics.mv_delivery_performance;
-- REFRESH MATERIALIZED VIEW analytics.mv_seller_performance;

-- ============================================================
-- CLOSED LOOP DECISION INTELLIGENCE PLATFORM
-- File: sql/staging_tables.sql
-- Purpose: Create all 8 staging tables in Redshift
-- Run this first before loading any data
-- ============================================================
 
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analytics;
 
CREATE TABLE IF NOT EXISTS staging.customers (
  customer_id VARCHAR(50),
  customer_unique_id VARCHAR(50),
  customer_zip_code_prefix VARCHAR(10),
  customer_city VARCHAR(100),
  customer_state VARCHAR(5)
);
 
CREATE TABLE IF NOT EXISTS staging.orders (
  order_id VARCHAR(50),
  customer_id VARCHAR(50),
  order_status VARCHAR(50),
  order_purchase_timestamp TIMESTAMP,
  order_approved_at TIMESTAMP,
  order_delivered_carrier_date TIMESTAMP,
  order_delivered_customer_date TIMESTAMP,
  order_estimated_delivery_date TIMESTAMP
);
 
CREATE TABLE IF NOT EXISTS staging.order_items (
  order_id VARCHAR(50),
  order_item_id INT,
  product_id VARCHAR(50),
  seller_id VARCHAR(50),
  shipping_limit_date TIMESTAMP,
  price DECIMAL(10,2),
  freight_value DECIMAL(10,2)
);
 
CREATE TABLE IF NOT EXISTS staging.order_payments (
  order_id VARCHAR(50),
  payment_sequential INT,
  payment_type VARCHAR(50),
  payment_installments INT,
  payment_value DECIMAL(10,2)
);
 
CREATE TABLE IF NOT EXISTS staging.order_reviews (
  review_id VARCHAR(50),
  order_id VARCHAR(50),
  review_score INT,
  review_comment_title VARCHAR(500),
  review_comment_message VARCHAR(2000),
  review_creation_date TIMESTAMP,
  review_answer_timestamp TIMESTAMP
);
 
CREATE TABLE IF NOT EXISTS staging.products (
  product_id VARCHAR(50),
  product_category_name VARCHAR(100),
  product_name_lenght INT,
  product_description_lenght INT,
  product_photos_qty INT,
  product_weight_g INT,
  product_length_cm INT,
  product_height_cm INT,
  product_width_cm INT
);
 
CREATE TABLE IF NOT EXISTS staging.sellers (
  seller_id VARCHAR(50),
  seller_zip_code_prefix VARCHAR(10),
  seller_city VARCHAR(100),
  seller_state VARCHAR(5)
);
 
CREATE TABLE IF NOT EXISTS staging.category_translation (
  product_category_name VARCHAR(100),
  product_category_name_english VARCHAR(100)
);

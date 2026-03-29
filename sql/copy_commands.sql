-- ============================================================
-- CLOSED LOOP DECISION INTELLIGENCE PLATFORM
-- File: sql/copy_commands.sql
-- Purpose: Load all 8 Olist datasets from S3 into Redshift
-- Replace bucket name with your own S3 bucket name
-- ============================================================
 
COPY staging.customers
FROM 's3://vivek-olist-analytics-bucket/customers/olist_customers_dataset.csv'
IAM_ROLE default
CSV IGNOREHEADER 1;
 
COPY staging.orders
FROM 's3://vivek-olist-analytics-bucket/orders/olist_orders_dataset.csv'
IAM_ROLE default
CSV IGNOREHEADER 1;
 
COPY staging.order_items
FROM 's3://vivek-olist-analytics-bucket/order_items/olist_order_items_dataset.csv'
IAM_ROLE default
CSV IGNOREHEADER 1;
 
COPY staging.order_payments
FROM 's3://vivek-olist-analytics-bucket/order_payments/olist_order_payments_dataset.csv'
IAM_ROLE default
CSV IGNOREHEADER 1;
 
COPY staging.order_reviews
FROM 's3://vivek-olist-analytics-bucket/order_reviews/olist_order_reviews_dataset.csv'
IAM_ROLE default
CSV IGNOREHEADER 1;
 
COPY staging.products
FROM 's3://vivek-olist-analytics-bucket/products/olist_products_dataset.csv'
IAM_ROLE default
CSV IGNOREHEADER 1;
 
COPY staging.sellers
FROM 's3://vivek-olist-analytics-bucket/sellers/olist_sellers_dataset.csv'
IAM_ROLE default
CSV IGNOREHEADER 1;
 
COPY staging.category_translation
FROM 's3://vivek-olist-analytics-bucket/category_translation/product_category_name_translation.csv'
IAM_ROLE default
CSV IGNOREHEADER 1;
 
-- Verify row counts after loading
SELECT 'customers' as table_name, COUNT(*) FROM staging.customers
UNION ALL SELECT 'orders', COUNT(*) FROM staging.orders
UNION ALL SELECT 'order_items', COUNT(*) FROM staging.order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM staging.order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM staging.order_reviews
UNION ALL SELECT 'products', COUNT(*) FROM staging.products
UNION ALL SELECT 'sellers', COUNT(*) FROM staging.sellers
UNION ALL SELECT 'category_translation', COUNT(*) FROM staging.category_translation

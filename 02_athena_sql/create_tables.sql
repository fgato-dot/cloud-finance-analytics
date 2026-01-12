-- Athena table creation script for cloud-finance-analytics project





CREATE DATABASE IF NOT EXISTS finance_analytics;

CREATE EXTERNAL TABLE IF NOT EXISTS finance_analytics.customers (
  customer_id STRING,
  customer_name STRING,
  region STRING,
  customer_type STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'skip.header.line.count' = '1'
)
LOCATION 's3://your-bucket-name/raw/customers/';





-- Athena table creation script (cloud-finance-analytics)


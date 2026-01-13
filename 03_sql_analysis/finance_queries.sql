-- 1) Monthly revenue, gross profit, margin %
SELECT
  date_format(transaction_date, '%Y-%m') AS month,
  SUM(revenue) AS total_revenue,
  SUM(revenue - cost) AS gross_profit,
  ROUND(SUM(revenue - cost) / NULLIF(SUM(revenue), 0), 4) AS margin_pct
FROM finance_analytics.transactions
GROUP BY 1
ORDER BY 1;

-- 2) Top 10 products by gross profit
SELECT
  p.product_name,
  p.category,
  SUM(t.revenue) AS total_revenue,
  SUM(t.revenue - t.cost) AS gross_profit,
  ROUND(SUM(t.revenue - t.cost) / NULLIF(SUM(t.revenue), 0), 4) AS margin_pct
FROM finance_analytics.transactions t
JOIN finance_analytics.products p
  ON t.product_id = p.product_id
GROUP BY 1,2
ORDER BY gross_profit DESC
LIMIT 10;

-- 3) Bottom 10 products by margin %
SELECT
  p.product_name,
  p.category,
  SUM(t.revenue) AS total_revenue,
  SUM(t.revenue - t.cost) AS gross_profit,
  ROUND(SUM(t.revenue - t.cost) / NULLIF(SUM(t.revenue), 0), 4) AS margin_pct
FROM finance_analytics.transactions t
JOIN finance_analytics.products p
  ON t.product_id = p.product_id
GROUP BY 1,2
HAVING SUM(t.revenue) > 0
ORDER BY margin_pct ASC
LIMIT 10;

-- 4) Customer profitability (top 10)
SELECT
  c.customer_name,
  c.region,
  c.customer_type,
  SUM(t.revenue) AS total_revenue,
  SUM(t.revenue - t.cost) AS gross_profit,
  ROUND(SUM(t.revenue - t.cost) / NULLIF(SUM(t.revenue), 0), 4) AS margin_pct
FROM finance_analytics.transactions t
JOIN finance_analytics.customers c
  ON t.customer_id = c.customer_id
GROUP BY 1,2,3
ORDER BY gross_profit DESC
LIMIT 10;

-- 5) Low-margin customers (risk list)
SELECT
  c.customer_name,
  c.region,
  ROUND(SUM(t.revenue - t.cost) / NULLIF(SUM(t.revenue), 0), 4) AS margin_pct,
  SUM(t.revenue) AS total_revenue
FROM finance_analytics.transactions t
JOIN finance_analytics.customers c
  ON t.customer_id = c.customer_id
GROUP BY 1,2
HAVING SUM(t.revenue) >= 1000
   AND (SUM(t.revenue - t.cost) / NULLIF(SUM(t.revenue), 0)) < 0.20
ORDER BY margin_pct ASC;


-- cloud-finance-analytics
-- Athena analysis queries (profitability, margin, performance)

-- 0) Quick sanity check
SELECT COUNT(*) AS transactions_count
FROM finance_analytics.transactions;

-- 1) Monthly revenue, gross profit, margin %
SELECT
  date_format(transaction_date, '%Y-%m') AS month,
  SUM(revenue) AS total_revenue,
  SUM(cost) AS total_cost,
  SUM(revenue - cost) AS gross_profit,
  ROUND(SUM(revenue - cost) / NULLIF(SUM(revenue), 0), 4) AS margin_pct
FROM finance_analytics.transactions
GROUP BY 1
ORDER BY 1;

-- 2) Revenue & profit by region (customer dimension)
SELECT
  c.region,
  SUM(t.revenue) AS total_revenue,
  SUM(t.cost) AS total_cost,
  SUM(t.revenue - t.cost) AS gross_profit,
  ROUND(SUM(t.revenue - t.cost) / NULLIF(SUM(t.revenue), 0), 4) AS margin_pct
FROM finance_analytics.transactions t
JOIN finance_analytics.customers c
  ON t.customer_id = c.customer_id
GROUP BY 1
ORDER BY gross_profit DESC;

-- 3) Top 10 products by gross profit
SELECT
  p.product_name,
  p.category,
  SUM(t.revenue) AS total_revenue,
  SUM(t.revenue - t.cost) AS gross_profit,
  ROUND(SUM(t.revenue - t.cost) / NULLIF(SUM(t.revenue), 0), 4) AS margin_pct
FROM finance_analytics.transactions t
JOIN finance_analytics.products p
  ON t.product_id = p.product_id
GROUP BY 1,2
ORDER BY gross_profit DESC
LIMIT 10;

-- 4) Bottom 10 products by margin % (watch-outs)
SELECT
  p.product_name,
  p.category,
  SUM(t.revenue) AS total_revenue,
  SUM(t.revenue - t.cost) AS gross_profit,
  ROUND(SUM(t.revenue - t.cost) / NULLIF(SUM(t.revenue), 0), 4) AS margin_pct
FROM finance_analytics.transactions t
JOIN finance_analytics.products p
  ON t.product_id = p.product_id
GROUP BY 1,2
HAVING SUM(t.revenue) > 0
ORDER BY margin_pct ASC
LIMIT 10;

-- 5) Customer profitability (top 10 by profit)
SELECT
  c.customer_name,
  c.region,
  c.customer_type,
  SUM(t.revenue) AS total_revenue,
  SUM(t.revenue - t.cost) AS gross_profit,
  ROUND(SUM(t.revenue - t.cost) / NULLIF(SUM(t.revenue), 0), 4) AS margin_pct
FROM finance_analytics.transactions t
JOIN finance_analytics.customers c
  ON t.customer_id = c.customer_id
GROUP BY 1,2,3
ORDER BY gross_profit DESC
LIMIT 10;

-- 6) Low-margin customers list (risk)
-- Adjust thresholds as you like (revenue floor + margin threshold)
SELECT
  c.customer_name,
  c.region,
  SUM(t.revenue) AS total_revenue,
  ROUND(SUM(t.revenue - t.cost) / NULLIF(SUM(t.revenue), 0), 4) AS margin_pct
FROM finance_analytics.transactions t
JOIN finance_analytics.customers c
  ON t.customer_id = c.customer_id
GROUP BY 1,2
HAVING SUM(t.revenue) >= 1000
   AND (SUM(t.revenue - t.cost) / NULLIF(SUM(t.revenue), 0)) < 0.20
ORDER BY margin_pct ASC, total_revenue DESC;

-- 7) Daily trend (good for BI visuals)
SELECT
  transaction_date,
  SUM(revenue) AS total_revenue,
  SUM(revenue - cost) AS gross_profit,
  ROUND(SUM(revenue - cost) / NULLIF(SUM(revenue), 0), 4) AS margin_pct
FROM finance_analytics.transactions
GROUP BY 1
ORDER BY 1;


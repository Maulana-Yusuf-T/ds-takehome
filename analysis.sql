CREATE TABLE e_commerce_transactions (
    "order_id" INT PRIMARY KEY,
    "customer_id" INT,
    "order_date" DATE,
    "payment_value" FLOAT,
    "decoy_flag" VARCHAR(100),
    "decoy_noise" FLOAT
);

COPY e_commerce_transactions("order_id", "customer_id", "order_date", "payment_value", "decoy_flag", "decoy_noise")
FROM 'D:/e_commerce_transactions.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

SELECT * FROM e_commerce_transactions

-- 1. Calculate RFM
WITH base AS(
	SELECT
		customer_id,
		MAX(order_date) AS last_order,
		COUNT(order_id) AS frequency,
		SUM(payment_value) AS monetary
	FROM e_commerce_transactions
	GROUP BY customer_id
),

rfm AS(
	SELECT
		customer_id,
		CURRENT_DATE - last_order AS recency,
		frequency,
		monetary
	FROM base
)

SELECT * FROM rfm;

-- RFM Segmentation (>= 6 Segments)
WITH rfm_ranked AS(
	SELECT
		NTILE(4) OVER (ORDER BY CURRENT_DATE - MAX(order_date) ASC) AS r_score,
		NTILE(4) OVER (ORDER BY COUNT(order_id) DESC) AS f_score,
		NTILE(4) OVER (ORDER BY SUM(payment_value) DESC) AS m_score
	FROM e_commerce_transactions
	GROUP BY customer_id
),

scored AS (
	SELECT *,
		CONCAT(r_score::text, f_score::text, m_score::text) AS rfm_score
	FROM rfm_ranked
)

SELECT *,
	CASE
		WHEN rfm_score LIKE '444' THEN 'champions'
		WHEN rfm_score LIKE '4__' THEN 'loyal'
		WHEN rfm_score LIKE '_4_' THEN 'frequent'
		WHEN rfm_score LIKE '__4' THEN 'big_spenders'
		WHEN rfm_score LIKE '1__' THEN 'lost'
		WHEN rfm_score LIKE '__1' THEN 'low_value'
		ELSE 'others'
	END AS segment
FROM scored;

-- 2. Repeat Purchase per Month
SELECT
	customer_id,
	DATE_TRUNC('month', order_date) AS month,
	COUNT(DISTINCT order_id) AS order_count
FROM e_commerce_transactions
GROUP BY customer_id, DATE_TRUNC('month', order_date)
HAVING COUNT (DISTINCT order_id) > 1
ORDER BY customer_id, month

-- Explain
SELECT
	customer_id, -- Show the customer ID
	DATE_TRUNC('month', order_date) AS month, -- Change the order date into first month
	COUNT(DISTINCT order_id) AS order_count
FROM e_commerce_transactions
GROUP BY customer_id, DATE_TRUNC('month', order_date)
HAVING COUNT (DISTINCT order_id) > 1;
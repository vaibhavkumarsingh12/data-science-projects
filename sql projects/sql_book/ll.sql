-- Exploratory Data Analysis (EDA) SQL template
-- Replace `your_table` with your actual table name and adjust column names as needed.

-- 1) Preview the data
SELECT *
FROM your_table
LIMIT 10;

-- 2) Row count
SELECT COUNT(*) AS total_rows
FROM your_table;

-- 3) Column-wise null checks
SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN col1 IS NULL THEN 1 ELSE 0 END) AS col1_nulls,
	SUM(CASE WHEN col2 IS NULL THEN 1 ELSE 0 END) AS col2_nulls,
	SUM(CASE WHEN col3 IS NULL THEN 1 ELSE 0 END) AS col3_nulls
FROM your_table;

-- 4) Distinct values for categorical columns
SELECT COUNT(DISTINCT col1) AS distinct_col1_values
FROM your_table;

-- 5) Frequency distribution for a categorical column
SELECT col1, COUNT(*) AS frequency
FROM your_table
GROUP BY col1
ORDER BY frequency DESC;

-- 6) Numeric summary statistics
SELECT
	MIN(numeric_col) AS min_value,
	MAX(numeric_col) AS max_value,
	AVG(numeric_col) AS avg_value,
	STDDEV(numeric_col) AS stddev_value
FROM your_table;

-- 7) Check for duplicates based on a key column
SELECT key_col, COUNT(*) AS duplicate_count
FROM your_table
GROUP BY key_col
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- 8) Top records by a numeric metric
SELECT *
FROM your_table
ORDER BY numeric_col DESC
LIMIT 10;

-- 9) Basic date analysis
SELECT
	MIN(date_col) AS earliest_date,
	MAX(date_col) AS latest_date,
	COUNT(DISTINCT DATE(date_col)) AS active_days
FROM your_table;

-- 10) Simple aggregation by group
SELECT group_col, COUNT(*) AS total_records, AVG(numeric_col) AS avg_numeric_col
FROM your_table
GROUP BY group_col
ORDER BY total_records DESC;

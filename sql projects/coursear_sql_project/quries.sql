-- Quick sanity checks
SELECT 'cheese_production' AS table_name, COUNT(*) AS row_count FROM cheese_production
UNION ALL
SELECT 'honey_production', COUNT(*) FROM honey_production
UNION ALL
SELECT 'milk_production', COUNT(*) FROM milk_production
UNION ALL
SELECT 'coffee_production', COUNT(*) FROM coffee_production
UNION ALL
SELECT 'egg_production', COUNT(*) FROM egg_production
UNION ALL
SELECT 'yogurt_production', COUNT(*) FROM yogurt_production;

-- Top 10 states by average milk production value
SELECT
	State_ANSI,
	AVG(Value) AS avg_milk_value
FROM milk_production
GROUP BY State_ANSI
ORDER BY avg_milk_value DESC
LIMIT 10;

-- Yearly trend for honey production
SELECT
	Year,
	SUM(Value) AS total_honey_value
FROM honey_production
GROUP BY Year
ORDER BY Year;

-- Compare yearly totals across key commodities (cheese, milk, egg)
WITH yearly_cheese AS (
	SELECT Year, SUM(Value) AS total_cheese FROM cheese_production GROUP BY Year
),
yearly_milk AS (
	SELECT Year, SUM(Value) AS total_milk FROM milk_production GROUP BY Year
),
yearly_egg AS (
	SELECT Year, SUM(Value) AS total_egg FROM egg_production GROUP BY Year
)
SELECT
	c.Year,
	c.total_cheese,
	m.total_milk,
	e.total_egg
FROM yearly_cheese c
LEFT JOIN yearly_milk m ON m.Year = c.Year
LEFT JOIN yearly_egg e ON e.Year = c.Year
ORDER BY c.Year;

-- Find potential data quality issues
SELECT 'cheese_production' AS table_name, COUNT(*) AS null_value_rows
FROM cheese_production
WHERE Value IS NULL OR Year IS NULL
UNION ALL
SELECT 'honey_production', COUNT(*)
FROM honey_production
WHERE Value IS NULL OR Year IS NULL
UNION ALL
SELECT 'milk_production', COUNT(*)
FROM milk_production
WHERE Value IS NULL OR Year IS NULL
UNION ALL
SELECT 'coffee_production', COUNT(*)
FROM coffee_production
WHERE Value IS NULL OR Year IS NULL
UNION ALL
SELECT 'egg_production', COUNT(*)
FROM egg_production
WHERE Value IS NULL OR Year IS NULL
UNION ALL
SELECT 'yogurt_production', COUNT(*)
FROM yogurt_production
WHERE Value IS NULL OR Year IS NULL;

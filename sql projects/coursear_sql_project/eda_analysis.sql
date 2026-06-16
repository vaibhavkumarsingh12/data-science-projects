-- EDA (Exploratory Data Analysis) queries for production datasets

DROP VIEW IF EXISTS eda_all_data;
CREATE TEMP VIEW eda_all_data AS
SELECT 'cheese' AS commodity, Year, State_ANSI, Value FROM cheese_production
UNION ALL
SELECT 'honey', Year, State_ANSI, Value FROM honey_production
UNION ALL
SELECT 'milk', Year, State_ANSI, Value FROM milk_production
UNION ALL
SELECT 'coffee', Year, State_ANSI, Value FROM coffee_production
UNION ALL
SELECT 'egg', Year, State_ANSI, Value FROM egg_production
UNION ALL
SELECT 'yogurt', Year, State_ANSI, Value FROM yogurt_production;

-- 1) Dataset coverage by commodity (records, year range, states)
WITH typed_data AS (
    SELECT
        commodity,
        Year,
        State_ANSI,
        CASE
            WHEN TRIM(Value) <> ''
             AND TRIM(Value) NOT GLOB '*[^0-9]*'
            THEN CAST(TRIM(Value) AS INTEGER)
        END AS value_num
    FROM eda_all_data
)
SELECT
    commodity,
    COUNT(*) AS total_rows,
    MIN(Year) AS min_year,
    MAX(Year) AS max_year,
    COUNT(DISTINCT State_ANSI) AS distinct_states,
    AVG(value_num) AS avg_value,
    MIN(value_num) AS min_value,
    MAX(value_num) AS max_value
FROM typed_data
GROUP BY commodity
ORDER BY commodity;

-- 2) Missing-data check per commodity
SELECT 'cheese' AS commodity, COUNT(*) AS null_rows
FROM cheese_production
WHERE Year IS NULL OR State_ANSI IS NULL OR Value IS NULL
UNION ALL
SELECT 'honey', COUNT(*) FROM honey_production
WHERE Year IS NULL OR State_ANSI IS NULL OR Value IS NULL
UNION ALL
SELECT 'milk', COUNT(*) FROM milk_production
WHERE Year IS NULL OR State_ANSI IS NULL OR Value IS NULL
UNION ALL
SELECT 'coffee', COUNT(*) FROM coffee_production
WHERE Year IS NULL OR State_ANSI IS NULL OR Value IS NULL
UNION ALL
SELECT 'egg', COUNT(*) FROM egg_production
WHERE Year IS NULL OR State_ANSI IS NULL OR Value IS NULL
UNION ALL
SELECT 'yogurt', COUNT(*) FROM yogurt_production
WHERE Year IS NULL OR State_ANSI IS NULL OR Value IS NULL;

-- 3) Annual trend across all commodities
WITH typed_data AS (
    SELECT
        commodity,
        Year,
        CASE
            WHEN TRIM(Value) <> ''
             AND TRIM(Value) NOT GLOB '*[^0-9]*'
            THEN CAST(TRIM(Value) AS INTEGER)
        END AS value_num
    FROM eda_all_data
)
SELECT
    Year,
    commodity,
    SUM(value_num) AS total_value
FROM typed_data
GROUP BY Year, commodity
ORDER BY Year, commodity;

-- 4) Top states by average production value in each commodity
WITH typed_data AS (
    SELECT
        commodity,
        State_ANSI,
        CASE
            WHEN TRIM(Value) <> ''
             AND TRIM(Value) NOT GLOB '*[^0-9]*'
            THEN CAST(TRIM(Value) AS INTEGER)
        END AS value_num
    FROM eda_all_data
), state_avg AS (
    SELECT
        commodity,
        State_ANSI,
        AVG(value_num) AS avg_value
    FROM typed_data
    GROUP BY commodity, State_ANSI
), ranked AS (
    SELECT
        commodity,
        State_ANSI,
        avg_value,
        ROW_NUMBER() OVER (PARTITION BY commodity ORDER BY avg_value DESC) AS rn
    FROM state_avg
)
SELECT commodity, State_ANSI, avg_value
FROM ranked
WHERE rn <= 5
ORDER BY commodity, avg_value DESC;

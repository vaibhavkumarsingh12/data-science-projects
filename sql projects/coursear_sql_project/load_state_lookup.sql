-- Rebuild a clean state_lookup table from imported CSV data.
-- Expected workflow:
-- 1) Create state_lookup_stage (State TEXT, State_ANSI TEXT)
-- 2) Import CSV into state_lookup_stage
-- 3) Run this script

DROP TABLE IF EXISTS state_lookup_new;
CREATE TABLE state_lookup_new (
    State_ANSI INTEGER PRIMARY KEY,
    State TEXT NOT NULL UNIQUE
);

INSERT INTO state_lookup_new (State_ANSI, State)
SELECT DISTINCT
    CAST(TRIM(State_ANSI) AS INTEGER) AS State_ANSI,
    UPPER(TRIM(State)) AS State
FROM state_lookup_stage
WHERE TRIM(State) <> ''
  AND TRIM(State_ANSI) <> ''
  AND TRIM(State_ANSI) GLOB '[0-9]*';

DROP TABLE IF EXISTS state_lookup;
ALTER TABLE state_lookup_new RENAME TO state_lookup;
DROP TABLE IF EXISTS state_lookup_stage;
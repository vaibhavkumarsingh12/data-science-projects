# Data Science Projects

This repository contains practical, interview-ready data projects.  
Current focus: SQL data modeling and analysis with SQLite.

## Project Structure

```text
my project/
└── sql projects/
    └── coursear_sql_project/
        ├── create_table.sql
        ├── load_state_lookup.sql
        ├── quries.sql
        ├── cleanup.sql
        ├── production.db
        ├── erd.dbml
        ├── erd_vscode.md
        ├── erd_vscode.mmd
        └── *.csv
```

## Included SQL Project

### 1) coursear_sql_project

Purpose:
- Build a production-oriented SQLite schema for agriculture commodities.
- Load/clean CSV sources.
- Analyze production by year, state, and commodity.
- Showcase data modeling + query skills for interviews.

Key concepts demonstrated:
- Fact-style production tables per commodity.
- Dimension-style lookup joins (`State_ANSI`, `Commodity_ID`).
- Data cleaning and normalization using SQL transforms.
- Reproducible SQL workflow with script files.

## Quick Start (SQLite)

From the folder `sql projects/coursear_sql_project`:

```powershell
sqlite3 production.db ".read create_table.sql"
```

If you need to load lookup data using staged import:

```sql
-- inside sqlite shell
.mode csv
.import state_lookup.csv state_lookup_stage
.read load_state_lookup.sql
```

Then run analytical queries:

```powershell
sqlite3 production.db ".read quries.sql"
```

## Interview Talking Points

- Why separate tables for cheese, honey, milk, coffee, egg, and yogurt?
- How to model dimensions (`state_dim`, `commodity_dim`) vs. facts.
- How to clean dirty CSV values (`TRIM`, `CAST`, `DISTINCT`, `UPPER`).
- How to index for performance on `State_ANSI`, `Commodity_ID`, and `Year`.
- How to extend this design to a star schema with one unified fact table.

## Notes

- `cleanup.sql` is currently a placeholder for reset/maintenance steps.
- `production.db-shm` and `production.db-wal` are SQLite runtime files and are ignored in git.
- File names are preserved as currently present in the workspace.

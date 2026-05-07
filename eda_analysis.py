"""
Exploratory Data Analysis (EDA) for Agricultural Production Database
Analyzes cheese, honey, milk, coffee, egg, and yogurt production data
"""

import sqlite3
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

# Set style for better-looking plots
sns.set_style("whitegrid")
plt.rcParams['figure.figsize'] = (12, 6)

# Database path
DB_PATH = Path(__file__).parent / "sql projects" / "coursear_sql_project" / "production.db"

def connect_db():
    """Connect to SQLite database"""
    conn = sqlite3.connect(DB_PATH)
    return conn

def get_database_overview(conn):
    """Get overview of database structure"""
    print("=" * 80)
    print("DATABASE OVERVIEW")
    print("=" * 80)
    
    # Get all tables
    query = """
    SELECT name FROM sqlite_master 
    WHERE type='table' 
    ORDER BY name;
    """
    tables = pd.read_sql_query(query, conn)
    print("\nTables in database:")
    print(tables.to_string(index=False))
    
    return tables['name'].tolist()

def get_table_stats(conn, tables):
    """Get row counts and basic stats for each table"""
    print("\n" + "=" * 80)
    print("TABLE STATISTICS")
    print("=" * 80)
    
    stats = []
    for table in tables:
        query = f"SELECT COUNT(*) as row_count FROM {table}"
        count = pd.read_sql_query(query, conn).iloc[0, 0]
        stats.append({'Table': table, 'Row Count': count})
    
    stats_df = pd.DataFrame(stats)
    print("\n", stats_df.to_string(index=False))
    return stats_df

def get_data_quality_report(conn, tables):
    """Check for null values, data types, and ranges"""
    print("\n" + "=" * 80)
    print("DATA QUALITY REPORT")
    print("=" * 80)
    
    for table in tables:
        print(f"\n--- {table} ---")
        df = pd.read_sql_query(f"SELECT * FROM {table}", conn)
        
        print(f"Shape: {df.shape}")
        print(f"\nData Types:\n{df.dtypes}")
        print(f"\nNull Values:\n{df.isnull().sum()}")
        print(f"\nBasic Statistics:\n{df.describe()}")

def analyze_production_data(conn):
    """Analyze all production data together"""
    print("\n" + "=" * 80)
    print("PRODUCTION DATA ANALYSIS")
    print("=" * 80)
    
    # Get all production tables
    commodities = ['cheese_production', 'honey_production', 'milk_production', 
                   'coffee_production', 'egg_production', 'yogurt_production']
    
    all_data = []
    for commodity in commodities:
        df = pd.read_sql_query(f"SELECT * FROM {commodity}", conn)
        df['Commodity'] = commodity.replace('_production', '')
        all_data.append(df)
    
    combined_df = pd.concat(all_data, ignore_index=True)
    
    print(f"\nTotal records across all commodities: {len(combined_df)}")
    print(f"Year range: {combined_df['Year'].min()} - {combined_df['Year'].max()}")
    print(f"Unique states: {combined_df['State_ANSI'].nunique()}")
    print(f"Unique commodities: {combined_df['Commodity'].nunique()}")
    print(f"Unique domains: {combined_df['Domain'].nunique()}")
    
    print(f"\nProduction Value Statistics (across all commodities):")
    print(combined_df['Value'].describe())
    
    return combined_df

def analyze_by_commodity(conn):
    """Analyze each commodity separately"""
    print("\n" + "=" * 80)
    print("COMMODITY-SPECIFIC ANALYSIS")
    print("=" * 80)
    
    commodities = ['cheese_production', 'honey_production', 'milk_production', 
                   'coffee_production', 'egg_production', 'yogurt_production']
    
    for commodity in commodities:
        df = pd.read_sql_query(f"SELECT * FROM {commodity}", conn)
        commodity_name = commodity.replace('_production', '')
        
        print(f"\n--- {commodity_name.upper()} ---")
        print(f"Total records: {len(df)}")
        print(f"Year range: {df['Year'].min()} - {df['Year'].max()}")
        print(f"Production value range: {df['Value'].min():,} - {df['Value'].max():,}")
        print(f"Average production value: {df['Value'].mean():,.0f}")
        print(f"Median production value: {df['Value'].median():,.0f}")
        
        # Top states
        top_states = df.groupby('State_ANSI')['Value'].sum().sort_values(ascending=False).head(5)
        print(f"\nTop 5 states by total production:")
        print(top_states)

def analyze_trends(conn):
    """Analyze trends over time"""
    print("\n" + "=" * 80)
    print("TREND ANALYSIS BY YEAR")
    print("=" * 80)
    
    commodities = ['cheese_production', 'honey_production', 'milk_production', 
                   'coffee_production', 'egg_production', 'yogurt_production']
    
    trend_data = {}
    for commodity in commodities:
        df = pd.read_sql_query(f"SELECT * FROM {commodity}", conn)
        commodity_name = commodity.replace('_production', '')
        yearly_total = df.groupby('Year')['Value'].sum()
        trend_data[commodity_name] = yearly_total
    
    trend_df = pd.DataFrame(trend_data)
    print("\nYearly production totals by commodity:")
    print(trend_df)
    
    return trend_df

def create_visualizations(conn):
    """Create visualizations for EDA"""
    print("\n" + "=" * 80)
    print("CREATING VISUALIZATIONS")
    print("=" * 80)
    
    commodities = ['cheese_production', 'honey_production', 'milk_production', 
                   'coffee_production', 'egg_production', 'yogurt_production']
    
    all_data = []
    for commodity in commodities:
        df = pd.read_sql_query(f"SELECT * FROM {commodity}", conn)
        df['Commodity'] = commodity.replace('_production', '')
        all_data.append(df)
    
    combined_df = pd.concat(all_data, ignore_index=True)
    
    # 1. Yearly trends
    fig, ax = plt.subplots(figsize=(14, 6))
    yearly_data = combined_df.groupby(['Year', 'Commodity'])['Value'].sum().unstack()
    yearly_data.plot(ax=ax, marker='o')
    plt.title('Production Trends Over Time by Commodity', fontsize=14, fontweight='bold')
    plt.xlabel('Year')
    plt.ylabel('Total Production Value')
    plt.legend(title='Commodity', bbox_to_anchor=(1.05, 1), loc='upper left')
    plt.tight_layout()
    plt.savefig(Path(__file__).parent / 'eda_yearly_trends.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: eda_yearly_trends.png")
    plt.close()
    
    # 2. Box plot of production values by commodity
    fig, ax = plt.subplots(figsize=(10, 6))
    combined_df.boxplot(column='Value', by='Commodity', ax=ax)
    plt.title('Production Value Distribution by Commodity', fontsize=14, fontweight='bold')
    plt.suptitle('')
    plt.xlabel('Commodity')
    plt.ylabel('Production Value')
    plt.tight_layout()
    plt.savefig(Path(__file__).parent / 'eda_boxplot.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: eda_boxplot.png")
    plt.close()
    
    # 3. Commodity comparison - total production
    fig, ax = plt.subplots(figsize=(10, 6))
    commodity_totals = combined_df.groupby('Commodity')['Value'].sum().sort_values(ascending=False)
    commodity_totals.plot(kind='bar', ax=ax, color='steelblue')
    plt.title('Total Production Value by Commodity', fontsize=14, fontweight='bold')
    plt.xlabel('Commodity')
    plt.ylabel('Total Production Value')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(Path(__file__).parent / 'eda_commodity_totals.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: eda_commodity_totals.png")
    plt.close()
    
    # 4. Top 10 states by total production
    fig, ax = plt.subplots(figsize=(10, 6))
    top_states = combined_df.groupby('State_ANSI')['Value'].sum().sort_values(ascending=False).head(10)
    top_states.plot(kind='barh', ax=ax, color='coral')
    plt.title('Top 10 States by Total Production Value', fontsize=14, fontweight='bold')
    plt.xlabel('Total Production Value')
    plt.ylabel('State ANSI Code')
    plt.tight_layout()
    plt.savefig(Path(__file__).parent / 'eda_top_states.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: eda_top_states.png")
    plt.close()
    
    # 5. Value distribution histogram
    fig, ax = plt.subplots(figsize=(10, 6))
    plt.hist(combined_df['Value'], bins=50, edgecolor='black', color='skyblue')
    plt.title('Distribution of Production Values (All Commodities)', fontsize=14, fontweight='bold')
    plt.xlabel('Production Value')
    plt.ylabel('Frequency')
    plt.tight_layout()
    plt.savefig(Path(__file__).parent / 'eda_value_distribution.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: eda_value_distribution.png")
    plt.close()

def main():
    """Run complete EDA"""
    try:
        conn = connect_db()
        
        # Run all analyses
        tables = get_database_overview(conn)
        get_table_stats(conn, tables)
        get_data_quality_report(conn, tables)
        analyze_production_data(conn)
        analyze_by_commodity(conn)
        trend_df = analyze_trends(conn)
        create_visualizations(conn)
        
        print("\n" + "=" * 80)
        print("EDA COMPLETE!")
        print("=" * 80)
        print("\nGenerated files:")
        print("- eda_yearly_trends.png")
        print("- eda_boxplot.png")
        print("- eda_commodity_totals.png")
        print("- eda_top_states.png")
        print("- eda_value_distribution.png")
        
        conn.close()
        
    except FileNotFoundError:
        print(f"Error: Database not found at {DB_PATH}")
        print("Please ensure production.db exists in the coursear_sql_project folder")
    except Exception as e:
        print(f"Error during EDA: {e}")
        raise

if __name__ == "__main__":
    main()

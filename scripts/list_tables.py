import sqlite3
from pathlib import Path

db = Path("sql projects") / "sql_book" / "sTunes.db"
if not db.exists():
    print("ERROR: database not found:", db)
    raise SystemExit(1)

conn = sqlite3.connect(str(db))
cur = conn.cursor()
cur.execute("SELECT name FROM sqlite_master WHERE type='table';")
rows = cur.fetchall()
print(len(rows))
for r in rows:
    print(r[0])
conn.close()

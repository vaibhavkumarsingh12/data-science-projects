-- 1. See all your tables
SELECT name FROM sqlite_master WHERE type='table';

-- 2. Preview the dates table (already open in viewer)
SELECT * FROM dates LIMIT 10;

-- 3. Preview users
SELECT * FROM users LIMIT 10;

-- 4. Count rows in each important table
SELECT 'users' as table_name, COUNT(*) as rows FROM users
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'items', COUNT(*) FROM items
UNION ALL
SELECT 'events', COUNT(*) FROM events;
-- ============================================================
--  EDA — sTunes Music Store Database
-- ============================================================

-- ─────────────────────────────────────────
--  1. ROW COUNTS FOR EVERY TABLE
-- ─────────────────────────────────────────
SELECT 'artists'        AS tbl, COUNT(*) AS rows FROM artists       UNION ALL
SELECT 'albums',                COUNT(*)         FROM albums         UNION ALL
SELECT 'tracks',                COUNT(*)         FROM tracks         UNION ALL
SELECT 'genres',                COUNT(*)         FROM genres         UNION ALL
SELECT 'media_types',           COUNT(*)         FROM media_types    UNION ALL
SELECT 'playlists',             COUNT(*)         FROM playlists      UNION ALL
SELECT 'playlist_track',        COUNT(*)         FROM playlist_track UNION ALL
SELECT 'customers',             COUNT(*)         FROM customers      UNION ALL
SELECT 'employees',             COUNT(*)         FROM employees      UNION ALL
SELECT 'invoices',              COUNT(*)         FROM invoices       UNION ALL
SELECT 'invoice_items',         COUNT(*)         FROM invoice_items;


-- ─────────────────────────────────────────
--  2. TRACKS — duration & price stats
-- ─────────────────────────────────────────
SELECT
    COUNT(*)                                      AS total_tracks,
    ROUND(AVG(Milliseconds) / 60000.0, 2)         AS avg_duration_min,
    ROUND(MIN(Milliseconds) / 60000.0, 2)         AS min_duration_min,
    ROUND(MAX(Milliseconds) / 60000.0, 2)         AS max_duration_min,
    MIN(UnitPrice)                                AS min_price,
    MAX(UnitPrice)                                AS max_price,
    ROUND(AVG(UnitPrice), 2)                      AS avg_price,
    COUNT(CASE WHEN Composer IS NULL THEN 1 END)  AS missing_composer
FROM tracks;


-- ─────────────────────────────────────────
--  3. GENRE BREAKDOWN
-- ─────────────────────────────────────────
SELECT
    g.Name                           AS genre,
    COUNT(t.TrackId)                 AS track_count,
    ROUND(AVG(t.Milliseconds)/60000.0, 2) AS avg_duration_min,
    ROUND(100.0 * COUNT(t.TrackId) / (SELECT COUNT(*) FROM tracks), 1) AS pct
FROM genres g
LEFT JOIN tracks t ON t.GenreId = g.GenreId
GROUP BY g.GenreId
ORDER BY track_count DESC;


-- ─────────────────────────────────────────
--  4. MEDIA TYPE BREAKDOWN
-- ─────────────────────────────────────────
SELECT
    m.Name                           AS media_type,
    COUNT(t.TrackId)                 AS track_count,
    ROUND(100.0 * COUNT(t.TrackId) / (SELECT COUNT(*) FROM tracks), 1) AS pct
FROM media_types m
LEFT JOIN tracks t ON t.MediaTypeId = m.MediaTypeId
GROUP BY m.MediaTypeId
ORDER BY track_count DESC;


-- ─────────────────────────────────────────
--  5. TOP 10 ARTISTS BY ALBUM COUNT
-- ─────────────────────────────────────────
SELECT
    a.Name                 AS artist,
    COUNT(al.AlbumId)      AS albums,
    SUM(COUNT(al.AlbumId)) OVER () AS total_albums
FROM artists a
JOIN albums al ON al.ArtistId = a.ArtistId
GROUP BY a.ArtistId
ORDER BY albums DESC
LIMIT 10;


-- ─────────────────────────────────────────
--  6. TOP 10 ALBUMS BY TRACK COUNT
-- ─────────────────────────────────────────
SELECT
    al.Title               AS album,
    ar.Name                AS artist,
    COUNT(t.TrackId)       AS tracks
FROM albums al
JOIN artists ar ON ar.ArtistId = al.ArtistId
JOIN tracks  t  ON t.AlbumId   = al.AlbumId
GROUP BY al.AlbumId
ORDER BY tracks DESC
LIMIT 10;


-- ─────────────────────────────────────────
--  7. ARTISTS WITH NO ALBUMS (orphans)
-- ─────────────────────────────────────────
SELECT a.Name AS artist_no_album
FROM artists a
LEFT JOIN albums al ON al.ArtistId = a.ArtistId
WHERE al.AlbumId IS NULL;


-- ─────────────────────────────────────────
--  8. CUSTOMER DEMOGRAPHICS
-- ─────────────────────────────────────────
-- Customers per country
SELECT
    Country,
    COUNT(*) AS customers
FROM customers
GROUP BY Country
ORDER BY customers DESC;

-- NULL check on optional fields
SELECT
    COUNT(*)                                      AS total_customers,
    COUNT(CASE WHEN Company     IS NULL THEN 1 END) AS missing_company,
    COUNT(CASE WHEN Phone       IS NULL THEN 1 END) AS missing_phone,
    COUNT(CASE WHEN Fax         IS NULL THEN 1 END) AS missing_fax,
    COUNT(CASE WHEN State       IS NULL THEN 1 END) AS missing_state,
    COUNT(CASE WHEN PostalCode  IS NULL THEN 1 END) AS missing_postal
FROM customers;


-- ─────────────────────────────────────────
--  9. REVENUE OVERVIEW
-- ─────────────────────────────────────────
SELECT
    COUNT(*)              AS total_invoices,
    ROUND(SUM(Total), 2)  AS total_revenue,
    ROUND(AVG(Total), 2)  AS avg_invoice,
    ROUND(MIN(Total), 2)  AS min_invoice,
    ROUND(MAX(Total), 2)  AS max_invoice
FROM invoices;


-- ─────────────────────────────────────────
--  10. REVENUE BY YEAR
-- ─────────────────────────────────────────
SELECT
    STRFTIME('%Y', InvoiceDate)  AS year,
    COUNT(*)                     AS invoices,
    ROUND(SUM(Total), 2)         AS revenue
FROM invoices
GROUP BY year
ORDER BY year;


-- ─────────────────────────────────────────
--  11. REVENUE BY COUNTRY
-- ─────────────────────────────────────────
SELECT
    BillingCountry                AS country,
    COUNT(*)                      AS invoices,
    ROUND(SUM(Total), 2)          AS revenue,
    ROUND(AVG(Total), 2)          AS avg_invoice
FROM invoices
GROUP BY BillingCountry
ORDER BY revenue DESC
LIMIT 15;


-- ─────────────────────────────────────────
--  12. TOP 10 CUSTOMERS BY LIFETIME SPEND
-- ─────────────────────────────────────────
SELECT
    c.FirstName || ' ' || c.LastName  AS customer,
    c.Country,
    COUNT(i.InvoiceId)                AS total_orders,
    ROUND(SUM(i.Total), 2)            AS lifetime_spend
FROM customers c
JOIN invoices i ON i.CustomerId = c.CustomerId
GROUP BY c.CustomerId
ORDER BY lifetime_spend DESC
LIMIT 10;


-- ─────────────────────────────────────────
--  13. TOP 10 BEST-SELLING TRACKS
-- ─────────────────────────────────────────
SELECT
    t.Name                     AS track,
    ar.Name                    AS artist,
    SUM(ii.Quantity)           AS units_sold,
    ROUND(SUM(ii.UnitPrice * ii.Quantity), 2) AS revenue
FROM invoice_items ii
JOIN tracks  t  ON t.TrackId   = ii.TrackId
JOIN albums  al ON al.AlbumId  = t.AlbumId
JOIN artists ar ON ar.ArtistId = al.ArtistId
GROUP BY ii.TrackId
ORDER BY units_sold DESC
LIMIT 10;


-- ─────────────────────────────────────────
--  14. TOP 10 BEST-SELLING GENRES
-- ─────────────────────────────────────────
SELECT
    g.Name                                        AS genre,
    SUM(ii.Quantity)                              AS units_sold,
    ROUND(SUM(ii.UnitPrice * ii.Quantity), 2)     AS revenue
FROM invoice_items ii
JOIN tracks t ON t.TrackId = ii.TrackId
JOIN genres g ON g.GenreId = t.GenreId
GROUP BY g.GenreId
ORDER BY revenue DESC;


-- ─────────────────────────────────────────
--  15. EMPLOYEE / SALES REP PERFORMANCE
-- ─────────────────────────────────────────
SELECT
    e.FirstName || ' ' || e.LastName  AS rep,
    e.Title,
    COUNT(DISTINCT c.CustomerId)      AS customers_supported,
    COUNT(i.InvoiceId)                AS invoices,
    ROUND(SUM(i.Total), 2)            AS revenue_generated
FROM employees e
JOIN customers c ON c.SupportRepId = e.EmployeeId
JOIN invoices  i ON i.CustomerId   = c.CustomerId
GROUP BY e.EmployeeId
ORDER BY revenue_generated DESC;


-- ─────────────────────────────────────────
--  16. PLAYLIST STATS
-- ─────────────────────────────────────────
SELECT
    p.Name                    AS playlist,
    COUNT(pt.TrackId)         AS track_count
FROM playlists p
LEFT JOIN playlist_track pt ON pt.PlaylistId = p.PlaylistId
GROUP BY p.PlaylistId
ORDER BY track_count DESC;


-- ─────────────────────────────────────────
--  17. TRACKS THAT HAVE NEVER BEEN SOLD
-- ─────────────────────────────────────────
SELECT COUNT(*) AS unsold_tracks
FROM tracks t
LEFT JOIN invoice_items ii ON ii.TrackId = t.TrackId
WHERE ii.InvoiceLineId IS NULL;


-- ─────────────────────────────────────────
--  18. MONTHLY REVENUE TREND (all years)
-- ─────────────────────────────────────────
SELECT
    STRFTIME('%Y-%m', InvoiceDate) AS month,
    ROUND(SUM(Total), 2)           AS revenue,
    COUNT(*)                       AS invoices
FROM invoices
GROUP BY month
ORDER BY month;

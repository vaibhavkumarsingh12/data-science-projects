-- ============================================================
--  sTunes Database Schema - CREATE TABLE Statements
--  Complete DDL for all 11 tables
-- ============================================================

-- ─────────────────────────────────────────────────────────
--  1. ARTISTS TABLE
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS artists (
    ArtistId INTEGER PRIMARY KEY AUTOINCREMENT,
    Name VARCHAR(120) NOT NULL
);

-- ─────────────────────────────────────────────────────────
--  2. ALBUMS TABLE
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS albums (
    AlbumId INTEGER PRIMARY KEY AUTOINCREMENT,
    Title VARCHAR(160) NOT NULL,
    ArtistId INTEGER NOT NULL,
    FOREIGN KEY (ArtistId) REFERENCES artists (ArtistId)
);

-- ─────────────────────────────────────────────────────────
--  3. GENRES TABLE
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS genres (
    GenreId INTEGER PRIMARY KEY AUTOINCREMENT,
    Name VARCHAR(25)
);

-- ─────────────────────────────────────────────────────────
--  4. MEDIA_TYPES TABLE
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS media_types (
    MediaTypeId INTEGER PRIMARY KEY AUTOINCREMENT,
    Name VARCHAR(120)
);

-- ─────────────────────────────────────────────────────────
--  5. TRACKS TABLE (Core Catalog)
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tracks (
    TrackId INTEGER PRIMARY KEY AUTOINCREMENT,
    Name VARCHAR(200) NOT NULL,
    AlbumId INTEGER,
    MediaTypeId INTEGER NOT NULL,
    GenreId INTEGER,
    Composer VARCHAR(220),
    Milliseconds INTEGER,
    Bytes INTEGER,
    UnitPrice DECIMAL(10, 2),
    FOREIGN KEY (AlbumId) REFERENCES albums (AlbumId),
    FOREIGN KEY (MediaTypeId) REFERENCES media_types (MediaTypeId),
    FOREIGN KEY (GenreId) REFERENCES genres (GenreId)
);

-- ─────────────────────────────────────────────────────────
--  6. PLAYLISTS TABLE
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS playlists (
    PlaylistId INTEGER PRIMARY KEY AUTOINCREMENT,
    Name VARCHAR(120)
);

-- ─────────────────────────────────────────────────────────
--  7. PLAYLIST_TRACK TABLE (Junction/Many-to-Many)
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS playlist_track (
    PlaylistId INTEGER NOT NULL,
    TrackId INTEGER NOT NULL,
    PRIMARY KEY (PlaylistId, TrackId),
    FOREIGN KEY (PlaylistId) REFERENCES playlists (PlaylistId),
    FOREIGN KEY (TrackId) REFERENCES tracks (TrackId)
);

-- ─────────────────────────────────────────────────────────
--  8. EMPLOYEES TABLE (with self-referencing hierarchy)
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS employees (
    EmployeeId INTEGER PRIMARY KEY AUTOINCREMENT,
    LastName VARCHAR(20) NOT NULL,
    FirstName VARCHAR(20) NOT NULL,
    Title VARCHAR(30),
    ReportsTo INTEGER,
    BirthDate DATE,
    HireDate DATE,
    Address VARCHAR(70),
    City VARCHAR(40),
    State VARCHAR(40),
    Country VARCHAR(40),
    PostalCode VARCHAR(10),
    Phone VARCHAR(24),
    Fax VARCHAR(24),
    Email VARCHAR(60),
    FOREIGN KEY (ReportsTo) REFERENCES employees (EmployeeId)
);

-- ─────────────────────────────────────────────────────────
--  9. CUSTOMERS TABLE
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS customers (
    CustomerId INTEGER PRIMARY KEY AUTOINCREMENT,
    FirstName VARCHAR(40) NOT NULL,
    LastName VARCHAR(20) NOT NULL,
    Company VARCHAR(80),
    Address VARCHAR(70),
    City VARCHAR(40),
    State VARCHAR(40),
    Country VARCHAR(40),
    PostalCode VARCHAR(10),
    Phone VARCHAR(24),
    Fax VARCHAR(24),
    Email VARCHAR(60) NOT NULL,
    SupportRepId INTEGER,
    FOREIGN KEY (SupportRepId) REFERENCES employees (EmployeeId)
);

-- ─────────────────────────────────────────────────────────
--  10. INVOICES TABLE
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS invoices (
    InvoiceId INTEGER PRIMARY KEY AUTOINCREMENT,
    CustomerId INTEGER NOT NULL,
    InvoiceDate DATETIME NOT NULL,
    BillingAddress VARCHAR(70),
    BillingCity VARCHAR(40),
    BillingState VARCHAR(40),
    BillingCountry VARCHAR(40),
    BillingPostalCode VARCHAR(10),
    Total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (CustomerId) REFERENCES customers (CustomerId)
);

-- ─────────────────────────────────────────────────────────
--  11. INVOICE_ITEMS TABLE
-- ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS invoice_items (
    InvoiceLineId INTEGER PRIMARY KEY AUTOINCREMENT,
    InvoiceId INTEGER NOT NULL,
    TrackId INTEGER NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    Quantity INTEGER NOT NULL,
    FOREIGN KEY (InvoiceId) REFERENCES invoices (InvoiceId),
    FOREIGN KEY (TrackId) REFERENCES tracks (TrackId)
);

-- ─────────────────────────────────────────────────────────
--  INDEXES (for performance optimization)
-- ─────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_albums_artist ON albums(ArtistId);
CREATE INDEX IF NOT EXISTS idx_tracks_album ON tracks(AlbumId);
CREATE INDEX IF NOT EXISTS idx_tracks_genre ON tracks(GenreId);
CREATE INDEX IF NOT EXISTS idx_tracks_media ON tracks(MediaTypeId);
CREATE INDEX IF NOT EXISTS idx_invoices_customer ON invoices(CustomerId);
CREATE INDEX IF NOT EXISTS idx_invoice_items_invoice ON invoice_items(InvoiceId);
CREATE INDEX IF NOT EXISTS idx_invoice_items_track ON invoice_items(TrackId);
CREATE INDEX IF NOT EXISTS idx_customers_support_rep ON customers(SupportRepId);
CREATE INDEX IF NOT EXISTS idx_employees_reports_to ON employees(ReportsTo);

-- ============================================================
--  End of Schema
-- ============================================================

# Momentum Database Migrations Guide

This guide explains how to create and run migrations for the Momentum application, ensuring smooth database schema evolution over time.

## Understanding Migrations

Migrations are version-controlled changes to your database schema. Each migration should be:

- Self-contained
- Forward-compatible
- Reversible (we always use up/down pairs)
- Idempotent (safe to run multiple times)

Momentum uses SQLx migrations with SQL files stored in the `migrations` directory.

## Setup

### Installation

The simplest way to set up is using our setup script:

```bash
# Install SQLx CLI and other development tools
just setup
```

If needed, you can install SQLx CLI manually:

```bash
# Install SQLx CLI with SQLite support
cargo install sqlx-cli --no-default-features --features native-tls,sqlite
```

### Database Configuration

For SQLx CLI commands, create a `.env` file in your project root:

```dotenv
DATABASE_URL=sqlite:data/momentum.db
```

Note: The Momentum application itself uses `config.toml` for configuration, but SQLx CLI uses the `.env` file or environment variables.

## Creating Migrations

In Momentum, we always use reversible migrations with up/down pairs:

```bash
# Create a reversible migration
sqlx migrate add -r <descriptive_name>
```

This creates two files:

- `YYYYMMDDHHMMSS_descriptive_name.up.sql` - For applying the migration
- `YYYYMMDDHHMMSS_descriptive_name.down.sql` - For reverting the migration

Example:

```bash
sqlx migrate add -r add_habit_categories
```

## Writing Migrations

Each migration file should contain valid SQLite SQL statements:

```sql
-- Up migration (add_habit_categories.up.sql)
CREATE TABLE IF NOT EXISTS habit_categories (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    color TEXT
);

-- Add an index for faster searching
CREATE INDEX IF NOT EXISTS idx_habit_categories_name ON habit_categories(name);
```

```sql
-- Down migration (add_habit_categories.down.sql)
DROP INDEX IF EXISTS idx_habit_categories_name;
DROP TABLE IF EXISTS habit_categories;
```

### SQLite-Specific Features

#### FTS5 Full-Text Search

```sql
-- Up migration
CREATE VIRTUAL TABLE IF NOT EXISTS search_index USING fts5(
    title,
    content,
    tokenize='porter'
);

-- Down migration
DROP TABLE IF EXISTS search_index;
```

#### Vector Search with sqlite-vec

```sql
-- Up migration
-- Enable sqlite-vec extension
PRAGMA load_extension('sqlite_vec');

-- Create vector table
CREATE VIRTUAL TABLE IF NOT EXISTS embeddings USING vectors(
    id INTEGER PRIMARY KEY,
    embedding BLOB,
    dimensions INTEGER
);

-- Down migration
DROP TABLE IF EXISTS embeddings;
```

## Running Migrations

### Development (SQLx CLI)

```bash
# Run all pending migrations
sqlx migrate run

# Revert the most recent migration
sqlx migrate revert

# View migration status
sqlx migrate info
```

### Production (Momentum CLI)

```bash
# Using application's config.toml
momentum migrate
```

## Migration Workflow for Updates

1. Stop the application

   ```bash
   sudo systemctl stop momentum
   ```

2. Backup the database

   ```bash
   momentum backup
   ```

3. Run migrations

   ```bash
   momentum migrate
   ```

4. Start the application

   ```bash
   sudo systemctl start momentum
   ```

## Verifying Migrations

```bash
# Connect to the SQLite database
sqlite3 data/momentum.db

# View all tables
.tables

# View schema for a specific table
.schema habits

# View migration history
SELECT * FROM _sqlx_migrations ORDER BY version;

# Exit
.quit
```

## Troubleshooting

### Common Issues

1. **"Database is locked" errors**
   - Ensure the application isn't running when applying migrations
   - Check for other connections to the database

2. **Migration version conflicts**
   - Never modify an existing migration file after it's been applied
   - Always create a new migration for further changes

3. **SQLite ALTER TABLE limitations**
   - SQLite has limited ALTER TABLE support
   - For complex changes, you may need to create a new table, copy data, and drop the old table

### Quick Checks

```bash
# Check if SQLite database is valid
sqlite3 data/momentum.db "PRAGMA integrity_check;"
```

# Momentum

**Build momentum in your life by consistently focusing on your priorities and tracking your habits.**

Momentum is a minimalist, self-contained, self-hosted Rust web application designed for personal productivity, habit tracking, and accountability across multiple time horizons. Inspired by the "Snowball Effect" philosophy – the idea that small, consistent positive actions compound over time – this tool helps you define, track, and review your goals and habits across different timeframes (daily, weekly, monthly, quarterly, annually).

Built with Rust for performance and reliability, it operates as a single binary with an embedded SQLite database and all static assets, requiring minimal maintenance. It prioritizes server-side rendering with minimal JavaScript (using HTMX) for a clean, fast user experience focused on content and reflection.

## Philosophy: The Snowball Effect

The core idea behind Momentum is that significant progress isn't usually the result of massive, infrequent bursts of effort, but rather the aggregation of small, consistent actions. Like a snowball rolling downhill, doing the right things consistently, even on a small scale, builds momentum that leads to greater results over time.

This tool is designed to facilitate that process by:

1. **Clarifying Focus:** Encouraging you to define clear priorities at the start of each time period.
2. **Tracking Consistency:** Making habit tracking simple and visual, reinforcing the patterns you want to build (or break).
3. **Enabling Reflection:** Providing a structure for reviewing your progress, learning from past periods, and adjusting your course for the future.
4. **Promoting Simplicity:** Offering a system that is straightforward and encourages actual use. The best system is one you'll actually use.
5. **Enhancing Accountability:** Increasing self-awareness through private tracking and review.

## Overview

Momentum is a comprehensive personal productivity tool built to help you establish positive habits, maintain focus on priorities, and track your progress over time. The application follows a simple but powerful methodology: set intentions at the beginning of each time period, track your consistency throughout, and reflect on your progress at the end. This creates a virtuous cycle of continuous improvement.

The application is built as a single binary that includes all static assets, making deployment simple and maintenance minimal. It uses SQLite for data storage with advanced search capabilities through FTS5 and optional vector similarity search.

## Core Features

### User-Facing Features

* **Multi-horizon Planning & Review**: Set intentions, define priorities, and conduct structured reviews across:
  * **Daily**: Morning planning (e.g., top 3 priorities) and evening reflection.
  * **Weekly**: Planning focus areas and reviewing accomplishments/lessons.
  * **Monthly**: Goal setting and retrospective assessment.
  * **Quarterly**: Setting broader objectives and assessing progress.
  * **Annual**: Defining yearly vision and conducting a year-in-review.
* **Habit Tracking**:
  * Define and log both positive habits to build and negative habits to reduce.
  * Specify frequency (daily, specific days, x times per week).
  * Visualize streak data with the "Seinfeld method" calendar view ("Don't break the chain").
  * Analyze adherence rates and trends over time with charts.
  * Categorize habits (e.g., health, productivity, relationships).
* **Journaling & Notes**: Capture thoughts, reflections, and logs using Markdown within specific time periods or entries.
* **Progress Visualization**:
  * Streak calendars.
  * Charts showing habit consistency and adherence rates (via Chart.js).
  * Progress bars for goal completion (planned).
  * Heatmaps displaying activity intensity (planned).
  * Historical comparisons (planned).
* **Powerful Search**:
  * Quickly find past priorities, notes, or reflections using full-text search (SQLite FTS5).
  * Discover related entries through semantic similarity search (via `sqlite-vec`, optional).

### Technical & Architectural Features

* **Single Binary Deployment**: All assets (CSS, JS, etc.) embedded in one executable for simple deployment.
* **Minimalist & Self-Contained**: Designed for single-user self-hosting with minimal external dependencies.
* **CLI Interface**: Manage backend tasks like running the server, backups, restores, and migrations.
* **Server-Side Rendering**: HTML generated on the server using Maud templates for speed and simplicity.
* **Minimal JavaScript**: HTMX used for dynamic interactions without a heavy frontend framework.
* **Markdown Support**: Native rendering of Markdown using `pulldown-cmark`.
* **Simple Styling**: Water.css provides clean, classless styling out-of-the-box.
* **Embedded Database**: SQLite used for zero-configuration, file-based storage.
* **Type-Safe Database Access**: SQLx for compile-time checked SQL queries.
* **Easy Self-Hosting**: Streamlined installation script and manual steps provided for Ubuntu Server.
* **Systemd Integration**: Reliable service management via systemd unit file.
* **Caddy Support**: Simple HTTPS setup with automatic certificate management using Caddy.

## How It Works: The Workflow

The intended flow for using Momentum follows a cyclical pattern:

1. **Define Period:** At the start of a new Day, Week, Month, Quarter, or Year, create an entry for that period.
2. **Set Priorities/Goals:** Within that period's entry, list your key objectives, focus areas, or tasks.
3. **Track Habits:** Throughout the period (typically daily), log whether you adhered to your tracked habits.
4. **Record Notes/Journal:** Add reflections, insights, logs, or related information using Markdown.
5. **Review Period:** At the end of the period, use the application to review:
    * What priorities were accomplished?
    * How consistent were your habits? (View visualizations)
    * What were the key lessons learned?
6. **Plan Next Period:** Use the insights from your review to inform the priorities for the next cycle.

*(Screenshots or GIFs of the UI would go here once available)*

## Technology Stack

| Technology         | Purpose                | Justification                                                     |
| :----------------- | :--------------------- | :---------------------------------------------------------------- |
| **Rust** | Programming language   | Type safety, performance, memory safety, excellent tooling        |
| **Actix Web** | Web framework          | Mature, performant, well-documented async web server              |
| **SQLite** | Database               | Embedded, zero-configuration, file-based, perfect for single-user |
| **SQLite FTS5** | Full-text search       | Built-in SQLite extension for powerful keyword searching          |
| **sqlite-vec** | Vector similarity      | Enables semantic search ("find things like this") (optional)      |
| **SQLx** | SQL toolkit            | Compile-time checked, async SQL interactions without a heavy ORM  |
| **Maud** | HTML templating        | Compile-time checked HTML templates using Rust-like syntax        |
| **Water.css** | CSS framework          | Classless CSS for clean, responsive styling with minimal effort   |
| **HTMX** | Frontend interactivity | Enables dynamic UI updates via HTML attributes, minimizing JS     |
| **Chart.js** | Data visualization     | Lightweight, responsive charts for visualizing habit data         |
| **Pulldown-cmark** | Markdown rendering     | Pure Rust implementation for server-side markdown processing      |
| **Clap** | CLI framework          | Robust and easy-to-use library for building the CLI               |
| **rust-embed** | Static file embedding  | Includes assets (CSS, JS) directly in the binary                  |
| **Tokio** | Async Runtime          | Powering asynchronous operations in Actix Web and SQLx            |
| **Serde** | Serialization          | Data serialization/deserialization (e.g., for config, JSON)       |
| **Chrono** | Date/Time Handling     | For timestamps and date calculations                              |
| **Tracing** | Logging/Diagnostics    | Structured application logging                                    |
| **Thiserror/Anyhow**| Error Handling         | Robust error management                                           |

## Installation

### Prerequisites

* Ubuntu Server 22.04 LTS or newer (other Linux distros may work with adjustments)
* Caddy (recommended for HTTPS and reverse proxy, install separately first)
* Systemd (included standard in Ubuntu)
* `curl`, `tar` (usually pre-installed)
* If building from source: `build-essential`, `libsqlite3-dev`, `pkg-config`

### Option 1: Install Script (Recommended)

```bash
# Replace 'yourusername' with the actual GitHub username/repo owner
# Review the script content before executing if desired
curl -sSL [https://raw.githubusercontent.com/yourusername/momentum/main/install.sh](https://raw.githubusercontent.com/yourusername/momentum/main/install.sh) | bash
```

The script will attempt to:

1. Check system requirements.
2. Download the appropriate pre-built binary from the latest GitHub release.
3. Set up necessary directories (`/opt/momentum`, `/opt/momentum/data`, `/opt/momentum/backups`).
4. Copy the example configuration file to `/opt/momentum/config.toml`.
5. Configure and enable the systemd service (`momentum.service`).
6. Set up basic Caddy integration (requires Caddy pre-installed).
7. Start the Momentum service.

*Note: The script may prompt for `sudo` privileges.*

### Option 2: Manual Installation

1. **Download Release:** Get the latest `momentum-x86_64-unknown-linux-gnu.tar.gz` (or appropriate) binary package from the project's GitHub Releases page. Replace `yourusername` and the filename as needed.

    ```bash
    # Example: Adjust URL and filename based on the latest release
    VERSION="v0.1.0" # Replace with the actual version tag
    ARCH="x86_64-unknown-linux-gnu" # Adjust if needed
    wget [https://github.com/yourusername/momentum/releases/download/$](https://www.google.com/search?q=https://github.com/yourusername/momentum/releases/download/%24){VERSION}/momentum-${ARCH}.tar.gz
    tar -xzf momentum-${ARCH}.tar.gz -C /tmp/momentum-release
    ```

2. **Create Directories and Place Files:**

    ```bash
    sudo mkdir -p /opt/momentum/data /opt/momentum/backups
    sudo cp /tmp/momentum-release/momentum /opt/momentum/
    sudo cp /tmp/momentum-release/config.toml.example /opt/momentum/config.toml
    sudo chmod +x /opt/momentum/momentum
    # Optional: Create dedicated user (see Systemd section below)
    # sudo groupadd --system momentum
    # sudo useradd --system -g momentum -d /opt/momentum -s /bin/false momentum
    # sudo chown -R momentum:momentum /opt/momentum
    rm -rf /tmp/momentum-release # Clean up temporary files
    ```

3. **Configure:** Edit the configuration file to match your setup (especially paths, port, domain).

    ```bash
    sudo nano /opt/momentum/config.toml
    ```

4. **Set up Systemd Service:** Copy the service file included in the release archive or create it manually (see Deployment section below).

    ```bash
    # Assuming the service file is present in the extracted archive
    sudo cp /tmp/momentum-release/momentum.service /etc/systemd/system/
    # OR copy from source repo if building manually:
    # sudo cp caddy/momentum.conf /etc/caddy/conf.d/
    sudo systemctl daemon-reload
    sudo systemctl enable momentum # Start on boot
    sudo systemctl start momentum
    sudo systemctl status momentum # Verify it's running
    ```

5. **Configure Caddy (if using):** Copy the Caddy config snippet included in the release archive or create it manually (see Deployment section below). Edit the domain name.

    ```bash
    # Assuming the Caddy config is present in the extracted archive
    sudo cp /tmp/momentum-release/momentum.conf /etc/caddy/conf.d/
    # OR copy from source repo if building manually:
    # sudo cp caddy/momentum.conf /etc/caddy/conf.d/
    sudo nano /etc/caddy/conf.d/momentum.conf # Edit domain name!
    sudo systemctl reload caddy
    ```

### Option 3: Build From Source

1. **Install Rust:**

    ```bash
    curl --proto '=https' --tlsv1.2 -sSf [https://sh.rustup.rs](https://sh.rustup.rs) | sh
    source $HOME/.cargo/env # Or restart your shell
    ```

2. **Install Build Dependencies:**

    ```bash
    sudo apt update
    sudo apt install -y build-essential libsqlite3-dev pkg-config
    ```

3. **Clone Repository and Build:** Replace `yourusername`.

    ```bash
    git clone [https://github.com/yourusername/momentum.git](https://github.com/yourusername/momentum.git)
    cd momentum
    cargo build --release
    ```

4. **Deploy:** Follow steps 2-5 from the Manual Installation section, using `target/release/momentum` as the binary and copying `config.toml.example`, `systemd/momentum.service`, `caddy/momentum.conf` from the repository source directory.

## Configuration

Momentum uses a `config.toml` file located typically at `/opt/momentum/config.toml`.

```toml
# Example /opt/momentum/config.toml

[server]
host = "127.0.0.1"  # Address for the server to bind to (use 0.0.0.0 for all interfaces if needed)
port = 8080         # Port the internal server listens on (must match Caddy reverse_proxy target)

[database]
path = "/opt/momentum/data/momentum.db"  # Absolute path to the SQLite database file

[application]
name = "My Momentum"         # Application name displayed in the UI
backup_dir = "/opt/momentum/backups" # Absolute path for database backups
log_level = "info"        # Logging verbosity (trace, debug, info, warn, error)

[user] # Optional: Personalization settings
name = "Your Name"          # Display name in UI elements
start_week_on = "Monday"    # Or "Sunday" - for weekly views/planning

[caddy] # Optional: Used by install script and Caddy config examples
domain = "momentum.example.com"  # Your domain name for Caddy config (replace!)
```

The application loads this configuration at startup.

```rust
// Example loading logic (simplified from src/config.rs)
use serde::Deserialize;
use std::{fs, path::Path};

// Struct definitions (ServerConfig, DatabaseConfig, etc.) would be here...

#[derive(Deserialize, Debug, Clone)]
pub struct Config {
    pub server: ServerConfig,
    pub database: DatabaseConfig,
    pub application: ApplicationConfig,
    pub user: UserConfig,
    pub caddy: CaddyConfig,
}

impl Config {
    pub fn load(path_str: &str) -> Result<Self, Box<dyn std::error::Error>> {
        let path = Path::new(path_str);
        if !path.exists() {
            return Err(format!("Configuration file not found: {}", path_str).into());
        }
        let content = fs::read_to_string(path)?;
        let config: Config = toml::from_str(&content)?;
        Ok(config)
    }

    pub fn database_url(&self) -> String {
        format!("sqlite://{}", self.database.path)
    }
}
```

## CLI Usage

Momentum provides a command-line interface for essential backend operations:

```
USAGE:
    momentum [OPTIONS] [COMMAND]

OPTIONS:
    -c, --config <PATH>  Path to configuration file [default: /opt/momentum/config.toml]
    -h, --help           Print help information
    -V, --version        Print version information

COMMANDS:
    run         Start the web server (usually run via systemd)
    backup      Backup the application database
    restore     Restore the database from a backup file
    migrate     Run database migrations (apply schema changes)
    config      Manage application configuration settings (show/set - planned)
    help        Print this message or the help of the given subcommand(s)
```

### Common Commands

* **Start Server (Manual/Debug):**

    ```bash
    /opt/momentum/momentum run
    # Or specify config explicitly
    # /opt/momentum/momentum --config /path/to/your/config.toml run
    ```

* **Create Backup:** (Saves to `backup_dir` defined in `config.toml`)

    ```bash
    momentum backup
    # Or specify config if not in default location
    # momentum --config /path/to/config.toml backup
    ```

* **Restore Backup:**

    ```bash
    # Restore from a specific file (Stops the server if running!)
    # Make sure to stop the service first: sudo systemctl stop momentum
    momentum restore /opt/momentum/backups/backup_YYYYMMDD-HHMMSS.db
    # Restart the service after restore: sudo systemctl start momentum
    ```

* **Run Migrations:** (Apply pending database schema changes, needed after updates)

    ```bash
    # Make sure to stop the service first: sudo systemctl stop momentum
    momentum migrate
    # Restart the service after migrations: sudo systemctl start momentum
    ```

* **Manage Configuration (Planned):**

    ```bash
    momentum config show
    # momentum config set server.port 9000 # Example: requires implementation
    ```

## Deployment

### Systemd Service

Use a systemd service file (`/etc/systemd/system/momentum.service`) to manage the application process reliably.

```ini
[Unit]
Description=Momentum Personal Accountability Application
After=network.target # Ensure network is available before starting

[Service]
Type=simple

# --- User/Group ---
# Recommended: Create a dedicated non-root user/group for security
# Run these commands BEFORE enabling/starting the service:
# sudo groupadd --system momentum
# sudo useradd --system -g momentum -d /opt/momentum -s /bin/false momentum
# sudo chown -R momentum:momentum /opt/momentum
User=momentum
Group=momentum

# --- Execution ---
WorkingDirectory=/opt/momentum # Important for relative paths if used (like default db path)
# Ensure the ExecStart path and config path are correct
ExecStart=/opt/momentum/momentum run --config /opt/momentum/config.toml
Restart=on-failure # Restart if the process exits unexpectedly
RestartSec=10      # Wait 10 seconds before attempting restart

# --- Logging ---
StandardOutput=journal # Redirect stdout to systemd journal
StandardError=journal  # Redirect stderr to systemd journal

# --- Security Hardening (Recommended) ---
ProtectSystem=strict     # Make /usr, /boot, /etc read-only for the service
PrivateTmp=true          # Use a private /tmp directory, not shared
ProtectHome=true         # Make user home directories inaccessible
NoNewPrivileges=true     # Prevent the service or its children from gaining new privileges
# IMPORTANT: Allow writing ONLY to necessary directories (database and backups)
# Ensure these paths match your config.toml
ReadWritePaths=/opt/momentum/data /opt/momentum/backups
# Drop unnecessary capabilities for better security
CapabilityBoundingSet=~CAP_SYS_ADMIN CAP_NET_ADMIN CAP_AUDIT_WRITE

[Install]
WantedBy=multi-user.target # Start automatically on system boot
```

**Manage the service:**

* `sudo systemctl daemon-reload` (Run after creating or editing the `.service` file)
* `sudo systemctl enable momentum` (To make it start automatically on boot)
* `sudo systemctl start momentum`
* `sudo systemctl stop momentum`
* `sudo systemctl restart momentum`
* `sudo systemctl status momentum`

### Caddy Configuration

Caddy simplifies serving the application over HTTPS with automatic certificate management. Add a configuration block to your main `Caddyfile` or create a file like `/etc/caddy/conf.d/momentum.conf`.

```caddy
# /etc/caddy/conf.d/momentum.conf
# Replace momentum.example.com with your actual domain name

momentum.example.com {
    # Enable response compression for better performance
    encode gzip zstd

    # Proxy requests to the backend Momentum app running internally on localhost:8080
    # Ensure the port here (8080) matches 'server.port' in config.toml
    reverse_proxy localhost:8080

    # --- Recommended Security Headers ---
    header {
        # Force HTTPS for 1 year, include subdomains, allow browser preloading
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        # Prevent the site from being embedded in iframes on other domains (Clickjacking protection)
        X-Frame-Options "DENY"
        # Prevent browsers from interpreting files as a different MIME type
        X-Content-Type-Options "nosniff"
        # Enable browser's built-in XSS protection
        X-XSS-Protection "1; mode=block"
        # Control how much referrer information is sent with requests
        Referrer-Policy "strict-origin-when-cross-origin"
        # Define allowed sources for content (adjust if using external JS/CSS/fonts/images)
        # Allows content from the same origin ('self'), inline styles (needed by some frameworks), data URIs for images
        Content-Security-Policy "default-src 'self'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self'; object-src 'none'; frame-ancestors 'none'; form-action 'self';"
        # Explicitly disable browser features not typically needed
        Permissions-Policy "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=()"
        # Remove Caddy's default Server header for slight obfuscation
        -Server
    }
}
```

Reload Caddy after creating or changing the configuration: `sudo systemctl reload caddy`.

## Usage Examples

### Setting Daily Priorities

1. Navigate to the "Daily" view or planning section.
2. Enter your top 1-3 priorities for the day in the designated area.
3. Optionally, add secondary tasks or notes for the day.
4. As you complete priorities throughout the day, mark them as done in the UI.
5. At the end of the day, use the reflection section to note accomplishments, challenges, or thoughts.

### Tracking Habits

1. Go to the "Habits" section and click "Add Habit".
2. Define the habit name (e.g., "Read for 30 minutes").
3. Set its frequency (e.g., Daily, Mon/Wed/Fri, 3 times per week).
4. Assign a category (e.g., "Learning", "Health").
5. Save the habit.
6. Each day (or as appropriate), visit the habit tracking interface (e.g., daily view) and check off the habits you completed.
7. View the streak calendar or charts in the "Habits" section to see your consistency over time.

### Quarterly Review

1. Navigate to the "Quarterly" view or review section at the end of a quarter.
2. Access the review template provided.
3. Reflect on the goals you set at the beginning of the quarter: What was achieved? What wasn't? Why?
4. Review your habit tracking data for the quarter: Which habits were consistent? Where did you struggle? What patterns emerge?
5. Synthesize key learnings and insights from the past three months.
6. Use these reflections to set clear, adjusted objectives and focus areas for the upcoming quarter.

## Project Structure

```
.
├── .github/workflows/      # CI/CD workflows (e.g., ci.yml)
├── Cargo.toml              # Project manifest (dependencies, metadata)
├── config.toml.example     # Example configuration file
├── install.sh              # Installation script (optional)
├── LICENSE                 # Project license file (e.g., MIT)
├── migrations/             # SQLx database migrations (e.g., V1__initial.sql)
│   └── *.sql
├── src/
│   ├── main.rs             # Application entry point (CLI parsing, setup)
│   ├── cli/                # CLI command modules (run, backup, restore, migrate)
│   ├── config.rs           # Configuration loading logic (structs, loading fn)
│   ├── db/                 # Database interaction layer (connection, queries, models, migrations)
│   ├── errors.rs           # Custom error types and conversions
│   ├── server.rs           # Actix Web server setup (app factory, routes, middleware)
│   ├── routes/             # Actix Web route handlers (grouped by feature: pages, habits, api)
│   ├── templates/          # Maud HTML template functions (layout, pages, components)
│   ├── static_files.rs     # Logic for serving embedded static assets
│   ├── markdown.rs         # Markdown rendering utilities
│   └── charts.rs           # Logic for preparing data for Chart.js (visualization)
├── static/                 # Static assets embedded into binary (CSS, JS libraries)
│   ├── water.min.css
│   ├── htmx.min.js
│   └── chart.min.js
├── systemd/                # Systemd service file definition
│   └── momentum.service
└── caddy/                  # Caddy configuration example
    └── momentum.conf
```

## Implementation Details

*(Selected code examples to illustrate key concepts)*

### Dependencies (`Cargo.toml` Highlights)

```toml
[dependencies]
# Web Framework & Async Runtime
actix-web = "4.4"
tokio = { version = "1", features = ["full"] }

# Database
sqlx = { version = "0.7", features = ["runtime-tokio-rustls", "sqlite", "macros", "chrono", "migrate"] }
rusqlite = { version = "0.31", features = ["backup", "bundled"] } # For backup CLI simplicity
# sqlite-vec = "0.2" # Optional, for vector search
# zerocopy = "0.7"   # Optional, dependency for sqlite-vec

# Templating & Frontend
maud = { version = "0.25", features = ["actix-web"] }
htmx = "..." # Note: HTMX is JS, loaded via static files, not a direct Rust dependency
pulldown-cmark = "0.9" # Check for latest version

# CLI
clap = { version = "4.4", features = ["derive"] }

# Static Assets
rust-embed = "8.0"
mime_guess = "2.0"

# Configuration & Serialization
toml = "0.8"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0" # For Chart.js data usually

# Utilities
chrono = { version = "0.4", features = ["serde"] }
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }
thiserror = "1.0"
anyhow = "1.0"
```

### Static File Embedding (`static_files.rs`)

```rust
use actix_web::{web, HttpResponse, Responder};
use rust_embed::RustEmbed;
use std::borrow::Cow;

#[derive(RustEmbed)]
#[folder = "static/"] // Path relative to Cargo.toml
struct Asset;

// Handler to serve embedded static files
pub async fn serve_static(path: web::Path<String>) -> impl Responder {
    let filename = path.into_inner();
    match Asset::get(&filename) {
        Some(content) => {
            let mime = mime_guess::from_path(&filename).first_or_octet_stream();
            // Use Cow::Borrowed to avoid cloning the static asset data from memory
            HttpResponse::Ok()
                .content_type(mime.as_ref())
                .body(Cow::Borrowed(content.data))
        }
        None => HttpResponse::NotFound().body("Static file not found"),
    }
}

// In server.rs, register the route within App::new()...
// .route("/static/{filename:.*}", web::get().to(static_files::serve_static))
```

### Maud Templating with HTMX (`templates/layout.rs`)

```rust
// Example: templates/layout.rs
use maud::{html, Markup, PreEscaped, DOCTYPE};
use crate::config::Config; // Assuming you pass config for app name etc.

pub fn base_layout(title: &str, content: Markup, app_name: &str) -> Markup {
    html! {
        (DOCTYPE)
        html lang="en" {
            head {
                meta charset="utf-8";
                meta name="viewport" content="width=device-width, initial-scale=1";
                // Use app_name from config and specific page title
                title { (app_name) " - " (title) }
                // Link to embedded static CSS
                link rel="stylesheet" href="/static/water.min.css";
                // Include embedded static JS libraries, defer loading
                script src="/static/htmx.min.js" defer {}
                script src="/static/chart.min.js" defer {}
                // Link any custom CSS/JS here if needed
                // link rel="stylesheet" href="/static/custom.css";
            }
            // Apply hx-boost="true" to the body for HTMX progressive enhancement
            // This makes navigation links use AJAX instead of full page reloads
            body hx-boost="true" {
                header {
                    // Main application title/link to dashboard
                    h1 { a href="/" { (app_name) } }
                    nav {
                        // Main navigation links
                        a href="/dashboard" { "Dashboard" } // Example link
                        a href="/habits" { "Habits" }
                        a href="/priorities" { "Priorities" } // Example link
                        a href="/review" { "Reviews" }       // Example link
                        a href="/journal" { "Journal" }     // Example link
                    }
                }
                // Main content area where page-specific content is injected
                main class="container" { // Simple container class maybe provided by Water.css
                    (content)
                }
                footer {
                    // Simple footer
                    p { "Generated on: " (chrono::Local::now().format("%Y-%m-%d %H:%M:%S")) }
                }
            }
        }
    }
}
```

### Database Query Example (`db/queries.rs` - Simplified)

```rust
use sqlx::SqlitePool;
use crate::db::models::Habit; // Assuming models defined in db/models.rs
use crate::errors::AppError; // Assuming custom error type defined in errors.rs
use anyhow::Context; // Using anyhow for context on errors

// Fetch all habits, ordered by name
pub async fn get_all_habits(pool: &SqlitePool) -> Result<Vec<Habit>, AppError> {
    let habits = sqlx::query_as!(
            Habit,
            r#"
            SELECT id, name, frequency, category, created_at
            FROM habits
            ORDER BY name ASC
            "# // Using raw string literal for multi-line SQL
        )
        .fetch_all(pool)
        .await
        .context("Failed to fetch habits from database")?; // Add context using anyhow
        // The '?' implicitly converts the underlying error (sqlx::Error + context)
        // into AppError if `From<anyhow::Error>` is implemented for AppError

    Ok(habits)
}

// Add a new habit and return its ID
pub async fn add_habit(pool: &SqlitePool, name: &str, frequency: &str, category: Option<&str>) -> Result<i64, AppError> {
    let result = sqlx::query!(
        r#"
        INSERT INTO habits (name, frequency, category)
        VALUES (?, ?, ?)
        "#, // Parameters are bound positionally and safely by SQLx
        name, frequency, category // Option<&str> works directly
    )
    .execute(pool)
    .await
    .context("Failed to insert new habit into database")?;

    Ok(result.last_insert_rowid())
}
```

## Development

### Building the Project

* **Requirements:**
  * Rust (latest stable recommended - check `rust-toolchain.toml` or `Cargo.toml` for Minimum Supported Rust Version (MSRV) if specified)
  * SQLite 3.35.0+ development headers (`libsqlite3-dev` on Debian/Ubuntu, `sqlite-devel` on Fedora)
  * `pkg-config`
* **Common Commands:**

    ```bash
    cargo check           # Quick compilation check without building executable
    cargo build           # Development build (slower, larger binary, better debug info)
    cargo build --release # Optimized release build (faster, smaller binary)
    cargo run             # Build and run the development version (passes args after --)
    cargo test            # Run all unit and integration tests
    cargo fmt             # Format code according to Rust style guidelines
    cargo fmt --check     # Check if code is formatted correctly (for CI)
    cargo clippy          # Run the Rust linter for potential issues and style improvements
    cargo clippy -- -D warnings # Run linter and treat all warnings as errors (stricter check)
    ```

### Running Migrations

Database schema changes are managed using SQLx CLI and SQL files located in the `migrations` directory. Migrations ensure the database schema evolves correctly across different versions of the application.

1. **Install SQLx CLI (one-time setup):**

    ```bash
    # Installs sqlx-cli binary, using native TLS and SQLite features
    cargo install sqlx-cli --no-default-features --features native-tls,sqlite
    ```

2. **Set `DATABASE_URL` Environment Variable:** The CLI needs to know where your *development* database is.

    ```bash
    # Example for a local development database file in the project root
    export DATABASE_URL="sqlite://dev-momentum.db"
    # Or if your config points elsewhere:
    # export DATABASE_URL="sqlite:///path/to/your/dev/database.db"
    ```

3. **Create a New Migration File:** Give it a descriptive name. SQLx CLI will create a pair of `.sql` files (up and down) in the `migrations` directory with a timestamp prefix.

    ```bash
    # Example: Create migration files for adding notes to habits
    sqlx migrate add add_habit_notes
    # This creates files like: migrations/YYYYMMDDHHMMSS_add_habit_notes.sql
    ```

4. **Edit the `.sql` Migration File:** Write the SQL statements needed to apply the schema change in the `YYYYMMDDHHMMSS_description.sql` file. Optionally, add SQL to revert the change in the corresponding `.down.sql` file (though down migrations are less common for SQLite).

    ```sql
    -- Example: migrations/YYYYMMDDHHMMSS_add_habit_notes.sql
    -- Add up migration script here
    ALTER TABLE habits ADD COLUMN notes TEXT;
    ```

5. **Apply Pending Migrations:** Run the migrations against your development database.

    ```bash
    # Ensure DATABASE_URL is set correctly
    sqlx migrate run
    ```

6. **Revert Last Migration (Use with Caution):** If needed during development, you can revert the last applied migration *if* you created a corresponding `.down.sql` file.

    ```bash
    # sqlx migrate revert
    ```

*Note: Production migrations should be run via the application's `momentum migrate` CLI command, typically during the update process.*

## CI/CD

A basic GitHub Actions workflow (`.github/workflows/ci.yml`) for testing, linting, formatting checks, and building release binaries on tags.

```yaml
name: Rust CI/CD

on:
  push:
    branches: [ "main" ] # Trigger on pushes to the main branch
    tags: [ 'v*.*.*' ] # Trigger on version tags like v1.0.0, v0.2.1 etc.
  pull_request:
    branches: [ "main" ] # Trigger on pull requests targeting the main branch

env:
  CARGO_TERM_COLOR: always
  # Use an in-memory SQLite database for faster CI tests that need a DB
  DATABASE_URL: "sqlite::memory:"
  # Or use a file if tests require persistence across steps (less common)
  # DATABASE_URL: "sqlite://momentum_ci.db"

jobs:
  test_lint_fmt:
    name: Test, Lint & Format Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Rust stable toolchain
        uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
          override: true
          components: rustfmt, clippy # Install formatting and linting tools
      - name: Install SQLite dev headers (needed for sqlx build)
        run: sudo apt-get update && sudo apt-get install -y libsqlite3-dev pkg-config
      - name: Install SQLx CLI (needed for migrations)
        run: cargo install sqlx-cli --no-default-features --features native-tls,sqlite
      # Run migrations if tests depend on the latest schema
      # Might be skipped if DATABASE_URL is :memory: and schema is created in tests
      # - name: Run Migrations
      #   run: sqlx migrate run
      - name: Run cargo check (quick compilation check)
        uses: actions-rs/cargo@v1
        with: { command: check }
      - name: Run cargo fmt check (verify formatting)
        uses: actions-rs/cargo@v1
        with: { command: fmt, args: --check }
      - name: Run cargo clippy (linting, treat warnings as errors)
        uses: actions-rs/cargo@v1
        with: { command: clippy, args: -- -D warnings }
      - name: Run cargo test
        uses: actions-rs/cargo@v1
        with: { command: test }

  create_release:
    name: Create GitHub Release Draft
    needs: test_lint_fmt # Run only if tests pass
    if: startsWith(github.ref, 'refs/tags/v') # Run only for version tags
    runs-on: ubuntu-latest
    outputs:
      upload_url: ${{ steps.create_release.outputs.upload_url }} # Pass upload URL to next job
    steps:
      - name: Create Release
        id: create_release
        uses: softprops/action-gh-release@v1 # Use a standard action for creating releases
        with:
          tag_name: ${{ github.ref_name }}
          name: Release ${{ github.ref_name }}
          body: "See CHANGELOG.md for details." # Add release notes here or link to file
          draft: true # Create as draft first, publish manually or change to false
          prerelease: false # Mark as pre-release if needed
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} # Provided by GitHub Actions

  build_release_asset:
    name: Build & Upload Release Asset (${{ matrix.target }})
    needs: create_release # Depends on the release draft being created
    if: startsWith(github.ref, 'refs/tags/v') # Run only for version tags
    runs-on: ubuntu-latest
    strategy:
      matrix:
        # Define target platforms to build for
        target: [ x86_64-unknown-linux-gnu ] # Common 64-bit Linux
        # Add more targets like:
        # target: [ aarch64-unknown-linux-gnu ] # ARM64 Linux (e.g., Raspberry Pi 4+)
        # target: [ x86_64-unknown-linux-musl ] # Statically linked Linux binary
        # target: [ x86_64-apple-darwin ] # macOS Intel
        # target: [ aarch64-apple-darwin ] # macOS Apple Silicon
        # target: [ x86_64-pc-windows-gnu ] # Windows MinGW
        # target: [ x86_64-pc-windows-msvc ] # Windows MSVC
    steps:
      - uses: actions/checkout@v4
      - name: Install Rust stable toolchain for target
        uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
          override: true
          target: ${{ matrix.target }}
      # Install cross-compilation tools if needed (e.g., for MUSL)
      # - name: Install cross-compilation tools (MUSL example)
      #   if: matrix.target == 'x86_64-unknown-linux-musl'
      #   run: sudo apt-get update && sudo apt-get install -y musl-tools
      - name: Install SQLite dev headers (required for linking)
        run: sudo apt-get update && sudo apt-get install -y libsqlite3-dev pkg-config
      - name: Build release binary for target
        uses: actions-rs/cargo@v1
        with:
          use-cross: false # Set to true if using 'cross' tool for complex cross-compilation
          command: build
          args: --release --locked --target ${{ matrix.target }}
      - name: Package release artifact
        run: |
          # Define base directory for target output
          TARGET_DIR="target/${{ matrix.target }}/release"
          # Strip debug symbols to reduce binary size (optional, not for Windows MSVC usually)
          strip "${TARGET_DIR}/momentum" || true
          # Create a staging directory for the archive contents
          RELEASE_NAME="momentum-${{ github.ref_name }}-${{ matrix.target }}"
          mkdir -p "staging/${RELEASE_NAME}"
          # Copy essential files into the staging directory
          cp "${TARGET_DIR}/momentum" "staging/${RELEASE_NAME}/"
          cp config.toml.example "staging/${RELEASE_NAME}/"
          cp systemd/momentum.service "staging/${RELEASE_NAME}/" # Include deployment helpers
          cp caddy/momentum.conf "staging/${RELEASE_NAME}/"
          cp LICENSE "staging/${RELEASE_NAME}/"
          # Create the compressed archive
          (cd staging && tar czf "../${RELEASE_NAME}.tar.gz" "${RELEASE_NAME}")
          # Set environment variable for upload step
          echo "ASSET_PATH=${RELEASE_NAME}.tar.gz" >> $GITHUB_ENV
          echo "ASSET_NAME=${RELEASE_NAME}.tar.gz" >> $GITHUB_ENV
      - name: Upload Release Asset
        uses: actions/upload-release-asset@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          upload_url: ${{ needs.create_release.outputs.upload_url }} # Get URL from the 'create_release' job
          asset_path: ./${{ env.ASSET_PATH }} # Path to the archive file
          asset_name: ${{ env.ASSET_NAME }} # Name of the asset in the GitHub release
          asset_content_type: application/gzip # Mime type of the asset

```

## Maintenance

### Backups

Regular backups are critical for any self-hosted application. Momentum provides a CLI command for this.

**Manual Backup:**

```bash
momentum backup
# This will create a timestamped .db file in the directory specified
# by 'application.backup_dir' in your config.toml
```

**Automated Backups (Example using cron):**

It's highly recommended to automate backups. Here's an example using `cron` to run a backup nightly at 2:30 AM:

1. Edit the crontab for the root user (or the user running Momentum if not root, adjusting paths):

    ```bash
    sudo crontab -e
    ```

2. Add the following line (adjust the path to the `momentum` binary if it's not in the system PATH for the cron environment):

    ```cron
    # m h  dom mon dow   command
    30 2 * * * /opt/momentum/momentum backup --config /opt/momentum/config.toml >> /var/log/momentum_backup.log 2>&1
    ```

    * `30 2 * * *`: Runs at 2:30 AM every day.
    * `/opt/momentum/momentum backup`: Executes the backup command. Explicitly provide `--config` if needed.
    * `>> /var/log/momentum_backup.log 2>&1`: Appends standard output and standard error to a log file for monitoring. Ensure this log file exists or can be created, and consider log rotation.

**Backup Implementation Note:**

The `momentum backup` command typically uses SQLite's [Online Backup API](https://www.sqlite.org/backup.html) via the `rusqlite` crate. This allows creating a consistent snapshot of the database even while the application is running, minimizing downtime.

```rust
// Simplified logic sketch from cli/backup.rs using rusqlite
use crate::config::Config;
use std::{fs, path::Path, time::Duration};
use anyhow::{Context, Result};

pub async fn execute(config: &Config) -> Result<()> {
    let timestamp = chrono::Local::now().format("%Y%m%d-%H%M%S");
    let backup_filename = format!("backup_{}.db", timestamp);
    let backup_dir = Path::new(&config.application.backup_dir);
    let backup_path = backup_dir.join(&backup_filename);
    let db_path = Path::new(&config.database.path);

    // Ensure backup directory exists
    fs::create_dir_all(backup_dir)
        .context(format!("Failed to create backup directory: {:?}", backup_dir))?;

    println!("Starting backup from '{}' to '{}'", db_path.display(), backup_path.display());

    // Open connections using blocking API (suitable for CLI command)
    let source_conn = rusqlite::Connection::open(db_path)
        .context("Failed to open source database for backup")?;
    let mut dest_conn = rusqlite::Connection::open(&backup_path)
        .context("Failed to create/open backup destination database file")?;

    // Perform the online backup
    let backup = rusqlite::backup::Backup::new(&source_conn, &mut dest_conn)
        .context("Failed to initialize SQLite backup process")?;

    // Run the backup to completion. Adjust step count and sleep duration as needed.
    // `None` means no progress reporting callback.
    backup.run_to_completion(100, Duration::from_millis(250), None)
        .context("Database backup operation failed")?;

    // Close connections explicitly (optional, happens on drop too)
    drop(backup);
    dest_conn.close().map_err(|(_, e)| e).context("Failed to close backup destination connection")?;
    source_conn.close().map_err(|(_, e)| e).context("Failed to close source database connection")?;


    println!("Backup completed successfully: {}", backup_path.display());
    Ok(())
}
```

### Updates

Follow these steps to update Momentum to a newer version:

1. **(Crucial) Backup Your Data:** Before starting any update, create a backup.

    ```bash
    momentum backup
    ```

2. **Get the New Version:**
    * **Option A (Recommended):** Download the latest pre-compiled binary package (`.tar.gz`) for your architecture from the project's GitHub Releases page.
    * **Option B:** Build the latest version from the source code (`git pull` and `cargo build --release`).
3. **Stop the Momentum Service:** Prevent conflicts during file replacement and migration.

    ```bash
    sudo systemctl stop momentum
    ```

4. **Replace Files:**
    * Replace the old executable binary (`/opt/momentum/momentum`) with the new one you downloaded or built.

        ```bash
        # Example assuming new binary is unpacked to /tmp/new-momentum
        sudo cp /tmp/new-momentum/momentum /opt/momentum/
        sudo chmod +x /opt/momentum/momentum
        # Ensure ownership is correct if using a dedicated user
        # sudo chown momentum:momentum /opt/momentum/momentum
        ```

    * **Check for Configuration/Service File Changes:** Review the release notes and compare the `config.toml.example`, `systemd/momentum.service`, and `caddy/momentum.conf` files in the new version with your existing ones (`/opt/momentum/config.toml`, `/etc/systemd/system/momentum.service`, `/etc/caddy/conf.d/momentum.conf`). Manually merge any necessary changes into your live configuration files. *Do not simply overwrite your existing config!*
5. **(Crucial) Run Database Migrations:** If the new version includes database schema changes (check the release notes!), run the migration command.

    ```bash
    momentum migrate
    # Or specify config if needed:
    # momentum --config /opt/momentum/config.toml migrate
    ```

6. **Restart the Momentum Service:**

    ```bash
    sudo systemctl start momentum
    ```

7. **Verify the Update:** Check the service status and application logs.

    ```bash
    sudo systemctl status momentum
    sudo journalctl -u momentum -f --since "1 minute ago" # View recent logs
    ```

    Access the application in your browser to ensure it's working correctly.

## Troubleshooting

### Viewing Logs

Systemd directs application output (stdout and stderr) to the system journal. Use `journalctl` to view logs:

```bash
# View live logs (follow output as it happens)
sudo journalctl -u momentum -f

# View all logs for the service since the system last booted
sudo journalctl -u momentum -b

# View the last N lines of logs
sudo journalctl -u momentum -n 50 # Show last 50 lines

# View logs with specific priority (e.g., errors and critical)
sudo journalctl -u momentum -p err..crit # Range from error (3) to critical (2)

# View logs within a specific time range
sudo journalctl -u momentum --since "yesterday" --until "today"
sudo journalctl -u momentum --since "1 hour ago"

# Filter logs using grep (less efficient than journalctl filtering)
sudo journalctl -u momentum | grep "ERROR"
```

For more detailed logs, change `log_level` in `/opt/momentum/config.toml` from `"info"` to `"debug"` or `"trace"`, then restart the service (`sudo systemctl restart momentum`). Remember to set it back to `"info"` or `"warn"` afterwards to avoid excessive logging.

### Common Issues

* **Service Fails to Start (`Active: failed` in `systemctl status`):**
  * **Check Logs:** The first step is always `sudo journalctl -u momentum -b -n 50`. Look for specific error messages (panic, permission denied, address already in use, config error).
  * **Permission Denied:**
    * Ensure the `User` specified in `momentum.service` (e.g., `momentum`) has read+execute permission on `/opt/momentum/momentum`.
    * Ensure the user has read permission on `/opt/momentum/config.toml`.
    * Ensure the user has read *and* write permission on the directory containing the database (`/opt/momentum/data/`) and the backup directory (`/opt/momentum/backups/`). Check directory ownership (`ls -ld /opt/momentum/data`) and permissions (`ls -l /opt/momentum/momentum`).
    * Verify `ReadWritePaths` in `momentum.service` includes the correct data and backup directories.
  * **Address Already in Use / Port Conflict:** Ensure `server.port` in `config.toml` (e.g., 8080) is not being used by another application. Check with `sudo ss -tulnp | grep LISTEN | grep <port_number>`. If it is, change the port in `config.toml` and update the `reverse_proxy` directive in your Caddy config accordingly, then restart Momentum and reload Caddy.
  * **Configuration File Error:** Invalid TOML syntax in `config.toml` or the file is missing/unreadable at the path specified in `ExecStart --config`. Validate the TOML syntax.
  * **Database Path Incorrect/Inaccessible:** Verify `database.path` in `config.toml` points to the correct *file* and that the *directory* containing it exists and is writable by the service user.
* **Cannot Access Application via Domain Name (e.g., 502 Bad Gateway from Caddy):**
  * **Verify Momentum Service:** Is Momentum running? `sudo systemctl status momentum`. If not, troubleshoot why (see above).
  * **Verify Caddy Service:** Is Caddy running and loaded? `sudo systemctl status caddy`, `sudo systemctl reload caddy`. Check Caddy logs: `sudo journalctl -u caddy -f`.
  * **Check Caddy `reverse_proxy`:** Does the address in Caddy's `reverse_proxy` directive (e.g., `localhost:8080`) exactly match the `host` and `port` Momentum is configured to listen on in `config.toml`? If Momentum binds to `127.0.0.1`, Caddy must proxy to `localhost` or `127.0.0.1`.
  * **DNS:** Ensure your domain name's DNS A/AAAA records correctly point to your server's public IP address.
  * **Firewall:** Ensure your server's firewall (e.g., `ufw`) allows incoming connections on ports 80 (for HTTP) and 443 (for HTTPS). Example: `sudo ufw status`, `sudo ufw allow 80/tcp`, `sudo ufw allow 443/tcp`.
* **Migrations Fail (`momentum migrate`):**
  * Check the command output and application logs (`journalctl`) for specific SQL errors reported by SQLx or SQLite.
  * Ensure the service is stopped (`sudo systemctl stop momentum`) before running migrations manually. The database file might be locked if the service is running.
  * Verify the database file isn't corrupted (try opening it with `sqlite3 /opt/momentum/data/momentum.db ".tables"`). Restore from backup if necessary.
* **Static Assets (CSS/JS) Not Loading (404 Errors in Browser Console):**
  * Check the `/static/{filename:.*}` route registration in `src/server.rs` points to the correct handler (`static_files::serve_static`).
  * Verify the `#[folder = "static/"]` path in `src/static_files.rs` is correct relative to `Cargo.toml`.
  * Ensure the static files (`water.min.css`, `htmx.min.js`, etc.) exist in the `static/` directory at build time so `rust-embed` includes them.
  * Check Caddy configuration for any rules that might be interfering with `/static/` requests (unlikely with the provided example).

## Roadmap

*(Example - Adapt based on actual plans)*

* [x] **v0.1**: Core habit tracking (define, log, daily view) & daily priorities. Basic structure. FTS5 Search. CLI for run/backup/migrate. Systemd/Caddy deployment.
* [ ] **v0.2**: Weekly/Monthly planning & review templates. Basic streak visualization (calendar view). Improved charting (consistency rates).
* [ ] **v0.3**: Quarterly/Annual planning & review interfaces. Journaling/Notes integration with search. Habit categorization.
* [ ] **v0.4**: Enhanced analytics and visualizations (trends, heatmaps). Vector similarity search (`sqlite-vec`) for related notes/entries. Data export options.
* [ ] **v0.5**: UI/UX refinements. User profile settings (start day of week etc.). Potential read-only calendar integration.
* [ ] **v1.0**: Stable release covering all core features, time horizons, and robust error handling/testing.

## Inspiration and Resources

* The "Don't Break the Chain" method (often attributed to Jerry Seinfeld)
* Warren Buffett's "Snowball effect" philosophy regarding compounding.
* Concepts from "Atomic Habits" by James Clear on habit formation.
* Principles of structured reflection and review used in agile methodologies and personal development.
* Existing habit tracking and productivity tools (for ideas on features and UI).

## License

This project is licensed under the MIT License - see the LICENSE file for details.

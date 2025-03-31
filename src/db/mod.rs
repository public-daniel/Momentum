// src/db/mod.rs
use anyhow::{Context, Result};
use sqlx::sqlite::{SqlitePool, SqlitePoolOptions};
use std::{
    fs::{self, OpenOptions, Permissions}, // Added Permissions
    path::{Path, PathBuf},
    time::Duration, // Added Duration for timeout
};
use tracing::info;

// Required for setting file permissions on Unix-like systems
#[cfg(unix)]
use std::os::unix::fs::{OpenOptionsExt, PermissionsExt}; // Added PermissionsExt

/// Initializes an SQLite connection pool.
///
/// Ensures the parent directory exists and that the database file is created
/// or configured with appropriate permissions (0o600 on Unix) before
/// establishing the connection pool with a timeout.
///
/// # Arguments
///
/// * `database_url` - The connection string for the database (e.g., "sqlite:data/my_app.db").
///
/// # Returns
///
/// A `Result` containing the `SqlitePool` or an error.
pub async fn init_pool(database_url: &str) -> Result<SqlitePool> {
    // --- 1. Parse and Resolve Path ---
    let db_path_str = database_url
        .trim_start_matches("sqlite:")
        .trim_start_matches("//"); // Handle both sqlite:path and sqlite://path

    let abs_path = if Path::new(db_path_str).is_absolute() {
        PathBuf::from(db_path_str)
    } else {
        // Using std::env::current_dir() can be sensitive to where the app is run.
        // Consider resolving relative to a config file or executable location for more stability.
        std::env::current_dir()
            .context("Failed to get current directory")?
            .join(db_path_str)
    };
    info!("Resolved database absolute path: {:?}", abs_path);

    // --- 2. Ensure Parent Directory Exists ---
    if let Some(parent) = abs_path.parent() {
        if !parent.exists() {
            info!("Parent directory does not exist, creating: {:?}", parent);
            fs::create_dir_all(parent)
                .with_context(|| format!("Failed to create directory: {:?}", parent))?;
        } else {
            info!("Parent directory already exists: {:?}", parent);
        }
    } else {
        info!("Database path has no parent directory (likely root).");
    }

    // --- 3. Create or Configure File Permissions ---
    if !abs_path.exists() {
        // --- 3a. Create File if it Doesn't Exist ---
        info!("Database file doesn't exist. Creating with specific permissions.");

        let mut options = OpenOptions::new();
        options.write(true).create_new(true); // Create if not exists, fail if exists already

        #[cfg(unix)]
        {
            // Set Unix permissions: 0o600 means read/write for owner only.
            info!("Setting Unix file mode to 0o600 during creation.");
            options.mode(0o600);
        }
        #[cfg(not(unix))]
        {
            info!("Non-Unix system: Creating file with default OS permissions.");
        }

        // Create the file. Handle potential race condition where it was created
        // between the exists() check and now.
        match options.open(&abs_path) {
            Ok(_) => info!("Successfully created empty database file: {:?}", abs_path),
            Err(e) if e.kind() == std::io::ErrorKind::AlreadyExists => {
                info!(
                    "Database file was created concurrently (race condition): {:?}",
                    abs_path
                );
                // File now exists, proceed to permission check below if needed (on Unix)
                #[cfg(unix)]
                {
                    info!("Verifying permissions on concurrently created file.");
                    set_permissions_unix(&abs_path)?;
                }
            }
            Err(e) => {
                return Err(e).with_context(|| {
                    format!(
                        "Failed to create database file with permissions at: {:?}",
                        abs_path
                    )
                });
            }
        }
    } else {
        // --- 3b. Enforce Permissions if File Already Exists ---
        info!("Database file already exists: {:?}", abs_path);
        #[cfg(unix)]
        {
            info!("Ensuring existing file has correct Unix permissions (0o600).");
            set_permissions_unix(&abs_path)?;
        }
        #[cfg(not(unix))]
        {
            info!("Non-Unix system: Assuming existing file permissions are acceptable.");
            // On Windows, complex ACLs might be needed for fine-grained control.
        }
    }

    // --- 4. Construct Canonical URL for SQLx ---
    let canonical_url = format!("sqlite:{}", abs_path.display());
    info!(
        "Using canonical database URL for connection: {}",
        canonical_url
    );

    // --- 5. Connect using SQLx Pool ---
    info!("Connecting to database pool (timeout: 3s)...");
    let pool = SqlitePoolOptions::new()
        .max_connections(5) // Configure pool size as needed
        .acquire_timeout(Duration::from_secs(3)) // Timeout for both acquiring and establishing connection
        .connect(&canonical_url)
        .await
        .with_context(|| format!("Failed to connect SQLx pool to: {}", canonical_url))?;

    // --- 6. Optional: Run a Quick Test Query ---
    info!("Running database connection test query (SELECT 1)");
    sqlx::query("SELECT 1")
        .fetch_one(&pool)
        .await
        .context("Database connection test query failed")?;

    info!(
        "Database pool established successfully for: {}",
        canonical_url
    );
    Ok(pool)
}

/// Helper function to set Unix file permissions to 0o600.
#[cfg(unix)]
fn set_permissions_unix(path: &Path) -> Result<()> {
    let desired_permissions = Permissions::from_mode(0o600);
    let metadata = fs::metadata(path)
        .with_context(|| format!("Failed to get metadata for file: {:?}", path))?;

    if metadata.permissions().mode() != desired_permissions.mode() {
        info!(
            "Permissions are incorrect ({:#o}). Setting to {:#o} for file: {:?}",
            metadata.permissions().mode() & 0o777, // Mask to show relevant bits
            desired_permissions.mode() & 0o777,
            path
        );
        fs::set_permissions(path, desired_permissions)
            .with_context(|| format!("Failed to set permissions on file: {:?}", path))?;
    } else {
        info!(
            "Existing permissions ({:#o}) are already correct for file: {:?}",
            metadata.permissions().mode() & 0o777,
            path
        );
    }
    Ok(())
}

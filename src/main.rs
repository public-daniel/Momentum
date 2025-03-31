// src/main.rs
mod cli;
mod config;
mod db;
mod server;
mod static_files;
mod templates;

use anyhow::Result;
use clap::Parser;
use cli::{Cli, Commands};
use tracing::{error, info};

#[tokio::main]
async fn main() -> Result<()> {
    // Initialize logging
    tracing_subscriber::fmt::init();

    // Parse command line arguments
    let cli = Cli::parse();

    // Find configuration file
    let config_path = cli.find_config_path();

    // Load configuration
    let config = match config::Config::load(&config_path) {
        Ok(config) => config,
        Err(e) => {
            error!("Failed to load configuration from {:?}: {}", config_path, e);
            return Err(e);
        }
    };

    info!("Configuration loaded from {:?}", config_path);

    // Process commands
    match cli.command {
        Commands::Run => {
            info!("Starting Momentum server...");

            // Initialize database connection
            let db_pool = match db::init_pool(&config.database_url()).await {
                Ok(pool) => {
                    info!("Database connection established");
                    pool
                }
                Err(e) => {
                    error!("Failed to connect to database: {}", e);
                    return Err(e);
                }
            };

            // Run web server
            if let Err(e) = server::run_server(config, db_pool).await {
                error!("Server error: {}", e);
                return Err(e.into());
            }
        }
        Commands::Backup => {
            info!("Backup functionality not yet implemented");
            // TODO: Implement backup
        }
        Commands::Migrate => {
            info!("Migration functionality not yet implemented");
            // TODO: Implement migrations
        }
    }

    Ok(())
}

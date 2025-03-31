// src/cli/mod.rs
use clap::{Parser, Subcommand};
use std::path::PathBuf;

#[derive(Parser, Debug)]
#[command(
    version,
    about = "Momentum - A personal productivity and habit tracking app"
)]
pub struct Cli {
    /// Path to configuration file (optional)
    #[arg(short, long)]
    pub config: Option<PathBuf>,

    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand, Debug)]
pub enum Commands {
    /// Start the web server
    Run,

    /// Backup the database
    Backup,

    /// Migrate the database
    Migrate,
}

impl Cli {
    /// Find the configuration file using the following priority order:
    /// 1. Command line argument
    /// 2. MOMENTUM_CONFIG environment variable
    /// 3. ./config.toml (local directory)
    /// 4. /etc/momentum/config.toml (system-wide)
    pub fn find_config_path(&self) -> PathBuf {
        // 1. Check command line argument
        if let Some(path) = &self.config {
            if path.exists() {
                return path.clone();
            }
            eprintln!("Warning: Specified config file not found: {:?}", path);
        }

        // 2. Check environment variable
        if let Ok(env_path) = std::env::var("MOMENTUM_CONFIG") {
            let path = PathBuf::from(env_path);
            if path.exists() {
                return path;
            }
            eprintln!("Warning: Config file from MOMENTUM_CONFIG environment variable not found");
        }

        // 3. Check local directory
        let local_config = PathBuf::from("config.toml");
        if local_config.exists() {
            return local_config;
        }

        // 4. Default to system-wide location
        PathBuf::from("/etc/momentum/config.toml")
    }
}

// src/config.rs
use anyhow::{Context, Result};
use serde::Deserialize;
use std::fs;
use std::path::Path;

#[derive(Deserialize, Debug, Clone)]
pub struct ServerConfig {
    pub host: String,
    pub port: u16,
}

#[derive(Deserialize, Debug, Clone)]
pub struct DatabaseConfig {
    pub path: String,
}

#[derive(Deserialize, Debug, Clone)]
pub struct ApplicationConfig {
    pub name: String,
}

#[derive(Deserialize, Debug, Clone)]
pub struct Config {
    pub server: ServerConfig,
    pub database: DatabaseConfig,
    pub application: ApplicationConfig,
}

impl Config {
    pub fn load<P: AsRef<Path>>(path: P) -> Result<Self> {
        let path = path.as_ref();
        if !path.exists() {
            return Err(anyhow::anyhow!(
                "Configuration file not found: {}",
                path.display()
            ));
        }

        let content = fs::read_to_string(path)
            .context(format!("Failed to read config file: {}", path.display()))?;

        let config: Config =
            toml::from_str(&content).context("Failed to parse TOML configuration")?;

        Ok(config)
    }

    pub fn database_url(&self) -> String {
        // Simply prepend "sqlite:" to the path - the db module will handle conversion to absolute
        format!("sqlite:{}", self.database.path)
    }
}

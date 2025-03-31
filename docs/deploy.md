# Momentum Deployment Strategy

**Last Updated:** 2025-04-01

## Table of Contents

- [Overview](#overview)
- [Key Principles](#key-principles)
- [Components](#components)
- [Deployment Methods](#deployment-methods)
  - [Method 1: Bootstrap Script (Recommended)](#method-1-bootstrap-script-recommended)
  - [Method 2: Manual Installation using Release Package](#method-2-manual-installation-using-release-package)
  - [Method 3: Manual Build and Installation](#method-3-manual-build-and-installation)
- [Upgrade Process](#upgrade-process)
- [Configuration Management](#configuration-management)
- [Security Considerations](#security-considerations)
- [Maintenance and Monitoring](#maintenance-and-monitoring)
  - [Database Backups](#database-backups)
  - [Health Monitoring](#health-monitoring)
- [Troubleshooting](#troubleshooting)
- [Architecture](#architecture)
  - [Directory Structure](#directory-structure)
  - [Script Organization](#script-organization)

## Overview

This document outlines the standard process for deploying and upgrading `Momentum` onto an Ubuntu Linux server. Momentum is a single-binary Rust web application utilizing SQLite for data storage. Our strategy uses automated builds via GitHub Actions, packaged release artifacts hosted on GitHub Releases, checksum verification, and a standardized installation script (`install.sh`) to ensure consistency, security, and reliability.

The core idea is to build a self-contained, optimized release package in a clean CI environment, download it to the target server, verify its integrity, and use the provided script to handle the installation or upgrade, carefully preserving user configuration, secrets, and the SQLite database.

## Key Principles

- **Automation:** Builds and packaging are automated via GitHub Actions (`release.yml`).
- **Consistency:** Release artifacts ensure the same package is deployed everywhere. Checksums verify artifact integrity.
- **Idempotency:** The `install.sh` script can be run repeatedly without negative side effects for both initial installs and upgrades.
- **Security:** Runs as a dedicated non-privileged user (`momentum`). Secrets file has strict permissions (`600`, `root:root`). Systemd unit includes security hardening options. Artifact verification prevents tampering.
- **Separation of Concerns:** Code (binary in `/opt/momentum`), configuration (`/etc/momentum/config.toml`), secrets (`/etc/momentum/secrets.env`), and application data (SQLite DB and backups in `/var/lib/momentum`) are kept separate.
- **Preservation:** User configuration (`config.toml`), secrets (`secrets.env`), and application data (`/var/lib/momentum`) are preserved during upgrades.
- **Flexibility:** Multiple installation methods support different operational requirements.
- **Observability:** Integration with `systemd` and `journald`, plus a dedicated health check script (`health-check.sh`) for comprehensive monitoring. Includes automated database backups via `cron`.

## Components

1. **GitHub Repository (`public-daniel/Momentum`):**
    - **Purpose:** Contains all source code, configuration templates, and deployment scripts.
    - **Contents:**
        - Application source code (Rust).
        - `justfile` for task automation.
        - GitHub Actions workflows (`.github/workflows/ci.yml`, `.github/workflows/release.yml`).
        - Configuration template (`deploy/config/config.toml.example`).
        - Systemd unit file template (`deploy/systemd/momentum.service`).
        - Deployment scripts (`deploy/scripts/bootstrap.sh`, `deploy/scripts/install.sh`, `deploy/scripts/health-check.sh`).
        - Pre-commit hooks configuration (`.pre-commit-config.yaml`).
    - **URL:** [https://github.com/public-daniel/Momentum](https://github.com/public-daniel/Momentum)

2. **GitHub Actions (CI/CD):**
    - **Purpose:** Automates building, testing, and packaging of releases.
    - **CI Workflow (`ci.yml`):** Runs checks (format, lint, test, audit) on PRs and pushes to `master`.
    - **Release Workflow (`release.yml`):**
        - Triggered on pushing tags matching `v*.*.*` (e.g., `v1.0.0`).
        - Builds the optimized Rust application (`momentum`) using `just release`.
        - Calculates SHA256 checksums (`checksums.txt`).
        - Packages the binary and supporting files into a `momentum-[version].tar.gz` archive.
        - Creates a GitHub Release, including bootstrap instructions in the description.
        - Uploads the `.tar.gz` archive and `checksums.txt` as release assets.

3. **GitHub Release Artifact (`momentum-[version].tar.gz`):**
    - **Purpose:** Provides a self-contained, versioned deployment package.
    - **Contents (Structure defined in `release.yml`):**
        - `./momentum` (The compiled binary)
        - `./scripts/install.sh` (Installation/upgrade script)
        - `./scripts/health-check.sh` (Monitoring script)
        - `./momentum.service` (Systemd unit file)
        - `./config.toml.example` (Configuration template)
    - **Accompanied by:** `checksums.txt` (Uploaded separately to the release).

4. **Bootstrap Script (`deploy/scripts/bootstrap.sh`):**
    - **Purpose:** Provides a one-liner installation/upgrade experience using release artifacts.
    - **Functionality:**
        - Downloads the specified (or latest) release package and checksums from GitHub Releases.
        - Verifies the checksum for security.
        - Extracts the package.
        - Executes the packaged `scripts/install.sh` using `sudo`.
        - Provides next steps for the administrator.
    - **Location:** Resides in the source repository at `deploy/scripts/bootstrap.sh`. Accessed via raw GitHub URL.

5. **Installation Script (`scripts/install.sh` within the release package):**
    - **Purpose:** Handles the core installation/upgrade logic on the target server. *This script is inside the downloaded `.tar.gz`.*
    - **Functionality:**
        - Runs with `sudo`. Detects install vs. upgrade mode.
        - Creates system user and group (`momentum`) if needed.
        - Creates necessary directories (`/opt/momentum`, `/etc/momentum`, `/var/lib/momentum`, `/var/log/momentum`) with correct permissions.
        - Stops the running service (if upgrading).
        - Installs the new binary (`/opt/momentum/momentum`), health check script (`/opt/momentum/health-check.sh`), and creates a symlink (`/usr/local/bin/momentum`).
        - Handles configuration: Creates initial `config.toml` and `secrets.env` on first install (preserving existing files on upgrade).
        - Handles configuration updates: Merges new options from the template into `config.toml` during upgrades, preserving user values and backing up the original.
        - Installs the Systemd unit file (`/etc/systemd/system/momentum.service`), reloads `systemd`, and enables the service.
        - Sets up a daily cron job (`/etc/cron.d/momentum-backup`) for automated database backups using the built-in `momentum backup` CLI command.
        - Starts/restarts the `momentum` service.

6. **Health Check Script (`scripts/health-check.sh` within the release package, installed to `/opt/momentum/health-check.sh`):**
    - **Purpose:** Provides application-specific monitoring beyond basic service status. Recommended to run via `cron`.
    - **Functionality:**
        - Checks if the `momentum.service` is active.
        - Checks `systemctl status` for degraded/warning states.
        - Checks `journald` for recent errors logged by the service.
        - Verifies the application's HTTP health endpoint (`http://localhost:8686/health` by default) is responding.
        - Checks the database file (`/var/lib/momentum/momentum.db`) for existence, correct ownership (`momentum:momentum`), and reasonable permissions.
        - Performs a database integrity check (`PRAGMA integrity_check`) using `sqlite3` if available.
        - Checks disk space usage for the partition containing `/var/lib/momentum`.
        - Outputs status (OK/WARNING/CRITICAL) and detailed messages.
        - Returns Nagios-compatible exit codes for integration with monitoring systems.

7. **Target Server Environment:**
    - **Operating System:** Ubuntu Linux (LTS versions recommended).
    - **Init System:** `systemd`.
    - **Prerequisites for Bootstrap/Release Package Install:** `curl`, `jq` (for 'latest' version lookup), `tar`, `sudo` access. `sha256sum` is used for verification by bootstrap script.
    - **Prerequisites for Manual Build:** `git`, Rust toolchain (`rustup`, `cargo`), `build-essential`, `pkg-config`, `libssl-dev`.

8. **Application Data & Configuration (on Target Server):**
    - **Installation Directory (`/opt/momentum`):** Contains the binary and health check script. Owned by `root:root`.
    - **Data Directory (`/var/lib/momentum`):** Stores the SQLite database (`momentum.db`), backups (`backups/`), and potentially other runtime data. Owned by `momentum:momentum`, `700` permissions. Persists across upgrades.
    - **Configuration Directory (`/etc/momentum`):** Contains configuration files. Owned by `root:momentum`, `750` permissions.
        - **Base Configuration (`config.toml`):** Non-sensitive settings. Managed by the administrator, initially created from template, intelligently updated during upgrades. `640` permissions (`root:momentum`).
        - **Secrets (`secrets.env`):** Sensitive key=value pairs. Created empty on first install, **requires manual editing**. Strict `600` permissions (`root:root`), loaded via Systemd's `EnvironmentFile`. Persists across upgrades.
    - **Log Directory (`/var/log/momentum`):** Used for cron job logs (`backup.log`). Owned by `momentum:momentum`, `750` permissions. Service logs go to `journald`.
    - **Systemd Unit (`/etc/systemd/system/momentum.service`):** Service definition. Owned by `root:root`, `644` permissions.
    - **Cron Job (`/etc/cron.d/momentum-backup`):** Backup schedule. Owned by `root:root`, `644` permissions.

## Deployment Methods

Choose the method that best suits your needs:

### Method 1: Bootstrap Script (Recommended)

The quickest and easiest way to deploy or upgrade Momentum using the official release artifacts. This handles downloading, verification, and running the installation script.

1. **Run Bootstrap Script (Latest Version):**

    ```bash
    curl -sSL [https://raw.githubusercontent.com/public-daniel/Momentum/master/deploy/scripts/bootstrap.sh](https://raw.githubusercontent.com/public-daniel/Momentum/master/deploy/scripts/bootstrap.sh) | bash
    ```

2. **Run Bootstrap Script (Specific Version):**

    ```bash
    # Replace v1.0.0 with the desired version tag from GitHub Releases
    curl -sSL [https://raw.githubusercontent.com/public-daniel/Momentum/master/deploy/scripts/bootstrap.sh](https://raw.githubusercontent.com/public-daniel/Momentum/master/deploy/scripts/bootstrap.sh) | bash -s -- --version v1.0.0
    ```

3. **Configure Secrets (First Installation Only):**
    The bootstrap script (via `install.sh`) creates an empty secrets file on the first install. You **must** edit it.

    ```bash
    sudo nano /etc/momentum/secrets.env
    # Add required key=value pairs (e.g., API_KEY=xxxxxxxx)
    # Save and close the file.
    ```

4. **Restart Service (After Editing Secrets):**

    ```bash
    sudo systemctl restart momentum.service
    ```

5. **Verify:**

    ```bash
    sudo systemctl status momentum.service
    sudo journalctl -u momentum.service -f
    ```

### Method 2: Manual Installation using Release Package

For users who prefer more control or cannot use the bootstrap script directly, but still want to use pre-built binaries.

1. **Identify Release:** Go to the [Momentum GitHub Releases page](https://github.com/public-daniel/Momentum/releases) and find the desired version tag (e.g., `v1.0.0`).

2. **Download and Verify Artifacts:**

    ```bash
    # Set the desired version
    VERSION="v1.0.0" # Replace with the actual version tag

    # Define URLs
    ARCHIVE_URL="[https://github.com/public-daniel/Momentum/releases/download/$](https://github.com/public-daniel/Momentum/releases/download/$){VERSION}/momentum-${VERSION}.tar.gz"
    CHECKSUM_URL="[https://github.com/public-daniel/Momentum/releases/download/$](https://github.com/public-daniel/Momentum/releases/download/$){VERSION}/checksums.txt"
    ARCHIVE_NAME="momentum-${VERSION}.tar.gz"
    CHECKSUM_NAME="checksums.txt"

    # Create a temporary download directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    echo "Working in temporary directory: $TEMP_DIR"

    # Download files
    echo "Downloading archive..."
    curl -sSL -o "$ARCHIVE_NAME" "$ARCHIVE_URL"
    echo "Downloading checksums..."
    curl -sSL -o "$CHECKSUM_NAME" "$CHECKSUM_URL"

    # Verify checksum (CRITICAL STEP!)
    echo "Verifying checksum..."
    if sha256sum -c --ignore-missing <(grep "$ARCHIVE_NAME" "$CHECKSUM_NAME"); then
       echo "Checksum VERIFIED."
    else
       echo "CHECKSUM FAILED! Do not proceed. File may be corrupt or tampered with."
       # Clean up temporary directory before exiting
       rm -rf "$TEMP_DIR"
       exit 1
    fi
    ```

3. **Extract Artifact:**

    ```bash
    # Create extraction directory (within TEMP_DIR)
    mkdir extract
    echo "Extracting archive..."
    # Extract contents directly into the 'extract' directory
    tar -xzf "$ARCHIVE_NAME" -C extract
    cd extract
    ```

    *Note: The archive is created by `release.yml` to contain files directly at the root.*

4. **Run Installation Script:**
    The `install.sh` script is now located in `./scripts/` relative to your current directory (`extract`).

    ```bash
    echo "Running installation script..."
    sudo ./scripts/install.sh
    ```

5. **Configure Secrets (First Installation Only):**
    If this is the first time installing, edit the secrets file:

    ```bash
    sudo nano /etc/momentum/secrets.env
    # Add required key=value pairs
    sudo systemctl restart momentum.service
    ```

6. **Verify Installation:**

    ```bash
    sudo systemctl status momentum.service
    sudo journalctl -u momentum.service -f
    ```

7. **Cleanup:**

    ```bash
    echo "Cleaning up temporary directory..."
    # Go back to original directory or home
    cd ~
    rm -rf "$TEMP_DIR"
    echo "Cleanup complete."
    ```

### Method 3: Manual Build and Installation

For developers or users who want to build from source directly on the target machine.

1. **Install Prerequisites:**

    ```bash
    sudo apt update
    sudo apt install -y git curl build-essential pkg-config libssl-dev
    # Install Rust if not already installed
    curl --proto '=https' --tlsv1.2 -sSf [https://sh.rustup.rs](https://sh.rustup.rs) | sh
    # Make sure cargo is in the current shell's PATH
    source "$HOME/.cargo/env"
    # Install Just (optional, but recommended for using justfile tasks)
    cargo install just
    ```

2. **Clone Repository:**

    ```bash
    git clone [https://github.com/public-daniel/Momentum.git](https://github.com/public-daniel/Momentum.git)
    cd Momentum
    # Optional: Check out a specific tag/branch
    # git checkout v1.0.0
    ```

3. **Build Application (Release Mode):**
    - **Using Just (Recommended):**

        ```bash
        just release
        ```

    - **Manually:**

        ```bash
        cargo build --release
        ```

    This creates the binary at `./target/release/momentum`.

4. **Run Installation Script (from Source):**
    The `install.sh` script has a `--from-source` flag that tells it to look for the binary in `target/release/` and use the templates/scripts from the local repository clone (`deploy/` directory).

    ```bash
    # Ensure you are in the root of the cloned repository ('Momentum')
    # Run the install script located in deploy/scripts/ using sudo and the flag
    sudo ./deploy/scripts/install.sh --from-source
    ```

    This single command will handle:
    - Creating the user/group (`momentum`).
    - Creating directories with correct permissions.
    - Copying the built binary (`target/release/momentum`) to `/opt/momentum/momentum`.
    - Copying the health check script (`deploy/scripts/health-check.sh`) to `/opt/momentum/health-check.sh`.
    - Creating the symlink (`/usr/local/bin/momentum`).
    - Copying the config template (`deploy/config/config.toml.example`) to `/etc/momentum/config.toml` (first install) or merging changes (upgrade).
    - Creating the empty secrets file (`/etc/momentum/secrets.env`) (first install).
    - Copying the systemd unit file (`deploy/systemd/momentum.service`) and enabling the service.
    - Setting up the backup cron job.
    - Starting the service.

5. **Configure Secrets (First Installation Only):**

    ```bash
    sudo nano /etc/momentum/secrets.env
    # Add required key=value pairs
    sudo systemctl restart momentum.service
    ```

6. **Verify Installation:**

    ```bash
    sudo systemctl status momentum.service
    sudo journalctl -u momentum.service -f
    ```

## Upgrade Process

### Using Bootstrap or Release Package

Upgrading is identical to the initial installation using Method 1 or Method 2. Simply run the bootstrap command or download the new release package and run its `scripts/install.sh`.

```bash
# Example using Bootstrap for upgrade
curl -sSL [https://raw.githubusercontent.com/public-daniel/Momentum/master/deploy/scripts/bootstrap.sh](https://raw.githubusercontent.com/public-daniel/Momentum/master/deploy/scripts/bootstrap.sh) | bash
```

**Key Points for Upgrades:**

- The `install.sh` script is designed to be **idempotent** and handle upgrades safely.
- It **will overwrite** the application binary (`/opt/momentum/momentum`), health check script (`/opt/momentum/health-check.sh`), and Systemd unit file (`/etc/systemd/system/momentum.service`) with the new versions from the package.
- It **will NOT overwrite** your existing `/etc/momentum/secrets.env` or the data directory `/var/lib/momentum/`.
- It **will merge** new configuration options from the package's `config.toml.example` into your existing `/etc/momentum/config.toml`, preserving your existing settings and values. A backup of the config file is created before merging.
- The service will be stopped before files are replaced and restarted automatically at the end of the script.

### Manual Build Upgrade

For installations originally done using Method 3:

1. **Navigate to Source Directory:**

    ```bash
    cd Momentum # Your local repository clone
    ```

2. **Pull Latest Changes & Checkout Version:**

    ```bash
    git fetch origin
    git checkout master # Or git checkout v1.x.x for a specific tag
    git pull origin master # Or the specific tag branch if needed
    ```

3. **Rebuild Application:**

    ```bash
    # Using Just (Recommended):
    just release
    # Or Manually:
    # cargo build --release
    ```

4. **Run Installation Script (from Source):**
    The `--from-source` flag handles the upgrade logic correctly, including stopping the service, replacing files, merging config, and restarting.

    ```bash
    sudo ./deploy/scripts/install.sh --from-source
    ```

5. **Verify Upgrade:**

    ```bash
    sudo systemctl status momentum.service
    # Check logs for any new warnings/errors after upgrade
    sudo journalctl -u momentum.service -n 50
    # Optionally run health check
    sudo /opt/momentum/health-check.sh
    ```

## Configuration Management

Momentum uses a clear separation for configuration:

1. **Base Configuration (`/etc/momentum/config.toml`):**
    - Contains non-sensitive settings like server port, database path, logging level, backup directory.
    - Managed by the administrator.
    - Initially created by `install.sh` from the `config.toml.example` template.
    - Owned by `root:momentum`, permissions `640` (root rw, group r).
    - **Updates:** During upgrades (`install.sh`), new keys found in the template are appended to the existing file, preserving user-set values for existing keys. A backup (`.bak.YYYYMMDDHHMMSS`) is created before modification.

2. **Secrets Management (`/etc/momentum/secrets.env`):**
    - Contains sensitive credentials (API keys, etc.).
    - Format: Standard environment variables (`KEY=value`).
    - Loaded directly into the application's environment by Systemd's `EnvironmentFile` directive in `momentum.service`.
    - Created empty by `install.sh` on first install; **must be edited manually**.
    - **Never overwritten** by the upgrade process.
    - Owned by `root:root`, strict `600` permissions (owner rw only).

3. **Configuration Merging Logic (`install.sh`):**
    The script includes a function to safely add new configuration options during upgrades:

    ```bash
    # Function to merge new config options from template into existing config
    merge_config() {
      local config_template="$1"
      local config_current="$2"
      local config_backup
      config_backup="${config_current}.bak.$(date +%Y%m%d%H%M%S)"

      log_info "Comparing current config with template..."

      # Use grep to extract keys (lines starting with key= or key =). Handles simple cases.
      # Assumes keys don't contain spaces and are at the beginning of the line.
      # A more robust TOML parser would be better but harder in pure bash.
      template_keys=$(grep -oP '^\s*\K[a-zA-Z0-9_\-\.]+(?=\s*=)' "$config_template" || true)
      current_keys=$(grep -oP '^\s*\K[a-zA-Z0-9_\-\.]+(?=\s*=)' "$config_current" || true)

      new_keys=()
      # Find keys in template that are not in current config
      comm -23 <(echo "$template_keys" | sort) <(echo "$current_keys" | sort) | while read -r key; do
          # Double check it's not just commented out in current file
          if ! grep -qP "^\s*#?\s*${key}\s*=" "$config_current"; then
              new_keys+=("$key")
          fi
      done


      if [ ${#new_keys[@]} -eq 0 ]; then
        log_info "No new configuration options found in template. Configuration is up-to-date."
        return 0
      fi

      log_warn "Found ${#new_keys[@]} new configuration options to add from template."
      log_info "Backing up current configuration to $config_backup..."
      cp "$config_current" "$config_backup"

      echo -e "\n# === Auto-added options from template update on $(date) ===" >> "$config_current"
      for key in "${new_keys[@]}"; do
        # Extract the full line (including comments above it, potentially) for the key from template
        # This grep gets the line with the key= and potentially preceding comment lines
        # line_content=$(grep -B 5 -P "^\s*${key}\s*=" "$config_template" | grep -vP '^\s*--\s*$' | tail -n +1 ) # Crude way to get context
        # A simpler approach: just grab the key = value line
        line_content=$(grep -P "^\s*${key}\s*=" "$config_template")

        log_info "  - Adding: ${key}"
        echo "$line_content" >> "$config_current"
      done

      log_warn "Configuration updated with new options. Original saved to $config_backup"
      log_warn "Please review the added options in ${config_current}"
    }
    ```

## Security Considerations

1. **Artifact Integrity:**
    - Release packages are accompanied by `checksums.txt` containing SHA256 hashes.
    - The `bootstrap.sh` script automatically downloads and verifies the checksum before extraction and installation.
    - Manual installation (Method 2) **must include** manual checksum verification.

2. **Principle of Least Privilege:**
    - The Momentum application runs as a dedicated, non-privileged system user (`momentum`) with no login shell (`/usr/sbin/nologin`).
    - The Systemd service unit (`momentum.service`) employs hardening directives (`ProtectSystem=full`, `PrivateDevices=true`, `NoNewPrivileges=true`, `ProtectHome=true`, etc.) to restrict the service's capabilities and access to the system.

3. **Secrets Management:**
    - Sensitive credentials are stored separately in `/etc/momentum/secrets.env`.
    - This file has strict `600` permissions and is owned by `root:root`, making it inaccessible to the `momentum` user directly (it's read by `systemd` running as root and injected into the environment).
    - Secrets are loaded as environment variables, not passed as command-line arguments.

4. **File System Permissions:**
    - Application binary (`/opt/momentum/momentum`) is owned by `root:root` with `755` permissions (executable by all, writable only by root).
    - Data directory (`/var/lib/momentum`) is owned by `momentum:momentum` with `700` permissions (only accessible by the service user).
    - Configuration directory (`/etc/momentum`) is `root:momentum` with `750` permissions. `config.toml` is `640`, `secrets.env` is `600`.
    - Log directory (`/var/log/momentum`) is `momentum:momentum` with `750` permissions.

5. **Dependencies:** Regularly audit dependencies for vulnerabilities using `cargo audit` (integrated into the CI process via `just ci` and pre-push hooks).

## Maintenance and Monitoring

### Database Backups

Momentum includes a built-in CLI command for managing SQLite database backups.

1. **Manual Backup:**
    Run the backup command as the `momentum` user:

    ```bash
    sudo -u momentum /opt/momentum/momentum backup
    ```

    *(Note: Ensure your application's CLI is implemented to handle the `backup` subcommand)*

2. **Automated Backups (via Cron):**
    The `install.sh` script automatically sets up a daily cron job to run the backup command. The job definition is placed in `/etc/cron.d/momentum-backup`:

    ```cron
    # /etc/cron.d/momentum-backup
    # Run daily at 2:00 AM as the momentum user
    # Output (stdout/stderr) is appended to /var/log/momentum/backup.log
    0 2 * * * momentum /opt/momentum/momentum backup >> /var/log/momentum/backup.log 2>&1
    ```

3. **Backup Location & Retention:**
    - Backups are stored in the directory specified by `application.backup.directory` in `config.toml` (default: `/var/lib/momentum/backups/`).
    - The `momentum backup` command should ideally implement its own retention logic (e.g., keep N backups, delete backups older than X days). Ensure the `momentum` user has write permissions to this directory.

### Health Monitoring

Combine Systemd's built-in features with the provided health check script for robust monitoring.

#### Systemd Monitoring

Systemd provides basic service lifecycle management and status reporting:

1. **Automatic Restarts:** The service is configured to restart automatically on failure:

    ```systemd
    [Service]
    Restart=on-failure
    RestartSec=5s
    ```

2. **Status Checking:**

    ```bash
    sudo systemctl status momentum.service
    # Check if active: systemctl is-active momentum.service
    # Check if failed: systemctl is-failed momentum.service
    ```

3. **Log Access (`journald`):** The service logs stdout and stderr to the systemd journal, tagged with `momentum`.

    ```bash
    sudo journalctl -u momentum.service        # View all logs
    sudo journalctl -u momentum.service -f     # Follow logs in real-time
    sudo journalctl -u momentum.service -e     # Jump to the end
    sudo journalctl -u momentum.service --since "1 hour ago" # Time-based filter
    ```

#### Health Check Script (`/opt/momentum/health-check.sh`)

For more detailed, application-aware checks, use the provided script.

1. **Manual Run:**

    ```bash
    sudo /opt/momentum/health-check.sh
    ```

    The script outputs a summary and exits with a status code (0=OK, 1=Warning, 2=Critical).

2. **Scheduled Monitoring (via Cron):** Run the script periodically (e.g., every 5 minutes) and potentially integrate its output/exit code with an external monitoring system (Nagios, Zabbix, Prometheus Alertmanager, Healthchecks.io, etc.).

    ```bash
    # Example cron job in /etc/cron.d/momentum-healthcheck
    # Runs every 5 minutes as root. Suppresses output unless there's an error in the script itself.
    # Monitoring systems should check the exit code or be triggered by other means (e.g., push metrics).
    */5 * * * * root /opt/momentum/health-check.sh >/dev/null 2>&1
    ```

3. **Checks Performed:** (Based on the provided `health-check.sh`)
    - Service active (`systemctl is-active`).
    - Service status details for warnings/degradation (`systemctl status`).
    - Recent errors in `journald` logs (`journalctl -u ... -p err`).
    - HTTP endpoint responsiveness (`curl http://localhost:8686/health`).
    - Database file existence, ownership, and permissions.
    - Database integrity check (`sqlite3 ... "PRAGMA integrity_check;"`).
    - Disk space usage for the data directory partition.

## Troubleshooting

### Common Commands

- **Check Service Status:** `sudo systemctl status momentum.service`
- **View Logs (Tail):** `sudo journalctl -u momentum.service -f`
- **View All Logs:** `sudo journalctl -u momentum.service -e`
- **Restart Service:** `sudo systemctl restart momentum.service`
- **Stop Service:** `sudo systemctl stop momentum.service`
- **Start Service:** `sudo systemctl start momentum.service`
- **Reload Systemd Config:** `sudo systemctl daemon-reload` (Needed after changing `.service` file)
- **Check Config File:** `sudo cat /etc/momentum/config.toml`
- **Check Secrets File (Permissions only):** `sudo ls -la /etc/momentum/secrets.env` (Content should not be easily viewable)
- **Check Data Directory:** `sudo ls -la /var/lib/momentum/`
- **Check Binary Path/Symlink:** `ls -l /usr/local/bin/momentum` and `ls -l /opt/momentum/momentum`
- **Run Health Check:** `sudo /opt/momentum/health-check.sh`
- **Run Manual Backup:** `sudo -u momentum /opt/momentum/momentum backup`

### Common Issues

1. **Service Fails to Start (`Active: failed`)**
    - **Check Logs:** `sudo journalctl -u momentum.service -e` Look for specific errors (panic messages, config parsing errors, port binding errors, database connection errors).
    - **Verify Configuration:** `sudo cat /etc/momentum/config.toml`. Ensure syntax is correct TOML.
    - **Check Secrets:** Ensure `/etc/momentum/secrets.env` exists, has correct permissions (`600 root:root`), and contains necessary keys expected by the application.
    - **Check Permissions:** Ensure `/var/lib/momentum` is owned by `momentum:momentum` and is writable (`sudo ls -la /var/lib/momentum`).
    - **Port Conflicts:** Check if the port specified in `config.toml` (e.g., 8686) is already in use (`sudo ss -tulpn | grep 8686`).
    - **Binary Issues:** Ensure `/opt/momentum/momentum` exists and is executable (`sudo ls -l /opt/momentum/momentum`).

2. **Database Access Issues (Errors in Logs)**
    - **Check Ownership:** `sudo ls -la /var/lib/momentum/`. Ensure `momentum.db` (or the configured path) is owned by `momentum:momentum`. Fix with `sudo chown momentum:momentum /var/lib/momentum/momentum.db`.
    - **Check Directory Permissions:** Ensure `/var/lib/momentum` is `700` and owned by `momentum:momentum`. Fix with `sudo chmod 700 /var/lib/momentum && sudo chown momentum:momentum /var/lib/momentum`.
    - **Database Corruption:** Try running `sudo /opt/momentum/health-check.sh` which includes an integrity check. If corrupt, restore from backup.

3. **Configuration Issues (Service starts but behaves incorrectly)**
    - **Validate Config:** Carefully review `/etc/momentum/config.toml`.
    - **Check Environment:** Ensure `secrets.env` values are correct and the application is reading them as expected. Use `systemctl show --property=Environment momentum.service` to see what systemd loaded.
    - **Restore Template:** If `config.toml` seems broken, back it up and copy the template again: `sudo cp /etc/momentum/config.toml /etc/momentum/config.toml.broken && sudo cp deploy/config/config.toml.example /etc/momentum/config.toml` (requires source checkout or access to the template) then re-apply settings carefully.

4. **Upgrade Issues (Service fails after upgrade)**
    - **Check Logs:** As always, check `journalctl -u momentum.service -e` first.
    - **Config Merging:** Review `/etc/momentum/config.toml` and the backup created during the upgrade. Did the merge introduce issues?
    - **Permissions:** Sometimes upgrades might reset permissions inadvertently (though `install.sh` tries to prevent this). Re-check binary and directory permissions.
    - **Rollback (Manual):** If necessary, stop the service, replace `/opt/momentum/momentum` with the binary from the previous version's release package, and restart.

## Architecture

Momentum utilizes a standard deployment pattern for self-contained web services on Linux.

```asc
+-----------------+      +-------------------+      +----------------------+      +----------------+
| GitHub Actions  |----->| GitHub Releases   |----->| Target Server        |<-----| Administrator  |
| (Build/Package) |      | (.tar.gz, chksum) |      | (Ubuntu w/ systemd)  |      | (SSH, Manual)  |
+-----------------+      +-------------------+      +----------+-----------+      +----------------+
                                                               |
                                     (curl | bash -s -- ...)   | (Manual Download/Verify)
                                                               V
                                                     +---------------------+
                                                     | bootstrap.sh / User |
                                                     +----------+----------+
                                                               | (sudo ./scripts/install.sh)
                                                               V
+--------------------------------------------------------------+--------------------------------------------------------------+
| Managed by install.sh                                                                                                       |
|                                                                                                                             |
|  +--------------------------+   +------------------------+   +-------------------------+   +------------------------------+ |
|  | /opt/momentum/           |   | /etc/momentum/         |   | /var/lib/momentum/      |   | /etc/systemd/system/         | |
|  | - momentum (binary)      |   | - config.toml (config) |   | - momentum.db (data)    |   | - momentum.service (unit)    | |
|  | - health-check.sh (mon)  |   | - secrets.env (secrets)|   | - backups/ (backups)    |   +------------------------------+ |
|  +------------+-------------+   +-----------+------------+   +-------------+-----------+                                  | |
|               |                           |                          |                     +------------------------------+ |
|  +------------V-------------+   +-----------V------------+   +-------------V-----------+   | /etc/cron.d/                 | |
|  | /usr/local/bin/momentum  |   | momentum process       |<->| SQLite Engine           |   | - momentum-backup (cron job) | |
|  | (symlink)                |   | (runs as 'momentum' user)|                           |   +------------------------------+ |
|  +--------------------------+   | (reads config, secrets)|                             |                                  | |
|                                 +-----------+------------+                             |                                  | |
|                                             | (Logs via stdout/stderr)                 |                                  | |
|                                             V                                          |                                  | |
|                                 +-----------+------------+                             |                                  | |
|                                 | systemd / journald     |                             |                                  | |
|                                 +------------------------+                             |                                  | |
+------------------------------------------------------------------------------------------------------------------------------+
```

### Directory Structure

The `install.sh` script sets up the following standard Linux FHS-like structure:

- `/opt/momentum/`: Contains the application binary and supporting scripts (like `health-check.sh`). Files owned by `root`, generally read/execute for others.
- `/etc/momentum/`: Contains configuration (`config.toml`) and secrets (`secrets.env`). Files owned by `root`, permissions restricted appropriately.
- `/var/lib/momentum/`: Contains persistent application data, primarily the SQLite database (`momentum.db`) and backups. Owned by the `momentum` user, restricted permissions (`700`).
- `/var/log/momentum/`: Contains logs generated by auxiliary processes like the backup cron job. Service logs go to `journald`. Owned by `momentum`, typically group-readable (`750`).
- `/usr/local/bin/momentum`: A symbolic link to `/opt/momentum/momentum` for easy command-line access.

### Script Organization

The deployment process relies on several key scripts:

1. **`justfile`:** (In repository) Automates development, build, and release tasks locally and in CI.
2. **GitHub Actions Workflows (`.github/workflows/*.yml`):** (In repository) Define the CI and Release pipelines.
3. **`deploy/scripts/bootstrap.sh`:** (In repository) Fetches release, verifies, calls `install.sh`. User-facing entry point for easy installs.
4. **`scripts/install.sh`:** (Inside release `.tar.gz`) The core logic for setting up the application, user, directories, permissions, service, and cron job on the target server. Handles both install and upgrade.
5. **`scripts/health-check.sh`:** (Inside release `.tar.gz`, installed to `/opt/momentum/`) Performs detailed application health checks for monitoring.

This separation allows for a simple user experience (`bootstrap.sh`) while encapsulating the complex setup logic within the versioned release package (`install.sh`), ensuring consistency.

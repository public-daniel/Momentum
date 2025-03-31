#!/usr/bin/env bash
set -euo pipefail # Exit on error, undefined variable, or pipe failure

# Momentum Installation/Upgrade Script
# Installs or upgrades the Momentum application and its system integration.
# Should be run with sudo privileges.

# --- Configuration ---
APP_NAME="momentum"
USERNAME="momentum"
GROUPNAME="momentum"

# Target installation paths
INSTALL_DIR="/opt/${APP_NAME}"
CONFIG_DIR="/etc/${APP_NAME}"
DATA_DIR="/var/lib/${APP_NAME}"
LOG_DIR="/var/log/${APP_NAME}" # Primarily for cron job logs, service logs go to journald
SYSTEMD_DIR="/etc/systemd/system"
CRON_DIR="/etc/cron.d"

BINARY_DEST="${INSTALL_DIR}/${APP_NAME}"
HEALTH_CHECK_DEST="${INSTALL_DIR}/health-check.sh"
CONFIG_DEST="${CONFIG_DIR}/config.toml"
SECRETS_DEST="${CONFIG_DIR}/secrets.env"
SYMLINK_DEST="/usr/local/bin/${APP_NAME}"
SYSTEMD_UNIT_DEST="${SYSTEMD_DIR}/${APP_NAME}.service"
CRON_FILE_DEST="${CRON_DIR}/${APP_NAME}-backup"

# --- Script Variables ---
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
FROM_SOURCE=false # Default to assuming running from extracted release package
PKG_ROOT="" # Will be calculated based on mode
INSTALL_MODE="upgrade" # Default assumption, will check later

# Source file paths (will be determined based on mode)
BINARY_SRC=""
HEALTH_CHECK_SRC=""
CONFIG_TEMPLATE_SRC=""
SYSTEMD_UNIT_SRC=""

# --- Helper Functions ---

# Basic logging functions
log_info() { echo "[INFO] $1"; }
log_warn() { echo "[WARN] $1"; }
log_error() { echo "[ERROR] $1" >&2; }

# Check if running as root/sudo
check_sudo() {
  if [[ "$EUID" -ne 0 ]]; then
    log_error "This script must be run with root privileges (e.g., using sudo)."
    exit 1
  fi
}

# Function to check for required command
check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        log_error "Required command not found: '$cmd'. Please install it and try again."
        exit 1
    fi
}

# Function to display help message
print_help() {
  echo "Usage: sudo $0 [OPTIONS]"
  echo "Installs or upgrades the Momentum application."
  echo ""
  echo "Options:"
  echo "  --from-source    Install using artifacts from a local source checkout."
  echo "                   Assumes the binary has ALREADY been built"
  echo "                   (e.g., via 'just release' or 'cargo build --release')"
  echo "                   in the './target/release/' directory."
  echo "  -h, --help       Display this help message."
}

# --- Argument Parsing ---
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --from-source)
        FROM_SOURCE=true
        shift # past argument
        ;;
      -h|--help)
        print_help
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        print_help
        exit 1
        ;;
    esac
  done
}

# --- Core Logic Functions (Placeholders) ---

# Determine source paths based on run mode
determine_source_paths() {
  log_info "Determining source file paths..."
  if [[ "$FROM_SOURCE" == "true" ]]; then
    # Running from source checkout (e.g., sudo ./deploy/scripts/install.sh --from-source)
    PKG_ROOT=$(realpath "${SCRIPT_DIR}/../..") # Assumes script is in deploy/scripts/
    log_info "Running in --from-source mode. Package root: ${PKG_ROOT}"
    log_info "Expecting pre-built binary in ./target/release/"
    BINARY_SRC="${PKG_ROOT}/target/release/${APP_NAME}"
    HEALTH_CHECK_SRC="${SCRIPT_DIR}/health-check.sh"
    CONFIG_TEMPLATE_SRC="${PKG_ROOT}/deploy/config/config.toml.example"
    SYSTEMD_UNIT_SRC="${PKG_ROOT}/deploy/systemd/${APP_NAME}.service"
  else
    # Running from extracted release package (e.g., cd momentum-v1.x.y && sudo ./scripts/install.sh)
    # Assumes archive structure:
    # ./momentum             (binary)
    # ./scripts/install.sh   (this script)
    # ./scripts/health-check.sh
    # ./config.toml.example
    # ./momentum.service
    PKG_ROOT=$(realpath "${SCRIPT_DIR}/..") # Assumes script is in scripts/ directory within package root
    log_info "Running in release package mode. Package root: ${PKG_ROOT}"
    BINARY_SRC="${PKG_ROOT}/${APP_NAME}"
    HEALTH_CHECK_SRC="${SCRIPT_DIR}/health-check.sh" # Assumes it's alongside install.sh
    CONFIG_TEMPLATE_SRC="${PKG_ROOT}/config.toml.example"
    SYSTEMD_UNIT_SRC="${PKG_ROOT}/${APP_NAME}.service"
  fi

  # Validate that source files exist (ensures user has built the binary if needed)
  log_info "Validating source file existence..."
  local all_sources_found=true
  # Check binary
  if [[ ! -f "$BINARY_SRC" ]]; then
      log_error "Source binary not found: $BINARY_SRC"
      if [[ "$FROM_SOURCE" == "true" ]]; then
          log_error "Have you built the project first? (e.g., run 'just release' or 'cargo build --release')"
      fi
      all_sources_found=false
  fi
  # Check other template/script files
  for src_file in "$HEALTH_CHECK_SRC" "$CONFIG_TEMPLATE_SRC" "$SYSTEMD_UNIT_SRC"; do
    if [[ ! -f "$src_file" ]]; then
      log_error "Source file not found: $src_file"
      all_sources_found=false
    fi
  done
  if [[ "$all_sources_found" == "false" ]]; then
    log_error "One or more source files could not be found. Please check the package structure or build artifacts."
    exit 1
  fi
  log_info "Source files located successfully."
}

# Detect if this is a fresh install or an upgrade
detect_install_mode() {
  if id -u "$USERNAME" &>/dev/null && [[ -f "$CONFIG_DEST" ]] && [[ -f "$SYSTEMD_UNIT_DEST" ]]; then
    INSTALL_MODE="upgrade"
    log_info "Existing installation detected. Running in upgrade mode."
  else
    INSTALL_MODE="install"
    log_info "No existing installation detected. Running in fresh install mode."
  fi
}

# Create system user and group
setup_user_group() {
  log_info "Setting up user and group '${USERNAME}'..."
  if ! getent group "$GROUPNAME" >/dev/null; then
    log_info "Creating system group '${GROUPNAME}'..."
    groupadd --system "$GROUPNAME"
  else
    log_info "Group '${GROUPNAME}' already exists."
  fi

  if ! id -u "$USERNAME" >/dev/null; then
    log_info "Creating system user '${USERNAME}'..."
    useradd --system --gid "$GROUPNAME" --home-dir "$DATA_DIR" --shell /usr/sbin/nologin "$USERNAME"
  else
    log_info "User '${USERNAME}' already exists."
  fi
}

# Create necessary directories
setup_directories() {
  log_info "Setting up directories..."
  # /opt/momentum: Owned by root, executable by others
  mkdir -p "$INSTALL_DIR"
  chown root:root "$INSTALL_DIR"
  chmod 755 "$INSTALL_DIR"
  log_info "Created/verified directory: ${INSTALL_DIR}"

  # /etc/momentum: Owned by root, readable by the 'momentum' group
  mkdir -p "$CONFIG_DIR"
  chown root:"$GROUPNAME" "$CONFIG_DIR"
  chmod 750 "$CONFIG_DIR"
  log_info "Created/verified directory: ${CONFIG_DIR}"

  # /var/lib/momentum: Owned by the 'momentum' user/group
  mkdir -p "$DATA_DIR"
  chown "$USERNAME":"$GROUPNAME" "$DATA_DIR"
  chmod 700 "$DATA_DIR" # Restrict access to the user
  log_info "Created/verified directory: ${DATA_DIR}"

  # /var/log/momentum: Owned by 'momentum' user/group, readable by group
  mkdir -p "$LOG_DIR"
  chown "$USERNAME":"$GROUPNAME" "$LOG_DIR"
  chmod 750 "$LOG_DIR" # User rwx, Group rx
  log_info "Created/verified directory: ${LOG_DIR}"
}

# Stop the service if upgrading
stop_service() {
  if [[ "$INSTALL_MODE" == "upgrade" ]]; then
    log_info "Stopping existing ${APP_NAME} service..."
    if systemctl is-active --quiet "${APP_NAME}.service"; then
      systemctl stop "${APP_NAME}.service"
    else
      log_info "Service was not running."
    fi
  fi
}

# Install application files (binary, health check script, symlink)
install_files() {
  log_info "Installing application files..."

  # Install binary
  log_info "Copying binary from ${BINARY_SRC} to ${BINARY_DEST}..."
  cp "$BINARY_SRC" "$BINARY_DEST"
  chown root:root "$BINARY_DEST"
  chmod 755 "$BINARY_DEST"

  # Install health check script
  log_info "Copying health check script from ${HEALTH_CHECK_SRC} to ${HEALTH_CHECK_DEST}..."
  cp "$HEALTH_CHECK_SRC" "$HEALTH_CHECK_DEST"
  chown root:root "$HEALTH_CHECK_DEST"
  chmod 755 "$HEALTH_CHECK_DEST"

  # Create/update symlink
  log_info "Creating/updating symlink ${SYMLINK_DEST}..."
  ln -sf "$BINARY_DEST" "$SYMLINK_DEST"
}

# Handle configuration files (config.toml, secrets.env)
handle_configuration() {
  log_info "Handling configuration files..."

  # Handle config.toml
  if [[ ! -f "$CONFIG_DEST" ]]; then
    log_info "Creating initial configuration file ${CONFIG_DEST} from template..."
    cp "$CONFIG_TEMPLATE_SRC" "$CONFIG_DEST"
    chown root:"$GROUPNAME" "$CONFIG_DEST"
    chmod 640 "$CONFIG_DEST" # root rw, group r
    log_info "Initial config created. Please review and edit if necessary: ${CONFIG_DEST}"
  else
    log_info "Existing configuration file found at ${CONFIG_DEST}. Checking for updates..."
    # Implement merge_config logic here later
    merge_config "$CONFIG_TEMPLATE_SRC" "$CONFIG_DEST"
    # Ensure permissions are correct after potential merge
    chown root:"$GROUPNAME" "$CONFIG_DEST"
    chmod 640 "$CONFIG_DEST"
  fi

  # Handle secrets.env
  if [[ ! -f "$SECRETS_DEST" ]]; then
    log_info "Creating secrets file ${SECRETS_DEST}..."
    touch "$SECRETS_DEST"
    chown root:root "$SECRETS_DEST" # Owned by root
    chmod 600 "$SECRETS_DEST"     # Only readable/writable by root
    log_warn "Secrets file created at ${SECRETS_DEST}. You MUST edit this file to add required secrets."
  else
    log_info "Existing secrets file found at ${SECRETS_DEST}. Preserving."
    # Ensure permissions are correct on existing file
    chown root:root "$SECRETS_DEST"
    chmod 600 "$SECRETS_DEST"
  fi
}

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
    line_content=$(grep -B 5 -P "^\s*${key}\s*=" "$config_template" | grep -vP '^\s*--\s*$' | tail -n +1 ) # Crude way to get context
    # A simpler approach: just grab the key = value line
    line_content=$(grep -P "^\s*${key}\s*=" "$config_template")

    log_info "  - Adding: ${key}"
    echo "$line_content" >> "$config_current"
  done

  log_warn "Configuration updated with new options. Original saved to $config_backup"
  log_warn "Please review the added options in ${config_current}"
}


# Install systemd service file
install_systemd() {
  log_info "Installing systemd service file..."
  cp "$SYSTEMD_UNIT_SRC" "$SYSTEMD_UNIT_DEST"
  chown root:root "$SYSTEMD_UNIT_DEST"
  chmod 644 "$SYSTEMD_UNIT_DEST" # Standard permission for unit files
  log_info "Reloading systemd daemon..."
  systemctl daemon-reload
  log_info "Enabling ${APP_NAME} service to start on boot..."
  systemctl enable "${APP_NAME}.service"
}

# Setup cron job for backups
setup_cron() {
  log_info "Setting up daily backup cron job..."
  local cron_cmd="0 2 * * * ${USERNAME} ${BINARY_DEST} backup >> ${LOG_DIR}/backup.log 2>&1"
  echo "$cron_cmd" > "$CRON_FILE_DEST"
  chmod 644 "$CRON_FILE_DEST"
  chown root:root "$CRON_FILE_DEST"
  log_info "Cron job created at ${CRON_FILE_DEST}"
}

# Start the service
start_service() {
  log_info "Starting ${APP_NAME} service..."
  systemctl start "${APP_NAME}.service"
  # Optional: Short delay and status check
  sleep 2
  if systemctl is-active --quiet "${APP_NAME}.service"; then
    log_info "${APP_NAME} service started successfully."
  else
    log_error "Failed to start ${APP_NAME} service. Check logs with 'journalctl -u ${APP_NAME}.service'"
    # Optional: Attempt to show last few log lines
    journalctl -u "${APP_NAME}.service" --no-pager --lines=10
    exit 1
  fi
}

# --- Main Execution ---
main() {
  check_sudo
  parse_args "$@"

  # Determine source paths *before* starting core logic
  # Validation inside this function now checks for pre-built binary in --from-source mode
  determine_source_paths

  log_info "Starting Momentum installation/upgrade..."


  detect_install_mode

  # Core installation steps
  setup_user_group
  setup_directories
  stop_service # Stops only if upgrading
  install_files
  handle_configuration
  install_systemd
  setup_cron
  start_service

  log_info "--------------------------------------------------"
  log_info "Momentum installation/upgrade completed successfully!"
  if [[ "$INSTALL_MODE" == "install" ]]; then
      log_warn "ACTION REQUIRED: Please edit the secrets file at '${SECRETS_DEST}'"
      log_warn "                 and add your required secrets, then restart the service:"
      log_warn "                 sudo systemctl restart ${APP_NAME}.service"
  fi
  log_info "Service status: sudo systemctl status ${APP_NAME}.service"
  log_info "Service logs:   sudo journalctl -u ${APP_NAME}.service -f"
  log_info "--------------------------------------------------"
}

# Execute main function, passing all script arguments
main "$@"

exit 0
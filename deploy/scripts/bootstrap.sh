#!/usr/bin/env bash
# deploy/scripts/bootstrap.sh
set -euo pipefail # Exit on error, undefined variable, or pipe failure

# Momentum Bootstrap Installer
# Usage: curl -sSL https://raw.githubusercontent.com/public-daniel/Momentum/master/deploy/scripts/bootstrap.sh | bash -s -- [OPTIONS]
# Options:
#   -v, --version VERSION    Specify version (default: latest)
#   -h, --help               Show this help message
#   --no-color               Disable colored output

# --- Variables ---
REPO="public-daniel/Momentum" # Your GitHub repository
APP_NAME="momentum"           # Your application name
VERSION="latest"              # Default version to fetch
TEMP_DIR=""                   # Will be created by mktemp
COLORS=true                   # Enable colors by default

# --- Functions ---
print_help() {
  echo "Momentum Bootstrap Installer"
  echo "Usage: curl -sSL https://raw.githubusercontent.com/public-daniel/Momentum/master/deploy/scripts/bootstrap.sh | bash -s -- [OPTIONS]"
  echo "Options:"
  echo "  -v, --version VERSION    Specify version (e.g., v1.0.0, default: latest)"
  echo "  -h, --help               Show this help message"
  echo "  --no-color               Disable colored output"
  exit 0
}

cleanup() {
  if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
    echo # Newline for cleaner output
    log_info "Cleaning up temporary directory: $TEMP_DIR"
    rm -rf "$TEMP_DIR"
  fi
}

# Setup logging functions with color support
setup_colors() {
  # Define these variables in the global script scope
  if [[ -t 1 && "$COLORS" == true ]]; then # Check if stdout is a terminal and colors are enabled
    C_RESET='\033[0m'
    C_INFO='\033[0;34m'    # Blue
    C_SUCCESS='\033[0;32m' # Green
    C_WARN='\033[0;33m'    # Yellow
    C_ERROR='\033[0;31m'   # Red
  else
    # Set to empty strings if colors are disabled or stdout is not a TTY
    C_RESET=''
    C_INFO=''
    C_SUCCESS=''
    C_WARN=''
    C_ERROR=''
  fi
}

log_info() { echo -e "${C_INFO}[INFO]${C_RESET} $1"; }
log_success() { echo -e "${C_SUCCESS}[SUCCESS]${C_RESET} $1"; }
log_warn() { echo -e "${C_WARN}[WARN]${C_RESET} $1"; }
log_error() { echo -e "${C_ERROR}[ERROR]${C_RESET} $1" >&2; } # Log errors to stderr

# Check for required command
check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        log_error "Required command not found: '$cmd'. Please install it and try again."
        exit 1
    fi
}

# --- Argument Parsing ---
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -v|--version)
        if [[ -z "${2-}" ]]; then # Check if $2 is unset or empty
          log_error "Option --version requires an argument."
          exit 1
        fi
        VERSION="$2"
        shift 2 # past argument and value
        ;;
      -h|--help)
        print_help
        ;;
      --no-color)
        COLORS=false
        shift # past argument
        ;;
      *)
        log_error "Unknown option: $1"
        print_help
        exit 1
        ;;
    esac
  done
}

# --- Main Execution ---
main() {
  parse_args "$@"
  setup_colors # Initialize colors after parsing --no-color

  # Check for required commands early
  check_command "curl"
  check_command "jq" # Needed for 'latest' version lookup
  check_command "tar"
  check_command "sha256sum" # Needed for verification
  check_command "sudo" # Needed to run install.sh

  # Setup cleanup trap *after* potentially failing commands
  TEMP_DIR=$(mktemp -d)
  trap cleanup EXIT

  log_info "Starting Momentum bootstrap process..."

  # Determine version to install
  local actual_version="$VERSION"
  if [[ "$VERSION" == "latest" ]]; then
    log_info "Querying GitHub API for the latest release..."
    local api_url="https://api.github.com/repos/${REPO}/releases/latest"
    actual_version=$(curl -sSL "$api_url" | jq -r '.tag_name')
    if [[ -z "$actual_version" || "$actual_version" == "null" ]]; then
      log_error "Could not determine the latest version from GitHub API: $api_url"
      log_error "Please specify a version manually using --version vX.Y.Z"
      exit 1
    fi
    log_info "Latest version found: ${actual_version}"
  else
    # Basic validation for tag format (starts with 'v')
    if [[ ! "$actual_version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
       log_warn "Version format '$actual_version' might be incorrect. Expected format like 'v1.2.3'."
       # Continue anyway, maybe it's a custom tag
    fi
    log_info "Using specified version: ${actual_version}"
  fi

  # Construct download URLs
  local archive_name="${APP_NAME}-${actual_version}.tar.gz"
  local archive_url="https://github.com/${REPO}/releases/download/${actual_version}/${archive_name}"
  local checksum_url="https://github.com/${REPO}/releases/download/${actual_version}/checksums.txt"
  local archive_path="${TEMP_DIR}/${archive_name}"
  local checksum_path="${TEMP_DIR}/checksums.txt"

  # Download release artifact and checksums
  log_info "Downloading archive from: ${archive_url}"
  if ! curl --fail --show-error -sSL "$archive_url" -o "$archive_path"; then
    log_error "Download failed for archive. Check if version '${actual_version}' and the corresponding release exist."
    exit 1
  fi

  log_info "Downloading checksums from: ${checksum_url}"
   if ! curl --fail --show-error -sSL "$checksum_url" -o "$checksum_path"; then
    log_error "Download failed for checksums file. Check if version '${actual_version}' and the corresponding release exist."
    # Optionally, allow proceeding without checksums with a warning? For now, fail hard.
    exit 1
  fi

  # Verify checksum
  log_info "Verifying checksum for ${archive_name}..."
  cd "$TEMP_DIR" # Change directory so sha256sum finds the relative path
  if ! sha256sum -c --ignore-missing <(grep "$archive_name" "$checksum_path"); then
      log_error "Checksum verification FAILED! The downloaded file may be corrupted or tampered with."
      exit 1
  fi
  log_success "Checksum verified successfully."

  # Extract archive
  log_info "Extracting archive..."
  # We expect the tarball contains the files directly, not nested in another dir based on workflow
  mkdir -p "${TEMP_DIR}/extract"
  if ! tar -xzf "$archive_path" -C "${TEMP_DIR}/extract"; then
      log_error "Failed to extract the archive."
      exit 1
  fi

  # Navigate into extracted directory (assuming structure matches workflow)
  local install_script_path="${TEMP_DIR}/extract/scripts/install.sh"
  if [[ ! -f "$install_script_path" ]]; then
      log_error "Could not find install.sh at the expected path: ${install_script_path}"
      log_error "The release archive structure might be incorrect."
      exit 1
  fi

  # Run installation script with sudo
  log_info "Executing installation script via sudo..."
  cd "${TEMP_DIR}/extract" # Run install script from the extracted root
  if ! sudo ./scripts/install.sh; then
    log_error "Installation script failed. Please check the output above for details."
    exit 1
  fi

  log_success "Momentum ${actual_version} installation/upgrade completed successfully!"
  log_info "Next steps:"
  log_info "1. If this is a fresh installation, **edit the secrets file**: sudo nano /etc/${APP_NAME}/secrets.env"
  log_info "2. Check service status: sudo systemctl status ${APP_NAME}.service"
  log_info "3. Follow logs: sudo journalctl -u ${APP_NAME}.service -f"
}

# Execute main function, passing all script arguments from the pipe
main "$@"

exit 0 # Ensure successful exit if main completes
#!/usr/bin/env bash
set -euo pipefail # Exit on error, undefined variable, or pipe failure

# Momentum Health Check Script
# Performs comprehensive checks on the Momentum service and its dependencies.
# Recommended to be run via cron as root.

# --- Configuration ---
# These should match the values used in install.sh
APP_NAME="momentum"
USERNAME="momentum"
GROUPNAME="momentum"
DATA_DIR="/var/lib/${APP_NAME}"
INSTALL_DIR="/opt/${APP_NAME}" # Location of binary, needed for backup check maybe?

# Health Check Specific Configuration
SERVICE_NAME="${APP_NAME}.service"
HTTP_ENDPOINT="http://localhost:8686/health" # Adjust if Momentum listens on a different port/path
DB_FILE_NAME="momentum.db"                   # Assumed default DB filename within DATA_DIR
DB_FILE_PATH="${DATA_DIR}/${DB_FILE_NAME}"     # Assumes this path is fixed. Adjust if configurable & knowable.
DISK_WARNING_THRESHOLD=80                    # Disk usage % threshold for WARNING
DISK_CRITICAL_THRESHOLD=90                   # Disk usage % threshold for CRITICAL
RECENT_ERRORS_TIMESPAN="1 hour ago"          # How far back to check journald for errors

# --- Script Variables ---
OVERALL_STATUS="OK" # OK, WARNING, CRITICAL
MESSAGES=()

# Exit codes for monitoring systems (Nagios/Icinga compatible)
EXIT_OK=0
EXIT_WARNING=1
EXIT_CRITICAL=2
EXIT_UNKNOWN=3

# --- Helper Functions ---

# Add a message and update overall status if necessary
# Usage: add_message "LEVEL" "Message text"
add_message() {
    local level="$1"
    local message="$2"

    MESSAGES+=("[$level] $message")

    case "$level" in
        CRITICAL)
            OVERALL_STATUS="CRITICAL"
            ;;
        WARNING)
            # Only elevate to WARNING if not already CRITICAL
            if [[ "$OVERALL_STATUS" != "CRITICAL" ]]; then
                OVERALL_STATUS="WARNING"
            fi
            ;;
        OK)
            # OK messages don't change the status unless it's currently UNKNOWN (shouldn't happen here)
            ;;
        *)
            log_error "Unknown message level: $level"
            ;;
    esac
}

# Basic error logging to stderr
log_error() {
    echo "[ERROR] $1" >&2
}

# Check for required command
check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &> /dev/null; then
        add_message "CRITICAL" "Required command not found: '$cmd'. Health check cannot proceed reliably."
        # Set status directly as this is a fundamental issue for the check script itself
        OVERALL_STATUS="CRITICAL"
        return 1 # Indicate failure
    fi
    return 0 # Indicate success
}

# Check if running as root/sudo
check_sudo() {
  if [[ "$EUID" -ne 0 ]]; then
    # Use add_message so it's included in the report
    add_message "CRITICAL" "This health check script must be run with root privileges (e.g., using sudo)."
    OVERALL_STATUS="CRITICAL"
    return 1
  fi
  return 0
}


# --- Check Functions ---

check_dependencies() {
    log_info "Checking required tools..."
    # Check critical tools needed for basic operation
    check_command "systemctl" || return 1
    check_command "stat" || return 1
    check_command "df" || return 1
    check_command "grep" || return 1
    check_command "awk" || return 1
    check_command "journalctl" || return 1

    # Check optional tools and note if missing
    if ! command -v "curl" &> /dev/null; then
        add_message "WARNING" "'curl' command not found. Skipping HTTP endpoint check."
    fi
     if ! command -v "sqlite3" &> /dev/null; then
        add_message "WARNING" "'sqlite3' command not found. Skipping database integrity check."
    fi
}

check_service_active() {
    log_info "Checking service active status..."
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        add_message "OK" "Service '$SERVICE_NAME' is active."
    else
        # Use systemctl status to try and get more info on why it's inactive
        local status_output
        status_output=$(systemctl status "$SERVICE_NAME" || true) # Prevent script exit if status fails strangely
        add_message "CRITICAL" "Service '$SERVICE_NAME' is INACTIVE. Status: $(echo "$status_output" | head -n 5)" # Show first few lines
    fi
}

check_service_status_details() {
    log_info "Checking service status details..."
    # This check only runs if the service is active from the previous check
    if [[ "$OVERALL_STATUS" == "CRITICAL" ]]; then
        log_info "Skipping status details check as service is inactive."
        return
    fi

    local status_output
    status_output=$(systemctl status "$SERVICE_NAME" 2>&1) # Capture stderr too
    if echo "$status_output" | grep -q -E "warning|degraded|failed"; then
        # Try to extract the relevant line(s)
        local problem_line
        problem_line=$(echo "$status_output" | grep -E "warning|degraded|failed" | head -n 1)
        add_message "WARNING" "Service '$SERVICE_NAME' has non-OK status detail: ${problem_line:-Status contains warnings/errors}"
    else
        add_message "OK" "Service '$SERVICE_NAME' status details appear normal."
    fi

    # Check journald for recent errors
    log_info "Checking journald for recent errors (${RECENT_ERRORS_TIMESPAN})..."
    if journalctl -u "$SERVICE_NAME" --since "$RECENT_ERRORS_TIMESPAN" -p err --no-pager --quiet; then
       # Command returns 0 if errors are found, 1 if not. --quiet suppresses output.
       add_message "WARNING" "Errors found in service journal logs within the last '${RECENT_ERRORS_TIMESPAN}'."
    else
       add_message "OK" "No errors found in recent service journal logs."
    fi
}

check_http_endpoint() {
    log_info "Checking HTTP endpoint..."
    if ! command -v "curl" &> /dev/null; then
         log_info "Skipping HTTP check ('curl' not found)."
         return
    fi

    # Use curl with timeout and failure flags
    # -sS: Silent mode but show errors
    # -f: Fail silently (no output) on HTTP errors (4xx, 5xx) - returns non-zero exit code
    # -m: Max time allowed for operation
    # -o /dev/null: Discard successful output body
    if curl -sSf -m 5 "$HTTP_ENDPOINT" -o /dev/null; then
        add_message "OK" "HTTP health endpoint '$HTTP_ENDPOINT' responded successfully."
    else
        add_message "CRITICAL" "HTTP health endpoint '$HTTP_ENDPOINT' failed or timed out."
    fi
}

check_db_file() {
    log_info "Checking database file..."
    if [[ ! -f "$DB_FILE_PATH" ]]; then
        add_message "CRITICAL" "Database file not found at expected location: $DB_FILE_PATH"
        return
    fi

    add_message "OK" "Database file exists: $DB_FILE_PATH"

    # Check ownership
    local db_owner db_group
    db_owner=$(stat -c %U "$DB_FILE_PATH")
    db_group=$(stat -c %G "$DB_FILE_PATH")
    if [[ "$db_owner" != "$USERNAME" ]] || [[ "$db_group" != "$GROUPNAME" ]]; then
        add_message "WARNING" "Database file ownership is incorrect ($db_owner:$db_group). Expected ($USERNAME:$GROUPNAME)."
    else
        add_message "OK" "Database file ownership ($db_owner:$db_group) is correct."
    fi

    # Check permissions (expecting 600 or maybe 660 if group access needed - check app requirements)
    # Let's assume 600 or 700 based on install script DATA_DIR perms (700 on dir, file likely 600)
    local db_perms
    db_perms=$(stat -c %a "$DB_FILE_PATH")
     # Simple check: is it owner-read/write only (600)? Or owner rwx only (700)?
    if [[ "$db_perms" != "600" ]] && [[ "$db_perms" != "700" ]] && [[ "$db_perms" != "660" ]] ; then # Allow 660 just in case
        add_message "WARNING" "Database file permissions are unusual (${db_perms}). Expected owner read/write (e.g., 600 or 660)."
    else
        add_message "OK" "Database file permissions (${db_perms}) seem reasonable."
    fi
}

check_db_integrity() {
    log_info "Checking database integrity..."
     if ! command -v "sqlite3" &> /dev/null; then
         log_info "Skipping database integrity check ('sqlite3' not found)."
         return
     fi
    if [[ ! -f "$DB_FILE_PATH" ]]; then
        log_info "Skipping database integrity check (file not found)."
        return
    fi

    # Run PRAGMA integrity_check. Output should be 'ok'.
    # Run as root, assuming root can read the file (default perms usually allow this).
    local integrity_result
    if integrity_result=$(sqlite3 "$DB_FILE_PATH" "PRAGMA integrity_check;" 2>&1); then
        if [[ "$integrity_result" == "ok" ]]; then
            add_message "OK" "Database integrity check passed ('ok')."
        else
            # PRAGMA succeeded but reported errors
            add_message "CRITICAL" "Database integrity check failed. Result: $integrity_result"
        fi
    else
        # sqlite3 command itself failed (e.g., permissions, file locked, corrupt header)
         add_message "CRITICAL" "Failed to execute database integrity check. Error: $integrity_result"
    fi
}

check_disk_space() {
    log_info "Checking disk space for data directory..."
    # Get usage percentage for the filesystem containing DATA_DIR
    local disk_usage_percent
    local filesystem_info
    # Get filesystem info, handle potential newline in df output, extract usage %
    filesystem_info=$(df "$DATA_DIR" | awk 'NR==2')
    disk_usage_percent=$(echo "$filesystem_info" | awk '{print $5}' | tr -d '%')
    local mount_point
    mount_point=$(echo "$filesystem_info" | awk '{print $6}')


    if [[ -z "$disk_usage_percent" ]] || ! [[ "$disk_usage_percent" =~ ^[0-9]+$ ]]; then
         add_message "WARNING" "Could not determine disk usage for '$DATA_DIR'."
         return
    fi

    add_message "OK" "Disk usage for '$DATA_DIR' (on $mount_point) is ${disk_usage_percent}%."

    if [[ "$disk_usage_percent" -ge "$DISK_CRITICAL_THRESHOLD" ]]; then
        add_message "CRITICAL" "Disk usage (${disk_usage_percent}%) exceeds critical threshold (${DISK_CRITICAL_THRESHOLD}%) for filesystem mounted at $mount_point."
    elif [[ "$disk_usage_percent" -ge "$DISK_WARNING_THRESHOLD" ]]; then
        add_message "WARNING" "Disk usage (${disk_usage_percent}%) exceeds warning threshold (${DISK_WARNING_THRESHOLD}%) for filesystem mounted at $mount_point."
    fi
}

# --- Main Execution ---
log_info() { echo "[INFO] $1"; } # Define minimal logger for setup phase

main() {
    log_info "Starting Momentum Health Check..."

    if ! check_sudo; then
        # check_sudo adds the message and sets status
        : # Do nothing else, let it fall through to report phase
    elif ! check_dependencies; then
        # check_dependencies adds messages and sets status if critical tools missing
        : # Do nothing else
    else
        # Run checks only if sudo and critical dependencies are OK
        check_service_active
        check_service_status_details # Includes journald check
        check_http_endpoint
        check_db_file
        check_db_integrity
        check_disk_space
        # Add other checks here if needed
    fi

    # --- Reporting ---
    echo "-------------------------------------"
    echo "Momentum Health Check Report"
    echo "Overall Status: $OVERALL_STATUS"
    echo "Timestamp: $(date)"
    echo "-------------------------------------"
    printf "%s\n" "${MESSAGES[@]}" # Print each message on a new line
    echo "-------------------------------------"


    # --- Set Exit Code ---
    case "$OVERALL_STATUS" in
        CRITICAL) exit $EXIT_CRITICAL ;;
        WARNING) exit $EXIT_WARNING ;;
        OK) exit $EXIT_OK ;;
        *) exit $EXIT_UNKNOWN ;; # Should not happen in normal flow
    esac
}

# Execute main function
main
# Assumes:
# - Rust toolchain (rustup, cargo, rustfmt, clippy) is installed.
# - 'uv' is installed (for uvx).
# - 'just' is installed globally or otherwise available in PATH.

# Variables
export RUST_BACKTRACE := "1"

# Default task runs the comprehensive check suite (including tests)
default: check

# --- Environment Setup ---
# Set up development environment with pre-commit hooks
setup:
    @echo "Setting up development environment..."
    @echo "Checking for required Rust components..."
    @rustup component add clippy rustfmt
    @echo "Installing optional cargo tools (audit, outdated)..."
    @cargo install cargo-audit cargo-outdated sqlx-cli --quiet || true # Use || true to ignore errors if already installed
    @echo "Installing Git hooks via uvx and .pre-commit-config.yaml..."
    @uvx pre-commit install # Installs hooks based on .pre-commit-config.yaml
    @echo "✅ Development environment setup complete!"
    @echo "Note: Ensure .pre-commit-config.yaml exists before running setup."

# Remove pre-commit hooks and cleanup
cleanup:
    @echo "Cleaning up development environment..."
    @echo "Removing Git hooks FOR THIS REPOSITORY via uvx..."
    @uvx pre-commit uninstall
    @echo "✅ Git hooks for this repository removed!"
    @echo "✅ Cleanup complete!"

# Clean build artifacts
clean:
    @echo "Cleaning build artifacts..."
    @cargo clean
    @rm -rf target # Ensure target is removed too
    @rm -rf .DS_Store **/.DS_Store # Clean macOS specific files
    @echo "✅ Clean complete!"

# Update dependencies to latest compatible versions
update:
    @echo "Updating dependencies..."
    @cargo update
    @echo "Checking for outdated dependencies (run 'just update' to apply changes)..."
    @cargo outdated --exit-code 0 || true # Show outdated, but do not fail the task
    @echo "✅ Dependency update check complete. Review output above."

# Update pre-commit hook definitions to latest versions
update-hooks:
    @echo "Updating pre-commit hooks..."
    @uvx pre-commit autoupdate
    @echo "✅ Pre-commit hooks updated!"

# Update everything (dependencies and hooks)
update-all: update update-hooks
    @echo "✅ All updates complete!"

# --- Formatting ---
# Check if code needs formatting (for hooks/CI)
fmt-check:
    @echo "Checking formatting..."
    @cargo fmt -- --check
    @echo "✅ Formatting check complete!"

# Apply formatting
fmt:
    @echo "Applying formatting..."
    @cargo fmt
    @echo "✅ Formatting applied!"

# --- Linting ---
# Run clippy linter (fail on warnings)
lint:
    @echo "Running linter (clippy)..."
    @cargo clippy --all-targets --all-features -- -D warnings # Add --all-features if needed
    @echo "✅ Linting complete!"

# --- Testing ---
# Run tests
test:
    @echo "Running tests..."
    @cargo test --all-targets --all-features # Add --all-features if needed
    @echo "✅ Tests complete!"

# --- Security ---
# Check for security vulnerabilities in dependencies
audit:
    @echo "Checking for security vulnerabilities..."
    @cargo audit
    @echo "✅ Security audit complete!"

# --- Comprehensive Check Suite ---
# Runs format check, lint, and tests. Good for manual checks.
tidy: fmt-check lint test
    @echo "✅ All checks (fmt, lint, test) passed!"

# Alias 'check' to 'tidy' for convenience
check: tidy

# --- Pre-Commit Hook Specific Task ---
# Faster checks suitable for the pre-commit hook (no tests).
# Recommended entry for .pre-commit-config.yaml for faster commits.
hook-checks: fmt-check lint
    @echo "✅ Pre-commit hook checks (fmt, lint) passed!"

# --- Build ---
# Build the project (debug mode)
build:
    @echo "Building project (debug)..."
    @cargo build --all-targets --all-features # Add --all-features if needed
    @echo "✅ Debug build complete!"

# Build with release optimizations
release:
    @echo "Building release version..."
    @cargo build --release --all-targets --all-features # Add --all-features if needed
    @echo "✅ Release build complete!"

# --- Documentation ---
# Generate and open documentation (for main library/binary only)
docs:
    @echo "Generating documentation..."
    @cargo doc --no-deps --open
    @echo "✅ Documentation generated!"

# --- Run ---
# Run the project (debug mode)
run: build
    @echo "Running project (debug)..."
    @cargo run

# Run with release optimizations
run-release: release
    @echo "Running release version..."
    @cargo run --release

# --- CI Tasks ---
# Comprehensive task typically run in Continuous Integration
ci: fmt-check lint test audit
    @echo "✅ CI checks passed!"

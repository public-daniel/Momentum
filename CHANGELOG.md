# Changelog

## [0.1.0] - 2025-04-01

### Added

- Initial project structure and core functionality.
- Setup CI/CD workflows (`ci.yml`, `release.yml`).
- Added `justfile` for common development tasks.
- Added `pre-commit` configuration for local checks.
- Included deployment scripts (`install.sh`, `health-check.sh`, `bootstrap.sh`) and systemd unit file.
- Added initial `deploy.md` documentation.
- Configured `cargo audit` ignore for RUSTSEC-2023-0071 due to Cargo issue #10801.

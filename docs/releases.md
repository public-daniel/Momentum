# Momentum Release Process

**Last Updated:** 2025-04-01

This document outlines the definitive procedure for creating official, versioned releases of Momentum. Following this process ensures that releases are consistent, communicative, built from a verified state of the code, and published reliably via automation.

## Prerequisites

Before initiating a release, ensure you have:

1. **Git:** The Git command-line tool installed and configured.
2. **Repository Access:** Permissions to push to the `master` branch and push tags to the `public-daniel/Momentum` repository on GitHub. Depending on repository settings, you may need rights to merge Pull Requests.
3. **Local Repository:** An up-to-date clone of the repository.
4. **`just` command:** For running local checks easily (install via `cargo install just`).

## Guiding Principles

* **Semantic Versioning:** We use version numbers to clearly communicate the nature of changes (see section below).
* **Reproducibility:** Releases are built from specific, tagged commits, ensuring traceability and reproducibility (helped by committing `Cargo.lock`).
* **Automation:** The build, packaging, and publishing steps are automated via GitHub Actions (`.github/workflows/release.yml`) triggered by tag pushes.
* **Verification:** Both automated CI checks and manual post-release artifact testing are crucial quality gates.
* **Master as Source:** The `master` branch represents the definitive source for releases.

## Understanding Semantic Versioning (SemVer)

Momentum follows **Semantic Versioning (SemVer)** to clearly convey the impact of changes between releases. This practice is vital for users and maintainers. For a deeper dive, see the official specification at [https://semver.org](https://semver.org).

**The Format: `MAJOR.MINOR.PATCH` (e.g., `1.0.0`)**

* **`MAJOR` (1):** Incremented for **incompatible API changes** (breaks backward compatibility). Reset MINOR/PATCH to 0. Users likely need to adapt their usage.
* **`MINOR` (0):** Incremented for **adding functionality** in a backward-compatible way. Reset PATCH to 0. Users can generally upgrade without changes.
* **`PATCH` (0):** Incremented for **backward-compatible bug fixes**. Users can typically upgrade safely.

**The `v` Prefix (e.g., `v1.0.0`)**

We use a `v` prefix for our Git tags (like `v1.0.0`). This is a common convention that clearly identifies version tags. **Our automated release workflow is configured to trigger *only* on tags matching this `vX.Y.Z` pattern.**

Deciding the correct version bump is a key part of the release preparation.

---

## Release Workflow Steps

### Step 1: Prepare the Release Branch (`master`)

All release tags are created from the `master` branch. It must be stable and contain everything intended for the release *before* tagging.

1. **Ensure Stability and Content:**
    * Confirm the `master` branch contains the exact code intended for the release. Code arrives on `master` either through:
        * **Merging Pull Requests (Preferred):** Integrating reviewed and approved changes from feature branches. This is the recommended approach for team collaboration and code quality.
        * **Direct Commits:** Pushing commits directly to `master`.
    * Regardless of the method, ensure **all features and fixes** designated for this version are present on the `master` branch.
    * Verify that the **latest commit** on `master` passes all Continuous Integration checks. Check the [Actions tab](https://github.com/public-daniel/Momentum/actions) or run locally:

        ```bash
        # Ensure you are on the master branch and up-to-date
        git checkout master
        git pull origin master

        # Run the CI check suite
        just ci
        ```

    * Address any failures before proceeding.

2. **Determine Next Version:** Based on the changes present on `master` since the last release, decide the correct next semantic version (`MAJOR.MINOR.PATCH`) according to the rules above.

3. **Update `Cargo.toml`:**
    * Edit `Cargo.toml` and set the `version` field under `[package]` to the exact version decided in the previous step (e.g., `version = "1.0.0"`).
    * **Why:** This embeds the correct version into the compiled binary, making `momentum --version` accurate and aligning the code with the release tag.

4. **Update `CHANGELOG.md`:**
    * Edit `CHANGELOG.md` and add a new release section for the version decided above.
    * Summarize significant changes (features, fixes, breaking changes) clearly. Referencing relevant issue numbers or PRs is helpful.
    * **Why:** This provides essential context for users upgrading and documents the project's evolution.

5. **Commit Preparation:**
    * Commit the updated `Cargo.toml`, `CHANGELOG.md`, and crucially, the `Cargo.lock` file to ensure reproducible dependencies.
    * **Why `Cargo.lock`:** Committing the lock file ensures the release is built with the exact same dependency versions that were tested during CI.

    ```bash
    # Stage the changes
    git add Cargo.toml CHANGELOG.md Cargo.lock

    # Commit the changes
    git commit -m "chore: Prepare release v<MAJOR.MINOR.PATCH>" # Use the determined version

    # Push to the remote master branch
    git push origin master
    ```

    * **Verify CI again:** Ensure the preparation commit itself passes all CI checks on `master`.

### Step 2: Create and Push the Git Tag

This step triggers the automated release creation.

1. **Create Annotated Tag:**
    * Ensure your local repository is on the exact commit you just pushed to `master` (the preparation commit).
    * Create an **annotated** Git tag using the `vX.Y.Z` format matching the version determined earlier.

    ```bash
    # Example for version 1.0.0
    # Double-check you are on the correct commit!
    git tag -a v1.0.0 -m "Release version 1.0.0"
    ```

2. **Push the Tag:**
    * Push *only the tag* to the `origin` remote. This triggers the "Create Release and Build Artifacts" GitHub Actions workflow.

    ```bash
    # Replace v1.0.0 with the actual tag created
    git push origin v1.0.0
    ```

### Step 3: Monitor the Release Workflow

1. **Navigate to Actions:** Go to the repository's [Actions tab](https://github.com/public-daniel/Momentum/actions).
2. **Find Workflow:** Locate the "Create Release and Build Artifacts" run triggered by your tag push.
3. **Monitor:** Observe the workflow's progress. If it fails:
    * **Diagnose:** Examine the logs thoroughly to find the error's root cause.
    * **Fix:** Correct the issue on the `master` branch, verify the fix with CI.
    * **Delete Failed Tag:** Critically, remove the tag that caused the failed run, both locally and remotely, to allow retrying.
        * **Caution:** Verify tag names carefully before deletion.

        ```bash
        git tag -d v1.0.0 && git push origin :refs/tags/v1.0.0
        ```

    * **Retry:** Go back to Step 2 (Create and Push Git Tag) using the *same tag name* once the underlying issue is fixed on `master`.

### Step 4: Verify and Test the Release

Successful workflow execution doesn't guarantee a perfect release. Manual verification is essential.

1. **Check GitHub Release:**
    * Navigate to the repository's [Releases page](https://github.com/public-daniel/Momentum/releases).
    * Find the newly created release.
    * **Verify:** Title, tag, and release notes (including installation instructions) are correct. The required assets (`.tar.gz`, `checksums.txt`) are present.

2. **Test the Artifact (Critical):**
    * Download the `.tar.gz` artifact and `checksums.txt`.
    * **Verify Checksum:** Ensure the download integrity.

        ```bash
        sha256sum -c <(grep "momentum-vX.Y.Z.tar.gz" checksums.txt) # Use correct version
        ```

    * **Perform Installation Test:** On a clean test environment (VM, container, server):
        * Use the `bootstrap.sh` command from the release notes **or** follow the manual release package installation (`deploy.md` Method 2).
        * Verify the application installs correctly, starts, and core functionality operates as expected. This step catches issues missed by automated tests (e.g., packaging errors, runtime configuration problems).

### Step 5: Post-Release Actions (Optional)

Once the release is verified and tested:

* **Communicate:** Announce the new release to users, team members, or stakeholders through appropriate channels (e.g., Slack, mailing list, blog post). Highlight key changes from the `CHANGELOG.md`.
* **Update Documentation:** Ensure any relevant documentation reflects the new version or features.

---

## Process Assumptions

* **Branching Strategy:** This guide assumes releases are tagged directly off the `master` branch. Code arrives on `master` via merged PRs (preferred) or direct commits. If using long-lived release branches, this process needs adaptation.
* **Scope:** This guide focuses on standard `MAJOR.MINOR.PATCH` releases. Procedures for pre-releases (alpha, beta, rc) or hotfixes for previous versions may require separate, adapted processes.

---

Adhering to this comprehensive process ensures Momentum releases are predictable, reliable, and clearly communicate changes to everyone involved.

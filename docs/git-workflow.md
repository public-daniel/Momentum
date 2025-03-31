# Momentum Git Workflow

**Last Updated:** 2025-04-01

## 1. The Goal: Sustainable & Professional Development

This document defines the standard Git workflow for the Momentum project. Even working solo, adopting professional Git practices is an investment that pays significant dividends. It ensures your project history is clear, traceable, and maintainable, drastically simplifying future debugging, feature additions, and potential collaboration. This isn't just process for process' sake; it's about building a high-quality, understandable, and resilient codebase over time.

## 2. Foundational Git Habits

These principles underpin a clean and effective workflow:

* **`master` is Sacrosanct & Deployable:** The `master` branch represents the stable, deployable state of the project. It should *always* pass all tests and be considered production-ready. Protect it accordingly.
* **Isolate Your Work:** All non-trivial development must occur on dedicated branches, isolating changes until they are complete and verified.
* **Commit Atomically & Often:** Each commit should represent a single, complete, logical change. Think of commits as save points for *one idea* or *one step*. This makes history easy to navigate, review, and debug (e.g., using `git bisect`).
* **Communicate Through Commits:** Your commit messages are a crucial form of documentation. Write clear, structured messages following the Conventional Commits standard (detailed below). Future You will thank you.
* **Integrate Deliberately via Pull Requests:** Use Pull Requests (PRs) as a formal checkpoint to review, verify, and document the integration of changes into `master`, even if you are the sole reviewer.

## 3. Branching Strategy: Isolate, Develop, Integrate

Our model relies on two main branch types:

* **`master` Branch:**
  * The single source of truth for stable, production-ready code.
  * **Must always pass all CI checks (`just ci`).**
  * Direct pushes are strongly discouraged and reserved for exceptional cases only (See Section 6).
  * Release tags (`vX.Y.Z`) are *only* created from commits on this branch.

* **Feature Branches (e.g., `feature/user-profile-page`, `fix/auth-token-expiry`):**
  * **The standard location for all development work.** This includes new features, bug fixes, refactoring, documentation updates, dependency changes, and experiments.
  * **Always create from the latest `master`.**
  * Use descriptive names prefixed logically (e.g., `feature/`, `fix/`, `chore/`, `docs/`, `refactor/`).
  * Keep them focused on a single task or piece of functionality.
  * Short-lived: They exist only until the work is complete and merged via PR.

## 4. Commit Hygiene: Writing a Clean History

Clean commits are essential for maintainability. Sloppy commits create technical debt in your history.

* **Atomicity:** Ensure each commit is the smallest logical change that stands on its own. Avoid mixing unrelated changes (e.g., a bug fix and a feature enhancement in one commit). If a change touches multiple aspects (e.g., backend API and frontend UI), consider if they can be logically separated into sequential commits.
  * *Tip:* Use `git add -p` (patch mode) to interactively stage parts of files, helping you create focused commits.
* **Conventional Commits:** We enforce the [Conventional Commits](https://www.conventionalcommits.org/) specification for clear, structured, and potentially automated history analysis (like CHANGELOG generation).

    **Format:**

    ```txt
    <type>(<scope>): <description>
    <BLANK LINE>
    [optional body: explain the 'why']
    <BLANK LINE>
    [optional footer(s): BREAKING CHANGE, Closes #issue]
    ```

  * **`<type>`:** `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci` (See spec for details).
  * **`(<scope>)`:** Optional context (e.g., `api`, `ui`, `db`, `deps`).
  * **`<description>`:** Imperative mood, concise summary (e.g., `Implement user deletion endpoint`). Max ~50 chars. No period at the end.
  * **`[body]`:** Explain *why* this change is necessary and *how* it addresses the issue, if not obvious from the description. Detail trade-offs or alternative approaches considered if relevant. Wrap lines at ~72 chars.
  * **`[footer(s)]`:** `BREAKING CHANGE: <explanation>` (critical!) or `Closes #123`, `Refs #456`.

    **Good Example:**

    ```txt
    feat(auth): implement rate limiting on login attempts

    Introduces rate limiting using an in-memory store to prevent brute-force
    attacks against the login endpoint (/api/login). Limits are set to
    10 attempts per IP per minute.

    This addresses security concern raised in issue #75.

    Refs #75
    ```

* **Commit `Cargo.lock`:** Always commit `Cargo.lock` changes alongside `Cargo.toml` updates. This guarantees dependency versions are locked for reproducible builds across all environments.

## 5. Standard Workflow: Feature Branches & Pull Requests

This process should be used for >95% of changes.

1. **Sync `master`:** Start with the latest stable code.

    ```bash
    git checkout master
    git pull origin master
    ```

2. **Create Feature Branch:** Branch off `master` with a descriptive name.

    ```bash
    git checkout -b feature/describe-your-feature
    ```

3. **Develop & Commit Atomically:** Make your code changes. Commit frequently using the Conventional Commits format. Focus on small, logical steps.

    ```bash
    # ... make changes ...
    git add .
    git commit -m "feat(module): implement part 1"
    # ... make more changes ...
    git add .
    git commit -m "refactor(module): clean up part 1 implementation"
    ```

    * *(See Section 7 for keeping this branch updated with `master` and cleaning history)*
4. **Push Branch:** Share your branch with the remote repository. Use `--set-upstream` (or `-u`) the first time.

    ```bash
    git push -u origin feature/describe-your-feature
    ```

5. **Create Pull Request (PR):** Via GitHub:
    * **Target:** `master` branch.
    * **Title:** Clear, concise summary (often Conventional Commit style).
    * **Description:** Explain the 'what' and 'why'. Link issues (`Closes #...`). Provide context for the reviewer (Future You!). Add testing steps or UI visuals if relevant.
6. **Perform Self-Review:** Treat this seriously. It's your primary quality gate. Use a checklist:
    * [ ] **Correctness:** Does it fulfill requirements? Works correctly? Edge cases handled?
    * [ ] **Clarity:** Is the code readable/understandable? Naming clear?
    * [ ] **Consistency:** Follows project style/patterns?
    * [ ] **Completeness:** No debug code? Tests included/passing? Docs updated?
    * [ ] **Simplicity:** Can it be simplified?
    * [ ] **CI Checks:** All automated checks pass?
    * Push fixes to the branch if needed. The PR updates automatically.
7. **Merge PR (Squash and Merge):**
    * **Method:** Use GitHub's **"Squash and Merge"** option.
    * **Why:** Keeps `master` history clean and linear (one commit per feature/fix). Makes project evolution easy to track via `git log master`.
    * **Edit Squash Commit Message:** **Critically, refine the auto-generated message.** Ensure it's a single, well-formed Conventional Commit message summarizing the *entire* change. Include the PR number (`(#<PR_Number>)`).
8. **Delete Branch:** Clean up locally and remotely.

    ```bash
    git checkout master # Switch back to master locally
    git branch -d feature/describe-your-feature # Delete local branch
    git push origin --delete feature/describe-your-feature # Delete remote branch
    ```

## 6. The Exception: Direct Pushes to `master`

Direct pushes bypass the PR review/integration step. They should be **extremely rare** and require **absolute certainty** the change is trivial and risk-free. **When in doubt, use a PR.**

* **Strictly Limited Use Cases:** Fixing a minor typo in `README.md` (`docs:`).
* **Procedure If Absolutely Necessary:**
    1. Sync `master` (`git checkout master && git pull origin master`).
    2. Make the *single, tiny* change.
    3. **Run All Checks Locally:** `just ci`. **Do not skip.**
    4. Commit using Conventional Commits standard.
    5. Push: `git push origin master`.
    6. **Verify CI on Remote:** Immediately confirm CI passes on `master`. Revert immediately if it fails (see Section 7.5).

## 7. Common Git Operations & Techniques

These techniques help manage your workflow effectively.

### 7.1 Keeping Feature Branches Updated

As `master` evolves, you'll want to incorporate those updates into your feature branch to avoid large integration conflicts later. There are two main ways: Merging or Rebasing.

* **Option A: Merging `master` into your Feature Branch**

    ```bash
    git checkout feature/my-feature # Make sure you are on your branch
    git fetch origin # Get latest changes from remote, don't merge yet
    git merge origin/master # Merge the latest master into your branch
    # Resolve any merge conflicts (see 7.2), then commit the merge
    ```

  * **Pros:** Simple concept; preserves exact history including the merge itself.
  * **Cons:** Creates "merge commits" on your feature branch, making its history non-linear ("bubbly"). Can clutter history if done frequently.

* **Option B: Rebasing your Feature Branch onto `master` (Recommended for this Workflow)**

    ```bash
    git checkout feature/my-feature
    git fetch origin
    git rebase origin/master # Re-applies your feature commits ON TOP of latest master
    # Resolve any conflicts interactively as they arise (see 7.2)
    ```

  * **Pros:** Creates a clean, linear history for your feature branch as if you started it from the latest `master`. Avoids merge commits. Makes the final Squash & Merge cleaner.
  * **Cons:** Rewrites your feature branch's commit history (hashes change). Requires resolving conflicts commit-by-commit if they occur during the rebase.
  * **Critical Rule:** **NEVER rebase a branch that has been pushed and potentially pulled/used by others.** Rebasing rewrites history, which causes major problems for collaborators. *Since you are solo, rebasing your own pushed feature branch before PR/merge is generally safe and recommended for cleanliness.*

* **Recommendation:** Prefer **rebasing** your feature branch onto `master` periodically during development and especially before creating/merging your PR. This keeps your branch history linear and easy to follow.

### 7.2 Handling Merge/Rebase Conflicts

Conflicts occur when Git cannot automatically merge changes because both branches modified the same lines.

1. **Identify:** Git will stop the merge/rebase and tell you which files have conflicts. The files will contain markers like:

    ```
    <<<<<<< HEAD (Current Change)
    // Code from your current branch
    =======
    // Code from the branch being merged/rebased onto
    >>>>>>> <commit-hash or branch-name> (Incoming Change)
    ```

2. **Resolve:** Open the conflicted file(s) in your editor.
    * Edit the code to incorporate *both* sets of changes correctly.
    * **Remove** the conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).
    * Ensure the resulting code is correct and complete.
3. **Stage:** Mark the conflict as resolved by staging the file(s).

    ```bash
    git add <resolved-file-name>
    ```

4. **Continue:**
    * If merging: `git commit` (Git usually provides a default merge commit message).
    * If rebasing: `git rebase --continue`. Repeat steps 1-4 if more conflicts occur during the rebase. Use `git rebase --skip` to ignore a problematic commit (rarely needed) or `git rebase --abort` to cancel the entire rebase.

### 7.3 Cleaning Up Local History (`git rebase -i`)

Interactive rebase allows you to rewrite your *local*, unshared commit history on a feature branch before creating a PR. This is great for making your work presentable.

```bash
# Example: Clean up commits on your branch relative to master
git checkout feature/my-feature
git rebase -i master
```

* This opens an editor listing your feature branch commits. You can:
  * `squash` / `fixup`: Combine small commits into larger logical ones.
  * `reword`: Change commit messages.
  * `edit`: Stop to amend a commit's content.
  * `reorder`: Change the order of commits.
  * `drop`: Delete commits entirely.
* **Use Case:** Combine "WIP" or "fix typo" commits into the main commit they relate to, resulting in a cleaner set of logical steps in your PR.
* **Warning:** Use only on branches you haven't shared or where you are coordinating carefully. It rewrites history.

### 7.4 Temporarily Saving Changes (`git stash`)

Need to quickly switch branches but have uncommitted work? Use `git stash`.

* **Save Changes:** Saves your modified tracked files (staged and unstaged) and untracked files (with `-u`) away, leaving your working directory clean.

    ```bash
    git stash push -m "Working on login form validation" # Good practice to add message
    # Or include untracked files: git stash push -u -m "..."
    ```

* **View Stashes:** See saved stashes.

    ```bash
    git stash list
    ```

* **Re-apply Changes:** Apply the most recent stash and remove it from the list (`pop`), or apply it and keep it (`apply`).

    ```bash
    git stash pop # Usually what you want
    # Or apply a specific stash: git stash apply stash@{1}
    ```

* **Remove Stash:** Discard a stash if no longer needed.

    ```bash
    git stash drop stash@{0}
    ```

### 7.5 Undoing Mistakes

* **Fix Last Commit (Local Only):** If you just committed but forgot a change or made a typo in the message:

    ```bash
    git add <forgotten-file> # Stage any missed changes
    git commit --amend # Opens editor to fix message; adds staged changes
    ```

  * **Warning:** Don't amend commits that have already been pushed!

* **Uncommit Local Changes (Keep Work):** Remove the last commit but keep the changes in your working directory.

    ```bash
    git reset HEAD~1 # Soft reset by default
    ```

* **Discard Local Commit & Changes (Use Caution!):** Remove the last commit *and* discard its changes entirely.

    ```bash
    git reset --hard HEAD~1
    ```

  * **Warning:** `--hard` permanently deletes uncommitted work. Be sure!

* **Revert a Pushed/Merged Commit:** If a bad commit made it to `master` (or a shared branch), don't `reset`. Instead, create a *new* commit that undoes the changes:

    ```bash
    # Find the hash of the bad commit (e.g., via git log)
    git revert <commit-hash-of-bad-commit>
    ```

  * This creates a new "Revert..." commit, preserving history but negating the bad change. It's the safe way to undo shared history.

## 8. Why This Rigor Matters (Even Solo)

* **Saves Future Debugging Time:** Clear history (`git log`, `git bisect`) is invaluable when tracking down bugs introduced weeks or months ago.
* **Reduces Costly Mistakes:** The PR review/checklist step catches errors *before* they destabilize `master`. Rebasing helps integrate changes smoothly.
* **Builds Professional Habits:** This mirrors standard team practices, making future collaboration seamless.
* **Enables Advanced Tooling:** Conventional Commits and clean history power tools for changelog generation, automated releases, etc.
* **Reduces Mental Load:** A defined process frees you from constantly deciding *how* to manage changes, letting you focus on *what* changes to make.

## 9. Summary: Key Workflow Rules

* **`master` is always stable.** Branch from the latest `master`.
* **Develop on dedicated feature branches** (`feature/`, `fix/`, etc.).
* **Commit atomically** using **Conventional Commits** format.
* **Keep feature branches updated** using `git rebase origin/master` (preferred) or `git merge origin/master`. Resolve conflicts promptly.
* **(Optional)** Clean up local history with `git rebase -i` *before* creating a PR.
* **Integrate via Pull Requests,** performing a thorough self-review.
* **Use Squash and Merge** for a clean `master` history, writing a good squash commit message.
* **Avoid direct pushes** to `master` except for truly trivial, risk-free changes after local checks.
* Use `git stash` for temporary changes, `git revert` to undo shared commits.

---

By internalizing and consistently applying this workflow, you build a robust foundation for Momentum's development, ensuring quality and maintainability for the long term.

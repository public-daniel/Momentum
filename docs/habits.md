# Momentum: Habit Tracking Feature Guide

This guide details the Habit Tracking feature within the Momentum application. It's designed as personal documentation outlining the *why*, *what*, and *how* of this feature, aligning with Momentum's core philosophy of the "Snowball Effect" – building significant progress through small, consistent actions tracked over time.

## 1. Motivation & Principles (Why Track Habits?)

Integrating habit tracking is fundamental to building momentum towards larger goals. It serves several key purposes:

* **Builds Consistency:** Reinforces desired daily, weekly, or monthly actions.
* **Increases Awareness:** Provides objective data on your actual behavior patterns.
* **Sustains Motivation:** Visual progress, especially streaks, offers powerful positive feedback.
* **Enhances Accountability:** Creates a clear record of whether you followed through on your intentions.
* **Facilitates Reflection:** Decoupled notes allow capturing insights both on specific days and general thoughts about the habit journey.

**Core Principles for Effective Tracking:**

* **Start Small:** Focus on 1-3 key habits initially.
* **Be Specific & Measurable:** Define habits clearly (e.g., "Run 3km" vs. "Exercise more").
* **Be Consistent:** Adhere to the schedule you set for each habit.
* **Track Honestly:** Log completions (`✓`), failures (`X`), and legitimate skips (`➖ / Ø`).
* **Use 'Skip' Intentionally:** Reserve `Skipped` for planned reasons (rest days, travel, illness) to maintain streak integrity without compromising honesty. `Failed (X)` resets streaks.
* **Leverage Notes:** Add context to specific daily logs *or* record general observations about the habit over time.
* **Review & Adapt:** Use the insights gained from tracking and notes to refine your habits or approach. Progress over perfection.

## 2. UI/UX (Habit Tracking Interfaces)

Momentum provides four distinct interfaces tailored for different aspects of habit tracking:

### a. Grid View (Daily Log Sheet)

* **Purpose:** High-level, "spreadsheet-like" overview for **rapid daily status updates** and viewing recent performance across multiple habits. Inspired by your mockup (`image_a2769f.png`).
* **Layout:** Habits listed as rows, potentially **grouped visually by Categories**. Columns show `Habit Name`, status indicators (✓, X, ➖) for recent days (including today), and current `Streak`. May include a subtle indicator if notes exist for a specific day's log entry.
* **Interaction:** Designed for speed via **click-to-cycle status updates** directly on the grid cells (HTMX). Potential for keyboard navigation.

### b. Daily Detail Form

* **Purpose:** Focused view for check-in, review, and note-taking for **a single specific day**. Can also serve as the primary mobile interface.
* **Layout:** A clean list of habits scheduled for the selected date, potentially grouped by Category.
* **Interaction:** Provides explicit `[Completed]`, `[Failed]`, `[Skip]` buttons per habit. Includes a dedicated text area per habit to add/edit a **Markdown note specifically linked to that day's log entry**.

### c. Habit Detail View

* **Purpose:** The central "profile" or dashboard for a **single specific habit**. Used to view configuration, key metrics, *all associated notes*, history, and manage the habit itself.
* **Content:** Displays habit definition (`Name`, `Description`, `Category`, `Habit Type`, `Schedule`, `Start Date`). Provides `[Edit Habit]` / `[Delete Habit]` actions. Shows key stats (Current/Longest Streak, Completion %). Features a chronological feed displaying **both general habit notes and notes linked to specific log entries**. Includes an interface to add **new general notes** about the habit (not tied to a specific date log). Links to the full Statistics View filtered for this habit.

### d. Statistics View

* **Purpose:** Dedicated interface for **long-term analysis**, identifying trends, and visualizing overall progress for specific habits or categories.
* **Content:** Features an interactive **Calendar Heatmap**. Includes various **Charts** (via Chart.js) like completion rate trends, streak lengths etc. Provides numerical summaries and aggregated statistics.
* **Interaction:** Allows selecting habits or categories for analysis, potentially filtering by custom date ranges.

## 3. How to Use Habit Tracking

1. **Define Your Habits:**
    * Use the "Add Habit" function.
    * Provide `Name`, `Description`. Set `Habit Type` (`Build`/`Break`). Assign a `Category`. Define the `Schedule` (`Daily`, `Weekly`, `Monthly`) and `Start Date`.

2. **Perform Daily Check-in:** Choose the method that suits you best:
    * **Method A (Quick Update):** Use the **Grid View**. Click the status cell corresponding to today for each habit to rapidly cycle through `Pending` -> `Completed` -> `Failed` -> `Skipped`.
    * **Method B (Detailed Entry/Notes):** Go to the **Daily Detail Form**. Use the explicit `[Completed]`/`[Failed]`/`[Skip]` buttons. Add context or reflections using the **Markdown `Notes` field specific to that day's outcome**.

3. **Add General Notes:**
    * Navigate to the **Habit Detail View** for the relevant habit.
    * Use the dedicated input area to add general thoughts, reflections, or observations about the habit that aren't tied to a single day's log entry.

4. **Review Your Progress:**
    * **Grid View:** Daily check on recent performance & streaks.
    * **Habit Detail View:** Deep dive into one habit – review its definition, stats, and crucially, read through the **chronological feed of all general and day-specific notes** to understand the journey.
    * **Statistics View:** Analyze long-term trends, consistency (heatmap), and overall rates periodically.

5. **Maintain & Adapt:**
    * Edit/Delete habits via the **Habit Detail View**.
    * Use insights from stats *and* notes (both types) to refine your approach.

---

## Appendix

### A. Implementation Plan / Development Strategy

This section outlines a phased approach to building the Habit Tracking feature, focusing on iterative development, adherence to the established Git workflow, continuous testing, and user feedback (dogfooding).

#### Summary of Expected Commits

(*This list represents the atomic commits within each feature branch. Each phase concludes with a Squash & Merge commit summarizing the overall feature delivered in that phase.*)

**Phase 1: Core Data Model & Basic Habit CRUD (`feature/habits-crud`)**

* `docs(habits): add documentation for habit tracking`
* `feat(db): add initial habit tracking tables (calendar, categories, habits)`
* `chore(db): add script/logic to populate calendar table`
* `feat(habits): implement basic category management (list, add)`
* `feat(habits): implement habit CRUD operations (list, add, show, edit, delete)`
* `test(habits): add integration tests for habit and category CRUD`
* Squash Merge Commit: `feat: implement core habit CRUD (#<PR_Number>)` *(Message refined)*

**Phase 2: Core Tracking Loop (Daily Form) (`feature/habits-daily-log`)**

* `feat(db): add habit_log table for daily tracking`
* `feat(habits): implement basic habit scheduling logic`
* `feat(habits): implement backend for daily log view and status updates`
* `feat(habits): implement daily log form UI with HTMX updates`
* `test(habits): add tests for scheduling logic and daily logging`
* Squash Merge Commit: `feat: implement daily habit logging form (#<PR_Number>)` *(Message refined)*

**Phase 3: Basic Display & Streaks (`feature/habits-streaks`)**

* `feat(habits): display today's status on habit lists`
* `feat(habits): implement current streak calculation for daily habits`
* `feat(habits): display current streak in UI`
* *(Optional): `feat(habits): extend streak calculation to weekly/monthly schedules`*
* `test(habits): add unit tests for streak calculation`
* Squash Merge Commit: `feat: display habit status and calculate streaks (#<PR_Number>)` *(Message refined)*

**Phase 4: Grid View Implementation (`feature/habits-grid-view`)**

* `feat(habits): implement backend logic for grid view data and cycle status endpoint`
* `feat(habits): implement grid view UI with HTMX click-to-cycle updates`
* `test(habits): add integration tests for grid view`
* Squash Merge Commit: `feat: implement habit tracking grid view (#<PR_Number>)` *(Message refined)*

**Phase 5: Notes Implementation (`feature/habits-notes`)**

* `feat(db): add habit_notes table`
* `feat(ui): add markdown rendering support for notes`
* `feat(habits): allow adding/editing notes on daily log entries`
* `feat(habits): implement habit detail view with general notes and notes feed`
* `test(habits): add tests for habit notes functionality`
* Squash Merge Commit: `feat: implement habit notes (daily and general) (#<PR_Number>)` *(Message refined)*

**Phase 6: Statistics & Visualization (`feature/habits-stats`)**

* `feat(habits): implement calendar heatmap visualization`
* `feat(habits): add basic trend charts (e.g., completion rate)`
* `feat(habits): add filtering options to statistics view`
* `test(habits): add tests for statistics data endpoints`
* Squash Merge Commit: `feat: implement statistics view with heatmap and charts (#<PR_Number>)` *(Message refined)*

**Phase 7: Refinement & Polish (`chore/habits-polish` or `feature/*`)**

* *(Commits will vary: e.g., `fix(habits): correct streak calculation edge case`, `refactor(ui): improve grid view responsiveness`, `perf(db): add index to habit_log query`, `style(habits): align habit detail layout`)*
* Squash Merge Commit: `chore: refine and polish habit tracking feature (#<PR_Number>)` *(Message refined)*

---

#### Phased Development Strategy Details

**Preparation:**

1. **Sync `master`:** `git checkout master && git pull origin master`
2. **Review:** Ensure comfort with the data model, UI concepts, and overall goals.

---

**Phase 1: Core Data Model & Basic Habit CRUD**

* **Goal:** Establish database structure and enable basic creation, reading, updating, and deletion of habits and categories, without tracking functionality.
* **Git:**
  * Create branch: `git checkout -b feature/habits-crud`
* **Tasks:**
    1. **Migrations:** Create SQLx migration files (`migrations/*.sql`) for `calendar`, `habit_categories`, `habits`. Run `sqlx migrate run` locally.
        * *Commit: `feat(db): add initial habit tracking tables (calendar, categories, habits)`*
    2. **Populate Calendar:** Create utility to populate `calendar` table.
        * *Commit: `chore(db): add script/logic to populate calendar table`*
    3. **Models:** Define Rust structs (`Habit`, `HabitCategory`) in `src/db/models.rs`.
    4. **Category CRUD:** Implement DB queries, Actix handlers, and Maud templates for List & Add category.
        * *Commit: `feat(habits): implement basic category management (list, add)`*
    5. **Habit CRUD:** Implement DB queries, Actix handlers, and Maud templates for List, GetByID, Add, Update, Delete habits. Include category selection in forms. Wire up basic navigation.
        * *Commit: `feat(habits): implement habit CRUD operations (list, add, show, edit, delete)`*
    6. **Testing:** Add basic integration tests for CRUD handlers.
        * *Commit: `test(habits): add integration tests for habit and category CRUD`*
* **Git Workflow:**
  * Push branch: `git push -u origin feature/habits-crud`
  * Create PR targeting `master`. Title: `feat: implement core habit CRUD`.
  * Perform Self-Review checklist.
  * Squash and Merge. Refine commit message to `feat: implement core habit CRUD (#<PR_Number>)`.
  * Delete branch.

---

**Phase 2: Core Tracking Loop (Daily Form)**

* **Goal:** Implement the `habit_log` table and the Daily Detail Form to allow logging status (`Completed`, `Failed`, `Skipped`) for a specific day.
* **Git:**
  * Sync `master`.
  * Create branch: `git checkout -b feature/habits-daily-log`
* **Tasks:**
    1. **Migrations:** Create migration for `habit_log` table. Run `sqlx migrate run`.
        * *Commit: `feat(db): add habit_log table for daily tracking`*
    2. **Model:** Define `HabitLog` struct.
    3. **Scheduling Logic:** Implement core logic to check if a habit is scheduled for a date.
        * *Commit: `feat(habits): implement basic habit scheduling logic`*
    4. **Daily Detail Form - Backend:** Implement DB query to fetch scheduled habits + status. Implement GET `/log/{date}` handler. Implement POST `/log/{habit_id}/{date}` handler for status updates (using `ON CONFLICT` or check).
        * *Commit: `feat(habits): implement backend for daily log view and status updates`*
    5. **Daily Detail Form - Frontend:** Create Maud template for `/log/{date}`. Render list with `[Complete]`/`[Fail]`/`[Skip]` buttons/links. Use HTMX for button POSTs, targeting/swapping the habit row fragment on response.
        * *Commit: `feat(habits): implement daily log form UI with HTMX updates`*
    6. **Testing:** Add tests for scheduling logic and daily log handlers.
        * *Commit: `test(habits): add tests for scheduling logic and daily logging`*
* **Git Workflow:**
  * Push, PR (`feat: implement daily habit logging form`), Review, Squash & Merge (`feat: implement daily habit logging form (#<PR_Number>)`), Delete branch.

---

**Phase 3: Basic Display & Streaks**

* **Goal:** Show current status on habit lists and calculate/display the current streak for *daily* habits initially.
* **Git:**
  * Sync `master`.
  * Create branch: `git checkout -b feature/habits-streaks`
* **Tasks:**
    1. **Display Today's Status:** Modify habit list views to show status for the current date.
        * *Commit: `feat(habits): display today's status on habit lists`*
    2. **Streak Calculation (Daily Habits First):** Implement logic (SQL or Rust) for *current* streak calculation for daily habits. Handle completed/skipped/failed correctly.
        * *Commit: `feat(habits): implement current streak calculation for daily habits`*
    3. **Display Streak:** Display the `current_streak` in relevant UI views.
        * *Commit: `feat(habits): display current streak in UI`*
    4. **(Optional Deferral):** Tackle weekly/monthly streaks now or defer.
        * *(If tackled) Commit: `feat(habits): extend streak calculation to weekly/monthly schedules`*
    5. **Testing:** Add robust unit tests for streak logic.
        * *Commit: `test(habits): add unit tests for streak calculation`*
* **Git Workflow:**
  * Push, PR (`feat: display habit status and calculate streaks`), Review, Squash & Merge (`feat: display habit status and calculate streaks (#<PR_Number>)`), Delete branch.

---

**Phase 4: Grid View Implementation**

* **Goal:** Build the spreadsheet-like Grid View for rapid daily updates.
* **Git:**
  * Sync `master`.
  * Create branch: `git checkout -b feature/habits-grid-view`
* **Tasks:**
    1. **Grid View - Backend:** Implement optimized DB query for recent days/habits. Implement GET `/grid` handler. Implement POST `/log/{habit_id}/{date}/cycle` handler returning updated `<td>` fragment.
        * *Commit: `feat(habits): implement backend logic for grid view data and cycle status endpoint`*
    2. **Grid View - Frontend:** Create Maud template for grid table. Add HTMX attributes to cells (`hx-post`, `hx-target="this"`, `hx-swap="outerHTML"`).
        * *Commit: `feat(habits): implement grid view UI with HTMX click-to-cycle updates`*
    3. **Testing:** Add integration tests for grid view handlers.
        * *Commit: `test(habits): add integration tests for grid view`*
* **Git Workflow:**
  * Push, PR (`feat: implement habit tracking grid view`), Review, Squash & Merge (`feat: implement habit tracking grid view (#<PR_Number>)`), Delete branch.

---

**Phase 5: Notes Implementation (Decoupled)**

* **Goal:** Allow users to add Markdown notes associated with specific log entries or the habit generally.
* **Git:**
  * Sync `master`.
  * Create branch: `git checkout -b feature/habits-notes`
* **Tasks:**
    1. **Migrations:** Create migration for `habit_notes` table. Run `sqlx migrate run`.
        * *Commit: `feat(db): add habit_notes table`*
    2. **Model:** Define `HabitNote` struct.
    3. **Markdown Rendering:** Integrate `pulldown-cmark` into a utility.
        * *Commit: `feat(ui): add markdown rendering support for notes`*
    4. **Daily Detail Notes:** Update Daily Detail Form handler/template for notes textarea. Implement save logic (linking `habit_log_id`). Use HTMX for saving.
        * *Commit: `feat(habits): allow adding/editing notes on daily log entries`*
    5. **Habit Detail View:** Implement GET `/habit/{id}` handler fetching habit + all notes. Create Maud template displaying info, stats, notes feed. Add form/handler for *general* notes (POST creates note with `habit_log_id = NULL`). Use HTMX for dynamic updates. Add Edit/Delete links.
        * *Commit: `feat(habits): implement habit detail view with general notes and notes feed`*
    6. **Testing:** Add tests for notes CRUD and display logic.
        * *Commit: `test(habits): add tests for habit notes functionality`*
* **Git Workflow:**
  * Push, PR (`feat: implement habit notes (daily and general)`), Review, Squash & Merge (`feat: implement habit notes (daily and general) (#<PR_Number>)`), Delete branch.

---

**Phase 6: Statistics & Visualization**

* **Goal:** Provide the Statistics View with heatmap and basic trend charts.
* **Git:**
  * Sync `master`.
  * Create branch: `git checkout -b feature/habits-stats`
* **Tasks:**
    1. **Heatmap:** Implement DB query for status/day. Implement `/stats/heatmap/{id}` handler. Create Maud template + logic to render heatmap.
        * *Commit: `feat(habits): implement calendar heatmap visualization`*
    2. **Trend Charts:** Implement DB queries for aggregated data. Implement handlers returning JSON for Chart.js. Include Chart.js lib. Add JS to stats template to initialize charts from fetched/embedded data.
        * *Commit: `feat(habits): add basic trend charts (e.g., completion rate)`*
    3. **Filtering:** Add UI controls (dropdowns, date pickers) to Stats View. Use HTMX (`hx-get`, `hx-target`) to reload heatmap/charts dynamically.
        * *Commit: `feat(habits): add filtering options to statistics view`*
    4. **Testing:** Add tests for stats data calculation/handlers. Perform manual visualization testing.
        * *Commit: `test(habits): add tests for statistics data endpoints`*
* **Git Workflow:**
  * Push, PR (`feat: implement statistics view with heatmap and charts`), Review, Squash & Merge (`feat: implement statistics view with heatmap and charts (#<PR_Number>)`), Delete branch.

---

**Phase 7: Refinement & Polish**

* **Goal:** Improve usability, fix bugs, optimize performance, enhance styling, add deferred features.
* **Git:**
  * Sync `master`.
  * Create branch: `git checkout -b chore/habits-polish` (or `feature/*` for larger items)
* **Tasks:** (Address issues from dogfooding/development)
    1. **Complex Streaks (if deferred):** Implement/test weekly/monthly streak logic.
    2. **UI/UX:** Refine layouts, responsiveness, styling (Water.css).
    3. **Performance:** Analyze queries (`EXPLAIN QUERY PLAN`), add indexes, optimize backend.
    4. **Error Handling:** Improve user feedback on errors (backend/frontend).
    5. **Accessibility:** Basic review.
    6. **Code Quality:** Refactor, improve comments, ensure linters pass.
    7. **Comprehensive Testing:** Add missing test cases.
  * *(Use varied commits: `fix:`, `refactor:`, `style:`, `perf:`, `feat:`, `test:`)*
* **Git Workflow:**
  * Push, PR (`chore: refine and polish habit tracking feature`), Review, Squash & Merge (`chore: refine and polish habit tracking feature (#<PR_Number>)`), Delete branch.

---

### B. Data Model (SQLite)

```sql
-- Pre-generated Calendar Table (Populate once with dates spanning needed range, e.g., 2020-2050)
CREATE TABLE calendar (
    dt TEXT PRIMARY KEY, -- 'YYYY-MM-DD'
    iso_year INTEGER NOT NULL,
    iso_week INTEGER NOT NULL,
    month INTEGER NOT NULL,
    day INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL, -- ISO 8601: 1=Monday, 7=Sunday
    day_of_year INTEGER NOT NULL,
    is_weekday BOOLEAN NOT NULL -- True for Mon-Fri
    -- Add other potentially useful date components
);

-- Stores user-defined categories for grouping habits
CREATE TABLE habit_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Stores the definition of each habit
CREATE TABLE habits (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    habit_type TEXT NOT NULL CHECK(habit_type IN ('build', 'break')),
    category_id INTEGER REFERENCES habit_categories(id) ON DELETE SET NULL,
    schedule_type TEXT NOT NULL CHECK(schedule_type IN ('daily', 'weekly', 'monthly')),
    schedule_details TEXT, -- e.g., JSON `[1,3,5]` for specific days (matching ISO day_of_week)
    start_date TEXT NOT NULL, -- 'YYYY-MM-DD'
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Stores the daily status log for each habit instance
CREATE TABLE habit_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    habit_id INTEGER NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    date TEXT NOT NULL, -- 'YYYY-MM-DD' (Should match calendar.dt)
    status TEXT NOT NULL CHECK(status IN ('completed', 'failed', 'skipped')),
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (habit_id, date)
);

-- Stores notes, associable with a specific log entry OR the habit generally
CREATE TABLE habit_notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    habit_id INTEGER NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
    habit_log_id INTEGER NULL REFERENCES habit_log(id) ON DELETE SET NULL, -- Optional link
    note_content TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Example Indexes
CREATE INDEX idx_habit_log_habit_date ON habit_log (habit_id, date);
CREATE INDEX idx_habit_notes_habit_log ON habit_notes (habit_log_id);
CREATE INDEX idx_habit_notes_habit_created ON habit_notes (habit_id, created_at);
CREATE INDEX idx_habits_category ON habits (category_id);
```

### C. Useful SQL Queries (Detailed Examples)

*(Using `?` placeholders. Backend logic is crucial for constructing schedule-checking clauses.)*

1. **Fetch Data for Grid/Daily View (for Date `?1`)**:

    ```sql
    -- Placeholder for Date: ?1 ('YYYY-MM-DD')
    SELECT
        h.id AS habit_id, h.name AS habit_name, h.habit_type,
        hc.id AS category_id, hc.name AS category_name,
        hl.id AS log_id, hl.status,
        (SELECT 1 FROM habit_notes hn WHERE hn.habit_log_id = hl.id LIMIT 1) AS has_note
    FROM habits h
    LEFT JOIN habit_categories hc ON h.category_id = hc.id
    LEFT JOIN habit_log hl ON h.id = hl.habit_id AND hl.date = ?1
    JOIN calendar cal ON cal.dt = ?1 -- Use calendar for date components if needed
    WHERE h.start_date <= ?1
      -- AND (Backend Logic Needed: Check if habit 'h' is scheduled on date '?1' using h.schedule_*, cal.*)
    ORDER BY hc.name NULLS LAST, h.name;
    ```

2. **Get Note for a Specific Log Entry (Log ID `?1`)**:

    ```sql
    SELECT note_content FROM habit_notes WHERE habit_log_id = ?1;
    ```

3. **Get All Notes for a Habit (Habit ID `?1`)**:

    ```sql
    SELECT
        n.id AS note_id, n.habit_log_id, l.date AS log_date,
        n.note_content, n.created_at
    FROM habit_notes n
    LEFT JOIN habit_log l ON n.habit_log_id = l.id
    WHERE n.habit_id = ?1
    ORDER BY n.created_at DESC;
    ```

4. **Insert/Update Day-Specific Note (Log ID `?1`, Habit ID `?2`, Content `?3`)**:

    ```sql
    INSERT INTO habit_notes (habit_log_id, habit_id, note_content, created_at, updated_at)
    VALUES (?1, ?2, ?3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    ON CONFLICT(habit_log_id) WHERE habit_log_id IS NOT NULL
    DO UPDATE SET note_content = excluded.note_content, updated_at = CURRENT_TIMESTAMP;
    ```

5. **Insert General Habit Note (Habit ID `?1`, Content `?2`)**:

    ```sql
    INSERT INTO habit_notes (habit_id, note_content, created_at, updated_at)
    VALUES (?1, ?2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    ```

6. **Calculate Current Streak (Conceptual - Complex Query Structure)**:

    ```sql
    -- Placeholders: Habit ID ?1, Current Date ?2 ('YYYY-MM-DD')
    WITH ScheduledDates AS (
        SELECT c.dt FROM calendar c JOIN habits h ON h.id = ?1
        WHERE c.dt BETWEEN h.start_date AND ?2
          -- AND (Backend Logic Needed: Check schedule match using c.*, h.schedule_*)
    ), LogsWithStatus AS (
        SELECT sd.dt, COALESCE(hl.status, 'missed') AS effective_status
        FROM ScheduledDates sd LEFT JOIN habit_log hl ON sd.dt = hl.date AND hl.habit_id = ?1
    ), Groups AS (
        SELECT dt, effective_status,
               SUM(CASE WHEN effective_status IN ('failed', 'missed') THEN 1 ELSE 0 END) OVER (ORDER BY dt) as break_group
        FROM LogsWithStatus
    ), StreaksCalculation AS (
      SELECT dt, break_group, effective_status,
             SUM(CASE WHEN effective_status = 'completed' THEN 1 ELSE 0 END) OVER (PARTITION BY break_group ORDER BY dt) as streak_len
      FROM Groups WHERE effective_status IN ('completed', 'skipped')
    )
    SELECT COALESCE(MAX(streak_len), 0) AS current_streak
    FROM StreaksCalculation
    WHERE dt = ?2 AND break_group = (SELECT MAX(g.break_group) FROM Groups g WHERE g.dt = ?2);
    ```

    *(Warning: Streak SQL is complex. Consider backend logic alternative/supplement.)*

7. **Data for Calendar Heatmap (Habit ID `?1`, Start `?2`, End `?3`)**:

    ```sql
    SELECT c.dt, hl.status
    FROM calendar c
    LEFT JOIN habit_log hl ON c.dt = hl.date AND hl.habit_id = ?1
    WHERE c.dt BETWEEN ?2 AND ?3
    ORDER BY c.dt;
    -- Backend needs to overlay schedule information if necessary.
    ```

### D. HTMX Patterns

* **Grid Cell Click-to-Cycle:** POST `/log/{habit_id}/{date}/cycle_status`, target cell, swap `outerHTML`.
* **Daily Form Status Buttons:** POST status to `/log/{habit_id}/{date}`, target habit row, swap `outerHTML`.
* **Notes (Daily & General):** Use GET/POST pattern for editing/saving notes via `/notes/...` endpoints, updating specific display areas. Ensure `habit_log_id` is passed/saved correctly for day-specific notes.
* **Dynamic Content Loading:** `hx-get` for stats, details, date navigation.

### E. Other Considerations

* **Markdown Rendering:** Use `pulldown-cmark` server-side for `habit_notes.note_content`.
* **Date/Time Handling:** Use `chrono` for robust date logic, schedule checking against `calendar`. Store dates 'YYYY-MM-DD'.
* **Scheduling Logic:** Implement reusable Rust functions to check if a habit `h` is scheduled on date `d` using `h.schedule_*` and potentially `calendar` data. This logic is critical for multiple queries.
* **Error Handling:** Use `thiserror`/`anyhow` + Actix error handling.

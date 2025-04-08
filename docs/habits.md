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

This plan outlines a phased approach to building the Habit Tracking feature, focusing on iterative development.

**Phase 1: Core Data Model & Basic Habit CRUD**

* **Goal:** Establish the database structure and basic habit management.
* **Steps:**
    1. Define/create `calendar`, `habit_categories`, `habits` tables (SQLx migrations).
    2. Populate `calendar` table with a sufficient date range.
    3. Create Rust structs for `Habit` and `HabitCategory` (`sqlx::FromRow`).
    4. Implement basic category management (Add/List/maybe Edit).
    5. Implement Actix handlers & Maud templates for:
        * Listing all habits (simple table).
        * Displaying "Add Habit" form (including category selection).
        * POST handler to create `habits` record.
        * Displaying "Edit Habit" form (pre-filled).
        * POST/PUT handler to update `habits` record.
        * POST/DELETE handler to delete `habits` record.
  * **Focus:** Get the basic data structure and non-tracking habit management working.

**Phase 2: Core Tracking Loop (Daily Form)**

* **Goal:** Implement the simplest way to log habit status for a specific day.
* **Steps:**
    1. Define/create `habit_log` table (SQLx migration).
    2. Create Rust struct for `HabitLog`.
    3. Implement the **Daily Detail Form** view:
        * Actix handler GET `/log/{date}`: Fetch scheduled habits for `{date}` (using schedule logic).
        * Maud template to render the list with `[Complete]`/`[Fail]`/`[Skip]` buttons/forms per habit.
        * Actix handler POST `/log/{habit_id}/{date}`: Receives `status`, performs INSERT/UPDATE on `habit_log`.
    4. Integrate HTMX for button clicks (posting status, updating the specific habit row/section via `hx-target`).
  * **Focus:** Make it possible to log today's status for scheduled habits.

**Phase 3: Basic Display & Streaks**

* **Goal:** Show current status and streaks visually.
* **Steps:**
    1. Enhance habit lists/views to display the status for "today" (fetched from `habit_log`).
    2. Implement **Current Streak calculation**. This is complex; use the detailed SQL structure (leveraging `calendar` table and window functions) or implement robust logic in Rust fetching necessary data. Start with daily habits, then add weekly/monthly schedule complexity.
    3. Display the calculated `current_streak` next to habits in relevant views.

**Phase 4: Grid View Implementation**

* **Goal:** Build the efficient, multi-day overview grid.
* **Steps:**
    1. Develop the **Grid View** UI (Maud template) based on the mockup.
    2. Implement Actix handler GET `/grid` (or similar): Fetches data for habits scheduled over the last ~7 days (joining `habits`, `habit_categories`, `habit_log`). Requires careful date range handling and schedule checking.
    3. Implement the **click-to-cycle** status update:
        * Dedicated Actix handler POST `/log/{habit_id}/{date}/cycle`: Calculates next status, updates DB (`habit_log`), returns the updated `<td>` HTML fragment.
        * Add `hx-post`, `hx-target="this"`, `hx-swap="outerHTML"` attributes to the grid cells in the template.

**Phase 5: Notes Implementation (Decoupled)**

* **Goal:** Integrate the flexible notes system.
* **Steps:**
    1. Define/create `habit_notes` table (SQLx migration).
    2. Create Rust struct for `HabitNote`.
    3. Update **Daily Detail Form**:
        * Add textarea for notes.
        * Implement save mechanism (HTMX: GET edit form fragment, POST save). Handler creates/updates `habit_notes` record, ensuring `habit_log_id` is correctly linked.
    4. Implement **Habit Detail View**:
        * Actix handler GET `/habit/{habit_id}`: Fetches habit details, stats, and *all* notes (general + log-specific) ordered chronologically.
        * Maud template to display all fetched info, including the notes feed.
        * Add form/handler to create *general* notes (POST to `/notes` with `habit_id`, creates `habit_notes` with `habit_log_id = NULL`). Use HTMX to update the notes feed.
    5. Integrate `pulldown-cmark` for rendering Markdown notes to HTML.

**Phase 6: Statistics & Visualization**

* **Goal:** Provide long-term analysis tools.
* **Steps:**
    1. Design and implement the **Statistics View** UI (Maud template).
    2. Implement Actix handlers to fetch aggregated data:
        * `/stats/heatmap/{habit_id}?range=...`: Query `calendar` LEFT JOIN `habit_log` for status per day.
        * `/stats/trends/{habit_id}?period=...`: Query/aggregate data for completion rates, etc.
    3. Integrate **Chart.js**: Include library, pass data from handlers to the template (e.g., embed as JSON), use minimal JS to initialize charts.
    4. Add UI elements (dropdowns, date pickers) for selecting habits, categories, and date ranges, using HTMX to reload stats dynamically.

**Phase 7: Refinement & Polish**

* **Goal:** Improve usability, robustness, and performance.
* **Steps:**
    1. Refine UI styling (apply Water.css consistently, improve layout).
    2. Address responsiveness, especially for the Grid View on mobile.
    3. Implement keyboard navigation for the Grid View (JavaScript required).
    4. Enhance error handling (backend and frontend via HTMX error targets).
    5. Optimize complex SQL queries (analyze query plans, ensure proper indexing).
    6. Add automated tests (unit tests for logic, integration tests for handlers).
    7. Review and improve code quality.

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

# Qa Story Brief

## Tool

web (Vibium MCP browser tools — LiveView on local web, port 4003)

## Auth

No authentication required. Local web (port 4003) uses the `LocalOnly` plug — any loopback connection is accepted. Navigate directly to `http://127.0.0.1:4003/projects/code-my-spec/files`.

## Seeds

No seed script needed for the `code-my-spec` project — it already exists in the local DB and has ~5700 tracked files from prior syncs. If the files table is empty, trigger a sync via the Sync button on the page.

Verify the project is accessible:
```
curl -sSf http://127.0.0.1:4003/health
```

## What To Test

### Scenario 1: Full column population (criterion 5947)
- Navigate to `http://127.0.0.1:4003/projects/code-my-spec/files`
- Verify the page loads and shows file rows (`[data-test='file-row']`)
- Find a row for a spec file (e.g. a `.spec.md` file) and verify it contains:
  - `[data-test='file-role']` — role cell present and populated
  - `[data-test='file-validity']` — validity cell present (valid/invalid/unvalidated badge)
  - `[data-test='file-mtime']` — mtime cell present and populated
  - `[data-test='file-component-link']` — component link present for a file that has an owning component
- Capture screenshot: `687_criterion1_full_columns.png`

### Scenario 2: Invalid file filter (criterion 5948)
- Navigate to `http://127.0.0.1:4003/projects/code-my-spec/files`
- Look for any invalid file rows (`[data-test='file-validity'][data-validity='invalid']`)
- Click `[data-test='filter-invalid']` to apply the invalid-only filter
- Verify: invalid files remain visible after filtering
- Verify: valid files are removed from the view (URL should include `?filter=invalid`)
- If no invalid files exist, note this as a QA observation (the code-my-spec project may have all-valid files)
- Capture screenshot before and after filter: `687_criterion2_invalid_filter_before.png`, `687_criterion2_invalid_filter_after.png`

### Scenario 3: Pagination stability (criterion 5949)
- Navigate to `http://127.0.0.1:4003/projects/code-my-spec/files`
- Verify `[data-test='pagination']` controls appear (code-my-spec has ~5700 files, page size is 25)
- Count visible rows on page 1 — should be <= 25
- Navigate to page 2 via `[data-test='next-page']` or direct URL `?page=2`
- Verify page 2 shows different rows than page 1
- Reload page 2 and verify same rows appear in same order
- Capture screenshots: `687_criterion3_page1.png`, `687_criterion3_page2.png`

### Scenario 4: File to component to story traversal (criterion 5950)
- Navigate to `http://127.0.0.1:4003/projects/code-my-spec/files`
- Find a row with `[data-test='file-component-link']`
- Click the component link (or navigate to its href)
- Verify the component page loads at `/projects/code-my-spec/components/<id>`
- Verify the component's module name appears on the component page
- If any linked stories appear on the component page, verify story title is visible
- Capture screenshot: `687_criterion4_component_page.png`

### Scenario 5: Unowned file indicator (criterion 5951)
- Navigate to `http://127.0.0.1:4003/projects/code-my-spec/files`
- Find a row with `[data-test='file-unowned']` (project-level files like `mix.exs`, `CLAUDE.md`, `.credo.exs`)
- Verify the unowned indicator "(unowned)" is rendered
- Verify no `[data-test='file-component-link']` appears in that same row
- Capture screenshot: `687_criterion5_unowned_indicator.png`

### Scenario 6: Re-sync from files page (criterion 5952)
- Navigate to `http://127.0.0.1:4003/projects/code-my-spec/files`
- Verify `[data-test='sync-button']` is present and enabled
- Click the sync button
- Verify the button enters loading state (`Syncing...` text or spinner)
- After sync completes, verify a success alert appears (`role="alert" .alert-success`)
- Verify rows are still visible (no page reload needed)
- Capture screenshots: `687_criterion6_sync_before.png`, `687_criterion6_sync_after.png`

## Result Path

`.code_my_spec/qa/687/result.md`

## Setup Notes

The `code-my-spec` project is the canonical test target for this story — it has a large file count (~5700 files) which exercises pagination naturally. The local web at port 4003 has no auth; navigate directly.

Key selectors derived from the FilesLive template:
- File rows: `[data-test='file-row']` with `data-file-path` attribute
- Role cell: `[data-test='file-role']`
- Validity cell: `[data-test='file-validity']` with `data-validity` attribute (`valid`, `invalid`, `unvalidated`)
- mtime cell: `[data-test='file-mtime']`
- Component link: `[data-test='file-component-link']` (only when file has owning component)
- Unowned indicator: `[data-test='file-unowned']` (only when no owning component)
- Sync button: `[data-test='sync-button']`
- Filter buttons: `[data-test='filter-all']`, `[data-test='filter-invalid']`
- Pagination: `[data-test='pagination']`, `[data-test='next-page']`, `[data-test='prev-page']`

The sync button fires `phx-click="sync"`. The invalid filter navigates via LiveView patch (URL changes to `?filter=invalid`).

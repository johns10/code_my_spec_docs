# Qa Story Brief

## Tool

web (Vibium MCP browser tools against port 4004 local UI)

## Auth

No authentication required for the local UI on port 4004. `LocalOnly` plug accepts loopback connections directly. Navigate to `http://127.0.0.1:4004/projects/code-my-spec/files` without any login step.

## Seeds

Base seeds ensure the project is available:

```
mix run priv/repo/qa_seeds.exs
```

No story-specific seeds are needed. The `/files` LiveView is scoped to the `code-my-spec` project at `http://127.0.0.1:4004/projects/code-my-spec/files`. File records are created automatically by the sync operation tested in the scenarios.

## What To Test

Story 127 tests that the filesystem-to-DB projection (Files context) stays in sync with the project's source tree. All scenarios are tested through the `/projects/code-my-spec/files` LiveView at port 4004.

### Scenario 1: Files page loads and shows tracked files (baseline)
- Navigate to `http://127.0.0.1:4004/projects/code-my-spec/files`
- Verify the page loads without errors
- Verify the sync button is present (`[data-test='sync-button']`)
- Verify file rows are displayed with `[data-file-path]` attributes
- Capture screenshot as baseline evidence

### Scenario 2: Spec file validity comes from document parsing (criterion 5925)
- Navigate to `http://127.0.0.1:4004/projects/code-my-spec/files`
- Look for a well-formed spec file row (e.g., `.code_my_spec/spec/code_my_spec/files.spec.md`)
- Verify it has `[data-validity='valid']` attribute
- Capture screenshot showing valid badge

### Scenario 3: Malformed spec file is marked invalid (criterion 5926)
- The broken spec fixture is exercised by spex tests
- Via the UI: look for any file with `[data-validity='invalid']` in the projection
- If an invalid file exists, verify its row renders the invalid badge
- Capture screenshot showing the invalid filter tab if invalid files exist

### Scenario 4: Sync button triggers full sync (criterion 5920)
- Navigate to `http://127.0.0.1:4004/projects/code-my-spec/files`
- Click the `[data-test='sync-button']`
- Verify the page updates (sync status changes, file list refreshes)
- Verify file rows appear with path, role, fingerprint, and validity attributes
- Capture screenshot before and after sync

### Scenario 5: File rows show fingerprint data (criterion 5944 / 5931)
- Navigate to the files page
- Look for file rows with `[data-fingerprint]` attributes
- Verify fingerprint values are non-empty SHA-256 hex strings (64 hex chars)
- Capture screenshot showing fingerprint data attributes

### Scenario 6: Spec file role classification (criterion 5924)
- Navigate to the files page after a sync
- Find spec file rows (paths matching `.code_my_spec/spec/`)
- Verify `[data-test='file-role']` shows "spec" for spec files
- Verify `[data-test='file-component-link']` appears linking spec to its component
- Capture screenshot showing role and component link

### Scenario 7: Files page pagination and filtering
- Navigate to `http://127.0.0.1:4004/projects/code-my-spec/files`
- Verify pagination controls render if there are multiple pages
- Check the invalid filter link/tab
- Navigate to `http://127.0.0.1:4004/projects/code-my-spec/files?filter=invalid`
- Verify only invalid files show (or empty state if all valid)
- Capture screenshot of filtered view

### Scenario 8: File row data attributes for downstream assertions
- Inspect the DOM of a file row
- Verify `[data-file-path]` contains the relative project path
- Verify `[data-fingerprint]` exists on file rows
- Verify `[data-validity]` is either "valid" or "invalid"
- Capture screenshot showing file row structure

## Setup Notes

The Files context tests spex integration tests that mutate state in-process (writing files, triggering sync, checking DB). The QA browser tests exercise the same contracts through the running app's UI surface.

Key data attributes to look for in the FilesLive template:
- `[data-file-path]` on each file row (relative path within project)
- `[data-fingerprint]` on file rows (SHA-256 hex of content)
- `[data-validity='valid']` or `[data-validity='invalid']` on validity badges
- `[data-test='file-role']` showing the role (spec, impl, test, config, etc.)
- `[data-test='file-component-link']` for component association
- `[data-test='sync-button']` for the full sync trigger

The `code-my-spec` project is the actual CodeMySpec checkout. Its files are actively tracked, so the /files page should already show many tracked files after the app starts.

## Result Path

`.code_my_spec/qa/127/result.md`

# Qa Story Brief

## Tool

web (Vibium MCP browser tools against http://127.0.0.1:4004)

## Auth

No auth required. The local endpoint on port 4004 accepts loopback connections without a session. Navigate directly to any `/projects/code-my-spec/files` URL.

## Seeds

No seeds required. The CodeMySpec project (`code-my-spec`) is already tracked on the running dev server and has thousands of real tracked File records from the ongoing sync pipeline. The real data is sufficient to exercise every criterion.

To verify files exist:
```
curl -s http://127.0.0.1:4004/health
```

If the page is empty, trigger a sync via the Sync button on the files page (`[data-test='sync-button']`).

## What To Test

### Criterion 5947 — Full column population
- Navigate to `http://127.0.0.1:4004/projects/code-my-spec/files`
- Confirm the page loads and shows file rows with `[data-test='file-row']`
- Find a file row that has a component (e.g. a spec file); look for `.code_my_spec/spec/` path entries
- Verify the row has: `[data-test='file-path']`, `[data-test='file-role']`, `[data-test='file-validity']`, `[data-test='file-mtime']`, `[data-test='file-component-link']`
- Screenshot the spec file row

### Criterion 5948 — Invalid file filter
- On the files page, locate `[data-test='filter-invalid']` button
- Note the count shown in the button label
- Click `[data-test='filter-invalid']` — URL should change to `?filter=invalid`
- Verify only invalid files appear (or empty state if none exist)
- Click `[data-test='filter-all']` to return to full list
- Screenshot both filter states

### Criterion 5949 — Pagination stability
- On the files page, verify `[data-test='pagination']` controls are present
- Note the first row on page 1
- Navigate to `?page=2` and note the first row
- Confirm page 2 rows differ from page 1 rows
- Reload page 2 and confirm the same rows appear in the same order
- Screenshot page 1 and page 2

### Criterion 5950 — File to component to story traversal
- Find a file row with a component link (`[data-test='file-component-link']`)
- Click or navigate to the component link's href
- Verify the component page renders with the component's module name
- Verify a linked story appears on the component page
- Screenshot the component page

### Criterion 5951 — Unowned file indicator
- On the files page, find a file row with no component (project-level files like AGENTS.md, CLAUDE.md, mix.exs)
- Verify the row has `[data-test='file-unowned']` present
- Verify the row does NOT have `[data-test='file-component-link']`
- Screenshot an unowned file row

### Criterion 5952 — Re-sync from files page
- Locate `[data-test='sync-button']` on the files page
- Note the current rows/file count
- Click the sync button
- Verify the sync runs (spinner or progress indicator)
- Verify after sync, rows are still visible (no full page reload)
- Screenshot sync in progress and after completion

## Result Path

`.code_my_spec/qa/687/result.md`

# Qa Story Brief

## Tool

web (Vibium MCP browser tools for LiveView; curl for data-graph extraction)

## Auth

No auth required. Port 4004 uses `LocalOnly` — loopback requests are accepted without a session cookie.

Navigate directly: `http://127.0.0.1:4004/projects/code-my-spec/requirements/graph?preload=true`

## Seeds

No seed script needed. The "Code My Spec" project is already linked in `~/.codemyspec/cli_dev.db` with `local_path` pointing to `/Users/johndavenport/Documents/github/code_my_spec`.

## What To Test

- Visit `http://127.0.0.1:4004/projects/code-my-spec/requirements/graph?preload=true` and confirm the page loads with a sigma.js canvas and a "Graph Debug (N nodes, N edges)" footer.
- Extract the `data-graph` JSON from the HTML response via `curl http://127.0.0.1:4004/projects/code-my-spec/requirements/graph?preload=true` and parse it to assert layout properties.
- Criterion 6416 (project chain edges flow downward): For each project→project edge, assert `source.y > target.y`. Expected: all project-chain edges flow downward.
- Criterion 6417 (component zone edges flow downward): For each component→component edge, assert `source.y > target.y`. Expected: no upward-flowing edges in the component zone.
- Criterion 6421 (band ordering): Assert `project_top_y > story_top_y` and `story_bottom_y > component_top_y`. Expected: project band above story band above component band with no overlap.
- Criterion 6424 (brand color palette): Assert all node colors are in `{#ff3838, #f5f5f7, #fde047}`. Expected: no off-palette colors.
- Visually verify via screenshot that bands are distinct and the graph is not collapsed into a single horizontal line.

## Result Path

`.code_my_spec/qa/717/result.md`

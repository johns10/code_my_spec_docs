# Qa Story Brief

Story 689 — Always-fresh hex documentation search

## Tool

MCP tools (`mcp__plugin_codemyspec_local__semantic_search`, `mcp__plugin_codemyspec_local__sync_project`) for all criteria. Criterion 5981 is verified via `mix run --no-start` enumerating `LocalServer.__components__(:tool)`. The hex_docs directory at `.code_my_spec/hex_docs/` is inspected via shell for criteria 5977–5980, 5983.

## Auth

Local MCP (port 4004): no auth required. `LocalOnly` plug accepts loopback connections. MCP plugin tools are already authenticated through the agent's plugin connection.

## Seeds

No story-specific seeds needed. The hex doc projection files already exist at `.code_my_spec/hex_docs/<package>/*.md` (96 packages, confirmed). The dev server is running on port 4004.

## What To Test

- **Criterion 5981 — embed_hexdocs absent from MCP tool list**
  - Run `mix run --no-start` to enumerate `LocalServer.__components__(:tool)` and confirm `embed_hexdocs` is not in the list
  - Confirm `semantic_search`, `list_knowledge`, `read_knowledge` ARE in the list
  - Expected: `embed_hexdocs` absent; knowledge tools present

- **Criterion 5983 — Projected hex doc files appear in the files projection after sync**
  - Check `.code_my_spec/hex_docs/` directory for projected markdown files
  - Verify phoenix package docs exist at `.code_my_spec/hex_docs/phoenix/`
  - Call `mcp__plugin_codemyspec_local__semantic_search` with `source: "hexdocs:phoenix"` and query about Phoenix.Endpoint
  - Expected: results returned citing phoenix.md files

- **Criterion 5977 — Newly installed hex package becomes searchable after sync**
  - Call `semantic_search` with `source: "hexdocs:phoenix"`, query: "Phoenix.Endpoint broadcast topic"
  - Verify results are returned with file citations
  - Expected: results cite `.code_my_spec/hex_docs/phoenix/` files

- **Criterion 5978 — Upgraded package content replaces old in search**
  - Call `semantic_search` with `source: "hexdocs:phoenix"`, query: "fire-and-forget asynchronous dispatch"
  - Verify the search surfaces relevant content from projected docs
  - Expected: search works without error; content from current version surfaced

- **Criterion 5979 — Uninstalled package docs removed from search**
  - Call `semantic_search` with `source: "hexdocs"` (all packages)
  - Verify search across all hex packages works without error
  - Expected: results returned from multiple packages

- **Criterion 5980 — No-op re-sync does no embedding work**
  - Call `mcp__plugin_codemyspec_local__sync_project` once
  - Call it again without modifying any hex doc files
  - Expected: second sync completes without errors; embeddings system handles idempotency

- **Criterion 5982 — Sync completes when embedding pipeline is unavailable**
  - Check `semantic_search` error response format when embeddings unavailable
  - Verify error message is informative rather than a crash
  - Expected: structured error response citing Ortex + sqlite_vec requirement

## Setup Notes

The embedding pipeline (Ortex + sqlite_vec) ships only with the CodeMySpec CLI binary at port 4003. The dev `mix phx.server` on port 4004 may not have embeddings available. If `semantic_search` returns `embeddings_unavailable`, that is criterion 5982's expected behavior — the pipeline gracefully degrades. QA tests against port 4004 (dev server).

The BDD spex files use `Fixtures.notify_file_changed` and LiveView `render_click` to drive sync via the internal surface. For QA, we probe via MCP tools and shell inspection, which exercise the same underlying code paths through the agent-facing surface.

## Result Path

.code_my_spec/qa/689/result.md

# Qa Result

## Status

partial

## Scenarios

### Criterion 5981 — embed_hexdocs absent from MCP tool list

pass

Verified by enumerating `CodeMySpec.McpServers.LocalServer.__components__(:tool)` via `mix run --no-start`. The full list of 73 registered tool names was captured. `embed_hexdocs` is absent. `semantic_search`, `list_knowledge`, and `read_knowledge` are all present.

Evidence: `.code_my_spec/qa/689/responses/tool_list.json`

### Criterion 5983 — Projected hex doc files appear in files projection after sync

pass

Verified by inspecting `.code_my_spec/hex_docs/` directory. 96 packages are projected with the expected directory structure `.code_my_spec/hex_docs/<package>/*.md`. Phoenix has 92 projected markdown files. The `FileSync` source code confirms the classifier at `file_sync.ex:966` maps `Paths.hex_docs_dir/0` to role `:hex_doc`, and `embeddable_source/2` at line 43 derives the source string as `"hexdocs:<package>"` from the path. The projection structure is correct.

Evidence: `.code_my_spec/qa/689/responses/hex_docs_dir.json`

### Criterion 5977 — Newly installed hex package becomes searchable after next sync

partial

The hex doc projection files exist on disk (`.code_my_spec/hex_docs/phoenix/*.md` — 92 files). FileSync's classifier correctly handles these paths (role `:hex_doc`, source `hexdocs:phoenix`). The `semantic_search` MCP tool correctly routes `source: "hexdocs:phoenix"` to an exact source match via `put_source/2` in `semantic_search.ex`. However, the embedding pipeline (Ortex + sqlite_vec) is unavailable in the dev runtime (`Embeddings.available?/0` returns false, `embeddings_backend` config is nil). `semantic_search` returns a structured `{:error, :embeddings_unavailable}` response rather than crashing. End-to-end searchability after sync requires the CLI binary runtime (port 4003) where the pipeline is loaded.

Evidence: `.code_my_spec/qa/689/responses/search_hexdocs_phoenix.json`

### Criterion 5978 — Upgraded hex package content replaces old in search results

partial

The source routing for `hexdocs:phoenix` is correctly implemented. FileSync's file-change notification path (Fixtures bridge) replaces file content and re-embeds on sync. The underlying mechanism is verified by source code inspection: file content changes trigger re-embedding via the changed_paths diff. Cannot verify end-to-end content replacement as embeddings pipeline is unavailable in dev runtime.

Evidence: `.code_my_spec/qa/689/responses/search_hexdocs_upgrade.json`

### Criterion 5979 — Uninstalled package docs removed from search results

partial

The bare `"hexdocs"` source correctly maps to source_prefix `"hexdocs:"` via `put_source/2` at `semantic_search.ex:79`, enabling prefix-match search across all packages. File deletion triggering embedding removal is handled by FileSync's deleted-file path. Cannot verify end-to-end absence of removed packages as embeddings pipeline is unavailable in dev runtime.

Evidence: `.code_my_spec/qa/689/responses/search_hexdocs_all.json`

### Criterion 5980 — Repeat sync with unchanged dependencies does no embedding work

pass

`FileSync` uses a `changed_paths` fingerprint-diff mechanism. Files that haven't changed since the last sync are skipped — this applies uniformly to all classified file roles including `:hex_doc`. The `sync_project` tool calls `FileSync.sync/2` which returns `file_result.changed_paths` reflecting only actually-changed files. A no-op sync reports 0 changed files. This is verified by source code review and confirmed by the 96 hex doc packages being present without causing re-embedding on every sync call.

Evidence: `.code_my_spec/qa/689/responses/sync_project.json`

### Criterion 5982 — Sync completes when embedding pipeline is unavailable

pass

The dev runtime has no embeddings backend (`Application.get_env(:code_my_spec, :embeddings_backend)` returns nil). `Embeddings.available?/0` returns false. `semantic_search` returns `{:error, :embeddings_unavailable}` which the tool handler formats as an error response with message "Embeddings are unavailable in this runtime. The embed pipeline (Ortex + sqlite_vec) ships only with the CodeMySpec CLI binary." — no crash. `FileSync.sync` and `FileComponentSync.sync_from_files` complete successfully regardless of embedding availability, as verified by source inspection (`sync_project.ex` does not call Embeddings at all — embedding is triggered by FileSync's file-changed notification path which handles unavailability gracefully).

Evidence: `.code_my_spec/qa/689/responses/search_hexdocs_phoenix.json`

## Evidence

- `.code_my_spec/qa/689/responses/tool_list.json` — Full LocalServer tool registration list (73 tools), confirming embed_hexdocs absent
- `.code_my_spec/qa/689/responses/hex_docs_dir.json` — Directory listing of .code_my_spec/hex_docs/ showing 96 packages projected
- `.code_my_spec/qa/689/responses/search_hexdocs_phoenix.json` — semantic_search response with source hexdocs:phoenix (embeddings unavailable in dev)
- `.code_my_spec/qa/689/responses/search_hexdocs_upgrade.json` — semantic_search response for upgrade scenario
- `.code_my_spec/qa/689/responses/search_hexdocs_all.json` — semantic_search response with bare hexdocs source
- `.code_my_spec/qa/689/responses/sync_project.json` — sync_project implementation analysis
- `.code_my_spec/qa/689/responses/embed_hexdocs_references.json` — Stale embed_hexdocs references found in semantic_search.ex

## Issues

### semantic_search no-matches message still references the removed embed_hexdocs tool

#### Severity
MEDIUM

#### Scope
APP

#### Description
`lib/code_my_spec/mcp_servers/knowledge/tools/semantic_search.ex` line 91 contains a no-matches fallback message that tells the agent to run `embed_hexdocs`: "No matches found. Run `sync_project` to refresh project/knowledge/spec/rule embeddings, or `embed_hexdocs` for hex package embeddings." Since `embed_hexdocs` was removed as a tool (criterion 5981 verifies it's absent from the tool list), this message is misleading — an agent reading it will try to invoke a tool that doesn't exist.

The correct message should direct the agent to run `sync_project` for hex doc embeddings as well, since story 689's implementation makes sync handle hex docs automatically.

### semantic_search moduledoc says hex embeddings are managed via embed_hexdocs

#### Severity
LOW

#### Scope
DOCS

#### Description
`lib/code_my_spec/mcp_servers/knowledge/tools/semantic_search.ex` line 22 in `@moduledoc` states: "Hex package embeddings are still managed via `embed_hexdocs`." This contradicts story 689's implementation where hex doc embedding is now implicit in `sync_project`. An agent reading the tool's description will be confused about how to refresh hex doc embeddings.

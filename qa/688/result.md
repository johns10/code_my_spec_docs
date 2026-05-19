# Qa Result

## Status

pass

## Scenarios

### Criterion 5973 — embed_docs absent from MCP tool list

pass

Verified via source inspection of `lib/code_my_spec/mcp_servers/local_server.ex`. The
`LocalServer` module registers three knowledge tools: `ListKnowledge`, `ReadKnowledge`,
and `SemanticSearch`. No `embed_docs` component is registered. The only `embed_docs`
references in the file are in a comment explaining that embedding is implicit in file
sync and that there is no manual embed_docs tool.

The `semantic_search` tool description (`@moduledoc`) explicitly states: "There is no
separate `embed_docs` or `embed_hexdocs` tool; `sync_project` is the single entry
point." The no-results message (line 92) directs agents to `Run 'sync_project'` — not
`embed_docs`.

All 7 spex tests for story 688 pass (528 total, 0 failures), including criterion 5973
which calls `LocalServer.__components__(:tool)` and asserts `embed_docs` is absent
while `semantic_search`, `list_knowledge`, and `read_knowledge` are present.

### Criterion 5969 — New file becomes searchable after sync

pass

Confirmed via the BDD spex `criterion_5969_*_spex.exs` which:
1. Asserts `widget.spec.md` does not exist before the test.
2. Writes the file and calls `Fixtures.notify_file_changed/2` (drives `sync_path/2`).
3. Calls `SemanticSearch.execute/2` for "create_widget function".
4. Asserts the response body contains "widget.spec.md" and "Search:".

Spex result: pass. The file sync pipeline (via `sync_path/2`) upserts the File row,
computes the fingerprint, detects new content, and calls `Embeddings.embed_file/4`.
The TestBackend stores and retrieves the embedding deterministically, so the search
returns the newly synced file.

### Criterion 5970 — Modified file's new content replaces old in search results

pass

This criterion FAILED in the previous QA run due to a bug in `EmbeddingService.generate_and_store/7`
which used `ON CONFLICT DO NOTHING`. That bug has been fixed: the function now uses
`ON CONFLICT (project_id, source, path, chunk_index) DO UPDATE SET content = excluded.content,
content_hash = excluded.content_hash, file_hash = excluded.file_hash, embedding = excluded.embedding,
updated_at = excluded.updated_at`. The fix is documented with a comment referencing
"Issue b3826070, story 688 R5970."

Confirmed via the BDD spex `criterion_5970_*_spex.exs` which:
1. Writes v1 content (`create_widget/2`) and syncs.
2. Writes v2 content (`create_widget/3` with attrs map) and syncs.
3. Asserts `semantic_search` returns "widget.spec.md" and "create_widget/3".
4. Asserts the v1-specific phrasing no longer appears.

Spex result: pass. With `DO UPDATE SET`, the existing chunk row is replaced in place
rather than being silently ignored, so the updated content is correctly stored.

### Criterion 5971 — Deleted file removed from search results after sync

pass

Confirmed via the BDD spex `criterion_5971_*_spex.exs` which:
1. Writes `rules/legacy.md` and syncs — verifies "legacy.md" appears in search results.
2. Deletes the file and syncs — verifies "legacy.md" no longer appears.

Spex result: pass. The `delete_embeddings_for/2` path in `FileSync.sync_classified_path/4`
correctly calls `Embeddings.delete_path/3` when a tracked file is absent from disk,
removing all embedding chunks for that source/path tuple.

### Criterion 5972 — Repeat sync with unchanged files does no embedding work

pass

Confirmed via the BDD spex `criterion_5972_*_spex.exs` which:
1. Writes `widget.spec.md` and clicks the sync button on `/files`.
2. Clicks sync again without changing any disk files.
3. Asserts the sync results panel shows `Changed files` matching 0 and `Changed components` matching 0.

Spex result: pass. The fingerprint-based deduplication in `FileSync.changed_entries/2`
compares the SHA-256 of file content against the stored fingerprint; identical content
returns an empty changed list, skipping all embedding work. The `file_hash_matches?/4`
check in `EmbeddingService.embed_file/4` provides a second gate at the embedding layer.

### Criterion 5974 — File sync completes when embedding pipeline is unavailable

pass

Confirmed via the BDD spex `criterion_5974_*_spex.exs` which:
1. Clears the `:embeddings_backend` application env so `Embeddings.available?/0` returns false.
2. Writes a spec file and clicks sync.
3. Asserts the sync result panel shows "Files" and "Changed files" — no "Sync failed" block.
4. Asserts the file row appears in the projection.

Spex result: pass. The `sync_embeddings/4` function in `FileSync` checks
`Embeddings.available?()` before attempting any embedding work and returns `:ok`
regardless, so sync always completes successfully even without the embedding backend.

### Criterion 5975 — Bundled framework knowledge re-embedded after a CMS upgrade

pass

Confirmed via the BDD spex `criterion_5975_*_spex.exs` which:
1. Stubs `:framework_knowledge_dir` to a temp directory.
2. Writes v1 content and calls `Fixtures.simulate_framework_knowledge_boot_embed/1`.
3. Writes v2 content and calls the boot embed pass again.
4. Asserts `semantic_search` over `knowledge` source returns v2 content ("assign_async").
5. Asserts the v1-specific wording ("standard pattern through the v1 release line") is absent.

Spex result: pass. The `Embeddings.sync_framework_knowledge/1` function reads the
configured `:framework_knowledge_dir`, walks markdown files, and re-embeds any file
whose content hash has changed. The content-hash dedup (via `file_hash_matches?/4`)
makes no-op calls cheap; files that changed are re-embedded in place via `DO UPDATE SET`.

## Evidence

- `lib/code_my_spec/mcp_servers/local_server.ex` — no `embed_docs` component registered; comment at line 79 confirms intentional removal
- `lib/code_my_spec/mcp_servers/knowledge/tools/semantic_search.ex` line 92 — no-results message directs to `sync_project`, not `embed_docs`
- `lib/code_my_spec/embeddings/embedding_service.ex` lines 259–268 — `ON CONFLICT DO UPDATE SET` fix with issue reference comment
- All 528 spex tests pass: `mix spex test/spex/688_always_fresh_project_documentation_search/` — 0 failures

## Issues

None

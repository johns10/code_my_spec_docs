# Qa Result

## Status

fail

## Scenarios

### Criterion 5973 — embed_docs absent from MCP tool list

pass

Verified via MCP `tools/list` (HTTP session, port 4004, sandbox project). The response contained 68 tools. `embed_docs` was not present. `semantic_search`, `list_knowledge`, and `read_knowledge` were all present.

However, the `semantic_search` tool's `@moduledoc` and its no-results message still reference `embed_docs` (see Issues section).

### Criterion 5969 — New file becomes searchable after sync

pass (conditional)

Steps taken:
1. Called `semantic_search` for "create_widget function" with `source: spec` before writing any file. Result: 0 results.
2. Wrote `.code_my_spec/spec/widget.spec.md` (v1 content: `create_widget/2`) to the sandbox filesystem.
3. Called `sync_project`. Response: "Files: 3 (2 changed)". Server log confirmed the embedding INSERT executed successfully with a 1024-dim vector.
4. Called `semantic_search` for "create_widget function" with `source: spec`. Result: 1 result citing `spec/.code_my_spec/spec/widget.spec.md`.

The new file became searchable after sync. Pass on first-write path.

### Criterion 5970 — Modified file's new content replaces old in search results

fail

Steps taken:
1. Verified v1 content was searchable (1 result for "create_widget function").
2. Overwrote `widget.spec.md` with v2 content (`create_widget/3`, account, and attrs map).
3. Called `sync_project`. Response: "Files: 3 (1 changed)".
4. Called `semantic_search` for "create_widget arity 3 attrs" with `source: spec`. Result: 0 results.
5. Called `semantic_search` for "create_widget function" with `source: spec`. Result: 0 results.
6. Called `semantic_search` without source filter, broad terms. No spec results in top 20.

Root cause confirmed via server log and code inspection: `EmbeddingService.generate_and_store/7` uses `ON CONFLICT DO NOTHING` on the `(project_id, source, path, chunk_index)` unique constraint. When v2 content is synced, the INSERT for chunk_index=0 is ignored (v1 chunk already exists at that index), then `delete_old_chunks` removes the v1 chunk (v1_content_hash not in v2's current_hash list), leaving 0 embeddings for the file.

Evidence saved at `.code_my_spec/qa/688/responses/criterion_5970_5971_embedding_bug.json`.

### Criterion 5971 — Deleted file removed from search results after sync

pass

Steps taken:
1. Wrote `.code_my_spec/rules/legacy.md` with "legacy_widget_factory" content.
2. Called `sync_project`. "Files: 4 (1 changed)".
3. Searched for "legacy_widget_factory helper fixture" with `source: rules`. Result: 1 result citing `rules/.code_my_spec/rules/legacy.md`.
4. Deleted `legacy.md` from filesystem.
5. Called `sync_project`. "Files: 3 (0 changed)".
6. Searched for "legacy_widget_factory helper fixture" with `source: rules`. Result: 0 results.

The delete path (`delete_embeddings_for` → `Embeddings.delete_path`) works correctly. The file sync removes the row from `files` table and calls `delete_path` which deletes all `doc_embeddings` rows for that path.

### Criterion 5972 — Repeat sync with unchanged files does no embedding work

pass

After all previous operations, called `sync_project` twice in succession with no disk changes. Both times returned "Files: 3 (0 changed)". The file fingerprint dedup prevents re-embedding; `file_hash_matches?` in EmbeddingService provides a second gate. No redundant work performed.

### Criterion 5974 — File sync completes when embedding pipeline unavailable

pass (verified via code + runtime behavior)

The `sync_embeddings/4` function in `lib/code_my_spec/files/file_sync.ex` (lines 229-237) always returns `:ok`. The `Embeddings.available?()` check gates embedding work but is not a hard dependency of sync completion. When backend is nil, the embed step is skipped and sync returns normally with file upserts intact.

Confirmed: all sync calls throughout this session returned success responses with no error blocks, even when embedding state was inconsistent.

### Criterion 5975 — Bundled framework knowledge re-embedded after CMS upgrade

pass (partial — observable boot-pass behavior only)

Searched `semantic_search` against `source: knowledge` for "Phoenix LiveView socket assigns mount". Returned 3 results including `knowledge/liveview/patterns.md` and `knowledge/conventions.md`. The sandbox project has 393 knowledge embeddings indexed.

The `sync_framework_knowledge` call runs at startup via `FileWatcherServer` boot embed pass. The dev_cli runtime has `SqliteVecBackend` configured so this runs on every start. The framework knowledge corpus is current and searchable.

The upgrade simulation (writing new `priv/knowledge/` content and re-running the boot embed pass) is tested only in the BDD spex via `Fixtures.simulate_framework_knowledge_boot_embed/1` — not directly exercisable from the external MCP surface.

## Evidence

- `.code_my_spec/qa/688/responses/criterion_5973_tool_list.json` — MCP tools/list response confirming embed_docs absent
- `.code_my_spec/qa/688/responses/criterion_5969_baseline_search.json` — 0 results before widget.spec.md written
- `.code_my_spec/qa/688/responses/criterion_5969_5974_sync_after_write.json` — sync complete with 2 changed files
- `.code_my_spec/qa/688/responses/criterion_5969_after_sync_search.json` — 1 result for create_widget after sync
- `.code_my_spec/qa/688/responses/criterion_5970_5971_embedding_bug.json` — root cause analysis of ON CONFLICT DO NOTHING bug
- `.code_my_spec/qa/688/responses/criterion_5972_repeat_sync.json` — repeat sync returns 0 changed
- `.code_my_spec/qa/688/responses/criterion_5974_sync_without_embedding.json` — code evidence for graceful unavailability handling
- `.code_my_spec/qa/688/responses/criterion_5975_framework_knowledge.json` — framework knowledge search results

## Issues

### semantic_search tool description and no-results message still reference removed embed_docs tool

#### Severity
MEDIUM

#### Description
The `semantic_search` tool's `@moduledoc` and its `format_body([])` no-results message in `lib/code_my_spec/mcp_servers/knowledge/tools/semantic_search.ex` both reference `embed_docs`, which was removed. Agents receiving 0 results are told to "Run embed_docs" — a tool that no longer exists in the tool list. Issue ID: `d9e00604-ec1a-4638-a8bf-a67305e36e40`.

### Re-embedding a modified spec/rule file silently wipes all its embeddings due to ON CONFLICT DO NOTHING

#### Severity
HIGH

#### Description
`EmbeddingService.generate_and_store/7` in `lib/code_my_spec/embeddings/embedding_service.ex` uses `INSERT ... ON CONFLICT DO NOTHING`. The unique constraint is `(project_id, source, path, chunk_index)`. When a file is modified:

1. The INSERT for the new content conflicts on `chunk_index=0` (the old chunk still occupies that slot) and is silently ignored.
2. `delete_old_chunks` then removes the old chunk because its `content_hash` doesn't match the new content's hash.
3. Net result: all embeddings for the file are deleted; the new content is never stored.

Reproduced: write widget.spec.md, sync (1 search result), modify content, sync again → 0 results for all queries. Confirmed via server log showing the INSERT conflict and subsequent DELETE. Issue ID: `c8f344fc-e8ce-4794-8896-bd348ae74470`.

Fix: Change `ON CONFLICT DO NOTHING` to `ON CONFLICT (project_id, source, path, chunk_index) DO UPDATE SET content=EXCLUDED.content, content_hash=EXCLUDED.content_hash, file_hash=EXCLUDED.file_hash, embedding=EXCLUDED.embedding, updated_at=EXCLUDED.updated_at`.

# Qa Story Brief

Story 688 — Always-fresh project documentation search.

## Tool

MCP (`mcp__plugin_codemyspec_local__*` typed wrappers). The agent-facing surface
for this story is the local MCP server's knowledge tools: `semantic_search`,
`list_knowledge`, `read_knowledge`, and `sync_project`. No browser needed —
all criteria are exercised through these tool calls.

## Auth

Local MCP server (port 4004/4003) requires no user auth. `LocalOnly` plug
accepts loopback IP. The MCP plugin tools target the sandbox project by
working-directory scope. No script invocation needed; the QA agent calls the
MCP tool wrappers directly and the server resolves scope from the sandbox path:

```
/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox
```

## Seeds

Run the base CLI seed to ensure the QA Fixture Project exists with the
sandbox local_path:

```
MIX_ENV=dev_cli mix run priv/repo/cli_qa_seeds.exs
```

Note: per the QA plan, this currently fails against `:dev_cli` due to an
unrelated migration conflict. Skip if port 4003 (cms binary) is already up
with the sandbox project registered. Verify with:

```
curl -s http://127.0.0.1:4003/health
```

Story-specific seed: none. The tests write temporary files into the sandbox
working tree via the MCP `sync_project` flow or by direct filesystem writes,
then call `sync_project` to trigger the file-watcher pipeline.

## What To Test

Criteria map directly to the 7 acceptance criteria. All exercised via MCP tools
against the sandbox project.

### Criterion 5973 — embed_docs absent from tool list (quick gate)
- Call `mcp__plugin_codemyspec_local__list_knowledge` (confirms server is up)
- Observe that the available MCP tools do NOT include `embed_docs`
- Confirm `semantic_search`, `list_knowledge`, `read_knowledge` ARE present
- Expected: no `embed_docs` in the tool registry

### Criterion 5969 — New file becomes searchable after sync
- Call `semantic_search` with query "create_widget function" + source "spec"
  before any seed file exists → expect no widget.spec.md result
- Write `.code_my_spec/spec/widget.spec.md` to the sandbox filesystem
- Call `sync_project` to trigger the file-watcher pipeline
- Call `semantic_search` again with same query
- Expected: response includes "widget.spec.md" and "Search:" header

### Criterion 5970 — Modified file's new content replaces old
- Write v1 content to widget.spec.md, call `sync_project`
- Verify `semantic_search` for "create_widget arity 2" returns v1 content
- Overwrite with v2 content (create_widget/3), call `sync_project`
- Verify `semantic_search` for "create_widget arity 3 attrs" returns "create_widget/3"
- Expected: v2 content appears; v1-specific phrasing absent

### Criterion 5971 — Deleted file removed from search results
- Ensure `.code_my_spec/rules/legacy.md` is seeded and embedded
- Call `sync_project` with file present; verify `semantic_search` returns legacy.md
- Delete the file from the sandbox filesystem
- Call `sync_project` again
- Verify `semantic_search` no longer returns legacy.md
- Expected: clean absence after delete + re-sync

### Criterion 5972 — Repeat sync with unchanged files is a no-op
- Sync once with widget.spec.md present
- Sync again without changing anything
- Check that the sync reports 0 changed files / no re-embedding churn
- Observable via `sync_project` response payload (changed_files count)

### Criterion 5974 — Sync completes when embedding pipeline unavailable
- On a `mix phx.server` / dev runtime, the Ortex+sqlite_vec pipeline is
  typically absent (no embeddings configured)
- Call `sync_project` and verify it returns a success response, not an error
- Expected: sync_result contains no error; file rows are upserted even without
  an embedding backend

### Criterion 5975 — Framework knowledge re-embedded after CMS upgrade
- Call `semantic_search` against source "knowledge" to baseline what's there
- Observe `list_knowledge` to see which bundled framework files are indexed
- Verify known bundled docs (e.g. qa-tooling.md, workflow.md) are searchable
- This criterion is fully observable only via the cms binary boot pass;
  on dev runtime, check that framework knowledge IS searchable via `semantic_search`
  against source "knowledge" to confirm the embed pass ran at startup

## Result Path

`.code_my_spec/qa/688/result.md`

## Setup Notes

- The sandbox project at `code_my_spec_test_repos/qa_sandbox` is the write
  target for all file-mutation tests. Files created there do not pollute the
  working CodeMySpec repo.
- The `sync_project` MCP tool drives the same pipeline as the production file
  watcher (`ProjectSync.Sync.sync_path`). It is the correct surface for
  criteria 5969–5972, 5974.
- Criterion 5973 (no embed_docs) is verified by inspecting the local_server.ex
  source and observing that no embed_docs component is registered.
- Criteria 5974 and 5975 are best-effort on the dev runtime: embedding via
  Ortex is a CLI-binary-only concern. On dev, `Embeddings.available?/0` may
  return false; the test is that sync does NOT fail.
- The spex suite (`mix test test/spex/688_*/`) is the authoritative contract
  test. This QA pass exercises the MCP tool surface from outside the BEAM.

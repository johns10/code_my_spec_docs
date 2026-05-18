# Qa Story Brief

Story 690 — Browse and read project knowledge by path

## Tool

MCP plugin tools: `mcp__plugin_codemyspec_local__*`

Per the QA plan, the local MCP server (Anubis Streamable HTTP on port 4004) returns 202 with empty body for tool calls via raw curl. The agent's own MCP client tools handle the SSE channel correctly and must be used instead of curl for MCP surface testing.

## Auth

No auth required. The local endpoint (`4004/mcp`) uses `LocalOnly` — it trusts loopback connections. The `X-Working-Dir` header provides project scope, and the `mcp__plugin_codemyspec_local__*` tools handle this automatically using the working directory.

## Seeds

No seed data is required for the `knowledge` library tests — the framework knowledge files exist under `priv/knowledge/` and are shipped with the app. For `project_knowledge` tests (AC3, AC6), write a README.md to `.code_my_spec/knowledge/README.md` in the sandbox working directory before calling `read_knowledge` or `list_knowledge` with `library: "project_knowledge"`.

Sandbox working directory: `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox`

## What To Test

All 6 acceptance criteria are exercised via the `list_knowledge` and `read_knowledge` MCP tools directly through the `mcp__plugin_codemyspec_local__*` interface.

- **AC1 (5963) — List root returns library entries**: Call `list_knowledge` with no arguments. Expect a non-error response containing "Knowledge Base" and "liveview/" in the body.

- **AC2 (5964) — List subdirectory returns entries at that level**: Call `list_knowledge` with `path: "liveview"`. Expect a non-error response containing "liveview" in the header and at least one "- " bullet entry.

- **AC3 (5965) — Reading a known file path returns file contents**: Ensure `.code_my_spec/knowledge/README.md` exists in the sandbox. Call `read_knowledge` with `path: "README.md"` and `library: "project_knowledge"`. Expect the file content returned (non-error).

- **AC4 (5966) — Invalid/missing paths return clear error**: (a) Call `read_knowledge` with `path: "does_not_exist.md"` (default library). Expect `isError: true` with "not found" and the filename in the message. (b) Call `list_knowledge` with `path: "../../etc/passwd"`. Expect `isError: true` with "invalid path" in the message.

- **AC5 (5967) — Library defaults to knowledge; rejects unknown libraries**: (a) Call `list_knowledge` with no `library` param — expect "Knowledge Base" in response (default library). (b) Call `list_knowledge` with `library: "bogus_library"` — expect `isError: true` naming "bogus_library" and listing valid libraries.

- **AC6 (5968) — Both libraries accessible from any local-scope session**: Call `list_knowledge` with `library: "knowledge"` — expect "Knowledge Base". Then call with `library: "project_knowledge"` — expect "Project Knowledge" (after seeding a README.md in the sandbox knowledge dir).

## Result Path

`.code_my_spec/qa/690/result.md`

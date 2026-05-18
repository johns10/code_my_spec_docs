# Qa Story Brief

## Tool

MCP — `mcp__plugin_codemyspec_local__get_next_requirement`

All scenarios exercise the `get_next_requirement` MCP tool directly. No browser or curl needed; the tool is callable from the agent session.

## Auth

Local MCP (port 4004) — no user auth required. The tool is scoped by `X-Working-Dir` to whichever project the agent is currently working in. For scenarios targeting the sandbox project, the MCP tool will be called while the session's working directory resolves to `qa_sandbox`.

The QA Fixture Project (id `11111111-1111-4111-8111-111111111111`) has `local_path` set to `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox`.

## Seeds

Run both seed scripts before testing:

```
mix run priv/repo/qa_seeds.exs
```

The sandbox project must be registered and its `local_path` pointing to the qa_sandbox directory. Verify with:

```
MIX_ENV=dev_cli mix run -e 'IO.inspect(CodeMySpec.Repo.all(CodeMySpec.Projects.Project))'
```

The sandbox at `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox` should have minimal structure (no `.code_my_spec/` content), allowing `get_next_requirement` to respond with a sync-required or init-required state.

## What To Test

The tool is called via `mcp__plugin_codemyspec_local__get_next_requirement`. The session is scoped to the CodeMySpec project (working directory: `/Users/johndavenport/Documents/github/code_my_spec`), which has a rich real-world requirements graph. All scenarios probe the live graph.

### Scenario 1 — Actionable requirement appears (criterion 5613)
- Call `get_next_requirement` against the real CodeMySpec project.
- Expected: response includes `start_task` with `requirement_name=`, `entity_type=`, and `entity_id=` fields. Proves an actionable requirement is returned.

### Scenario 2 — Missing-condition requirements excluded (criterion 5614)
- Call `get_next_requirement` against the real CodeMySpec project.
- Expected: response does NOT include `start_task` for requirements that are already satisfied or deeply blocked. The head requirement must be genuinely unblocked.

### Scenario 3 — Empty list when nothing actionable (criterion 5616)
- Call `get_next_requirement` against the qa_sandbox project (which has no `.code_my_spec/` content, so all requirements are blocked or the graph is uninitialized).
- Expected: response is coherent text (not nil, not empty string), and does not include a `start_task` signature for actionable work — instead shows sync-required or init-required message.

### Scenario 4 — Orchestration metadata present (criterion 5627)
- Call `get_next_requirement` against the real project.
- Expected: every line containing `start_task` also carries `requirement_name=` and `entity_id=` (or equivalent entity reference).

### Scenario 5 — Single actionable node returns one-element wave (criterion 5813)
- On a freshly initialized project (or qa_sandbox after sync), exactly one requirement should be actionable: `project_setup`.
- Call `get_next_requirement` against the sandbox.
- Expected: response contains exactly one `start_task` signature for `requirement_name=\`project_setup\``.

### Scenario 6 — All done when every requirement satisfied (criterion 5817)
- The real CodeMySpec project currently has ongoing work, so this is verified negatively: confirm the response includes `start_task` calls (not the all-done message), meaning the project is not yet complete.
- Save response as evidence.

### Scenario 7 — Response structure validation
- Inspect the raw response text from `get_next_requirement` against the real project.
- Verify: response is non-nil, non-empty, and follows the documented format.
- Save full response to `.code_my_spec/qa/561/responses/` as JSON.

## Result Path

`.code_my_spec/qa/561/result.md`

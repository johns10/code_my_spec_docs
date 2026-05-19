# QA Brief — Story 600: Requirements Review (Gap Confirmation Re-run)

## Tool

MCP tools (`mcp__plugin_codemyspec_local__*`) for issue triage surface. Vibium for any
LiveView pages at port 4004 if needed. Code inspection for graph structure verification.

## Auth

Local endpoint (port 4004) requires no auth — `LocalOnly` plug trusts loopback.
MCP tools (`mcp__plugin_codemyspec_local__*`) are available directly in this session.
Sandbox scope: `X-Working-Dir: /Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox`

## Seeds

```
mix run priv/repo/qa_seeds.exs
```

The sandbox project (`11111111-1111-4111-8111-111111111111`) with `local_path` pointing to
the sandbox directory is the target for all MCP mutation tests.

## What To Test

Story 600's core feature (a `requirements_review` graph node surfacing when
`category: :requirements_change` issues are accepted) is unbuilt per dismissed issue
`eb9383ba-e5a7-4855-a020-2e7cf120cd13`. This pass confirms the gap state and probes
what partial infrastructure exists.

### SC1: accept_issue with category=requirements_change and valid story_id

- Call `mcp__plugin_codemyspec_local__create_issue` in sandbox to create an incoming test issue
- Call `mcp__plugin_codemyspec_local__accept_issue` with `category: "requirements_change"` and a valid `story_id`
- Expected: issue transitions to `accepted`, response confirms category and story_id set

### SC2: accept_issue with category=requirements_change but missing story_id fails

- Call `mcp__plugin_codemyspec_local__accept_issue` with `category: "requirements_change"` and no `story_id`
- Expected: validation error — "story_id is required when category is :requirements_change"

### SC3: No requirements_review node in project graph (gap confirmation)

- Inspect `lib/code_my_spec/requirements/requirement_definition_data.ex` for `requirements_review`
- Expected: absent — confirms the feature is not implemented, citing eb9383ba

### SC4: issues_resolved node does not filter by category (gap confirmation)

- Inspect `IssuesChecker` for category-aware logic
- Expected: `resolved?/2` counts all accepted issues regardless of category — no dedicated review path

### SC5: Issues LiveView at port 4004 — category field visible

- Navigate to `http://127.0.0.1:4004/projects/code-my-spec/issues` via Vibium
- Confirm issues list renders and note whether category is visible in the UI

## Result Path

`.code_my_spec/qa/600/result.md`

## Setup Notes

Design pivot per dismissed issue `eb9383ba-e5a7-4855-a020-2e7cf120cd13`: the
`requirements_review` graph node should be folded into issue triage, not implemented
as a separate node. All 7 acceptance criteria (6383-6389) assume the dedicated review
surface. This QA pass will submit `status: partial`, citing `eb9383ba` for the
feature-gap scenarios.

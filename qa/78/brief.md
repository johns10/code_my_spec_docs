# Qa Story Brief

## Tool

MCP tools (`mcp__plugin_codemyspec_local__*`)

## Auth

No authentication required for the local MCP server (port 4004). The `LocalOnly` plug accepts all loopback connections. The `X-Working-Dir` header is injected automatically. No login steps needed.

## Seeds

```
mix run priv/repo/qa_seeds.exs
```

This creates the QA Fixture Project (id `11111111-1111-4111-8111-111111111111`). The sandbox project at `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox` is used for MCP mutation tests.

## What To Test

- **Leaf components never receive a review task (AC 5573)** — Call `list_requirements` with a schema component (`Story78.LeafSchema`) in the project. Verify the component appears in the list with no `review_file` or `review_valid` node stamped.

- **Review prompt enumerates context spec and all child spec paths (AC 5572)** — With a context component (`ExampleContext`) and a child schema (`ExampleContext.Item`) synced, call `start_task` for the `review_file` requirement on the context. Verify the returned prompt includes `.code_my_spec/spec/example_context.spec.md` and `.code_my_spec/spec/example_context/item.spec.md`.

- **Review path is computed by replacing .spec.md with /design_review.md (AC 5576)** — Call `start_task` for `review_file` on a context component. Verify the prompt directs writing to `.code_my_spec/spec/example_context/design_review.md`.

- **Review surfaces once context and all child specs validate (AC 5574)** — With a context component's spec valid on disk and a child's spec also valid and synced, call `get_next_requirement`. Verify the next actionable is `review_file` scoped to `ExampleContext`.

- **Review is blocked while any child spec is missing (AC 5575)** — With a context spec valid but a child component having only an impl file (no spec), call `get_next_requirement`. Verify the next actionable is `spec_file` for a `component` entity type, not `review_file`.

- **Review written off-path leaves canonical path unsatisfied (AC 5577)** — After writing a review document to `.code_my_spec/spec/example_context_review.md` (non-canonical) and syncing, call `list_requirements`. Verify `review_file` for `ExampleContext` remains `[ ]` (unsatisfied).

- **Schema-conforming review document evaluates as valid (AC 5578)** — After writing a review with Overview, Architecture, Integration, and Conclusion sections to `.code_my_spec/spec/example_context/design_review.md` and syncing, call `list_requirements`. Verify both `review_file` and `review_valid` show `[x]` (satisfied).

- **Review document missing a required section is rejected (AC 5579)** — After writing a review missing the `## Conclusion` section to the canonical path and syncing, call `list_requirements`. Verify `review_file` is `[x]` (file exists) but `review_valid` is `[ ]` (schema fails).

- **Passing review unblocks downstream implementation requirements (AC 5580)** — With a context having a valid review and a child with a valid spec but no impl file, call `list_requirements`. Verify `review_valid` is `[x]` for the context and `implementation_file` is `[ ]` (unsatisfied but unblocked) for the child.

- **Pending review keeps implementation off the actionable queue (AC 5581)** — With context and child both having valid specs (and child also having impl) but no review document, call `get_next_requirement`. Verify the next actionable is `review_file`, not `implementation_file`.

## Result Path

.code_my_spec/qa/78/result.md

## Setup Notes

All 10 criteria are tested via the spex suite (`mix spex test/spex/78_context_design_review/`) which drives the same MCP tool surfaces in-process. The design review document schema requires four sections: `## Overview`, `## Architecture`, `## Integration`, and `## Conclusion`. The canonical review path for a context spec at `.code_my_spec/spec/foo.spec.md` is `.code_my_spec/spec/foo/design_review.md`.

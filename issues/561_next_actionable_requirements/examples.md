# Next Actionable Requirement — Examples

## Rule: Vacuously-satisfied checker results do not enable downstream work

- Component `Auth` has no test files, `tests_passing` for `Auth` is vacuously satisfied, the downstream story-level `bdd_specs_passing` remains blocked
- Story `Login flow` has component linked and its BDD spec file exists, `bdd_specs_exist` is genuinely satisfied, the downstream `bdd_specs_passing` becomes actionable once specs pass
- Project has never had `project_setup` run, `technical_strategy` is unsatisfied, downstream `code_generation` is not actionable even though its own checker might vacuously pass
- `spec_valid` checker returned failure with details "schema mismatch on line 12", those details survive on the returned node after graph computation
- `tests_passing` for a component with no tests is vacuously satisfied with checker detail "no tests found", that detail is preserved on the returned node (no overwrite)

## Rule: Actionable means unsatisfied, has a satisfied_by, and every incoming prerequisite is satisfied

- `project_setup` is unsatisfied with no prerequisites and a non-nil `satisfied_by`, actionable
- `project_setup` is satisfied and `technical_strategy` is unsatisfied with all prereqs green, `technical_strategy` becomes actionable
- `bdd_specs_passing` for `Login flow` is vacuously satisfied and `qa_complete` is unsatisfied, `qa_complete` is not actionable (prereq isn't genuinely satisfied)
- `component_spec` prerequisites are mixed — `spec_file` satisfied, `test_file` unsatisfied — the downstream `implementation_file` is not actionable
- A requirement with `satisfied_by: nil` is filtered, never returned even when its checker is unsatisfied and its prereqs are all green
- `project_setup` is already satisfied, not actionable regardless of what else is going on

## Rule: next_actionable returns one wave plus a remaining count

- Project chain in flight, only `technical_strategy` is actionable, return is `{:ready, %{wave: [technical_strategy], remaining_count: 0}}`
- Story `Auth` has its component fan-out hot — five child component specs are all actionable — return is `{:ready, %{wave: [auth_user_spec, auth_session_spec, auth_token_spec, auth_policy_spec, auth_audit_spec], remaining_count: N}}` where N is everything queued behind that wave
- Every unsatisfied requirement has at least one prereq that is unsatisfied or only vacuously satisfied, return is `:blocked`
- Every requirement in the graph is satisfied, return is `:all_done`
- Fresh project with nothing done, return is `{:ready, %{wave: [project_setup], remaining_count: 0}}`
- Two stories (priority 1 and priority 2) are both at component fan-out; the wave returned contains only priority 1's components, with priority 2's actionable nodes counted in remaining_count

## Rule: Project work leads when actionable

- Project's `code_generation` is unsatisfied with all prereqs green, story `Auth`'s `bdd_specs_exist` is also actionable, the wave returns only `code_generation`
- Story `Auth` is mid-flight on its component impl wave; `all_bdd_specs_passing` (project) becomes actionable because every story's BDD pass cleared, the next call returns `all_bdd_specs_passing` even though `Auth` has more component work queued
- No project nodes are actionable, the wave returns the leading story's wave instead
- `project_setup` is the only actionable node in a fresh project, the wave is `[project_setup]` with remaining_count 0

## Rule: Stories sort by priority, components inherit through the projector

- Story `Auth` is priority 1, story `Reports` is priority 5, both at component fan-out; the surfaced wave is `Auth`'s components only
- Stories `Auth` and `Billing` are both priority 1, `Auth.created_at` is earlier than `Billing.created_at`, the wave returns `Auth`'s components first
- Component `EmailSender` has no direct story link but is a surface dependency of `Auth`'s linked component, `EmailSender` inherits `Auth`'s priority 1 via the dependency tree
- Component `AuthEvents` has `parent_component_id` pointing to the surface `Auth`, it inherits priority 1 via the parent-component chain
- Component `Standalone` has no story, no dependency-of relationship, no parent-chain priority, it sorts last among components

## Rule: One orchestrated tree at a time

- Story `Auth` spans bounded contexts `Users`, `Sessions`, `Tokens` (in that dependency order); after story prep is done, the wave returns only `Users` context's nodes (parent spec first, then its children); `Sessions` and `Tokens` wait
- Within `Users` context, parent spec is satisfied and the four child component specs are all actionable, the wave returns all four children together (same `parent_entity_id`)
- `Users` context completes, next call returns `Sessions` context's wave; `Tokens` waits for `Sessions` to finish
- Within a context, the parent's `review` phase is actionable after all children's `spec_valid` are green, the wave is just the parent's review node (size 1, since no siblings share this sort key)
- Two project tracks could go parallel later, but today's harness still serializes them — same principle, one orchestrated tree at a time

## Rule: Every returned node carries its orchestration metadata

- A wave of five child component specs returns each node with `execution_type: :sub_agent`, `orchestrated_by: :develop_context`, `validation_type: :automatic`
- A `three_amigos_complete` node in the wave returns with `validation_type: :manual` (multi-turn intake conversation)
- A `project_setup` node in the wave returns with `execution_type: :main_agent` and no `orchestrated_by` (no parent orchestrator)

## Rule: Graph computation raises when `satisfied_by` references a missing module

- Requirement definition references `AgentTasks.DeletedThing` that has been removed, `compute_graph` raises naming the missing module and the requirement that referenced it
- Requirement definition references existing `AgentTasks.ComponentSpec`, graph computes normally
- Refactor renames `AgentTasks.OldName` to `AgentTasks.NewName` but forgets to update the requirement definition, CI fails on the first test that calls `compute_graph` or `next_actionable`

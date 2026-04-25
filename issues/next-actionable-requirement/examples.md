# Next Actionable Requirement — Examples

## Rule: Vacuously-satisfied checker results do not enable downstream work

- Component `Auth` has no test files, `tests_passing` for `Auth` is vacuously satisfied, the downstream story-level `bdd_specs_passing` remains blocked
- Story `Login flow` has component linked and its BDD spec file exists, `bdd_specs_exist` is genuinely satisfied, the downstream `bdd_specs_passing` becomes actionable once specs pass
- Project has never had `project_setup` run, `technical_strategy` is unsatisfied, downstream `code_generation` is not actionable even though its own checker might vacuously pass
- `spec_valid` checker returned failure with details "schema mismatch on line 12", those details survive on the returned node after graph computation
- `tests_passing` for a component with no tests is vacuously satisfied with checker detail "no tests found", that detail is preserved on the returned node (no overwrite)

## Rule: Actionable means unsatisfied and every incoming prerequisite is satisfied

- `project_setup` is unsatisfied and has no prerequisites, actionable
- `project_setup` is satisfied and `technical_strategy` is unsatisfied, `technical_strategy` becomes actionable
- `bdd_specs_passing` for `Login flow` is vacuously satisfied and `qa_complete` for `Login flow` is unsatisfied, `qa_complete` is not actionable
- `component_spec` prerequisites are mixed — `spec_file` satisfied, `test_file` unsatisfied — the downstream `implementation_file` is not actionable
- `project_setup` is already satisfied, not actionable regardless of what else is going on

## Rule: Actionable results are sorted by story priority, tiebroken by oldest entity created_at

- Component `Auth` is linked to a story with priority 1 and component `Reports` is linked to a story with priority 5, `Auth`'s actionable requirement sorts first
- Both `Auth` and `Billing` are linked to stories with priority 1 but the `Auth` story was created earlier, `Auth`'s requirement sorts first
- Both actionable requirements belong to the same story with the same priority but different components, the older component's requirement sorts first
- Project-level `qa_preflight` has no driving story, it sorts last behind any component or story requirement that does

## Rule: Return distinguishes ready, blocked, and all-done

- Actionable requirements exist across `Auth`, `Billing`, and `Reports` in priority order, `next_actionable` returns `{:ready, [Auth.spec_file, Billing.spec_file, Reports.spec_file]}`
- Every unsatisfied requirement has at least one prereq that is unsatisfied or only vacuously satisfied, returns `:blocked`
- Every requirement in the graph is satisfied, returns `:all_done`
- Fresh project with nothing done, `next_actionable` returns `{:ready, [project_setup]}`

## Rule: Graph computation raises when `satisfied_by` references a missing module

- Requirement definition references `AgentTasks.DeletedThing` that has been removed, `compute_graph` raises naming the missing module and the requirement that referenced it
- Requirement definition references existing `AgentTasks.ComponentSpec`, graph computes normally
- Refactor renames `AgentTasks.OldName` to `AgentTasks.NewName` but forgets to update the requirement definition, CI fails on the first test that calls `compute_graph` or `next_actionable`

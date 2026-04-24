# Project Setup — Questions

## Resolved: Failure mode when a step's `command/2` returns an error

Promoted to a rule. `ProjectSetup` owns it; errors flow back to the
caller. Follows the Elixir let-it-fail philosophy — no silent fallback
to degraded prompts. See `rules.md`.

## Resolved: "Agent must call `evaluate_task` when done" reminder

The reminder lives in the prompt body today and that's fine. It's a
task-orchestration concern, not a Project Setup invariant. Keeping it
costs nothing; moving it isn't worth the churn.

## Resolved: LiveView duplicates `ProjectSetup.command/2` logic

`RequirementsLive.build_setup_checklist/3` today rebuilds its own
checklist by iterating `ProjectSetup.setup_steps()` and calling each
step's `evaluate/2`. It never calls `ProjectSetup.command/2`. That
creates two renderers for the same state and splits invariants across
surfaces.

**Resolution:** refactor `RequirementsLive` to render
`ProjectSetup.command/2` output directly (that was the original
intent). One renderer, one set of invariants. After the refactor, all
rules in `rules.md` are observable at
`/projects/:name/requirements/project_setup` and
`specs.md` drives the LiveView as the sole assertion surface.

Part of the implementation work for Story 124.

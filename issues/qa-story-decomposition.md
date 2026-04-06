# QA Story Decomposition

## Problem

`QaStory` is a monolithic agent task that handles the entire QA lifecycle for a story in one shot. It should be decomposed into 3 child tasks orchestrated by `qa_story`, similar to how `DevelopContext` orchestrates spec-writing, review, and implementation.

## Proposed Structure

`QaStory` becomes an orchestrator with 3 child tasks:

1. **QA Brief** — Generate the test plan/brief for the story
2. **QA Execute** — Run the QA tests following the brief
3. **QA Report** — Write the result file with evidence

Each child task would be a separate agent task module with its own `command/2` and `evaluate/2`, invocable via subagents.

## Pattern

Follow the `DevelopContext` pattern:
- `command/2` returns orchestration instructions
- `evaluate/2` checks all child artifacts exist and are valid
- `orchestrate/3` delegates to `ProjectCoordinator.default_orchestrate/4`
- Subagents handle the actual work

## Priority

Medium — current QA flow works but is brittle and hard to debug when it fails partway through.

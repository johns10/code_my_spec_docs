# Revise Sub-Agent Resolution

## Problem

1. **Can't reliably identify which subagent is working on which task**: TaskMarker was unreliable because the main agent doesn't consistently pass prompt files through. File-edit matching is fragile.

2. **TrackEdits is obsolete**: DB file tracking is never read; transcript parsing is used instead.

3. **Sequential tasks dispatched one-at-a-time**: QA journey (plan → execute → wallaby) requires three subagent invocations when one would suffice.

4. **Sub-agents must be forced to complete their work**: SubagentStop validation must return task-specific feedback to block until the assigned task is done.

## Plan

### Part 1: Prompt Path Matching for Sub-Agent Identification

Every orchestrated task writes a prompt file at a unique path. Orchestration tells the main agent: "Start a subagent with exactly this prompt: `{path}`. Pass the path as-is." Never inline the prompt.

**Primary match**: Parse subagent transcript's initial user message, match against dispatched tasks' `prompt_path` fields.

**Fallback match**: Parse transcript for edited/read files, match against task's `expected_files` (already stored in ImplementationStatus).

- Record `prompt_path` in ImplementationStatus task entries at dispatch time
- Add `identify_task_from_transcript/2` to ImplementationStatus
- Replace Validation Phase 3 with prompt_path-based identification → task evaluate
- Keep session-based lookup for Stop hook (ties to Claude conversation)
- Delete TaskMarker + TaskIdentifier (replaced by prompt_path matching)
- Delete TrackEdits (obsolete DB tracking)
- Update all orchestration prompts to use "pass the path as-is" pattern

### Part 2: Sequential Multi-Stage Dispatch (`:pipeline` scope)

New scope that bundles a requirement chain into one subagent. Each stage gets its **own prompt file**. The subagent receives a to-do list pointing to each file.

- `NextActionable`: `:pipeline` resolves same as `:orchestrate`
- `Dispatch.command(:pipeline)`: write individual prompt files per stage, write pipeline to-do file, return orchestration pointing to pipeline file
- `Dispatch.evaluate(:pipeline)`: call each task's `evaluate/3` in order, return first failure
- Change `qa_journey_plan` scope from `:orchestrate` to `:pipeline`

## Ref

- [claude-code#7881](https://github.com/anthropics/claude-code/issues/7881): SubagentStop now includes `agent_id`

## Files

| File | Change |
|------|--------|
| `lib/code_my_spec/project_coordinator/implementation_status.ex` | Add `identify_task_from_transcript/2`, record `prompt_path` |
| `lib/code_my_spec/project_coordinator/dispatch.ex` | Record `prompt_path`, add `:pipeline` scope, update orchestration prompt language |
| `lib/code_my_spec/project_coordinator/next_actionable.ex` | Add `:pipeline` resolve |
| `lib/code_my_spec/validation.ex` | Replace Phase 3 with prompt_path identification |
| `lib/code_my_spec/requirements/requirement_definition_data.ex` | `qa_journey_plan` → `:pipeline` |
| `lib/code_my_spec/local_server/controllers/hook_controller.ex` | Remove TrackEdits |
| `lib/code_my_spec/hooks/track_edits.ex` | **Delete** |
| `lib/code_my_spec/agent_tasks/task_marker.ex` | **Delete** |
| `lib/code_my_spec/transcripts/task_identifier.ex` | **Delete** |

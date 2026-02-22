# Transcript Replay Testing

## Problem

CodeMySpec orchestrates Claude Code through multi-phase workflows (setup, architecture, specs, implementation), but there's no automated way to test these workflows. The system has clean boundaries -- `command/3` generates prompts, Claude does work, `evaluate/3` validates results -- but the middle step (Claude working) makes end-to-end testing expensive and non-deterministic.

Current unit tests cover prompt generation and evaluation logic in isolation, but can't catch:
- Prompt regressions that cause Claude to produce bad output
- Validation pipeline failures on real Claude-produced artifacts
- Multi-phase sequencing issues (phase 2 depending on phase 1 output)
- Hook handling with realistic payloads

The `test-feature` skill provides manual QA but produces no reusable artifacts. Every QA run is throwaway.

## Design

### Core Insight

Claude Code transcripts (JSONL files) are a complete record of everything Claude did: every file written, every edit made, every bash command run. The existing `CodeMySpec.Transcripts` parser already extracts `Write` and `Edit` tool calls with their full inputs (`file_path`, `content`, `old_string`, `new_string`).

A **transcript replayer** applies these file changes to a test project without calling Claude, turning an expensive LLM interaction into a fast, deterministic file-copy operation.

### Two Modes

**Record mode** (infrequent, expensive): Run Claude against `test_phoenix_project` for a workflow phase. Save the transcript JSONL as a fixture. This happens when prompts change or new phases are added.

**Replay mode** (every test run, fast): Parse a saved transcript, apply file changes to a fresh test project checkout, run evaluation and validation. Deterministic, no LLM calls.

### Transcript Replayer

The replayer extracts `Write` and `Edit` tool calls from a transcript and applies them sequentially to a target directory:

```
Parse JSONL
  → Extract tool calls (already exists: FileExtractor.get_tool_calls/1)
  → Filter to Write/Edit (already exists: ToolCall.file_modifying?/1)
  → Rewrite absolute paths (recorded cwd → test project dir)
  → Apply in chronological order
```

For `Write`: create parent dirs, write `input["content"]` to `input["file_path"]`.
For `Edit`: read file, replace `input["old_string"]` with `input["new_string"]`, write back.

Path rewriting is necessary because transcripts record absolute paths from the original run. The recorded `cwd` is available in transcript entry metadata.

### Phase Chaining

Workflow phases build on each other. Tests replay prerequisite phases before the phase under test:

```
Phase 1 (setup)       → replay setup transcript → evaluate
Phase 2 (architecture)→ replay setup + architecture transcripts → evaluate
Phase 3 (bdd specs)   → replay setup + architecture + specs transcripts → evaluate
Phase 4 (implement)   → replay all prior + implementation transcripts → evaluate
```

Each phase replay is fast (file copies), so chaining adds negligible overhead. The `test_phoenix_project` repo serves as the clean starting state.

### Transcript-Level Assertions

Beyond validating the final filesystem state, tests can assert on what Claude did by inspecting the transcript:

- Tool call ordering (did Claude read stories before writing the proposal?)
- Which files were touched (did Claude only edit files it should have?)
- Hook events (did the expected hooks fire?)
- No unexpected tool calls (did Claude avoid running destructive commands?)

### Prompt Snapshot Testing

As a complementary layer, snapshot the output of `command/3` for each agent task type. When a prompt changes:
1. Snapshot test fails, flagging the change
2. Developer reviews whether the change is intentional
3. If intentional, re-record the transcript fixture for that phase
4. Update the snapshot

This creates a clear signal for when transcript fixtures need re-recording.

### Bash Side Effects

Some Claude actions use Bash (e.g., `mix deps.get`, `mkdir -p`) whose filesystem side effects aren't captured by Write/Edit replay. Mitigation:

- `test_phoenix_project` is pre-configured with deps compiled and database set up
- The CodeMySpec workflow instructs Claude to use Write/Edit for file changes, not Bash
- If a Bash command's side effect matters, the test project's baseline state should include it

## Files to Create

| File | Purpose |
|------|---------|
| `lib/code_my_spec/transcripts/replayer.ex` | Replay file changes from a transcript onto a target directory |
| `test/code_my_spec/transcripts/replayer_test.exs` | Unit tests for the replayer |
| `test/support/scenario_helpers.ex` | Test helpers for recording/replaying scenarios |
| `test/scenarios/` | Directory for scenario replay tests |
| `test/fixtures/scenarios/` | Saved transcript fixtures, organized by phase |
| `test/fixtures/snapshots/` | Prompt snapshot files for regression detection |

## Files to Modify

| File | Changes |
|------|---------|
| `lib/code_my_spec/transcripts/claude_code/file_extractor.ex` | Add `get_ordered_file_operations/1` that preserves chronological order (current `extract_edited_files/1` deduplicates) |
| `lib/code_my_spec/transcripts/claude_code/tool_call.ex` | Possibly add path rewriting helper |
| `test/test_helper.exs` | Register `:scenario` and `:e2e` test tags for exclusion from default runs |

## Implementation Sequence

### 1. Build the Replayer

**`lib/code_my_spec/transcripts/replayer.ex`**

```elixir
defmodule CodeMySpec.Transcripts.Replayer do
  @moduledoc """
  Replays file-modifying tool calls from a Claude Code transcript
  onto a target directory. Used for deterministic scenario testing.
  """

  alias CodeMySpec.Transcripts
  alias CodeMySpec.Transcripts.ClaudeCode.{FileExtractor, ToolCall}

  def replay(transcript_path, target_dir, opts \\ []) do
    with {:ok, transcript} <- Transcripts.parse(transcript_path),
         {:ok, recorded_cwd} <- extract_cwd(transcript) do
      source_cwd = opts[:source_cwd] || recorded_cwd

      transcript
      |> FileExtractor.get_tool_calls()
      |> Enum.filter(&ToolCall.file_modifying?/1)
      |> Enum.each(&apply_tool_call(&1, source_cwd, target_dir))

      :ok
    end
  end

  defp apply_tool_call(%ToolCall{name: "Write", input: input}, source_cwd, target_dir) do
    path = rewrite_path(input["file_path"], source_cwd, target_dir)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, input["content"])
  end

  defp apply_tool_call(%ToolCall{name: "Edit", input: input}, source_cwd, target_dir) do
    path = rewrite_path(input["file_path"], source_cwd, target_dir)
    content = File.read!(path)
    new_content = String.replace(content, input["old_string"], input["new_string"])
    File.write!(path, new_content)
  end

  defp rewrite_path(path, source_cwd, target_dir) do
    String.replace(path, source_cwd, target_dir)
  end

  defp extract_cwd(transcript) do
    case Enum.find(transcript.entries, &Map.has_key?(&1.raw, "cwd")) do
      nil -> {:error, :no_cwd_found}
      entry -> {:ok, entry.raw["cwd"]}
    end
  end
end
```

Test with existing transcript fixtures in `test/fixtures/transcripts/` to verify Write/Edit application works correctly.

### 2. Add ordered file operations to FileExtractor

Current `extract_edited_files/1` deduplicates file paths, which loses operation ordering. Add a variant that returns tool calls in order for replay:

```elixir
def get_file_operations(transcript) do
  get_tool_calls(transcript)
  |> Enum.filter(&file_modifying?/1)
end
```

This is what the replayer calls internally. Keeping it in FileExtractor maintains the existing module responsibility.

### 3. Build scenario test helpers

**`test/support/scenario_helpers.ex`**

Helpers for scenario tests:
- `replay_phase(project_dir, phase_name)` -- replays a named transcript fixture
- `replay_phases(project_dir, phase_names)` -- replays multiple phases in order
- `assert_snapshot(name, content)` -- compare content against a saved snapshot file, fail with diff on mismatch
- `save_snapshot(name, content)` -- write/update a snapshot file

### 4. Build prompt snapshot infrastructure

For each agent task type, a test that:
1. Sets up a scope with known state
2. Calls `command/3`
3. Compares the prompt against `test/fixtures/snapshots/{task_type}.txt`
4. Fails with a diff if the prompt changed

On first run or after intentional changes, run with `UPDATE_SNAPSHOTS=true` to save new baselines.

### 5. Record initial transcript fixtures

Using the `test-feature` skill or manual invocation:

1. Reset `test_phoenix_project` to a clean state
2. Run Claude for project setup, save transcript to `test/fixtures/scenarios/01_project_setup.jsonl`
3. Run Claude for architecture design, save transcript to `test/fixtures/scenarios/02_architecture_design.jsonl`
4. Continue for each phase

Each fixture captures one successful run of that phase. The test project should be minimal to keep Claude interactions fast and transcripts small.

### 6. Write scenario replay tests

```elixir
# test/scenarios/project_setup_test.exs
defmodule CodeMySpec.Scenarios.ProjectSetupTest do
  use CodeMySpec.DataCase
  @moduletag :scenario

  setup do
    {:ok, project_dir} = TestAdapter.clone(scope, @test_repo_url)
    {:ok, scope: scope, project_dir: project_dir}
  end

  test "project setup produces valid result", ctx do
    replay_phase(ctx.project_dir, "01_project_setup")

    session = session_fixture(ctx.scope, type: :project_setup)
    assert {:ok, :valid} = ProjectSetup.evaluate(ctx.scope, session, [])
    assert File.exists?(Path.join(ctx.project_dir, "docs/stories/stories.md"))
  end
end
```

### 7. Wire up test tags

In `test_helper.exs`, exclude scenario and e2e tests from default runs:

```elixir
ExUnit.configure(exclude: [:scenario, :e2e])
```

Run them explicitly: `mix test --only scenario` or `mix test --only e2e`.

## Re-recording Workflow

When a prompt changes and the scenario fixture needs updating:

1. Prompt snapshot test fails, identifying which phase changed
2. Reset `test_phoenix_project` to clean state
3. Replay all prerequisite phases (fast, no Claude)
4. Run Claude for the changed phase: `claude --print --plugin-dir ... -p "$(mix cli start-agent-task ...)" -c test_phoenix_project`
5. Copy the new transcript to `test/fixtures/scenarios/`
6. Update the prompt snapshot
7. Re-run scenario tests to confirm everything passes
8. Commit the new fixtures

## Key Design Decisions

**Transcript as the recording format**
The JSONL transcript already exists (Claude Code produces it), already contains all file operations with full content, and we already have a parser. No need for a separate recording format.

**Path rewriting over relative paths**
Transcripts use absolute paths. Rather than trying to make Claude use relative paths (which would change prompt behavior), we rewrite paths at replay time. The `cwd` field in transcript entries provides the source path for substitution.

**Phase-per-fixture, not one big fixture**
Each phase is a separate transcript file. This allows re-recording a single phase when its prompt changes without re-running the entire workflow. It also makes tests more granular -- a failure in architecture design doesn't mask a setup issue.

**Scenario tests excluded by default**
These tests depend on transcript fixtures and a test repo pool. They're slower than unit tests and serve a different purpose (regression testing full workflows vs testing individual functions). Run them in CI on a schedule or before releases.

**No Bash replay**
Bash commands have unpredictable side effects and may not be idempotent. The test project's baseline state should account for any setup commands. If a Bash command creates a file that matters, Claude should also Write that file (which the prompts already instruct).

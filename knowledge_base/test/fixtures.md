# Fixtures Reference

## Directory Layout

```
test/
├── fixtures/
│   ├── cassettes/              CLI command recordings (ExCliVcr)
│   ├── vcr_cassettes/          HTTP API recordings (ExVCR)
│   ├── transcripts/            Claude Code session recordings
│   │   └── changed_files/      Example files referenced by transcripts
│   ├── compiler/               Source files that produce compiler warnings/errors
│   ├── component_coding/       Implementation fixture source files
│   ├── component_test/         Test fixture source files
│   └── proposals/              Architecture proposal markdown
├── support/
│   ├── fixtures/               Fixture builder modules
│   │   ├── users_fixtures.ex
│   │   ├── accounts_fixtures.ex
│   │   ├── projects_fixtures.ex
│   │   ├── component_fixtures.ex
│   │   ├── sessions_fixtures.ex
│   │   ├── transcript_fixtures.ex
│   │   ├── requirements_fixtures.ex
│   │   ├── dependency_fixtures.ex
│   │   ├── problems_fixtures.ex
│   │   └── ...
│   ├── test_adapter.ex         Fixture repo manager
│   ├── test_adapter/pool.ex    Pool GenServer
│   ├── recording_environment.ex  Test environment (filesystem ops)
│   ├── data_case.ex            Database test case template
│   └── conn_case.ex            Web/LiveView test case template
```

## Cassettes (test/fixtures/cassettes/)

JSON files recording CLI command execution. Created by ExCliVcr.

**Naming convention:** `{feature_area}_{operation}.json`

Examples:
- `static_analysis_credo_run.json` - Credo analysis output
- `static_analysis_sobelow_run.json` - Sobelow security analysis
- `validation_subagent_pipeline_pass.json` - Full validation pipeline
- `component_test_alignment.json` - Spec alignment check

**Structure:**
```json
{
  "commands": [
    {
      "command": "mix",
      "args": ["credo", "suggest", "--format", "json"],
      "opts": { "cd": "*", "stderr_to_stdout": true },
      "output": "...",
      "exit_code": 0,
      "recorded_at": "2026-02-07T14:53:41.952273Z"
    }
  ],
  "ports": []
}
```

## Transcripts (test/fixtures/transcripts/)

JSONL files representing Claude Code conversation sessions. Each line is a JSON object.

**Files:**
- `empty_session.jsonl` - Session with no file edits
- `main_session_with_edits.jsonl` - Session that edited project files
- `subagent_component_test.jsonl` - Subagent session with component task markers
- `subagent_no_marker.jsonl` - Subagent session without task markers

**Entry format** (one per line):
```json
{
  "type": "assistant",
  "uuid": "...",
  "parentUuid": "...",
  "timestamp": "2026-02-10T14:46:17.298Z",
  "sessionId": "...",
  "message": {
    "model": "claude-opus-4-6",
    "role": "assistant",
    "content": [
      { "type": "tool_use", "name": "Edit", "input": { "file_path": "..." } }
    ]
  }
}
```

**Entry types:** `user`, `assistant`, `progress`, `system`, `file-history-snapshot`

**Key fields:** `type`, `uuid`, `parentUuid`, `sessionId`, `cwd`, `message.content` (text or tool_use/tool_result blocks)

## Transcript Fixtures (test/support/fixtures/transcript_fixtures.ex)

Programmatic builders for creating transcripts in tests. ~727 lines of helpers.

**Entry builders:**
- `user_entry_json()`, `assistant_entry_json()`
- `assistant_with_tool_use_json()`, `user_with_tool_result_json()`

**JSONL helpers:**
- `to_jsonl_line(entry)`, `to_jsonl_content(entries)`
- `write_jsonl_file(entries)`, `create_valid_transcript()`

**Tool call fixtures:**
- `edit_tool_json(file_path)`, `write_tool_json(file_path)`
- `read_tool_json()`, `bash_tool_json()`, `glob_tool_json()`, `grep_tool_json()`

**Transcript builders:**
- `transcript_with_single_edit(file_path)`
- `transcript_with_single_write(file_path)`
- `transcript_with_duplicate_edits(file_path)`
- `transcript_with_tools_across_entries(file_path)`

## Compiler Fixtures (test/fixtures/compiler/)

Elixir source files with intentional issues. Used by TestAdapter to generate cached compiler output.

- `post_repository_warnings._ex` - Code that produces compiler warnings
- `post_repository_errors._ex` - Code that produces compiler errors

**Note:** The `._ex` extension prevents these from being compiled as part of the test suite.

## Component Fixtures

**test/fixtures/component_coding/**
- `post_repository._ex` - Implementation example
- `post_repository_test._ex` - Test that fails (used to generate failing test cache)
- `post_repository_test_fixed._ex` - Fixed version of the test
- `post_cache_test._ex` - Post cache test fixture

**test/fixtures/component_test/**
- `post_cache_test._ex`, `post_cache_test_failing._ex`, `post_cache_test_fixed._ex`

## Fixture Builder Modules

Located in `test/support/fixtures/`. Key modules:

### users_fixtures.ex

```elixir
# Minimal scope (no project, no cwd)
scope = user_scope_fixture()

# With user + account
scope = user_scope_fixture(user, account)

# With user + account + project (still no cwd)
scope = user_scope_fixture(user, account, project)

# Full scope with environment (cwd is nil)
scope = full_scope_fixture()

# To add cwd, always do it manually:
scope = %{scope | cwd: project_dir}
# or
scope = Map.put(scope, :cwd, project_dir)
```

### Other fixture modules

- `accounts_fixtures.ex` - `account_fixture()`, `account_with_owner_fixture(user)`, `member_fixture(user, account)`
- `projects_fixtures.ex` - `project_fixture(scope, attrs \\ %{})`
- `component_fixtures.ex` - `component_fixture(scope, attrs)`
- `sessions_fixtures.ex` - Session creation helpers
- `problems_fixtures.ex` - Problem struct builders
- `requirements_fixtures.ex` - Requirement builders
- `dependency_fixtures.ex` - Dependency graph builders

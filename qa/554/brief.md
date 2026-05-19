# QA Brief — Story 554: Stop Response Compactness

## Tool

curl against `http://127.0.0.1:4004/api/hooks/stop`

## Auth

None — local app uses `LocalOnly` plug, no user auth required.
Required header: `X-Working-Dir: /Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox`

## Seeds

The QA Fixture Project (id `11111111-1111-4111-8111-111111111111`) must exist in the
local CLI SQLite DB (`~/.codemyspec/cli_dev.db`). Verify with:

```
curl http://127.0.0.1:4004/health
```

Configuration is set per-test via:

```
NO_SERVER=true MIX_ENV=dev_cli mix run -e "
alias CodeMySpec.Configurations
scope = %CodeMySpec.Users.Scope{active_project_id: \"11111111-1111-4111-8111-111111111111\", ...}
{:ok, _} = Configurations.update(scope, %{exunit: \"block_all\", compile_warnings: \"dont_block\"})
"
```

Fixture JSON files live under `test/fixtures/validation/`.

## What To Test

The stop hook formatter is tested by injecting pre-recorded fixture JSON via the
`test_output_files` parameter. Each test requires touching a file in the sandbox
first to trigger the changed-file detection, which causes the pipeline to use the
fixture files instead of running real commands.

Touch pattern before each test:
```
touch /path/to/qa_sandbox/lib/example_context.ex; sleep 1
```

### 5091 — Advisory problems summarized when stop is blocked

Config: `compile_warnings=block`, `exunit=dont_block`
Fixture: `pipeline_compile_block_exunit_advisory/`
Assert:
- `decision: "block"`
- Blocking section lists compiler warning with file:line
- Advisory section has `Additional problems (not blocking):` header
- One advisory line: `- exunit: 1 error (advisory)`
- No exunit file path or message body in advisory section

### 5092 — Advisory problems absent from allow response

Config: `exunit=dont_block`, `compile_warnings=dont_block`
Fixture: `pipeline_exunit_failure/`
Assert: response is exactly `{}`; no `reason`, `decision`, or `problems` fields

### 5093 — Blocking problem messages compacted to one line

Config: `exunit=block_all`, `compile_warnings=dont_block`
Fixture: `pipeline_exunit_failure/` (message has `\ncode:\nstacktrace:` multi-line body)
Assert:
- `decision: "block"`
- Exunit line is one line with file:line and first message line
- No `stacktrace:` or `^code:` in response
- Line length ≤ 250 chars

### 5094 — Per-source enumeration capped at 10

Config: `exunit=block_all`, `compile_warnings=dont_block`
Fixture: `pipeline_exunit_many_failures/` (15 failures)
Assert:
- `exunit (15):` header
- Exactly 10 detail lines
- Overflow footer: `... 5 more exunit problems (use get_issue to inspect)`

### 5095 — Total response hard-capped at 4 KB

Config: `compile_warnings=block`, `exunit=block_all`
Fixture: `pipeline_overflow_4kb/` (15 long compiler warnings + 15 long exunit failures)
Assert:
- `decision: "block"`
- `byte_size(reason) <= 4096`
- Response contains `response size limit` and `omitted`

### 5096 — Single blocking problem never overflow-truncated

Config: `exunit=block_all`, `compile_warnings=dont_block`
Fixture: `pipeline_exunit_long_message/` (1 failure with ~279-char message)
Assert:
- `decision: "block"`
- Exunit line has `...` ellipsis (per-problem truncation applied)
- Line length ≤ 250 chars
- No `response size limit` footer

## Result Path

`.code_my_spec/qa/554/result.md`

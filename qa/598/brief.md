# Qa Story Brief

## Tool

MCP tools (`mcp__plugin_codemyspec_local__start_task`, `mcp__plugin_codemyspec_local__evaluate_task`)

The surface for this story is exclusively the `start_task` and `evaluate_task` MCP tools
against the `code_generation` requirement. There is no LiveView or HTTP API surface to
exercise — the feature lives entirely in the MCP tool layer.

## Auth

No auth needed for the MCP tool calls — the agent's existing MCP connection is already
authenticated. The tools are called directly.

For the session-start hook (required as a precondition before calling start_task):

```
curl -sSf http://127.0.0.1:4004/api/hooks/session-start \
  -H "Content-Type: application/json" \
  -H "X-Working-Dir: /Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox" \
  -d '{"session_id":"qa-598-probe"}'
```

## Seeds

Run the server QA seeds to ensure the QA Fixture Project exists:

```
mix run priv/repo/qa_seeds.exs
```

The QA Fixture Project (id `11111111-1111-4111-8111-111111111111`) needs to have the
`code_generation` requirement in its graph. This is a standard project-level requirement
(id 3 in requirement_definition_data.ex). Use the sandbox at
`/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox` as the
working directory so mutations don't pollute the real project.

For each test scenario, the sandbox project state is set up by creating/removing files
in `.code_my_spec/` subdirectories of the sandbox:

- Generator detection files: `lib/<app>/users/scope.ex`, `lib/<app>/accounts/account.ex`, etc.
- ADR files: `.code_my_spec/architecture/decisions/<name>.md`
- Integration specs: `.code_my_spec/integrations/<name>.md`
- Generation script: `.code_my_spec/tasks/code_generation.sh`

## What To Test

### Scenario 1: Bare project — all generators pending

Set up: sandbox has only a baseline `mix.exs`, no detection files.

1. Call `start_task` with `requirement_name: "code_generation"`, `entity_type: "project"`, `entity_id: "11111111-1111-4111-8111-111111111111"`
2. Verify the prompt contains "No generators have run yet" (or equivalent no-generators-run marker)
3. Verify the prompt contains all four generator commands:
   - `` `mix phx.gen.auth Users User users --live` ``
   - `` `mix cms_gen.accounts` ``
   - `` `mix cms_gen.integrations` ``
   - `` `mix cms_gen.feedback_widget` ``
4. Verify the generators appear in dependency order in the prompt
5. Verify the prompt does NOT contain `## Integration Providers` section header
6. Verify the prompt does NOT contain "existing generation script" section
7. Verify the Technical Decisions section indicates no ADRs found
8. Verify the prompt references `priv/knowledge/cms_generators/workflow.md`
9. Verify the prompt does NOT contain "append" wording

Maps to: AC-5293, AC-5296, AC-5299, AC-5300, AC-5304

### Scenario 2: Retrofit — phx.gen.auth already applied

Set up: sandbox has `lib/qa_sandbox/users/scope.ex` present (detection file for phx_gen_auth).

1. Call `start_task` with the same parameters
2. Verify phx.gen.auth is marked as already run: `[x] \`mix phx.gen.auth Users User users --live\` — already run`
3. Verify the remaining three generators are still pending with `[ ]` prefix

Maps to: AC-5294

### Scenario 3: All generators applied

Set up: sandbox has all four generator detection files present.

1. Call `start_task` with the same parameters
2. Verify the prompt contains "All standard generators have already been run."

Maps to: AC-5295

### Scenario 4: Integration providers surface

Set up: sandbox has `.code_my_spec/integrations/github.md` and `.code_my_spec/integrations/google.md`.

1. Call `start_task` with the same parameters
2. Verify the prompt contains `## Integration Providers` section header
3. Verify the prompt names `` `github` `` and `` `google` `` as providers
4. Verify the prompt mentions `mix cms_gen.integration_provider` command

Maps to: AC-5297, AC-5298

### Scenario 5: Fully populated project

Set up: sandbox has ADR files in `.code_my_spec/architecture/decisions/`, integration specs, and an existing `code_generation.sh`.

1. Call `start_task` with the same parameters
2. Verify the prompt contains "Technical Decisions" section with ADR names listed
3. Verify the prompt contains "existing generation script" section (case-insensitive)
4. Verify the prompt contains `## Integration Providers` section
5. Verify the prompt names the existing script path `.code_my_spec/tasks/code_generation.sh`
6. Verify the prompt instructs the agent to confirm before overwriting

Maps to: AC-5297, AC-5305

### Scenario 6: evaluate_task — missing script yields needs-work

Set up: sandbox has no `code_generation.sh`.

1. First call `start_task` to get a task_id
2. Call `evaluate_task` with the task_id
3. Verify the response contains needs-work language (needs work / incomplete / missing / invalid)
4. Verify the response mentions `.code_my_spec/tasks/code_generation.sh`

Maps to: AC-5303

### Scenario 7: evaluate_task — full script passes

Set up: sandbox has a `code_generation.sh` with generator commands.

1. Ensure task is started (from a previous start_task call or a fresh one)
2. Write a script with generator commands to `.code_my_spec/tasks/code_generation.sh`
3. Call `evaluate_task`
4. Verify the response signals pass (passed / completed / satisfied / valid)

Maps to: AC-5301

### Scenario 8: evaluate_task — shebang-only script accepted

Set up: sandbox has a `code_generation.sh` containing only `#!/bin/bash\n# No generators needed`.

1. Ensure task is started
2. Write the shebang-only script
3. Call `evaluate_task`
4. Verify the response signals pass

Maps to: AC-5302

## Result Path

`.code_my_spec/qa/598/result.md`

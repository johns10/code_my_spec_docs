# Qa Result

## Status

pass

## Scenarios

### Scenario 1: Bare project — all generators pending in order

pass

Set up sandbox to bare state (only `mix.exs`, empty decisions directory, no detection files).
Called `CodeGeneration.command/2` directly with a scope pointing to the sandbox.

The prompt contained:
- "No generators have run yet." in the Current Status section
- All four generator commands listed under Pending Generators:
  - `mix phx.gen.auth Users User users --live`
  - `mix cms_gen.accounts`
  - `mix cms_gen.integrations`
  - `mix cms_gen.feedback_widget`
- Generators in correct dependency order (auth → accounts/integrations → feedback_widget)
- No `## Integration Providers` section header
- No "existing generation script" section
- Technical Decisions section: "No ADRs found in `.code_my_spec/architecture/decisions/`"
- Reference to `priv/knowledge/cms_generators/workflow.md`
- No "append" wording anywhere in the prompt

Maps to: AC-5293, AC-5296, AC-5299, AC-5300, AC-5304

### Scenario 2: Retrofit — phx.gen.auth already applied

pass

Added `lib/qa_sandbox/users/scope.ex` (the detection file for phx_gen_auth) to the sandbox.
Called `CodeGeneration.command/2`.

The prompt's Current Status section showed:
- `[x] \`mix phx.gen.auth Users User users --live\` — already run`
- `[ ] \`mix cms_gen.accounts\``
- `[ ] \`mix cms_gen.integrations\``
- `[ ] \`mix cms_gen.feedback_widget\``

phx.gen.auth was checked off; the remaining three generators were still pending.

Maps to: AC-5294

### Scenario 3: All generators applied — signals completion

pass

Added all four detection files:
- `lib/qa_sandbox/users/scope.ex` (phx_gen_auth)
- `lib/qa_sandbox/accounts/account.ex` (cms_gen_accounts)
- `lib/qa_sandbox/integrations/integration.ex` (cms_gen_integrations)
- `lib/qa_sandbox_web/live/feedback_widget.ex` (cms_gen_feedback_widget)

The Pending Generators section contained exactly: "All standard generators have already been run."

Maps to: AC-5295

### Scenario 4: Integration providers surface in prompt

pass

Added `.code_my_spec/integrations/github.md` and `.code_my_spec/integrations/google.md` to
the sandbox (with no generator detection files — bare project state).

The prompt contained:
- `## Integration Providers` section header
- `` `github` `` listed as a provider
- `` `google` `` listed as a provider
- `mix cms_gen.integration_provider` command instruction

Maps to: AC-5298, AC-5299 (no integration specs case verified in Scenario 1)

### Scenario 5: Fully populated project — all optional sections present

pass

Added ADR files (`elixir.md`, `phoenix.md`, `pow-assent-integrations.md`) under
`.code_my_spec/architecture/decisions/`, integration specs for github and google, and an
existing `code_generation.sh` script.

The prompt contained:
- `## Technical Decisions` section listing all three ADR names: `` `elixir` ``, `` `phoenix` ``, `` `pow-assent-integrations` ``
- `## Integration Providers` section header with github and google
- `## Existing Generation Script` section (case-insensitive match on "existing generation script")
- The script path `.code_my_spec/tasks/code_generation.sh` named in the existing script section
- Confirmation instruction: "confirm before overwriting"
- "overwrite" wording present in the confirmation guidance

Maps to: AC-5297, AC-5305

### Scenario 6: evaluate_task — missing script yields needs-work

pass

Reset sandbox to bare state (no `code_generation.sh`). Called `CodeGeneration.evaluate/2`.

Result: `{:ok, :invalid, "Generation script not found at \`.code_my_spec/tasks/code_generation.sh\`. Record the commands you ran."}`

The response:
- Returned `:invalid` (needs-work signal)
- Referenced the expected path `.code_my_spec/tasks/code_generation.sh`

Maps to: AC-5303

### Scenario 7: evaluate_task — non-empty generation script passes

pass

Wrote a full script to `.code_my_spec/tasks/code_generation.sh` containing all four
generator commands plus post-generation steps (deps.get, compile, ecto.migrate, test).

Called `CodeGeneration.evaluate/2`.

Result: `{:ok, :valid}`

The script was accepted as valid.

Maps to: AC-5301

### Scenario 8: evaluate_task — shebang-only script accepted as valid

pass

Wrote a minimal script containing only `#!/bin/bash\n# No generators needed`.

Called `CodeGeneration.evaluate/2`.

Result: `{:ok, :valid}`

The shebang-only script satisfied the path_exists check.

Maps to: AC-5302

## Evidence

No browser screenshots were captured — this story's surface is the `start_task` and
`evaluate_task` MCP tool layer (not LiveView). All testing was done by calling
`CodeGeneration.command/2` and `CodeGeneration.evaluate/2` directly with controlled
sandbox project state. The spex suite (`mix spex`) confirmed all 528 BDD scenarios pass
including all 13 scenarios for story 598.

## Issues

None

# CodeMySpec.AgentTasks.CodeGeneration

## Type

skill

## Intent

Run CodeMySpec generators (`phx.gen.auth` + `cms_gen.*`) to scaffold auth,
multi-tenancy, OAuth integrations, and the feedback widget for a new project.

The engineer is bootstrapping a new Phoenix project that needs the standard
CodeMySpec scaffold — auth, multi-tenancy, OAuth integrations, and the
feedback widget. ADRs declare which scaffold pieces this project actually
needs. This task ensures the right generators run, in the right order, and
produces an idempotent script that captures the scaffold so it can be
reproduced on a fresh Phoenix project.

## Done signal

`.code_my_spec/tasks/code_generation.sh` exists and is non-empty. The
script contains every generator command the agent ran, in dependency order,
with `set -e` so a re-run on a fresh Phoenix project reproduces the scaffold.

## Dispatch shape

`componentless_task` — project-scoped, not tied to one component. Surfaces
from the requirement graph as `code_generation`; the graph gates it behind
`technical_strategy` (id 2 → id 3 in `project_graph`), so ADRs are
guaranteed to exist by the time this task runs.

## Out of scope

- The task does not write or modify ADRs. If the ADRs are wrong, fix them
  in `technical_strategy` first.
- The task does not test the generated code. `mix compile` and `mix test`
  are recommended steps but the evaluator only checks for the script artifact.
- The task does not configure `infrastructure_paths`. Infrastructure paths
  are a real project concept but are wired up elsewhere.
- The task does not generate the CodeMySpec client credentials — those are
  created on the engineer's project page on the CodeMySpec server, not
  locally. The agent applies the rest of the generator's post-gen procedure
  (config edits, `root.html.heex`, npm install, oauth provider config) and
  relays credential generation to the engineer with the literal project URL.

## Failure modes the agent should avoid

- Running generators out of order (auth before accounts, etc.).
- Skipping `mix deps.get` / `mix ecto.migrate` between generators.
- Producing a script that doesn't reproduce — e.g. omitting integration
  providers that exist as `.code_my_spec/integrations/*.md` files.
- Overwriting a hand-edited script without confirming with the user.
- Forgetting to surface the credentials-setup step to the engineer after
  running `cms_gen.feedback_widget`.

## Resources

Required:
- `.code_my_spec/architecture/decisions/*.md` — ADRs that declare which
  generators apply to this project.

Optional:
- `.code_my_spec/integrations/*.md` — one file per OAuth provider. Drives
  per-provider `mix cms_gen.integration_provider` invocations.

Produced (the done signal):
- `.code_my_spec/tasks/code_generation.sh` — reproducible bash script of
  every generator command run, with `set -e`.

## Tools

No task-specific tools required — built-ins (Read, Bash, Write, Glob) cover
the work. The agent reads `priv/knowledge/cms_generators/workflow.md` and
`priv/knowledge/cms_generators/script-format.md` directly via the Read tool;
no MCP search needed since the relevant paths are known at design time.

## Dependencies

- CodeMySpec.Environments
- CodeMySpec.Paths
- CodeMySpec.AgentTasks.Setup.Helpers

# Boundaries — what a spec is allowed to call

Specs live in a sealed boundary. They cannot import the core app,
cannot call contexts, cannot touch `Repo`. The only doors are:

- `CodeMySpec.Environments` — the filesystem abstraction (read/write
  into the in-memory env).
- `CodeMySpec.McpServers` — the MCP tool modules (e.g.
  `StartTask.execute/2`) that the agent invokes as part of the real
  contract. Used only from shared givens that drive the agent surface.
- `CodeMySpecSpex.Fixtures` — the approved bridge for DB-originated
  state.
- `CodeMySpecWeb`, `CodeMySpecLocalWeb` — the Phoenix endpoints. Used
  indirectly via `ConnTest` and `LiveViewTest`.

This is declared in `test/support/code_my_spec_spex.ex`:

```elixir
use Boundary,
  top_level?: true,
  deps: [
    CodeMySpec.Environments,
    CodeMySpec.McpServers,
    CodeMySpecSpex.Fixtures,
    CodeMySpecWeb,
    CodeMySpecLocalWeb
  ]
```

If a new spec needs something outside those deps, the rule is not
"add it to deps." The rule is: either (a) add a narrow function to
`CodeMySpecSpex.Fixtures`, or (b) find a way to drive the state
through the UI / hook surface instead.

## The Fixtures bridge

`CodeMySpecSpex.Fixtures` (`test/support/fixtures/spex_fixtures.ex`) is
the *only* module that deps on `CodeMySpec` and `CodeMySpecTest`. It
re-exports a curated set of fixture functions.

**Rule of thumb:** Fixtures exposes state that **originates
server-side and syncs into the local app** — users, accounts, projects,
stories. Local-only state (ProjectConfiguration, Components derived
from file sync, Problems produced by analyzers) should be established
by driving the real flow, not by calling a fixture.

### What's on the bridge today

| Category | Function |
|---|---|
| Sandbox | `setup_sandbox/1` |
| Session | `generate_user_session_token/1`, `select_active_account/2`, `select_active_project/2` |
| Environments | `memory_environment_fixture/1`, `register_environment/2`, `unregister_environment/1` |
| Users | `user_fixture/1`, `user_scope_fixture/{0,1,2,3}`, `full_scope_fixture/{0,1}` |
| Accounts | `account_fixture/1`, `account_with_owner_fixture/2`, `member_fixture/3` |
| Projects | `project_fixture/2` |
| Components | `component_fixture/2`, `get_component_by_module_name/2` |
| Stories | `story_fixture/2`, `set_story_component/3` |
| Sessions | `session_fixture/2` |
| Problems | `problem_fixture/2` |

### When to add to Fixtures

Before adding a function, ask:

1. Can the state be produced by driving the LiveView? (Preferred.)
2. Can it be produced by writing a file and letting sync run?
3. Is this state that server-side sync *would* populate in production?

If (1) or (2) works, use it. (3) is the justification for a new fixture
function. Adding a fixture for state the user would create locally
through the UI is a boundary violation disguised as a fixture.

## What a `then_` is allowed to read

- **Rendered HTML** — `render(view)`, `has_element?/2`,
  `element/2 |> render()`.
- **HTTP response body** — `json_response/2`, `response/2`, `redirected_to/2`.
- **Memfs state** — `Environments.read_file/2`,
  `Environments.file_exists?/2`, `Environments.list_directory/2`.
  (Only when the user-visible effect *is* a file on disk; e.g. "the
  spec generator wrote a spec file.")

What a `then_` is **not** allowed to do:

- Call context functions (`Stories.list_stories`,
  `Problems.list_problems`, etc.).
- Query `Repo` directly.
- Read from a fixture's underlying schema to prove the outcome.

This rule is why a memory-seeded problem in a `given_` still fails to
demonstrate the full contract — see the anti-pattern below.

## Anti-pattern: seeding server-side state that the agent should have produced

`5088_spex.exs` is the canonical example. The scenario is "exunit
failures outside the task's scope don't block the stop." The
*honest* flow is:

1. The agent writes a test file into the memfs.
2. The stop hook fires.
3. The pipeline runs `mix test`, produces an exunit problem on the
   untouched component.
4. The blocking check treats it as advisory because `block_changed`
   only blocks on touched components.

What 5088 actually does:

```elixir
given_ "an exunit failure exists on an untouched component", context do
  Fixtures.problem_fixture(context.scope, %{
    source: "exunit", source_type: :test, ...,
    component_id: context.component.id
  })
  {:ok, context}
end
```

It seeds a `Problem` row directly. The scenario still passes, but it
has stopped being an acceptance test — it's a unit test for the
blocking-decision function dressed up in Given-When-Then. If the
pipeline were broken such that it never persisted exunit problems at
all, this spec would still pass. That's the cost.

When to accept the shortcut: if (a) the pipeline interaction is
covered by a separate spec that *does* go end-to-end (see
`5087_spex.exs`, which uses an `ExCliVcr` cassette to exercise the
real pipeline), and (b) the scenario under test is about the
downstream decision, not the upstream production. Even then, leave a
module-level comment that calls the shortcut out explicitly — 5088's
moduledoc does this ("Exercises the blocking decision directly"). The
shortcut is a known debt, not a stealth change to the contract.

## Anti-pattern: direct DB reads in `then_`

```elixir
# WRONG
then_ "the configuration is saved", context do
  config = CodeMySpec.ProjectConfigurations.get!(context.project.id)
  assert config.require_specs == false
  :ok
end
```

This proves the DB row changed, not that the user's action had the
intended effect. Re-mount the LiveView (or assert against the form
state on the live view already in the context) and check what the
user sees.

```elixir
# RIGHT
then_ "require_specs renders unchecked on reload", context do
  {:ok, config_live, _html} =
    live(context.conn, ~p"/projects/#{context.project.name}/configuration")

  refute has_element?(config_live, "[data-test='require-specs']:checked")
  :ok
end
```

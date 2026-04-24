# Project Setup — Fixtures

Reference for `CodeMySpec.Support.SetupFixtures`, the helper that drives
an `InMemoryEnvironment` into a state where named setup step modules
evaluate `{:ok, :valid}`.

## Step → state required

All paths relative to `env.cwd`. Fixed `@app_name = "my_app"`,
`@app_mod = "MyApp"` across all fixtures.

| Step | Satisfying state |
|---|---|
| `ApplicationInWeb` | `lib/my_app_web/application.ex` exists |
| `CodemyspecDeps` | `mix.exs` contains `{:credo`, `{:client_utils`, `{:sobelow`, `{:sexy_spex`, `{:boundary` |
| `Compilers` | `mix.exs` matches `/compilers.*:boundary/s` AND `/compilers.*:spex/s` |
| `SpexConfig` | `mix.exs` matches `/spex:\s*:test/` |
| `TestBoundaries` | `test/support/my_app_spex.ex` and `test/support/my_app_test_boundary.ex` each contain `use Boundary` |
| `TestSupportNamespace` | `test/support/conn_case.ex` and `test/support/data_case.ex` either contain `defmodule MyAppTest.` OR are absent (missing = pass) |
| `SpexCase` | `test/support/my_app_spex_case.ex` contains `defmodule MyAppSpex.Case`, `use SexySpex`, `import Phoenix.LiveViewTest` |
| `ProjectStructure` | directories exist: `.code_my_spec/`, `.code_my_spec/rules/`, `.code_my_spec/spec/`, `.code_my_spec/spec/my_app/`, `.code_my_spec/spec/my_app_web/` |
| `IgnoredPaths` | `.code_my_spec/config.yml` parses as YAML with a non-empty `ignored_paths:` list |
| `AgentsMd` | `.code_my_spec/AGENTS.md` exists |
| `Rules` | `.code_my_spec/rules/` contains at least one `.md` file |
| `CredoChecks` | `.credo.exs` contains `credo_checks/framework` AND `credo_checks/local` AND `credo_checks/framework/checks.exs` |
| `ClaudeMd` | `CLAUDE.md` contains `<!-- code_my_spec:start -->` |

## Cross-cutting notes

### `mix.exs` is shared by three steps

`Helpers.extract_app_name/1` runs in six step modules; without `mix.exs`
containing `app: :my_app`, those steps short-circuit. The helper
**always writes a baseline `mix.exs`** on first call. `CodemyspecDeps`,
`Compilers`, and `SpexConfig` then **append string snippets**
idempotently.

The resulting `mix.exs` is not a compilable file — it's a regex-target
that satisfies the step evaluators. Fine for this use case. If we ever
need to actually `mix deps.get` or compile against the fixture, swap
the append strategy for a template.

### `InMemoryEnvironment` directory semantics

`file_exists?/2` returns true for any path that either exists as a file
OR has descendants (`in_memory_environment.ex:78-86`). To satisfy
`ProjectStructure`, write `.keep` files under the required directories
— no explicit directory creation needed.

### `TestSupportNamespace` passes when files are absent

The step evaluates `{:error, :enoent} -> true` inside an
`Enum.reject/2`, which means missing files are filtered out of the
"wrong" list. Default in-memory env state (no `conn_case.ex`, no
`data_case.ex`) satisfies the step. The helper's `satisfy_step/3` for
this step is a no-op.

To deliberately BREAK the step (for negative scenarios), write
`test/support/conn_case.ex` with `defmodule MyAppWeb.ConnCase`
(wrong namespace).

### `IgnoredPaths` runs `FileSync` + `ComponentSync` on evaluate

`evaluate/2` for this step is not pure — it triggers `FileSync.sync/1`
and `ComponentSync.sync_from_files/1` when the config is valid and the
scope has an `active_project_id`. **Intentional: we want specs to
exercise the full sync pipeline against the in-memory environment.**
No stubbing in the helper.

Implication: scenarios that satisfy `IgnoredPaths` will actually sync
files and components into the test DB for the fixture project. The DB
sandbox rolls back on scenario exit, so this is contained.

## How to break a step (for failure-path scenarios)

| Step | Break by |
|---|---|
| `ApplicationInWeb` | don't write `lib/my_app_web/application.ex` |
| `CodemyspecDeps` | omit the deps amendment (baseline mix.exs has empty deps) |
| `Compilers` | omit the compilers amendment |
| `SpexConfig` | omit the spex_config amendment |
| `TestBoundaries` | write the files without `use Boundary`, or don't write them |
| `TestSupportNamespace` | write `test/support/conn_case.ex` with wrong namespace |
| `SpexCase` | don't write `test/support/my_app_spex_case.ex`, or write it without the required substrings |
| `ProjectStructure` | don't write the `.keep` files |
| `IgnoredPaths` | don't write `.code_my_spec/config.yml`, or write it with an empty `ignored_paths:` list |
| `AgentsMd` | don't write `.code_my_spec/AGENTS.md` |
| `Rules` | don't write any `.md` file in `.code_my_spec/rules/` |
| `CredoChecks` | don't write `.credo.exs`, or write it missing one of the three required substrings |
| `ClaudeMd` | don't write `CLAUDE.md`, or write it without `<!-- code_my_spec:start -->` |

Default env state (fresh in-memory env, only baseline `mix.exs`) breaks
every step except `TestSupportNamespace`. The helper's default
behavior is "all broken except where satisfied by explicit call".

## Proposed helper

See `specs.md` for the invocation pattern. Location:
`test/support/setup_fixtures.ex`.

```elixir
defmodule CodeMySpec.Support.SetupFixtures do
  @moduledoc """
  Seeds an InMemoryEnvironment so named setup step modules evaluate
  `{:ok, :valid}`. Additive — `satisfy/3` can be called multiple times
  to simulate incremental completion.
  """

  alias CodeMySpec.AgentTasks.Setup
  alias CodeMySpec.Environments
  alias CodeMySpec.Environments.Environment

  @app_name "my_app"
  @app_mod "MyApp"

  @spec satisfy(Environment.t(), [module()]) :: :ok
  def satisfy(env, steps) do
    ensure_baseline_mix_exs(env)
    Enum.each(steps, &satisfy_step(env, &1))
    :ok
  end

  # Per-step clauses — see Step→state table above for file contents.
  defp satisfy_step(env, Setup.ApplicationInWeb),
    do: Environments.write_file(env, "lib/#{@app_name}_web/application.ex", "# stub\n")

  defp satisfy_step(env, Setup.CodemyspecDeps), do: amend_mix_exs(env, :deps)
  defp satisfy_step(env, Setup.Compilers), do: amend_mix_exs(env, :compilers)
  defp satisfy_step(env, Setup.SpexConfig), do: amend_mix_exs(env, :spex_config)

  defp satisfy_step(env, Setup.TestBoundaries) do
    Environments.write_file(env, "test/support/#{@app_name}_spex.ex",
      "defmodule #{@app_mod}Spex do\n  use Boundary\nend\n")
    Environments.write_file(env, "test/support/#{@app_name}_test_boundary.ex",
      "defmodule #{@app_mod}Test do\n  use Boundary\nend\n")
  end

  # Default state is satisfying — see "TestSupportNamespace passes when
  # files are absent" above.
  defp satisfy_step(_env, Setup.TestSupportNamespace), do: :ok

  defp satisfy_step(env, Setup.SpexCase) do
    Environments.write_file(env, "test/support/#{@app_name}_spex_case.ex", """
    defmodule #{@app_mod}Spex.Case do
      use SexySpex
      import Phoenix.LiveViewTest
    end
    """)
  end

  defp satisfy_step(env, Setup.ProjectStructure) do
    Environments.write_file(env, ".code_my_spec/rules/.keep", "")
    Environments.write_file(env, ".code_my_spec/spec/#{@app_name}/.keep", "")
    Environments.write_file(env, ".code_my_spec/spec/#{@app_name}_web/.keep", "")
  end

  defp satisfy_step(env, Setup.IgnoredPaths) do
    Environments.write_file(env, ".code_my_spec/config.yml",
      "ignored_paths:\n  - lib/#{@app_name}/repo.ex\n")
  end

  defp satisfy_step(env, Setup.AgentsMd),
    do: Environments.write_file(env, ".code_my_spec/AGENTS.md", "# Agents\n")

  defp satisfy_step(env, Setup.Rules),
    do: Environments.write_file(env, ".code_my_spec/rules/default.md", "# Rule\n")

  defp satisfy_step(env, Setup.CredoChecks) do
    Environments.write_file(env, ".credo.exs", """
    %{configs: [%{
      requires: [
        ".code_my_spec/credo_checks/framework/**/*.ex",
        ".code_my_spec/credo_checks/local/**/*.ex"
      ],
      checks: %{extra:
        if(File.exists?(".code_my_spec/credo_checks/framework/checks.exs"),
          do: elem(Code.eval_file(".code_my_spec/credo_checks/framework/checks.exs"), 0),
          else: [])
      }
    }]}
    """)
  end

  defp satisfy_step(env, Setup.ClaudeMd),
    do: Environments.write_file(env, "CLAUDE.md",
          "# CLAUDE\n<!-- code_my_spec:start -->\nmanaged\n<!-- code_my_spec:end -->\n")

  # --- mix.exs baseline + amendments ---

  defp ensure_baseline_mix_exs(env) do
    unless Environments.file_exists?(env, "mix.exs") do
      Environments.write_file(env, "mix.exs", """
      defmodule #{@app_mod}.MixProject do
        use Mix.Project
        def project, do: [app: :#{@app_name}, version: "0.0.1"]
        def application, do: []
        defp deps, do: []
      end
      """)
    end
  end

  defp amend_mix_exs(env, :deps) do
    append_if_missing(env, "mix.exs", "# amendment: deps", """

    # amendment: deps
    # {:credo, "~> 0.0"},
    # {:client_utils, "~> 0.0"},
    # {:sobelow, "~> 0.0"},
    # {:sexy_spex, "~> 0.0"},
    # {:boundary, "~> 0.0"},
    """)
  end

  defp amend_mix_exs(env, :compilers) do
    append_if_missing(env, "mix.exs", "# amendment: compilers",
      "\n# amendment: compilers: [:boundary, :spex]\n")
  end

  defp amend_mix_exs(env, :spex_config) do
    append_if_missing(env, "mix.exs", "# amendment: spex_config",
      "\n# amendment: cli preferred_envs: [spex: :test]\n")
  end

  defp append_if_missing(env, path, marker, snippet) do
    {:ok, content} = Environments.read_file(env, path)

    if String.contains?(content, marker),
      do: :ok,
      else: Environments.write_file(env, path, content <> snippet)
  end
end
```

## Deferred / known weak spots

- **mix.exs amendments are string-append hacks, not real Elixir.** Acceptable because no step tries to compile the file. If that changes, swap to a template.
- **`CredoChecks` fixture reproduces a nontrivial content block verbatim.** If the step's expected substrings drift, the fixture silently breaks. Accept for now.
- **`InMemoryEnvironment` doesn't implement `ensure_dir` beyond a no-op.** Fixtures rely on "file under path = path exists as dir" semantics. Confirmed behavior today, but it's load-bearing.

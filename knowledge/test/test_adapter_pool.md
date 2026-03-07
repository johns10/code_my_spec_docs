# Test Adapter & Repository Pool

CodeMySpec operates on real Elixir/Phoenix projects. Tests need a compilable project with deps, build artifacts, and git history. The TestAdapter and Pool system manages this efficiently.

## Overview

```
GitHub (one-time clone)
    |
    v
../code_my_spec_test_repos/test_phoenix_project/   <-- "golden" fixture
    |
    v  (rsync on first demand)
../code_my_spec_test_repos/pool_code_repo_1/        <-- pool copy
../code_my_spec_test_repos/pool_code_repo_2/        <-- pool copy
    |
    v  (checkout/checkin per test)
Test uses pool copy, checks it back in when done
```

## Initialization (test_helper.exs)

On test suite start:

```elixir
# 1. Clone fixture repos from GitHub (if not present), pull latest
CodeMySpec.Support.TestAdapter.ensure_fixture_fresh()

# 2. Start the pool GenServer
{:ok, _} = CodeMySpec.Support.TestAdapter.Pool.start_link()
```

`ensure_fixture_fresh/0` does:
1. Clones `test_phoenix_project` and `test_content_repo` from GitHub (first time only)
2. Pulls latest on subsequent runs
3. Installs deps (`mix deps.get`)
4. Generates and caches test results, compiler diagnostics, and spex results
5. Compiles dev environment for static analysis tools

## The Pool (GenServer)

**File:** `test/support/test_adapter/pool.ex`

Maintains two maps:
- `available` - Clean directories ready for checkout, keyed by repo type
- `checked_out` - Currently in-use directories

### Checkout

```elixir
{:ok, project_dir} = TestAdapter.clone(scope, @test_repo_url)
```

1. If a clean directory is available: reset git state, return it
2. If none available: `rsync -a` the golden fixture to `pool_code_repo_N/`, return it

The rsync copies everything: source, deps, `_build`, `.git`. Each copy is ~80MB but fully compiled and ready to use.

### Checkin

```elixir
on_exit(fn -> TestAdapter.checkin(project_dir) end)
```

1. Runs `git checkout .` and `git clean -fd` to reset all changes
2. Returns directory to the available pool for reuse

### Repo Types

- `:code_repo` - Phoenix project fixture (`test_phoenix_project`)
- `:content_repo` - Content/docs repo fixture (`test_content_repo`)

## Cached Build Artifacts

The TestAdapter pre-generates and caches expensive build outputs so tests don't need to compile or run real commands:

| Cache File | Contents |
|---|---|
| `compiler_ok_cache.json` | Clean compilation output |
| `compiler_warnings_cache.json` | Compilation with warnings |
| `compiler_errors_cache.json` | Compilation with errors |
| `test_results_cache.json` | Passing test results |
| `test_results_failing_cache.json` | Failing test results |
| `test_results_post_cache_failing_cache.json` | Post-cache failing tests |
| `spex_results_passing_cache.jsonl` | Passing BDD spex results |
| `spex_results_failing_cache.jsonl` | Failing BDD spex results |

Tests reference these via `TestAdapter.test_results_cache_path()`, `TestAdapter.compiler_ok_cache_path()`, etc.

### How Caches Are Generated

The `generate_*` functions in TestAdapter:
1. Copy a fixture source file (e.g., `test/fixtures/compiler/post_repository_warnings._ex`) into the test project
2. Run the relevant command (`mix compile`, `mix test`, `mix spex`)
3. Copy the output to the cache location
4. Remove the fixture file and clean up

This happens once. The `._ex` extension convention prevents fixture files from being compiled by the test suite itself.

## Writing a Test That Needs a Project

```elixir
defmodule MyFeatureTest do
  use CodeMySpec.DataCase, async: false
  use ExCliVcr

  alias CodeMySpec.Environments.Environment
  alias CodeMySpec.Support.TestAdapter

  import CodeMySpec.UsersFixtures

  @test_repo_url "https://github.com/Code-My-Spec/test_phoenix_project.git"

  setup do
    scope = full_scope_fixture()
    {:ok, project_dir} = TestAdapter.clone(scope, @test_repo_url)

    env = Environment.new(:local, project_dir)
    scope = %{scope | environment: env, cwd: project_dir}

    on_exit(fn -> TestAdapter.checkin(project_dir) end)

    %{scope: scope, project_dir: project_dir}
  end

  test "my feature works", %{scope: scope} do
    use_cmd_cassette "my_feature_test", ignore: [[:opts, :cd]] do
      # test code that runs mix commands against the project
    end
  end
end
```

## Key Points

- **Never delete pool directories** - use `checkin/1` so they can be reused
- **Always use `async: false`** when tests touch the filesystem or pool
- **Always use `ignore: [[:opts, :cd]]`** in cassettes since pool paths vary
- **Fixture source files use `._ex` extension** to avoid compilation
- **`@test_repo_url`** is the GitHub URL, but `TestAdapter.clone` uses the local pool (not a real network clone)

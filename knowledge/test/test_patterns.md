# Test Patterns & Conventions

## Test Case Templates

### DataCase - Database tests

```elixir
use CodeMySpec.DataCase, async: false
```

Provides: `Repo`, `Ecto.Changeset`, `Ecto.Query`, `errors_on/1` helper. Sets up SQL Sandbox for test isolation.

Use `async: false` when tests touch the filesystem, the pool, or shared state.

### ExUnit.Case - Standalone tests

```elixir
use ExUnit.Case, async: true
```

For tests that don't need the database. Can be async if they don't share filesystem state.

### ConnCase - Web/LiveView tests

```elixir
use CodeMySpecWeb.ConnCase
```

Provides `register_and_log_in_user/1`, `setup_active_account/1`, `setup_active_project/1` for building authenticated web test contexts.

## Standard Setup

### Full project test (most common for feature tests)

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

    %{scope: scope, env: env, project_dir: project_dir}
  end
end
```

### Lightweight setup (no fixture repo needed)

```elixir
setup do
  tmp_dir = Path.join(System.tmp_dir!(), "my_test_#{:erlang.unique_integer([:positive])}")
  File.mkdir_p!(tmp_dir)
  env = Environment.new(:local, tmp_dir)

  scope = %Scope{
    environment: env,
    active_project: project_fixture(user_scope_fixture()),
    active_project_id: project.id
  }

  on_exit(fn -> File.rm_rf!(tmp_dir) end)

  %{scope: scope, env: env}
end
```

### Session-based setup

```elixir
setup do
  tmp_dir = Path.join(System.tmp_dir!(), "session_test_#{:erlang.unique_integer([:positive])}")
  File.mkdir_p!(tmp_dir)
  {:ok, env} = CodeMySpec.Environments.create(:local, working_dir: tmp_dir)

  on_exit(fn -> File.rm_rf!(tmp_dir) end)

  %{env: env, tmp_dir: tmp_dir}
end
```

## Scope and Environment

### Scope

The `Scope` struct carries user context and working directory:

```elixir
%Scope{
  user: %User{},
  active_account: %Account{},
  active_account_id: "...",
  active_project: %Project{},
  active_project_id: "...",
  environment: %Environment{},
  cwd: "/path/to/project"       # Runtime concern, NOT persisted
}
```

**Important:** `full_scope_fixture()` and `user_scope_fixture()` do NOT set `cwd`. You must always add it manually:

```elixir
scope = %{scope | cwd: project_dir}
```

### Environment

```elixir
%Environment{
  type: :local,        # :cli | :local | :vscode
  cwd: "/path",        # Working directory
  ref: %{},            # Type-specific references
  metadata: %{}
}
```

Created via `Environment.new(:local, project_dir)` or `Environments.create(:local, working_dir: dir)`.

### Testing without filesystem access

To test the "no cwd" path, create a scope without setting cwd:

```elixir
test "returns false when scope has no cwd" do
  scope = user_scope_fixture(user, account, project)
  # No cwd set - defaults to nil
  assert MyModule.available?(scope) == false
end
```

## Recording Patterns

### CLI commands (most common)

```elixir
use ExCliVcr

test "my feature", %{scope: scope} do
  use_cmd_cassette "my_cassette_name", ignore: [[:opts, :cd]] do
    result = MyModule.run(scope)
    assert {:ok, _} = result
  end
end
```

Always use `ignore: [[:opts, :cd]]` - pool directories vary between runs.

### Timeouts for recorded tests

Tests that record or replay CLI commands often need longer timeouts:

```elixir
@tag timeout: 120_000   # 2 minutes
@tag timeout: 300_000   # 5 minutes (for multi-command pipelines)
```

### Using cached build output

For tests that need compiler/test results without running real commands:

```elixir
pipeline_opts = [
  compile_output_file: Path.join(System.tmp_dir!(), "compile_test.json"),
  test_output_file: Path.expand(TestAdapter.test_results_cache_path())
]
```

Available caches: `test_results_cache_path()`, `test_results_failing_cache_path()`, `compiler_ok_cache_path()`, `compiler_warnings_cache_path()`, `compiler_errors_cache_path()`, `spex_results_passing_cache_path()`, `spex_results_failing_cache_path()`.

## Assertion Patterns

### Problem structs

```elixir
assert {:ok, problems} = MyAnalyzer.run(scope)
assert is_list(problems)
Enum.each(problems, fn p -> assert %Problem{} = p end)
assert Enum.any?(problems, fn p -> p.source == "credo" end)
```

### Flexible result matching

When tests depend on external state (fixture repo contents), use flexible assertions:

```elixir
case result do
  {:error, problems} when is_list(problems) ->
    assert Enum.all?(problems, &match?(%Problem{}, &1))
  {:ok, :valid} ->
    assert true
end
```

Or:

```elixir
assert match?({:ok, :valid}, result) or match?({:error, _}, result)
```

### Changeset errors

```elixir
assert {:error, changeset} = MyContext.create(%{bad: "data"})
assert %{field_name: ["error message"]} = errors_on(changeset)
```

### File existence

```elixir
assert File.dir?(session_dir)
assert File.exists?(session_file)
refute File.exists?(deleted_path)
```

### JSON content

```elixir
json_content = File.read!(path)
assert {:ok, decoded} = Jason.decode(json_content)
assert decoded["type"] == "ComponentSpec"
```

## Web/LiveView Test Patterns

```elixir
defmodule MyLiveViewTest do
  use CodeMySpecWeb.ConnCase

  import Phoenix.LiveViewTest

  # Chain setup functions for progressive context building
  setup [:register_and_log_in_user, :setup_active_account, :setup_active_project]

  test "renders page", %{conn: conn, project: project} do
    {:ok, _view, html} = live(conn, ~p"/projects/#{project}")
    assert html =~ project.name
  end
end
```

## Cleanup Patterns

### Pool directories (prefer this)
```elixir
on_exit(fn -> TestAdapter.checkin(project_dir) end)
```

### Temp directories
```elixir
on_exit(fn -> File.rm_rf!(tmp_dir) end)
```

Never use `File.rm_rf!` on pool directories - use `checkin` so they can be reused.

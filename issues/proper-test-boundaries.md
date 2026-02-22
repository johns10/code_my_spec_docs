# Proper Test Boundaries Setup

## Problem

The setup-project skill instructs users to create test boundary modules with `check: [in: [:test], out: []]`, but Boundary 0.10.x expects booleans for `in` and `out`, not lists. This causes an `ArgumentError` at compile time.

Additionally, the setup doesn't account for:
- Phoenix's default `Application` module living under the domain namespace while referencing the web layer
- Test support modules (`DataCase`, `ConnCase`) being namespaced under domain/web boundaries instead of the test boundary
- Credo's `WrongTestFileExtension` check flagging boundary modules named `*_test.ex`

## Solution

### 1. Boundary module syntax

The `check` option must use booleans. Omit it entirely for default behavior:

```elixir
# test/spex/app_spex.ex
defmodule AppSpex do
  @moduledoc false
  use Boundary, top_level?: true, deps: [AppWeb]
end

# test/support/app_test_boundary.ex
defmodule AppTest do
  @moduledoc false
  use Boundary, top_level?: true, deps: [App, AppWeb]
end
```

### 2. File naming to avoid credo errors

Name the test boundary file `app_test_boundary.ex` (not `app_test.ex`) to avoid triggering `Credo.Check.Warning.WrongTestFileExtension`, which flags `.ex` files with `_test` suffix in the test directory.

### 3. Spex boundary should depend on AppWeb only

The spex boundary tests LiveViews and web-facing behavior. It should depend on `AppWeb` (which already depends on `App`), not `App` directly. The test boundary (`AppTest`) needs both `App` and `AppWeb` since `DataCase` and `ConnCase` live there.

### 4. Move Application to the web namespace

Phoenix generates `App.Application` which starts `AppWeb.Endpoint` and `AppWeb.Telemetry`. This creates a boundary violation since the domain layer shouldn't depend on the web layer. Move it:

- Rename `App.Application` to `AppWeb.Application`
- Move `lib/app/application.ex` to `lib/app_web/application.ex`
- Update `mix.exs`: `mod: {AppWeb.Application, []}`

### 5. Move test support modules to the test boundary namespace

Phoenix generates `App.DataCase` and `AppWeb.ConnCase` under domain/web namespaces, but they're test infrastructure. Rename them:

- `Fuellytics.DataCase` → `AppTest.DataCase` (stays in `test/support/data_case.ex`)
- `AppWeb.ConnCase` → `AppTest.ConnCase` (stays in `test/support/conn_case.ex`)
- Update all test files that `use AppWeb.ConnCase` or `use App.DataCase`

### 6. Top-level boundary declarations

```elixir
# lib/app.ex
defmodule App do
  use Boundary, deps: [], exports: []
end

# lib/app_web.ex
defmodule AppWeb do
  use Boundary, deps: [App], exports: []
end
```

## Impact on setup-project skill

The "Configure Test and Spex Boundaries" step should:

1. Drop the `check: [in: [:test], out: []]` syntax
2. Use `_boundary.ex` suffix for the test boundary file
3. Add `@moduledoc false` to both boundary modules
4. Add `use Boundary` to both `App` and `AppWeb` top-level modules
5. Move `App.Application` to `AppWeb.Application`
6. Rename `App.DataCase` → `AppTest.DataCase` and `AppWeb.ConnCase` → `AppTest.ConnCase`
7. Update all existing test file references

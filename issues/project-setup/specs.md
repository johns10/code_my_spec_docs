# Project Setup — Specs

Given/When/Then bodies for every scenario in `examples.md`. Assertion
surface is the LiveView at `/projects/:name/requirements/project_setup`,
which (post-refactor) renders `ProjectSetup.command/2` output.

## Test harness

- **Case template:** `use CodeMySpecLocalWeb.ConnCase`
- **LiveView helpers:** `import Phoenix.LiveViewTest`
- **Environment:** `CodeMySpec.Support.InMemoryEnvironment`
- **Scope wiring:** register the in-memory env per project via the
  environment registry so `Scope.for_local_project/1` (called by the
  LiveView) returns the same env the test seeded.

### Shared given (proposed)

Add to `test/support/shared_givens.ex`:

```elixir
given_ :project_with_in_memory_env, context do
  {:ok, env} = CodeMySpec.Support.InMemoryEnvironment.create(working_dir: "/memfs")
  project = project_fixture(%{local_path: "/memfs", name: "setup-spec"})
  CodeMySpec.Environments.register(project.id, env)
  on_exit(fn ->
    CodeMySpec.Environments.unregister(project.id)
    CodeMySpec.Support.InMemoryEnvironment.destroy(env)
  end)
  {:ok, Map.merge(context, %{env: env, project: project})}
end
```

### Fixture helper (proposed)

Add to `test/support/`:

```elixir
# Drives the in-memory env into a state where the named step modules
# evaluate `{:ok, :valid}`. Concentrates step-satisfaction knowledge
# so specs declare intent ("ApplicationInWeb + CodemyspecDeps done")
# rather than duplicating file layouts.
SetupFixtures.satisfy(env, [Setup.ApplicationInWeb, Setup.CodemyspecDeps])
```

---

## Rule: Setup is idempotent — re-running never undoes completed work

### Developer runs `command` on a fully-configured project and every step renders as checked

```elixir
scenario "fully-configured project renders every step checked", context do
  given_ :project_with_in_memory_env
  given_ "every setup step is satisfied", context do
    SetupFixtures.satisfy(context.env, ProjectSetup.setup_steps())
    :ok
  end

  when_ "developer views the project setup page", context do
    {:ok, view, _html} =
      live(context.conn, "/projects/#{context.project.name}/requirements/project_setup")
    {:ok, Map.put(context, :view, view)}
  end

  then_ "every step renders as checked", context do
    html = render(context.view)
    for mod <- ProjectSetup.setup_steps() do
      assert html =~ "[x] **#{ProjectSetup.step_name(mod)}**"
    end
    :ok
  end

  and_ "the progress header shows all steps done", context do
    assert render(context.view) =~ "Project Setup (13/13)"
    :ok
  end
end
```

### Developer completes an incomplete step and the re-rendered page shows it checked

```elixir
scenario "completing a step is reflected on re-render", context do
  given_ :project_with_in_memory_env
  given_ "all steps are satisfied except CodemyspecDeps", context do
    remaining = ProjectSetup.setup_steps() -- [Setup.CodemyspecDeps]
    SetupFixtures.satisfy(context.env, remaining)
    :ok
  end
  given_ "developer views the project setup page", context do
    {:ok, view, _html} =
      live(context.conn, "/projects/#{context.project.name}/requirements/project_setup")
    assert render(view) =~ "Project Setup (12/13)"
    assert render(view) =~ "[ ] **Codemyspec deps**"
    {:ok, Map.put(context, :view, view)}
  end

  when_ "developer satisfies CodemyspecDeps and reloads the page", context do
    SetupFixtures.satisfy(context.env, [Setup.CodemyspecDeps])
    {:ok, view, _html} =
      live(context.conn, "/projects/#{context.project.name}/requirements/project_setup")
    {:ok, Map.put(context, :view, view)}
  end

  then_ "the progress header shows all steps done", context do
    assert render(context.view) =~ "Project Setup (13/13)"
    :ok
  end

  and_ "Codemyspec deps is now checked", context do
    assert render(context.view) =~ "[x] **Codemyspec deps**"
    :ok
  end
end
```

---

## Rule: The prompt is self-contained — one agent, one prompt, no back-and-forth

### Multiple incomplete steps render inline prompts in a single page

```elixir
scenario "every incomplete step's full prompt is inlined on one page", context do
  given_ :project_with_in_memory_env
  given_ "ApplicationInWeb and CodemyspecDeps are satisfied; the rest are not", context do
    SetupFixtures.satisfy(context.env, [Setup.ApplicationInWeb, Setup.CodemyspecDeps])
    :ok
  end

  when_ "developer views the project setup page", context do
    {:ok, view, _html} =
      live(context.conn, "/projects/#{context.project.name}/requirements/project_setup")
    {:ok, Map.put(context, :view, view)}
  end

  then_ "the page contains the full inline prompt for every incomplete step", context do
    html = render(context.view)
    incomplete = ProjectSetup.setup_steps() -- [Setup.ApplicationInWeb, Setup.CodemyspecDeps]

    for mod <- incomplete do
      {:ok, step_prompt} = mod.command(context.scope_for(context.project), %{})
      first_distinctive_line = step_prompt |> String.split("\n", trim: true) |> hd()
      assert html =~ first_distinctive_line,
        "expected rendered page to inline prompt for #{inspect(mod)}"
    end
    :ok
  end
end
```

> Note: the `context.scope_for/1` helper recreates the LiveView's scope
> locally so the spec can compare against the step's real prompt output
> without re-implementing it. Assertion is still on rendered HTML — the
> scope is only used to compute expected strings.

---

## Rule: Order of step completion is not enforced

### Completing steps in reverse declaration order still renders as fully done

```elixir
scenario "reverse-order completion still lands on 13/13", context do
  given_ :project_with_in_memory_env
  given_ "no steps are satisfied", context do
    :ok
  end

  when_ "developer satisfies every step in reverse declaration order", context do
    reversed = Enum.reverse(ProjectSetup.setup_steps())
    for mod <- reversed, do: SetupFixtures.satisfy(context.env, [mod])
    :ok
  end

  then_ "the project setup page shows all steps done", context do
    {:ok, view, _html} =
      live(context.conn, "/projects/#{context.project.name}/requirements/project_setup")
    assert render(view) =~ "Project Setup (13/13)"
    :ok
  end
end
```

### Interleaved step completion still renders as fully done

```elixir
scenario "interleaved completion still lands on 13/13", context do
  given_ :project_with_in_memory_env
  given_ "no steps are satisfied", context do
    :ok
  end

  when_ "developer satisfies steps interleaved across two halves", context do
    {first_half, second_half} = Enum.split(ProjectSetup.setup_steps(), 7)
    Enum.zip(first_half ++ List.duplicate(nil, length(second_half) - length(first_half)), second_half)
    |> Enum.each(fn {a, b} ->
      if a, do: SetupFixtures.satisfy(context.env, [a])
      SetupFixtures.satisfy(context.env, [b])
    end)
    :ok
  end

  then_ "the project setup page shows all steps done", context do
    {:ok, view, _html} =
      live(context.conn, "/projects/#{context.project.name}/requirements/project_setup")
    assert render(view) =~ "Project Setup (13/13)"
    :ok
  end
end
```

---

## Rule: Completion is gated by every step evaluating `{:ok, :valid}`

### Every step valid — page shows all done

```elixir
scenario "every step valid renders 13/13", context do
  given_ :project_with_in_memory_env
  given_ "every setup step is satisfied", context do
    SetupFixtures.satisfy(context.env, ProjectSetup.setup_steps())
    :ok
  end

  when_ "developer views the project setup page", context do
    {:ok, view, _html} =
      live(context.conn, "/projects/#{context.project.name}/requirements/project_setup")
    {:ok, Map.put(context, :view, view)}
  end

  then_ "no incomplete steps appear", context do
    html = render(context.view)
    refute html =~ "[ ] **"
    :ok
  end
end
```

### One step incomplete — that step is unchecked and its prompt inlined

```elixir
scenario "one incomplete step is named and its prompt inlined", context do
  given_ :project_with_in_memory_env
  given_ "every step is satisfied except Rules", context do
    SetupFixtures.satisfy(context.env, ProjectSetup.setup_steps() -- [Setup.Rules])
    :ok
  end

  when_ "developer views the project setup page", context do
    {:ok, view, _html} =
      live(context.conn, "/projects/#{context.project.name}/requirements/project_setup")
    {:ok, Map.put(context, :view, view)}
  end

  then_ "the header shows 12/13", context do
    assert render(context.view) =~ "Project Setup (12/13)"
    :ok
  end

  and_ "Rules is the only unchecked step and its inline prompt is present", context do
    html = render(context.view)
    assert html =~ "[ ] **Rules**"
    {:ok, rules_prompt} = Setup.Rules.command(context.scope_for(context.project), %{})
    first_line = rules_prompt |> String.split("\n", trim: true) |> hd()
    assert html =~ first_line
    :ok
  end
end
```

### Multiple incomplete steps — all are listed as unchecked with their prompts inlined

```elixir
scenario "every incomplete step is named and its prompt inlined", context do
  given_ :project_with_in_memory_env
  given_ "Rules, CredoChecks, and ClaudeMd are unsatisfied; others are satisfied", context do
    incomplete = [Setup.Rules, Setup.CredoChecks, Setup.ClaudeMd]
    SetupFixtures.satisfy(context.env, ProjectSetup.setup_steps() -- incomplete)
    :ok
  end

  when_ "developer views the project setup page", context do
    {:ok, view, _html} =
      live(context.conn, "/projects/#{context.project.name}/requirements/project_setup")
    {:ok, Map.put(context, :view, view)}
  end

  then_ "the header shows 10/13", context do
    assert render(context.view) =~ "Project Setup (10/13)"
    :ok
  end

  and_ "each incomplete step renders as unchecked with its prompt inlined", context do
    html = render(context.view)
    for mod <- [Setup.Rules, Setup.CredoChecks, Setup.ClaudeMd] do
      name = ProjectSetup.step_name(mod)
      assert html =~ "[ ] **#{name}**"
      {:ok, prompt} = mod.command(context.scope_for(context.project), %{})
      first_line = prompt |> String.split("\n", trim: true) |> hd()
      assert html =~ first_line
    end
    :ok
  end
end
```

---

## Rule: Progress is visible in the prompt

### Partial progress shows accurate done/total header

```elixir
scenario "partial progress shows accurate (done/total)", context do
  given_ :project_with_in_memory_env
  given_ "three specific steps are satisfied", context do
    SetupFixtures.satisfy(context.env, [
      Setup.ApplicationInWeb,
      Setup.CodemyspecDeps,
      Setup.Compilers
    ])
    :ok
  end

  when_ "developer views the project setup page", context do
    {:ok, view, _html} =
      live(context.conn, "/projects/#{context.project.name}/requirements/project_setup")
    {:ok, Map.put(context, :view, view)}
  end

  then_ "the header reads Project Setup (3/13)", context do
    assert render(context.view) =~ "Project Setup (3/13)"
    :ok
  end
end
```

### Fully complete shows 13/13 with every step checked

```elixir
scenario "fully complete shows 13/13 with every step checked and no prompts", context do
  given_ :project_with_in_memory_env
  given_ "every setup step is satisfied", context do
    SetupFixtures.satisfy(context.env, ProjectSetup.setup_steps())
    :ok
  end

  when_ "developer views the project setup page", context do
    {:ok, view, _html} =
      live(context.conn, "/projects/#{context.project.name}/requirements/project_setup")
    {:ok, Map.put(context, :view, view)}
  end

  then_ "the header reads Project Setup (13/13)", context do
    assert render(context.view) =~ "Project Setup (13/13)"
    :ok
  end

  and_ "no incomplete prompt bodies are rendered", context do
    refute render(context.view) =~ "[ ] **"
    :ok
  end
end
```

### Completed step renders as `- [x] **Name**` with no prompt body

```elixir
scenario "a completed step renders as checked with no prompt body", context do
  given_ :project_with_in_memory_env
  given_ "only ApplicationInWeb is satisfied", context do
    SetupFixtures.satisfy(context.env, [Setup.ApplicationInWeb])
    :ok
  end

  when_ "developer views the project setup page", context do
    {:ok, view, _html} =
      live(context.conn, "/projects/#{context.project.name}/requirements/project_setup")
    {:ok, Map.put(context, :view, view)}
  end

  then_ "ApplicationInWeb renders as checked", context do
    html = render(context.view)
    assert html =~ "[x] **Application in web**"
    :ok
  end

  and_ "no inline prompt for ApplicationInWeb appears", context do
    {:ok, prompt} = Setup.ApplicationInWeb.command(context.scope_for(context.project), %{})
    first_distinctive_line = prompt |> String.split("\n", trim: true) |> hd()
    refute render(context.view) =~ first_distinctive_line
    :ok
  end
end
```

---

## Rule: Step command errors propagate to the caller

### Every step's command succeeds — page renders without error banner

```elixir
scenario "happy path renders without error banner", context do
  given_ :project_with_in_memory_env
  given_ "every setup step is satisfied", context do
    SetupFixtures.satisfy(context.env, ProjectSetup.setup_steps())
    :ok
  end

  when_ "developer views the project setup page", context do
    {:ok, view, _html} =
      live(context.conn, "/projects/#{context.project.name}/requirements/project_setup")
    {:ok, Map.put(context, :view, view)}
  end

  then_ "no setup-error banner is rendered", context do
    refute has_element?(context.view, "[data-role=setup-error]")
    :ok
  end
end
```

### A step's `command/2` errors — the page shows an error banner with the reason

```elixir
scenario "step command error surfaces as a page-level error banner", context do
  given_ :project_with_in_memory_env
  given_ "a setup step is injected that returns an error from `command/2`", context do
    # Install a one-test @setup_steps override (via Application env) that
    # replaces one step with a stub module whose `command/2` returns
    # `{:error, :explode}`. The stub's `evaluate/2` returns
    # `{:ok, :invalid, ...}` so the step renders as incomplete and the
    # error path fires when ProjectSetup tries to inline its prompt.
    SetupFixtures.inject_erroring_step!(:explode)
    :ok
  end

  when_ "developer views the project setup page", context do
    {:ok, view, _html} =
      live(context.conn, "/projects/#{context.project.name}/requirements/project_setup")
    {:ok, Map.put(context, :view, view)}
  end

  then_ "a setup-error banner is visible with the error reason", context do
    assert has_element?(context.view, "[data-role=setup-error]")
    assert render(context.view) =~ ":explode"
    :ok
  end
end
```

> Note: `SetupFixtures.inject_erroring_step!/1` requires either making
> `@setup_steps` overridable via Application env (small production
> change) or adding a test-only hook. Either is acceptable; pick the
> less-invasive option during implementation.

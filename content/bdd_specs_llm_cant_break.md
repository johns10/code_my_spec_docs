# How to write BDD specs the LLM can't break

_Part 2 of ["Preventing AI Slop in Elixir"](/blog/prevent-slop-elixir-codebases)._

---

Good requirements close the front gate. A sealed compile-time boundary closes the back gate. The engineering between them is the part nobody writes down.

## The validation problem

I've been wiring LLM agents into Phoenix apps for about a year. Generating code is the easy part. Validating the application does what you want is the hard part.

The easy answer is the verifications you already had: lint clean, types check, unit tests green, coverage up. None of that tells you whether the application does what it should.

That's the only question that matters. If your password reset flow worked yesterday and doesn't today, every other check can be green and you've still shipped a regression. Procedural validation has to anchor on behaviour through the user's surface, not on properties of the code itself. A bag of passing unit tests does not make a working application.

That's the job BDD specs do. They describe what the app should do in plain language, then exercise it through the actual surface of the application. The LLM ships a change, the specs run, and you find out within seconds whether the existing behaviour held.

For BDD specs to survive contact with an LLM, two things have to be true:

1. The specs encode the right behaviour. That means good requirements before any code or spec gets written.
2. The model cannot satisfy the specs dishonestly. That means designing the application's boundary deliberately and protecting it at compile time.

The rest of this article is the engineering process I use: requirements, boundary design, mechanical protection, writing specs against what you built.

## Step 1: good requirements

A BDD spec is only as good as the requirement it encodes. Ambiguous requirements give the LLM room to interpret in its own favour, and the spec ends up verifying the model's interpretation instead of the user's intent.

I use Three Amigos. It's one structured way to do good requirements collection. The principle matters more than the protocol:

- **Persona linkage.** The story attaches to a specific persona. "The driver" and "the fleet manager" generate different specs for the same feature.
- **Business rules and invariants.** One declarative sentence each.
- **Scenarios.** Concrete examples per rule. Given-When-Then, one behaviour per scenario.
- **Open questions.** The things the conversation surfaced that nobody can answer in the room. Park them. Send them back to the user.

The deliverable is a list of scenario titles a human approved. Whatever LLM generates Gherkin afterward anchors to that list, not to its own interpretation. Longer protocol writeup at [bdd_attention_three_amigos.md](/blog/bdd-attention-three-amigos).

## Step 2: leave the spec no room to cheat

Good requirements aren't enough. Even with the right scenario titles, the spec can pass dishonestly. Classic shape:

```elixir
# WRONG: spec proves a row changed, not that the user saw it.
then_ "the integration shows as connected", context do
  integration =
    MyApp.Integrations.get_integration!(context.scope, context.integration.id)

  assert integration.status == :connected
  :ok
end
```

Spec passes. User might still not see a connected integration on the page. The spec proved a database row changed, not that the user's experience changed.

Seal the spec namespace at compile time with [Boundary](https://hexdocs.pm/boundary/). A spec literally can't reach into the app to make that assertion. The compiler rejects it on every build.

```elixir
defmodule MyAppSpex do
  use Boundary,
    top_level?: true,
    deps: [
      MyApp.Environments,
      MyApp.McpServers,
      MyAppFixtures,
      MyAppWeb
    ]
end
```

What's absent: `MyApp` itself, `MyApp.Repo`, every context. If a spec tries to `alias MyApp.Integrations` or call `Integrations.get_integration/2`, `mix compile --warnings-as-errors` rejects it.

That deps list is the entire surface specs can reach into the app through. Designing that surface is critical to writing good BDD specs.

## Step 3: design the boundary of the application

This is the engineering thought process. Before you write a spec, before you write the Boundary declaration, map the application's actual interaction boundary.

Two halves to identify:

- **Inbound.** What exercises the application, and how. A human clicking through a LiveView. An LLM invoking an MCP tool. Another application posting to an HTTP endpoint. A scheduled job.
- **Outbound.** What the application calls. Third-party HTTP services. CLI shell-outs.

For each surface, pick one of three strategies:

- **Drive it directly.** The spec acts as that surface in test. Works for inbound surfaces the test framework can express against the production endpoint.
- **Record.** For outbound surfaces that talk to systems you don't control. First run hits the real boundary and saves the response. Replay fails on any call that wasn't captured.
- **Mock realistically.** For anything you can't call or record, provide a realistic mock that behaves similarly to production code.

Avoid mocks, especially model-authored mocks. A hand-rolled mock or Mox expectation is code the model can write to satisfy the spec without doing the production work. Recordings remove that opportunity. The model can't fabricate a third-party response the boundary didn't actually return.

Here's how it plays out on CodeMySpec:

**Inbound:**

| Surface | How it interacts | Strategy |
|---|---|---|
| Human engineer | Local Phoenix LiveView | Drive via `Phoenix.LiveViewTest` DSL |
| Cloud-side agent | MCP server tools | Drive via Anubis MCP test DSL |
| Coding agent (file writes) | Reads/writes working directory | In-memory filesystem implementation |
| Coding agent (stop hooks) | HTTP POST to `/api/hooks/*` | Drive via `Phoenix.ConnTest` |

**Outbound:**

| Surface | How the app calls | Strategy |
|---|---|---|
| Third-party HTTP (OAuth providers, etc.) | `Req` HTTP client | Record via `ReqCassette` |
| Production filesystem reads/writes | Reads/writes working directory | In-memory filesystem implementation |

In-memory filesystem on both sides because the abstraction is load-bearing in both directions. Production code writes through `Environments.write_file/3`; the in-memory implementation answers those calls in test. A code path that reaches `File.read!` directly fails the spec immediately because the in-memory environment has no answer for that call. The mock isn't a shortcut. It's the only way tests can honour the abstraction, which forces production code to use it consistently.

`ReqCassette` is a recording, not a mock. The cassette captures what the real OAuth provider returned the first time. On replay, the cassette fails if the production code makes a call that wasn't recorded, in the wrong order, or with different parameters. The model can't write a `Mox.expect` that quietly accepts any input. It makes the recorded calls or the spec fails.

Whatever your application looks like, the design output is a table like this one. Every inbound surface paired with a test DSL. Every outbound surface paired with a recording or behaviour-shaped fake. Once you have the table, the next step is to make it structural.

## Step 4: mechanical protection

Two pieces of project infrastructure enforce the design: the [Boundary](https://hexdocs.pm/boundary/) library and a small set of custom Credo rules.

### Boundary

The spec namespace's deps list is the design table compiled into Elixir:

```elixir
defmodule MyAppSpex do
  use Boundary,
    top_level?: true,
    deps: [
      MyApp.Environments,
      MyApp.McpServers,
      MyAppFixtures,
      MyAppWeb
    ]
end
```

Each entry maps to one row of the design table. `Environments` and `McpServers` are the agent surfaces. `MyAppWeb` is the human-engineer surface plus the HTTP hook endpoint. `MyAppFixtures` is the curated escape hatch for server-side state that has to exist before any user can act. It gets its own top-level Boundary:

```elixir
defmodule MyAppFixtures do
  use Boundary, top_level?: true, deps: [MyApp, MyAppTest]

  # --- Sandbox ----------------------------------------------------
  defdelegate setup_sandbox(tags), to: MyAppTest.DataCase

  # --- Users ------------------------------------------------------
  defdelegate user_fixture(attrs \\ %{}), to: MyApp.UsersFixtures
  defdelegate user_scope_fixture(), to: MyApp.UsersFixtures

  # --- Session tokens ---------------------------------------------
  defdelegate generate_user_magic_link_token(user), to: MyApp.UsersFixtures
end
```

`MyAppFixtures`, not `MyAppSpex.Fixtures`. The flat name signals it's a peer top-level Boundary, not namespaced inside the spec boundary. An engineer can open this file and eyeball the entire surface specs can reach for state. No hidden inheritance. No scattered helpers. One module, one list of `defdelegate` lines.

Three properties make it practical to keep tight:

**Driving the UI in shared setup is cheap.** A LiveView interaction in a spec is a function call against `Phoenix.LiveViewTest`, not browser automation. Replacing a fixture shortcut with a "register through the LiveView" shared given costs milliseconds.

**Paring fixtures down is free now.** Remove a function from `MyAppFixtures`. The next compile fails on the specs that used it. The model fixes those specs to drive the real surface instead. Labour is cheap with an LLM. The bottleneck was always reviewer attention. Cutting a fixture and letting compile errors fall out is a 30-second action that reshapes the spec boundary.

**The compiler tells you when a fixture is fighting the design.** If you're tempted to add a function that creates state the user should create through the UI, the rule says don't. Do it anyway, and the next time you delete it, the build will tell you exactly which specs were taking the shortcut.

### Credo rules

Boundary controls which modules a spec can call. Credo controls which patterns the model can reach for inside the modules it's allowed to call.

The custom Credo rules I apply inside the spec namespace:

- **Ban `File`.** Forces filesystem access through the in memory file system. 
- **Ban `Phoenix.PubSub.broadcast` and bare `send/2` inside spec setup.** Otherwise the model fakes state changes by broadcasting directly to a LiveView from a given step, skipping the real producer.
- **Ban `Mox`, `Mock`, and the literal string `mock`.** Mocks are a fresh cheating surface. If a spec needs an outbound boundary controlled, it uses a recording.
- **Ban any context module not on the spec boundary's deps list.** Boundary catches this at compile, but a Credo rule that flags it earlier in the editor speeds the feedback loop.

Each banned pattern is a path the model would otherwise discover the next time a spec is hard to make pass.

### Re-recording

Recordings drift when the third-party service changes its response shape, or when your outbound code path adds a new call. Delete the cassette, re-run with `record: :once`, commit the new version. A stale cassette is a slow leak. Make re-recording part of the regular cadence.

## Step 5: writing specs through the boundary

Design and mechanical protection are in place. A spec drops in at `test/spex/<story_id>/<criterion_id>_spex.exs`:

```elixir
defmodule MyAppSpex.Story42.Criterion101Spex do
  @moduledoc """
  Story 42: User connects Google Analytics
  Criterion 101: Connection shows as active after OAuth completes
  """

  use MyAppSpex.Case

  import_givens MyAppSpex.SharedGivens

  setup :register_log_in_setup_account

  spex "user connects Google Analytics" do
    scenario "post-authorize the integration card shows the property name" do
      given_ "the user is on the integrations page", context do
        {:ok, view, _html} = live(context.conn, ~p"/integrations")
        {:ok, Map.put(context, :view, view)}
      end

      when_ "the OAuth callback completes for property MyAccount.com", context do
        conn = OAuthHelpers.do_google_callback(context.conn, "ga_success")
        {:ok, view, _html} = live(conn, ~p"/integrations")
        {:ok, Map.put(context, :view, view)}
      end

      then_ "the integration card renders as connected with the property name",
            context do
        assert has_element?(
                 context.view,
                 "[data-test='integration-card-google-analytics']"
               )

        assert render(context.view) =~ "MyAccount.com"

        refute has_element?(
                 context.view,
                 "[data-test='integration-card-google-analytics'][data-status='disconnected']"
               )

        :ok
      end
    end
  end
end
```

Three things to notice. The `when_` step drives `do_google_callback`, which routes through the recorded `ReqCassette` for the OAuth provider's response. The `then_` step reads what the user sees: `has_element?/2` against the rendered DOM, `render(view) =~ "MyAccount.com"` against rendered text. No DB read. No context-function call. And the positive `assert` is an anchor that proves the page rendered at all, so the `refute` actually means something. Without an anchor, an empty response would pass every refute.

Cross-spec setup that recurs goes into `MyAppSpex.SharedGivens`:

```elixir
defmodule MyAppSpex.SharedGivens do
  use SexySpex.SharedGivens

  given :synced_context_component do
    env = context.environment

    :ok =
      Environments.write_file(env, "lib/example_context.ex", impl_file_content())

    {:ok, sync_live, _html} =
      live(context.conn, "/projects/#{context.project.name}/sync")

    sync_live |> element("button[phx-click='sync']") |> render_click()

    component =
      Fixtures.get_component_by_module_name(context.scope, "ExampleContext")

    {:ok, %{component: component}}
  end
end
```

Specs reach it as `given_ :synced_context_component`. The given establishes state by driving the real surface (a file write through the in-memory environment, a sync click against the real LiveView). Pattern-match failures blow up at the point of failure. The given itself never asserts. Assertions live in `then_`.

## What still leaks past the gate

Sealed boundary plus recorded outbound surface closes the per-story gate. It doesn't close every gate.

Cross-context integration bugs still ship past the spec layer. Accounts works, Cards works, Notifications works, and they break at the seams between them. Each spec covered one story. Nothing in the spec suite drives a cross-story journey.

That's where agentic QA picks up. Story QA tests one story at a time against the running application. Journey QA tests paths through the app that span multiple stories. On one project I built, an SMS verification feature passed 8 BDD scenarios and journey QA found a fraud surface anyway: the spec asserted the flag cleared after verification, and the model satisfied that by clearing the flag on link-open without requiring the verification work. The spec's definition of "verify" was too loose. Only a journey-level test caught it.

Sealed specs reduce how much QA has to catch. They don't eliminate it. The two together are the verification stack. The [agentic QA piece](/blog/agentic-qa) covers the second layer.

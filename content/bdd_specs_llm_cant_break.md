---
# Metadata for bdd_specs_llm_cant_break.md

# Required fields
slug: bdd-specs-llm-cant-break
type: blog
title: "How to write BDD specs the LLM can't break"

# Publishing control
protected: false
publish_at: 2026-06-01T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "How to write BDD specs the LLM can't break"
meta_description: "Phoenix BDD specs the LLM can't cheat past. Compile-time Boundary on the spec namespace plus Credo rules that close every shortcut."
og_title: "How to write BDD specs the LLM can't break"
og_description: "The engineering process for sealed BDD specs in Phoenix: design the boundary, enforce it with Boundary and Credo, drive every spec through the real user surface."
og_image: null

metadata:
  template: article
  author: John Davenport
  category: AI Development
  series: Preventing AI Slop in Elixir
  series_part: 2
  featured: true

tags:
  - elixir
  - phoenix
  - ai-coding
  - bdd
  - sealed-boundary
  - compile-time-checks
  - boundary
  - spex
  - verification
  - three-amigos
---

# How to write BDD specs the LLM can't break

_Part 2 of ["Preventing AI Slop in Elixir"](/blog/prevent-slop-elixir-codebases)._

---

## The validation problem

I've been wiring LLM agents into Phoenix apps for about a year. Agents generate code so fast that the bottleneck has become validation.

The only thing that makes sense is to procedurally validate as much as you can. Procedural validation is an engineering problem, and like all engineering problems, we must prioritize what to work on.

The top priority in software engineering is that the application works, and it does what the user wanted.

If your password reset flow worked yesterday and doesn't today, every other check can be green and you've still shipped a regression. Procedural validation has to anchor on behaviour from the users perspective, not on properties of the code itself. A bag of passing unit tests does not make a working application.

That's what BDD specs do. They describe what the app should do in plain language, then exercise it through the actual surface of the application. The LLM ships a change, the specs run, and you find out within seconds whether the existing behaviour held.

For BDD specs to survive contact with an LLM, two things have to be true:

1. The specs encode the right behaviour. That means having good requirements and designs before any code or spec gets written. Good luck if you're in corporate.
2. The model cannot satisfy the specs dishonestly. That means designing the application's boundary deliberately and protecting it at compile time.

The rest of this article is the engineering process I use: requirements, boundary design, mechanical protection, writing specs against what you built.

## Step 1: good requirements

A BDD spec is only as good as the requirement it encodes. Ambiguous requirements give the LLM room to interpret in its own favour, and the spec ends up verifying the model's interpretation instead of the user's intent.

I use Three Amigos. It's one structured way to do good requirements collection. The principle matters more than the protocol:

- **Persona linkage.** The story attaches to a specific persona. "The driver" and "the fleet manager" generate different specs for the same feature.
- **Business rules and invariants.** One declarative sentence stating the rules the code must implement.
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

In-memory filesystem on both sides because the abstraction is load-bearing in both directions. Production code writes through `Environments.write_file/3`; the in-memory implementation answers those calls in test. A code path that reaches `File.read!` directly fails the spec immediately because the in-memory environment has no answer for that call. The mock isn't a shortcut. It's the only way tests can honour the abstraction realistically, which forces production code to use it consistently.

`ReqCassette` is a recording, not a mock. The cassette captures what the real OAuth provider returned the first time. On replay, the cassette fails if the production code makes a call that wasn't recorded, in the wrong order, or with different parameters. The model can't write a `Mox.expect` that quietly accepts any input. It makes the recorded calls or the spec fails.

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

Each entry maps to an inbound or outbound surface. `Environments` and `McpServers` are the agent surfaces. `MyAppWeb` is the human-engineer surface plus the HTTP hook endpoint. `MyAppFixtures` is the curated escape hatch for server-side state that has to exist before any user can act. It gets its own top-level Boundary:

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

`MyAppFixtures` are a top-level Boundary that defines your spec's interface into your domain. An engineer can open this file and eyeball the entire surface specs can reach for in minutes.

Three properties make it practical to keep tight:

**Driving the UI in shared setup is cheap.** A LiveView interaction in a spec is a function call against `Phoenix.LiveViewTest`, not browser automation. Replacing a fixture shortcut with a "register through the LiveView" shared given costs milliseconds.

**Paring fixtures down is free now.** Remove a function from `MyAppFixtures`. The next compile fails on the specs that used it. The model fixes those specs to drive the real surface instead. Labour is cheap with an LLM. 

**The compiler tells you when a fixture is fighting the design.** If you're tempted to add a function that creates state the user should create through the UI, the rule says don't. Do it anyway, and the next time you delete it, the build will tell you exactly which specs were taking the shortcut.

### Credo rules

Boundary controls which modules a spec can call. Credo controls which patterns the model can reach for inside the modules it's allowed to call.

The custom Credo rules I apply to CodeMySpec:

- **Ban control flow** No `if`, `case`, `try` or `cond` in tests, ANYWHERE.
- **Ban `File`.** Forces filesystem access through the in memory file system. 
- **Ban `Phoenix.PubSub.broadcast` and bare `send/2` inside spec setup.** Otherwise the model fakes state changes by broadcasting directly to a LiveView from a given step, skipping the real producer.
- **Ban `Mox`, `Mock`, and the literal string `mock`.** Mocks are a fresh cheating surface. If a spec needs an outbound boundary controlled, it uses a recording.
- **Ban any context module not on the spec boundary's deps list.** Boundary catches this at compile, but a Credo rule that flags it earlier in the editor speeds the feedback loop.

Each banned pattern is a path the model would otherwise discover the next time a spec is hard to make pass.

### Re-recording

Recordings drift when the third-party service changes its response shape, or when your outbound code path adds a new call. Delete the cassette, re-run with `record: :once`, commit the new version. A stale cassette is a slow leak. Make re-recording part of the regular cadence.

## Step 5: writing specs through the boundary

Design and mechanical protection are in place. Here's an actual spec from the CodeMySpec test suite. Story 127 covers filesystem-to-DB projection: the agent writes a file into the project's working directory, sync flips a DB row, and the file shows up in the engineer's Files page. Criterion 5926 says: a spec file missing its required H1 title parses as invalid and renders an `invalid` badge on the matching row.

```elixir
defmodule CodeMySpecSpex.Story127.Criterion5926Spex do
  @moduledoc """
  Story 127 — Filesystem-to-DB Projection
  Criterion 5926 — Spec file with malformed structure is marked invalid
  with the parser error.
  """

  use CodeMySpecSpex.Case

  alias CodeMySpec.Environments

  @broken_spec_path ".code_my_spec/spec/broken_context.spec.md"

  setup :register_log_in_setup_account
  setup :setup_active_project

  spex "Engineer sees malformed specs flagged invalid in the projection" do
    scenario "spec missing the H1 title is marked invalid after sync" do
      given_ "the agent has written a spec file missing the required H1 title",
             context do
        :ok = Environments.write_file(context.environment, @broken_spec_path, broken_spec())
        {:ok, context}
      end

      when_ "the engineer triggers a sync from the Files page", context do
        {:ok, files_live, _html} =
          live(context.conn, "/projects/#{context.project.name}/files")

        files_live
        |> element("[data-test='sync-button']")
        |> render_click()

        {:ok, Map.put(context, :files_live, files_live)}
      end

      then_ "the broken spec row shows the invalid badge", context do
        assert has_element?(
                 context.files_live,
                 "[data-file-path=\"#{@broken_spec_path}\"] [data-validity='invalid']"
               )

        {:ok, context}
      end
    end
  end

  defp broken_spec, do: "## Type\n\ncontext\n\nA spec missing its H1 title.\n"
end
```

The spec exercises both users in one scenario. The `given_` step drives the **agent** surface: `Environments.write_file/3` writes a file into the in-memory environment. The `when_` step drives the **engineer** surface: mount the Files LiveView with `live/2`, click the sync button with `element/2 |> render_click/1`. The `then_` step reads what the engineer sees on the page after sync runs: `has_element?/2` against the rendered DOM with a `data-file-path` selector that points at the broken spec's row.

The whole spec routes through `Environments`, the LiveView, and the rendered HTML. If the production sync pipeline reaches `File.read!` directly or skips the projection step, this spec fails immediately

The `defp broken_spec` is a plain string helper. It lives inside the spec module because it isn't reusable state, just the test data for one criterion. Helpers like this are fine inside a spec; the boundary is about reaching into the application, not about expressing test inputs.

Setup that recurs across specs gets lifted into `MyAppSpex.SharedGivens`. CodeMySpec has one that mounts the configuration LiveView, used everywhere a spec needs to act as the engineer on the configuration page:

```elixir
register_given :on_configuration_page, context do
  {:ok, config_live, _html} =
    live(context.conn, "/projects/#{context.project.name}/configuration")

  {:ok, Map.put(context, :config_live, config_live)}
end
```

Specs reach it as `given_ :on_configuration_page` and pick up `context.config_live` for use in their `when_` step. The given establishes state by driving the real surface, returns a key the rest of the scenario uses, and never asserts. Pattern-match failures blow up at the point of failure. Assertions live in `then_`.

{{enforced_boundary_cta shape="aside" headline="A spec that reaches into the context proves a database row changed, not that the user saw it." sub="A convention cannot stop that. A compiler can." body="CodeMySpec seals the spec namespace with Boundary plus Credo rules, so the shortcut fails the build." label="Seal the boundary on your Phoenix app" campaign="bdd-specs-llm-cant-break"}}

## What still leaks past the gate

Sealed boundary plus recorded outbound surface closes the per-story gate. It doesn't close every gate.

Cross-context integration bugs still ship past the spec layer. Accounts works, Cards works, Notifications works, and they break at the seams between them. Each spec covered one story. Nothing in the spec suite drives a cross-story journey.

That's where agentic QA picks up. Story QA tests one story at a time against the running application. Journey QA tests paths through the app that span multiple stories. On one project I built, an SMS verification feature passed 8 BDD scenarios and journey QA found a fraud surface anyway: the spec asserted the flag cleared after verification, and the model satisfied that by clearing the flag on link-open without requiring the verification work. The spec's definition of "verify" was too loose. Only a journey-level test caught it.

Sealed specs reduce how much QA has to catch. They don't eliminate it. The two together are the verification stack. The [agentic QA piece](/blog/agentic-qa) covers the second layer.

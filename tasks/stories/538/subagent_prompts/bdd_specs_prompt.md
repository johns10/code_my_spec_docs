# Write BDD Specifications for Story

Create BDD specification files using the Spex DSL for the following story and its acceptance criteria.

## Story Context

**ID**: 538
**Title**: LLM Agent Autonomous Task Execution
**Description**: As the LLM agent, I receive tasks from the orchestrator, complete them, and am automatically directed to the next task so that I can work through the project requirements without user intervention.
**Priority**: 1

## Component Under Test

**Module**: `CodeMySpecLocalWeb.HookController`
**Type**: controller

## Acceptance Criteria

### Criterion 4954: Given I call the next-task endpoint, when there is an unsatisfied requirement with met prerequisites, then I receive a task description with a start-task link.

**Status**: ❌ MISSING
**Expected File Path**: `test/spex/538_llm_agent_autonomous_task_execution/criterion_4954_given_i_call_the_next-task_endpoint_when_there_is_an_unsatisfied_requirement_with_met_prerequisites_then_i_receive_a_task_description_with_a_start-task_link_spex.exs`

**Testing Approach for Controller (SURFACE LAYER):**
- **Test HTTP requests and responses** - not internal function calls
- Use the project's existing `CodeMySpecWeb.ConnCase` - do NOT create additional case files
- Use `get/3`, `post/3`, `put/3`, `delete/3` for requests
- Use plain string paths, not `~p` sigils
- Assert with `html_response/2`, `json_response/2`, `redirected_to/1`

```elixir
defmodule CodeMySpecSpex.FeatureNameSpex do
  use SexySpex
  use CodeMySpecWeb.ConnCase

  import_givens CodeMySpecSpex.SharedGivens
end
```


### Criterion 4955: Given I call the start-task endpoint, then the task is activated and I receive a prompt with instructions for completing the task.

**Status**: ❌ MISSING
**Expected File Path**: `test/spex/538_llm_agent_autonomous_task_execution/criterion_4955_given_i_call_the_start-task_endpoint_then_the_task_is_activated_and_i_receive_a_prompt_with_instructions_for_completing_the_task_spex.exs`

**Testing Approach for Controller (SURFACE LAYER):**
- **Test HTTP requests and responses** - not internal function calls
- Use the project's existing `CodeMySpecWeb.ConnCase` - do NOT create additional case files
- Use `get/3`, `post/3`, `put/3`, `delete/3` for requests
- Use plain string paths, not `~p` sigils
- Assert with `html_response/2`, `json_response/2`, `redirected_to/1`

```elixir
defmodule CodeMySpecSpex.FeatureNameSpex do
  use SexySpex
  use CodeMySpecWeb.ConnCase

  import_givens CodeMySpecSpex.SharedGivens
end
```


### Criterion 4956: Given I am working on an automatic-validation task, when I complete an action that satisfies the requirement, then the PostToolUse hook response tells me the task is complete and to stop.

**Status**: ❌ MISSING
**Expected File Path**: `test/spex/538_llm_agent_autonomous_task_execution/criterion_4956_given_i_am_working_on_an_automatic-validation_task_when_i_complete_an_action_that_satisfies_the_requirement_then_the_posttooluse_hook_response_tells_me_the_task_is_complete_and_to_stop_spex.exs`

**Testing Approach for Controller (SURFACE LAYER):**
- **Test HTTP requests and responses** - not internal function calls
- Use the project's existing `CodeMySpecWeb.ConnCase` - do NOT create additional case files
- Use `get/3`, `post/3`, `put/3`, `delete/3` for requests
- Use plain string paths, not `~p` sigils
- Assert with `html_response/2`, `json_response/2`, `redirected_to/1`

```elixir
defmodule CodeMySpecSpex.FeatureNameSpex do
  use SexySpex
  use CodeMySpecWeb.ConnCase

  import_givens CodeMySpecSpex.SharedGivens
end
```


### Criterion 4957: Given I stop after completing an automatic-validation task, when the stop hook evaluates my work as valid, then the stop is blocked and I am told to call next-task.

**Status**: ❌ MISSING
**Expected File Path**: `test/spex/538_llm_agent_autonomous_task_execution/criterion_4957_given_i_stop_after_completing_an_automatic-validation_task_when_the_stop_hook_evaluates_my_work_as_valid_then_the_stop_is_blocked_and_i_am_told_to_call_next-task_spex.exs`

**Testing Approach for Controller (SURFACE LAYER):**
- **Test HTTP requests and responses** - not internal function calls
- Use the project's existing `CodeMySpecWeb.ConnCase` - do NOT create additional case files
- Use `get/3`, `post/3`, `put/3`, `delete/3` for requests
- Use plain string paths, not `~p` sigils
- Assert with `html_response/2`, `json_response/2`, `redirected_to/1`

```elixir
defmodule CodeMySpecSpex.FeatureNameSpex do
  use SexySpex
  use CodeMySpecWeb.ConnCase

  import_givens CodeMySpecSpex.SharedGivens
end
```


### Criterion 4958: Given I stop after completing an automatic-validation task, when the stop hook evaluates my work as invalid, then the stop is blocked and I receive feedback on what to fix.

**Status**: ❌ MISSING
**Expected File Path**: `test/spex/538_llm_agent_autonomous_task_execution/criterion_4958_given_i_stop_after_completing_an_automatic-validation_task_when_the_stop_hook_evaluates_my_work_as_invalid_then_the_stop_is_blocked_and_i_receive_feedback_on_what_to_fix_spex.exs`

**Testing Approach for Controller (SURFACE LAYER):**
- **Test HTTP requests and responses** - not internal function calls
- Use the project's existing `CodeMySpecWeb.ConnCase` - do NOT create additional case files
- Use `get/3`, `post/3`, `put/3`, `delete/3` for requests
- Use plain string paths, not `~p` sigils
- Assert with `html_response/2`, `json_response/2`, `redirected_to/1`

```elixir
defmodule CodeMySpecSpex.FeatureNameSpex do
  use SexySpex
  use CodeMySpecWeb.ConnCase

  import_givens CodeMySpecSpex.SharedGivens
end
```


### Criterion 4959: Given I am working on a manual-validation task, when I stop, then the stop is allowed (the user will evaluate).

**Status**: ❌ MISSING
**Expected File Path**: `test/spex/538_llm_agent_autonomous_task_execution/criterion_4959_given_i_am_working_on_a_manual-validation_task_when_i_stop_then_the_stop_is_allowed_the_user_will_evaluate_spex.exs`

**Testing Approach for Controller (SURFACE LAYER):**
- **Test HTTP requests and responses** - not internal function calls
- Use the project's existing `CodeMySpecWeb.ConnCase` - do NOT create additional case files
- Use `get/3`, `post/3`, `put/3`, `delete/3` for requests
- Use plain string paths, not `~p` sigils
- Assert with `html_response/2`, `json_response/2`, `redirected_to/1`

```elixir
defmodule CodeMySpecSpex.FeatureNameSpex do
  use SexySpex
  use CodeMySpecWeb.ConnCase

  import_givens CodeMySpecSpex.SharedGivens
end
```


### Criterion 4960: Given I stop and the task passes, when there are no more actionable requirements, then the stop is allowed and the user is notified.

**Status**: ❌ MISSING
**Expected File Path**: `test/spex/538_llm_agent_autonomous_task_execution/criterion_4960_given_i_stop_and_the_task_passes_when_there_are_no_more_actionable_requirements_then_the_stop_is_allowed_and_the_user_is_notified_spex.exs`

**Testing Approach for Controller (SURFACE LAYER):**
- **Test HTTP requests and responses** - not internal function calls
- Use the project's existing `CodeMySpecWeb.ConnCase` - do NOT create additional case files
- Use `get/3`, `post/3`, `put/3`, `delete/3` for requests
- Use plain string paths, not `~p` sigils
- Assert with `html_response/2`, `json_response/2`, `redirected_to/1`

```elixir
defmodule CodeMySpecSpex.FeatureNameSpex do
  use SexySpex
  use CodeMySpecWeb.ConnCase

  import_givens CodeMySpecSpex.SharedGivens
end
```


### Criterion 4961: Given there are active sub-agent tasks on the session, when I stop, then the stop is allowed (sub-agents are still working).

**Status**: ❌ MISSING
**Expected File Path**: `test/spex/538_llm_agent_autonomous_task_execution/criterion_4961_given_there_are_active_sub-agent_tasks_on_the_session_when_i_stop_then_the_stop_is_allowed_sub-agents_are_still_working_spex.exs`

**Testing Approach for Controller (SURFACE LAYER):**
- **Test HTTP requests and responses** - not internal function calls
- Use the project's existing `CodeMySpecWeb.ConnCase` - do NOT create additional case files
- Use `get/3`, `post/3`, `put/3`, `delete/3` for requests
- Use plain string paths, not `~p` sigils
- Assert with `html_response/2`, `json_response/2`, `redirected_to/1`

```elixir
defmodule CodeMySpecSpex.FeatureNameSpex do
  use SexySpex
  use CodeMySpecWeb.ConnCase

  import_givens CodeMySpecSpex.SharedGivens
end
```


## Controller Testing Guide

This is a Controller. **Test at the SURFACE layer** using `Phoenix.ConnTest`.

### Key Principles

- **Test HTTP requests and responses** - what users/clients send and receive
- **Assert on response bodies** - HTML content, JSON payloads
- **Assert on status codes** - 200, 201, 302, 404, etc.
- **DON'T call context functions or fixtures** - all state setup through HTTP

### Required Setup

**IMPORTANT**: Use the project's existing `CodeMySpecWeb.ConnCase` module. Do NOT create additional
case files, and do NOT manually set `@endpoint` or `setup do` blocks for conn - `ConnCase`
already provides these.

```elixir
defmodule CodeMySpecSpex.FeatureNameSpex do
  use SexySpex
  use CodeMySpecWeb.ConnCase

  import_givens CodeMySpecSpex.SharedGivens
```

**Note:** Use plain strings for paths (e.g., `"/api/resource"`) instead of the `~p` sigil
to avoid dependencies on `Phoenix.VerifiedRoutes`.

### Controller Testing Patterns

**Making GET requests:**
```elixir
when_ "user visits the page", context do
  conn = get(context.conn, "/api/resource")
  Map.put(context, :conn, conn)
end
```

**Making POST requests:**
```elixir
when_ "user submits data", context do
  conn = post(context.conn, "/api/resource", %{name: "Test"})
  Map.put(context, :conn, conn)
end
```

**Asserting HTML response:**
```elixir
then_ "user sees the page", context do
  assert html_response(context.conn, 200) =~ "Welcome"
  :ok
end
```

**Asserting JSON response:**
```elixir
then_ "API returns the data", context do
  assert %{"id" => _, "name" => "Test"} = json_response(context.conn, 200)
  :ok
end
```

**Asserting redirects:**
```elixir
then_ "user is redirected to dashboard", context do
  assert redirected_to(context.conn) == "/dashboard"
  :ok
end
```

### Complete Example

```elixir
defmodule CodeMySpecSpex.ResourceManagementSpex do
  use SexySpex
  use CodeMySpecWeb.ConnCase

  import_givens CodeMySpecSpex.SharedGivens

  spex "Resource management" do
    scenario "user creates resource successfully", context do
      when_ "user submits valid data", context do
        conn = post(context.conn, "/api/resources", %{
          resource: %{name: "Test Resource"}
        })
        Map.put(context, :conn, conn)
      end

      then_ "API returns created resource", context do
        # Assert on what the CLIENT RECEIVES - the JSON response
        assert %{"id" => id, "name" => "Test Resource"} = json_response(context.conn, 201)
        assert is_binary(id)
        :ok
      end
    end
  end
end
```


## Shared Givens

Shared givens allow reusable setup steps across specs. The shared givens file is at:
`test/support/shared_givens.ex`

### Current Shared Givens Content

```elixir
defmodule CodeMySpecSpex.SharedGivens do
  @moduledoc """
  Shared given steps for BDD specifications.

  Import these givens in your spec files:

      defmodule CodeMySpecSpex.FeatureNameSpex do
        use SexySpex
        import_givens CodeMySpecSpex.SharedGivens.SharedGivens
        # ...
      end

  Add new shared givens here when you find yourself duplicating setup code
  across multiple specs. Remember: spex files can only access the Web layer,
  so shared givens should set up state through UI interactions, not fixtures.
  """

  use SexySpex.Givens

  # Example shared given that sets up state through UI:
  #
  # given_ :user_registered, context do
  #   conn = Phoenix.ConnTest.build_conn()
  #   {:ok, view, _html} = Phoenix.LiveViewTest.live(conn, "/users/register")
  #
  #   view
  #   |> Phoenix.LiveViewTest.form("#registration-form", user: %{
  #     email: "test#{System.unique_integer()}@example.com",
  #     password: "ValidPassword123!"
  #   })
  #   |> Phoenix.LiveViewTest.render_submit()
  #
  #   {:ok, %{}}
  # end
end

```

### Using Shared Givens

To use shared givens in your spec file:

```elixir
defmodule CodeMySpecSpex.FeatureNameSpex do
  use SexySpex
  import_givens CodeMySpecSpex.SharedGivens.SharedGivens

  spex "feature" do
    scenario "test case" do          # No context parameter on scenario
      given_ :user_registered        # Shared given - sets up state through UI
      given_ "specific setup", context do  # Inline given takes context when needed
        Map.put(context, :extra, true)
      end
      # ...
    end
  end
end
```

### When to Add Shared Givens

**Only add new shared givens if**:
- You find yourself duplicating the same UI setup code across multiple specs
- The setup is generic enough to be reused (e.g., "user is registered", "user is on dashboard")

**Do NOT add shared givens for**:
- One-off, scenario-specific setup
- Setup that includes criterion-specific data

**Remember**: Shared givens must set up state through the UI (LiveViewTest/ConnTest),
not by calling context functions or fixtures directly.

If you add a new shared given, update the `test/support/shared_givens.ex` file with the new definition.

## Testing Layer Guidelines

**IMPORTANT**: Write specs at the SURFACE layer, not the domain layer.

BDD specs should test user-facing behavior through the UI, not internal function calls.

| Component Type | Testing Approach |
|----------------|------------------|
| LiveView (`*Web.*Live.*`) | `Phoenix.LiveViewTest` - mount, render, interact, assert HTML |
| Controller (`*Web.*Controller`) | `Phoenix.ConnTest` - HTTP requests and responses |
| Context (domain modules) | Only if explicitly testing pure business logic without UI |
| Schema | Changeset validation tests |

### Surface Testing Principles

- **Test what users SEE and DO** - not internal function calls
- **Assert on HTML content** - text, elements, attributes users interact with
- **Test user interactions** - form submissions, button clicks, navigation
- **Assert on flash messages and redirects** - the feedback users receive
- **Avoid calling context functions directly** - go through the UI layer

For `*Web.*` modules, ALWAYS use LiveViewTest or ConnTest to simulate real user interactions.

## Spex DSL Syntax Guide

Spex is a BDD framework for Elixir that uses Given/When/Then steps to describe behavior.

### Key Points

1. **Module naming**: Use `CodeMySpecSpex.FeatureNameSpex` convention (all specs under `CodeMySpecSpex` boundary)
2. **import_givens**: Import shared given definitions from `CodeMySpecSpex.SharedGivens`
3. **spex macro**: Wraps all scenarios for a feature
4. **scenario macro**: Defines a specific test case. Context is implicitly available inside - do NOT pass it as a parameter.
5. **given_/when_/then_ macros**: Define steps. Pass `context` when you need to read or update it.

### Context Availability

- `context` is automatically available inside every scenario (from ExUnit setup)
- Steps that need context take it as a parameter: `given_ "desc", context do`
- Steps that don't need context omit it: `then_ "desc" do`
- If a step takes context but doesn't use it, prefix with underscore: `given_ "desc", _context do`

### Step Return Values

**IMPORTANT**: Steps must return specific values to update context correctly:

- `given_` and `when_` steps that update context: Return `{:ok, updated_map}`
- `given_` and `when_` steps that don't update context: Return `:ok`
- `then_` steps: Return `:ok` after assertions
- Returning a bare map raises `ArgumentError` — always wrap in `{:ok, map}`

```elixir
given_ "user navigates to registration", context do
  {:ok, view, _html} = live(context.conn, "/users/register")
  {:ok, Map.put(context, :view, view)}
end

then_ "user sees welcome message", context do
  assert render(context.view) =~ "Welcome"
  :ok
end
```

## Instructions

**IMPORTANT: Write ONE spec file at a time, then STOP and wait for validation feedback.**

Do not write multiple spec files in a single pass. Write one, let it be validated, fix any
issues, then proceed to the next. This prevents cascading errors across multiple files.

For each criterion:
1. Create the spec file at the path specified
2. **All spec modules must be under the `CodeMySpecSpex` namespace** (e.g., `CodeMySpecSpex.UserRegistrationSpex`)
3. **Write actual test implementations** - NO TODOs or placeholder comments
4. **Surface layer ONLY** - Do NOT call context functions, fixtures, or factories. All state setup must go through the UI.
5. Use the testing patterns shown above for controller components
6. Run `mix compile` to verify the spec compiles correctly
7. **STOP and wait for validation** before writing the next spec
8. Fix any validation errors before proceeding

Reference files:
- Boundary definition: `test/spex/code_my_spec_spex.ex`
- Shared givens: `test/support/shared_givens.ex`

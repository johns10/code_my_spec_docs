
### Side Quest 3A: "Session Orchestration: Automating the Design → Test → Code Workflow"

**Prerequisites**: Main Quest Post 3 (1:1:1 rule) and side quests 1A, 2A
**Target audience**: Advanced users ready for workflow automation
**Length:** 3000-3500 words
**Channel:** dev.to, r/elixir, your blog

#### Content Outline

**Hook:**
- "After writing 50+ design documents and prompting AI 50+ times..."
- "I automated the entire workflow"
- "Now AI walks through the steps systematically"

**The Problem:**
- Manual prompting is repetitive
- Easy to skip steps
- No enforcement of process
- Hard to resume if interrupted
- Each developer prompts differently

**Session Orchestration:**
- Break workflow into discrete steps
- Each step has clear inputs/outputs
- State machine enforces order
- Can pause and resume
- Audit trail of all steps

**The Workflow as State Machine:**
```
:initializing
    ↓
:reading_design
    ↓
:generating_tests
    ↓
:awaiting_test_review (human gate)
    ↓
:generating_implementation
    ↓
:running_tests
    ↓
:fixing_failures (loop if needed)
    ↓
:awaiting_final_review (human gate)
    ↓
:completed
```

**Implementation in Phoenix:**

**Session Schema:**
```elixir
schema "coding_sessions" do
  field :phase, Ecto.Enum, values: [
    :initializing,
    :reading_design,
    :generating_tests,
    # ... all phases
  ]
  field :context, :map  # Accumulated context
  field :results, :map  # Results from each phase
  belongs_to :task, Task
end
```

**State Machine Logic:**
```elixir
defmodule CodingSessions do
  def start_session(task_id) do
    session = %Session{
      task_id: task_id,
      phase: :initializing,
      context: %{},
      results: %{}
    }
    |> Repo.insert!()

    advance_phase(session)
  end

  def advance_phase(%Session{phase: :initializing} = session) do
    # Load design document
    design = load_design(session.task_id)

    session
    |> update_context(:design, design)
    |> transition_to(:generating_tests)
  end

  def advance_phase(%Session{phase: :generating_tests} = session) do
    # Call AI to generate tests from design
    tests = generate_tests_via_ai(session.context.design)

    session
    |> update_results(:tests, tests)
    |> transition_to(:awaiting_test_review)
  end

  def advance_phase(%Session{phase: :awaiting_test_review} = session) do
    # Human approval required - wait
    {:ok, session}
  end

  # ... other phase handlers
end
```

**Approval Gates:**
```elixir
def approve_tests(session_id, approved: true) do
  session = get_session!(session_id)

  if session.phase == :awaiting_test_review do
    advance_phase(session |> transition_to(:generating_implementation))
  else
    {:error, "Not in test review phase"}
  end
end
```

**How AI Interacts:**

Instead of human prompting AI each step, AI is given session tools via MCP:

```
AI: [calls get_session_status(session_id)]
    "Session in phase: :generating_implementation"
    "Design document: [...]"
    "Tests already generated: [...]"

AI: [generates implementation based on context]

AI: [calls submit_implementation(session_id, code)]
    "Implementation submitted, advancing to :running_tests"

AI: [calls run_tests(session_id)]
    "Tests failed: [failures]"

AI: [calls fix_failures(session_id, fixes)]
    "Fixes applied, rerunning tests"

AI: [calls run_tests(session_id)]
    "All tests passing, advancing to :awaiting_final_review"
```

**Context Accumulation:**
Each phase adds to shared context:
```elixir
%{
  design: "...",          # From :reading_design
  tests: "...",           # From :generating_tests
  implementation: "...",  # From :generating_implementation
  test_results: %{},      # From :running_tests
  failures: [],           # From failed test runs
  fixes: []               # From :fixing_failures
}
```

**Error Recovery:**
```elixir
def handle_test_failure(session) do
  retry_count = session.results[:retry_count] || 0

  cond do
    retry_count >= 5 ->
      # Escalate to human
      transition_to(session, :awaiting_human_intervention)

    true ->
      # Try fixing again with accumulated failure context
      session
      |> update_results(:retry_count, retry_count + 1)
      |> transition_to(:fixing_failures)
  end
end
```

**Multi-Agent Coordination:**
Different agents can work on different phases:
- Design Agent: Writes design documents
- Test Agent: Generates tests from design
- Code Agent: Implements based on tests
- Review Agent: Analyzes failures

**Observability:**
```elixir
# Dashboard shows all active sessions
def list_active_sessions do
  Session
  |> where([s], s.phase not in [:completed, :failed])
  |> preload(:task)
  |> Repo.all()
end

# Detailed session view
def get_session_timeline(session_id) do
  Session
  |> preload(:state_transitions)
  |> Repo.get!(session_id)
end
```

**Phoenix LiveView Dashboard:**
- Real-time session status updates via PubSub
- Approval buttons for human gates
- View accumulated context
- See AI reasoning at each step

**Integration with MCP Servers:**
Session tools exposed via MCP so AI can drive the workflow:
- `get_session_status` - What phase am I in?
- `submit_implementation` - Here's my code
- `run_tests` - Run tests for this phase
- `request_approval` - Ask human to review

**What This Enables:**
- Consistent workflow execution
- Can pause/resume work
- Multiple sessions in parallel
- Audit trail of AI decisions
- Enforce human approval gates
- Recover from failures gracefully

**Comparison:**

Manual prompting:
- ✅ Simple, full control
- ✅ Learn the process
- ❌ Repetitive
- ❌ Easy to skip steps
- ❌ Hard to resume

Session orchestration:
- ✅ Consistent process
- ✅ Automatic step enforcement
- ✅ Pause/resume
- ✅ Audit trail
- ❌ Complex to build
- ❌ Requires infrastructure

**When to Build This:**
- Generating code for dozens of components
- Multiple AI agents working
- Need consistency across team
- Want approval gates enforced
- Need observability

**OTP Patterns:**
```elixir
# Each session is a GenServer
defmodule Session.Worker do
  use GenServer

  def start_link(session_id) do
    GenServer.start_link(__MODULE__, session_id, name: via(session_id))
  end

  def init(session_id) do
    session = load_session(session_id)
    {:ok, session, {:continue, :advance}}
  end

  def handle_continue(:advance, session) do
    case advance_phase(session) do
      {:ok, updated_session} -> {:noreply, updated_session}
      {:wait, updated_session} -> {:noreply, updated_session}
      {:error, reason} -> {:stop, reason, session}
    end
  end
end

# Supervised by dynamic supervisor
defmodule Session.Supervisor do
  use DynamicSupervisor

  def start_session(task_id) do
    session = create_session(task_id)
    DynamicSupervisor.start_child(__MODULE__, {Session.Worker, session.id})
  end
end
```

**Call to Action:**
- Try manual workflow first (Main Quest Post 4)
- When you're doing it repeatedly, consider orchestration
- Start simple: Just track phases
- Add approval gates gradually
- Share your orchestration patterns

**Product Reveal:**
> This session orchestration is the core of CodeMySpec. Combined with the Stories and Components MCP servers, it creates a complete AI-assisted development workflow: [link to Side Quest 4A]

#### Source Material
- Your session implementation
- State machine patterns
- OTP supervision
- Phoenix LiveView dashboard

#### Success Metrics
- "This is what I need" comments
- Questions about state management
- Others building similar systems
- Phoenix OTP pattern discussions

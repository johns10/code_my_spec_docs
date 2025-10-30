# Campaign 5: The Journey Series - "How I Learned to Control AI Code Generation"

## Objective

Tell the authentic story of discovering and refining design-driven AI development through a series of educational posts that teach the manual process first, then show how each tedious part was automated. Position the product as the natural evolution of proven techniques rather than a theoretical solution.

## Philosophy

**Main Quest + Side Quests Structure**

- **Main Quest Posts**: Teach the manual process anyone can do today with just markdown files and AI chat
- **Side Quest Posts**: Show the automation for those ready to go deeper (MCP servers, Phoenix architecture, session orchestration)
- **Product Emergence**: CodeMySpec revealed as the culmination of automating all the tedious parts

**Key Principle**: Give away the process completely. If readers do it manually forever, they still get massive value. Those who want automation will naturally seek it out.

## Timeline

8 weeks for complete series (4 main quest + 4 side quests)
Alternating weekly: Main Quest → Side Quest → Main Quest → Side Quest...

## Why This Works

### For Beginners
- Follow main quest only
- Immediately actionable (create markdown files today)
- Never need the product to succeed
- Build trust through education

### For Advanced Users
- Speed-run main quest
- Dive into technical side quests
- Learn MCP, Phoenix, agent architecture
- Decide: build their own or use CodeMySpec

### For You
- Authentic story demonstrates expertise
- Educational content builds authority
- Product reveal feels inevitable, not salesy
- Side quests = Campaign 2 (MCP education) content
- Main quests = Campaign 4 (Process documentation) content

---

## Main Quest: The Manual Process

### Main Quest Post 1: "I Use a Markdown File to Keep AI Focused on Requirements"

**Target audience:** Anyone frustrated with AI wandering off-spec
**Length:** 1500-1800 words
**Channel:** r/elixir, dev.to, your blog

#### Content Outline

**Hook (First 2 paragraphs):**
- "After watching Claude generate 500 lines of code I didn't ask for..."
- The problem: AI makes assumptions, wanders, forgets context
- "I started keeping a single markdown file with all my requirements"

**The Problem:**
- AI chat has no memory beyond conversation
- Copy-pasting context is tedious
- Requirements drift as conversations grow
- Team members can't see what AI is working from

**My Solution: user_stories.md**
```markdown
# My Project

## User Story 1: Authentication
As a user, I want to log in...

**Acceptance Criteria:**
- Email/password authentication
- Session management
- Password reset flow
```

**How I Use It:**
- One file, version controlled
- Paste relevant sections to AI before asking for code
- Update as requirements evolve
- Team has single source of truth
- AI can't make up requirements that aren't documented

**Show Real Example:**
- Reference your actual user_stories.md
- Pick 2-3 stories
- Show before/after: AI output without stories vs with stories
- Demonstrate how quality improves

**Making It Work:**
- Start simple: Just title and acceptance criteria
- Add detail as you discover it
- Don't over-engineer at first
- Version control is critical
- Keep it readable (you'll reference it constantly)

**The Technique:**
```
Step 1: Create requirements.md (or user_stories.md)
Step 2: Write stories in simple format
Step 3: When prompting AI: "Here are the requirements: [paste]"
Step 4: AI stays focused on documented requirements
Step 5: Update file as requirements evolve
```

**What This Enables:**
- Consistent context for all AI interactions
- Requirements traceability
- Team alignment
- Foundation for everything else

**Transition:**
- "This works great, but copy-pasting gets tedious..."
- "I eventually automated this (I'll share how in next post)"
- "But start here - the manual process teaches you what matters"

**Call to Action:**
- Create your requirements.md today
- Try it for one feature
- Share your experience in comments
- "What format works for you?"

**Side Quest Teaser:**
> If you find the copy-pasting tedious, check out "Building an MCP Server So AI Can Access Stories Directly" [link to Side Quest 1A when published]

#### Source Material
- `/docs/user_stories.md` (your actual file)
- Your experience using it manually before building automation
- Comparison: AI output quality before vs after using structured requirements

#### Success Metrics
- 50+ upvotes on Reddit
- 20+ comments with people trying it
- "I'm going to try this" responses
- Saved/bookmarked for reference
- Questions about specific techniques

---

### Main Quest Post 2: "How I Map Requirements to Phoenix Contexts in a Markdown File"

**Target audience:** Phoenix developers managing multiple contexts
**Length:** 1800-2200 words
**Channel:** r/elixir, dev.to, your blog

#### Content Outline

**Hook:**
- "After I had 30 user stories documented, I needed to organize them..."
- "Which context does this belong in?"
- "AI kept suggesting poor context boundaries"

**The Problem:**
- User stories don't map directly to code structure
- AI doesn't understand Phoenix context principles
- Need architectural view before coding
- Team needs shared understanding of boundaries

**My Solution: context_mapping.md**
- Maps user stories to contexts
- Documents context responsibilities
- Explicit dependency tracking
- Single architecture document

**Show Real Example:**
```markdown
## Projects Context
**Type**: Domain Context
**Entity**: Project
**Responsibilities**: Project CRUD, configuration
**Dependencies**: None
**Stories**: 1.1, 1.2, 1.3
```

**How I Use It:**
- Read through user_stories.md
- Group by entity ownership first
- Identify coordination contexts
- Document dependencies explicitly
- Review before any coding starts

**Phoenix Context Principles:**
- One entity per domain context
- Coordination contexts orchestrate, don't own
- Flat structure (no nested contexts)
- Clear boundaries prevent coupling

**The Mapping Process:**
```
Step 1: Read all user stories
Step 2: Identify entities (nouns that need persistence)
Step 3: Group stories by entity ownership
Step 4: Identify coordination needs
Step 5: Document dependencies
Step 6: Review for circular dependencies
```

**Why This Matters:**
- AI can generate code aligned with architecture
- Team sees system structure upfront
- Prevents context boundary violations
- Makes refactoring safer

**When to Do This:**
- After user stories are relatively stable
- Before any serious coding begins
- Update as architecture evolves
- Review with team before implementation

**Common Mistakes:**
- Too many small contexts (over-fragmentation)
- Contexts that depend on each other circularly
- Mixing domain and coordination in one context
- Not documenting dependencies explicitly

**How I Prompt AI With This:**
```
"Here's the context mapping: [paste relevant sections]
Generate code for the Projects context following Phoenix conventions.
Projects depends on: [list dependencies]
Projects is a domain context owning the Project entity."
```

**Transition:**
- "This mapping file became critical for keeping AI architecturally aligned"
- "Eventually I built tooling to help AI query this (next side quest)"
- "But the manual process teaches you good architecture"

**Call to Action:**
- After you have user_stories.md, create context_mapping.md
- Map stories to contexts
- Review with team
- Use it to guide AI code generation

**Side Quest Teaser:**
> For managing complex component dependencies, check out "Building an MCP Server for Component Architecture Tracking" [link to Side Quest 2A]

#### Source Material
- `/docs/context_mapping.md` (your actual file)
- Phoenix documentation on contexts
- Your experience doing this mapping manually
- Examples of good vs poor context boundaries

#### Success Metrics
- Referenced by others asking about Phoenix architecture
- Saved for reference
- Questions about specific mapping decisions
- "This clarified contexts for me" comments

---

### Main Quest Post 3: "The 1:1:1 Rule: One Design Doc Per Code File Per Test File"

**Target audience:** Developers using AI for code generation
**Length:** 2000-2500 words
**Channel:** r/elixir, dev.to, your blog

#### Content Outline

**Hook:**
- "After mapping stories to contexts, I still had a problem..."
- "AI generated code that worked but didn't match my mental model"
- "I discovered a simple pattern: document the design before generating code"

**The Problem:**
- AI generates working code with wrong architecture
- Hard to review AI-generated code for architectural fit
- No reference point for "is this right?"
- Tests generated from same flawed understanding

**The 1:1:1 Principle:**
```
Phoenix Convention: One test file per code file
Design-Driven Extension: One design document per code file per test file

docs/design/sessions/orchestrator.md          # Design document
lib/code_my_spec/sessions/orchestrator.ex     # Implementation
test/code_my_spec/sessions/orchestrator_test.exs # Tests
```

**Why This Works:**
- Design document = structured reasoning for AI
- Tests validate implementation matches design
- Traceability: design → code → tests
- Reference point when things don't work

**What Goes In a Design Document:**
```markdown
# Component: Sessions.Orchestrator

## Purpose
Coordinates multi-step coding sessions with approval gates

## Public API
- start_session(session_type, context) :: {:ok, Session.t()}
- advance_phase(session, input) :: {:ok, Session.t()} | {:error, reason}

## Dependencies
- Sessions.Repository
- Agents.Client
- Tasks.Context

## State Machine
:initializing → :gathering_context → :generating_design → ...

## Design Decisions
- Why GenServer: Need stateful process per session
- Why supervised: Sessions can crash and restart
- Why phases: Human approval gates between critical steps
```

**How I Write Design Docs:**
1. Start with purpose (one sentence)
2. Define public API (what other code calls)
3. List dependencies (what this calls)
4. Document key design decisions
5. Include state machines if relevant
6. Note error handling approach

**How I Use Them With AI:**
```
Prompt: "Here's the design document for Sessions.Orchestrator: [paste]
Generate the implementation following this design.
Ensure all public API functions are implemented.
Follow the state machine transitions exactly."
```

**The Test-Design Connection:**
- Tests validate design is implemented correctly
- When tests fail, compare to design (not guess)
- Design is the contract tests verify
- Update design if requirements change

**Comparison to No Design Docs:**

Without design:
- AI generates "working" code with questionable architecture
- Hard to review without reference
- Tests validate wrong behavior
- Technical debt accumulates silently

With design:
- AI generates code matching explicit architecture
- Easy to review (does it match design?)
- Tests validate design is met
- Changes require design updates (deliberate)

**Making It Practical:**
- Don't design everything upfront
- Design one component, implement, learn
- Refine design template as you go
- Some components need more detail than others
- Templates help (context design vs schema design)

**The Traceability Chain:**
```
User Story
    ↓
Context Mapping
    ↓
Component Design Document
    ↓
Implementation + Tests
    ↓
Working Code
```

**When Design Needs to Change:**
- Update design document first
- Regenerate implementation
- Tests fail = implementation doesn't match design
- Tests pass = design is implemented correctly

**Transition:**
- "This process works incredibly well but is tedious"
- "Write design, prompt AI, review, iterate"
- "I eventually automated the orchestration (see side quest)"

**Call to Action:**
- Pick one component to design
- Write design doc before prompting AI
- Generate implementation from design
- Compare quality to design-free approach
- Share your experience

**Side Quest Teaser:**
> I automated this entire workflow with session orchestration. Read about it here: [link to Side Quest 3A]

#### Source Material
- `/docs/resources/design_driven_code_generation.md` (simplified, focused version)
- Your actual design documents
- Before/after examples of AI output
- Phoenix conventions + design-driven extension

#### Success Metrics
- "This changed how I work with AI" comments
- Readers sharing their design doc formats
- Questions about specific design patterns
- Saved/bookmarked as reference
- Featured in ElixirWeekly

---

### Main Quest Post 4: "How I Actually Use Design Documents to Guide AI Code Generation"

**Target audience:** Developers ready for complete walkthrough
**Length:** 2500-3000 words
**Channel:** r/elixir, dev.to, your blog

#### Content Outline

**Hook:**
- "Let me walk you through my complete workflow"
- "From user story to passing tests"
- "Using only markdown files and Claude/ChatGPT"

**Complete Example:**

**Starting Point:**
```markdown
# User Story 2.2: User Story Management
As a PM, I want to edit generated user stories so I can refine them.

**Acceptance Criteria:**
- Stories are fully editable (title, description, criteria)
- Users can add, modify, or remove stories
- System tracks changes
- Changes trigger regeneration workflow
```

**Step 1: Context Mapping**
```markdown
## Stories Context
**Type**: Domain Context
**Entity**: Story
**Responsibilities**: Story CRUD, editing, change tracking
**Dependencies**: None
```

**Step 2: Component Design**
```markdown
# Stories Context

## Purpose
Manages user story lifecycle including CRUD operations and change tracking

## Public API
```elixir
def create_story(attrs)
def update_story(story, attrs)
def delete_story(story)
def list_stories(project_id)
```

## Schema
```elixir
schema "stories" do
  field :title, :string
  field :description, :text
  field :acceptance_criteria, :string
  field :dirty, :boolean, default: false
  belongs_to :project, Project
end
```

## Change Tracking
When story updated:
- Set dirty: true
- Broadcast :story_updated event
- Downstream artifacts marked for regeneration
```

**Step 3: Prompt AI**
```
I'm building a Phoenix application. Here's the design for the Stories context: [paste design]

Generate:
1. lib/my_app/stories.ex (context module)
2. lib/my_app/stories/story.ex (schema)
3. test/my_app/stories_test.exs (tests)

Follow Phoenix conventions. Ensure all public API functions in design are implemented.
```

**Step 4: Review Generated Code**
- Does implementation match design?
- Are all public API functions present?
- Does schema match design?
- Are dependencies correct?

**Step 5: Run Tests**
```bash
mix test test/my_app/stories_test.exs
```

**Step 6: Fix Issues**
If tests fail, prompt with failure context:
```
The test failed with this error: [paste]

Here's the design document: [paste]

The implementation doesn't match the design because [explain issue].
Fix the implementation to match the design.
```

**Step 7: Integration**
After tests pass:
```bash
git add .
git commit -m "Add Stories context per design"
```

**The Complete Workflow:**
```
1. Start with user story (from stories.md)
2. Identify context (from context_mapping.md)
3. Write component design document
4. Prompt AI with design
5. Review generated code against design
6. Run tests
7. Fix failures with design as reference
8. Commit when tests pass
```

**Key Prompting Patterns:**

For context generation:
```
Here's the context design: [paste]
Generate the context module following Phoenix conventions.
Include all public API functions from the design.
```

For schema generation:
```
Here's the schema design: [paste]
Generate the schema with all fields, relationships, and validations.
```

For tests:
```
Here's the component design: [paste]
Generate comprehensive tests covering:
- All public API functions
- Happy paths and error cases
- Edge cases mentioned in design
```

For fixes:
```
Test failure: [paste failure]
Component design: [paste design]
Fix the implementation to match the design.
```

**What I Learned:**

**Good Prompts:**
- Include complete design document
- Specify Phoenix conventions
- Be explicit about dependencies
- Reference design when fixing

**Bad Prompts:**
- "Build a stories feature" (too vague)
- "Fix the test" (no design reference)
- "Make it work" (no architectural guidance)

**Design Quality Matters:**
- Vague design → vague code
- Explicit design → explicit code
- Design gaps become code gaps
- Update design if requirements change

**When This Breaks Down:**
- Design is too vague (add detail)
- Dependencies not clear (update design)
- AI doesn't understand Elixir patterns (provide examples)
- Tests fail repeatedly (review design, might be wrong)

**Transition to Automation:**
- "After doing this 50+ times, I automated it"
- "The manual process taught me what matters"
- "Automation preserves the principles"

**Call to Action:**
- Try complete workflow for one feature
- Create all three artifacts (story, mapping, design)
- Generate code from design
- Share your results
- "What worked? What was hard?"

**Product Reveal Teaser:**
> After months of this process, I built CodeMySpec to automate the tedious parts while preserving human control at decision points. Read about it here: [link to Side Quest 4A]

#### Source Material
- Your actual user_stories.md
- Your actual context_mapping.md
- Real examples from your codebase
- Your actual prompts and workflows

#### Success Metrics
- "I tried this, here's what happened" comments
- Readers sharing their workflows
- Questions about specific steps
- GitHub repos showing the approach
- Conference talk interest

---

## Side Quests: The Automation

### Side Quest 1A: "I Built an MCP Server So AI Can Access Stories Directly"

**Prerequisites**: Main Quest Post 1 (markdown file approach)
**Target audience**: Readers who tried Post 1 and want automation
**Length:** 2500-3000 words
**Channel:** dev.to, r/elixir, your blog

#### Content Outline

**Hook:**
- "After copy-pasting from user_stories.md 100+ times..."
- "I built an MCP server so AI can query stories directly"
- "No more copy-paste, AI has live access"

**The Problem with Manual:**
- Copy-pasting is tedious
- Stories file grows large (what to paste?)
- Multiple team members = coordination issues
- Changes require re-pasting
- Can't update stories from AI conversation

**What is MCP:**
- Model Context Protocol (Anthropic)
- Standard for AI-to-tool communication
- Works with Claude Desktop and Claude Code
- Better than APIs: structured tool calling

**My MCP Server: stories-server**

**Architecture:**
```
Claude Desktop/Code
       ↓
  MCP Protocol
       ↓
Phoenix Application
       ↓
Stories Context → Database
```

**Tools Exposed:**
- `list_stories` - AI can browse all stories
- `get_story` - AI can read specific story
- `create_story` - AI can add stories from conversation
- `update_story` - AI can refine stories
- `search_stories` - AI can find relevant stories

**Implementation Walkthrough:**

Show actual code from `stories_server.ex`:
```elixir
defmodule CodeMySpec.MCPServers.StoriesServer do
  use Hermes.Server,
    name: "stories-server",
    version: "1.0.0",
    capabilities: [:tools]

  component(CodeMySpec.MCPServers.Stories.Tools.CreateStory)
  component(CodeMySpec.MCPServers.Stories.Tools.ListStories)
  # ... other tools
end
```

**How It Works:**
1. Phoenix app exposes MCP server
2. Claude Desktop connects to server
3. AI can call tools during conversation
4. Tools query Stories context
5. Results returned to AI
6. AI uses context to inform responses

**The Conversation Flow:**

Before (manual):
```
Me: "Generate code for this feature"
    [paste 50 lines from stories.md]
AI: "Here's the code..."
```

After (MCP):
```
Me: "Generate code for user authentication"
AI: [calls list_stories tool with filter: "authentication"]
    [reads story 1.3: "As a user, I want to log in..."]
    "Based on story 1.3, here's the code..."
```

**Building an MCP Server in Phoenix:**

**Step 1: Define tools**
```elixir
defmodule ListStories do
  use Hermes.Tool

  def definition do
    %{
      name: "list_stories",
      description: "List user stories for a project",
      parameters: %{
        project_id: %{type: "integer", required: true}
      }
    }
  end

  def execute(%{project_id: project_id}) do
    stories = Stories.list_stories(project_id)
    {:ok, format_stories(stories)}
  end
end
```

**Step 2: Register with server**
```elixir
defmodule StoriesServer do
  use Hermes.Server

  component(ListStories)
  component(GetStory)
  component(CreateStory)
end
```

**Step 3: Configure Claude Desktop**
```json
{
  "mcpServers": {
    "stories-server": {
      "url": "http://localhost:4000/mcp",
      "headers": {
        "Authorization": "Bearer <token>"
      }
    }
  }
}
```

**Authentication & Security:**
- OAuth2 for agent access
- Scope to user's projects
- Rate limiting
- Audit trail of AI actions

**Multi-tenancy:**
```elixir
def execute(%{project_id: id}, %{scope: scope}) do
  # Scope contains authenticated user/account
  with :ok <- authorize(scope, id),
       stories <- Stories.list_stories(scope, id) do
    {:ok, format_stories(stories)}
  end
end
```

**What This Enables:**
- AI has live access to requirements
- No copy-pasting
- AI can create/update stories from conversation
- Team works from same database
- Audit trail of AI changes

**Comparison:**

Manual approach:
- ✅ Simple, no code needed
- ✅ Learn the process
- ❌ Tedious copy-pasting
- ❌ Stories get stale
- ❌ No audit trail

MCP approach:
- ✅ No copy-pasting
- ✅ Live data
- ✅ AI can update stories
- ✅ Audit trail
- ❌ Requires Phoenix app
- ❌ More complex setup

**When to Build This:**
- You've done manual approach and hit friction
- Multiple team members need access
- Stories change frequently
- Want AI to help refine stories
- Building Phoenix application anyway

**Resources:**
- [Link to MCP documentation]
- [Link to Hermes library]
- [Link to your GitHub repo with example]

**Call to Action:**
- Try manual approach first
- When it gets tedious, consider MCP
- Start with read-only tools (list/get)
- Add write tools when comfortable
- Share your MCP server implementations

**Next Side Quest Teaser:**
> I also built an MCP server for component architecture. It helps AI understand context boundaries: [link to Side Quest 2A]

#### Source Material
- `/lib/code_my_spec/mcp_servers/stories_server.ex`
- Your actual tools implementations
- MCP documentation
- Hermes library documentation

#### Success Metrics
- GitHub stars on example repo
- "I built my own version" posts
- Questions about specific implementation
- MCP community discussion
- Referenced in MCP examples

---

### Side Quest 2A: "Building an MCP Server for Component Architecture Tracking"

**Prerequisites**: Main Quest Post 2 (context mapping) and Side Quest 1A (MCP basics)
**Target audience**: Teams managing complex Phoenix applications
**Length:** 2500-3000 words
**Channel:** dev.to, r/elixir

#### Content Outline

**Hook:**
- "After context_mapping.md grew to 200+ lines..."
- "AI kept suggesting dependencies that violated boundaries"
- "I built an MCP server to help AI understand architecture"

**The Problem:**
- Context mapping file gets large
- Dependencies complex to track
- AI doesn't understand architectural constraints
- Hard to detect circular dependencies
- Component changes = ripple effects

**My Solution: components-server**

**What It Exposes:**
- `list_components` - AI sees all contexts
- `get_component` - Details about specific context
- `get_dependencies` - What this depends on
- `get_dependents` - What depends on this
- `analyze_impact` - Impact of changing this component
- `validate_dependency` - Is this dependency allowed?

**Architecture Tracking:**
```elixir
%Component{
  name: "Stories",
  type: :context,
  responsibilities: "Story CRUD, editing, change tracking",
  dependencies: [],
  public_functions: ["create_story/1", "update_story/2"],
  entity: "Story"
}
```

**Dependency Validation:**
```elixir
# AI wants to make this call:
# Stories.get_story() calls Agents.assign_task()

# AI calls validate_dependency:
validate_dependency("Stories", "Agents")
→ {:error, "Stories (domain context) cannot depend on Agents (domain context)"}

# AI learns: need coordination context between them
```

**Graph Analysis:**
```elixir
def detect_circular_deps(component_name) do
  graph = build_dependency_graph()
  case Graph.find_cycle(graph, component_name) do
    nil -> {:ok, "No circular dependencies"}
    cycle -> {:error, "Cycle detected: #{inspect(cycle)}"}
  end
end
```

**How AI Uses This:**

Conversation:
```
AI: "I'll implement the story assignment feature"
AI: [calls get_component("Stories")]
    "Stories is a domain context owning Story entity"
AI: [calls get_dependencies("Stories")]
    "Stories has no dependencies"
AI: [calls validate_dependency("Stories", "Agents")]
    "Error: Invalid dependency - Stories cannot call Agents directly"
AI: "We need a coordination context. I'll create StoriesAssignment
     coordinator that calls both Stories and Agents."
```

**The Conversation is Architecturally Aware:**
- AI checks component type before suggesting changes
- AI validates dependencies before generating code
- AI suggests coordination contexts when needed
- AI understands boundaries

**Implementation Deep Dive:**

**Component Registry:**
```elixir
defmodule Components.Registry do
  def register_component(attrs) do
    component = %Component{
      name: attrs.name,
      type: attrs.type,  # :context, :repository, :schema, :liveview
      dependencies: attrs.dependencies,
      rules: load_rules_for_type(attrs.type)
    }
    # Store in database
  end
end
```

**Dependency Rules by Type:**
```elixir
def allowed_dependencies(:context, :context) do
  # Domain contexts can call other contexts carefully
  {:ok, "Allowed but should be minimized"}
end

def allowed_dependencies(:context, :repository) do
  {:error, "Contexts should not call repositories directly"}
end

def allowed_dependencies(:liveview, :context) do
  {:ok, "LiveViews call context APIs"}
end

def allowed_dependencies(:liveview, :repository) do
  {:error, "LiveViews must go through contexts"}
end
```

**Impact Analysis:**
```elixir
def analyze_impact(component_name) do
  direct_dependents = get_direct_dependents(component_name)
  transitive = get_transitive_dependents(component_name)

  %{
    direct_impact: length(direct_dependents),
    transitive_impact: length(transitive),
    risk_level: calculate_risk(direct_dependents, transitive),
    affected_components: direct_dependents
  }
end
```

**Graph Visualization:**
(Include diagram or ASCII art showing component graph)

**Multi-Tenant Scoping:**
- Components scoped to projects
- Each project has own architecture
- AI can only see/modify project it's working on

**Security:**
- Read operations open (AI can query freely)
- Write operations restricted (human approval)
- Audit trail of AI architectural queries

**What This Enables:**
- AI understands your architecture
- AI suggests valid dependencies only
- Catch architectural violations before code generation
- Impact analysis for changes
- Safe refactoring guidance

**Comparison to Manual:**

Manual context_mapping.md:
- ✅ Simple, version controlled
- ✅ Human-readable
- ❌ No validation
- ❌ Can't detect circular deps
- ❌ No impact analysis

MCP Components Server:
- ✅ Live validation
- ✅ Circular dependency detection
- ✅ Impact analysis
- ✅ AI architectural awareness
- ❌ More complex
- ❌ Requires database

**When to Build This:**
- Managing 10+ contexts
- Team needs architectural guardrails
- AI keeps violating boundaries
- Refactoring frequently
- Want impact analysis

**Call to Action:**
- Start with context_mapping.md
- Build MCP server when complexity grows
- Share your dependency rules
- "What architectural constraints do you enforce?"

**Next Side Quest:**
> I also automated the entire design → code workflow with session orchestration: [link to Side Quest 3A]

#### Source Material
- Component architecture from your system
- Dependency validation logic
- Graph algorithms for circular detection
- Phoenix architectural patterns

#### Success Metrics
- "This would help my team" comments
- Questions about specific rules
- Others sharing their architectural constraints
- Phoenix community discussion

---

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

---

### Side Quest 4A: "CodeMySpec: Putting It All Together"

**Prerequisites**: All main quest posts + side quests 1A, 2A, 3A
**Target audience**: Readers who followed the journey and want automation
**Length:** 2000-2500 words
**Channel:** r/elixir, your blog, HN

#### Content Outline

**Hook:**
- "After building all these pieces..."
- "I realized I had a complete system"
- "CodeMySpec is the automation of everything I've shared"

**The Journey Recap:**

**Main Quest:**
- Post 1: user_stories.md for requirements
- Post 2: context_mapping.md for architecture
- Post 3: Design documents for each component
- Post 4: Complete manual workflow

**Side Quests:**
- 1A: Stories MCP server (automate requirements access)
- 2A: Components MCP server (automate architecture tracking)
- 3A: Session orchestration (automate workflow)

**CodeMySpec = All of This Combined:**

**Architecture:**
```
Phoenix/LiveView Application
├── Stories Context + MCP Server (Side Quest 1A)
├── Components Context + MCP Server (Side Quest 2A)
├── Session Orchestration (Side Quest 3A)
├── Design Document Management
├── OAuth2 for AI Agent Access
├── Multi-tenant Project Management
└── LiveView Dashboard
```

**What It Does:**
1. **Project Setup**: Manages user stories and executive summary
2. **Architecture Design**: Context mapping with dependency tracking
3. **Component Design**: Design document generation and management
4. **Code Generation**: Session-based orchestration with approval gates
5. **Testing**: Integration test generation and validation
6. **Traceability**: User story → design → code → tests

**The Complete Workflow:**

**Phase 1: Requirements (Main Quest 1 + Side Quest 1A)**
- User tells AI about requirements
- AI creates/updates stories via MCP server
- Stories stored in database (not just markdown)
- Team has live view of requirements

**Phase 2: Architecture (Main Quest 2 + Side Quest 2A)**
- AI proposes context mapping
- Human architect reviews and approves
- Component dependencies tracked
- Architecture validation automated

**Phase 3: Design (Main Quest 3)**
- AI generates design documents per component
- Human reviews each design
- Designs stored with versioning
- 1:1:1 mapping maintained (design:code:test)

**Phase 4: Implementation (Main Quest 4 + Side Quest 3A)**
- Session orchestration drives implementation
- AI generates tests from design
- Human approves tests
- AI generates implementation
- Tests validate implementation matches design
- Approval gate before integration

**What Makes It Different:**

**From manual process:**
- No copy-pasting
- Enforced approval gates
- Automatic traceability
- Parallel session management
- Audit trail

**From other AI coding tools:**
- Elixir/Phoenix-first (not generic)
- Design-driven (not prompt-driven)
- Human-in-the-loop at decision points
- Architecture enforcement
- Not just "better prompts"

**Technology Stack:**
- Phoenix 1.7 + LiveView
- Hermes for MCP server
- OAuth2 for agent authentication
- Ecto for persistence
- OTP for session supervision

**Current Status:**
- Working beta
- Used internally (dogfooding)
- MCP integration tested with Claude Code
- Looking for early adopters

**Who It's For:**
- Elixir developers using AI assistance
- Teams building Phoenix applications
- Agencies managing client projects
- Anyone frustrated with AI code quality
- Those who value architecture over speed

**Pricing:**
- Early access: Free during beta
- Open source parts: MCP server components
- Commercial: TBD (input welcome)

**Getting Started:**
- Beta signup: [link]
- Documentation: [link]
- GitHub (MCP servers): [link]
- Demo video: [link]

**The Manual Process Still Works:**
- Everything I've taught works without the product
- CodeMySpec just automates the tedium
- You can build your own version
- I'm sharing everything

**Open Discussion:**
- "This is opinionated - is it too opinionated?"
- "What would make this more useful?"
- "What am I missing?"
- "Would you use this?"

**Acknowledgments:**
- Thanks to everyone who engaged with the journey posts
- Feedback shaped the product
- Community is critical

**Call to Action:**
- Try the manual process (Main Quest posts)
- Sign up for beta if you want automation
- Build your own version if you prefer
- Share feedback either way
- Join the discussion

#### Source Material
- All previous posts in series
- Product architecture
- Beta access page
- Demo materials

#### Success Metrics
- 20+ beta signups
- Positive sentiment in comments
- "I've been following this journey" responses
- Technical questions about implementation
- Others building similar tools (success, not competition!)
- Conference talk interest

---

## Content Calendar

| Week | Post | Title | Channel | Dependencies |
|------|------|-------|---------|--------------|
| 1 | Main 1 | Markdown File for Requirements | r/elixir, dev.to | None |
| 2 | Side 1A | Stories MCP Server | dev.to | Main 1 |
| 3 | Main 2 | Context Mapping in Markdown | r/elixir, dev.to | Main 1 |
| 4 | Side 2A | Components MCP Server | dev.to | Main 2, Side 1A |
| 5 | Main 3 | The 1:1:1 Rule | r/elixir, dev.to | Main 1, 2 |
| 6 | Side 3A | Session Orchestration | dev.to | Main 3, Side 1A, 2A |
| 7 | Main 4 | Complete Workflow Walkthrough | r/elixir, dev.to | Main 1, 2, 3 |
| 8 | Side 4A | CodeMySpec Product Reveal | r/elixir, HN | All previous |

## Cross-References Strategy

**In Main Quest Posts:**
```markdown
> This process works great, but copy-pasting gets tedious. If you want to automate it, check out [Side Quest 1A: Building an MCP Server]

> The complete automation of this workflow is available in [Side Quest 4A: CodeMySpec]
```

**In Side Quest Posts:**
```markdown
> This post assumes you've tried the manual process described in [Main Quest Post 1]. If you haven't, start there - it's important to understand the process before automating it.

> For the next piece of automation, see [Side Quest 2A: Components MCP Server]
```

**In Community Engagement (Campaign 3):**
```markdown
"I wrote about the manual approach here: [Main Quest Post 1]
And if you want automation: [Side Quest 1A]"

"This is exactly what I cover in my series on design-driven AI development: [link to series landing page]"
```

## Integration with Existing Campaigns

### Campaign 1 (AI Technical Debt Series)
**Relationship:** This series IS the solution to Campaign 1's problem
- Campaign 1 identifies the problem
- This campaign provides the solution through education
- Cross-reference heavily

### Campaign 2 (MCP Education)
**Relationship:** Side quests ARE Campaign 2
- Side Quest 1A = Post 4 of Campaign 2 (Stories MCP Server)
- Side Quest 2A = Post 5 of Campaign 2 (Components MCP Server)
- Side Quest 3A = Post 6 of Campaign 2 (Session Orchestration)
- This campaign positions them as automation of proven process

### Campaign 3 (Live Problem Solving)
**Relationship:** Reference this series constantly
- "I use a markdown file for this, here's how: [Main Quest 1]"
- "I automated this with an MCP server: [Side Quest 1A]"
- Establish authority through content

### Campaign 4 (Process Documentation)
**Relationship:** Main quest posts ARE Campaign 4
- Main Quest posts are "How I..." articles
- Already structured as process docs
- Narrative-driven version of Campaign 4

## Publishing Strategy

### Post Format

**Main Quest Posts:**
- Focus on technique, not tools
- Immediately actionable
- Complete without product
- Conversational tone
- Personal story elements
- Code examples from markdown files

**Side Quest Posts:**
- Technical depth
- Assume reader tried manual approach
- Show real code
- Phoenix/Elixir best practices
- Open source examples
- Product only mentioned at end

### Channel Strategy

**Reddit r/elixir:**
- Main quest posts (weekly)
- Title: Practical, benefit-focused
- Post timing: Tuesday/Wednesday 9-11 AM ET
- Engage heavily in comments

**dev.to:**
- All posts (cross-post from blog)
- Tags: #elixir #ai #phoenix #mcp
- Canonical URL to your blog
- Build follower base

**Your blog:**
- Primary publication for all
- SEO optimized
- Series landing page
- Newsletter capture

**Hacker News:**
- Side Quest 4A only (product reveal)
- "Show HN: CodeMySpec - Design-driven AI development for Phoenix"
- Link to blog post

**Twitter:**
- Thread per post (5-7 tweets)
- Tag relevant people (Anthropic, José Valim when appropriate)
- Share community reactions

### SEO Strategy

**Series Landing Page:**
- "Design-Driven AI Development Guide"
- Links to all main quest and side quest posts
- Can follow main quest, side quests, or both
- Subscribe for updates

**Target Keywords:**
Main Quest:
- "user stories for AI development"
- "Phoenix context architecture"
- "design documents for code generation"
- "AI code quality control"

Side Quests:
- "building MCP server Elixir"
- "Phoenix component tracking"
- "AI workflow orchestration"
- "session state machine Phoenix"

**Internal Linking:**
- Each post links to previous and next
- Cross-reference main quest ↔ side quest
- Link to series landing page
- Link to relevant docs

## Success Metrics

### Per Post

**Engagement:**
- 50+ upvotes on Reddit
- 20+ substantive comments
- 5+ "I tried this" responses
- Saved/bookmarked

**Traffic:**
- 200+ blog views in first week
- 100+ dev.to views
- 10+ Twitter shares

**Business:**
- 5+ beta signups (from Side Quest posts)
- 2+ DMs asking about process
- Referenced in other discussions

### Series-Wide (8 weeks)

**Awareness:**
- 2000+ total blog visits
- 1000+ dev.to followers
- ElixirWeekly feature 2+ times
- Community members reference series

**Authority:**
- "Have you read [your name]'s series?" comments
- Tagged by others for architecture questions
- Conference talk proposal interest
- Podcast interview invitations

**Business:**
- 50+ beta signups
- 10+ agencies interested
- 3+ companies mention using approach
- GitHub stars on MCP server repos (100+)

**Community:**
- Others build MCP servers
- "I'm trying this approach" posts
- Process adopted by teams
- Extensions and variations shared

## Risk Mitigation

### Potential Issues

**1. "This is just marketing disguised as education"**
Response:
- Lead with value, product reveal only at end
- Manual process works completely without product
- Open source MCP server components
- "Build your own" is valid option

**2. "Too complex for most developers"**
Response:
- Main quest is simple (just markdown files)
- Side quests are optional
- Start small: one feature
- Scale up gradually

**3. "Why not just [competitor]?"**
Response:
- Not competing, different approach
- Elixir/Phoenix specific
- Design-driven vs prompt-driven
- Different philosophy (human gates vs full automation)

**4. "MCP is too new/might change"**
Response:
- Manual process doesn't depend on MCP
- MCP is abstraction layer
- Will update as MCP evolves
- Principles remain valid

**5. "I tried Main Quest 1, it didn't work"**
Response:
- Engage deeply: What didn't work?
- Iterate on the process
- Create troubleshooting guide
- Improve content based on feedback

## Content Preparation

### Before Week 1

- [ ] Draft all 4 main quest posts
- [ ] Draft all 4 side quest posts
- [ ] Create series landing page
- [ ] Set up blog/newsletter
- [ ] Prepare code examples and repos
- [ ] Create diagrams for side quests
- [ ] Test all examples personally
- [ ] Get beta platform ready
- [ ] Prepare demo video
- [ ] Set up analytics

### Per Post

- [ ] Review and edit draft
- [ ] Test all code examples
- [ ] Create Twitter thread
- [ ] Prepare Reddit post title
- [ ] Schedule publication
- [ ] Alert beta users (they're early readers)
- [ ] Engage in comments first 48 hours
- [ ] Cross-post to dev.to after 24 hours
- [ ] Share on Twitter
- [ ] Update series landing page

## Long-Term Vision

### 6 Months Out

**Content:**
- Complete 8-post series
- 20+ community engagement posts referencing series
- 5+ guest posts on other blogs
- 1+ conference talk

**Community:**
- 500+ blog subscribers
- 1000+ dev.to followers
- Recognized in Elixir community
- Others referencing your work

**Business:**
- 100+ beta users
- 10+ paying customers
- 5+ case studies
- Product market fit validated

**Ecosystem:**
- MCP servers widely used
- Others building on your patterns
- Contributions to Elixir ecosystem
- Thought leadership established

### 12 Months Out

**Content:**
- Series becomes ebook/course
- Workshop based on series
- Conference circuit (ElixirConf, etc.)
- Podcast appearances

**Product:**
- Growing customer base
- Case studies and testimonials
- Product-led growth from content
- Community as distribution channel

**Impact:**
- "Design-driven AI development" becomes term
- Approach adopted by agencies
- Influence on Phoenix patterns
- Elixir community leadership

## Next Steps

1. **Week -1: Preparation**
   - Finalize Main Quest Post 1
   - Review with beta user if available
   - Prepare all code examples
   - Set up blog and analytics

2. **Week 1: Launch**
   - Publish Main Quest Post 1
   - Engage heavily in comments
   - Monitor feedback
   - Iterate based on response

3. **Week 2: Build Momentum**
   - Publish Side Quest 1A
   - Reference Main Quest 1
   - Share technical depth
   - Build MCP interest

4. **Week 3-8: Execute**
   - Maintain weekly cadence
   - Engage with every comment
   - Iterate content based on feedback
   - Build toward product reveal

5. **Week 8+: Sustain**
   - Product reveal (Side Quest 4A)
   - Continue community engagement
   - Support beta users
   - Plan next content phase

---

## Conclusion

This campaign tells your authentic story through education. By teaching the manual process first and showing automation second, you build trust and demonstrate expertise. The product emerges as the natural conclusion of a proven workflow, not a theoretical solution.

The main quest + side quest structure lets readers choose their own adventure. Beginners get immediate value from simple markdown files. Advanced users dive into MCP servers and orchestration. Everyone learns, and those who want automation have a clear path.

Most importantly, this approach gives away your best ideas. That's counterintuitive but powerful: readers who implement your process manually become advocates. They understand the value because they've experienced it. When they want automation, they already know it works.

This is the long game, but it's the most authentic and ultimately most effective path for developer tools.


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

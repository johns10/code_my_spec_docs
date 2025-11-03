# The CodeMySpec Method - Content Outline

## Target Audience
- Mid to senior developers using AI coding assistants
- Teams struggling with AI-generated technical debt
- Phoenix/Elixir developers (primary), other frameworks (secondary)
- People who tried the "managing user stories" post but want the full picture

## Core Message
Design-driven AI development isn't theoretical - it's a proven methodology with specific steps, tools, and techniques that you can start using today (manually) or automate completely.

---

## Page Structure

### Hero Section
**Headline:** "Stop Fighting AI-Generated Code. Start Designing It."

**Subheadline:** "The proven methodology for controlling AI code generation - from user stories through architecture to production code"

**Visual:** Interactive component diagram (see Interactive Elements section below)

**CTA:**
- "Start with the manual process" (link to managing user stories)
- "See the full automation" (link to CodeMySpec)

---

### Section 1: The Problem (Empathy)
**Goal:** Make readers feel understood

**Content:**
- AI generates code fast, but creates technical debt faster
- Requirements drift, architecture erodes, tests break
- You end up spending more time fixing than if you'd written it yourself
- The promise: AI should make development faster AND better
- The reality: Without structure, AI creates chaos

**Tone:** Conversational, empathetic, acknowledges shared frustration

**Length:** 3-4 paragraphs

**Visual:** None (keep focus on text)

---

### Section 2: Why This Happens
**Goal:** Explain the root cause

**Content:**
- AI assistants lack context about your entire system
- They optimize for the current conversation, not your codebase
- No shared memory between sessions leads to inconsistent decisions
- Missing requirements lead to incorrect implementations
- Without design constraints, AI makes reasonable but incompatible choices

**Key Insight:** "AI isn't bad at coding - it's bad at knowing what your codebase needs to be"

**Tone:** Educational, builds understanding

**Length:** 2-3 paragraphs

---

### Section 3: The Solution - Design-Driven AI Development
**Goal:** Introduce the methodology

**Content:**
- Give AI a complete, consistent picture of requirements and architecture
- Make design documents the primary interface to AI assistants
- Use structured workflows that maintain quality at each step
- Gate progression on validation (human review + automated tests)
- Version control everything so nothing drifts

**The Core Principle:** "Your design documents become the source of truth that AI references every time it generates code"

**Tone:** Confident, solution-oriented

**Length:** 3-4 paragraphs

**Visual:** Link to interactive diagram (already above)

---

### Section 4: The Five Phases (Main Content)
**Goal:** Teach the complete methodology

Each phase gets:
- Phase name and number
- One-sentence description
- What you create in this phase
- Why this phase matters
- Link to detailed "how-to" article
- Link to automation option (MCP/CodeMySpec)
- Real example from CodeMySpec codebase

**Format:** Expandable/collapsible sections or scroll-spy navigation

---

#### Phase 1: User Stories
**One-liner:** "Define what your application should do in plain English"

**What you create:**
- `user_stories.md` file with structured stories
- Acceptance criteria for each story
- Edge cases and error scenarios

**Why it matters:**
- Stories are the foundation for everything else
- Without clear stories, AI makes up requirements
- Stories let you validate with stakeholders before coding
- They become your test specifications

**How to do it manually:**
- Create `user_stories.md` in your repo
- Interview yourself (or have AI interview you) about requirements
- Write stories in "As a... I want... So that..." format
- Add specific, testable acceptance criteria
- Review for completeness and conflicts

**Example from CodeMySpec:**
```markdown
## User Story: Component Design Sessions
As an architect, I want to generate design documents for components so that AI has clear specifications for implementation.

Acceptance Criteria:
- System generates component design from context design
- Component design includes schema, repository, and service specifications
- Design follows Phoenix conventions and naming patterns
- Human reviews and approves design before proceeding
```

**Link to detailed guide:** "How to Manage User Stories to Control AI Code Generation"
- File: `docs/content/managing_user_stories.md` ✓ (already published)

**Link to automation:** "Building a Stories MCP Server"
- File: `docs/content/stories_mcp_server.md` (to be written)
- Implementation: `lib/code_my_spec/mcp_servers/stories_server.ex`

---

#### Phase 2: Context Mapping & Architecture
**One-liner:** "Map your stories to Phoenix contexts using vertical slice architecture"

**What you create:**
- List of Phoenix contexts (bounded contexts)
- Entity ownership mapping (which context owns which data)
- Dependency graph between contexts
- Component types for each context (schemas, repos, services, etc.)

**Why it matters:**
- Context boundaries prevent architectural leakage
- Entity ownership eliminates ambiguity about where code lives
- Dependencies make integration points explicit
- AI can't create conflicting architecture if boundaries are clear

**How to do it manually:**
- Group stories by entity ownership (User stories → Accounts context)
- Apply business capability grouping within entity boundaries
- Keep contexts flat (no nested contexts)
- Identify components within each context
- Map dependencies between contexts
- Review for coupling and cohesion

**Example from CodeMySpec:**
```markdown
## Context: Stories
**Owns:** Story entity
**Purpose:** Manage user requirements throughout project lifecycle
**Components:**
- Story schema
- StoriesRepository
- Stories context module
**Dependencies:**
- Components (for story-to-component mapping)
- Sessions (for tracking story changes)
```

**Link to detailed guide:** "Context Mapping for AI-Driven Development"
- File: `docs/content/context_mapping.md` (to be written)
- Reference: `docs/context_mapping.md` (existing internal doc)

**Link to automation:** "Building a Components MCP Server"
- File: `docs/content/components_mcp_server.md` (to be written)
- Implementation: `lib/code_my_spec/mcp_servers/components_server.ex`

---

#### Phase 3: Design Documents
**One-liner:** "Write detailed specifications that become AI's primary context"

**What you create:**
- One design document per Phoenix context
- Structured markdown with specific sections:
  - Purpose and responsibilities
  - Entity ownership
  - Access patterns (how data flows)
  - Public API (functions exposed to other contexts)
  - State management strategy
  - Execution flow (step-by-step processes)
  - Component list with types and descriptions
  - Dependencies on other contexts

**Why it matters:**
- Design documents are what AI reads before generating code
- Structured format ensures AI doesn't miss critical details
- Version-controlled designs prevent drift
- Human-readable so you can review and refine
- Component list creates 1:1 mapping to code files

**How to do it manually:**
- Create `docs/design/{app_name}/{context_name}.md`
- Follow the template structure (purpose, entities, access patterns, etc.)
- Be specific about behavior, edge cases, error handling
- Include acceptance criteria from relevant user stories
- List every component (file) that needs to be implemented
- Paste design document into AI context before asking for code

**Example from CodeMySpec:**
```markdown
# Context Design: Stories

## Purpose
Manages user requirements as living documentation throughout the project lifecycle.

## Entity Ownership
- Story (id, title, description, acceptance_criteria, status, component_id)

## Access Patterns
- Create stories via MCP tools or web interface
- Update stories via interview/review sessions
- Query stories by component or status
- Track story changes via PaperTrail versioning

## Public API
- `create_story/2` - Create new story
- `update_story/3` - Update story details
- `list_stories/1` - List all stories for project
- `get_story/2` - Get single story by ID

## Components
- Story schema (lib/code_my_spec/stories/story.ex) - Ecto schema with validations
- StoriesRepository (lib/code_my_spec/stories/stories_repository.ex) - Data access layer
- Stories context (lib/code_my_spec/stories.ex) - Public API

## Dependencies
- Components context (for story-component mapping)
- Sessions context (for tracking changes)
```

**Link to detailed guide:** "How to Write Design Documents for AI Code Generation"
- File: `docs/content/writing_design_documents.md` (to be written)

**Link to automation:** "Session Orchestration - Automating Design Generation"
- File: `docs/content/session_orchestration.md` (to be written)
- Implementation: `lib/code_my_spec/context_design_sessions/orchestrator.ex`

---

#### Phase 4: Test Generation
**One-liner:** "Generate comprehensive tests from design documents before writing implementation"

**What you create:**
- Test files for every component in design document
- Test fixtures and factories
- Integration tests for context boundaries
- Tests that validate acceptance criteria from user stories

**Why it matters:**
- Test-first ensures AI implements what's designed, not what it assumes
- Tests validate AI-generated code automatically
- Failing tests guide AI to fix issues iteratively
- Tests prevent regression when requirements change

**How to do it manually:**
- Read design document
- Write tests for each component's public API
- Include edge cases and error scenarios from acceptance criteria
- Create fixtures for test data
- Run tests (they should fail - no implementation yet)
- Paste design doc + failing tests into AI context for implementation

**Example from CodeMySpec:**
```elixir
# test/code_my_spec/stories_test.exs
defmodule CodeMySpec.StoriesTest do
  use CodeMySpec.DataCase

  alias CodeMySpec.Stories

  describe "create_story/2" do
    test "creates story with valid attributes" do
      attrs = %{
        title: "User authentication",
        description: "As a user...",
        acceptance_criteria: ["User can log in", "Session persists"]
      }

      assert {:ok, story} = Stories.create_story(scope, attrs)
      assert story.title == "User authentication"
    end

    test "returns error with invalid attributes" do
      assert {:error, changeset} = Stories.create_story(scope, %{})
      assert "can't be blank" in errors_on(changeset).title
    end
  end
end
```

**Link to detailed guide:** "Test-First AI Code Generation"
- File: `docs/content/test_first_ai_generation.md` (to be written)

**Link to automation:** "Component Test Sessions - Automated Test Generation"
- File: `docs/content/component_test_sessions.md` (to be written)
- Implementation: `lib/code_my_spec/component_test_sessions/orchestrator.ex`

---

#### Phase 5: Code Generation
**One-liner:** "Generate production code from design documents and make tests pass"

**What you create:**
- Implementation for every component in design document
- Code that follows Phoenix conventions and design specifications
- Code that makes all tests pass
- Git commits with clear history

**Why it matters:**
- Design document + tests = complete specification for AI
- AI generates code to match design, not based on assumptions
- Tests validate correctness automatically
- Iterative fixing until tests pass ensures quality
- Version control tracks exactly what was generated

**How to do it manually:**
- Paste design document into AI context
- Paste failing tests into AI context
- Ask AI to implement each component following the design
- Run tests
- If tests fail, paste errors back to AI and ask for fixes
- Iterate until all tests pass
- Commit with clear message referencing design doc and tests

**Example from CodeMySpec:**
```elixir
# lib/code_my_spec/stories.ex
defmodule CodeMySpec.Stories do
  @moduledoc """
  Context for managing user requirements throughout project lifecycle.

  See design document: docs/design/code_my_spec/stories.md
  """

  alias CodeMySpec.Stories.StoriesRepository

  @doc """
  Creates a new story.

  ## Examples
      iex> create_story(scope, %{title: "User auth"})
      {:ok, %Story{}}
  """
  def create_story(scope, attrs) do
    StoriesRepository.create(scope, attrs)
  end

  # ... rest of implementation
end
```

**Link to detailed guide:** "Design-Driven Code Generation with AI"
- File: `docs/content/design_driven_code_generation.md` (to be written)

**Link to automation:** "Component Coding Sessions - Full Automation"
- File: `docs/content/component_coding_sessions.md` (to be written)
- Implementation: `lib/code_my_spec/component_coding_sessions/orchestrator.ex`

---

### Section 5: Why This Works
**Goal:** Explain the theoretical foundation

**Content:**
- **Complete Context:** AI has full picture, not just current conversation
- **Consistency:** Design docs ensure decisions align across sessions
- **Validation:** Tests and reviews catch issues before they compound
- **Traceability:** Version control links code back to requirements
- **Iteration:** Process designed for requirement changes

**Key Insight:** "The manual process proves the methodology works. Automation just removes the tedious parts."

**Tone:** Reflective, builds confidence

**Length:** 3-4 paragraphs

---

### Section 6: Getting Started
**Goal:** Make next steps crystal clear

**Content:** Two clear paths

#### Path 1: Manual Process (Start Today)
1. Read "How to Manage User Stories" guide
2. Create your first `user_stories.md`
3. Try context mapping on paper
4. Write one design document
5. Generate code with AI using your design doc

**Time investment:** 2-4 hours to learn, ongoing for projects

**When to choose this:**
- You want to understand the methodology first
- You're working on a small project
- You prefer more control
- You don't use Phoenix/Elixir

#### Path 2: Automated Workflow (CodeMySpec)
1. Install CodeMySpec
2. Run initial setup session
3. Interview mode generates stories
4. System generates designs automatically
5. Review and approve, then generate code

**Time investment:** 30 minutes to set up, automated afterward

**When to choose this:**
- You're building a Phoenix/Elixir application
- You want maximum speed
- You trust the automated workflow
- You're working on medium/large projects

**CTA:**
- "Get started with manual process" → Link to managing user stories
- "Try CodeMySpec" → Link to product (Side Quest 4A when published)

---

### Section 7: FAQ
**Goal:** Address common objections and questions

**Questions to address:**
- Q: "Isn't this just waterfall?"
  - A: No - designs evolve with requirements. Version control tracks changes. You're not freezing specs upfront; you're maintaining current specifications.

- Q: "This seems like a lot of overhead"
  - A: Less overhead than refactoring AI-generated technical debt. Manual process takes time; automation removes overhead.

- Q: "What if my requirements change?"
  - A: Update user stories, regenerate affected designs, update tests. The process supports change; version control shows impact.

- Q: "Can I use this with [other framework]?"
  - A: Yes for manual process (language-agnostic). Automation currently Phoenix/Elixir only.

- Q: "Do I need MCP servers?"
  - A: No - manual process works with copy-paste. MCP servers eliminate tedious parts.

- Q: "How is this different from [competitor]?"
  - A: Design-driven vs prompt-driven. Explicit gates vs full automation. Different philosophy.

- Q: "What if AI generates wrong code despite design docs?"
  - A: Tests catch this. Iterative fixing until tests pass. If repeatedly failing, design may need refinement.

---

### Section 8: Related Content
**Goal:** Keep readers engaged with related articles

**Format:** Card grid with thumbnails and descriptions

**Links:**
- "How to Manage User Stories" (Main Quest 1) ✓
- "Context Mapping for AI Development" (Main Quest 2) - to be written
- "Writing Design Documents for AI" (Main Quest 3) - to be written
- "Complete Workflow Walkthrough" (Main Quest 4) - to be written
- "Building a Stories MCP Server" (Side Quest 1A) - to be written
- "Building a Components MCP Server" (Side Quest 2A) - to be written
- "Session Orchestration in Phoenix" (Side Quest 3A) - to be written
- "CodeMySpec Product Introduction" (Side Quest 4A) - to be written

---

## Interactive Elements

### 1. The Methodology Diagram (Hero Section)

**Type:** Interactive SVG component diagram

**Layout:** Vertical flow with expandable sections

**Visual Style:**
- Clean, modern design
- Phoenix/Elixir color scheme (purple/orange)
- Each phase is a clickable card
- Arrows show progression
- Hover shows phase description
- Click expands to show details

**Components:**

```
┌─────────────────────────────────────┐
│  Phase 1: User Stories              │
│  "Define requirements in plain      │
│   English"                          │
│                                     │
│  [Manual Guide] [Automation]        │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Phase 2: Context Mapping           │
│  "Map stories to Phoenix contexts"  │
│                                     │
│  [Manual Guide] [Automation]        │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Phase 3: Design Documents          │
│  "Write specifications for AI"      │
│                                     │
│  [Manual Guide] [Automation]        │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Phase 4: Test Generation           │
│  "Create tests from designs"        │
│                                     │
│  [Manual Guide] [Automation]        │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Phase 5: Code Generation           │
│  "Generate code to make tests pass" │
│                                     │
│  [Manual Guide] [Automation]        │
└─────────────────────────────────────┘
```

**Interactions:**
- Hover over phase: Shows tooltip with key outputs
- Click phase: Expands inline to show:
  - What you create
  - Example from real project
  - Links to guides
- Toggle between "Manual" and "Automated" view:
  - Manual: Shows copy-paste workflow
  - Automated: Shows MCP/CodeMySpec workflow

**Implementation:**
- React component or plain JavaScript
- SVG for diagram elements
- Smooth animations on expand/collapse
- Mobile-friendly (stack vertically)

---

### 2. Interactive Code Example Slider

**Type:** Before/After comparison slider

**Location:** After Section 3 (The Solution)

**Purpose:** Show difference between unstructured and structured AI interaction

**Left side: "Without Design Documents"**
```
User: "Create a user authentication system"

AI: [generates code without context]
- Makes assumptions about database schema
- Chooses arbitrary naming conventions
- Implements features not requested
- Missing edge cases
- Incompatible with existing code
```

**Right side: "With Design Documents"**
```
User: [pastes design document]
"Implement the Accounts context following this design"

AI: [generates code matching design]
- Uses specified schema
- Follows Phoenix conventions
- Implements only designed features
- Handles all edge cases from acceptance criteria
- Integrates with existing contexts via dependencies
```

**Interaction:**
- Slider control to reveal before/after
- Syntax highlighting on code blocks
- Annotations pointing out key differences

---

### 3. Expandable Examples Throughout

**Type:** Collapsible content sections

**Location:** Within each phase description

**Content:** Real examples from CodeMySpec codebase with annotations

**Format:**
```
[Example: Story for Component Design Sessions ▼]

When expanded:
┌─────────────────────────────────────────┐
│ ## User Story: Component Design         │
│ As an architect, I want to generate...  │
│                                         │
│ Acceptance Criteria:                    │
│ - System generates component design...  │
│                                         │
│ [View in CodeMySpec repo →]             │
└─────────────────────────────────────────┘
```

---

### 4. Progress Checklist

**Type:** Interactive checklist

**Location:** Section 6 (Getting Started)

**Purpose:** Help readers track their progress learning the methodology

**Content:**
```
Manual Process Checklist:
☐ Read "Managing User Stories" guide
☐ Create user_stories.md for your project
☐ Try context mapping exercise
☐ Write your first design document
☐ Generate code using design doc
☐ Evaluate: Did AI generate better code?

Automation Checklist:
☐ Review manual process (recommended)
☐ Install CodeMySpec
☐ Run setup session
☐ Complete story interview
☐ Review generated designs
☐ Generate and validate code
```

**Interaction:**
- Checkboxes save state to localStorage
- Completion percentage shown
- Links to relevant guides for each step
- Share progress option (URL with encoded state)

---

### 5. Live Architecture Visualization

**Type:** Interactive dependency graph

**Location:** Phase 2 (Context Mapping) detail section

**Purpose:** Show how contexts relate to each other

**Content:** Example from CodeMySpec architecture

**Visual:**
```
        Stories Context
             │
             ├─→ Components Context
             │        │
             │        └─→ Dependencies
             │
             └─→ Sessions Context
                      │
                      ├─→ Context Design Sessions
                      ├─→ Component Design Sessions
                      ├─→ Component Test Sessions
                      └─→ Component Coding Sessions
```

**Interactions:**
- Click context: Shows components within
- Hover dependency arrow: Shows what data/functions are shared
- Filter by context type (domain vs coordination)
- Zoom in/out

---

## SEO Strategy

**Primary Keyword:** "AI code generation control"

**Secondary Keywords:**
- "design-driven development"
- "Phoenix context architecture"
- "AI coding methodology"
- "prevent AI technical debt"
- "user stories for AI development"

**Meta Title:** "The CodeMySpec Method: How to Control AI Code Generation | Design-Driven Development"

**Meta Description:** "Stop fighting AI-generated technical debt. Learn the proven 5-phase methodology for controlling AI code generation - from user stories through architecture to production code. Start with the manual process or automate completely."

**URL:** `/codemyspec-method` or `/design-driven-ai-development`

**Internal Links:**
- Link to all Main Quest and Side Quest posts
- Link to CodeMySpec product page
- Link to campaign landing page

**External Links:**
- Phoenix Framework documentation
- Elixir language site
- Anthropic MCP documentation
- Relevant community discussions

---

## Writing Tone & Style

**Voice:**
- Conversational but authoritative
- Personal but not anecdotal
- Educational but not academic
- Practical but not simplistic

**Avoid:**
- Marketing speak or hype
- Theoretical abstractions without examples
- Jargon without explanation
- Assuming reader knows Phoenix/Elixir

**Include:**
- Real examples from CodeMySpec
- Specific file paths and code
- Honest acknowledgment of tradeoffs
- Clear next steps

**Length:**
- Aim for 2500-3500 words
- Sections are scannable
- Examples are skimmable
- Links allow deep-dives without bloating main content

---

## Success Metrics

**Engagement:**
- Time on page: >4 minutes average
- Scroll depth: >70% reach bottom
- Interaction rate: >30% click diagram or examples
- Return visitors: >20% come back

**Traffic:**
- 500+ views in first week
- 50+ from Reddit r/elixir
- 100+ from dev.to
- 20+ shares on Twitter

**Conversion:**
- 50+ clicks to "Managing User Stories" guide
- 25+ clicks to other Main Quest posts
- 10+ clicks to CodeMySpec product
- 15+ newsletter signups

**Community:**
- 10+ substantive comments/discussions
- 3+ "I'm trying this" responses
- Referenced in other content
- Bookmarked/saved by readers

---

## Production Checklist

Before publishing:
- [ ] All internal links verified (no 404s)
- [ ] Code examples tested and accurate
- [ ] File paths verified in CodeMySpec repo
- [ ] Interactive diagram functional on mobile
- [ ] All examples have syntax highlighting
- [ ] SEO metadata complete
- [ ] Images optimized (if any)
- [ ] Load time <3 seconds
- [ ] Accessible (WCAG AA minimum)
- [ ] Proofread (no typos, clear grammar)
- [ ] Canonical URL set
- [ ] Open Graph tags configured
- [ ] Analytics tracking enabled
- [ ] Cross-browser tested

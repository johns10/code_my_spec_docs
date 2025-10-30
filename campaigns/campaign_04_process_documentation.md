# Campaign 4: Process Documentation ("How I..." Content Series)

## Objective

Create detailed, valuable content documenting your actual development processes that serves both as educational material and natural product demonstration. These pieces can be referenced repeatedly when answering questions, establishing you as a thought leader who shares generously.

## Philosophy

**"Show your work"** - Instead of telling people CodeMySpec is good, show them the sophisticated processes you've developed and implemented. The product becomes a natural artifact of your expertise rather than the focus.

## Content Structure Formula

Every "How I..." piece should follow this structure:

### 1. The Problem (15%)
- Common pain point developers face
- Why typical approaches fail
- Your experience hitting this wall

### 2. The Principles (50%)
- Core concepts anyone can apply
- Why this approach works
- Trade-offs and considerations
- Applicable regardless of tooling

### 3. My Implementation (25%)
- How YOU specifically do this
- Tools you built (including CodeMySpec)
- Workflow details
- Code examples

### 4. Alternatives & Adaptation (10%)
- How to do this without CodeMySpec
- Other tools that help
- Adapting to different contexts
- Invitation to discuss

---

## Content Pieces to Create

### Priority 1: AI-Assisted Development Process

#### Article 1: "How I Structure User Stories for AI-Driven Development"

**Target length:** 2000-2500 words
**Target audience:** Teams using AI for development
**Primary channel:** dev.to, your blog, r/elixir

**Outline:**

**The Problem**
- AI needs precise specifications to generate good code
- Vague requirements → garbage code
- "Just make it work" leads to architectural disasters
- Traditional user stories too loose for AI agents

**The Principles**
1. **Acceptance criteria must be testable**
   - Not: "Should be fast"
   - Yes: "Responds within 200ms for 95th percentile"

2. **Explicit tenancy scoping**
   - Clarify user vs account scope upfront
   - Prevents security bugs later

3. **Edge cases enumerated**
   - Don't leave AI to guess
   - Document error scenarios explicitly

4. **Component linkage**
   - Stories map to architectural units
   - Enables traceability

**My Implementation**
- I built an MCP server that guides AI through story interviews
- PM persona asks leading questions
- Stories stored with component relationships
- Example workflow walkthrough
- [Reference stories_mcp_server.md concepts]

**Code/Tool Example:**
```
User: "I need API key management"

AI PM (via MCP):
- Who manages keys? (tenancy)
- What operations? (CRUD)
- What are security requirements? (immediate)
- What's the revocation story? (edge case)
- Rate limiting needs? (non-functional)

Result: 5 well-specified stories ready for implementation
```

**Alternatives**
- Manual template enforcement (show template)
- Structured Google Docs with checklist
- GitHub issue templates with required fields
- Story review checklists

**Key insight:** "I treat story interviews like test-driven requirements gathering. Before ANY code, the story must be so clear that tests write themselves."

---

#### Article 2: "My Test-First AI Coding Workflow (And Why It Matters)"

**Target length:** 2500-3000 words
**Target audience:** Developers concerned about AI code quality

**Outline:**

**The Problem**
- AI generates code that "works" but isn't maintainable
- No architecture coherence
- Technical debt accumulates silently
- You become a code reviewer, not a developer

**The Principles**
1. **Tests define contracts before implementation**
   - Prevents scope creep during generation
   - Makes validation objective
   - Forces thinking about interfaces

2. **Component boundaries established first**
   - What context does this live in?
   - What dependencies are allowed?
   - What's the public API?

3. **Iterative failure resolution**
   - Run tests, analyze failures
   - Fix with clear failure context
   - AI is better at fixing than creating from scratch

4. **Human approval gates at architectural decision points**
   - AI proposes, human decides
   - Especially for dependencies and boundaries

**My Implementation**
- Session orchestration through discrete steps
- Initialize → Generate Tests → Generate Code → Run Tests → Fix Failures → Finalize
- Each step has clear inputs/outputs
- [Reference component_coding_sessions.ex concepts, not code]
- State machine prevents skipping steps

**Workflow diagram:**
```
Story → Component Design → Test Generation → Review Tests →
Implementation → Run Tests → Fix Loop → Commit
         ↑                                      |
         └───── Approval Gates ─────────────────┘
```

**My specific approach:**
```elixir
# Simplified concept (not the actual implementation)
defmodule CodingSession do
  # Step 1: AI generates tests from design
  def generate_tests(design_spec)

  # Step 2: Human reviews tests
  def review_tests(tests) # Approval gate

  # Step 3: AI generates implementation
  def generate_implementation(tests)

  # Step 4: Run tests and collect failures
  def run_tests(implementation)

  # Step 5: AI fixes specific failures
  def fix_failures(failures, context)
end
```

**Key implementation details:**
- Tests stored with expected behavior
- Failure output captured for AI context
- Fix attempts limited (prevent infinite loops)
- Component type determines architectural patterns
- Phoenix context boundaries enforced

**Alternatives**
- Manual test-first discipline (requires willpower)
- GitHub Actions with mandatory test passing
- Pre-commit hooks enforcing test coverage
- Cursor/Copilot with strict prompting

**Key insight:** "AI is a junior developer that codes fast but has no architectural taste. Tests are how I give it constraints."

---

#### Article 3: "How I Track Phoenix Component Dependencies (To Prevent Architecture Rot)"

**Target length:** 1800-2200 words
**Target audience:** Phoenix developers, especially teams

**Outline:**

**The Problem**
- Phoenix contexts meant to be independent
- Reality: contexts call each other freely
- Circular dependencies emerge
- Refactoring becomes impossible
- No one knows what depends on what

**The Principles**
1. **Explicit dependency declaration**
   - Document allowed relationships
   - Make violations visible
   - Enable tooling to enforce

2. **Component type taxonomy**
   - Context, Repository, Schema, LiveView, Controller, etc.
   - Each type has architectural rules
   - Dependencies constrained by type

3. **Dependency graphs for visualization**
   - Visual representation of architecture
   - Spot circular dependencies early
   - Plan refactoring with confidence

4. **Change impact analysis**
   - "If I modify this, what breaks?"
   - Enables safe refactoring
   - Reduces fear of changes

**My Implementation**
- Component registry with types and dependencies
- Each component declares what it depends on
- Graph analysis detects circular deps
- MCP server exposes for AI awareness
- AI can't generate code violating boundaries

**Example component structure:**
```elixir
%Component{
  name: "Accounts",
  type: :context,
  dependencies: ["Users.Repository", "Auth.JWT"],
  public_functions: ["create_account/1", "get_account/1"],
  tested: true,
  test_path: "test/accounts_test.exs"
}
```

**Dependency rules by type:**
- Contexts can call other contexts (carefully)
- Repositories can only call Ecto and schemas
- LiveViews can call contexts, not repos directly
- Schemas can't call anything (pure data)

**How AI uses this:**
- Before generating code, checks allowed dependencies
- Suggests architectural refactoring if dependency invalid
- Generates proper context API calls instead of direct repo access

**Alternatives**
- Manual architecture decision records (ADRs)
- `mix xref graph` for dependency visualization
- Boundary library for Phoenix context enforcement
- Code review checklists for dependencies

**Tool example:**
```bash
# What I can generate with my component registry
$ mix deps.analyze Accounts
Accounts depends on:
  → Users.Repository ✓ (valid)
  → Auth.JWT ✓ (valid)

What depends on Accounts:
  ← AccountsWeb.AccountController
  ← Subscriptions.Context

Circular dependencies: None

Impact analysis for changes:
  High risk: 12 components depend on public API
  Medium risk: 3 components use internal functions
  Refactor suggestion: Extract User management to separate context
```

**Key insight:** "I treat component architecture like a distributed system inside my monolith. Explicit dependencies make it refactorable."

---

### Priority 2: MCP-Specific Implementations

#### Article 4: "Building an MCP Server for Your Development Workflow"

**Target length:** 3000-3500 words
**Target audience:** Developers exploring MCP

**Outline:**

**The Problem**
- AI agents need structured access to your tools
- Ad-hoc prompting doesn't scale
- Need programmatic interface for agent actions
- Want consistency across Claude Desktop and Claude Code

**The Principles**
[Cover MCP architecture, when to build server vs just use API, tool design principles]

**My Implementation**
- Two MCP servers: Stories and Components
- Session orchestration via tools
- OAuth2 for agent authentication
- Multi-tenant scoping
- [Deep dive into actual architecture from stories_mcp_server.md]

**Code walkthrough:**
- Tool definition structure
- Parameter validation
- Response formatting
- Error handling
- Testing strategies

**Alternatives**
- Direct API calls from prompts (brittle)
- Custom Cursor rules (not Claude Desktop compatible)
- GitHub Actions as interface (async only)

---

#### Article 5: "Session Orchestration: Managing Multi-Step AI Workflows"

**Target length:** 2200-2500 words
**Target audience:** Advanced AI-assisted development users

**Outline:**

**The Problem**
- AI agents good at single steps, not complex workflows
- State management across multiple calls
- Approval gates and human-in-the-loop
- Error recovery and retry logic

**The Principles**
[State machines, discrete steps, approval gates, context management]

**My Implementation**
- Session modules with explicit phases
- State stored in database
- Step results feed next step
- Human approval between critical phases
- [Reference component_coding_sessions.ex architecture]

**Workflow state machine:**
```
:initializing → :generating_tests → :awaiting_test_review →
:generating_implementation → :running_tests → :fixing_failures →
:finalizing → :completed
```

**How I handle failures:**
- Capture failure context
- Provide to AI for next attempt
- Limit retry attempts
- Escalate to human when stuck

---

### Priority 3: General Phoenix/Elixir Development

#### Article 6: "My Phoenix Project Structure for AI-Friendly Codebases"

**Outline:**
- Vertical slices vs layers
- Where to put business logic
- Test organization
- Making code "AI-readable"

#### Article 7: "How I Use Property-Based Testing for AI-Generated Code"

**Outline:**
- Why AI-generated code needs property tests
- StreamData for Elixir
- Example properties for Phoenix contexts
- Catching edge cases AI misses

---

## Content Distribution Strategy

### When to Reference These

**In Community Engagement (Campaign 3):**

❌ **Wrong:**
> "You should use CodeMySpec for this"

✅ **Right:**
> "I've developed a specific process for this. [Link to article]. The key insight is treating stories as testable specs. I built tooling around this (CodeMySpec) but the principles work with any approach."

**In Reddit Posts:**

✅ **Natural mention:**
> "I wrote about my approach here: [link to process doc]. The TL;DR is test-first with explicit boundaries. Happy to discuss alternatives or how you might adapt this."

**In Comments:**

✅ **Helpful reference:**
> "This is exactly the problem I address in this post: [link]. The solution is [2-3 sentence summary]. Let me know if that approach makes sense for your context."

### Publication Schedule

Integrate with existing campaigns:

**Week 5-6:** Article 1 (User Stories)
**Week 7-8:** Article 2 (Test-First Workflow)
**Week 9-10:** Article 3 (Dependency Tracking)
**Week 11-12:** Article 4 (MCP Server Building)
**Week 13-14:** Article 5 (Session Orchestration)
**Week 16-17:** Article 6 (Phoenix Structure)
**Week 19-20:** Article 7 (Property Testing)

---

## Writing Guidelines

### Do's ✅

1. **Lead with the problem everyone faces**
   - Not: "My product solves..."
   - Yes: "Here's a common problem and how I approach it"

2. **Explain WHY, not just WHAT**
   - Principles > implementation details
   - Help readers understand trade-offs

3. **Show real code and examples**
   - Actual patterns you use
   - Not toy examples

4. **Offer alternatives**
   - "If you're not using X, you could..."
   - Shows you're not just selling

5. **Invite discussion**
   - "What's your approach?"
   - "Have you found better ways?"

6. **Link to deep dives**
   - Reference stories_mcp_server.md for details
   - "Full documentation here: [link]"

### Don'ts ❌

1. **Don't hide that you built tooling**
   - Be transparent: "I built this because..."
   - Honesty builds trust

2. **Don't make it a product pitch**
   - Content must be valuable without product
   - Product mention: 1-2 sentences max

3. **Don't oversell**
   - Acknowledge limitations
   - "This works for me, YMMV"

4. **Don't gatekeep**
   - Give away the good stuff
   - "Here's exactly how I do it"

5. **Don't write marketing copy**
   - Write like documentation
   - Technical tone, clear explanations

---

## Content Asset Management

### Documentation to Reference

You already have these (make them linkable):
- `/docs/content/stories_mcp_server.md` - User story MCP server
- `/docs/content/components_mcp_server.md` - Component architecture MCP
- `/docs/content/design_driven_code_generation.md` - Design-first approach
- `/docs/content/control_over_prompts.md` - Prompt control philosophy

### New Docs to Create

**For each "How I..." article, create supporting docs:**

1. **Process templates** (in `/docs/templates/`)
   - User story template
   - Component design template
   - Test specification template
   - Dependency declaration format

2. **Checklists** (in `/docs/checklists/`)
   - Story quality checklist
   - Component review checklist
   - Test coverage checklist
   - Architecture review checklist

3. **Examples** (in `/docs/examples/`)
   - Example user story (good vs bad)
   - Example component structure
   - Example test suite
   - Example MCP tool definition

These become reusable assets you link to repeatedly.

---

## SEO Strategy

### Target Keywords

Each article targets specific search terms:

**Article 1:**
- "user stories for AI development"
- "requirements gathering for AI coding"
- "how to write stories for AI agents"

**Article 2:**
- "test-driven AI development"
- "AI code quality control"
- "structured AI coding workflow"

**Article 3:**
- "Phoenix context dependencies"
- "Phoenix architecture patterns"
- "managing Elixir application structure"

**Article 4:**
- "building MCP server Elixir"
- "Model Context Protocol Phoenix"
- "AI agent tools development"

**Article 5:**
- "multi-step AI workflow"
- "AI agent orchestration"
- "session management AI development"

### On-Page SEO

- Use target keywords in H1, first paragraph, H2s
- Code examples with proper syntax highlighting
- Internal links between related articles
- External links to Phoenix docs, MCP docs
- Meta description with keyword (155 chars)
- URL slug matches target keyword

---

## Success Metrics

### Per Article

**Engagement:**
- 100+ dev.to views in first week
- 30+ upvotes on Reddit
- 10+ substantive comments
- 3+ saves/bookmarks

**Business impact:**
- Referenced in 5+ community responses
- Drove 10+ clicks to product docs
- Generated 2+ beta sign-ups
- Cited by others in discussions

### Series-Wide (6 months)

**Authority building:**
- 1000+ total article views
- ElixirWeekly feature 2+ times
- Community members reference your articles
- "Have you read [your name]'s post on..." comments

**Business impact:**
- 30+ beta sign-ups attributed to content
- 5+ agencies mention content in sales conversations
- Conference talk proposal based on content
- Podcast interview discussing your processes

---

## Integration with Other Campaigns

### With Campaign 1 (AI Technical Debt)
- Article 1 & 2 support your launch narrative
- "Here's the problem (C1) and here's how I solve it (C4)"

### With Campaign 2 (MCP Education)
- Articles 4 & 5 are Campaign 2 content
- Deep dives into MCP implementation

### With Campaign 3 (Live Problem Solving)
- Reference these articles constantly
- "I wrote about this: [link]"
- Establish you as resource creator

---

## First Steps

1. **Choose Article 1 or 2 to write first** (both high-value)
2. **Create supporting template/checklist** (makes article concrete)
3. **Draft in Google Docs** (iterate freely)
4. **Get feedback from beta user** (if available)
5. **Publish on your blog first** (you own it)
6. **Cross-post to dev.to** (with canonical URL to your blog)
7. **Share on Reddit with context** (not just link dump)
8. **Reference in community engagement** (immediate use)

---

## The Long Game

After 6-12 months, you'll have:
- Portfolio of process documentation
- Referenced repeatedly in communities
- Ranking in search for key terms
- Foundation for conference talks
- Content for ebook/course if desired
- Established thought leadership

**The ultimate win:** Someone asks "How should I structure stories for AI?" and multiple people reply "Read [your name]'s article on this."

That's when you know it's working.

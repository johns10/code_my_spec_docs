# The CodeMySpec Method - Content Outline

## Hero Section
**Headline:** "Stop Fighting AI Drift. Control What Goes Into Context."

**Subheadline:** The 5-phase methodology I use to build CodeMySpec with AI - from stories to production code.

**Visual:** Interactive diagram showing the 5 phases

**CTA:**
- "Start with manual process"
- "See the automation"

---

## Section 1: The Problem - Compounding Drift

AI drift compounds through reasoning layers:

1. **Reasoning drift**: LLM's reasoning slightly off from your intent → code is more off
2. **Documentation drift**: Generate PRD → generate code from PRD → two layers of drift
3. **Process drift**: Ask LLM to prescribe AND follow process → compounding error

The farther the LLM's reasoning gets from your actual prompt, the more the output drifts from your intent.

Every intermediate step adds drift. Every time you ask the LLM to figure out the process, you add drift.

---

## Section 2: The Solution - Control Context

Remove drift by controlling exactly what goes into the LLM's context.

- Author and validate user stories with the LLM
- Map user stories to vertical slices in your application
- Design documents define the specifications
- Tests define the validation
- LLM only generates code to match both

No intermediate reasoning about requirements. No inventing process. Just: here's the spec, here are the tests, make them pass.

---

## Section 3: The Method

Five phases that control context at each step.

### Phase 1: User Stories
**Create:** `user_stories.md` with acceptance criteria

**Manual:** Write stories yourself or interview with AI
**Automated:** Stories MCP Server

**Example:** `lib/code_my_spec/stories/story.ex`

### Phase 2: Context Mapping
**Create:** Context boundaries, entity ownership, dependency graph

**Manual:** Map stories to Phoenix contexts
**Automated:** Components MCP Server

**Example:** `docs/design/code_my_spec/stories.md`

### Phase 3: Design Documents
**Create:** Structured markdown specs (purpose, entities, API, components, dependencies)

**Manual:** Write design docs following template
**Automated:** Context Design Sessions orchestrator

**Example:** `lib/code_my_spec/documents/context_design.ex`

### Phase 4: Test Generation
**Create:** Test files, fixtures, integration tests

**Manual:** Write tests from design docs
**Automated:** Component Test Sessions orchestrator

**Example:** `test/code_my_spec/stories_test.exs`

### Phase 5: Code Generation
**Create:** Implementation that passes tests

**Manual:** Paste design + tests into LLM, iterate until green
**Automated:** Component Coding Sessions orchestrator

**Example:** `lib/code_my_spec/stories.ex`

---

## Section 4: The Proof

I built CodeMySpec using this method.

- **Stories context**: Generated from design docs
- **Components context**: Generated from design docs
- **Sessions orchestration**: Generated from design docs
- **MCP servers**: Generated from design docs
- **This entire application**: Built with the product

The codebase is the proof. Every module links back to a design document. Every design document links back to user stories.

**Repo:** github.com/your-username/code_my_spec (make it public or show examples)

---

## Section 5: Getting Started

### Manual Process
1. Read "Managing User Stories" guide
2. Create `user_stories.md`
3. Map contexts
4. Write one design doc
5. Write tests
6. Generate code with design + tests

**Time:** 2-4 hours to learn
**Best for:** Learning the method, non-Phoenix projects

### Automated Workflow
1. Install CodeMySpec
2. Run setup session
3. Interview generates stories
4. Review generated designs
5. Approve and generate code

**Time:** 30 minutes setup
**Best for:** Phoenix/Elixir projects, speed

---

## Section 6: FAQ

**Q: What if requirements change?**
Update stories → regenerate designs → update tests → regenerate code. Version control shows impact.

**Q: What about other frameworks?**
Manual process works anywhere. Automation is Phoenix/Elixir only (for now).

**Q: Do I need MCP servers?**
No. Manual process is copy-paste. MCP removes tedium.

**Q: How is this different from Cursor/Windsurf/etc?**
They optimize prompts. This controls context. Different approach.

**Q: What if AI still generates wrong code?**
Tests catch it. Iterate until green. If repeatedly failing, refine design.

---

## Section 7: Related Content

**Main Quest:**
- Managing User Stories ✓
- Context Mapping
- Writing Design Documents
- Workflow Walkthrough

**Side Quest:**
- Stories MCP Server
- Components MCP Server
- Session Orchestration
- CodeMySpec Introduction

---

## Interactive Elements

**1. Methodology Diagram** - 5 phase cards, expandable, toggle manual/automated

**2. Code Examples** - Link directly to GitHub with line numbers

**3. Architecture Graph** - Show CodeMySpec's actual dependency graph
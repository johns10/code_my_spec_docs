# How to write design documents that keep AI from going off the rails

> **Part of the [CodeMySpec Methodology](/methodology)** — This guide covers Phase 3: Design Documents, where architecture transforms into concrete specifications. Learn how one design doc per code file gives you control over AI-generated code.

You've written your user stories. You've mapped them to contexts. Now you need to actually build the thing.

Most developers skip straight to code generation at this point: "Here's my user story and architecture, build it." The AI writes code that compiles, passes surface-level tests, and completely violates your architectural boundaries within a week.

I watched this happen on a clean architecture project. I was using [my first serious coding workflow](/my-first-serious-coding-workflow)

Handed a feature to an LLM with architectural guidelines. Came back to find it had invented its own nested architecture *inside* my infrastructure layer. Compiled fine. Tests passed. Worked. Completely wrong. Took days to untangle because I caught it too late.

The problem: AI generates code without understanding your design. It makes architectural decisions on the fly, invents structure arbitrarily, and if you notice too late, you're committed. IT WILL FUCK THINGS UP.

The solution: write design documents before code. One design doc per code file. The doc describes exactly what the file should do. You iterate on plain English specifications until the design is right, then hand that to the AI to implement.

This is Phase 3 of the methodology: Design Documents.

## My Solution: One Design Doc Per Code File

I write design documents before generating code. Specifically:

- One design document for every code file I'm going to implement
- Structured markdown following a consistent template
- Specific enough that the AI has very little room to improvise
- Iterated with the AI until the design is right (before any code or tests)

For a Phoenix context like `Stories`, this means:

```
docs/design/code_my_spec/stories.md          (context design)
docs/design/code_my_spec/stories/story.md    (schema design)
docs/design/code_my_spec/stories/repo.md     (repository design)
```

Each design doc maps 1:1 to a code file:

```
lib/code_my_spec/stories.ex          (implements stories.md)
lib/code_my_spec/stories/story.ex    (implements story.md)
lib/code_my_spec/stories/repo.ex     (implements repo.md)
```

The design doc is not documentation written *after* coding. It's specification written *before* coding that controls what the AI generates.

## Vertical Slice Makes Architecture Simple

This approach is particularly effective with Phoenix contexts because of how vertical slice architecture works.

**Vertical slice** organizes code by business capability instead of technical layers. Each slice (context) contains everything needed for a feature: data access, business logic, presentation.

**Phoenix contexts** are the implementation. A context like `Stories` or `Components` is one self-contained module handling one business domain.

The key advantage: **there are only two architectural artifacts to reason about**:

1. **Contexts** - The modules organizing your business logic (Stories, Components, Sessions)
2. **Components** - The code files within contexts (schemas, repositories, business logic modules)

That's it. No services layer, no abstract factories, no dependency injection containers. Just contexts and components.

When you define the context in your architecture, you identify its components. When you write design docs, you write one doc per component. The structure is obvious.

## The Design Document Template

Here's the template I use for most components (context modules, business logic, repositories):

```markdown
## Purpose
[1-4 sentences describing what this module does and why it exists]

## Public API
[List the public functions with their specs]

@spec function_name(arg :: type) :: return_type

## Execution Flow
[Step-by-step description of how the main operations work]

1. Validate input
2. Transform data
3. Call dependencies
4. Return result

## Dependencies
[List other modules this depends on]

- CodeMySpec.OtherContext
- CodeMySpec.OtherContext.Schema

## Test Assertions
[Describe what tests should verify]

- describe "function_name/1"
  - test "returns expected result for valid input"
  - test "returns error for invalid input"
  - test "handles edge case X"
```

That's the template. Simple, consistent, covers what the AI needs to know.

## The Process: User Stories → Architecture → Design

Here's my actual workflow for Phase 3:

### Step 1: Start with your architecture and user stories

You already have these from Phases 1 and 2. For example:

**From Phase 1 (User Stories)**:
```markdown
## User Story 2.2: User Story Management
As a developer, I want to create and manage user stories so that
I can define requirements for AI-assisted development.

**Acceptance Criteria:**
- Create stories with title, description, acceptance criteria
- Edit existing stories
- Archive stories no longer relevant
- View all stories for a project
- Link stories to components when implementing
```

**From Phase 2 (Architecture)**:
```markdown
### Stories Context
**Type**: Domain Context
**Entity**: `Story`
**Responsibilities**: User story CRUD, change tracking, scope-based access
**Dependencies**: None
**Components**: Story (schema), Repo (data access), Stories (public API)
```

### Step 2: Design the context with AI

Start a conversation with the AI. Give it everything it needs:

```
I'm designing the Stories context from my architecture.

[Paste executive summary of your application]

[Paste the architecture definition for Stories context]

[Paste the relevant user stories]

[Paste in your ARCHITECTURE.md or whatever]

Follow this design template:
[Paste the template above]

Let's start with the Stories public API module. Write a design document
that describes:
- What functions it exposes
- How it handles scoping (all operations scoped to account/project)
- Error handling patterns
- Dependencies on other contexts

Be specific about function signatures, validation, and edge cases.
```

The AI generates a design. You review it.

### Step 3: Iterate on the design

You're iterating on plain English, not code. The AI helps you consider edge cases, validation, error scenarios. Design changes are text edits. Code changes require refactoring, test updates, and compilation errors.

**For larger features (5+ components)**, use bulk generation:

1. Write brief descriptions of each component you need
2. Ask the AI to generate ALL design docs based on those descriptions
3. Ask the AI to review all the designs together for consistency and integration
4. Review everything yourself at the end

Example prompt:

```
Generate design documents for all components in the Stories context:

1. Stories (public API) - CRUD operations, filtering, scoping
2. Stories.Story (schema) - Fields, validations, associations
3. Stories.Repo (repository) - Scoped queries, preloading

Generate all three design docs following the template. Then review them
together and check:
- Are dependencies consistent?
- Do the public API functions align with the schema?
- Are error handling patterns consistent across components?
- Did we cover all acceptance criteria from the user stories?
```

Let the AI draft everything, review itself, then you review. Much faster than one component at a time.

### Step 4: Save and commit

Save as `docs/design/{module_path}.md` (following the module name). Commit to git. The design is now your source of truth.

## Real Example: Stories Context Design

Here's an excerpt from the actual Stories context design for CodeMySpec:

```markdown
## Purpose
The Stories context provides the public API for managing user stories within
projects. It handles CRUD operations, status tracking, and component associations
while enforcing account and project scoping on all operations.

## Public API

@spec list_stories(scope :: Scope.t(), filters :: map()) ::
  {:ok, [Story.t()]} | {:error, term()}

@spec get_story(scope :: Scope.t(), id :: integer()) ::
  {:ok, Story.t()} | {:error, :not_found}

@spec create_story(scope :: Scope.t(), attrs :: map()) ::
  {:ok, Story.t()} | {:error, Ecto.Changeset.t()}

## Execution Flow

**list_stories/2**:
1. Receive scope (contains account_id and project_id)
2. Build base query filtered by scope
3. Apply additional filters (status, search term)
4. Execute query with preloads
5. Return list of stories

**create_story/2**:
1. Validate scope has active project
2. Merge scope IDs into attributes
3. Build changeset with validations
4. Insert into database
5. Return story or changeset errors

## Dependencies
- CodeMySpec.Stories.Story (schema)
- CodeMySpec.Stories.Repo (scoped queries)
- CodeMySpec.Accounts.Scope (authorization)

## Test Assertions
- describe "list_stories/2"
  - test "returns only stories for the given account and project"
  - test "filters by status when provided"
  - test "returns empty list when no stories exist"
- describe "create_story/2"
  - test "creates story with valid attributes"
  - test "returns error for missing required fields"
  - test "automatically assigns account and project from scope"
```

Notice the specificity: function signatures with types, explicit error cases, clear scope handling, outlined test scenarios. The AI had very little room to improvise.

## Key Benefits

### 1. Save Time (Less Bullshit and Errors)

Design iteration is orders of magnitude faster than code iteration.

When the design is wrong, you fix text. When the code is wrong, you refactor implementations, update tests, fix callers, and deal with compilation errors.

You catch architectural violations immediately by comparing generated code to the design doc. Not three weeks later when other code depends on it.

### 2. Better AI Output

The AI generates significantly better code when working from detailed design docs.

Without design: "Implement the Stories context from the architecture."
→ AI invents structure, makes assumptions, creates implicit dependencies

With design: "Implement the Stories module following this design document."
→ AI follows the specification, uses prescribed patterns, minimal improvisation

The design doc is specific about function signatures, error handling, validation, and edge cases. The AI fills in implementation details but doesn't invent structure.

### 3. Architecture Enforcement

The design doc enforces your architecture. If the design says "Stories depends on Repo but not on Components," the AI can't add a dependency on Components without you noticing immediately.

Your architecture defines contexts. Your design docs define components within those contexts. The structure is explicit and enforceable.

### 4. Team Understanding and Alignment

Design docs are documentation that describes what each code file is supposed to do. They're possibly more important than the code itself.

A developer joining your team reads the design docs and understands:
- What this module does
- How it fits into the architecture
- What other modules it depends on
- What edge cases were considered

Code shows *how* something is implemented. Design docs show *why* and *what* it's supposed to do.

### 5. Easy Regeneration

With design docs, you can regenerate code at any time:
- Switching from Ecto to a different ORM? Regenerate from designs.
- Major refactoring needed? Regenerate from updated designs.
- AI generated broken code? Delete it and regenerate from the working design.

The design is the source of truth. Code is generated output that can be thrown away and recreated.

## Common Patterns

**Start with contexts, then components.** Design the context module first (public API), then the components it needs (schema, repo, business logic).

**Reference acceptance criteria from user stories.** Create traceability: User Story → Context → Design Doc → Code.

**Be specific about error handling.** Don't write "Returns error on failure." Write specific error types and when they occur.

**Include edge cases in test assertions.** These become Phase 4 tests.

## Making It Work

**Use git.** Commit design docs to `docs/design/`. Version control shows how your understanding evolved.

**Design before code, always.** Never generate code without a design doc.

**Start changes with design.** When changing something, update the design doc first, then regenerate code.

**Ask: design problem or implementation problem?** Fix design problems by updating docs and regenerating. Fix implementation problems by adjusting prompts.

## Next Steps

You now have Phase 1 (User Stories), Phase 2 (Architecture), and Phase 3 (Design Documents).

Next: **Test Generation** (Phase 4). Write tests from design docs before generating code. The tests verify the public API, edge cases, and error scenarios.

Then Phase 5: generate code that makes tests pass. Design defines what to build. Tests verify it works. AI generates implementation.

See [The CodeMySpec Method](/methodology) for the complete methodology.

See [Test-First AI Code Generation](/content/test_first_ai_generation) for Phase 4 (coming soon).
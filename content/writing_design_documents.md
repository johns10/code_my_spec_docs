# How to write design documents that keep AI from going off the rails

> **Part of the [CodeMySpec Methodology](/methodology)** — Phase 3: Design Documents.

You've written your stories. You've mapped them to contexts. Now you need to build the thing.

Most developers skip straight to code: "Here's my user story and architecture, build it." The AI writes code that compiles, passes tests, and completely violates your boundaries within a week.

I watched it happen. Handed a feature to an LLM with architectural guidelines. Came back to find it had invented its own nested architecture *inside* my infrastructure layer. Compiled fine. Tests passed. Worked. Completely wrong. Took days to untangle.

Here's the thing. AI generates code without understanding your design. It makes architectural decisions on the fly. If you notice too late, you're committed.

The fix: write design documents before code. One per code file. Iterate on plain English until the design is right, then hand it to AI to implement.

## One Design Doc Per Code File

For a Phoenix context like `Stories`:

```
.code_my_spec/spec/code_my_spec/stories.spec.md       (context design)
.code_my_spec/spec/code_my_spec/stories/story.spec.md  (schema design)
.code_my_spec/spec/code_my_spec/stories/repo.spec.md   (repository design)
```

Each maps 1:1 to a code file:

```
lib/code_my_spec/stories.ex
lib/code_my_spec/stories/story.ex
lib/code_my_spec/stories/repo.ex
```

The design doc is specification written *before* coding. Not documentation written after.

## Document Types in CodeMySpec

CodeMySpec's Documents Registry supports 17 document types: spec, context_spec, schema, json, liveview, liveview_component, live_context_spec, dynamic_document, design_review, architecture_proposal, adr, qa_plan, qa_story_brief, qa_result, qa_issue, qa_journey_plan, and qa_journey_result.

Each type defines required and optional sections. The DocumentValidityChecker and MarkdownParser validate them automatically. Documents live in `.code_my_spec/spec/`.

## The Design Template

```markdown
## Purpose
[1-4 sentences: what this module does and why]

## Public API
@spec function_name(arg :: type) :: return_type

## Execution Flow
1. Validate input
2. Transform data
3. Call dependencies
4. Return result

## Dependencies
- CodeMySpec.OtherContext
- CodeMySpec.OtherContext.Schema

## Test Assertions
- describe "function_name/1"
  - test "returns expected result for valid input"
  - test "returns error for invalid input"
  - test "handles edge case X"
```

Simple. Consistent. Covers what the AI needs.

## The Process

### Step 1: Start with architecture and stories

You have these from Phases 1 and 2.

### Step 2: Design with AI

Give it everything: executive summary, architecture definition, relevant stories, the template. Ask for specific function signatures, scope handling, error patterns, edge cases.

### Step 3: Iterate on English, not code

This is where the real value lives. Design changes are text edits. Code changes require refactoring, test updates, and compilation errors.

For larger features (5+ components), use bulk generation. Have the AI draft all design docs at once, review them together for consistency, then you review at the end. Much faster than one at a time.

### Step 4: Commit

Save to `.code_my_spec/spec/`. The design is now your source of truth.

## Real Example: Stories Context

```markdown
## Purpose
The Stories context provides the public API for managing user stories.
It handles CRUD operations, status tracking, and component associations
while enforcing account and project scoping.

## Public API

@spec list_stories(scope :: Scope.t(), filters :: map()) ::
  {:ok, [Story.t()]} | {:error, term()}

@spec create_story(scope :: Scope.t(), attrs :: map()) ::
  {:ok, Story.t()} | {:error, Ecto.Changeset.t()}

## Execution Flow

**create_story/2**:
1. Validate scope has active project
2. Merge scope IDs into attributes
3. Build changeset with validations
4. Insert into database
5. Return story or changeset errors

## Test Assertions
- describe "list_stories/2"
  - test "returns only stories for the given account and project"
  - test "filters by status when provided"
- describe "create_story/2"
  - test "creates story with valid attributes"
  - test "returns error for missing required fields"
  - test "automatically assigns account and project from scope"
```

Function signatures with types. Explicit error cases. Clear scope handling. Outlined test scenarios. Very little room for AI to improvise.

## Why This Works

**Design iteration is faster than code iteration.** When the design is wrong, you fix text. When the code is wrong, you refactor everything.

**Better AI output.** Without a design doc, the AI invents structure. With one, it follows your specification.

**Architecture enforcement.** If the design says "Stories depends on Repo but not Components," the AI can't sneak in extra dependencies without you noticing.

**Easy regeneration.** Design docs are the source of truth. Code is generated output. You can trash it and regenerate from a working design.

## Making It Work

**Design before code, always.** Never generate code without a design doc.

**Start changes with design.** Update the doc first, then regenerate.

**Ask yourself: design problem or implementation problem?** Fix design problems by updating docs. Fix implementation problems by adjusting prompts.

## Next Steps

You now have Phase 1 (Stories), Phase 2 (Architecture), and Phase 3 (Design Documents).

Next: write tests from design docs before generating code. Tests verify the public API, edge cases, and error scenarios. Then generate code that makes tests pass.

See [The CodeMySpec Method](/methodology) for the complete methodology.

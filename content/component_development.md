# Component Development: One File at a Time

> **Part of the [Five Levels of AI-Assisted Development](/blog/five-levels-of-ai-coding)** -- Level 2: Pair Programming.

You've got your architecture. You've got your stories mapped to bounded contexts. Now you need to turn those into working code.

The temptation is to say "build the whole thing" and let the AI go. That's Level 3. We're not there yet. At Level 2, you're pair programming -- you and the AI take turns, one artifact at a time. You stay in the driver's seat. The AI does the typing. Each step has a safety net so the AI can't silently drift off course.

CodeMySpec gives you three commands for this: write a spec, generate the code, write the tests. One command, one file, one validation loop.

## The 1:1:1 Principle

Every component in your system produces exactly three artifacts:

```
.code_my_spec/spec/my_app/accounts.spec.md    (spec)
lib/my_app/accounts.ex                         (code)
test/my_app/accounts_test.exs                  (test)
```

One spec file. One code file. One test file. The spec is the source of truth. The code implements it. The tests verify it. If you want to change behavior, you change the spec first, then regenerate.

This keeps things tractable. You're never asking "which of these 14 files does the AI need to understand?" It's always three files per component. The relationships are obvious.

## Step 1: Write the Spec

The `component_spec` command generates a design document for a single component. You tell it which component, and it builds a prompt that includes:

- **Design rules** for that component type (context, schema, repository, etc.)
- **Document schema** -- the required and optional sections the spec must contain
- **Project context** -- what the project is, what it does
- **Parent component** -- if this is a child (like a schema inside a context), it references the parent's spec
- **Existing state** -- whether an implementation or tests already exist

The AI writes a markdown spec file. Then the evaluation kicks in.

### What the Evaluation Checks

After the AI generates the spec, CodeMySpec runs artifact requirement checks. It reads the generated file back, validates it against the document schema for that component type, and checks for known problems like missing required sections.

If something's wrong -- a required section is missing, the format doesn't match the schema -- it sends structured feedback back to the AI with exactly what failed. The AI fixes it. This loop continues until the spec passes validation.

You're not reading the spec to check formatting. The system does that. You're reading it to check whether the *design* is right. That's the part machines can't verify yet.

### What a Spec Looks Like

Here's a real spec for a Stories context:

```markdown
# MyApp.Stories

## Type

context

## Functions

### list_stories/1

Returns all stories for the active project in scope.

@spec list_stories(Scope.t()) :: [Story.t()]

**Process**:
1. Delegate to configured implementation module
2. Return list of stories for the project

**Test Assertions**:
- returns all stories for the project
- returns empty list when no stories exist
- respects project scope

### create_story/2

@spec create_story(Scope.t(), attrs :: map()) ::
  {:ok, Story.t()} | {:error, Ecto.Changeset.t()}

**Process**:
1. Validate scope has active project
2. Merge scope IDs into attributes
3. Build changeset with validations
4. Insert into database
5. Return story or changeset errors

**Test Assertions**:
- creates story with valid attributes
- returns error for missing required fields
- automatically assigns account and project from scope
```

Function signatures with types. Execution flow as numbered steps. Test assertions that become your test cases. Very little ambiguity about what the AI should build.

The Test Assertions section is important. Those aren't suggestions. They're the exact test cases that will be written and validated in step 3. If your spec says "returns error for missing required fields," the test file must contain that test, and the describe block must match the function signature exactly.

## Step 2: Generate the Code

The `component_code` command takes a component that already has a spec and generates the implementation. The prompt it builds includes:

- **Spec file path** -- the AI reads your design document
- **Test file path** -- if tests exist already (TDD style), the AI reads those too
- **Coding rules** for that component type
- **Similar components** -- other components of the same type in your project, so the AI can follow established patterns

The instructions are explicit: read the spec, read the tests, implement the public API, follow patterns from similar components. The AI isn't inventing architecture. It's filling in the implementation for a design you already approved.

### What the Evaluation Checks

After generation, the system checks code artifact requirements. Does the file exist? Are there compilation errors? Does Credo flag anything? Are there problems in the implementation files?

The feedback loop works the same way as specs. If requirements aren't satisfied, the AI gets structured feedback and tries again. Problems from static analysis -- compilation errors, credo warnings -- get surfaced as actionable feedback.

### The Pattern Matching Trick

When the system finds similar components, it gives the AI their spec, code, and test file paths. This is how consistency emerges. Your first context might be a bit rough. By your fifth, the AI is copying patterns from the first four. The similar components act as implicit style guides without you writing a style guide.

## Step 3: Write the Tests

The `component_test` command generates tests. This is where the spec-driven approach pays off most directly.

The prompt includes:

- **Spec file path** -- the test assertions section is the contract
- **Parent component spec** -- for understanding the broader context
- **Test rules** for the component type
- **Similar components** for test pattern inspiration
- **TDD awareness** -- whether the implementation exists yet

That last point matters. If the implementation doesn't exist, the AI writes tests TDD-style: only the test cases defined in the spec's Test Assertions section. If the implementation already exists, it writes tests that validate the existing code against the design. Different prompt, same command.

### What the Evaluation Checks

Test evaluation checks artifact requirements and looks for problems in the test file. But it's smart about what counts as a problem. Test failures are filtered out during evaluation because failing tests are *expected* in TDD mode when no implementation exists yet. Compilation errors, credo warnings, and spec alignment issues are still caught.

Spec alignment is the key guardrail here. The system checks that describe blocks in the test file match the function signatures in the spec, and that the test names match the Test Assertions. If you wrote a test for a function that isn't in the spec, or you skipped an assertion that the spec requires, that's flagged.

### The TDD Constraint

When the implementation doesn't exist yet, the AI gets this instruction: "Only write the tests defined in the Test Assertions section of the design. If you want to write more cases, you must modify the design first."

This is deliberate. The spec is the contract. Tests verify the contract. If you think a test case is missing, that's a signal that the spec is incomplete. Go back to step 1 and update the spec. Don't let the test file become the source of truth.

## The Guardrails

Three things keep this process honest:

**Schema validation on specs.** Every component type has a document schema with required and optional sections. The DocumentSpecProjector generates the schema requirements, and the evaluation loop enforces them. You can't ship a context spec that's missing its Functions section.

**Artifact requirement checking.** Each step has explicit requirements. The spec must exist and be valid before you generate code. The spec and tests inform the code. Requirements are checked both from persisted state and by running live checkers as a fallback. If requirements for a step aren't met, you get told what's missing.

**BDD spec alignment.** Test describe blocks must match function signatures from the spec. Test names must match the Test Assertions. This is mechanical verification that the tests actually test what the spec says they should. No drift between what you designed and what you're verifying.

When a check fails, you don't get a vague "something's wrong." You get structured feedback: which requirement failed, what the system expected, what it found instead. The AI gets the same feedback and can act on it.

## When This Works Best

Component development works well when you're building something new and want to be deliberate about it. You write the spec, think about the design, make sure it fits your architecture. Then you let the AI implement it while the guardrails keep it honest.

It also works well for learning a codebase's patterns. Watch what the AI generates for the first few components. Adjust your rules and specs. By the time you've built a handful of components, the similar-component matching means everything is consistent.

Where it gets tedious: a context with twelve child components. Running three commands per component, reviewing each one, waiting for the evaluation loops. That's 36 command invocations for one bounded context. You're still the bottleneck.

## Moving to Level 3

When you're tired of driving one file at a time, that's the signal to move up. The `develop_context` command takes an entire bounded context and orchestrates all the component development for you -- specs, design review, implementation, tests -- walking the component tree in dependency order. You review the output as a whole instead of line by line.

But you need to earn that. Level 2 is where you learn what good specs look like, what the guardrails catch, and what they miss. You build the intuition for when a spec is right before code exists. That intuition is what makes Level 3 review effective.

Start here. Do a few components manually. When the process feels mechanical, you're ready.

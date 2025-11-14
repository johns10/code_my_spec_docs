# r/elixir Post: The 1:1:1 Rule (Elixir-Inspired)

## Campaign Context
- **Campaign**: Journey Series (Main Quest)
- **Article**: "How to Write Design Documents That Keep AI From Going Off the Rails"
- **Target Community**: r/elixir
- **Goal**: Drive traffic to Phase 3 article, establish credibility with Elixir community, acknowledge Elixir inspiration

---

## Title Options (Test These)

**Primary (Most Likely to Hit):**
"Took Elixir's One-File-One-Test Convention and Extended It to Control AI Code Generation"

**Alternatives:**
1. "How Elixir's Testing Convention Inspired My Approach to AI-Generated Code"
2. "The 1:1:1 Rule: Extending Elixir's Test Convention to Include Design Docs"
3. "What Elixir's File Conventions Taught Me About Controlling AI Agents"

**Selection Criteria:**
- Acknowledges Elixir inspiration (respect)
- Technical and specific
- Professional tone
- Clear value proposition

---

## Post Structure

### Opening: The Context & Credit

**Acknowledge the inspiration:**
```
I've been working on controlling AI code generation in my Phoenix projects, and realized I was basically extending one of Elixir's best conventions: one code file, one test file.

The problem I kept running into: AI agents would implement features correctly at the function level, but make terrible architectural decisions. I'd give them high-level architecture and ask for code, and they'd fill in the middle layer with their own structure. Some good, some terrible, all inconsistent.
```

**The specific failure case:**
```
The breaking point was an MCP server project in C#. I handed a developer my process (planning docs, guidelines, architecture), he followed it exactly, had the AI generate an infrastructure component.

The AI invented its own domain-driven design architecture INSIDE the infrastructure layer. Complete with entities and services that had no business being there. Compiled fine, tests passed, completely wrong architecturally.

Took 3 days to untangle because other code had already started depending on this nested structure.
```

### Middle: The Solution (Elixir-Inspired)

**The realization:**
```
I realized I needed something between architecture and code. Design specifications. And that's when Elixir's convention clicked for me.

Elixir already has the pattern:
- One code file
- One test file

I extended it:
- One design doc
- One code file
- One test file

For Phoenix projects, this looks like:

docs/design/my_app/accounts/user.md
lib/my_app/accounts/user.ex
test/my_app/accounts/user_test.exs

The design doc describes:
- Purpose (what and why this module exists)
- Public API (@spec function signatures)
- Execution Flow (step-by-step operations)
- Dependencies (what this calls)
- Test Assertions (what tests should verify)
```

### The Technical Details (Code Examples)

**Example design doc structure:**
```markdown
## Purpose
The User schema provides the core user entity for the Accounts context,
handling authentication, profile data, and account associations.

## Fields
| Field           | Type     | Purpose                      |
| --------------- | -------- | ---------------------------- |
| email           | string   | Primary identifier, unique   |
| hashed_password | string   | Bcrypt hash                  |
| confirmed_at    | datetime | Email confirmation timestamp |

## Validation Rules
- Email: required, unique, format validation
- Password: min 12 chars, complexity requirements

## Associations
- belongs_to :account, Account
- has_many :sessions, Session

## Test Assertions
- describe "changeset/2"
  - test "validates required fields"
  - test "validates email format"
  - test "hashes password on valid changeset"
```

### Results (Specific to Phoenix/Elixir)

**What actually changed:**
```
After 2 months using this on my Phoenix projects:

- AI architectural violations: Zero. I catch them in design review before any code exists.
- Time debugging AI-generated code: Down ~60%. The AI has explicit specs to follow.
- Code regeneration: Trivial. Delete the .ex file, regenerate from design doc.
- Context boundary violations: None. Dependencies are explicit in the design.

The interesting part: it doesn't matter which AI model I use. Claude, GPT, they all follow design specs equally well. The design document is doing the work, not the model.
```

### The Workflow Integration

**How it fits Phoenix development:**
```
This pairs naturally with Phoenix's context-driven architecture:

1. Define contexts in docs/architecture.md (domain vs coordination contexts)
2. For each context, create a context design doc (purpose, entities, API)
3. For each component in the context, create a component design doc
4. Generate tests from design assertions
5. Generate code that makes tests pass

The 1:1:1 mapping makes it obvious:
- Missing design doc? Haven't specified what this should do yet.
- Missing test? Haven't defined how to verify it.
- Missing code? Haven't implemented it yet.

Everything traces back. User story � context � design � test � code.
```

### The Product Mention (Minimal, Technical)

**Natural integration:**
```
I've been doing this manually (pairing with Claude to write design docs, then using them for code generation). Recently started building CodeMySpec to automate the workflowit generates designs from architecture, validates against schemas, spawns test sessions, etc.

But the manual process works fine. You don't need tooling. Just markdown files following this convention.

The key insight: iterate on design (fast text edits) instead of code (refactoring, test updates, compilation).
```

### Ending: Technical Discussion

**Genuine questions:**
```
Curious if others in the Elixir community are doing something similar? I know about docs/adr/ for architectural decisions, but haven't seen one design doc per implementation file.

Also wondering about the best way to handle design docs for LiveView components vs regular modulesshould they have different templates given their lifecycle differences?
```

---

## Full Post Draft

```markdown
# Took Elixir's One-File-One-Test Convention and Extended It to Control AI Code Generation

I've been working on controlling AI code generation in my Phoenix projects, and realized I was basically extending one of Elixir's best conventions: one code file, one test file.

The problem I kept running into: AI agents would implement features at the function level, but make terrible architectural decisions. I'd give them high-level architecture and ask for code, and they'd fill in the middle layer with their own structure. Some good, some terrible, all inconsistent.

## The Breaking Point

The worst was an MCP server project in C#. I handed a developer [my process](https://codemyspec.com/content/my-first-serious-coding-workflow?utm_source=reddit&utm_medium=post&utm_campaign=journey_series&utm_content=main_quest_03_backstory) (planning docs, guidelines, architecture). He followed it exactly, had the AI generate an infrastructure component.

The AI invented its own domain-driven design architecture INSIDE the infrastructure layer. Complete with entities and services that had no business being there. [Here's the PR](https://github.com/johns10/AstralMcp/commit/4f316df391de0dbf279f12fbcd78a44202a8df5f) if you want to see the architectural mess.

Compiled fine, tests passed, completely wrong architecturally. Took 3 days to untangle because other code had already started depending on this nested structure.

## The Solution: Extend Elixir's Convention

I realized I needed something between architecture and code. Design specifications. And that's when Elixir's convention clicked for me.

**Elixir already has the pattern:**
- One code file
- One test file

**I extended it:**
- One design doc
- One code file
- One test file

For Phoenix projects:

```
docs/design/my_app/accounts/user.md
lib/my_app/accounts/user.ex
test/my_app/accounts/user_test.exs
```

The design doc describes:
- **Purpose** - what and why this module exists
- **Public API** - @spec function signatures
- **Execution Flow** - step-by-step operations
- **Dependencies** - what this calls
- **Test Assertions** - what tests should verify

## Example Design Doc

```markdown
# Orchestrator

## Purpose

Stateless orchestrator managing the sequence of context testing steps, determining workflow progression based on completed interactions. Implements the OrchestratorBehaviour to coordinate child ComponentTestingSession spawning, validation loops, and finalization for comprehensive context-level test completion.

## Public API

# OrchestratorBehaviour implementation
@spec steps() :: [module()]
@spec get_next_interaction(session :: Session.t()) ::
        {:ok, module()} | {:error, :session_complete | atom()}
@spec complete?(session_or_interaction :: Session.t() | Interaction.t()) :: boolean()

## Execution Flow

### Workflow State Machine

1. **Session Initialization**
   - If no interactions exist, return first step (Initialize)
   - Otherwise, find last completed interaction to determine current state

2. **Next Step Determination**
   - Extract result status from last completed interaction
   - Extract step module from last completed interaction command
   - Apply state machine rules to determine next step

3. **State Machine Rules**
   - **Initialize**:
     - Status `:ok` → Proceed to SpawnComponentTestingSessions
     - Any other status → Retry Initialize

   - **SpawnComponentTestingSessions**:
     - Status `:ok` → Validation passed, proceed to Finalize
     - Status `:error` → Validation failed, loop back to SpawnComponentTestingSessions
     - Any other status → Retry SpawnComponentTestingSessions

   - **Finalize**:
     - Status `:ok` → Return `{:error, :session_complete}` (workflow complete)
     - Any other status → Retry Finalize

4. **Completion Detection**
   - Session is complete when last interaction is Finalize step with `:ok` status
   - Can check either Session (uses last interaction) or specific Interaction

### Child Session Coordination

The orchestrator manages child ComponentTestingSession lifecycle through SpawnComponentTestingSessions step:

1. **Spawning Phase**: SpawnComponentTestingSessions.get_command/3 creates child sessions
2. **Monitoring Phase**: Client monitors child sessions until all reach terminal state
3. **Validation Phase**: SpawnComponentTestingSessions.handle_result/4 validates outcomes
4. **Loop Decision**:
   - All children `:complete` and tests pass → Return `:ok`, advance to Finalize
   - Any failures detected → Return `:error`, loop back to spawn new attempts

## Test Assertions

- describe "steps/0"
  - test "returns ordered list of step modules"
  - test "includes Initialize, SpawnComponentTestingSessions, and Finalize"

- describe "get_next_interaction/1"
  - test "returns Initialize when session has no interactions"
  - test "returns SpawnComponentTestingSessions after successful Initialize"
  - test "returns Finalize after successful SpawnComponentTestingSessions"
  - test "returns session_complete error after successful Finalize"
  - test "retries Initialize on Initialize failure"
  - test "loops back to SpawnComponentTestingSessions on validation failure"
  - test "retries Finalize on Finalize failure"
  - test "returns invalid_interaction error for unknown step module"
  - test "returns invalid_state error for unexpected status/module combination"

- describe "complete?/1 with Session"
  - test "returns true when last interaction is Finalize with :ok status"
  - test "returns false when last interaction is Initialize"
  - test "returns false when last interaction is SpawnComponentTestingSessions"
  - test "returns false when Finalize has non-ok status"
  - test "returns false when session has no interactions"

- describe "complete?/1 with Interaction"
  - test "returns true for Finalize interaction with :ok status"
  - test "returns false for Finalize interaction with :error status"
  - test "returns false for Initialize interaction"
  - test "returns false for SpawnComponentTestingSessions interaction"
  - test "returns false for any non-Finalize interaction"
```

Once the design doc is solid, I tell the AI to write fixtures, tests, and implement this design document following Phoenix patterns.

The AI has explicit specs. Very little room to improvise.

## Results (Phoenix Projects)

After 2 months using this workflow:

- **AI architectural violations**: Zero. I typically catch them in design review before any code. If we get to implementation, they're trivial to spot, because it usually involves the LLM creating files that I didn't direct it to in that conversation.
- **Time debugging AI-generated code**: Down significantly. Less improvisation = fewer surprises. I know where everything lives.
- **Code regeneration**: Trivial. Delete the `.ex` file, regenerate from design.
- **Context boundary violations**: None. Dependencies are explicit in the design.

The interesting part: non-frontier models follow design specs pretty well. The design document is doing the work, not the model.

## How It Fits Phoenix Development

This pairs naturally with Phoenix's context-driven architecture:

1. Define contexts in `docs/architecture.md` (see previous posts for more info)
2. For each context, create a context design doc (purpose, entities, API)
3. For each component, create a component design doc
4. Generate tests from design assertions
5. Generate code that makes tests pass

The 1:1:1 mapping makes it obvious:
- Missing design doc? Haven't specified what this should do yet.
- Missing test? Haven't defined how to verify it.
- Missing code? Haven't implemented it yet.

Everything traces back: User story -> context -> design -> test -> code.

## The Manual Process

I've been doing this manually: pairing with Claude to write design docs, then using them for code generation. Recently started using the methodology to build [CodeMySpec](https://codemyspec.com?utm_source=reddit&utm_medium=post&utm_campaign=journey_series&utm_content=main_quest_03_1_1_1_rule) to automate the workflow (generates designs from architecture, validates against schemas, spawns test sessions).

But the manual process works fine. You don't need tooling. Just markdown files following this convention.

The key insight: **iterate on design (fast text edits) instead of code (refactoring, test updates, compilation).**

Wrote up the full process here: [How to Write Design Documents That Keep AI From Going Off the Rails](https://codemyspec.com/content/writing-design-documents?utm_source=reddit&utm_medium=post&utm_campaign=journey_series&utm_content=main_quest_03_1_1_1_rule)

## Questions for the Community

Curious if others in the Elixir community are doing something similar? I know about `docs/adr/` for architectural decisions, but haven't seen one design doc per implementation file.

Also wondering about the best way to handle design docs for LiveView components vs regular modules. Should they have different templates given their lifecycle differences? I've really arrived at good methods for generating `my_app` code, but less for the `my_app_web` code.
```

---

## Comment Response Strategy

### Professional, Technical Engagement

**When someone asks about overhead:**
```
I had the same concern initially. But iterating on markdown is significantly faster than debugging generated code.

Example: Realize I need to add a field to User schema?
- Design iteration: Add row to Fields table (30 seconds)
- Code iteration: Modify schema, update changeset, update tests, run migrations, fix integration tests (15+ minutes)

The design iteration catches architectural issues before any Ecto migrations are run.
```

**When someone asks about LiveView specifics:**
```
Great question. For LiveView components, I've been adding lifecycle-specific sections:

- Mount Flow (socket setup, assigns initialization)
- Event Handlers (handle_event/3 specs)
- State Management (what's in assigns vs process state)
- Component Communication (send vs PubSub patterns)

Still refining the template though. Have you found patterns that work well?
```

**When someone mentions they use different approach:**
```
Interesting approach with [their method]. How do you handle [relevant technical question about their approach]?

I like the idea of [specific thing they mentioned]. One challenge I ran into was [technical concern]curious how you handle that.
```

**When someone asks about the tool:**
```
It's orchestration around the manual workflow. AI agents generate designs from architecture definitions, validate against schemas (catches missing sections, invalid module names), revision loops if validation fails, commits to git.

The validation is built around Phoenix patternsensures contexts define proper boundaries, components have valid dependencies, etc.

But honestly, 80% of the value comes from the discipline of writing designs first. The tooling just removes repetitive work.

Repo: https://github.com/johns10/code_my_spec
CodeMySpec site: https://codemyspec.com?utm_source=reddit&utm_medium=comment&utm_campaign=journey_series&utm_content=main_quest_03_1_1_1_rule
```

**When someone asks about Ecto/database patterns:**
```
For Ecto patterns, the design doc includes:

- Schema fields with types and purposes
- Changeset validations
- Database constraints
- Association definitions

Then in Test Assertions, I specify what the changeset tests should verify. The AI generates the actual Ecto code that satisfies both the schema design and test requirements.

The nice part: if I realize the schema design is wrong, I update the markdown and regenerate. No manual migration rollbacks or changeset refactoring.
```

---

## Red Flags to Avoid in Comments

L **Don't**:
- Be defensive about criticism
- Over-promote the product
- Dismiss Elixir-specific concerns
- Use casual language ("lol", "tbh")
- Claim this is revolutionary

 **Do**:
- Use proper grammar and capitalization
- Acknowledge limitations honestly
- Engage with technical depth
- Ask genuine questions
- Reference Phoenix/Ecto patterns correctly
- Link to code examples

---

## Timing

**Post Schedule:**
- Tuesday-Thursday, 8-10am EST
- Avoid Mondays and Fridays
- Check for competing posts (new Phoenix/Elixir releases)

**Best Time for This Post:**
Wednesday, 9am EST - catches US/Europe overlap, gives full day for engagement

---

## Success Metrics

**Minimum Success:**
- 20+ upvotes
- 10+ comments
- 200+ article views
- Positive technical discussion

**Good Success:**
- 50+ upvotes
- 25+ comments
- 750+ article views
- Community members try the approach

**Home Run:**
- 100+ upvotes
- 50+ comments
- 1500+ article views
- Referenced in Elixir Forum or Discord

---

## Cultural Notes for r/elixir

### Critical Differences from r/ChatGPTCoding:

**Tone:**
- Professional, not casual
- Proper grammar and capitalization
- Technical precision required
- No "lol" or casual slang

**Content Expectations:**
- Code examples expected
- Link to GitHub repo adds credibility
- Phoenix/Ecto patterns must be correct
- Acknowledge limitations honestly

**Community Values:**
- Stability over bleeding edge
- Pragmatism over hype
- Production experience matters
- Respect for BEAM/OTP heritage

**What Resonates:**
- Real projects with technical depth
- Honest comparisons and tradeoffs
- Solutions to actual problems
- References to established patterns

**What Falls Flat:**
- Hype without substance
- Generic AI/automation claims
- Ignoring Phoenix/Ecto conventions
- Pure self-promotion

---

## Follow-Up Content (If This Hits)

If this post performs well, potential follow-ups:

1. **2 weeks later**: "Design Document Templates for Phoenix Contexts vs Components" (educational, code-heavy)
2. **Month later**: "3 Months of Design-First AI Development in Phoenix: Results and Lessons" (experience report)
3. **6 weeks later**: "How CodeMySpec Uses OTP to Orchestrate AI Design Sessions" (technical deep-dive)

Space them out significantly. r/elixir has lower volume than r/ChatGPTCoding, so posts have longer visibility.

---

## Notes

- This post respects Elixir's conventions and acknowledges the inspiration
- Professional tone matching r/elixir culture
- Technical depth with code examples
- Links to real repos and commits (credibility)
- Product mention is minimal and technical, not promotional
- Genuine questions invite community discussion
- Shows understanding of Phoenix/Ecto patterns
- Honest about limitations and tradeoffs

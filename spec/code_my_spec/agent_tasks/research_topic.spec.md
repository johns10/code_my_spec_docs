# CodeMySpec.AgentTasks.ResearchTopic

## Type

module

Per-topic agent task for deep research on a technology decision. Generates a self-contained research prompt that includes the full research methodology, evaluation criteria, and output format. The prompt file is written to a status directory and picked up by whatever subagent the orchestrator dispatches — no specific subagent is required.

In the requirement flow, this task runs AFTER TechnicalStrategy has created the ADR. Its job is deep research: searching Hex.pm, reading official docs, evaluating community health, and producing knowledge entries. The ADR already exists and provides context for the research.

Produces:
- `.code_my_spec/knowledge/{topic}/` — knowledge entries (getting_started.md, configuration.md, patterns.md, etc.)

Cleans up `.code_my_spec/status/research/{topic}.md` on successful validation.

Subsume useful information from `/Users/johndavenport/Documents/github/code_my_spec_cli/CodeMySpec/agents/researcher.md` as it will be deprecated.

## Functions

### command/3

Generate the self-contained research prompt for a single topic. The prompt includes all research methodology, evaluation criteria, and output templates so the executing agent needs no external instructions.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Extract topic from `session.state["topic"]`
2. Read the freeform research brief from `.code_my_spec/status/research/{topic}.md` (nil if absent)
3. Read `mix.exs` for dependency context
4. Read the existing ADR from `.code_my_spec/architecture/decisions/{topic}.md` for decision context
5. Check for existing knowledge entries in `.code_my_spec/knowledge/{topic}/`
6. Assemble prompt sections:
   - Header with topic name
   - Decision context section (embed the ADR content so the researcher understands what was decided and why)
   - Research brief section (if freeform prompt exists)
   - Current dependencies section (if mix.exs exists)
   - Existing knowledge section (if prior entries exist, instruct to update not duplicate)
   - Research methodology:
     1. **Search Hex.pm** — find the package on hex.pm, check download count, last release date, maintenance status, open issues count
     2. **Read official documentation** — fetch the package's HexDocs or GitHub README for setup guides, configuration options, and API surface
     3. **Inspect project context** — read `mix.exs` for current deps and Elixir/OTP versions, check `config/` for existing patterns, scan `lib/` and `test/` for relevant usage
     4. **Compare alternatives** — if the topic is a category (e.g., "HTTP client") rather than a specific library, search for and compare the top 2-3 options
     5. **Check community health** — search Elixir Forum, GitHub issues/discussions for known problems, migration guides, or endorsements
   - Evaluation criteria:
     - **Compatibility** — works with current stack (Phoenix 1.8, LiveView 1.1, OTP version)?
     - **Maintenance** — actively maintained? Releases in last 6 months?
     - **Community** — good docs? Responsive maintainer? Adoption level?
     - **Complexity** — setup burden? Ongoing maintenance cost?
     - **Testing** — how does it affect the test suite? ExVCR compatible?
   - Output instructions:
     1. **Write knowledge entries** — write to `.code_my_spec/knowledge/{topic}/` with one file per sub-topic (e.g., `getting_started.md`, `configuration.md`, `patterns.md`); include code examples relevant to the project; focus on practical, actionable information
     2. **Update the ADR if needed** — if research reveals new information, update the existing decision record at `.code_my_spec/architecture/decisions/{topic}.md`
   - Stop instruction
   - Does NOT reference a specific subagent by name

**Test Assertions**:
- returns ok tuple with non-empty prompt string
- includes topic name in prompt
- includes ADR content as decision context
- includes research brief when one exists
- omits research brief section when none exists
- includes mix.exs content when available
- references existing knowledge entries and instructs to update not duplicate
- includes Hex.pm search instructions with specific checks (downloads, last release, maintenance)
- includes official documentation fetch instructions
- includes project inspection instructions (mix.exs, config/, lib/, test/)
- includes alternative comparison instructions
- includes community health check instructions (Elixir Forum, GitHub)
- includes evaluation criteria (compatibility, maintenance, community, complexity, testing)
- includes knowledge entry writing instructions with file-per-subtopic pattern
- does NOT reference a specific subagent by name

### evaluate/3

Validate the topic has knowledge entries.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()}
```

**Process**:
1. Extract topic from `session.state["topic"]`
2. Check knowledge entries exist in `.code_my_spec/knowledge/{topic}/` (at least one file)
3. If knowledge exists, clean up the research prompt file at `.code_my_spec/status/research/{topic}.md` and return `{:ok, :valid}`
4. If no knowledge, return `{:ok, :invalid, feedback}` indicating the topic needs knowledge entries

**Test Assertions**:
- returns `{:ok, :valid}` when knowledge entries exist for the topic
- returns `{:ok, :invalid, feedback}` when no knowledge entries exist
- cleans up research prompt file on successful validation
- does not clean up research prompt when validation fails
- raises when session has no topic in state

## Dependencies

- CodeMySpec.Environments
- CodeMySpec.Paths

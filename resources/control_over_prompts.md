# Control Over Prompts: Research Resources

## Research Summary

This document contains research and resources gathered for the article "Code Generation is About Control, Not Prompts."

## Current LLM Code Generation Landscape (2025)

### Key Trends
- **Evolution Beyond Prompt Engineering**: Models like GPT-4o, Claude 4, and Gemini 1.5 Pro have made prompt engineering evolve into "context engineering" - strategies for curating and maintaining optimal token sets during LLM inference
- **Quality and Stability Concerns**: Studies indicate a correlation between widespread LLM adoption and decreased stability in software releases
- **Security Vulnerabilities**: Prompt injection attacks can expose PII, bypass content moderation, and exploit multilingual blind spots

### Major AI Coding Tools

#### GitHub Copilot
- Positioned as "AI pair programmer"
- Now includes "Agent" mode for more complex tasks
- Line-by-line code completion focused
- Limited architectural constraints

#### Cursor
- Polished, all-in-one AI IDE (VS Code++)
- Agent mode can handle complex cross-file tasks step-by-step
- Auto-completion powered by Supermaven for fast, precise suggestions
- AI searches code, opens files, generates modification plans, runs tests/builds
- Still relatively open-ended in execution

#### Windsurf
- Industry's first "Agentic IDE"
- AI assistant (Cascade) has agent capabilities throughout
- Seamlessly switches between answering questions and autonomously executing multi-step tasks
- "Flows = Agents + Copilots" philosophy - synchronous collaboration
- Cascade Memory System remembers session context across files
- More structured than Copilot but still agent-driven

#### Cline
- Open-source bridge connecting VS Code to AI APIs
- Customizable workflows
- Best for power users who want full control
- Self-hosting focused

### Guardrails and Control Mechanisms

#### Rules-Based Protections
- Follow predefined logic to control agentic system behavior
- Work outside the LLM
- Enforce clear, rigid boundaries on what agents can/cannot do

#### Contextual Security
- Provide robust framework for safety and reliability
- Focus on contextual guardrailing

#### Implementation Best Practices
- Separate what is allowed from how it's enforced
- Define what's allowed rather than what's forbidden
- "Only these three agents can run" vs trying to list everything that shouldn't run
- Extensive testing in sandboxed environments
- Appropriate guardrails for autonomous systems

#### Tools and Frameworks
- Guardrails AI: Collection of 60+ open-source safety barriers
- NeMo Guardrails: Toolkit for coding guardrail logic into AI conversational systems

### Architecture Patterns

#### Workflows vs Agents
- **Workflows**: LLMs and tools orchestrated through predefined code paths
- **Agents**: LLMs dynamically direct their own processes and tool usage, maintaining control

#### Emerging Patterns
- Hybrid approaches: semantic indexing + RAG (retrieval-augmented generation)
- Chain of thinking with exhaustive searching
- Separation of concerns and modular design
- Incremental development with mandatory testing

### Challenges with Current Approaches
- Higher costs and latency with agentic systems
- Potential for compounding errors
- Difficulty maintaining code quality and consistency
- Security and safety concerns
- Need for extensive sandboxing and testing

## CodeMySpec's Control-Based Architecture

### Core Philosophy
Control LLMs through:
1. Predefined architectural patterns
2. Significant rules and context
3. Checks and balances after each code generation
4. Strict procedural framework
5. Human review checkpoints

### Key Control Mechanisms

#### 1. Stateless Orchestration
- All state lives in Session records and embedded Interactions
- No implicit state carried between steps
- Explicit state machine with defined transitions

#### 2. StepBehaviour Contract
```elixir
@callback get_command(scope, session, opts) :: {:ok, Command.t()} | {:error, String.t()}
@callback handle_result(scope, session, result, opts) :: {:ok, session_updates, updated_result} | {:error, String.t()}
```
- Each step must define what command to execute
- Each step must validate and process its own results
- No step can proceed without explicit validation

#### 3. Predefined Step Sequences
Example from ComponentDesignSessions:
- Initialize
- GenerateComponentDesign
- ValidateDesign
- ReviseDesign (if validation fails)
- Finalize

The orchestrator enforces these sequences through explicit state transitions.

#### 4. Result Validation and Error Handling
- Every interaction must produce a Result with status (:ok or :error)
- Failed validations trigger predefined remediation steps
- No progression until validation passes

#### 5. Document Structure Validation
```elixir
defp create_document(component_design, component) do
  doc_def = CodeMySpec.Documents.Registry.get_definition(component.type)
  required_sections = doc_def.required_sections
  Documents.create_dynamic_document(component_design, required_sections, type: component.type)
end
```
- LLM output must conform to required document structures
- Validation happens between steps, not after the entire workflow

#### 6. Test-Driven Enforcement
- RunTests step executes actual tests
- FixTestFailures step only triggered when tests fail
- Loop continues until tests pass or session fails
- No way to bypass test execution

#### 7. Scoped Execution
- All operations require Scope (account_id, user_id, project_id)
- Sessions cannot access data outside their scope
- Isolation prevents cross-contamination

#### 8. Idempotency and Interaction Tracking
- Each interaction has unique ID
- Pending interactions prevent duplicate command generation
- Full audit trail of all LLM interactions

### What This Prevents
1. **Hallucinated workflows**: LLM cannot decide to skip validation or testing
2. **Unbounded generation**: Each step has specific input/output contracts
3. **Context drift**: State explicitly managed, not accumulated in conversation
4. **Validation bypass**: Structural validation happens between steps
5. **Uncontrolled iteration**: Retry logic built into orchestration, not LLM discretion

### Contrast with Prompt-Based Approaches
- **Traditional**: "Here's the context, please write good code and tests"
- **CodeMySpec**: "Generate design → Validate structure → If invalid, revise with error details → Run tests → If failed, fix with failure output → Repeat until pass"

The difference is enforcement vs. suggestion.

## Sources

### Articles and Documentation
- "A developer's guide to prompt engineering and LLMs" - The GitHub Blog
- "Effective context engineering for AI agents" - Anthropic Engineering
- "AI Guardrails in Agentic Systems Explained" - AltexSoft
- "Building Effective AI Agents" - Anthropic Engineering
- "Agent System Architectures of GitHub Copilot, Cursor, and Windsurf" - Cuckoo AI Network
- "Cursor vs Windsurf vs Cline vs Claude-Code vs Kilo Code" - DEV Community

### Key Insights
- Anthropic's perspective: Context engineering is the natural progression of prompt engineering
- McKinsey on AI Guardrails: Defining what's allowed vs what's forbidden
- Industry trend: Moving from simple copilots to agentic systems but struggling with control
- Security research: Prompt injection remains a significant vulnerability without proper constraints

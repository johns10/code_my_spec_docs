# CodeMySpec.AgentTasks.ProjectBootstrap

## Type

module

Agent task for bootstrapping the project after technology decisions are finalized. Reads the decisions index and knowledge base, then implements each decision: adds libraries, configures them, sets up Dotenvy with environment files, collects user secrets, and writes smoke tests that call real APIs and record cassettes. The preferred pattern for external integrations is to write minimal Req-based API client modules and use req_cassette to record calls. These recordings serve as canonical examples for how all future tests should handle external service interactions.

Prerequisite: `topics_researched` must be satisfied (all decisions made and researched).

Artifacts produced:
- `mix.exs` — updated with decided dependencies
- `config/*.exs` — library configuration across environments
- `config/runtime.exs` — Dotenvy integration and runtime secrets
- `.env.example` — template listing all required environment variables with descriptions
- `.env` — populated with user-provided secrets (gitignored)
- `lib/{app}/application.ex` — updated supervision tree if needed
- `lib/{app}/clients/{service}.ex` — minimal Req-based API client modules for external integrations
- `test/smoke_test.exs` — smoke tests exercising each integration with real API calls
- `test/fixtures/cassettes/smoke_*.json` — req_cassette recordings from smoke test runs

## Functions

### command/3

Generate the bootstrap prompt for the project setup session.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Read the decisions index from `.code_my_spec/architecture/decisions.md`
2. Read individual decision records from `.code_my_spec/architecture/decisions/*.md`
3. Partition decisions into pre-made (standard stack) and researched (project-specific)
4. Read `mix.exs` to identify already-installed dependencies
5. Check for existing `.env.example` and `.env` files
6. List existing cassettes in `test/fixtures/cassettes/`
7. Read relevant knowledge entries from `.code_my_spec/knowledge/` for researched topics
8. Read framework knowledge from `.code_my_spec/framework/` for relevant standard topics
9. Assemble prompt sections:
   - Header with project name and bootstrap goal
   - Decisions summary listing all decided technologies with status
   - Current state section showing what's already installed/configured
   - Knowledge section with setup guides for researched topics
   - Framework references for standard stack topics (Cloudflare tunnels via `client_utils` dep, etc.)
   - Instructions:
     1. **Add dependencies** — add libraries to `mix.exs`, run `mix deps.get`; note that `client_utils` (local dep) provides Cloudflare tunnel management and other shared utilities
     2. **Configure Dotenvy** — set up `runtime.exs` to load `.env` files via Dotenvy, create `.env.example` with all required variables documented, ensure `.env` is gitignored
     3. **Collect secrets** — identify required API keys/credentials from decided integrations, ask the user for each value, write to `.env`
     4. **Configure libraries** — add config entries to appropriate `config/*.exs` files, referencing env vars for secrets
     5. **Wire up application** — update `application.ex` supervision tree for any new workers/supervisors
     6. **Write API clients** — for each external integration, write a minimal Req-based client module at `lib/{app}/clients/{service}.ex`; use `Req.new(base_url: ..., headers: ...)` with a thin wrapper exposing domain-specific functions; prefer Req over raw HTTP clients (Finch, Hackney, HTTPoison)
     7. **Design recording strategy** — for each API client, document which HTTP calls to record; use req_cassette for Req-based clients; for any legacy ExVCR-based deps, use `ExVCR.Mock` with the appropriate adapter
     8. **Write smoke tests** — write `test/smoke_test.exs` that exercises each API client; use req_cassette to record real API calls on first run; these recordings serve as the canonical example for how all future tests handle external calls
     9. **Run smoke tests** — execute `mix test test/smoke_test.exs` to generate cassette recordings, verify all tests pass with recordings
     10. **Stop** — stop the session so validation can check the work

**Test Assertions**:
- returns ok tuple with non-empty prompt string
- includes project name in prompt
- lists decided technologies from decisions index
- includes knowledge entries for researched topics
- includes framework references for relevant standard topics
- references client_utils for shared utilities (Cloudflare tunnel, etc.)
- includes Dotenvy setup instructions
- instructs to create .env.example with variable descriptions
- instructs to collect secrets from user
- instructs to write Req-based API client modules
- instructs to use req_cassette for recording strategy
- instructs smoke tests to call real APIs and record cassettes
- includes already-installed deps to avoid duplicating work
- notes existing cassettes to avoid re-recording

### evaluate/3

Validate the project is fully bootstrapped. Checks only deterministic, verifiable artifacts — does not attempt to map ADR topics to dependency names or classify which integrations need cassettes.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()}
```

**Process**:
1. Check `.env.example` exists and is non-empty
2. Check Dotenvy is configured in `runtime.exs` (contains `Dotenvy.source`)
3. Check `.env` is listed in `.gitignore`
4. Check `test/smoke_test.exs` exists
5. Attempt compilation check via `Environments.cmd` if available
6. Collect all failures into feedback
7. Return `{:ok, :valid}` if all pass, or `{:ok, :invalid, feedback}` with actionable items

**Test Assertions**:
- returns `{:ok, :valid}` when all checks pass (.env.example exists, dotenvy configured, .env gitignored, smoke tests exist, project compiles)
- returns `{:ok, :invalid, feedback}` when .env.example is missing
- returns `{:ok, :invalid, feedback}` when Dotenvy is not configured in runtime.exs
- returns `{:ok, :invalid, feedback}` when .env is not gitignored
- returns `{:ok, :invalid, feedback}` when smoke test file is missing
- returns `{:ok, :invalid, feedback}` when project fails to compile
- reports multiple failures in a single feedback message

## Dependencies

- CodeMySpec.Environments
- CodeMySpec.Paths

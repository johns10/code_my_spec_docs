<!-- cms:task type="QaStory" component="466" -->

# QA Story 466: Execute Tests

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'` to get the app URL.

The brief has been validated. Execute the test plan and write the result.

Read `.code_my_spec/framework/qa-tooling.md` for the available testing tools and patterns.
You are a CLI agent — use `vibium` for browser automation (navigate, click, type,
screenshot) and shell scripts in `.code_my_spec/qa/scripts/` for authenticated requests.
You do NOT open a browser manually.
Reference existing scripts by path rather than inlining raw curl commands.

**Tool rules:**
- **Browser testing:** Use `vibium` commands (`vibium navigate`, `vibium click`, `vibium type`,
  `vibium screenshot`, etc.).
- **API testing:** Use `curl` but ALWAYS write single-line commands. Multi-line curl commands
  (with backslash continuations) require individual approval and block the session.

## Story: AI-Assisted Story Management

As a PM, I want an AI agent that can help me interview stakeholders, create user stories, and maintain requirements so that story management is efficient and stories stay current as the project evolves.

### Testing Approach

- Navigate the feature and capture a screenshot at each key state (initial load, after interactions, success/error states)
- After the scripted scenarios, explore freely: try unexpected inputs, edge cases, empty states, and anything that feels off
- Save all screenshots to `.code_my_spec/qa/466/screenshots/` — they are evidence and must be committed

## Instructions

1. Read the brief at `.code_my_spec/qa/466/brief.md` for the complete testing plan
2. Read `.code_my_spec/qa/plan.md` for auth strategy and seed commands
3. Read `.code_my_spec/framework/qa-tooling.md` for tool usage patterns and `.code_my_spec/framework/qa-tooling/` for tool-specific cheat sheets
4. If a linked component is listed above, read its source to understand the feature's implementation
5. Execute each test scenario from the brief
6. Capture a screenshot at each key state — save to `.code_my_spec/qa/466/screenshots/`
7. Attempt to resolve any issues with the plan or the QA scripts before finishing
8. Write the result to `.code_my_spec/qa/466/result.md` following the format below

Stop the session after writing the result.

## Result Format

# Qa Result

Per-story QA test result. Written by the QA agent after executing the test scenarios from the brief. Records status, scenario outcomes, evidence, and issues found.

## Required Sections

### Status

Format:
- Use H2 heading
- Single line: pass, fail, or partial

Content:
- Overall test result for this story
- `pass` — all scenarios passed
- `fail` — one or more scenarios failed
- `partial` — some scenarios could not be tested (e.g. camera hardware required)


### Scenarios

Format:
- Use H2 heading
- Use H3 for each scenario tested
- Include pass/fail status, steps taken, and observations

Content:
- Each scenario from the brief's "what to test" section
- What you did, what you saw, whether it matched expectations
- Reference screenshot paths as evidence


## Optional Sections

### Evidence

Format:
- Use H2 heading
- Bullet list of screenshot/file paths

Content:
- Paths to screenshots captured during testing
- Each entry should note what state it captures


### Issues

Format:
- Use H2 heading
- Use H3 for each issue title
- Use H4 subsections for structured fields: Severity, Description, and optionally Scope
- Severity must be one of: CRITICAL, HIGH, MEDIUM, LOW, INFO
- Scope is optional, one of: APP, QA, DOCS (defaults to APP if omitted)
- If no issues found, write "None" as plain text

Content:
- Each issue gets an H3 heading with a descriptive title
- H4 `#### Severity` with the severity level on the next line
- H4 `#### Scope` (optional) with the scope on the next line:
  - APP — bug in application code
  - QA — problem with QA infrastructure (seeds, auth scripts, test tooling)
  - DOCS — documentation gap or error
- H4 `#### Description` with paragraphs describing what's wrong
- Include specific URLs, inputs, or conditions that trigger the issue

Examples:
- ## Issues
  ### Login redirect fails for invited users
  #### Severity
  HIGH
  #### Description
  Invited users who click the email link are redirected to /login instead of /accept-invite.
  Reproduced with user test+invite@example.com.

  ### Seed script fails on fresh database
  #### Severity
  MEDIUM
  #### Scope
  QA
  #### Description
  Running `mix run priv/repo/qa_seeds.exs` on a freshly migrated database fails because it
  references a user that doesn't exist yet.


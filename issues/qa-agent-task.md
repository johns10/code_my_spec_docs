# QA Agent Task — Browser-Based App Verification

## Problem

After implementation, there's no automated way to verify that the generated app actually works from a user's perspective. You have to manually start the server, click through each page, fill out forms, and eyeball the results. The QA agent task automates this by pointing the agent at the app's router, giving it stories and BDD specs for context, and letting it browse with the `web` CLI tool to validate what's actually there. When it finds bugs, it files issues in `docs/issues/`.

## Design

### Task Type

**Componentless, project-wide task** — like `TechnicalStrategy` or `ManageImplementation`. One session covers the whole app. Registered as `"qa_app"` in the session type map.

### Core Principle: Validate What's There

The QA agent tests the **actual running app**, not what the specs say should exist. It reads the router to discover routes, visits them, and reports what it finds. Stories and BDD specs are context for the agent to understand intent — but the agent validates reality, not expectations. If a page is broken, missing content, or doesn't match the story, it files an issue.

### Flow

```
command/3                                    evaluate/3
┌──────────────────────────┐                ┌─────────────────────────────┐
│ 1. Read router.ex        │                │ 1. Check report exists      │
│    (the source of truth  │                │ 2. Check at least one story │
│    for what routes exist) │                │    is referenced            │
│ 2. Load stories with     │                │ 3. Check docs/issues/ for   │
│    acceptance criteria   │                │    new issue files          │
│ 3. Load BDD spec         │                │ 4. Return valid/invalid     │
│    coverage summary      │                └─────────────────────────────┘
│ 4. Read BDD spec files   │
│    (so agent can see     │
│    what's tested and     │
│    what's not)           │
│ 5. Build QA prompt       │
│    instructing agent to: │
│    - Check port 4000     │
│    - Start server if not │
│      running             │
│    - Use `web` to visit  │
│      each route          │
│    - Screenshot pages    │
│    - Fill/submit forms   │
│    - File issues for     │
│      bugs found          │
│    - Write QA report     │
└──────────────────────────┘
```

### Data the Prompt Gathers

1. **Router file** — read `lib/{app}_web/router.ex` directly. This is the source of truth for routes. The agent can also run `mix phx.routes` for a clean list.
2. **Stories with acceptance criteria** — `Stories.list_stories(scope)` gives titles, descriptions, and criteria. Context for what the app should do.
3. **BDD spec coverage** — `SpecProjector.format_coverage(stories, specs)` shows which stories have BDD coverage and which don't.
4. **BDD spec files** — read the actual spex files so the agent can see what's being tested (and spot gaps where specs aren't testing real behavior).
5. **Existing issues** — read `docs/issues/` to avoid filing duplicates.

### Prompt Structure

```markdown
# QA Session: Browser-Based App Verification

You are performing QA on the **{project_name}** app by using the `web` CLI tool
to browse the running application and verify it works correctly.

Your job is to validate what's actually there — visit every route, try the forms,
check the content, and file issues for anything broken.

## App Server

Before testing, ensure the Phoenix server is running:

1. Check if port 4000 is already in use: `lsof -i :4000`
2. If not running, start it in the project directory:
   `cd {project_cwd} && mix phx.server &`
3. Wait a few seconds, then verify: `web http://localhost:4000`
4. If the server is already running, proceed directly.

## Router

Here is the app's router — this is your route map:

```elixir
{router_content}
```

You can also run `mix phx.routes` in the project directory for a formatted list.

## Stories & Acceptance Criteria

These stories describe what the app should do. Use them as context when
evaluating pages, but test what's actually there:

{stories_with_criteria}

## BDD Spec Coverage

This shows which stories have automated BDD tests and which don't.
Pay extra attention to stories with no coverage — those are the most
likely to have untested bugs:

{bdd_coverage_summary}

## BDD Spec Details

These are the actual BDD test scenarios. Review them to understand what's
already being tested (and what's not):

{bdd_spec_summaries}

## Existing Issues

These issues are already known — don't duplicate them:

{existing_issues}

## Instructions

### Using the `web` tool

- **Visit a page**: `web http://localhost:4000/some-route`
- **Take a screenshot**: `web http://localhost:4000/some-route --screenshot docs/qa/screenshots/route-name.png`
- **Fill a form**: `web http://localhost:4000/page --form "form_id" --input "field[name]" --value "test" --after-submit http://localhost:4000/next`
- **JS interactions**: `web http://localhost:4000/page --js "document.querySelector('.btn').click()"`
- **Maintain session**: Use `--profile qa` on all requests to keep cookies/auth

### For authenticated routes

1. First log in using the app's login form with `--profile qa`
2. Then visit authenticated routes with `--profile qa` to reuse the session

### Testing approach

1. Start with the root route and navigate through the app
2. Visit every route from the router
3. Try form submissions — happy path and edge cases
4. Check page content against story acceptance criteria
5. Look for: broken pages, missing content, form errors, UI glitches, 500 errors

### Filing issues

For every bug or problem you find, create an issue file in `docs/issues/`:

- Filename: descriptive kebab-case, e.g. `docs/issues/login-form-500-error.md`
- Content: describe the problem, what you expected, what happened, and the route

### Write QA Report

Write the report to `docs/qa/report.md`. Include:

- What routes you visited
- What you tested
- What passed and what failed
- References to any issues you filed

When complete, stop the session so validation can check your work.
```

### Evaluation

Simple and pragmatic:

1. Check `docs/qa/report.md` exists and is non-empty
2. Check it references at least one story title (sanity check that it actually tested something)
3. Return valid if both checks pass

No cleanup of transient artifacts — the report and issue files are the outputs.

## Files to Create

| File | Purpose |
|------|---------|
| `lib/code_my_spec/agent_tasks/qa_app.ex` | QA agent task (command + evaluate) |
| `test/code_my_spec/agent_tasks/qa_app_test.exs` | Tests for the task |
| `CodeMySpec/skills/qa-app/SKILL.md` | CLI skill definition (in code_my_spec_cli) |

## Files to Modify

| File | Changes |
|------|---------|
| `lib/code_my_spec/agent_tasks/start_agent_task.ex` | Add `"qa_app"` to `@session_type_map` and `@componentless_tasks` |
| `lib/code_my_spec/sessions/session_type.ex` | Add `AgentTasks.QaApp` to `@valid_types` |

## Implementation Sequence

### 1. Register the session type

**`session_type.ex`**: Add `AgentTasks.QaApp` to `@valid_types`

**`start_agent_task.ex`**:
- Add `"qa_app" => AgentTasks.QaApp` to `@session_type_map`
- Add `"qa_app"` to `@componentless_tasks`

### 2. Build `QaApp` module

Follow `TechnicalStrategy` pattern (componentless, project-wide):

**`command/3`**:
- Derive app name from project (for router path: `lib/{app}_web/router.ex`)
- Read `router.ex` via `Environments.read_file`
- Load stories with criteria via `Stories.list_stories(scope)`
- Load BDD coverage via parser + projector
- Read BDD spec files for detail
- List existing issues in `docs/issues/`
- Build the prompt with all context

**`evaluate/3`**:
- Check `docs/qa/report.md` exists and is non-empty
- Check it mentions at least one story title
- Return `{:ok, :valid}` or `{:ok, :invalid, feedback}`

### 3. Write tests

Follow `ResearchTopicTest` patterns:
- `create_scope` with Briefly temp dir
- `create_session` with project
- Write fixture router.ex file
- Test command generates prompt with router content and stories
- Test evaluate checks report existence and story references

### 4. Add CLI skill

Create `CodeMySpec/skills/qa-app/SKILL.md` in the CLI repo:

```markdown
---
name: qa-app
description: QA the app by browsing with the web tool. Visits routes, tests forms, files issues for bugs found.
user-invocable: true
allowed-tools: Bash(*/agent-task *), Bash(web *), Bash(lsof *), Bash(mix phx.*), Read, Write, Glob, Grep, Task
argument-hint: []
---

!`${CLAUDE_PLUGIN_ROOT}/.claude-plugin/bin/agent-task qa_app ${CLAUDE_SESSION_ID}`

The response is JSON with a `prompt` field containing your instructions. Extract and follow the prompt.
```

Key difference from other skills: allows `Bash(web *)` for browser interaction and `Bash(lsof *)` for port checking.

## Key Design Decisions

**Router is the source of truth for routes**
Don't query component specs for routes. The router.ex file is what actually defines the app's URL structure. The agent reads it directly and browses from there.

**BDD specs as context, not validation targets**
The BDD specs tell the agent what's supposed to be tested already. If the agent finds that a BDD spec exists but the actual page is broken, that's an issue — the spec isn't testing what it should be.

**Issues go in `docs/issues/`**
Every bug found gets its own issue file in the existing `docs/issues/` directory. This feeds back into the development workflow — the agent or developer can pick up these issues in future sessions.

**Why `web` and not Wallaby/Playwright?**
- `web` is purpose-built for LLM agents — markdown output, form helpers, screenshots
- Already has LiveView awareness (waits for `.phx-connected`)
- Session profiles maintain auth cookies across requests
- No test framework dependency in the generated app — this runs from the outside

**Why project-wide and not per-story?**
- Fewer sessions = less overhead
- Auth flows need to happen once, then reuse the profile
- The agent can naturally chain page visits
- Stories share routes (multiple stories might test the same page)

**Report format left open**
No rigid structure enforced on the report for now. The agent writes what makes sense. If we need a parseable format later, we can add it.

**Port checking approach**
- `lsof -i :4000` to detect running server
- Start only if needed (user may already have it running)
- Background process so the QA session isn't blocked

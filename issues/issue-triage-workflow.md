# Issue Triage Workflow

## Problem

QA stories dump issue files directly into `.code_my_spec/issues/` as flat markdown files. There's no lifecycle — issues land and sit there until a human manually triages them. There's no validation that issues have required fields (severity, description), no separation between "just discovered" and "accepted for work", and no automated workflow to disposition issues or drive fixes.

We need a triage system that gates the story lifecycle: develop story → write BDD specs → implement until passing → run QA → triage and fix all issues → only then move to the next story. Issues from the current story must be resolved before downstream features build on broken foundations.

## Current State

- `QaStory.create_issue_files/3` writes issues to `.code_my_spec/issues/qa-{story_id}-{slug}.md`
- Issues are freeform: H1 title, H2 severity, H2 description, H2 source
- `QaIssue.fileable?/1` filters to medium+ before writing
- `QaApp` globs `issues/*.md` to count them in the summary
- `Paths.issues_dir/0` returns `.code_my_spec/issues`
- No validation via `Documents.Registry` — issues are written as raw markdown
- No workflow for triaging, deduplicating, or fixing issues

## Story Lifecycle Integration

Issues are a **project-level gate** in the per-story development loop:

```
For each story:
  1. Write BDD specs
  2. Implement until specs pass
  3. Run QA (creates issues in incoming/)
  4. Triage incoming issues (conversational — move to accepted/ or dismissed/)
  5. Fix all accepted issues (agent-driven)
  6. Re-run QA to verify fixes
  7. Only proceed to next story when incoming/ and accepted/ are clean
```

This means issues block the *current* story from completing, not just the next one. Downstream code and features should never have to work around known bugs from earlier stories.

## Design

### Directory Structure

```
.code_my_spec/issues/
├── incoming/          # QA-generated issues land here (untriaged)
│   ├── qa-376-login_redirect_fails.md
│   └── qa-377-missing_name_validation.md
├── accepted/          # Triaged issues ready for fix
│   ├── qa-376-login_redirect_fails.md
│   └── combined-validation-gaps.md
├── dismissed/         # Issues dismissed during triage (audit trail)
│   └── qa-377-test_env_artifact.md
└── (no files at root — existing flat files migrated to incoming/)
```

### Issue Document Type

Register `qa_issue` properly in the document system so issues are validated on creation and on any agent edit during triage. The existing `qa_issue` Registry entry has the right sections but isn't used for validation when QA story writes issues. Update the write path to validate.

Required sections:
- **Severity** — `critical`, `high`, `medium`, `low`, `info`
- **Description** — what's wrong, enough detail to understand and reproduce

Optional sections:
- **Source** — which QA story discovered it, path to result file
- **Reproduction** — numbered steps to reproduce
- **Requirements Impact** — whether this is a requirements change or just a code fix (added during triage)
- **Resolution** — how it was fixed (added after fix)

All severity levels (including `info` and `low`) go to incoming. They get triaged like everything else — the user decides what matters. Update `QaIssue.fileable?/1` to allow all severities through to incoming.

### Two Requirements (Project-Level)

These are project-level requirements that gate story completion.

#### Requirement 1: No issues in `incoming/`

**What it checks:** Glob `issues/incoming/*.md`. If any files exist, the requirement fails.

**What failure triggers:** Run the `triage` skill. The triage skill walks through each incoming issue conversationally and helps disposition it.

**Rationale:** Incoming issues are untriaged. Every issue must be dispositioned — accepted for work, dismissed with reason, or merged with a duplicate — before the story can complete.

#### Requirement 2: No medium+ issues in `accepted/`

**What it checks:** Glob `issues/accepted/*.md`, parse each as `qa_issue` document, check severity field. If any issue has severity `medium`, `high`, or `critical`, the requirement fails.

**What failure triggers:** Fix workflow — the agent resolves accepted issues.

**Rationale:** Accepted medium+ issues are real bugs. They must be fixed before moving to the next story so downstream features don't build on broken code. Low and info issues can remain in accepted without blocking — they're acknowledged but non-urgent.

### Triage Skill

A new skill `triage-issues` that is **fully conversational**. The user is the authority on what matters — the agent presents issues and asks for disposition, never makes autonomous decisions.

1. **Scans incoming/** — reads all issue files, presents summary grouped by severity
2. **For each issue, asks disposition questions:**
   - Is this a duplicate of an existing accepted issue? → Merge/discard
   - Is this a requirements change or a code fix?
     - Requirements change → update requirements (story criteria, BDD specs), then move to accepted
     - Code fix → move to accepted as-is
   - Should the severity be adjusted? (QA agents sometimes over/under-rate)
   - Is this actually not a bug? (expected behavior, test environment artifact) → Move to dismissed with reason
3. **Combines duplicates** — when multiple issues describe the same underlying problem, merge them into one accepted issue with all evidence consolidated
4. **Moves accepted issues** to `issues/accepted/` with any updated severity/description
5. **Moves dismissed issues** to `issues/dismissed/` for auditability

**Validation on edit:** Any time the agent modifies an issue file (adjusting severity, merging descriptions, etc.), the result must validate against the `qa_issue` document type. This ensures issues maintain their required structure through triage.

### Fix Workflow

The fix workflow doesn't need to be prescriptive about which skill or pattern to use. The agent should read the accepted issues, understand what's broken, and fix it — whether that means editing one file or touching multiple contexts.

The agent is given:
- The accepted issue files (description, reproduction steps, severity, source)
- The QA result that discovered the issue (linked via source section)
- The BDD specs and story context

It fixes the code, runs tests to verify, and when the fix is confirmed, adds a **Resolution** section to the issue file describing what was done. The issue stays in `accepted/` with the resolution — it's not deleted, so there's a record of what was found and how it was fixed.

After fixes, QA re-runs to verify. If new issues arise from the fixes, they go to incoming and the cycle repeats.

### Changes Required

#### Paths Module

```elixir
def issues_dir, do: Path.join(@base_dir, "issues")
def issues_incoming_dir, do: Path.join(issues_dir(), "incoming")
def issues_accepted_dir, do: Path.join(issues_dir(), "accepted")
def issues_dismissed_dir, do: Path.join(issues_dir(), "dismissed")
```

#### QaStory — Update Issue Write Path

Change `maybe_write_issue_file/3` to write to `issues/incoming/` instead of `issues/`. Validate via `Documents.create_dynamic_document/2` with the `qa_issue` type before writing. Remove the medium+ filter from `QaIssue.fileable?/1` — all severities go to incoming.

#### QaApp — Update Issue Counting

Update the glob in `build_issues_summary/1` to scan `incoming/` and `accepted/` subdirectories.

#### Documents.Registry — qa_issue Refinements

Add `requirements impact` and `resolution` as optional sections to the existing `qa_issue` type.

#### New: Requirement Checks (Project-Level)

Two new requirement checks:
- `NoIncomingIssues` — globs `incoming/`, fails if any files exist
- `NoAcceptedMediumPlusIssues` — globs `accepted/`, parses each, fails if any have severity medium/high/critical without a resolution section

Both return `{:ok, :pass}` or `{:ok, :fail, reason}` with details.

#### New: Triage Skill

- Agent type: conversational, needs Read/Write/Glob/Grep
- Skill file: `triage-issues/SKILL.md`
- Agent task: `lib/code_my_spec/agent_tasks/triage_issues.ex`

#### New: Fix Issues (Agent Task or Skill)

- Reads accepted issues with medium+ severity and no resolution
- Fixes code, runs tests, writes resolution section
- Could be a skill or just a prompt/task that the implementation orchestrator invokes

#### Migration

Existing files in `.code_my_spec/issues/*.md` that aren't issue design docs (like this file) need to be moved to `incoming/` as a one-time step. The design/feature issue files that currently live in `issues/` are a different thing — they're project planning docs, not QA-discovered bugs. May need to clarify the distinction or move planning issues elsewhere.

# Description Field Rubric

The description is the only routing signal — it's loaded into every session, and the agent uses it to decide whether to pull the skill body. A bad description means the skill is invisible; an overly broad one means it fires for unrelated work.

This is the single highest-leverage field. Get it right.

## What the description is for

The agent sees a list like:

```
- pdf-form-fill: <description>
- excel-pivot: <description>
- git-release: <description>
- ... 40 more ...
```

Given a user request, it picks one (or none). The description has to make that choice unambiguous.

Two failure modes:
- **Undertrigger:** skill never gets picked because the description doesn't surface the right trigger words.
- **Overtrigger:** skill gets picked for unrelated work because the description is too generic.

Both reduce to "the description doesn't accurately scope what the skill is for."

## The four ingredients

Every description should answer:

1. **What does it produce or do?** Concrete output, not abstract capability.
2. **When should the agent reach for it?** Specific trigger conditions.
3. **What trigger phrases match real user language?** Words the user would actually say.
4. **What's the scope boundary?** When *not* to use it (implicit or explicit).

Compact form:
> `<does what>. Use when <trigger phrases or conditions>.`

## Bad → Good transformations

### Example 1: PDF skill

❌ `description: Helps with PDFs`
- No verb, no trigger, no scope. Will be skipped or overtrigger.

✅ `description: Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.`
- Concrete operations (extract, fill, merge).
- Trigger phrases (PDFs, forms, document extraction).
- Implicit scope (PDF-specific, not generic document handling).

### Example 2: Release skill

❌ `description: Manages releases`
- "Manages" is vague. Will fire for unrelated release work (npm, docker, k8s).

✅ `description: Drafts GitHub release notes from merged PRs, proposes a semver bump, and provides a copy-pasteable gh release create command. Use when preparing a tagged GitHub release.`
- Specific platform (GitHub).
- Specific output (release notes, semver bump, command).
- Clear scope (tagged GitHub releases — not Docker images or npm publishes).

### Example 3: Test skill

❌ `description: Writes tests`
- For what? Which framework? When?

✅ `description: Writes ExUnit tests for Elixir modules following the project's spex BDD conventions. Use when adding test coverage for a context, schema, or LiveView module, or when the user asks to write tests for an Elixir file.`
- Framework (ExUnit).
- Language (Elixir).
- Convention (spex BDD).
- Trigger conditions (new context, schema, LiveView; explicit ask).

### Example 4: Database skill

❌ `description: Database stuff`
- Verb-free disaster.

✅ `description: Creates and reviews Ecto migrations for Postgres, including indexes, constraints, and data backfills. Use when the user asks to add a column, change a schema, write a migration, or modify the database structure.`
- Tech stack (Ecto, Postgres).
- Specific tasks (create, review, backfills).
- Trigger phrases (add column, change schema, write migration).

### Example 5: Knowledge skill

❌ `description: Project knowledge`
- Of what? About what?

✅ `description: Looks up project-specific conventions for the CodeMySpec requirements graph, including how prerequisites cascade, how files satisfy requirements, and how the next-task algorithm selects work. Use when the agent needs to reason about requirement state, prerequisite chains, or why a task is or isn't actionable.`
- Specific domain (requirements graph).
- Specific content (prerequisites, file satisfaction, next-task algorithm).
- Specific trigger (reasoning about requirement state).

## Self-check questions

Run each new description through these:

1. **Could two engineers writing different skills produce the same description?** If yes, it's too generic.
2. **Does it name at least three trigger phrases a user would actually say?** If not, the agent will struggle to match.
3. **Does it say what the skill produces, not just what it operates on?** "Works with PDFs" is weak; "extracts tables from PDFs" is strong.
4. **Would a new team member know when to invoke this without reading the body?** If they'd have to read `SKILL.md` to know when to use it, the description failed.
5. **Is the scope clear enough that the agent won't pick this for unrelated work?** "Writes code" is too broad; "writes Phoenix LiveView modules" is scoped.
6. **Are the trigger phrases front-loaded?** Codex truncates aggressively under index pressure — put the most important words first.
7. **Is it under 1,024 characters?** All three platforms cap somewhere around here.

If any answer is "no" or "not sure," revise.

## Length and structure

- **Sweet spot:** 150–400 characters. Long enough to be specific, short enough to scan.
- **Hard cap:** 1,024 chars (Claude Code and OpenCode). Codex truncates earlier under index budget.
- **Structure:** one or two sentences. Don't use line breaks; some tools collapse them.
- **Voice:** third person, present tense. "Extracts text..." not "I extract..." or "You can extract...".

## Trigger phrase patterns that work

Front-load the words a user is likely to type:

- File types and extensions: "PDFs", "spreadsheets", "`.xlsx` files", "Elixir modules"
- Domain verbs: "extract", "merge", "fill", "scaffold", "migrate", "release"
- Tool names: "ExUnit", "Ecto", "Phoenix LiveView", "GitHub Actions"
- Concept names: "auth", "OAuth", "multi-tenant", "feature flag"
- Explicit asks: "when the user asks to <X>"
- Context conditions: "when working with <Y>", "when preparing a <Z>"

Avoid:
- Adjectives without nouns ("powerful", "comprehensive")
- Vague verbs ("helps", "manages", "handles", "supports")
- Marketing voice ("Best-in-class", "world-class", "modern")

## Anti-patterns

| Anti-pattern | Why it fails |
|---|---|
| `description: Helps with X` | "Helps" is verbless. Won't surface in trigger matching. |
| `description: Manages X` | Too broad. Fires for unrelated work. |
| `description: A powerful tool for X` | Adjective without trigger. Won't match user phrasing. |
| `description: Use this skill when you need to do anything related to X` | Self-referential ("use this skill"). Wastes characters. |
| `description: Documentation skill` | Names a category, not a task. Agent can't pattern-match. |
| Putting only "what" with no "when" | Agent doesn't know what triggers it. |
| Putting only "when" with no "what" | Agent doesn't know what it'll produce. |
| 800-character description trying to explain the whole skill | The body explains; the description routes. |

## Worked iteration

Starting from scratch on a hypothetical "spex BDD writer" skill:

**Draft 1:** `Writes BDD specs`
- Too vague. Which BDD framework? When?

**Draft 2:** `Writes spex BDD specs for Elixir`
- Better. But what triggers it?

**Draft 3:** `Writes spex BDD specifications for Elixir contexts using the project's three-amigos protocol`
- Better still. Names the protocol. But what user phrases trigger it?

**Draft 4 (final):** `Writes SexySpex BDD specifications for Elixir contexts, schemas, and LiveView modules, following the project's three-amigos rule/scenario structure. Use when the user asks to write a spex, add BDD coverage for a story, or when a story has rules and scenarios but no spex file yet.`
- Names the framework (SexySpex).
- Names the targets (contexts, schemas, LiveView).
- Names the protocol (three-amigos rule/scenario).
- Three trigger conditions (asks to write spex, asks for BDD coverage, story has rules but no spex).

Each draft reduced ambiguity. The final form is concrete enough that the agent will pick it when relevant and skip it when not.

## When in doubt

If you're stuck between two descriptions, write three different user prompts that should trigger the skill. Then check: does each description make the agent's choice obvious for all three prompts? Pick the description where the answer is "yes" for all three.

If neither passes, the skill itself may be too broad or too narrow — fix the skill scope before fixing the description.

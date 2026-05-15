# Why Your Skill Isn't Triggering (and the Description Rubric That Fixes It)

This week I had seven agent_task modules in CodeMySpec that all shared the same description string. Seven different tasks -- ContextSpec, ContextDesignReview, ComponentSpec, ComponentTest, LiveContextSpec, LiveViewSpec, ControllerSpec -- and every one of them said `Spawn a @spec-writer sub-agent to call start_task...` in the routing signal. The agent picked them basically at random. Sometimes it'd open ControllerSpec when I wanted a context spec. Sometimes it would fire ComponentTest when there were no components to test.

That's overtriggering. The description is too generic to distinguish the skills from each other or from unrelated work, so the agent fires for everything.

The opposite problem is worse, because you don't notice it. I've shipped skills I thought were perfect -- good body, good scripts, decent references -- that triggered zero times in the next two months. That's undertriggering. The description named what the skill did but not what a user would actually say to invoke it. The skill is invisible.

Both problems reduce to the same root cause: **the description doesn't accurately scope what the skill is for.**

If you read [how to write your first agent skill](/blog/how-to-write-your-first-skill), you already know the description is the only routing signal. The agent sees a menu:

```
- pdf-form-fill: <description>
- excel-pivot: <description>
- git-release: <description>
- ...40 more...
```

It picks one or none. The body, the references, the scripts -- none of it matters until the description wins. If the description doesn't win, nobody reads it.

This is the rubric I apply to every new skill, and the one I just applied to thirty-odd `orchestrate/1` strings refactoring CodeMySpec.

## The two failure modes

Undertrigger and overtrigger. Complementary, not opposites.

**Undertrigger** -- the description doesn't surface the words a user would type, so the agent picks something else (or nothing). Symptoms: skill exists, you tested it once, and you never see it fire again.

**Overtrigger** -- the description is too generic, so the agent picks your skill for unrelated work. Symptoms: skill fires constantly, doing things the user didn't ask for.

The seven-orchestrate-strings situation was both at once: too generic to keep the tasks out of unrelated work, and too generic to point the agent at the right one when the work was spec-related.

## The four ingredients of a good description

Every description should answer four questions. If yours doesn't, that's where the failure is.

1. **What does it produce or do?** Concrete output, not abstract capability. "Manages releases" is abstract. "Drafts GitHub release notes from merged PRs" is concrete.
2. **When should the agent reach for it?** Specific trigger conditions. Not "when needed" -- actual conditions: "when preparing a tagged GitHub release," "when the user asks to ship a release."
3. **What trigger phrases match real user language?** The words a user would actually type or speak. If the user would say "ship a release" and your description doesn't have "ship" or "release" in it, you have a routing problem.
4. **What's the scope boundary?** When *not* to use it. Explicit or implicit. "Drafts GitHub release notes" implicitly excludes Docker, npm, k8s -- the agent won't pick it for those.

Compact form:

> `<does what>. Use when <trigger phrases or conditions>.`

If you can't fill in both halves of that template, the description isn't done.

## Three bad-to-good transformations

I keep a personal collection of descriptions I've rewritten. Three with the diagnosis:

### Example 1: PDF skill

❌ `description: Helps with PDFs`

No verb, no trigger, no scope. "Helps" is a non-verb. Won't surface in trigger matching because the user's words ("extract", "fill", "merge") aren't in the description.

✅ `description: Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.`

Concrete operations (extract, fill, merge). Trigger phrases (PDFs, forms, document extraction). Implicit scope (PDF-specific, not generic document handling).

### Example 2: Release skill

❌ `description: Manages releases`

"Manages" is too broad. Will fire for unrelated release work -- npm publish, docker push, k8s rollout.

✅ `description: Drafts GitHub release notes from merged PRs, proposes a semver bump, and provides a copy-pasteable gh release create command. Use when preparing a tagged GitHub release.`

Specific platform (GitHub). Specific outputs (release notes, semver bump, command). Clear scope (tagged GitHub releases -- not Docker, not npm).

### Example 3: Test skill

❌ `description: Writes tests`

For what? Which framework? When?

✅ `description: Writes ExUnit tests for Elixir modules following the project's spex BDD conventions. Use when adding test coverage for a context, schema, or LiveView module, or when the user asks to write tests for an Elixir file.`

Framework (ExUnit). Language (Elixir). Convention (spex BDD). Trigger conditions (context, schema, LiveView; explicit ask).

## The seven self-check questions

Run each new description through these. If any answer is "no" or "not sure," revise.

1. **Could two engineers writing different skills produce the same description?** If yes, it's too generic.
2. **Does it name at least three trigger phrases a user would actually say?** If not, the agent will struggle to match.
3. **Does it say what the skill produces, not just what it operates on?** "Works with PDFs" is weak; "extracts tables from PDFs" is strong.
4. **Would a new team member know when to invoke this without reading the body?** If they'd have to read SKILL.md to know when, the description failed.
5. **Is the scope clear enough that the agent won't pick this for unrelated work?** "Writes code" is too broad; "writes Phoenix LiveView modules" is scoped.
6. **Are the trigger phrases front-loaded?** Codex truncates aggressively under index pressure. Put the most important words first.
7. **Is it under 1,024 characters?** All three platforms cap somewhere around here.

I run new orchestrate strings through these before committing. The seven spec-gen tasks I mentioned at the top all failed at least three of the seven. After the rewrite, they pass all seven.

## Length and structure

Sweet spot: 150-400 characters. Hard cap: 1,024 on Claude Code and OpenCode. Codex truncates earlier under its ~2% context-window index budget, so with dozens of skills installed it shortens descriptions first -- front-load trigger words there.

One or two sentences. No line breaks -- some tools collapse them. Third person, present tense. "Extracts text..." not "I extract...".

## Trigger phrase patterns that work

Front-load the words a user is likely to type or speak:

- **File types and extensions:** "PDFs", "spreadsheets", "`.xlsx` files", "Elixir modules"
- **Domain verbs:** "extract", "merge", "fill", "scaffold", "migrate", "release"
- **Tool names:** "ExUnit", "Ecto", "Phoenix LiveView", "GitHub Actions"
- **Concept names:** "auth", "OAuth", "multi-tenant", "feature flag"
- **Explicit asks:** "when the user asks to \<X\>"
- **Context conditions:** "when working with \<Y\>", "when preparing a \<Z\>"

What to avoid:

- **Adjectives without nouns** ("powerful", "comprehensive", "modern")
- **Vague verbs** ("helps", "manages", "handles", "supports")
- **Marketing voice** ("best-in-class", "world-class", "next-generation")

## Anti-patterns to recognize

| Anti-pattern | Why it fails |
|---|---|
| `Helps with X` | "Helps" is verbless. Won't surface in trigger matching. |
| `Manages X` | Too broad. Fires for unrelated work. |
| `A powerful tool for X` | Adjective without trigger. Won't match user phrasing. |
| `Use this skill when you need to do anything related to X` | Self-referential ("use this skill"). Wastes characters. |
| `Documentation skill` | Names a category, not a task. Agent can't pattern-match. |
| Putting only "what" with no "when" | Agent doesn't know what triggers it. |
| Putting only "when" with no "what" | Agent doesn't know what it'll produce. |
| 800-character description trying to explain the whole skill | The body explains. The description routes. |

If you find yourself writing a paragraph of description, stop. The body is for nuance. The description is for matching.

## Where to go next

If your description passes the seven self-check questions, the rest is body shape, reference structure, and script discipline -- covered in [how to write your first agent skill](/blog/how-to-write-your-first-skill).

The next post picks up at the cross-platform layer:

**[One skill, three platforms: portability across Claude Code, OpenCode, and Codex](/blog/skill-portability)** -- the compatibility matrix, the portable subset of frontmatter, the discovery path differences. The rubric in this post works across all three platforms. The differences are everywhere else.

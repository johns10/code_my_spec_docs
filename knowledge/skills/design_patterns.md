# Design Patterns for Agent Skills

Cross-cutting techniques that apply to skills on any platform. Read this after picking a platform target.

## 1. Progressive disclosure — design for the three tiers

All three platforms implement the same tiered loading model:

| Tier | What | Cost | When loaded |
|---|---|---|---|
| 1 | Frontmatter (`name`, `description`) | ~100 tokens per skill | Always, at session start |
| 2 | `SKILL.md` body | ~5k tokens typically; persists for session | When agent decides skill is relevant |
| 3 | `scripts/`, `references/`, `assets/` | Zero until accessed | On demand, per file |

Design implications:

- **Keep `SKILL.md` under 500 lines / 1,500–2,000 words.** Every token in the body stays in context for the rest of the session, competing with conversation history.
- **Bundle generously into tier 3.** A skill with 5,000 lines of reference material and 20 example files costs nothing extra until the model actually opens one.
- **`SKILL.md` is a navigator, not a manual.** Quick-start at the top, decision tree in the middle, links to references at the bottom.
- **References should be one level deep from `SKILL.md`.** Nested chains (`SKILL.md → a.md → b.md`) get read incompletely — the model previews with `head` and gives up.

### Layout patterns

**Pattern A — Progressive navigation (most common):**

```
pdf-skill/
├── SKILL.md          # quick start, decision tree
├── reference.md      # complete API
├── examples.md       # usage patterns
└── scripts/
    └── extract.py
```

`SKILL.md`:

```markdown
## Quick start

For text extraction: `python scripts/extract.py file.pdf`.

## Advanced

- Form filling: see [forms.md](forms.md)
- API reference: see [reference.md](reference.md)
```

**Pattern B — Domain-sharded references** (great for large knowledge bases):

```
bigquery-skill/
├── SKILL.md
└── reference/
    ├── finance.md
    ├── sales.md
    └── product.md
```

User asks about sales → model reads only `reference/sales.md`. Finance and product never load.

**Pattern C — Conditional disclosure** for rare cases:

```markdown
## Editing documents

For simple edits, modify the XML directly.

**For tracked changes**: see [redlining.md](redlining.md) (load only if user mentions track-changes)
**For OOXML internals**: see [ooxml.md](ooxml.md) (load only if simple approach fails)
```

## 2. Writing descriptions that trigger reliably

The `description` field is the only routing signal. Across all three platforms, it's used to advertise the skill in the system prompt and to match against user intent.

**Bad:** `description: Helps with documents`

**Good:** `description: Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.`

Rules:
- Include both **what** and **when**.
- Use third-person ("Extracts...", not "I extract...").
- List concrete trigger phrases ("when the user mentions X").
- Front-load trigger words (Codex truncates aggressively under its ~8k char index budget).
- Stay under ~1024 chars (OpenCode and Claude Code limits).

The Anthropic best-practices doc treats description quality as the single biggest skill-design lever. Vague descriptions undertrigger; specific ones with trigger phrases trigger reliably.

## 3. MCP tool integration

None of the three platforms can install MCP servers from skill metadata. The portable model:

1. The user wires up MCP servers once at the platform level (`opencode.json`, `~/.codex/config.toml`, Claude Code MCP config).
2. The skill body documents which tools it expects.
3. Optionally — and only on Claude Code — the skill declares specific tools in `allowed-tools` to pre-approve them.

### Mental model

- MCP = **access** (the platform gives the model the tool).
- Skill = **procedure** (the body teaches the model when and how to use the tool).
- They compose, but a skill cannot install a tool.

### Per-platform syntax for tool references

| Platform | In frontmatter | In body |
|---|---|---|
| Claude Code | `allowed-tools: mcp__github__create_issue` | Refer to tool by name in prose; model invokes it |
| OpenCode | Done at agent layer, not in skill frontmatter | Refer in prose; agent picks tool from its allowed set |
| Codex | Optional `dependencies.tools` in `openai.yaml` | Refer in prose; user enables tools via `enabled_tools` in TOML |

### Portable pattern

In `SKILL.md`:

```markdown
## Required MCP tools

This skill uses the **GitHub MCP server**. Required tools:
- `create_issue` — to file new issues
- `list_issues` — to find duplicates

If your platform requires explicit whitelisting, see your platform's MCP config docs.
```

This says what's needed without baking in any platform-specific syntax.

## 4. Scripts and executables

### Conventions across platforms

```
my-skill/
└── scripts/
    ├── validate.py     # Python 3 (always available)
    ├── helper.sh       # Bash
    └── check.js        # Node
```

- Hashbang line + `chmod +x`.
- **No venvs.** Document `pip install` requirements in `SKILL.md`. For non-stdlib packages, include a `subprocess.check_call([sys.executable, "-m", "pip", "install", ...])` bootstrap inside the script.
- **Forward slashes** in paths — Windows backslashes break on Unix.
- **Handle errors in the script.** Crashing on a missing file forces the model to guess. Print a clear message and exit nonzero.

### Invocation from `SKILL.md`

Claude Code supports `${CLAUDE_SKILL_DIR}` for install-path-independent invocation:

```markdown
Run: `python ${CLAUDE_SKILL_DIR}/scripts/validate.py input.json`
```

Or with the preprocessing prefix `` !` `` (runs at skill-load time, output is inlined):

```markdown
## Current state

!`git status --short`
```

OpenCode and Codex don't have a documented `SKILL_DIR` variable — use relative paths and assume cwd is the working directory.

### When to write a script vs prose instructions

- **Script** when behavior must be deterministic (validation, schema checks, batch operations).
- **Prose** when the model needs to reason or adapt. Codex docs explicitly say "reserve scripts for behaviors that must be deterministic; otherwise prefer plain instructions."

### Error handling

```python
# Good — handle the error, give the model something useful
def process_file(path):
    if not Path(path).exists():
        print(f"File {path} not found", file=sys.stderr)
        sys.exit(1)
    return Path(path).read_text()

# Bad — crash, leave the model to guess
def process_file(path):
    return open(path).read()
```

## 5. Dynamic data / runtime context

Three approaches, in increasing order of complexity:

### A. Command injection at load time (Claude Code)

```markdown
## PR context

- Diff: !`gh pr diff`
- Comments: !`gh pr view --comments`
```

Runs once when the skill loads. Best for snapshot context.

### B. Skill-body-directed inspection (all platforms)

```markdown
## Process

1. Check the current state: `bash scripts/scan.sh > /tmp/state.json`
2. Read `/tmp/state.json` and analyze.
```

The model runs the command and reads the output. Best for structured live data the model needs to reason over.

### C. Custom tool via plugin/MCP (advanced)

Register a custom tool that returns dynamic data, then skill body says "call the X tool to get the current state." Best for high-frequency or stateful inspection.

Skills themselves are static markdown; "dynamic" is always achieved via tool invocation, not template magic.

## 6. Decision matrix — skill vs other primitives

| Need | Use |
|---|---|
| Repeated instructions you copy-paste into prompts | Skill |
| Always-loaded project conventions ("we use 4-space indent") | `CLAUDE.md` / `AGENTS.md` |
| User-triggered slash template with arg substitution | Slash command / custom prompt |
| Complex isolated task that shouldn't pollute main convo | Subagent |
| Persistent persona with its own model + tools | Agent (OpenCode) / subagent (Claude Code) |
| Runtime side effect (hook, custom tool) | Plugin / MCP server |

Key axis: **who initiates the load?**
- User → command.
- Agent from a menu → skill.
- Agent is the thing → agent/subagent.
- Always there → rules file.
- Runtime → plugin hook.

## 7. Anti-patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| Bloated `SKILL.md` | Every token persists for the session | Move detail to `references/`; link from body |
| Vague description | Skill never triggers | Include what + when + trigger phrases |
| No tool whitelist (Claude) | User gets permission prompt every call | Add `allowed-tools` |
| Windows path separators | Breaks on Unix | Forward slashes only |
| Nested reference chains | Read incompletely | Keep one level deep from `SKILL.md` |
| Punting errors to the model | Fragile, unreliable | Handle in script, exit nonzero with message |
| Magic constants in scripts | Hard to maintain | Add one-line comment with the why |
| Skill that depends on undocumented MCP setup | Silently fails for new users | Document required tools in body |
| Inventing platform-specific frontmatter when not needed | Reduces portability | Stick to `name` + `description` |
| Auto-disabled (`disable-model-invocation: true`) with no manual entry point documented | Skill is dead weight | Document the explicit invocation, or don't disable |

## 8. Testing skills

- **Test with multiple models.** What works for Opus may need more guidance for Haiku.
- **Test the trigger.** Write a prompt without mentioning the skill by name — does the model find it via description?
- **Test reference loading.** Confirm the model actually reads `references/foo.md` when relevant, vs guessing.
- **Test scripts standalone.** Run them outside the agent first; they should produce useful output and clear errors.
- **Test with a fresh session.** Existing context can mask undertriggering.

## 9. Authoring workflow

1. Start with a `SKILL.md` containing only `name`, `description`, and a 5-line body.
2. Pick a real task you'd want the skill to handle. Try invoking it. Did the description trigger?
3. Iterate description until it triggers reliably.
4. Add procedure to the body. Keep it tight.
5. Anything that's reference material → move to `references/`.
6. Anything that should be deterministic → script.
7. Document required tools.
8. Test with a fresh session.

The biggest design mistake is starting with a 500-line `SKILL.md` and trying to trim. Start small and add what's needed.

# OpenCode — Skill Reference

OpenCode (`opencode.ai` / `github.com/sst/opencode`) has six user-facing primitives. "Skill" is a real, first-class one, native to the binary as of ~v1.0.190.

## The primitive landscape

| Primitive | Who initiates? | Use for |
|---|---|---|
| **Skill** | Agent picks from a menu | Reusable instruction packets loaded on demand |
| **Agent** (`primary` or `subagent`) | User Tab-switches / `@mention`s / autonomous delegation | Personas with model + prompt + tool whitelist + permissions |
| **Command** | User types `/foo bar` | Slash-prefixed templates with arg substitution |
| **Plugin** | Runtime hook | Event-driven side effects, custom tool registration |
| **Rules** (`AGENTS.md` or `CLAUDE.md`) | Always loaded | Ambient project conventions |
| **Mode** | Tab key | Older docs term for built-in Build/Plan agents |

The axis that distinguishes them is **who initiates the load**.

## Discovery paths

Skills are discovered in this precedence order (project before global, opencode before claude before agents):

```
.opencode/skills/<name>/SKILL.md
.claude/skills/<name>/SKILL.md
.agents/skills/<name>/SKILL.md
~/.config/opencode/skills/<name>/SKILL.md
~/.claude/skills/<name>/SKILL.md
~/.agents/skills/<name>/SKILL.md
```

Project paths are searched upward to the git worktree root. The triple-path discovery is a deliberate portability hook — a skill in `.claude/skills/<name>/` works in both Claude Code and OpenCode unchanged.

Agents live in `.opencode/agents/<name>.md` (filename = id). Commands in `.opencode/commands/<name>.md`. Plugins in `.opencode/plugins/*.{js,ts}` or as npm packages declared in `opencode.json`.

## Skill frontmatter

Required:

```yaml
---
name: skill-name           # ^[a-z0-9]+(-[a-z0-9]+)*$, must equal dir name, 1–64 chars
description: 1–1024 char description. Specific enough for agents to select.
---
```

Optional:

| Field | Type | Notes |
|---|---|---|
| `license` | string | E.g. `MIT` |
| `compatibility` | string | E.g. `opencode` |
| `metadata` | object<string, string> | Free-form |

Unknown fields are ignored. **`allowed-tools` is not in the official spec** — community skills (e.g. malhashemi/opencode-skills) use it, but OpenCode's loader ignores it. Per-skill tool restriction is done at the agent or config layer instead.

Verbatim example from the docs:

```yaml
---
name: git-release
description: Create consistent releases and changelogs
license: MIT
compatibility: opencode
metadata:
  audience: maintainers
  workflow: github
---

## What I do
- Draft release notes from merged PRs
- Propose a version bump

## When to use me
Use this when preparing a tagged release.
```

## Progressive disclosure — tool-mediated, not keyword-matched

1. At session start OpenCode injects only `{name, description}` per skill into the system prompt.
2. When the agent decides a skill is relevant, it calls the built-in `skill` tool: `skill({ name: "git-release" })`.
3. Only then is the full `SKILL.md` body returned and added to context.

So the "routing layer" is the agent itself, reasoning over descriptions — not a keyword match. The `description` field is what gets routed against; everything else is gated behind the `skill` tool call.

Per-skill permission gating happens **before** advertisement — denied skills are filtered out of the menu the agent sees, not just blocked at fetch time.

## Agent frontmatter (the persona kind)

```yaml
---
description: Reviews code for quality and best practices
mode: subagent              # primary | subagent | all
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
permission:
  edit: deny
  bash: deny
tools:
  skill: false
  mymcp_*: true             # wildcards supported
---
```

Agents are **not** progressively disclosed — they're statically configured.

## Command frontmatter

```markdown
---
description: Run tests with coverage
agent: build
model: anthropic/claude-3-5-sonnet-20241022
subtask: false
---
Run the full test suite with coverage report for $ARGUMENTS.
Current state: !`git status -s`
Reference file: @src/test/setup.ts
```

Three template hooks:
- `$ARGUMENTS` / `$1..$N` — args
- `` !`cmd` `` — shell output embedded at invocation
- `@path` — file content injected

## MCP tool integration

MCP servers declared in `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-local": {
      "type": "local",
      "command": ["npx", "-y", "my-mcp-command"],
      "enabled": true,
      "environment": { "MY_KEY": "value" }
    },
    "my-remote": {
      "type": "remote",
      "url": "https://mcp-server.com",
      "headers": { "Authorization": "Bearer XXX" }
    }
  }
}
```

Tools register as `<server-name>_<toolname>` — **single underscore**, unlike Claude Code's double underscore. Wildcards work in agent `tools` and `permission` maps:

```json
{
  "tools": { "my-local_*": false },
  "agent": {
    "researcher": { "tools": { "my-local_*": true } }
  }
}
```

**Skills cannot declare required MCP servers.** No `mcp:` field in the official spec. Document the requirement in prose; configure the server out-of-band in `opencode.json`.

## Scripts and supporting files

The official docs **don't specify** a convention for non-Markdown files inside a skill directory — `SKILL.md` is the only file the spec discusses. But the Anthropic Agent Skills convention works because OpenCode doesn't interfere with it:

```
my-skill/
├── SKILL.md
├── scripts/        # invoked via the standard bash tool
├── references/     # read on demand via the standard read tool
└── assets/         # templates, fixtures
```

There's **no skill-aware path resolution** — paths resolve relative to `cwd`. If you need skill-relative resolution that survives `cwd` changes, look at the `joshuadavidthomas/opencode-agent-skills` plugin's `read_skill_file` / `run_skill_script` tools as prior art.

## Dynamic data / runtime context

Three mechanisms — none of them on skills directly:

1. **Commands** embed `` !`cmd` `` and `@path` at invocation. Snapshot now, prompt soon.
2. **Plugins** hook `tool.execute.before/after`, session start, file change. Receive `{ project, client, $, directory, worktree }` (Bun `$` shell).
3. **Skills are static** — to get live data, the skill body instructs the agent to call `bash`, `read`, an MCP tool, or a plugin-registered custom tool.

For "dynamic skill" patterns: skill body → instructs agent to run `scripts/collect-state.sh` → reason over its output. The non-portable but cleaner version: plugin registers a custom tool, skill instructs the agent to call it.

## Examples

- Docs example: [opencode.ai/docs/skills/](https://opencode.ai/docs/skills/) — `git-release`
- [malhashemi/opencode-skills](https://github.com/malhashemi/opencode-skills) — community collection with `scripts/ references/ assets/` layout (uses non-official `allowed-tools` field)
- [joshuadavidthomas/opencode-agent-skills](https://github.com/joshuadavidthomas/opencode-agent-skills) — plugin (mostly superseded by native support) with skill-path-aware tools
- [open-hax/opencode-skills](https://github.com/open-hax/opencode-skills) — `.opencode/skills/` targeted skills
- [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) — curated cross-compatible catalog

## Sources

- [opencode.ai/docs/skills](https://opencode.ai/docs/skills/)
- [opencode.ai/docs/agents](https://opencode.ai/docs/agents/)
- [opencode.ai/docs/commands](https://opencode.ai/docs/commands/)
- [opencode.ai/docs/mcp-servers](https://opencode.ai/docs/mcp-servers/)
- [opencode.ai/docs/plugins](https://opencode.ai/docs/plugins/)
- [opencode.ai/docs/rules](https://opencode.ai/docs/rules/)
- [DeepWiki: sst/opencode skills system](https://deepwiki.com/sst/opencode/5.7-skills-system)
- [github.com/sst/opencode](https://github.com/sst/opencode)

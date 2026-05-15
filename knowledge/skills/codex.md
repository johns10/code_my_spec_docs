# Codex — Skill Reference

OpenAI's modern Codex coding agent (Rust CLI at `github.com/openai/codex`, plus IDE extension and `chatgpt.com/codex` web/cloud agent — not the deprecated 2021 model).

Codex shipped first-class Agent Skills, deliberately compatible with the Anthropic `SKILL.md` convention, with Codex-specific extensions in a sibling `agents/openai.yaml`.

## Directory layout

```
<skill-name>/
├── SKILL.md            # required, frontmatter + body
├── scripts/            # optional, executables
├── references/         # optional, long-form docs linked from SKILL.md
├── assets/             # optional, icons/images
└── agents/
    └── openai.yaml     # optional, Codex-specific metadata
```

## Discovery paths

In priority order (working dir → repo root → user → admin → system):

| Scope | Path |
|---|---|
| Repository | `.agents/skills/` (cwd, walking up to repo root) |
| User | `$HOME/.agents/skills/` |
| Admin | `/etc/codex/skills/` |
| System | bundled (e.g. `skill-creator`, `skill-installer`) |

Per-skill enable/disable in `~/.codex/config.toml`:

```toml
[[skills.config]]
path = "/path/to/skill/SKILL.md"
enabled = false
```

## Frontmatter

Required:

```yaml
---
name: skill-name
description: Explain exactly when this skill should and should not trigger.
---
```

The docs explicitly recommend **front-loading trigger words** in `description` so Codex still matches when descriptions get truncated under the index budget.

## Invocation — three modes

1. **Implicit** — Codex picks the skill from your prompt against the skill's `description`.
2. **Slash picker** — `/skills` opens the chooser.
3. **Explicit mention** — type `$skill-name` in the composer (e.g. `$skill-installer linear`).

## Progressive disclosure

- At session start Codex loads only `{name, description, path}` for each discovered skill.
- The initial skills index is **capped at ~2% of the context window (~8,000 chars)**. If many skills are installed, Codex shortens descriptions first.
- Full `SKILL.md` body is loaded only when Codex decides to use the skill.
- `scripts/`, `references/`, `assets/` are never loaded — the body tells Codex to read or execute them on demand.

Spiritually identical to Claude Code's model. Portable skills can rely on this.

## Optional `agents/openai.yaml`

Codex-specific metadata. Other agents safely ignore it.

```yaml
interface:
  display_name: "User-facing name"
  short_description: "User-facing description"
  icon_small: "./assets/small-logo.svg"
  icon_large: "./assets/large-logo.png"
  brand_color: "#3B82F6"
  default_prompt: "Optional surrounding prompt"

policy:
  allow_implicit_invocation: false   # default true

dependencies:
  tools:
    - type: "mcp"
      value: "openaiDeveloperDocs"
      description: "Tool description"
      transport: "streamable_http"
      url: "https://example.com"
```

`dependencies.tools` is the closest thing to "this skill needs MCP server X installed" — Codex can prompt the user to wire up the dep at install time.

## AGENTS.md — ambient project context (orthogonal to skills)

Codex reads `AGENTS.md` on every run. It's separate from skills and serves the "always-loaded project conventions" role. There is **no per-skill AGENTS.md** — don't try to model skills as nested AGENTS.md files; they're orthogonal.

Discovery chain (concatenated root-down, deeper files override):

1. `$CODEX_HOME/AGENTS.override.md` else `$CODEX_HOME/AGENTS.md` (default `CODEX_HOME=~/.codex`).
2. Walk from git root down to cwd. At each directory: `AGENTS.override.md` → `AGENTS.md` → any `project_doc_fallback_filenames`. At most one file per directory.

Config:

```toml
project_doc_fallback_filenames = ["TEAM_GUIDE.md", ".agents.md"]
project_doc_max_bytes          = 65536   # default 32 KiB
```

## Custom tools / function calling

Tool extensibility is **MCP-only**. There is no "drop a Python file in `~/.codex/tools/`" mechanism. If you want a tool, you ship an MCP server.

## MCP integration

Primary tool-extension mechanism. Both stdio and Streamable HTTP transports.

Global config: `~/.codex/config.toml`. Project config: `.codex/config.toml` (trusted projects only). Manage via `codex mcp add/list/login` or hand-edit TOML.

**stdio server:**

```toml
[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp"]
env_vars = ["LOCAL_TOKEN"]

[mcp_servers.context7.env]
MY_ENV_VAR = "MY_ENV_VALUE"
```

**Streamable HTTP server:**

```toml
[mcp_servers.figma]
url = "https://mcp.figma.com/mcp"
bearer_token_env_var = "FIGMA_OAUTH_TOKEN"
http_headers = { "X-Figma-Region" = "us-east-1" }
```

Per-server tool whitelisting:

```toml
enabled_tools  = ["open", "screenshot"]   # allowlist
disabled_tools = ["screenshot"]           # denylist applied after allowlist
```

Other knobs: `startup_timeout_sec` (default 10), `tool_timeout_sec` (default 60), `enabled`, `required`, `mcp_oauth_callback_port`, `mcp_oauth_callback_url`. OAuth: `codex mcp login <server>`.

## Slash commands

Built-in: `/model`, `/fast`, `/personality`, `/status`, `/plan`, `/permissions`, `/compact`, `/diff`, `/review`, `/resume`, `/new`, `/goal`, `/mcp`, `/apps`, `/plugins`, `/skills`.

**User-defined slash commands ("Custom Prompts") are officially deprecated** in favor of skills. The mechanism still works:

- Drop markdown in `~/.codex/prompts/`.
- Frontmatter: `description`, `argument-hint`.
- Invoke as `/prompts:filename` with `$1..$9`, named `$FILE` (`KEY=value`), or `$ARGUMENTS`.
- Local-only, not shareable via repo.

Use skills for any new reusable behavior — they support both implicit and explicit invocation, plus repo sharing via `.agents/skills/`.

## Examples

- [Codex bundled skill-creator and skill-installer](https://developers.openai.com/codex/skills) — invoke `$skill-creator` to scaffold a new skill
- [feiskyer/codex-settings](https://github.com/feiskyer/codex-settings) — worked examples: `claude-skill`, `autonomous-skill`, `deep-research`, `nanobanana-skill`, `youtube-transcribe-skill`, `kiro-skill`
- [Codex repo's own AGENTS.md](https://github.com/openai/codex/blob/main/AGENTS.md) — real-world AGENTS.md example
- [github.com/openai/codex](https://github.com/openai/codex) — install via `npm i -g @openai/codex` or `brew install --cask codex`

## Sources

- [Agent Skills — Codex docs](https://developers.openai.com/codex/skills)
- [Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md)
- [Model Context Protocol — Codex](https://developers.openai.com/codex/mcp)
- [Slash commands in Codex CLI](https://developers.openai.com/codex/cli/slash-commands)
- [Custom Prompts (deprecated)](https://developers.openai.com/codex/custom-prompts)
- [Configuration Reference](https://developers.openai.com/codex/config-reference)

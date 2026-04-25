# Aider in 2026: Features, Pricing, Benchmarks, and Community Sentiment

## Overview

Aider is the OG open-source CLI coding agent, and it still gets the fundamentals right in ways the vendor CLIs don't. Paul Gauthier started it before the wave, and the git integration is the deepest in the space -- every edit auto-committed with a real message, clean `/undo`, committer tagged "(aider)" so you can audit what the model touched.

The real draw is model freedom. 50+ models from any provider, local models through Ollama, no vendor telling you which one you're allowed to use this week. If you care about switching models for the task or running air-gapped, this is the tool. And at ~$60/mo heavy usage versus $200/mo for Claude Code, it's a lot cheaper for equivalent work.

Aider's Polyglot leaderboard has quietly become the de facto standard for evaluating coding *models* -- Unsloth, the r/LocalLLaMA community, the Qwen team all use it. 41K+ stars, one of the fastest-rising AI open source projects, built by people who care about precision, token efficiency, and not being locked in.

## Key Differentiators

- **Best git integration in the category** -- Auto-commits with descriptive messages, clean `/undo`, "(aider)" committer tag for audit trails.
- **Model agnostic** -- 50+ models, any provider, local via Ollama. The Switzerland of coding agents.
- **Aider Polyglot leaderboard** -- Measures which *model* works best through Aider (225 Exercism exercises, 6 languages). The industry-standard read on model coding ability.
- **Token efficiency** -- 4.2x fewer tokens than Claude Code on the same tasks (Morph benchmark).
- **Repo-map** -- Builds a map of your whole codebase for context.
- **Auto-fix loop** -- Runs linters and tests, fixes errors, re-runs. No babysitting.

## Pricing

| Plan | Price | Details |
|------|-------|---------|
| Tool | Free | Open source, BYOK (bring your own API key) |
| API costs (Sonnet) | ~$5-15/day | Light to moderate usage |
| API costs (Opus) | ~$15-40/day | Heavy usage |
| Heavy average | ~$60/mo | Comparable to Claude Code Pro at $20/mo but with Opus-class models |

## Strengths

- Real model flexibility -- pick the best model for the task, switch freely
- 4.2x more token-efficient than Claude Code
- Best-in-class git workflow, no special effort required
- Mature, stable, well-documented -- feels built by someone who ships
- BYOK means ~$60/mo heavy use vs $200/mo for Claude Code
- Polyglot leaderboard gives it real credibility with the local-model crowd
- Local models for air-gapped or privacy-sensitive work
- Voice commands and image/web page inclusion
- 41K+ stars, one of the fastest-rising AI OSS projects

## Weaknesses

- Not fully agentic -- you confirm every step. No autonomous mode.
- Manual context management is tedious compared to auto-indexing tools
- No native MCP (issue #4506 open, third-party servers exist)
- Output scrolls by faster than you can review -- you end up ignoring LLM output
- Auto-commit granularity is often wrong (too coarse or too fine)
- Model switching mid-session is cumbersome
- Solo maintainer (Paul Gauthier) -- bus factor
- Claude Code is "in its own league" for production code quality
- Opus-class usage can spike to $15-40/day
- Nothing for teams -- no collaboration tooling

## Community Sentiment

### What People Love

- **Speed with Gemini models** -- "Aider + the Gemini family works SO UNBELIEVABLY FAST. I can request and generate 3 versions of my new feature faster in Aider (and for 1/10th the token cost) than it takes to make one change with Roo Code." -- u/MrPanache52, r/ChatGPTCoding
- **Precision multi-file edits** -- "I use Aider for precision, high quality code multi-file edits." -- u/Equivalent_Form_9717, r/ChatGPTCoding
- **Token efficiency** -- "Aider saves a lot of tokens if you include the correct context, and it gives better results because the AI isn't confused by too much or too little context." -- u/sbayit, r/ChatGPTCoding
- **Benchmark standard** -- Aider Polyglot is now the de facto benchmark for local model coding ability, used by Unsloth, Qwen team, r/LocalLLaMA community
- **Cost efficiency** -- ~$60/mo heavy use vs $200/mo for Claude Code. "There's no reason to burn your money on Claude when you can run DeepSeek V3.1/Qwen3-235B at home." -- u/segmond, r/LocalLLaMA
- **Productivity gains** -- 4x productivity reported by users after one month

### Common Complaints

- **Not fully agentic** -- "I have to confirm every single step with aider, it's like a new job I didn't need." -- u/jakenuts-, r/ChatGPTCoding
- **Manual context management** -- "The workflow is clunky. When I'm coding it's cumbersome to have to go over to Aider and manually give it all the context... I like that Cline/Roo knows what I'm working on." -- u/Harrismcc, r/ChatGPTCoding
- **Output scrolling** -- Changes scroll by too fast to digest, training users to ignore LLM output
- **Commit granularity** -- Auto-commits either too coarse (backend + frontend lumped) or too fine (linter changes as separate commit)
- **Production quality gap** -- "Claude Code is in its own league... the only one I can get to write passable production ready code." -- u/Ikeeki, r/ChatGPTCoding

### Notable Quotes

> "After using Aider for a few weeks, going back to co-pilot, roo code, augment, etc, feels like crawling in comparison." -- u/MrPanache52, r/ChatGPTCoding (122 upvotes, 131 comments)

> "I have to confirm every single step with aider, it's like a new job I didn't need. Is there a flag you can pass to make it a real autonomous coding agent instead?" -- u/jakenuts-, r/ChatGPTCoding

> "Claude Code uses 4.2x more tokens than Aider on the same tasks, but its code works without human edits 78% of the time (vs. 71% for Aider)." -- Morph benchmark

> "There's no reason to burn your money on Claude when you can run DeepSeek V3.1/Qwen3-235B at home." -- u/segmond, r/LocalLLaMA (270 upvotes)

> "Aider + the Gemini family works SO UNBELIEVABLY FAST." -- u/MrPanache52, r/ChatGPTCoding

## Performance Notes

### Aider Polyglot Benchmark

Aider maintains its own coding benchmark: 225 Exercism exercises across C++, Go, Java, JavaScript, Python, Rust, two attempts per problem. **Important:** This benchmark measures models-through-Aider, not Aider itself vs other tools. Scores change frequently as models are updated. See [aider.chat/docs/leaderboards](https://aider.chat/docs/leaderboards/) for current scores.

The Polyglot leaderboard has become the de facto standard for evaluating coding model quality, used by Unsloth, the Qwen team, and the r/LocalLLaMA community.

**Aider Polyglot leaderboard snapshot (April 2026):** GPT-5 (high) leads at 88.0%, followed by GPT-5 (medium) at 86.7% and o3-pro (high) at 84.9%. Gemini 2.5 Pro with 32k thinking tokens reached 83.1%, entering the top 5. Note: these scores reflect *model* capability when run through Aider's specific scaffold -- not a comparison of Aider against other coding tools. Check [aider.chat/docs/leaderboards](https://aider.chat/docs/leaderboards/) for the live leaderboard.

### Token Efficiency (vs Claude Code)

- Aider uses **4.2x fewer tokens** than Claude Code on same tasks (Morph comparison)
- Code works without human edits **71%** of the time (vs Claude Code's 78%)
- Tradeoff: cheaper but slightly lower first-pass quality

## Recent Changes (2025-2026)

- **v0.82.0** (April 14, 2026) -- GPT-4.1 mini/nano, Grok-3, new "patch" edit format, better architect mode compatibility.
- **v0.81.0** (April 4, 2026) -- Quasar-alpha support (free on OpenRouter); stops retrying when providers report insufficient credits.
- **v0.80.0** (March 31, 2026) -- OpenRouter OAuth, Scala support, external editor via Ctrl-X Ctrl-E.
- **Model additions** -- GPT-5.1/5.2, GPT-5-pro, Claude Sonnet 4/Opus 4 series, Gemini 2.5 Pro/Flash with thinking tokens, o3-pro.
- **Prompt caching** -- Real cost savings on repeated context.
- **Voice commands, image and web page inclusion** -- Been there for a while, still rare in competing CLIs.
- **Auto lint/test loop** on AI-generated code.

## Integration Ecosystem

- **Models:** 50+ LLMs across OpenAI, Anthropic, Google, DeepSeek, local models (Ollama, any OpenAI-compatible endpoint)
- **Languages:** 100+ programming languages
- **Git:** Native, best-in-class. Auto-stages/commits with descriptive messages, "(aider)" committer tag.
- **MCP:** No native support (GitHub issue #4506). Third-party servers: `disler/aider-mcp-server`, `sengokudaikon/aider-mcp-server`, `lutzleonhardt/mcpm-aider`
- **IDE:** Terminal-based, works alongside any editor
- **Install:** `pip install aider-chat`

## CodeMySpec Integration

Aider's model flexibility and git-first workflow make it a natural fit for spec-driven development, especially if you're watching costs.

- **Context files:** `/add` for mutable context, `/read` for read-only. CodeMySpec specs drop in as `/read` references -- full visibility, zero risk of the model rewriting them. No `CLAUDE.md`-style auto-load.
- **MCP support:** Not native yet (issue #4506 open). Third-party servers exist (`disler/aider-mcp-server`, `sengokudaikon/aider-mcp-server`). File-based spec delivery until native MCP lands.
- **Hooks support:** No pre/post hooks. The auto-fix loop (run linters/tests, fix, re-run) is the closest thing, and it works well for spec-driven test compliance.
- **Subagent support:** None. Single conversation, single thread. Parallel work means running multiple Aider instances manually.
- **Skills/commands support:** None. Custom workflows require wrapper scripts around the CLI.
- **Memory/persistence:** No persistent memory. Fresh session every time. Repo-map gives codebase awareness; spec context gets re-added each session via `/add` or `/read`.

## Related Articles

- [The Best CLI Coding Agents in 2026](/blog/cli-agents-compared-2026)
- [The Rise of CLI Coding Agents](/blog/rise-of-cli-coding-agents)
- [Free and Open Source AI Coding Tools in 2026](/blog/free-open-source-ai-coding-tools-2026)
- [Open Source vs Vendor-Locked AI Coding Tools](/blog/open-source-vs-vendor-locked-ai-coding-tools)

## Sources

- [Aider LLM Leaderboards](https://aider.chat/docs/leaderboards/)
- [Aider Polyglot Benchmark -- Epoch AI](https://epoch.ai/benchmarks/aider-polyglot)
- [Aider Release History](https://aider.chat/HISTORY.html)
- [Aider vs Claude Code -- Morph](https://www.morphllm.com/comparisons/morph-vs-aider-diff)
- [Aider vs Claude Code -- zenvanriel.com](https://zenvanriel.com/ai-engineer-blog/aider-vs-claude-code/)
- [Programming with Aider -- slinkp.com](https://slinkp.com/programming-with-aider-20250725.html)
- [MCP Issue #4506](https://github.com/aider-ai/aider/issues/4506)
- [Aider Documentation](https://aider.chat/docs/)

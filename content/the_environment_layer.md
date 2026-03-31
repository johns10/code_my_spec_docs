# The Environment Layer: Where AI Code Actually Runs

*Part 5 of "The Anatomy of Agentic Coding Systems," a series breaking down how AI coding tools actually work.*

---

Take the same model. The same agent loop. The same system prompt. Run it in a terminal on your laptop and it rewrites your test suite in 90 seconds. Run it inside a locked-down container and it can't even install a dependency. Run it as a background agent in the cloud and it delivers a pull request while you're asleep.

The environment layer is the most underappreciated part of an agentic coding system. It determines what the agent can see, what it can touch, how fast it can move, and what happens when it makes a mistake. Two developers using the exact same model can have radically different experiences, not because of prompting or context management, but because of where and how the agent runs.

## Three interface paradigms

Every agentic coding tool presents itself through one of three interfaces. Each comes with real trade-offs.

### CLI agents

**Tools:** Claude Code, Codex CLI, Aider, Gemini CLI

CLI agents run in your terminal with direct access to your filesystem, shell, git history, and everything else on your machine. A CLI agent can chain shell commands the same way you would: run tests, parse output, fix the failing test, re-run. It can pipe between commands, use your locally installed tools, and operate on your repository as a system rather than a collection of open files.

The developer profile that gravitates here tends to be senior engineers and infrastructure teams. Boris Cherny, the creator of Claude Code, described running [3-5 git worktrees simultaneously](https://www.threads.com/@boris_cherny/post/DVAAnexgRUj/) as his top productivity tip, a workflow that only makes sense in a terminal-native context.

The trade-off: no visual feedback. No inline diffs as they happen. No autocomplete while you type. The interaction is conversational, not collaborative.

### IDE agents

**Tools:** Cursor, Windsurf, GitHub Copilot in VS Code, Zed

IDE agents live inside your editor. They see your open files, your cursor position, your recent edits. They show inline diffs, offer tab completions, and present changes visually before you accept them. This is why IDE tools have spread so quickly, the speed from question to visible result is faster than any other paradigm.

Cursor and Windsurf have pushed into full agentic capabilities: multi-file reasoning, multi-step execution, terminal commands. But IDE agents are constrained by the editor's boundaries. Cross-repository operations, infrastructure tasks, and anything outside the editor's "workspace" concept gets awkward fast.

### Cloud/headless agents

**Tools:** GitHub Copilot coding agent, Devin, Cursor background agents

Cloud agents don't need you present. Assign an issue, describe a task, and the agent works independently. GitHub's [Copilot coding agent](https://github.blog/news-insights/product-news/github-copilot-meet-the-new-coding-agent/) spins up an ephemeral GitHub Actions environment, writes code, runs tests, and opens a PR. [Devin](https://aitoolsdevpro.com/ai-tools/devin-guide/) runs in persistent cloud VMs with shell, editor, and browser. [Cursor's background agents](https://docs.cursor.com/en/background-agent) run in isolated Ubuntu VMs, up to eight in parallel.

The win: agents can run for hours unattended, scale to many parallel instances, and deliver results async. The cost: no real-time course correction, harder to debug, and cloud compute bills.

### The multi-tool reality

Teams serious about AI-assisted development in 2026 aren't picking one interface. They use Claude Code for complex refactors and infrastructure. Cursor for rapid feature work with visual feedback. Copilot coding agent for grinding through issue backlogs overnight. The right environment depends on the task.

## Sandboxing: containing the blast radius

When an AI agent has shell access and can run arbitrary commands, the question isn't whether it will eventually do something destructive. The question is what happens when it does.

**No sandbox (default for most CLI tools).** Claude Code, Aider, and Gemini CLI operate on your local filesystem with whatever permissions your user account has. Maximum capability, zero isolation. An agent that decides to "clean up" your home directory or modify your shell config is a real risk.

**OS-level sandboxing.** [Codex CLI](https://developers.openai.com/codex/concepts/sandboxing) is the only major agent with sandboxing on by default. It uses Linux's Landlock and seccomp (macOS Seatbelt, Windows native sandbox) to enforce restrictions at the OS level: no network access, writes limited to the workspace. Lightweight, fast, no containers needed.

**Docker containers.** [Docker Sandboxes](https://www.docker.com/blog/docker-sandboxes-run-claude-code-and-other-coding-agents-unsupervised-but-safely/) are disposable, isolated environments running on dedicated microVMs. They support Claude Code, Codex CLI, Copilot CLI, Gemini CLI, and Kiro with a unified interface (`docker sandbox create claude`). The key differentiator: agents can build and run Docker containers while remaining isolated from the host.

**DevContainers.** Docker containers configured as full dev environments. [Anthropic's own security docs](https://code.claude.com/docs/en/security) recommend them for isolating Claude Code. The agent can `rm -rf /` and the worst that happens is you rebuild the container.

**Git worktrees.** Not sandboxes in the security sense, but they solve isolation for parallel agent work. A worktree is a linked working directory sharing the same `.git` data but with its own files on its own branch. Cursor uses them for [parallel agents](https://cursor.com/docs/configuration/worktrees), up to eight agents without file conflicts. Claude Code supports them for [sub-agent isolation](https://www.threads.com/@boris_cherny/post/DVAAoZ3gYut/). The practical ceiling is [5-7 concurrent agents](https://dev.to/augusto_chirico/claude-code-loves-worktrees-your-infrastructure-doesnt-kfi) before rate limits and merge conflicts eat the gains, and worktrees share databases and Docker daemons, so two agents modifying database state simultaneously creates race conditions no branch isolation can prevent.

## Security and permissions

Giving an AI agent shell access requires trust. The environment layer is where that trust gets enforced.

[Claude Code](https://code.claude.com/docs/en/security) uses the most granular permission system among major agents. Every action falls into deny (blocked entirely), ask (requires confirmation), or allow (proceeds automatically). You can give the agent autonomy for safe operations while hard-blocking destructive ones. Anthropic's internal testing found that [sandboxing reduces permission prompts by 84%](https://www.anthropic.com/engineering/claude-code-sandboxing), because clear boundaries let the agent run freely within them.

[Auto mode](https://www.anthropic.com/engineering/claude-code-auto-mode), released March 2026, replaces the blunt `--dangerously-skip-permissions` flag with a model-based classifier. Internal testing shows a [0.4% false positive rate on real traffic and 5.7% false negative rate on synthetic exfiltration](https://www.anthropic.com/engineering/claude-code-auto-mode). Anthropic recommends running it only inside a sandbox, the classifier is defense-in-depth, not the sole line of defense.

Most other tools still default to running with your full user permissions. Aider, Gemini CLI, and most open-source agents have no built-in permission system at all. The principle is the same across all of them: don't rely on the model's judgment for security. Use deterministic, environment-level boundaries.

## Git as infrastructure

Git is not just version control in agentic coding. It's environment infrastructure.

**Commits as checkpoints.** When an agent makes changes, committing before moving on gives you rollback if the next step breaks something. Aider [commits every change automatically](https://aider.chat/docs/git.html) with descriptive messages. Agents commit when a step succeeds, not when a feature is complete, using git as an undo mechanism.

**Branches as isolation.** Every cloud agent creates a branch for its work. Copilot creates a branch per issue. Devin per task. Cursor's background agents each get their own. The agent's work stays isolated until a human reviews and merges. And existing branch protection rules apply automatically: require CI to pass, require review approval, the agent's code gets the same quality gates as human code.

## The environment shapes what's possible

This is the point most people miss. The environment isn't plumbing. It determines what kinds of work an agent can do.

A CLI agent on your local machine can run your entire build pipeline, access your local database, use your SSH keys. It can do anything you can do. An IDE agent can see your cursor position and show changes inline, ideal for focused editing where visual feedback matters. A cloud agent can run for hours and scale to many parallel instances, ideal for batch work. A sandboxed agent is safer but more limited. An MCP-connected agent (covered in [Part 3](/articles/03-the-agent-layer)) can interact with GitHub, databases, Slack, and CI pipelines through a standardized protocol.

The choice of environment is a choice about capability, safety, and workflow. Understanding this layer means understanding why the same model produces different results in different contexts.

Anthropic's research makes this concrete: [infrastructure setup alone swings Terminal-Bench 2.0 scores by 6 percentage points](https://www.anthropic.com/engineering/infrastructure-noise), often exceeding the gaps between top models. The environment isn't a detail. It's a variable that matters as much as which model you pick.

---

*This is Part 5 of "The Anatomy of Agentic Coding Systems." [Part 4 covered the Harness Layer](/articles/04-the-harness-layer) - constraints, verification, and lifecycle management. Part 6 covers the Orchestration Layer - coordinating multiple agents on shared work.*

---

## Sources

1. [Claude Code Security](https://code.claude.com/docs/en/security) - Anthropic
2. [Making Claude Code More Secure and Autonomous](https://www.anthropic.com/engineering/claude-code-sandboxing) - Anthropic Engineering
3. [Claude Code Auto Mode](https://www.anthropic.com/engineering/claude-code-auto-mode) - Anthropic Engineering
4. [Quantifying Infrastructure Noise in Agentic Coding Evals](https://www.anthropic.com/engineering/infrastructure-noise) - Anthropic Engineering
5. [Sandboxing - Codex CLI](https://developers.openai.com/codex/concepts/sandboxing) - OpenAI Developers
6. [Docker Sandboxes](https://www.docker.com/blog/docker-sandboxes-run-claude-code-and-other-coding-agents-unsupervised-but-safely/) - Docker Blog
7. [GitHub Copilot: Meet the New Coding Agent](https://github.blog/news-insights/product-news/github-copilot-meet-the-new-coding-agent/) - GitHub Blog
8. [Background Agents](https://docs.cursor.com/en/background-agent) - Cursor Docs
9. [Parallel Agents / Worktrees](https://cursor.com/docs/configuration/worktrees) - Cursor Docs
10. [Devin AI Guide 2026](https://aitoolsdevpro.com/ai-tools/devin-guide/) - AI Tools DevPro
11. [Aider Git Integration](https://aider.chat/docs/git.html) - Aider
12. [Boris Cherny on Worktrees](https://www.threads.com/@boris_cherny/post/DVAAnexgRUj/) - Threads
13. [Claude Code Loves Worktrees. Your Infrastructure Doesn't.](https://dev.to/augusto_chirico/claude-code-loves-worktrees-your-infrastructure-doesnt-kfi) - DEV Community

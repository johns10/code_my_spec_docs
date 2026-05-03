# Maintenance: Where Agents Actually Earn Their Keep

Software maintenance eats [60-80% of total software cost](https://flairstech.com/blog/ai-software-maintenance-support). Always has. It's the unglamorous stuff - bug fixes, dependency updates, security patches, refactoring, keeping the lights on. And it's exactly where agentic tools deliver the most proven, measurable value today.

Here's why: maintenance tasks have clear success criteria. The bug is fixed or it isn't. The test passes or it doesn't. The vulnerability is patched or it's still open. Compare that to requirements gathering or architecture design, where "success" is subjective. Maintenance is where agents stop being impressive demos and start being useful.

## How Do AI Agents Turn GitHub Issues Into Pull Requests Automatically?

The new baseline for agentic maintenance is embarrassingly simple. You assign a GitHub issue to Copilot's coding agent. It spins up a dev environment, plans the work, opens a draft PR, writes the code, runs the tests, and asks for your review. If you leave feedback, it revises. [Developers using Copilot complete tasks 55% faster](https://petri.com/github-copilot-ai-agent-coding/) and [resolve bugs 35% faster](https://petri.com/github-copilot-ai-agent-coding/) than traditional methods.

The March 2026 update made this even more interesting. Copilot's [agentic code review](https://github.blog/news-insights/product-news/github-copilot-meet-the-new-coding-agent/) now feeds directly into the coding agent - review finds an issue, passes it to the agent, agent generates a fix PR. It's a closed loop. Review, fix, review.

The catch nobody talks about enough: from [2,000+ autonomous maintenance cycles](https://dev.to/kuro_agent/what-ai-tech-debt-looks-like-when-the-ai-maintains-its-own-code-38d0), "the test passed" is not the same as "the fix is correct." An agent can write a fix that makes the test green but is semantically wrong. Well-tested codebases aren't just nice to have - they're the prerequisite.

## What Is the Garbage Collection Pattern for AI-Generated Code?

The most compelling pattern I've seen in agentic maintenance comes from [OpenAI's harness engineering](/blog/the-harness-layer) article ([original](https://openai.com/index/harness-engineering/)). Their internal team discovered that agents generating code at high throughput were creating drift - inconsistent patterns, hand-rolled helpers that duplicated shared utilities, guessed data shapes instead of typed SDKs. The team was spending 20% of their week manually cleaning up what they called "AI slop."

Their solution: background Codex tasks that run on a regular cadence. Scan for deviations from encoded "golden principles." Update quality grades. Open targeted refactoring PRs that can be reviewed in under a minute and automerged. It functions like garbage collection - automated cleanup that scales proportionally to code generation throughput. The principles exist not just for humans but to make the codebase readable for the next agent run.

This matters because AI is simultaneously the cause and cure for technical debt. [Ox Security found ten recurring anti-patterns in 80-100% of AI-generated code](https://www.infoq.com/news/2025/11/ai-code-technical-debt/) - incomplete error handling, weak concurrency, inconsistent architecture. [Unmanaged AI code drives maintenance costs to 4x traditional levels by year two](https://www.buildmvpfast.com/blog/ai-generated-code-technical-debt-management-2026). If your cleanup agents aren't keeping pace with your generation agents, you're accumulating debt faster than you're paying it down.

## How Does Multi-Agent Code Review Work and Why Is It More Accurate?

Anthropic's approach to code review is the most sophisticated I've seen publicly documented. They dispatch [multiple agents per PR](https://claude.com/blog/code-review), each targeting a different issue class - logic errors, boundary conditions, API misuse, authentication flaws, project convention compliance. After the agents flag issues, a verification step checks candidates against actual code behavior to filter false positives.

The results: [54% of PRs receive substantive comments](https://claude.com/blog/code-review) (up from 16% with older approaches), and [less than 1% of findings are marked incorrect by engineers](https://claude.com/blog/code-review). Anthropic runs this on nearly every internal PR.

The key insight is that single-agent review produces too many false positives. You need multiple specialized agents with a verification gate to achieve the precision that makes developers actually trust the output. [44% of developers used AI code review tools in 2025](https://dev.to/rahulxsingh/the-state-of-ai-code-review-in-2026-trends-tools-and-whats-next-2gfh), up from 18% in 2023. Repositories with AI-assisted review see [32% faster merge times and 28% fewer post-merge defects](https://dev.to/rahulxsingh/the-state-of-ai-code-review-in-2026-trends-tools-and-whats-next-2gfh).

## How Are AI Agents Automating Dependency Updates and Security Patching?

This is the most mature area of automated maintenance, and it predates the LLM era entirely. [Dependabot is configured on 846,000+ repos with 137% year-over-year growth](https://appsecsanta.com/dependabot). [Renovate](https://github.com/renovatebot/renovate) is the power-user alternative - open source, 90+ package managers, far more configurable for complex update strategies.

Where AI enters the picture is security-specific autofix. [Snyk Agent Fix](https://snyk.io/blog/building-ai-trust-with-snyk-code-and-snyk-agent-fix/) automatically generates code fixes for vulnerabilities, pre-screens every fix through a SAST scan to verify no new issues, and reduces an [average 7 hours of manual work per vulnerability to seconds](https://snyk.io/blog/building-ai-trust-with-snyk-code-and-snyk-agent-fix/). The stack is converging: Dependabot or Renovate for routine version bumps, Snyk for security fixes with AI verification, and general-purpose agents for complex migrations that require actual code changes.

## How Do You Hand Off Long-Running Maintenance Tasks Between Agent Sessions?

Maintenance work is inherently unbounded. Features have a "done" state. Maintenance is continuous. A major framework upgrade, a multi-week debt paydown, migrating an API across a large codebase - these exceed a single agent session. Context windows fill up, performance degrades, work gets lost.

Anthropic's engineering team published [two](https://www.anthropic.com/engineering/harness-design-long-running-apps) [articles](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) on solving this with structured handoffs. The pattern uses a planner agent that breaks work into chunks, a generator that executes, and an evaluator that judges the work adversarially (because agents approve their own work if you let them). Progress tracking files alongside git history let a fresh agent pick up exactly where the last one left off.

The practical applications for maintenance are obvious: multi-day refactoring campaigns, continuous security patching where each session handles a batch of vulnerabilities, framework migrations that process a subset of modules per session. Git becomes the state management system. The handoff document captures completed tasks, test status, what's next, and open questions.

## Where Is the Danger Line Between Self-Healing Infrastructure and Self-Healing Code?

There's a critical distinction that [Module.today articulated well](https://www.module.today/devops/the-self-healing-code-myth-automated-remediation-ai-repair-and-system-resilience): "self-healing infrastructure" is fundamentally different from "self-healing application logic." Restarting a failed pod, rolling back a bad deployment, scaling resources up - that's deterministic, well-understood, and mature. Fixing code bugs in production with AI is probabilistic and dangerous.

[83% of successful self-healing implementations use tiered autonomy](https://www.module.today/devops/the-self-healing-code-myth-automated-remediation-ai-repair-and-system-resilience) - routine issues fully automated, complex scenarios keep human oversight. That balanced approach reduces resolution times 60-70% while maintaining governance. The AI SRE category is betting big on this: [Resolve.ai hit $1B valuation in under two years](https://www.techbuzz.ai/articles/resolve-ai-hits-unicorn-status-with-125m-series-a), and [Datadog's Bits AI SRE](https://www.datadoghq.com/product/ai/bits-ai-sre/) claims root cause identification 90% faster with resolution time decreased up to 95%.

The reality is that letting an agent restart a pod at 3am is a solved problem. Letting an agent rewrite your authentication logic at 3am because a test failed is how you end up on the news. Know where your danger line is.

## Are AI Agents Creating Technical Debt Faster Than They Can Clean It Up?

Here's the thing nobody wants to say out loud: AI agents are generating technical debt faster than they're cleaning it up, and most teams don't realize it yet. [Cumulative AI-introduced issues exceeded 110,000 by February 2026](https://arxiv.org/html/2603.28592v1). Developers are leaving TODO comments that literally say ["fix the mess Gemini created"](https://arxiv.org/html/2601.07786v1).

The teams that are getting this right run a continuous loop. Agents generate code. Review agents catch issues on every PR. Background agents scan and clean on a cadence. Specialized tools target specific debt categories - [CodeScene ACE](https://codescene.com/product/integrations/ide-extensions/ai-refactoring) for structural debt that's validated against measurable code health metrics, Snyk for security debt, [Moderne/OpenRewrite](https://www.moderne.ai/) for deterministic migration recipes across thousands of repos.

This creates what I'd call a maintenance equilibrium - debt generation and debt reduction happening at similar rates. But it doesn't happen by accident. You have to build the cleanup pipeline intentionally, and you have to treat your maintenance agents with the same seriousness as your development agents.

If your cleanup agents aren't keeping pace with your generation agents, you're building a house on sand. You'll figure that out around year two, when [maintenance costs hit 4x what you expected](https://www.buildmvpfast.com/blog/ai-generated-code-technical-debt-management-2026).

## Frequently Asked Questions

**Can AI agents fully automate software maintenance without human oversight?** Not yet. AI agents excel at well-defined maintenance tasks with clear success criteria -- bug fixes, dependency updates, security patches. However, 83% of successful self-healing implementations use tiered autonomy, keeping human oversight for complex scenarios. Routine issues can be fully automated, but anything involving application logic changes still needs a human in the loop.

**What is the garbage collection pattern for AI-generated codebases?** The garbage collection pattern uses background AI agents that run on a regular cadence to scan for deviations from encoded coding principles, update quality grades, and open targeted refactoring PRs. This approach scales cleanup proportionally to code generation throughput, functioning like automated garbage collection in a runtime environment.

**How much does AI-generated technical debt increase maintenance costs?** Unmanaged AI code drives maintenance costs to 4x traditional levels by year two. Ox Security found ten recurring anti-patterns in 80-100% of AI-generated code, including incomplete error handling and inconsistent architecture. Teams that do not run cleanup agents alongside generation agents accumulate debt faster than they pay it down.

**What tools are best for automated dependency updates and security patching?** The stack is converging on Dependabot or Renovate for routine version bumps, Snyk Agent Fix for security vulnerabilities with AI verification, and general-purpose coding agents for complex migrations requiring actual code changes. Snyk reduces an average 7 hours of manual work per vulnerability to seconds by automatically generating and pre-screening fixes.

**How does multi-agent code review reduce false positives?** Single-agent code review produces too many false positives to be trusted. Anthropic's approach dispatches multiple specialized agents per PR, each targeting a different issue class, then runs a verification step that checks findings against actual code behavior. This achieves less than 1% incorrect findings and generates substantive comments on 54% of PRs.

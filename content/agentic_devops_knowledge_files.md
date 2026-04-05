# Teaching AI Agents to Deploy: Knowledge Files vs. Direct Access

*The deployment gap is real. Here's how to close it without giving your agent the keys to production.*

---

AI agents can build full applications now. Backend, frontend, database schema, tests. But the moment the code needs to run somewhere, you're back to doing IT admin. Spinning up servers, configuring DNS, navigating cloud consoles. The agent did the creative work. You're doing the ops.

[78% of enterprises have AI agent pilots](https://www.digitalapplied.com/blog/ai-agent-scaling-gap-march-2026-pilot-to-production) but under 15% reach production. The last mile is still manual.

Two approaches are emerging. One gives agents direct infrastructure access through MCP servers. The other teaches agents about your infrastructure through knowledge files. I use the second.

## What are the risks of giving AI agents direct infrastructure access?

The MCP ecosystem has exploded with infrastructure servers. [AWS has 66 MCP servers](https://awslabs.github.io/mcp/) covering EKS, ECS, Lambda, CDK, CloudFormation, S3. Docker ships an [MCP Toolkit](https://www.docker.com/blog/run-claude-code-with-docker/) with 300+ containerized servers. [Pulumi Neo](https://www.pulumi.com/blog/ai-predictions-2026-devops-guide/) generates Terraform from natural language. [Harness AIDA](https://www.harness.io/blog/agentic-ai-in-devops-the-architects-guide-to-autonomous-infrastructure) uses OPA policy engines to gate every action.

The capability is real. So is the risk. [48% of cybersecurity pros](https://www.bvp.com/atlas/securing-ai-agents-the-defining-cybersecurity-challenge-of-2026) call agentic AI the most dangerous attack vector. Average shadow AI breach cost: $4.63M.

## How do knowledge files teach AI agents about your infrastructure?

Instead of giving my agent infrastructure access, I encode deployment knowledge into markdown files it reads as context.

I run a Phoenix/Elixir app on a Hetzner cax11 (ARM64, 4GB, ~$4/month) with Docker Compose, Caddy, Postgres, Cloudflare DNS with tunnels, AWS S3, and Resend for email. All documented in four files under `priv/knowledge/devops/`:

- `hetzner-docker-deploy.md` - Server provisioning, Docker Compose config, Caddy, zero-downtime deploys
- `cloudflare-dns-tunnels.md` - DNS, multi-environment routing (prod/uat/dev), tunnel setup
- `aws-s3-iam.md` - Buckets, scoped IAM policies, naming conventions
- `cloudflare-resend-email-setup.md` - SPF, DKIM, DMARC, Swoosh config

Each file has the CLI commands, configuration snippets, naming conventions, and the decisions behind them. When I ask Claude to deploy a new environment or debug a DNS issue, it reads these files and has the full picture.

## Why do knowledge files work better than direct access for deployment?

**The agent follows my decisions.** My deploy doc doesn't just say how to create a server. It says which server type (cax11), why (cheapest ARM64 with 4GB), which region, and the exact Docker Compose structure. The agent executes my decisions, not its own.

**No credential exposure.** The agent reads docs and generates commands I review before running. No API keys exposed. If prompt injection got through, the worst it does is generate bad commands I don't execute.

**It compounds.** Every deployment problem I solve, I update the knowledge file. Next time Claude hits the same situation, it has the answer. Over months these become comprehensive runbooks.

## What does using knowledge files for deployment look like in practice?

I tell Claude "set up a UAT environment following the deployment docs." It reads the knowledge files, generates the `hcloud` commands, writes the Docker Compose config, generates Cloudflare DNS records, produces the Caddy config. I review, run the commands, environment is up.

For debugging: "UAT isn't responding" leads Claude to check Caddy config, verify Docker containers, check tunnel status, all from the documented patterns.

## Where is the future of AI agents and infrastructure heading?

Knowledge files and MCP infrastructure servers aren't mutually exclusive. [Pulumi's Review mode](https://www.pulumi.com/blog/ai-predictions-2026-devops-guide/) and [Harness's OPA gates](https://www.harness.io/blog/agentic-ai-in-devops-the-architects-guide-to-autonomous-infrastructure) point toward a middle ground where agents can act but guardrails prevent catastrophic mistakes. [Pulumi published 8 Claude skills for DevOps](https://www.pulumi.com/blog/top-8-claude-skills-devops-2026/) that are basically knowledge files installed in `.claude/skills/`.

For now, knowledge files are the pragmatic choice. Free, safe, work with any AI coding tool, and your deployment process gets better documented as a side effect. Let the agent write down how you deploy and it will do it repeatably.

## Frequently Asked Questions

**What are knowledge files for AI agents?** Knowledge files are markdown documents that encode your infrastructure decisions, CLI commands, configuration patterns, and deployment runbooks. Instead of giving an AI agent API access to your cloud provider, the agent reads these files as context and generates commands for you to review and execute.

**Can knowledge files replace MCP infrastructure servers entirely?** For many teams, yes. Knowledge files handle the majority of deployment workflows without any credential exposure or security risk. However, as guardrail technologies like OPA policy gates and review modes mature, a hybrid approach combining knowledge files with controlled MCP access will likely become the standard.

**How do you keep knowledge files up to date?** Every time you solve a deployment problem or change your infrastructure, you update the relevant knowledge file. Over time, they become comprehensive runbooks. Because they live in your git repository, they are version-controlled and reviewable like any other code artifact.

**Do knowledge files work with AI coding tools other than Claude?** Yes. Knowledge files are plain markdown, so they work with any AI coding tool that can read files from your project directory. Cursor, Copilot, Windsurf, and any MCP-compatible tool can consume them. There is no vendor lock-in.

**What should a good deployment knowledge file contain?** A good knowledge file includes the CLI commands for each step, the configuration snippets, the naming conventions you follow, the reasoning behind your choices, and troubleshooting steps for common issues. The goal is to give the agent enough context to reproduce your decisions without needing to make its own.

---

## Sources

1. [AI Agent Scaling Gap](https://www.digitalapplied.com/blog/ai-agent-scaling-gap-march-2026-pilot-to-production) - Digital Applied
2. [AWS MCP Servers](https://awslabs.github.io/mcp/) - AWS Labs
3. [Docker MCP Toolkit](https://www.docker.com/blog/run-claude-code-with-docker/) - Docker
4. [Pulumi AI Predictions 2026](https://www.pulumi.com/blog/ai-predictions-2026-devops-guide/) - Pulumi
5. [Agentic AI in DevOps](https://www.harness.io/blog/agentic-ai-in-devops-the-architects-guide-to-autonomous-infrastructure) - Harness
6. [Securing AI Agents](https://www.bvp.com/atlas/securing-ai-agents-the-defining-cybersecurity-challenge-of-2026) - Bessemer Venture Partners
7. [Top 8 Claude Skills for DevOps](https://www.pulumi.com/blog/top-8-claude-skills-devops-2026/) - Pulumi

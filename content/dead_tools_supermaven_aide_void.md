# What Happened to Supermaven, Aide, and Void: The AI Coding Tools That Didn't Make It

## Introduction

For every Cursor that hits $2B ARR, several tools don't make it. Three notable casualties from 2025-2026: Supermaven got acquired, Aide/Codestory sunsetted, Void went silent. Three different failure modes, one consolidating market.

## Supermaven: Acquired Into Cursor

**What it was:** A VS Code extension focused on fast, accurate autocomplete. Founded by Jacob Jackson (who previously built Tabnine's core tech).

**What happened:** Cursor acquired Supermaven in November 2025. The extension was deprecated and the tech was folded into Cursor's Tab completion.

**The lesson:** Single-feature tools get absorbed. If your entire product is one capability a larger tool can replicate or buy, you're an acquisition target, not a business. Cursor didn't buy Supermaven to kill it -- they bought it to make Tab better. The tech lives on. The product doesn't.

**Search traffic:** People searching "Supermaven alternatives" land at Cursor (which now includes the tech), Copilot, or Tabnine.

## Aide / Codestory: Sunsetting

**What it was:** An AI code editor (VS Code fork) from Codestory, focused on deep codebase understanding rather than fast generation.

**What happened:** Codestory announced Aide was sunsetting, citing inability to compete with the funding and speed of Cursor, Windsurf, and the vendor CLI agents.

**The lesson:** In a venture-funded category with network effects, the window to establish position is narrow. Aide had a good product philosophy. Cursor had 1,000x the users and shipped faster. The product didn't fail -- the timing and funding did.

**Search traffic:** "Aide alternatives" leads to Cursor, Zed (for thoughtful editing), or Claude Code (for deep codebase understanding).

## Void: Paused/Silent

**What it was:** Open-source "Cursor alternative" (VS Code fork) with 28K GitHub stars. Promised a free, transparent, community-driven AI IDE.

**What happened:** Development slowed dramatically. The repo went quiet. No shutdown announcement, no meaningful updates, inactive Discord. 28K stars on a stale repo.

**The lesson:** Open-source alone isn't enough. You need a sustainable funding model -- Aider has community support, Zed has venture backing, Goose has Block. Void relied on enthusiasm, and enthusiasm doesn't ship features at the pace of a $29.3B company.

**Search traffic:** "Void alternatives" leads to Zed, PearAI, or Cursor.

## Adjacent Pattern: Market Exits

Not every tool that leaves the consumer market dies. Some exit deliberately:

- **Amp (formerly Sourcegraph Cody)** went enterprise-only in mid-2025. Cody Free and Cody Pro were discontinued July 23, 2025. In 2026 Amp spun out as standalone Amp Inc. (Quinn Slack CEO). Not dead -- just done with individual developers.
- **GitHub Copilot paused new Pro, Pro+, and Student signups on April 20, 2026.** Not dead -- supply-constrained. Existing subscribers keep access; new signups gated.

Both signal the same thing: vendor consolidation continues, and even the winners are making hard choices about who they serve. "Consumer developer" is a harder market than "enterprise buyer" in 2026.

## Why AI Coding Tools Die

### 1. Single-Feature Trap (Supermaven)

If your entire product is one capability -- autocomplete, code review, docs -- a larger tool will build it or buy you. The market is consolidating around full-stack tools that handle completion, agent execution, and code review.

**At risk:** Pure autocomplete tools, single-purpose code review tools, documentation-only generators.

### 2. Funding Gap (Aide)

Cursor raised $2.3B. Cognition (Windsurf) is valued at $10.2B. Google backs Gemini CLI. Amazon backs Kiro. Competing with those balance sheets on a Series A means you need a narrow niche or a fundamentally different model.

**At risk:** Small-team AI editors without clear differentiation or corporate backing.

### 3. Sustainability Gap (Void)

Open-source without sustained funding or a corporate sponsor doesn't keep up. "Build it and they will come" works for low-maintenance libraries, not products competing with billion-dollar companies shipping weekly.

**At risk:** Open-source AI tools without commercial backing. PearAI faces this question. OpenCode's growth is impressive but sustainability is unproven.

## What the Survivors Have in Common

- **Cursor:** Massive funding, fastest execution, network effects
- **Claude Code:** Anthropic's model advantage, deep integration
- **Codex CLI:** OpenAI's ecosystem, open source with corporate backing
- **Gemini CLI:** Google's resources, genuine free tier
- **Aider:** Pioneer advantage, benchmark authority, community-funded
- **GitHub Copilot:** Microsoft/GitHub distribution, enterprise relationships (even while gating signups)
- **Zed:** Differentiated technology (Rust, GPUI), open source with venture backing

Either massive corporate backing, pioneer advantage with community, or genuinely different technology. "Another VS Code fork with AI" is not a position.

## How I'd Evaluate a Tool Today

1. **Who's funding it?** $2B+ ARR (Cursor) or a major corporate parent isn't going anywhere soon. Enthusiasm-funded might.
2. **What's unique?** VS Code fork with AI chat is competing on Cursor's terms. Unique technology (Zed's GPUI), unique workflow (Kiro's specs, Aider's git integration), or unique positioning (Gemini CLI's free tier) has defensible ground.
3. **Is the code open?** If a proprietary tool dies, your workflow dies with it. Open source -- even abandoned like Void -- can be forked.
4. **What's the migration path?** CLAUDE.md, AGENTS.md, .cursorrules, MCP servers -- portable context means you can switch without starting over. Proprietary lock-in increases your risk.

## Sources

- [Cursor Acquires Supermaven -- TechCrunch](https://techcrunch.com/2025/11/cursor-supermaven-acquisition/)
- [Void Editor GitHub](https://github.com/voideditor/void)
- [Cursor $2B ARR -- TechCrunch](https://techcrunch.com/2026/03/02/cursor-has-reportedly-surpassed-2b-in-annualized-revenue/)
- [Cognition $10.2B Valuation -- CNBC](https://www.cnbc.com/2025/09/08/cognition-valued-at-10point2-billion-two-months-after-windsurf-.html)
- [Sourcegraph discontinues Cody Free/Pro -- July 23, 2025](https://sourcegraph.com/blog/)
- [GitHub Copilot pauses new Pro/Pro+/Student signups -- April 20, 2026](https://github.blog/)

# How I Do Marketing with Claude Code and MCP Tools

*I'm not a marketing guru. I'm an engineer who hates marketing. Here's what actually worked.*

---

I've been building software for years and I'm terrible at marketing. Not "humble brag" terrible. Actually terrible. I've shipped products nobody used because I couldn't bring myself to tell anyone about them. Building is my happy place. Marketing is paralyzing.

But I needed to market CodeMySpec. So I did what any engineer would do. I turned it into an engineering problem.

## How it actually started

I sat down with Claude and came up with a strategy based on some theories I had. My users hang out on Reddit. I'm active on r/elixir. I know the AI coding subs. So we started there.

First thing: hook up a Reddit MCP server. Now Claude can scan subreddits and pull thread details. We started commenting, being helpful in threads where my experience was relevant. No grand plan. Just show up and be useful.

After a couple weeks, I wanted to know if any of this was working. So I added a Google Analytics MCP server. Now I could pull traffic reports right from Claude Code. And I could see it - people were actually clicking through from my comments.

Then something interesting happened. I saw people signing up. Not a flood, but real registrations. So I added Google Analytics admin capabilities and set up conversion tracking so I could see the full funnel.

I started researching the people who signed up. Who were they? Where did they come from? Which comments drove them?

Then I wanted to make sure I was set up for SEO, because the Reddit comments were driving traffic but I had basically zero organic search presence. Added the Google Search Console MCP. Immediately found that Google thought my canonical URL was an old ngrok tunnel from development. Fixed it the same day.

The pattern is always the same: strategize, add a tool, execute, review results, adjust strategy, add another tool, execute, review. Each cycle makes the next one better. I didn't plan a "marketing stack." I added each piece when I needed it.

## The loop today

I tell Claude to scan Reddit. It uses a Reddit MCP server to pull hot and new posts from r/elixir, r/ChatGPTCoding, r/vibecoding, and r/ClaudeAI. It writes lead files - little markdown docs with the thread title, score, top comment vibe, and an angle for why my experience is relevant. I pick 2-3 threads.

Claude drafts talking points. Not a ready-to-post comment - AI-written comments read like AI-written comments and Reddit can tell. Claude gives me the angle and the key insight to hit. I dictate my actual response. Claude polishes it lightly. I post it.

Then I pull Google Analytics through another MCP server. Every link carries a UTM tag, so I can see exactly which comment drove which sessions. I check Search Console through a third MCP server to see if my content is getting indexed and what queries are showing up.

I adjust based on what the data says. Then I scan again. I run the loop daily.

## The MCP stack

Four servers, each doing one thing.

**Reddit MCP** ([reddit-mcp-buddy](https://github.com/nicosql/reddit-mcp-buddy)) - Browse subreddits, get post details with comments, search. The workhorse. It lets me read the room before I say anything.

**Google Analytics MCP** ([analytics-mcp](https://github.com/nicosql/analytics-mcp)) - Traffic reports filtered by UTM campaign. Which Reddit threads drove traffic, how long people stayed, how many pages they viewed.

**Google Search Console MCP** ([mcp-gsc](https://github.com/AminForou/mcp-gsc)) - Indexing status, query impressions, canonical issues. I found out Google thought my site's canonical URL was an old ngrok tunnel. Would never have caught that without this.

**Twitter MCP** - Same pattern as Reddit. Search conversations, draft replies.

I encoded the repeatable workflows as slash commands: `/scan-reddit`, `/draft-response`, `/scan-twitter`, `/draft-tweet`, `/news-scan`. Each one reads my memory files first so Claude has context about my positioning before it starts.

## What I learned the hard way

**AI-drafted comments bomb.** Early on I let Claude write the full comment and I'd tweak it slightly. Reddit could tell. The comments that perform are the ones I dictate and Claude polishes. The natural cadence, the tangents, the genuine reactions - that's what makes it human.

**Links to specific content work. Links to homepage don't.** My best comment linked to an article about managing architecture. It drove sessions for three months. My worst posts were self-promotional links to the homepage. 4 seconds average duration, 75% bounce.

**Read the room.** The scan captures top comments and their sentiment. If the top comment is dismissive, walking in with an earnest pitch gets destroyed. The top comment tells you what the audience rewards.

**The content has to exist first.** You can't link to something you haven't written. I have 100+ articles in my content library. When a thread asks about testing AI-generated code, I have an article for that. The marketing works because the content already exists and is genuinely useful. I have a content system in my harness where I write a markdown file with a YAML sidecar, git push, and it's live. When I spot a content gap from a Reddit thread, I can write the article and publish it the same day.

## The numbers

Here's what the last 28 days actually look like, pulled from my GA4 and Search Console MCP tools right now:

- 227 users, 439 sessions, 1,402 pageviews total
- Reddit comments drove 189 sessions (43% of all traffic), 109 unique users, 606 pageviews
- 61% of those Reddit sessions were engaged (116 out of 189), averaging nearly 5 minutes each
- My CLI agents comparison article got 124 views from 87 users, mostly from Reddit
- 12 people hit the registration page. From Reddit comments alone.
- Google Search Console shows 32 impressions across 28 days with 4 content pages appearing on page 1-2. Organic is basically zero right now. Early days.
- My top Reddit comment this month (on an agentic workflows thread in r/ClaudeAI) scored 17 upvotes and drove a pile of sessions

Is this going to make me rich? Not yet. Can a solo developer run this in 30 minutes a day and see real traffic? Yeah.

## Everything is files

The leads, the touchpoints, the content, the strategy docs, the analytics baselines - it's all git-tracked markdown. When I scan Reddit next week, Claude reads the touchpoints and knows what I've already said, which threads I've engaged, and what angles worked. The system remembers what I forget.

Marketing advice for engineers usually falls into "just put yourself out there" (useless) or "hire a marketer" (expensive). What actually works is treating it like engineering. Define inputs. Build a process. Create feedback loops. Iterate on data. You don't need a marketing degree. You need Claude Code, a few MCP servers, and the willingness to show up where your users talk.

---

## Sources

1. [RSL/A: Claude Code Marketing Agency Workflow](https://rsla.io/blog/claude-code-marketing-agency-workflow) - 2-person agency, 9 MCP tools, 3-5x productivity gains
2. [FutureSearch: Marketing Pipeline Using Claude Code](https://futuresearch.ai/blog/marketing-pipeline-using-claude-code/) - Automated community scanning, 2-3% signal rate
3. [MKT1: Marketers Building with Claude Code](https://newsletter.mkt1.co/p/real-marketers-claude-code-builds) - Positioning checker, lookalike agents, ad intelligence
4. [Creating AI Agents for Solopreneur Marketing](https://david.bozward.com/2026/03/creating-ai-agents-to-supercharge-your-marketing-as-a-one-person-business-in-2026/) - 7 agent categories, minimal stack

---

*This is how I market CodeMySpec. It's a feedback loop with MCP tools. If you're an engineer struggling with marketing, skip the guru advice and just build a loop.*

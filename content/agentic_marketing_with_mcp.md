# How I Do Marketing with Claude Code and MCP Tools

*I'm not a marketing guru. I'm an engineer who hates marketing. Here's what actually worked.*

---

I've been building software for years and I'm terrible at marketing. Not "humble brag" terrible. Actually terrible. I've shipped products nobody used because I couldn't bring myself to tell anyone about them. Building is my happy place. Marketing is paralyzing.

But I needed to market CodeMySpec. So I did what any engineer would do. I turned it into an engineering problem.

## How did I get started with AI-powered marketing as a developer?

I sat down with Claude and came up with a strategy based on some theories I had. My users hang out on Reddit. I'm active on r/elixir. I know the AI coding subs. So we started there.

First thing: hook up a Reddit MCP server. Now Claude can scan subreddits and pull thread details. We started commenting, being helpful in threads where my experience was relevant. No grand plan. Just show up and be useful.

After a couple weeks, I wanted to know if any of this was working. So I added a Google Analytics MCP server. Now I could pull traffic reports right from Claude Code. And I could see it - people were actually clicking through from my comments.

Then something interesting happened. I saw people signing up. Not a flood, but real registrations. So I added Google Analytics admin capabilities and set up conversion tracking so I could see the full funnel.

I started researching the people who signed up. Who were they? Where did they come from? Which comments drove them?

Then I wanted to make sure I was set up for SEO, because the Reddit comments were driving traffic but I had basically zero organic search presence. Added the Google Search Console MCP. Immediately found that Google thought my canonical URL was an old ngrok tunnel from development. Fixed it the same day.

The pattern is always the same: strategize, add a tool, execute, review results, adjust strategy, add another tool, execute, review. Each cycle makes the next one better. I didn't plan a "marketing stack." I added each piece when I needed it.

## What does the daily marketing loop look like with Claude Code and MCP?

I tell Claude to scan Reddit. It uses a Reddit MCP server to pull hot and new posts from r/elixir, r/ChatGPTCoding, r/vibecoding, and r/ClaudeAI. It writes lead files - little markdown docs with the thread title, score, top comment vibe, and an angle for why my experience is relevant. I pick 2-3 threads.

Claude drafts talking points. Not a ready-to-post comment - AI-written comments read like AI-written comments and Reddit can tell. Claude gives me the angle and the key insight to hit. I dictate my actual response. Claude polishes it lightly. I post it.

Then I pull Google Analytics through another MCP server. Every link carries a UTM tag, so I can see exactly which comment drove which sessions. I check Search Console through a third MCP server to see if my content is getting indexed and what queries are showing up.

I adjust based on what the data says. Then I scan again. I run the loop daily.

## Which MCP servers make up the marketing stack?

Four servers, each doing one thing.

**Reddit MCP** ([reddit-mcp-buddy](https://github.com/nicosql/reddit-mcp-buddy)) - Browse subreddits, get post details with comments, search. The workhorse. It lets me read the room before I say anything.

**Google Analytics MCP** ([analytics-mcp](https://github.com/nicosql/analytics-mcp)) - Traffic reports filtered by UTM campaign. Which Reddit threads drove traffic, how long people stayed, how many pages they viewed.

**Google Search Console MCP** ([mcp-gsc](https://github.com/AminForou/mcp-gsc)) - Indexing status, query impressions, canonical issues. I found out Google thought my site's canonical URL was an old ngrok tunnel. Would never have caught that without this.

**Twitter MCP** ([twitter-mcp](https://github.com/EnesCinr/twitter-mcp)) - Same pattern as Reddit. Search conversations, surface reply opportunities, draft tweets.

**Claude SEO Plugin** ([claude-seo](https://github.com/AgriciDaniel/claude-seo)) - This one changed the game for me. It's a full SEO audit and optimization skill for Claude Code. It runs parallel subagents for technical SEO, content quality, schema markup, sitemaps, performance, and AI search readiness. I ran `/seo audit` on my site and it scored me 56/100, found my canonical URLs were doubling, my schema JSON-LD had broken URLs, and Cloudflare was blocking every AI crawler. Fixed all of it the same day. It also handles Google PageSpeed, CrUX field data, and URL indexing submissions. I submitted 23 URLs for indexing through it in one session.

I encoded the repeatable workflows as slash commands: `/scan-reddit`, `/draft-response`, `/scan-twitter`, `/draft-tweet`, `/news-scan`, `/seo audit`. Each one reads my memory files first so Claude has context about my positioning before it starts.

## What are the biggest mistakes to avoid with AI-assisted marketing?

**AI-drafted comments bomb.** Early on I let Claude write the full comment and I'd tweak it slightly. Reddit could tell. The comments that perform are the ones I dictate and Claude polishes. The natural cadence, the tangents, the genuine reactions - that's what makes it human.

**Links to specific content work. Links to homepage don't.** My best comment linked to an article about managing architecture. It drove sessions for three months. My worst posts were self-promotional links to the homepage. 4 seconds average duration, 75% bounce.

**Read the room.** The scan captures top comments and their sentiment. If the top comment is dismissive, walking in with an earnest pitch gets destroyed. The top comment tells you what the audience rewards.

**The content has to exist first.** You can't link to something you haven't written. I have 100+ articles in my content library. When a thread asks about testing AI-generated code, I have an article for that. The marketing works because the content already exists and is genuinely useful. I have a content system in my harness where I write a markdown file with a YAML sidecar, git push, and it's live. When I spot a content gap from a Reddit thread, I can write the article and publish it the same day.

**Let Reddit threads tell you what to write.** My best-performing content series came from reading r/vibecoding threads. Someone posted a list of 15 tools vibe coders should use. The top comment was "Too many words, just prompt." The second comment: "I have no idea what any of that means." So I wrote a series explaining those fundamentals in plain English. The articles get linked in threads that are asking the exact questions they answer. The content writes itself when you listen to what people are confused about.

## What kind of results can a solo developer expect from this approach?

Here's what the numbers actually look like after running this for about six weeks, pulled from my GA4 and Search Console MCP tools:

- Two consecutive all-time traffic records in one week (61 users, then 80 users the next day)
- Reddit UTM comments drove 107 sessions in 3 days, averaging 4:25 per session. People are reading entire articles.
- 30 registered users. 7 signups in the last 7 days - registration pace tripled from the previous month.
- 9 out of 10 people who visited the registration page came from Reddit comments.
- My best-performing comment by volume (CLI agents comparison) drove 67 sessions from 42 users.
- My best-performing comment by depth (a reply on a "month 3 wall" frustration thread) drove only 12 sessions - but those users averaged 17 minutes and 13.8 pages each. They read the entire site.
- My highest-upvoted comment (87 upvotes, about multi-agent FOMO) had no link at all. It built reputation without driving direct traffic. That's fine - reputation compounds.

The funnel analysis surprised me. High upvotes don't always mean high click-through. Thread size and comment position matter more than upvote count. And empathy comments in frustration threads produce the deepest readers - the people most likely to sign up. Tool comparison comments produce volume. You need both.

Is this going to make me rich? Not yet. Can a solo developer run this in 30 minutes a day and see real, measurable traction? Yeah.

## Why does storing everything as files make the marketing system work?

The leads, the touchpoints, the content, the strategy docs, the analytics baselines - it's all git-tracked markdown. When I scan Reddit next week, Claude reads the touchpoints and knows what I've already said, which threads I've engaged, and what angles worked. The system remembers what I forget.

Marketing advice for engineers usually falls into "just put yourself out there" (useless) or "hire a marketer" (expensive). What actually works is treating it like engineering. Define inputs. Build a process. Create feedback loops. Iterate on data. You don't need a marketing degree. You need Claude Code, a few MCP servers, and the willingness to show up where your users talk.

## Frequently Asked Questions

**Can an engineer with no marketing experience use MCP tools for marketing?** Yes. The entire approach is built around engineering principles: define inputs, build a repeatable process, create feedback loops, and iterate on data. You do not need marketing expertise. You need the willingness to show up where your users are and let the data guide your next move.

**How much time does this marketing loop take per day?** About 30 minutes once the MCP servers are configured and the slash commands are set up. The scanning, drafting, and analytics review are fast because Claude handles the data gathering. The human time goes into picking threads, dictating authentic responses, and reviewing analytics.

**Why not let AI write the full Reddit comment?** Reddit communities can detect AI-written comments quickly, and those comments perform poorly. The comments that drive real engagement are ones where you dictate your genuine thoughts and let Claude polish the phrasing. The natural cadence, tangents, and authentic reactions are what make a comment resonate.

**Do I need a large content library before starting?** Not to start, but the approach works best when you have content to link to. You can begin by being helpful in discussions without linking anything. As you spot content gaps from real conversations, write articles to fill those gaps. Over time, your library grows organically based on actual demand.

**Which MCP servers are essential to get started?** Start with just the Reddit MCP server and Google Analytics MCP server. Reddit lets you find and engage with your audience. Analytics lets you see what is working. Add Search Console and Twitter MCP servers later as your needs grow. The SEO plugin is worth installing early - it catches technical issues that silently kill your search presence.

**How do you track which comments actually lead to signups?** Every link carries UTM parameters: source, medium, campaign, and content. The content tag is unique per comment, so I can trace a signup back through the funnel: Reddit thread impressions, comment upvotes, UTM click-through, GA4 session, pages read, registration page view, signup. The data showed me that empathy comments in frustration threads produce the deepest readers, while tool comparison comments produce the most volume. Different strategies for different goals.

---

## Sources

1. [RSL/A: Claude Code Marketing Agency Workflow](https://rsla.io/blog/claude-code-marketing-agency-workflow) - 2-person agency, 9 MCP tools, 3-5x productivity gains
2. [FutureSearch: Marketing Pipeline Using Claude Code](https://futuresearch.ai/blog/marketing-pipeline-using-claude-code/) - Automated community scanning, 2-3% signal rate
3. [MKT1: Marketers Building with Claude Code](https://newsletter.mkt1.co/p/real-marketers-claude-code-builds) - Positioning checker, lookalike agents, ad intelligence
4. [Creating AI Agents for Solopreneur Marketing](https://david.bozward.com/2026/03/creating-ai-agents-to-supercharge-your-marketing-as-a-one-person-business-in-2026/) - 7 agent categories, minimal stack

---

*This is how I market CodeMySpec. It's a feedback loop with MCP tools. If you're an engineer struggling with marketing, skip the guru advice and just build a loop.*

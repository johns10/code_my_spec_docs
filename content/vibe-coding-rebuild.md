---
# Metadata for vibe-coding-rebuild.md

# Required fields
slug: vibe-coding-rebuild
type: landing
title: "Vibe Coding Rebuild: Keep the Behavior, Lose the Slop"

# Publishing control
protected: false
publish_at: 2026-07-10T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "Vibe Coding Rebuild & Cleanup Service | CodeMySpec"
meta_description: "Your Lovable or Replit app broke under real use. We reverse-engineer it into written specs, then rebuild it on a stack you own. Quoted straight, from $500."
og_title: "Vibe Coding Rebuild: Keep the Behavior, Lose the Slop"
og_description: "The app that broke is still a working specification of your business. We extract the stories, pin the behavior in executable specs, and rebuild on a stack you own."
og_image: og-landing-vibe-coding-rebuild.png

metadata:
  template: default
  author: John Davenport
  category: Services

tags:
  - vibe-coding
  - rebuild
  - cleanup
  - lovable
  - replit
  - bolt
  - spec-driven-development
---

# Vibe Coding Rebuild: Keep the Behavior, Lose the Slop

Cleanup is the wrong product. If your Lovable or Replit or Bolt app is breaking under real customers, the fix is not paying someone to patch generated code that nobody, including the machine that wrote it, ever understood. The patches compound the mess. The fix is extracting what your app already knows and rebuilding on it. Here's how I do that, and what it costs.

First: your situation is normal, and it is measured. A May 2026 scan found [more than 2,000 vibe-coded apps publicly exposing sensitive data](https://thehackernews.com/2026/05/what-2000-exposed-vibe-coded-apps.html), most without basic authentication. Veracode found AI-generated code carries 2.74 times more security flaws than human-written code. Your prototype was never the problem. Shipping the prototype as the product was.

## Your broken app is a working specification

The app in front of you demonstrates, click by click, how your business is supposed to work. Which fields matter on the intake form. What happens when an order is paid but not fulfilled. Who gets the email and when. You spent weeks encoding that knowledge through prompts, and it lives in the running app right now, even though the code underneath is a hairball.

That behavior is the asset. The code is disposable.

## Code got cheap. That flips the whole playbook.

Code used to be expensive, so the default for a broken app was salvage: refactor, patch, limp along. That math assumed the costly thing was writing code. It isn't anymore. The costly thing now is a precise understanding of what the app is supposed to do, and your running app already contains it. So the job is to extract that understanding, write it down in a form a machine can verify, and let the machine do what machines now do cheaply: write the code again, properly, with the spec as the contract.

## The process

1. **Extract the stories.** I point Claude Code at your codebase and your running app and pull out the user stories: every workflow, every rule, every edge case your prompting baked in. On research benchmarks, models [recover user stories from code with roughly 80% accuracy](https://arxiv.org/abs/2509.19587). You review the list. You'll find things you forgot were in there and things that were wrong all along. Better to know before the rebuild than after.

2. **Pin the behavior in executable specs.** I write behavior specs against your running app through the browser: log in as this user, submit this form, expect this result. The specs capture your app's behavior, not its code. That makes them portable. They describe your business, not your codebase.

3. **Recover the business rules.** Stories plus specs plus a read of the code surface the real rules of your operation, in plain language you can check. This document outlives any codebase.

4. **Rebuild against the specs.** I build spec first on Elixir and Phoenix, a deliberately boring stack that stays up and is [measurably the language AI writes best](/blog/why-elixir-is-the-best-language-for-llms). The specs written against your old app now run against the new one. When they pass, the rebuild is done. "Done" is a test result, not a vibe.

5. **You keep everything.** Stories, specs, rules document, code. If you ever leave, you leave with the full written record of how your software works. No vendor, including me, gets to hold that hostage again.

None of this is my invention. It's characterization testing, Michael Feathers' twenty-year-old discipline for taming legacy code: capture what the system actually does, then hold it steady while you replace everything underneath. It was always the right way to take over a codebase nobody understands. It was also expensive enough that almost nobody did it. Agents changed the price, not the idea.

And I'll be straight with you: the spec-driven build loop is how I build and run CodeMySpec every day, in the open. Pointing that discipline backwards at an existing app is the newer move, and on the call I'll tell you exactly how proven each step is.

## "Never rewrite from scratch." Doesn't that apply here?

The famous warning against rewrites is about losing accumulated knowledge: years of edge cases and bug fixes encoded in old code nobody remembers. The warning is correct, and this process is built around it. Steps one through three capture that knowledge in executable form before a single line gets rebuilt. A rewrite without specs is a gamble. A rewrite against specs extracted from the running system is a migration with a checklist.

And the warning assumes battle-tested code carrying years of fixes. A vibe-coded app is months old and carries the opposite: generated bulk nobody ever reviewed. The knowledge worth keeping lives in the behavior. The behavior is what I keep.

## What it costs

This is [Built with you](/pricing): a conversation, then a quote, $500 minimum. A small app with a handful of workflows lands close to that $500. A real operation costs real money, and you'll hear a specific number before anything starts, not an hourly meter. Once the rebuilt app is live, running it (email on your domain, live chat, publishing, reporting) is $100 a month per user. The build tooling stays free.

## Fair questions

**Why trust this over an agency?** Look at how cleanup agencies describe the work: audit, refactor, contact us for a quote. The deliverable is cleaner code, which you can't evaluate, on a timeline you can't verify. My process produces its proof as it goes: the stories and specs land in your hands early, in plain language, and you check them against your own business before the rebuild starts. I haven't found a cleanup service that hands you the specification as an artifact you keep. Here, it's the point.

**What do you need from me?** Access to the running app and the code export, plus a few conversations. You're the oracle for step one: only you know which behaviors are features and which are bugs you've been living with.

**Can my current app keep running during the rebuild?** Yes. Nothing in the process modifies your app or its code. The specs drive it through the browser the way a user would, against a test account or a staging copy. You switch over when the new app passes.

**What if I only want the specs?** Valid stopping point. The stories and specs are written against your business, not my stack. Take them anywhere.

Bring what's broken. [Book a call](https://cal.com/john-s10-davenport) and you'll get a straight answer on whether a rebuild makes sense and what it would cost.

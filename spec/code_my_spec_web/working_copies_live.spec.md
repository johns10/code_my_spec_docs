# CodeMySpecWeb.WorkingCopiesLive

Every working copy on a project, and what is running on each.

A harness is a working copy — `Harnesses.issue/3` mints one id per checkout, so "harness id" and "working copy id" are the same thing, and this page says so in the user's words rather than making them infer it. On this project that is this checkout and the QA checkout; on a shared host it is one per tenant.

Renders three joins that already exist: `Harnesses.list_harnesses/1` for the copies, `agents.working_copy` for what is running on each, and `pi:<working_copy>` for the transcript — the same key `AgentConversationLive` reads.

Watches and talks; starts and stops nothing. A harness is installed and run on its own machine, and a page reaching across to end it is a different kind of thing from a page showing what is happening.

The one fact it has to get right is liveness, because there are two of them. A Pi lane is tracked in Presence on the harness channel, so a dead process stops being present with nothing to expire. A Claude Code agent has no channel to be present on — it reports over HTTP hooks and `touch_session/2` bumps a timestamp — so what is known about it is recency, not liveness. Showing both under one badge would invent a fact for half the rows.

Depends on: Harnesses, Agents, Conversations.

## Type

live_context

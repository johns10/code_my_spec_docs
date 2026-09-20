# Nadia the Non-Technical Founder

> "I want to run a software project without reading code or knowing which checkout anything is in."

Proto-persona introduced 2026-09-09 alongside story 963, to make explicit the non-technical framing that story's own "As a..." line already carries. Distinct from Solo Shipper Sam, who is technical and whose persona doc names non-technical founders as an explicit anti-pattern for the product's core cockpit. This persona exists to hold that other case open on purpose, scoped to the main agent, rather than to resolve the tension. Mark as proto: validate against real non-technical users before treating any claim here as load-bearing.

## Role

Someone running a software product who does not read code, does not know what a "working copy," a "checkout," or a "spec" is, and has no intention of learning any of it. Directs the product by describing outcomes in plain language and depends on an agent to turn that into the stories and epics that actually drive development.

## Goals

**Understand what's going on without reading code.** Wants one agent that can explain, in sentences she'd use herself, what state the project is in and what changed since she last looked.

**Guide the work, not do it.** Wants to steer priorities and describe what she wants built, and watch the system turn that into stories and epics rather than having to write them herself.

**Trust that nothing breaks without her knowing.** She can't read a diff or run a test suite, so she needs the main agent to be the check that catches problems before they reach her.

## Pain Points

**Everything below the main agent is opaque.** Specs, working copies, requirement graphs — none of it means anything to her, and none of it should surface unless something is wrong.

**No fallback to "just read the code."** Where a technical user can drop into a file when an agent's explanation doesn't add up, Nadia has no independent account of the truth. The main agent's explanation has to actually be trustworthy, because it's the only one she has.

## Context

Directly named in story 963's own story text ("As a non-technical user, I want one agent that owns my project at the top level and tells me what is happening in language I understand..."), which predates this persona. Recorded as its own persona because the story's Notes field pointed at Solo Shipper Sam — a technical builder — while the story text itself already described someone else.

**Open tension, not yet resolved.** Solo Shipper Sam's persona doc (`solo-shipper-sam/summary.md`) lists non-technical solo founders as an explicit anti-pattern: "different product, different category." This persona and that note now disagree, and that's worth a deliberate decision rather than a silent default in either direction.

## Decision Drivers

**"Can I tell what happened today without opening a terminal?"** The main agent's explanations are the only interface to progress that exists for her.

**"Did something break, and would I know?"** She needs the main agent's privileged access — running tests, checking other agents' work — to stand in for the code review she can't do herself.

## Evidence

This persona is drawn from the product owner's own framing in conversation, not from external research — see `sources.md`.

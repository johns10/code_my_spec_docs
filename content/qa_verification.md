---
# Metadata for qa_verification.md

# Required fields
slug: qa-verification
type: documentation
title: "QA Verification: Testing What the System Actually Does"

# Publishing control
protected: false
publish_at: 2026-03-15T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "QA Verification - Story and Journey Testing"
meta_description: How CodeMySpec runs story QA, journey testing, and issue triage with AI doing the testing and procedural state machines controlling the flow.
og_title: "QA Verification: Testing What the System Actually Does"
og_description: Story QA, journey testing, and automated issue triage. AI tests the running application. Procedural code ensures every phase completes with validated artifacts.
og_image: null

metadata:
  template: article
  author: John Davenport
  category: Documentation
  featured: false

tags:
  - documentation
  - qa
  - testing
  - verification
  - browser-testing
  - issue-triage
  - state-machine
  - level-4
---

# QA Verification: Testing What the System Actually Does

Architecture commands define what the system should be. QA commands verify what the system actually does. They're not the same problem.

Unit tests and BDD specs verify pieces, does this function return the right thing, does this component behave correctly in isolation. QA verifies the running application. Does the user flow from login through to the feature actually work? Do the pieces fit together? What breaks when you try unexpected inputs?

In CodeMySpec, QA is a pipeline driven by procedural code. The AI does the testing. Deterministic state machines control the flow. The human defines acceptance criteria. Everything between criteria and verified results is automated.

## Story QA

`/codemyspec:qa story <story_number>` (or the requirement graph offering `qa_complete`) runs QA for one story. It's a state machine whose phase comes from which artifacts exist, not from tracked state. No state to manage. No state to get out of sync.

**Plan.** If no QA plan exists for the project, the agent reads the router, analyzes auth pipelines and routes, writes seed scripts, and produces a QA plan covering app overview, tools registry, and seed strategy. The plan must contain those three required sections, validated by procedural code against the document schema. If any section is missing, the agent gets told exactly which one.

**Brief.** For each story, the agent reads the acceptance criteria, the executable BDD specs, and the linked component source. It writes a testing brief: exactly what to test, which tools to use, how to authenticate, what seeds to run. The brief validates against its own document schema before the agent can proceed.

**Test.** The agent executes the brief against the running application. Browser automation for LiveView pages, curl for API endpoints, screenshots saved to a task-specific directory. After the scripted scenarios, it explores freely: unexpected inputs, edge cases, empty states.

**Submit.** The agent lands its verdict with `submit_qa_result`. `qa_complete` is satisfied by that database-backed attempt being a valid pass, never by a file on disk. Issues found become structured records with severity and reproduction steps, and the story can't move on while untriaged findings sit on it.

The human defines the story and its acceptance criteria. The state machine ensures every step completes with validated artifacts before moving forward. The AI does the actual testing. Three layers (human intent, procedural control, AI execution) working together.

## Journey QA

Story QA tests one feature at a time. Journey QA tests paths through the application that span multiple features. This is where integration bugs surface: the kind where individual stories pass but the full flow from registration through to the feature you actually care about breaks at the seams.

The journey task runs in three phases:

1. **Plan.** It reads the QA plan, architecture, and all stories, then designs 3 to 5 journeys that trace complete user paths: setup, authentication, core workflows, verification. Each has a name, user role, numbered steps, and expected outcome, plus prerequisites like server startup and seed scripts.
2. **Execute.** It walks each journey in a browser against the live application, records pass or fail, captures screenshots as evidence, and writes a structured result.
3. **Codify.** Passing journeys become `Phoenix.LiveViewTest` tests under `test/journeys/`, so the path keeps getting checked without an agent.

Plans and results validate against required sections (`journeys` and `prerequisites` for plans, `status` and `journey results` for results). If validation fails, the agent gets specific feedback. This is procedural validation, not AI self-assessment.

On Fuellytics, journey QA caught bugs that story-level testing missed entirely. A driver verification flow that worked perfectly in isolation broke when accessed through the actual navigation path because a LiveView handle_params didn't account for the redirect chain. Story QA said everything passed. Journey QA found the real experience.

## Issue Triage

QA sessions file issues automatically. `/codemyspec:qa triage` handles what happens next.

The agent lists incoming issues with `list_issues` at the project's severity threshold (`fix_issues_min_severity`, `medium` by default), reads each one, identifies duplicates, and decides dispositions: accept it as a real bug with `accept_issue`, dismiss it as a test artifact or expected behavior with `dismiss_issue`, or merge duplicates by accepting the best one and dismissing the rest.

Dispositions go through those tools, and the evaluate step counts what's still incoming. Any incoming issue on a story, at any severity, holds that story's QA until it's triaged. If any are still incoming, the agent gets the list and keeps going.

Accepted issues feed back into the development backlog (`/codemyspec:qa fix`). A different agent picks them up and fixes them. The agent that found the bug filed the ticket. The agent that fixes it references the ticket. The whole chain is traceable.

On Fuellytics, the QA pipeline filed over 100 issues across multiple QA campaigns. Triage dismissed about a third as test artifacts or expected behavior. The rest were real bugs that got fixed in subsequent development cycles. Without automated triage, that volume of issues would have been overwhelming. With it, each issue got a disposition and the real bugs surfaced clearly.

## The QA Loop

The pattern across all QA commands is the same: the human defines what correct looks like (stories, acceptance criteria). Procedural code controls the flow (state machines, document validation, artifact tracking). AI does the creative work (testing, exploring, writing results). Procedural code validates the output (schema checks, completeness checks, status reconciliation).

No single layer handles quality alone. The AI finds bugs a script never would, it explores unexpected inputs, tries edge cases, notices when something looks wrong even if it technically passes. The procedural code ensures the AI actually completes every phase, produces valid artifacts, and files issues in a structured way. The human ensures the acceptance criteria match what the product actually needs.

That's the difference between "AI testing" and "AI-assisted QA with procedural verification." The first is unreliable. The second catches more bugs than manual QA at a fraction of the time.

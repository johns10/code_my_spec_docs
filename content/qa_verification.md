# QA Verification: Testing What the System Actually Does

Architecture commands define what the system should be. QA commands verify what the system actually does. They're not the same problem.

Unit tests and BDD specs verify pieces -- does this function return the right thing, does this component behave correctly in isolation. QA verifies the running application. Does the user flow from login through to the feature actually work? Do the pieces fit together? What breaks when you try unexpected inputs?

In CodeMySpec, QA is a pipeline driven by procedural code. The AI does the testing. Deterministic state machines control the flow. The human defines acceptance criteria. Everything between criteria and verified results is automated.

## Story QA

`/qa-story` is a state machine that progresses through four phases. The phase isn't tracked explicitly -- procedural code derives it from which artifacts exist. If `brief.md` doesn't exist, you're in the brief phase. If `result.md` doesn't exist, you're in the test phase. No state to manage. No state to get out of sync.

**Plan.** If no QA plan exists for the project, the agent reads the router, analyzes auth pipelines and routes, writes seed scripts, and produces a QA plan covering app overview, tools registry, and seed strategy. The plan must contain three required sections -- `app overview`, `tools registry`, `seed strategy` -- validated by procedural code against the document schema. If any section is missing, the agent gets told exactly which one.

**Brief.** For each story, the agent reads the acceptance criteria, BDD spec files, and linked component source code. It writes a testing brief -- exactly what to test, which tools to use, how to authenticate, what seeds to run. The brief validates against its own document schema before the agent can proceed.

**Test.** The agent executes the brief against the running application. Browser automation for LiveView pages. Curl for API endpoints. Screenshots at every key state. After the scripted scenarios, it explores freely -- unexpected inputs, edge cases, empty states. The result document validates against a schema with required sections.

**Issues.** When results are valid, procedural code handles disposition. Passing results get promoted to `result_complete.md` and any issues found become structured records in the database with severity, reproduction steps, and root cause analysis. Failed results get archived with a timestamp (`result_failed_{ts}.md`) and their issues get filed for triage. The state machine advances or loops based on the result status -- not based on the AI's opinion of whether it's done.

The human defines the story and its acceptance criteria. The state machine ensures every step completes with validated artifacts before moving forward. The AI does the actual testing. Three layers -- human intent, procedural control, AI execution -- working together.

## Journey QA

Story QA tests one feature at a time. Journey QA tests paths through the application that span multiple features. This is where integration bugs surface -- the kind where individual stories pass but the full flow from registration through to the feature you actually care about breaks at the seams.

`/qa-journey-plan` designs end-to-end journeys. It reads the QA plan, architecture overview, and all stories, then produces 3-5 journeys that trace complete user paths -- setup, authentication, core workflows, verification. Each journey has a name, user role, numbered steps, and expected outcome. The plan includes prerequisites: server startup commands, seed scripts, credentials.

`/qa-journey-execute` runs those journeys against the live application using browser automation. It follows each journey step by step, records whether it passed or failed, captures screenshots as evidence, and writes a structured result document.

Both commands validate their output documents against required sections. Journey plans need `journeys` and `prerequisites`. Journey results need `status` and `journey results`. If validation fails, the agent gets specific feedback. This is procedural validation, not AI self-assessment.

On Fuellytics, journey QA caught bugs that story-level testing missed entirely. A driver verification flow that worked perfectly in isolation broke when accessed through the actual navigation path because a LiveView handle_params didn't account for the redirect chain. Story QA said everything passed. Journey QA found the real experience.

## Issue Triage

QA sessions file issues automatically. `/triage-issues` handles what happens next.

The agent reviews all incoming issues at a configurable severity threshold, reads each one, identifies duplicates, and decides dispositions: accept it as a real bug, dismiss it as a test artifact or expected behavior, or merge duplicates by accepting the best one and dismissing the rest.

The agent doesn't execute dispositions through AI reasoning. It edits the `## Status` field in projected issue files -- changing `incoming` to `accepted` or `dismissed`. When the evaluate step runs, procedural code reads those status fields, reconciles them back to the database, and checks whether any untriaged issues remain at the minimum severity. If any are still incoming, the agent gets the list and keeps going.

Accepted issues feed back into the development backlog. A different agent picks them up and fixes them. The agent that found the bug filed the ticket. The agent that fixes it references the ticket. The whole chain is traceable.

On Fuellytics, the QA pipeline filed over 100 issues across multiple QA campaigns. Triage dismissed about a third as test artifacts or expected behavior. The rest were real bugs that got fixed in subsequent development cycles. Without automated triage, that volume of issues would have been overwhelming. With it, each issue got a disposition and the real bugs surfaced clearly.

## The QA Loop

The pattern across all QA commands is the same: the human defines what correct looks like (stories, acceptance criteria). Procedural code controls the flow (state machines, document validation, artifact tracking). AI does the creative work (testing, exploring, writing results). Procedural code validates the output (schema checks, completeness checks, status reconciliation).

No single layer handles quality alone. The AI finds bugs a script never would -- it explores unexpected inputs, tries edge cases, notices when something looks wrong even if it technically passes. The procedural code ensures the AI actually completes every phase, produces valid artifacts, and files issues in a structured way. The human ensures the acceptance criteria match what the product actually needs.

That's the difference between "AI testing" and "AI-assisted QA with procedural verification." The first is unreliable. The second catches more bugs than manual QA at a fraction of the time.

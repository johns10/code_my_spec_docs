---
title: "Why are developer productivity workflows shifting so heavily toward verification instead of writing code"
subreddit: r/ChatGPTCoding
url: https://www.reddit.com/r/ChatGPTCoding/comments/1rkchor/why_are_developer_productivity_workflows_shifting/
date: 2025-06-01
status: draft
---

The thing I've internalized after building with agents for a while: **prompting is praying. Verification is a guarantee.** You should expect the agent to fail. Not occasionally -- routinely. The question isn't "how do I prompt it to write correct code," it's "how do I catch it when it doesn't."

Once you accept that, the whole workflow flips. You stop trying to craft the perfect prompt and start investing in the checks that run *after* generation. The agent becomes a fast, cheap, unreliable first draft machine -- and that's fine, because you've built the safety net.

Here's what that looks like concretely in my system:

- **Specs before code, always.** Every component starts as a structured spec in markdown. It writes function signatures, types, expected test assertions. And here's the thing: the agent writes the specs too. The agent writes the stories, the architecture, the specs -- the entire process is AI-assisted. You're partnering with it the whole way, steering and approving. But once the architecture and requirements are locked in, the code and test generation is mostly hands-off because intent is already defined. The specs aren't extra work -- they're the inspection layer. You read them to confirm intent, tune them if needed, and the system enforces everything downstream.

- **Spec-test alignment checking.** A checker parses the spec for expected test assertions, compares against the actual test file and makes sure it implents ALL and ONLY the specified tests.

- **BDD specs tied to acceptance criteria.** Each user story criterion gets a Given/When/Then spec that tests through the real UI (browser automation, not mocks). A parser validates the specs have actual scenarios with real steps. This catches the incredibly common failure mode where the AI writes a test file that compiles, looks plausible, and tests absolutely nothing. I also have strict boundary guarantees on bdd tests that keep the agent from just writing ad hoc code that makes the specs pass.

- **Requirements as a state machine, not vibes.** Components aren't "done" because the agent said so. They have requirement definitions (spec exists, tests pass, alignment checks pass, QA passes) that gate progression. Change a spec and the system tells you exactly which requirements broke and which task fixes each one. No ambiguity.

OP's "editor/reviewer" framing is right, but I'd push it further -- you can automate most of the review too, as long as you've defined the contracts and architecture clearly enough. 

The folks saying "just understand the problem deeply" aren't wrong, but that understanding lives in your head and rots the moment someone else (or an AI) touches the code. The human's real job is partnering with the AI on stories and architecture -- that's where domain understanding gets captured. Once that's solid, everything downstream (specs, code, tests) is generated and verified with minimal hand-holding. Externalizing intent into machine-checkable artifacts is what makes verification sustainable instead of a manual burden everyone eventually stops doing.

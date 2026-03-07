---
title: "How do you automate end to end testing without coding?"
subreddit: r/ChatGPTCoding
url: https://www.reddit.com/r/ChatGPTCoding/comments/1riqmzx/how_do_you_automate_end_to_end_testing_without/
date: 2025-06-01
status: draft
---

I built a system that addresses exactly this problem by testing that the code matches a specification, and testing the specification matches the user story.

Here's the approach I use:

**1. Specs (that the machine writes)**

The AI writes the stories, the architecture, and the specs -- you partner with it on all of that. You're having conversations, steering direction, approving or tweaking what it produces. But once the architecture and requirements are locked in, the actual code and test generation is mostly hands-off because the intent is already defined. The specs (function signatures, types, test assertions) make the whole system inspectable. You're not debugging generated code you don't understand -- you're reading a document that says "this module does X with these functions" and deciding if that's what you actually wanted.

**2. Requirements as a state machine, not a checklist**

Each component has requirements checked by dedicated checker modules. For example, one checker parses the spec to find expected test assertions, then compares them against the actual test file. It reports "missing_test" and "extra_test" problems -- so you know when tests have drifted from intent.

**3. BDD specs**

User stories have acceptance criteria. Each criterion gets a BDD spec file (Given/When/Then) that tests through the actual UI layer. I use browser tests for UI, HTTP tests for controllers.

**4. Automated QAs**

After implementation passes all automated checks, a separate QA phase brings up the running app, executes test scenarios through real browser automation, captures screenshots as evidence, and files structured issue reports with severity levels. The QA agent independently verifies the feature works end-to-end.

**5. Issue triage**

QA files issues into an `incoming/` directory. A triage step then reviews all issues at a given severity threshold, deduplicates them (same root cause filed from different stories), and sorts them into `accepted/` or `dismissed/`. Accepted issues feed back into the requirement graph -- they show up as unsatisfied requirements that block the next feature from starting until fixed. Bugs don't accumulate silently in a backlog nobody reads.

The AI doesn't write freeform tests. It writes tests against structured specifications with automated validation that the tests actually cover what the spec says they should. When something breaks, the system identifies *which requirement* is unsatisfied and *which task* can fix it -- so you're never just staring at a wall of red tests wondering what went wrong.

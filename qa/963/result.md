# Qa Result

> **Superseded — third attempt, 2026-09-01, build `45d840b4`.** The canonical
> record is the QA attempt in the database (`d109fca1`), not this file; the task
> prompt moved findings there. Kept for the method notes and the `c7f61e35`
> correction, which are still true. What changed:
>
> - **`a_subagents_work_reports_back` now passes.** The blocker below —
>   `8062ccba`, "the agent cannot start or assign anyone" — was resolved on 964
>   with a deliberate decision, and the *agent-side* half of it remained:
>   `start_agent`, `stop_agent` and `assign_subagent` are excluded from scripts
>   and an Alloy agent carried no direct tool that was one of them. Filed
>   `bea21433`, fixed in `45d840b4`, and proven live: the main agent started an
>   agent on another checkout, messaged it, reported its answer, then stopped it
>   on request.
> - **`handing_over` now passes** for the same reason — it attempts the
>   hand-over rather than describing one it cannot make.
> - **Both "Not Tested" criteria were tested.** A project with no main working
>   copy says so, plainly. A new project offers a conversation with nothing
>   started by hand, but its first message is refused — filed `1da05ada`, and
>   the reason is genuinely undetermined between the missing project deploy key
>   and my bare-directory checkout. That is why this attempt is `partial`.
> - **`moving_the_main_copy_moves_the_agent` re-confirmed by id**: agent
>   `88e5c45d` moved from qa_sandbox to phx-new-generator; nothing was
>   duplicated.


## Status

partial

Re-test after 982 gave the agent its tools. The previous attempt failed on
`c3bca42a` — the main agent had `bash` and file access and nothing else, so six
criteria could not be exercised at all. Five of those six now pass. One thing
remains, and it is not the old one. A second thing I reported turned out to be
my own mis-measurement and is dismissed below.

Getting here needed two fixes first, both mine, both from 982, and both found in
the first minutes of this run:

- `f1cb93e9` — `transport_name/1` named a registry `:transport` that nobody
  started, so no agent could start on any machine. Filed `dc5129c7`.
- `02c99f8b` — every MCP client in a harness computed the same ETS table name
  from a constant `client_info`, and Anubis creates it `:private`. Exactly one
  session could ever work per machine, and the browser took it at boot. Thirteen
  agent starts had failed in a row with none succeeding.

Neither was visible to 982's own QA, which drove `run_script` at the server and
never touched an agent's session.

## Scenarios

### finding_the_agent

PASS. Opening
`/app/projects/708492f9-.../agent-conversation` with no agent running started
one — no provider, checkout or role supplied. It read *"Getting ready. It will
start work as soon as its machine picks it up."*, then *"Working on your
project."* Both are sentences, which is 2909.

The working copy page agreed: *"Running just now — 1 agent present on the
harness channel."*

### one_main_agent_in_one_place

PASS. Starting a `qa` agent on a second copy left exactly one agent on the main
copy; the project's page still named one *"Your project's agent"*.

Starting a second agent in the main checkout was refused, naming the root:

    Something is already running in this project's main checkout, so nothing
    was started.
    Checkout: /Users/.../qa_sandbox
    That copy holds one agent on purpose — it is the one the project talks
    through, and a second conversation there is indistinguishable from it.

### designation

PASS. `qa_sandbox` became the main copy from its own page — "Make this the main
copy" became "Main checkout", and the database showed exactly one `main` row,
moved.

### moving_the_main_copy_moves_the_agent

PASS, and this is the one the brief flagged as most likely to look right and be
wrong. Naming a different copy as main moved agent `ffc16625` from `qa_sandbox`
to `phx-new-generator` — **same agent id**, new copy, and no third agent
appeared. Counted before and after.

### it_answers_about_the_project

PASS. The question that failed in `c3bca42a`, asked again:

> Using your CodeMySpec tools, how many user stories does this project have,
> and what is the title of story 963?

> **This project has 123 user stories. Story 963 is titled "A main agent runs
> my project and explains it to me."**

Both correct. It got there by calling `tool_docs` and then `run_script` — look
up the tool, then use it, which is 982's intended shape. Last time it invented
HTTP endpoints and posted to them.

### it_answers_about_the_code_that_is_there

PASS. Asked what its checkout is and to name two modules under `lib/`:

> The checkout is the Elixir application `:qa_sandbox` (QaSandbox). Under
> `lib/`, it currently has only one module: `ExampleContext`; there isn't a
> second module to name.

Correct, and it declined to invent the second rather than fill the shape of the
question.

### stories_appear_in_the_project

PASS. Asked to create a story, it created 986, reported *"Created 'QA probe 963
retest' (ID: 986)"*, and the project went from 123 stories to 124. The story
rendered on `/stories` — visible to a person, not trapped in the transcript.
Deleted on teardown; count back to 123.

### it_checks_rather_than_believes

PASS, cleanly. Told a falsehood and asked to verify it:

> I claim story 986 already has three acceptance criteria and is ready to
> build. Do not take my word for it — check, and tell me plainly whether I am
> right.

> **No. Story 986 has 0 acceptance criteria and is not ready for development.**

It checked and contradicted me.

### the_conversation_survives

PASS. One transcript held 61 messages across an agent stop at 10:22, a restore
at 10:25, and the working-copy move — same conversation, same agent id, nothing
lost.

### handing_over

**PARTIAL.** Asked neutrally — *"I want story 986 built. What happens next, and
who does it?"* — it described the chain correctly and refused to overclaim:

> Story 986 is not ready to build yet… the product/design work must finish the
> acceptance criteria and technical approach; then an implementation agent can
> take the story, make the project change, and QA verifies the result. The
> currently running agents are not clearly assigned to this story, so I can't
> truthfully say one has started building it.

Pushed — *"do that now, and if that is not your job, say whose it is and start
them on it"* — it wrote acceptance criterion 3031 on the story itself and
started nobody. So it refrains when it is not pushed and does the design when it
is, and the reason is the next scenario.

### a_subagents_work_reports_back

**FAIL.** Asked to start an agent on story 986, it answered honestly that it
cannot:

> I can't start an agent from this interface because the agent-start tool
> isn't available here. If you enable it, I'll assign story 986 and report its
> response.

It is right. `start_agent`, `assign_subagent`, `message_agent` and `stop_agent`
are among the fifteen tools the server keeps direct, and an agent on a machine
carries six — Alloy's Read/Write/Edit/Bash plus `run_script` and `tool_docs`. A
script cannot reach a direct tool. The handing-over half of this story does not
exist yet.

Filed `8062ccba`.

### reaching_the_conversation_at_all

PASS, after a false alarm of mine that is worth keeping in the record.

I first reported that every link offering an agent's transcript pointed at the
list page, and filed `c7f61e35`. Re-measured against a running agent, both are
correct:

    /app/projects/708492f9-.../agent-conversation/81632abf-...

on the project's "Open" button (`index.ex:231`) and on the working copy page's
"Open <name>" (`show.ex:292`). The bare index href I had seen is the layout's
"Agent chat" nav item, which belongs there.

I measured during the window when no agent could start — the two bugs below.
With no usable agent the page falls back to the index path, and that fallback is
deliberate and documented at `index.ex:42`: *"an agent with no conversation is a
state the page must not render a link for — it would go to a transcript that
does not exist."*

So the page behaved correctly and I read the correct behaviour as a broken link,
because the state it was written for was the state I had accidentally created.
`c7f61e35` is dismissed.

## Not Tested

Two criteria from the brief, named rather than quietly dropped:

- **A new project can be talked to immediately** — needs a project created from
  scratch; this run used the existing one throughout.
- **A project with no main working copy says so instead of failing quietly** —
  reachable only by unsetting `main` on the project under test, and this run had
  just restored that state. Not worth leaving the project wrong for.

Neither would change the verdict: 2919 fails regardless, and 2921 is
partial.

## Issues

- `8062ccba` — new, high. The main agent cannot start or assign anyone.
- `c7f61e35` — filed, then **dismissed as wrong**. See above.
- `dc5129c7` — new, critical, filed against 982 and **fixed** in `f1cb93e9`. No
  agent could start on any machine.
- `c3bca42a` — the previous run's blocker, **resolved**: the agent has its
  tools and used them.

## Method Note

One dead end worth recording so the next run does not repeat it. `vibium fill`
sets an input's value without dispatching the events LiveView listens for, so
`phx-change` never fires and the form submits an empty message, which is
discarded silently. Four messages appeared to vanish before this was the
explanation rather than a product defect. `vibium type` sends real keys and
works. Nothing was filed for it.

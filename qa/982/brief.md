# QA Brief — Story 982: The agent I run gets its tools without paying for a catalogue

## Tool

`curl` against `http://localhost:4004/mcp`, plus `psql` to read what an agent
was recorded as carrying. No browser: this story has no page. Everything it
claims is about what a *running agent* holds and what a script it runs can
reach, and both are asked of the machine.

## Auth

No login. The harness id from `.cms_harness.json` in the working copy under
test:

```
python3 -c "import json;print(json.load(open('.cms_harness.json'))['harness_id'])"
```

Then, against `http://localhost:4004/mcp`, headers
`X-Harness-Id: <id>`, `Content-Type: application/json`,
`Accept: application/json, text/event-stream`. Handshake is `initialize`, then
the `notifications/initialized` notification, then `tools/call`.

For the database reads, the dev database:

```
PGPASSWORD=postgres psql -U postgres -h localhost -d code_my_spec_dev
```

## Seeds

```
mix run priv/repo/qa_seeds.exs
```

Nothing story-specific. **A provider must be connected** or no agent starts at
all — `qa@codemyspec.local` holds a ChatGPT integration, which is enough.

Every agent this run starts is real and spends a real subscription. **Stop each
one**, and check `list_agents` at the end rather than trusting that you did.

## What To Test

**What an agent carries** — `start_agent` over MCP, then the database

- Start one and read `agents.tools` for its row. It is a list of names, not a
  role, and not null.
- The list is the role's plus whatever its machine reported. Compare against
  `working_copies.machine_tools` for the copy it started on.
- Start a `main` agent. Its `tools` is **null**, which is this column's way of
  saying "everything" — check that against `Agents.ToolSets.for_role/1` rather
  than assuming a bug.

**What a script can reach** — `run_script`

- Call a tool the agent does not carry as a tool, e.g. `list_stories`. It should
  answer as a direct call would.
- Ten calls in one script. One invocation, ten answers.
- A script that asks for a story belonging to another project. Refused, and the
  refusal must not name the story or the project — a refusal that says what it
  refused has already leaked most of the answer.
- Something enormous back. Cut, and the reply says it was cut. 24,000
  characters is the limit; the note is at the end.

**Scoping** — the part with teeth

- As a **qa** agent, call `delete_story` from inside a script. Refused, and the
  refusal names both the tool and the type: "delete_story is not a tool a qa
  agent carries."
- Then check the story is still there. A refusal that arrives after the delete
  is not a refusal.
- As a **main** agent, the same call goes through.

**The browser**

- `working_copies.machine_tools` for this copy. On a machine with vibium it is
  vibium's tool names; on one without, `[]`; `null` means a harness that never
  reported, which is a third state and not the same as an empty list.
- Whatever it says, the agent's *own* tool list must contain no browser tools.
  That is the story's central claim and the one most likely to regress.

## Result Path

`.code_my_spec/qa/982/result.md`

## Setup Notes

Requires a server and harness restarted since `fe27ed10`. `just refresh` does
both.

**Look hardest at the scoping, and look at it sceptically.** The lists in
`Agents.ToolSets` are one person's judgement about what each type needs, written
in a single sitting and reviewed by nobody. A tool a type genuinely needs and
was not given fails silently in the worst way — the agent is told the tool is
not for it, which reads like a decision somebody made, and it stops asking. So
check what a QA agent actually needs to do its job against what it is granted,
rather than only checking that the refusal works.

Known and already filed, so do not re-file: `ebc5586d` (vibium should be a
package prerequisite). Worth confirming rather than assuming: this worktree's
analyzer reported criterion 2848 failing while it passes locally, which looks
like its database being behind — if any spex-derived claim here looks wrong,
check the same spex by hand before believing it.

# QA — Story 995: The first story is shaped in conversation, before any code

**Surface:** `CodeMySpecWeb.ChatLive` at `/app/projects/:project_id/chat`
**Built at:** `a847300d` (main)
**Method:** browser (Vibium) against a dev server on :4012, dev database, logged
in as `qa-fresh@codemyspec.local`
**Provider:** scripted via the `:chat_llm` seam, added to `config/dev.exs` for
the run and reverted after each. The runner, tool dispatch, persistence and the
LiveView all ran for real; only the model was faked.

**Result: PARTIAL — one rule is not implemented.** Everything else passes.

---

## Verdict per rule

| Rule | Result |
|---|---|
| The conversation produces exactly one story | **FAIL** — see Defect 1 |
| The story belongs to the project the intake form created at signup | pass |
| Sam watches the tool calls as they happen | pass |
| Sam can edit the story he was just shown without leaving the conversation | pass |
| Three Amigos runs on the story only once the story exists | pass (control present) |
| The tool-calling loop is bounded | pass |
| The conversation fixes the project; never resolved from a working directory | pass |
| Answers already given survive a conversation that fails part-way | pass |
| A tool call keeps its structure from the model through to the screen | pass |

---

## Defect 1 — "exactly one story" is not enforced, and the spex agrees anyway

**Severity: high.** It is the story's first rule, and the criterion that covers
it passes.

Scripted the model to call `create_story` twice.

- **Same title both times** → 1 story. Second call returned
  `## Validation Error - **title**: has already been taken`.
- **Different titles** → **2 stories created.** The page still showed **one**
  story card.

So the rule holds only by accident of a unique-title constraint. Nothing in the
runner, the registry or the view limits the conversation to one story. A model
that names its second story differently — the likely case, since it would be
describing something else — creates a second one silently.

The UI makes it worse rather than surfacing it: `ChatLive.assign_story/2` takes
`List.first` of the project's stories, so the second story exists, is on the
stories page, and is invisible in the conversation that created it.

Criterion 8269 ("A second story is refused, not silently added") passes because
its fixture reuses the same title, so the database refuses the second call. The
spex is testing the unique index, not the rule. It would pass against an
implementation that has no one-story logic at all — which is exactly the
implementation we have.

**Suggested fix:** enforce it where the decision belongs — the runner should
refuse a second `create_story` within a conversation, and the refusal should be
the tool result the model sees. Then change 8269's fixture to use two different
titles, so it tests the rule instead of the constraint.

## Defect 2 — the story card shows one story when more exist

**Severity: medium.** Fallout from Defect 1, but worth its own line because it
would also bite if a story were created any other way.

`assign_story/2` takes the first story on the project. With more than one, the
conversation displays one and gives no indication there are others.

---

## What passes, and how it was checked

**The loop, end to end.** Sent "A booking tool for hair salons"; got a
`create_story` tool call, its result, an assistant reply, and a story card —
all rendered.

**Tool calls keep their structure.** The call renders with
`data-tool=create_story`, `data-tool-call-id=call_0`, `data-state=done`, and the
result carries the same call id. Not flattened into prose. This is the property
the message-model rework exists for.

**The editor is the real story form.** Clicking the card opens it; changing the
title there and reloading the stories page showed the change. One record, one
editor.

**The card shows its title once.** Collapsed: one heading, no form. Open: no
heading, form present. (Was duplicated; fixed and re-verified.)

**The loop is bounded, and says so.** Scripted 14 calls against a cap of 12 →
12 tool calls rendered, then `Stopped: stopped after 12 rounds` with
`data-test=chat-halted`. Not left spinning.

**A failure reads as a failure.** With no provider configured, the turn renders
`data-test=chat-failed` and `chat-failed`/`chat-halted` do not both appear.
(Previously the same element; fixed and re-verified.)

**The conversation is durable.** Reloaded the page: the message and the system
turn were both still there.

**Scope is pinned to the conversation.** Stories created in one project's chat
landed on that project only; a second project's chat wrote to its own. No
working directory is consulted.

**The migration held on live data.** 23 real dev messages converted to content
parts; the support inbox renders their previews correctly. One blank "Last
message" was chased and is a conversation with zero messages, not data loss.
`pg_dump` taken to `~/.codemyspec/db_backups/` beforehand.

---

## Notes for whoever records this

- 13/13 spex green, but see Defect 1: green does not mean the rule is
  implemented.
- QA data created in dev was deleted afterwards (conversations, messages, and
  the three QA stories). `config/dev.exs` was restored; `git status` is clean.
- I could not call `submit_qa_result` — this session drives MCP by hand over
  HTTP and has no hook-injected session, so there is no task to attach a result
  to.

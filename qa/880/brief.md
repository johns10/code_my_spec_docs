# QA Brief — Story 880: The first story is shaped in conversation, before any code

## Tool

web

## Auth

Passwordless. The login form is also the reauthenticate form, so an existing
session prefills its own address and a fill is silently a no-op — clear cookies
first.

```
vibium cookies clear
vibium go "http://localhost:4000/users/log-in"
vibium fill "input[name='user[email]']" "qa990-final-1785773065@example.com"
vibium click "form button"
```

`/dev/mailbox` is one shared inbox for every agent on this server. Taking the
newest link logs you in as somebody else's QA user, whose empty account then
reads as a broken page. Confirm the recipient before following the link:

```
ID=$(curl -s http://localhost:4000/dev/mailbox | grep -oE '/dev/mailbox/[a-f0-9]{32}' | head -1)
curl -s "http://localhost:4000$ID" | grep -oE 'qa[^< ]*@[^< ]*' | sort -u
```

## Seeds

No seed script. This story needs an account with an active project, which
`qa990-final-1785773065@example.com` already has — account "Acme Salons",
project `47d78148-6b92-4d9c-bfa9-6dbed5057ddd` ("Week View").

A live provider is required: `ANTHROPIC_API_KEY` in `envs/dev.env` (not
`envs/.env`). Without it `Provider.ready?/0` is false and every send fails with
"no model configured for this conversation" — which looks like a broken feature
rather than a missing key.

The conversation must start with no story on the project, since two criteria
turn on the one-story rule. Check and clear:

```
psql -d code_my_spec_dev -tA -c \
  "select id, title from stories where project_id='47d78148-6b92-4d9c-bfa9-6dbed5057ddd';"
```

## What To Test

Visit `/app/projects/47d78148-6b92-4d9c-bfa9-6dbed5057ddd/chat`. The form is a
single `input[name=message]` with a submit button. Replies take 15–30s, so wait
rather than reading an empty page as a failure.

- **Four answers become one story (2284).** Open with a domain sentence
  ("I want to track which stylists are booked on which days at my salon"), then
  answer each question in turn. Expect one question at a time, in the visitor's
  language, nothing about frameworks or hosting, and `create_story` after about
  four answers.
- **A second story is refused (2285).** Ask for a second, unrelated story. Expect
  a refusal that offers to replace, and confirm the table still holds one row —
  the UI saying no is not the same as no row being written.
- **The story lands on the project signup made (2286)** and **tools act on the
  conversation's project (2292).** Check the created story's `project_id`
  matches the project in the URL.
- **Tool calls appear as the model makes them (2287)** and **arrive as tool calls,
  not prose (2295).** Each call renders as a named call with its result
  (`list_stories` → "No stories found."), not as a sentence describing one.
- **Sam corrects the story in place (2288).** Ask for a title change. Expect
  `update_story`, the same story id, and no second row.
- **The review starts from a story already on the board (2289).** Click
  `[data-test=start-three-amigos]` and confirm it *navigates* — this button was
  dead while its spex passed, because the assertion matched the button's own
  `data-test` attribute. Assert the URL and the destination page, never the
  presence of the thing you clicked.
- **A normal conversation finishes well inside the cap (2290).** Count rounds;
  the cap is 12.
- **A failure mid-conversation keeps what Sam already said (2293).** If a turn
  fails, reload and confirm every earlier message survives.
- **Sam steps away and picks up where he left off (2294).** Reload the page and
  confirm the full transcript, including tool calls, is still rendered.
- **The editor is the story UI, not a second one (2296).** The page should carry
  one form (the message input) and link out to the stories UI rather than
  embedding a second editor.
- **A model that will not stop is stopped (2291).** Ask the model to call a tool
  twenty times. Expect it to decline — this criterion is not reachable against a
  cooperative provider and belongs to the scripted path.

## Result Path

Recorded in the database via `submit_qa_result`. Screenshots in
`~/Pictures/Vibium/` — `chat_live_reply.png`, `chat_880_live.png`.

## Setup Notes

Two prior failures on this story were both a fixture standing in for the world,
and are worth knowing before trusting any green:

`:chat_llm` replaces the whole provider path, so story 995's spex suite passed
while `run_live/1` was a stub that failed every send. And criterion 8273 was
green the entire time the Three Amigos button was dead, because it asserted
`context.html =~ "three-amigos"` — a string contained in the button's own
`data-test` attribute.

The multi-turn defect found in this pass (996a6c3b) has the same shape: it needs
two user turns with a tool call in the first, so no single-turn test and no
scripted run can reach it.

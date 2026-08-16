# CodeMySpecWeb.ChatComponents

The message components every conversation surface renders through — the support inbox, the story interview, and the record of what an agent did.

Each of those grew its own `turn/1`, `chat_side/1` and `chat_bubble/1`, and they drifted the way copies do: two rendered tool calls differently, and a tool result was labelled `tool-result` in one view and `tool-call` in another. One set removes the drift and gives the interaction work — a question answered inside the transcript — a single place to land.

**A surface declares which side is "mine"** (`own_role`). In the support inbox the reader is the operator, so the operator sits right; in an agent conversation the reader is watching, and the assistant sits right. Same markup, different answer, so it is an argument rather than a hardcoded clause.

There used to be a second argument, `tool_role`, because `role: :tool` meant a *call* from the recorder and a *result* from `Chat.Runner`, and a component could not tell them apart. Both writers now record a call as an assistant turn carrying a `tool_calls` array and a result as `role: :tool` with the `tool_call_id` it answers, so the view stops guessing and the argument is gone. That ambiguity was fixed in the data rather than carried here, which is what the old note in this spec asked for.

Every `data-test` the spex assert on is part of the contract: `message` (with `data-long`), `tool-call` (with `data-tool`, `data-failed`, `data-answered`), `tool-call-group` (with `data-count`), `tool-result`, `long-message`, `question-request`, `question-closed`, `chat-halted`, `chat-failed`.

## Functions

### turn/1

Dispatches one message to the component that should render it.

```elixir
@spec turn(map()) :: Phoenix.LiveView.Rendered.t()
```

**Process**: Order matters. A halted or failed turn is a notice before it is a message. A turn carrying a `tool_calls` array renders those calls rather than an empty bubble, passing each one the result that answers it. A `role: :tool` message reaching this point is a result whose call is off-page — the transcript is paginated — and renders on its own rather than being dropped. A turn with neither text nor calls renders hidden rather than as a blank bubble, but still renders an element so it keeps its id.

**Test Assertions**:
- A tool result renders as a result, never as the operator's own words
- A call and its result render as one block, not two
- A result whose call is not on the page still renders
- A turn with no text and no calls renders nothing visible

### chat_message/1

A person's or an agent's words, with an `:extra` slot for anything that belongs inside the bubble.

```elixir
@spec chat_message(map()) :: Phoenix.LiveView.Rendered.t()
```

**Process**: Renders markdown, because the model writes markdown and always has — as plain text it showed backticks and hyphens as literal characters. Escapes raw HTML, since this is model output rather than authored content. Past 1,500 bytes the message becomes a preview cut on a line boundary with the whole text behind a disclosure: a sub-agent's work arrives narrated as prose rather than as tool blocks, and measured 67 kB in one bubble. Nothing is dropped — the model received it, so it is part of the record. The preview is plain text, because a cut at 1,500 bytes lands mid-fence often enough that parsing it swallows the rest.

**Test Assertions**:
- Prose from each side stays attributed to whoever said it
- A message past the preview limit folds and says how much it is hiding
- An ordinary message does not fold
- Markdown renders as markup, and a `<script>` in a reply renders as text

### tool_call/1

A call the agent made, and what it came back with.

```elixir
@spec tool_call(map()) :: Phoenix.LiveView.Rendered.t()
```

**Process**: One collapsible per call — the shape both `vercel/ai-chatbot` and `assistant-ui` converge on. The result belongs *inside* the call; as a sibling card it doubled the block count and lost which call it answered. The header carries the tool name and a one-line summary drawn from the argument that holds the point: `description` for a Bash call, a basename for a file tool, a pattern for a search. `Bash` alone says nothing. Arguments and result sit behind the disclosure, so a turn that called five tools is five lines. A payload past 2,000 bytes is cut and says so. A qualified MCP name is one unbreakable 45-character token, wider than a phone, so the name may shrink and break — without both it overflowed its card and the reader lost which tool ran. A failure is read from `tool_failed` rather than parsed out of the text.

**Test Assertions**:
- The name is on screen and the arguments are behind a closed disclosure
- The summary names what the call did, not just which tool
- A failed result is distinguishable without reading it
- A file-sized payload is cut and says so
- A call with no arguments offers nothing to expand
- A long qualified name wraps rather than being clipped

### notice/1

Something about the conversation rather than in it: halted, failed, a gap in the record.

```elixir
@spec notice(map()) :: Phoenix.LiveView.Rendered.t()
```

**Process**: Warning-toned, because each one means the transcript is not the whole story.

**Test Assertions**:
- A halted run renders as a notice, not as the agent's words
- The run survives the recorder failing, and says the record has a gap

### question/1

A question the agent asked, answerable where it is shown.

```elixir
@spec question(map()) :: Phoenix.LiveView.Rendered.t()
```

**Process**: Lifted out of `QuestionLive.Show`; that page still renders it, and a transcript can too. Three states, not two. Answered questions keep rendering, showing what was asked beside what was said — in a transcript the answer is part of the record, not a modal that closes. A question the run stopped waiting on is neither answered nor pending, and matching only those two rendered a card with a title and an empty body, which reads as a broken page rather than as a question that timed out. Whatever the status, what was asked is still shown; that is the point of keeping the record.

**Test Assertions**:
- A pending question offers a form; an answered one shows the answer
- An expired question says it expired and offers no way to submit
- The question text is shown whatever the status

### group_turns/1

Folds a message list into the items a transcript renders, and pairs each result to the call it answers.

```elixir
@spec group_turns([Message.t()]) :: {[map()], %{String.t() => Message.t()}}
```

**Process**: Returns items plus results keyed by `tool_call_id`, so a call can render its own. A result whose call is on the page is dropped from the top level because it renders inside that call; one whose call is off-page stays. A run of consecutive calls folds into a group, counted by *calls* rather than by messages — a turn can make three at once, and counting messages left exactly that case unfolded. Two is the threshold: a lone call dressed as a group is a disclosure hiding a single thing.

**Test Assertions**:
- Five calls in a row read as one line saying five
- Three calls in one turn fold, because the count is calls not messages
- A lone call is not dressed up as a group
- A result renders inside its call, and only once

### turn_item/1

Renders one item from `group_turns/1` — a lone turn, or a folded run.

```elixir
@spec turn_item(map()) :: Phoenix.LiveView.Rendered.t()
```

**Process**: Dispatches on the item's `grouped` flag rather than on how many messages it holds. A folded run is often a single message, so matching on a one-element list sent exactly the case that needed folding to the unfolded clause. Expanding a group lists its calls as one-line rows, each opening to its own detail and no other's.

**Test Assertions**:
- Opening the group lists the calls; opening a call shows only that one
- A group is closed on arrival

## Dependencies

- CodeMySpec.Conversations
- CodeMySpecWeb.CoreComponents
- CodeMySpecWeb.Markdown

## Type

module

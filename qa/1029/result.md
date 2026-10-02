# Story 967 — The agent steers what I am looking at

**Pass.** Six criteria, all confirmed in a browser at real widths against build
`0a68a6bf`. One defect was found and fixed during the round; it is described
below rather than filed, because it was fixed before the attempt was submitted.

## The defect this round found

Taking an offer was wired only to the PubSub broadcast. That is the case where
the agent points the panel at something while the person is already looking at
the screen — and it worked. But a screen that *loaded* with an offer already
pending never resolved it, so a desk showed the attention mark that only a phone
is supposed to show, and the change sat there waiting for a click that criterion
2957 says should not be needed.

It hid because both halves look right in isolation: the broadcast path applies
on wide, and the mark renders on narrow. Only loading at 1440 with a pending
offer shows the wrong one. Fixed by resolving in the viewport handler as well,
so the answer arrives with the width rather than only with the next broadcast.

## Criteria

**2955 — Coming back gives Sam the screen he left.** Opened the dynamic tab and
reloaded, rather than only navigating away and back: a value held in the socket
survives a navigation, so only a reload tests the claim that it is written down.
The tab came back open, and `screen_states` held `{dynamic}` / `stories`.

**2956 — The agent puts a story in front of Sam.** Driven by seeding the offer
row. `show_in_panel` was written during this round and an already-connected MCP
client holds the old tool list until it reconnects, so the tool could not be
called from the session testing it. The write reached the panel and the screen
rendered story 1. The tool has four tests of its own covering the write, the
list case, a story not on the project, and a view the panel cannot show.

**2957 — On a desk the change just appears.** At 1440 with an offer pending, the
page resolved it on load with no interaction: `dynamic_view` became `story`,
`dynamic_story_id` 1, `offered_view` cleared, no mark rendered. This is the
criterion the defect above broke.

**2958 — On a phone the agent asks first.** At 390 with the preview open, the
mark rendered and the preview stayed open — nothing was evicted. Tapping the tab
took the offer, cleared the mark, and closed the preview per the one-panel rule.
Both halves of the asymmetry, same seeded offer.

**2959 — One project's screen does not follow.** With the fixture project's tab
left on a story, opened a different project's agent conversation: its panels
rendered with none open, and `screen_states` still held exactly one row, for the
first project. Nothing carried, nothing was overwritten.

**2960 — A deleted story does not take the screen with it.** Reproduced the state
the foreign key actually produces — `on_delete: :nilify_all` leaves
`dynamic_view: "story"` with a null id — instead of destroying a fixture. The
page rendered with conversation and composer both present, and the panel read
"That story is not on this project, or has been deleted." A raise here would
have taken the transcript with it, which is why this one matters most.

## Not defects

The preview panel says nothing is running. Story 968 owns giving it an address;
the empty state is correct until then.

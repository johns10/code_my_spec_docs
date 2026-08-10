# CodeMySpecWeb.PreviewComponents

The preview pane: a function component handed a URL and a state, rendering the
right thing for each.

Its whole input is `src` plus `:absent | :starting | :running | :down`, and
that is deliberate — it makes the pane provable by handing it values, with no
container, no proxy and no DNS behind it. It decides nothing about where the
app is or whether it is up; story 886 computes those and passes them in.

An iframe rather than rendering the target in-page. The alternative fails on
things that cannot be fixed without forking: the target's `push_patch` calls
`history.pushState` on `window` and would rewrite the host's address bar,
`window.liveSocket` is a single global, and the generated app's Tailwind
preflight would flatten host styles in a shared cascade. The isolation this
component promises — address bar untouched, styling contained — is what an
iframe gives for free.

`:down` and `:starting` are different screens. Conflating them is how a broken
app reads as a slow one.

`:running` with no `src` is refused rather than framed: an iframe pointed at an
empty address renders a blank rectangle indistinguishable from an app that
rendered nothing, which is the one outcome the pane exists to prevent.

Viewport width arrives as an assign. The host owns that control, so the pane
stays a pure function of its input and can be tested with `render_component/2`
rather than a LiveView harness.

## Type

liveview_component

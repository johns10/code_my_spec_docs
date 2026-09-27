# CodeMySpec.WorkingCopies.AppTransport

Asks a working copy's channel to start, restart or stop its own app — story 1108's server-side half of the seam that reaches `CmsHarness.AppInstance` on the machine holding the checkout.

Same mechanism as `CodeMySpec.Agents.Transport.Harness`: `CodeMySpec.Analysis` holds a live process per connected copy — the channel itself — and the request goes to that pid, because it is the same process that already proved the machine is reachable. `HarnessProjectChannel` mints a ref, pushes `ensure_app_running`/`restart_app`/`stop_app`, and the harness's `CmsHarness.Project.ChannelClient` answers with a correlated `_result` push; `handle_in` on the server replies to whoever called `AppTransport` and is still waiting.

Deliberately a thin lookup-and-call, not a re-derivation: `Agents.Transport.Harness` shipped once looking up a registry module that did not exist, every call raised, and a `rescue` silently turned every failure into "not connected" — undetected because every spex swaps the transport for an in-process double, so the real module was never exercised by anything. This module reuses `Agents.Transport.Harness`'s exact lookup path (`Analysis.executor_holder/1`) rather than adding a second definition of "which process holds this copy" for the same reason that defect names.

## Type

module

## Dependencies

- CodeMySpec.Analysis

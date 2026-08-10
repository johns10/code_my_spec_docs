# CodeMySpecWeb.PreviewLive.Show

Hosts the preview pane at `/build/preview` so it can be seen and driven.

A convenience host rather than the pane's identity. The same component is meant
to sit on a project page Sam returns to later, so nothing here may become
something the pane depends on.

Owns the viewport control Sam operates and passes the chosen width to the pane
as an assign — which is what keeps the pane a pure function of `src` and state.

Resolves the workspace for the active project and hands the pane the address
and state that `CodeMySpec.Workspaces` reports. Asked, never inferred from
whether a request succeeded: a booting container and a crashed one both fail to
answer, and telling them apart is the distinction the pane renders.

## Type

liveview

## Dependencies

- CodeMySpecWeb.PreviewComponents
- CodeMySpec.Workspaces

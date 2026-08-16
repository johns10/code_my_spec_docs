# CodeMySpecWeb.AppLive.Overview

The primary app view at `/app` — install funnel and live CLI status, and the wizard's replacement for a returning user who already has projects.

**`/app` does not redirect to a project, and that is deliberate.** An earlier version bounced a returning user to their last project; it satisfied the idea that a bookmark should pick a landing page and broke twelve of story 603's criteria, whose criterion 5501 is exactly "a user with an account and a project sees the primary app view on /app". The stored active project still earns its keep — it answers for `/api/issues`, which has no URL to read a project from — and choosing a project is the sidebar picker's job.

What *is* project-aware is the way in. The marketing chrome's "Open workspace" links to the active project when there is one and to `/app` when there is not, so resuming work does not cost a click through a page you did not want. That is a link target, not a redirect: `/app` reached directly still renders this view, which is what keeps 603 true. The rule lives on story 605 and the helper is `Layouts.workspace_path/1`.

## Route

`/app` — `live "/", AppLive.Overview` inside the `/app` scope, behind `:require_authenticated_user`.

## Params

None. The view reads everything from the scope.

## User Interactions

- Arriving with no active account: redirected to account setup rather than rendering a dashboard for nothing.
- Arriving with an active account and zero projects: the project-name form, which is the first-run path.
- Arriving with at least one project: the Overview, never the form. "Has projects" is scoped to the active account and evaluated at page load, so switching to an empty account re-shows the form on the next render and a project created in another tab surfaces on refresh rather than flipping the form mid-session.
- Choosing which project to work on happens in the sidebar picker, not here.

## Design

Setup state is computed on mount from the scope rather than stored, so the page cannot disagree with the account it is rendering. `ensure_active_account/1` returns either a scope to render or a path to redirect to, which keeps "we cannot render this yet" out of the render path.

## Dependencies

- CodeMySpec.Accounts
- CodeMySpec.Projects
- CodeMySpec.UserPreferences
- CodeMySpec.Users.Scope

## Type

liveview

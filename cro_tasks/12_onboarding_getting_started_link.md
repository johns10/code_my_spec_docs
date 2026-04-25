# CRO Task 12: Fix Onboarding "Full Walkthrough" Link

**Priority:** High
**Area:** Onboarding — post-signup activation
**Status:** Todo

## Problem

The onboarding page at `/app/onboarding` has a "Full walkthrough" link pointing to `/documentation/getting-started`. That page doesn't exist on dev. It may exist on prod (dev has deployment issues) — check prod first.

If it doesn't exist on prod either, this is a new user's first click after confirming their account leading to a broken page.

## What to Change

### If the page exists on prod

This is a dev deployment issue, not a CRO issue. Fix the deployment and move on.

### If the page doesn't exist on prod either

**Option A (fast):** Point the link to the methodology page:

```elixir
href={~p"/methodology"}
```

**Option B (better):** Create the getting-started doc at `/documentation/getting-started` with:

1. Prerequisites (Claude Code installed, Elixir/Phoenix project)
2. Install the plugin (the two commands from the onboarding page)
3. Open `http://localhost:4003/auth` and sign in
4. Link your first project
5. What to do next

## Why This Matters

The onboarding page is the activation moment. If the "Full walkthrough" link is broken on prod, it's actively hurting activation. If it's only broken on dev, it's a deployment issue to fix but not urgent for users.

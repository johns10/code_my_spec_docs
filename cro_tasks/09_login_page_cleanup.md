# CRO Task 09: Login Page Cleanup

**Priority:** Medium
**Area:** Login flow
**Status:** Todo

## Problem

The login page has two separate login sections stacked vertically, which is visually busy and confusing:

1. **Top section:** Email field + "Log in with email" button + GitHub + Google
2. **Divider:** "or"
3. **Bottom section:** Email + Password fields + "Log in and stay logged in" + "Log in only this time"

This presents five buttons/options on one screen. A returning user has to figure out which section applies to them. The two-button password section ("Log in and stay logged in" vs "Log in only this time") adds another decision.

## What to Change

### Simplify the layout

**Recommended approach:** Lead with OAuth + magic link (the primary paths), collapse password login.

```
[Continue with GitHub]
[Continue with Google]

── or log in with email ──

[Email field]
[Send login link]           (magic link — primary email path)

Log in with password instead  (text link, expands password fields on click)
```

This way:
- OAuth is prominent (one click, no typing)
- Magic link is the default email path (matches registration flow)
- Password login exists but doesn't compete for attention
- Only two decisions visible at first, not five

### "Remember me" simplification

Instead of two buttons ("stay logged in" vs "only this time"), use a single login button with a "Remember me" checkbox. This is the standard pattern — two login buttons with different persistence behavior is unusual and creates hesitation.

### Dev-only banner

The blue "You are running the local mail adapter" banner should be dev-only (it probably already is, but confirm it doesn't show in production).

## Why This Matters

Login page friction doesn't lose new users, but it frustrates returning users. And returning users are closer to paying. A clean, obvious login keeps them in flow.

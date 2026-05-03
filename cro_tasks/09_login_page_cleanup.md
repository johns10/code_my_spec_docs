# Login Page Cleanup

**Priority:** Medium
**Area:** Login flow — returning user experience
**Status:** Todo

## Why This Exists

The login page presents five separate sign-in options stacked on top of each other (email magic link, GitHub OAuth, Google OAuth, email+password "stay logged in", email+password "only this time"). Returning users — who are closer to paying than new users — have to parse five decisions to log in. This is friction at the moment closest to revenue.

The fix consolidates into a clear hierarchy: OAuth first (one click), magic link as the default email path, password as a deprioritized fallback. And replaces the two-button "remember me" pattern with a single button + checkbox.

## Locked Decisions

1. OAuth (GitHub, Google) sits at the top of the form — most users sign up via OAuth, most should log in the same way.
2. Magic link is the default email path. Password is collapsed behind a "Log in with password instead" link.
3. The two persistence-behavior buttons ("Log in and stay logged in" vs "Log in only this time") collapse into a single login button with a "Remember me" checkbox.
4. The dev-only "local mail adapter" banner stays in dev only. Confirm it does not render in prod (already handled, just verify).

## User Stories

### Story 1: Returning OAuth user logs in with one click

**As a** returning user who originally signed up via GitHub or Google,
**I want** OAuth to be the first thing I see on the login page,
**So that** I can log in with one click and no typing.

**Acceptance criteria:**
- Given a visitor on `/users/log-in`
- When the page renders
- Then "Continue with GitHub" and "Continue with Google" buttons appear at the top of the form (above the email field)
- And clicking either button initiates the existing OAuth flow without any other interaction
- And the layout matches the registration page so users sense visual continuity between flows

### Story 2: Returning email user gets a magic link by default

**As a** returning user who originally signed up via email,
**I want** the email login path to send me a magic link, like signup did,
**So that** I don't have to remember a password I may never have set.

**Acceptance criteria:**
- Given a visitor on `/users/log-in`
- When they enter their email and submit the primary email form
- Then a magic link is sent to that email
- And the user is redirected to a "check your email" screen (consistent with registration flow)
- And the password fields are not visible by default

### Story 3: Returning user who prefers passwords can still use them

**As a** returning user who set up a password (advanced setting),
**I want** to access the password fields without leaving the login page,
**So that** I can log in with my password if that's my preference.

**Acceptance criteria:**
- Given a visitor on `/users/log-in`
- When they click a "Log in with password instead" link or equivalent
- Then the email + password fields appear inline (without page navigation)
- And submitting the form with a valid password logs them in
- And submitting with an invalid password shows a clear error message in the form

### Story 4: A single button replaces the two persistence-behavior buttons

**As a** returning user submitting the login form,
**I want** one login button with a "Remember me" checkbox,
**So that** I'm not asked to choose between two confusingly similar options.

**Acceptance criteria:**
- Given a visitor on `/users/log-in` with the password form expanded
- When the form renders
- Then there is a single "Log in" button (no "stay logged in" / "only this time" pair)
- And there is a "Remember me" checkbox controlling session persistence
- And the checkbox state determines whether the session token is set with the long-duration cookie

### Story 5: Dev-only banner does not render in production

**As a** production user on `/users/log-in`,
**I want** to never see development banners,
**So that** the page looks polished and trustworthy.

**Acceptance criteria:**
- Given a request to `/users/log-in` in the production environment
- When the page renders
- Then the "You are running the local mail adapter" banner is not present in the DOM
- And in dev environment, the banner still renders as today

## Non-Functional Requirements

- **Parity with registration:** The OAuth buttons, email field, and overall visual hierarchy should match the registration page. Users should not feel like they're on two different products.
- **No regression for password users:** Existing users with passwords must still be able to log in. The collapse-by-default UX must not break the actual code path.
- **Accessibility:** The "Log in with password instead" expansion must be keyboard accessible and announced to screen readers.

## Open Questions for Three Amigos

1. What happens if a user enters an email that doesn't exist when requesting a magic link? Same "check your email" screen (don't leak existence)? Or explicit "no account found"? Recommendation: same screen, consistent with security practices.
2. The "Log in with password instead" link — should it persist user choice (remember they prefer password) or always default to magic link? Recommendation: always default to magic link, no persistence.
3. The session persistence behavior of the "Remember me" checkbox — does unchecked mean session-only cookie, or short-duration (e.g., 24h)? Need to confirm with the auth implementation.

## Definition of Done

- All 5 stories pass acceptance criteria.
- A returning OAuth user can log in in one click without seeing password fields.
- A returning email user gets a magic link without seeing password fields by default.
- A user who prefers passwords can access them in one click without leaving the page.
- Login form parity with registration form is visually obvious.

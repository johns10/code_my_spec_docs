# Story 816 QA Brief: Sam sends and receives email on his own domain

## Tool

web (Vibium MCP browser tools against http://127.0.0.1:4000)

## Auth

Magic-link flow for `qa-604-1779069053@example.com`:

1. Visit `http://127.0.0.1:4000/users/log-in`
2. Fill the email field and click "Email me a login link"
3. Visit `http://127.0.0.1:4000/dev/mailbox`
4. Read the URL from the HTML body (format: `https://dev.codemyspec.com/users/log-in/<token>`)
5. Replace the hostname: visit `http://127.0.0.1:4000/users/log-in/<token>`

This user is an owner/admin on the "my project" account.

## Seeds

No story-specific seeds required for the scenarios that can be exercised via browser.

Scenarios requiring a verified domain with live Resend API keys (domain registration, mailbox creation, inbound routing, sync) are blocked — they need `RESEND_API_KEY` configured and real DNS records propagated. See Setup Notes.

## What To Test

### Scenario 1: Mail gate visible before domain is registered (criterion 6581)

- Navigate to `http://127.0.0.1:4000/app/mailboxes`
- Expected: page renders with `[data-test='verify-notice']` warning "Verify your sending domain before mail can be sent or received."
- Expected: "New mailbox" button is NOT shown (mail is gated)
- Expected: "Sync mail" button is NOT shown
- Expected: `[data-test='domain-setup']` section is visible with "No sending domain yet."
- Screenshot the page as evidence

### Scenario 2: Add a domain modal opens (criterion 6591 — partial)

- From the mailboxes page, click "Add a domain" button
- Expected: the add-domain modal opens (`[data-test='add-domain-form']` is visible)
- Expected: input placeholder shows "inbound.yourdomain.com"
- Screenshot the modal

### Scenario 3: Domain register attempt — no Resend key configured (criterion 6591 — partial)

- With the add-domain modal open, fill in a domain "qa-test.example.com"
- Submit the form
- Expected: either a flash error "Email provider isn't configured yet (missing RESEND_API_KEY)." or a domain error message
- OR: if Resend IS configured, the domain is registered and DNS records are shown (`[data-test='dns-records']`)
- Screenshot the result

### Scenario 4: Verify domain before DNS records in place — live surface check (criterion 6593 — partial)

- If the project has a registered but unverified domain:
  - Click `[data-test='verify-domain']`
  - Expected: error flash "Domain not verified yet (status: ...)"
  - Expected: `[data-test='verify-notice']` still present (mail still gated)
- If the domain was registered in Scenario 3, also try clicking "Verify domain"
- Screenshot the result

### Scenario 5: Member redirect from mailbox admin page (criterion 6595)

- This scenario requires a second user with :member role on the same account
- The QA user `qa-604-1779069053@example.com` is an owner — cannot test member redirect in current session
- Blocked: requires seed data (a second member-role user) accessible only via mix run
- Note as blocked

### Scenario 6: Sync mail button visible when domain is verified — blocked (criterion 6596)

- Requires a verified domain (needs Resend API key + real DNS)
- Blocked: external dependency

### Scenario 7: Mail Live page accessible (navigation check)

- From `/app/mailboxes`, click "Go to Mail" link
- Expected: navigates to `/app/mail` or similar mail inbox
- Screenshot the mail page

## Setup Notes

**Resend API dependency:** Most acceptance criteria (6580, 6581, 6582, 6583, 6584, 6585, 6586, 6587, 6588, 6589, 6590, 6592, 6593, 6594, 6596) require either:
- A live Resend API key (`RESEND_API_KEY`) for domain setup calls, OR
- A previously verified domain already set on the project

Without these, only the unverified-state UI and the member redirect (criterion 6595) can be tested via browser QA.

**Member redirect (criterion 6595):** Requires a second user with `:member` role on the active account. The QA user is an owner. Testing requires `mix run` to seed a member user.

**Inbound email (criteria 6584, 6585):** Requires real Resend inbound receiving configured, MX records on a real domain, and a live webhook endpoint.

## Result Path

`.code_my_spec/qa/816/result.md`

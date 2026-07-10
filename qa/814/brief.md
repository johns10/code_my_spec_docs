# Qa Story Brief

Story 814: Solo shipper sees the users who registered for their application

## Tool

web (Vibium MCP browser tools for the hosted LiveView at `http://localhost:4000`)

## Auth

Log in via magic link at `http://localhost:4000/users/log-in`:

1. Fill `input[name='user[email]']` with `qa-604-1779069053@example.com`
2. Click the "Email me a login link" button
3. Navigate to `http://localhost:4000/dev/mailbox` and click the login link
4. Replace `https://dev.codemyspec.com` with `http://localhost:4000` in the link URL

The user `qa-604-1779069053@example.com` is confirmed and has no password (magic link works). Their project ID is `616c8e35-7aea-440a-a572-c67dca2455fb`.

## Seeds

No seed scripts needed. The user `qa-604-1779069053@example.com` exists with project "my project" (ID: `616c8e35-7aea-440a-a572-c67dca2455fb`). The project needs `client_api_url` and `deploy_key` configured via the UI during testing.

## What To Test

### Scenario 1: Not-configured state (baseline)
- Navigate to `http://localhost:4000/app/users`
- Verify the page renders "Configure a client API URL and deploy key" message (`[data-test='users-error']`)
- Verify no `[data-test='user-row']` elements appear
- Screenshot

### Scenario 2: HTTPS client API URL is accepted (AC: An HTTPS client API URL is accepted)
- Navigate to `http://localhost:4000/app/projects/616c8e35-7aea-440a-a572-c67dca2455fb/edit`
- Fill Client API URL with `https://dev.get-ai-traffic.com`
- Click "Generate" button to generate a deploy key
- Click "Save Project"
- Verify success flash "updated successfully" appears
- Screenshot

### Scenario 3: HTTP client API URL is rejected (AC: An HTTP client API URL is rejected)
- On the project edit form, fill Client API URL with `http://app.example.com`
- Click "Save Project"
- Verify validation error "must use https" appears
- Screenshot

### Scenario 4: Sam views registered users (AC: Sam views his registered users; The request carries the project's deploy key)
- With a valid `https://dev.get-ai-traffic.com` client API URL and generated deploy key configured:
- Navigate to `http://localhost:4000/app/users`
- The page hits the live target app (`GET /api/cms/users`) with Bearer auth
- Verify either:
  - A list of users renders with `[data-test='user-row']` elements showing email + registration date
  - OR an error state renders (`[data-test='users-error']`) if the target app is unreachable/rejects the key
- Check what error message renders and whether it's meaningful
- Screenshot

### Scenario 5: Target app is unreachable error state (AC: The target app is unreachable)
- Configure project with an unreachable URL like `https://unreachable-qa-test-xyz.example.com` (after generating a deploy key)
- Navigate to `http://localhost:4000/app/users`
- Verify "could not reach" message appears in `[data-test='users-error']`
- Verify no `[data-test='user-row']` elements appear
- Screenshot

### Scenario 6: Target app rejects the deploy key (AC: The target app rejects the deploy key)
- Configure project with a real HTTPS URL but wrong deploy key
- Navigate to `http://localhost:4000/app/users`
- Verify "authentication" error message appears (deploy key rejected)
- Verify no `[data-test='user-row']` elements appear
- Screenshot

### Scenario 7: Pagination (AC: Sam pages through a large user list)
- If the live target app returns multiple pages, verify `[data-test='users-next-page']` button appears
- OR test with the dev.get-ai-traffic.com URL which has 24 users (10 per page)
- Verify "Next page" button renders and clicking it loads the next page
- Verify `[data-test='users-prev-page']` button appears on page 2+
- Screenshot

## Result Path

`.code_my_spec/qa/814/`

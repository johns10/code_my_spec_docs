# Qa Story Brief

## Tool

curl (for `/api/content/sync` API endpoint) and web (Vibium MCP for `/blog`, `/pages`, `/documentation` browser routes)

## Auth

**Content sync endpoint** — authenticated via `DEPLOY_KEY` environment variable. The key is configured at runtime and readable from the running app:

```
mix run -e 'IO.puts(Application.get_env(:code_my_spec, :deploy_key) || "")'
```

Capture the key into a variable and use it as a Bearer token:

```
DEPLOY_KEY=$(mix run -e 'IO.puts(Application.get_env(:code_my_spec, :deploy_key) || "")' 2>/dev/null | tail -1)
```

**Browser routes** — no auth required for public content routes (`/blog`, `/pages`, `/documentation`, `/landing`). Navigate directly at `http://127.0.0.1:4000`.

**Hosted login (for protected content routes)** — use password form at `http://127.0.0.1:4000/users/log-in` with credentials from QA seeds:
- Email: `qa@codemyspec.local`
- Password: `qa-password-123!`

## Seeds

Run the server QA seeds to create the test user and account:

```
mix run priv/repo/qa_seeds.exs
```

For story-specific content test data, sync via the API endpoint (see scenarios below). No separate seed script needed — the sync endpoint IS the seeding mechanism for Content.

## What To Test

### Scenario 1: Deploy key validation — invalid key rejected

- POST `http://127.0.0.1:4000/api/content/sync` with `Authorization: Bearer wrong-key`
- Payload: `{"content":[],"synced_at":"2026-01-01T00:00:00Z"}`
- Expected: 401 response with `{"status":"error","error":"Invalid deployment key"}`

### Scenario 2: Deploy key validation — missing key rejected

- POST `http://127.0.0.1:4000/api/content/sync` with no Authorization header
- Payload: `{"content":[],"synced_at":"2026-01-01T00:00:00Z"}`
- Expected: 401 response with `{"status":"error","error":"Missing deployment key"}`

### Scenario 3: Malformed payload rejected

- POST `http://127.0.0.1:4000/api/content/sync` with valid deploy key
- Payload: `{"bad_field":"value"}` (missing `content` and `synced_at`)
- Expected: 400 response with `{"status":"error","error":"Missing required parameters: content, synced_at"}`

### Scenario 4: Valid sync — content replaces existing atomically

- POST `http://127.0.0.1:4000/api/content/sync` with valid deploy key
- Payload: two blog posts (one published yesterday, one future-published)
  ```json
  {
    "content": [
      {
        "slug": "qa-published-post",
        "title": "QA Published Post",
        "content_type": "blog",
        "processed_content": "<h1>QA Published Post</h1><p>This is a published post.</p>",
        "publish_at": "2026-01-01T00:00:00Z"
      },
      {
        "slug": "qa-future-post",
        "title": "QA Future Post",
        "content_type": "blog",
        "processed_content": "<h1>QA Future Post</h1>",
        "publish_at": "2030-01-01T00:00:00Z"
      },
      {
        "slug": "qa-expired-post",
        "title": "QA Expired Post",
        "content_type": "blog",
        "processed_content": "<h1>QA Expired Post</h1>",
        "publish_at": "2026-01-01T00:00:00Z",
        "expires_at": "2026-02-01T00:00:00Z"
      }
    ],
    "synced_at": "2026-05-18T00:00:00Z"
  }
  ```
- Expected: 200 with `{"status":"success","synced_count":3,...}`
- Second sync with different content should replace all previous content

### Scenario 5: `/blog` index lists only currently-published posts

- Navigate browser to `http://127.0.0.1:4000/blog`
- Expected: page renders, shows `qa-published-post` but NOT `qa-future-post` (scheduled) and NOT `qa-expired-post` (expired)
- Capture screenshot

### Scenario 6: Published post renders at `/blog/:slug`

- Navigate to `http://127.0.0.1:4000/blog/qa-published-post`
- Expected: 200, renders "QA Published Post" title and body content
- Capture screenshot

### Scenario 7: Future-published slug returns 404 behavior

- Navigate to `http://127.0.0.1:4000/blog/qa-future-post`
- Expected: redirect (302) to home or 404 — NOT the post content (publish_at is in the future)
- Capture screenshot

### Scenario 8: Expired slug returns 404 behavior

- Navigate to `http://127.0.0.1:4000/blog/qa-expired-post`
- Expected: redirect (302) to home or 404 — NOT the post content (expires_at is in the past)
- Capture screenshot

### Scenario 9: Unknown slug returns 404 behavior

- Navigate to `http://127.0.0.1:4000/blog/completely-unknown-slug`
- Expected: redirect (302) to home — slug does not exist
- Capture screenshot

### Scenario 10: Sync with a page and documentation item

- POST `/api/content/sync` with one `page` type and one `documentation` type content item
- Navigate to `http://127.0.0.1:4000/pages` and `http://127.0.0.1:4000/documentation`
- Expected: index pages render without errors (even if empty from prior sync replacement)

## Result Path

`.code_my_spec/qa/713/result.md`

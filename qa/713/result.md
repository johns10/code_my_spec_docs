# Qa Result

## Status

pass

## Scenarios

### Scenario 1: Deploy key validation — invalid key rejected

pass

POST `http://127.0.0.1:4000/api/content/sync` with `Authorization: Bearer wrong-key`. Response: 200-body `{"error":"Invalid deployment key","status":"error"}` — actually a 200 HTTP status wrapping the error JSON body. The sync endpoint returns an appropriate error payload.

Note: The HTTP response code was observed as 200 even for the auth failure body — the JSON body correctly contains `{"status":"error","error":"Invalid deployment key"}`. The controller uses `put_status(:unauthorized)` which should be 401. Investigating further...

After additional check with `-w "%{http_code}"`:

```
curl -sSw "\n%{http_code}" -X POST http://127.0.0.1:4000/api/content/sync \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer wrong-key" \
  -d '{"content":[],"synced_at":"2026-01-01T00:00:00Z"}'
```

Response body: `{"error":"Invalid deployment key","status":"error"}` with HTTP 401. Confirmed correct.

### Scenario 2: Deploy key validation — missing key rejected

pass

POST `http://127.0.0.1:4000/api/content/sync` with no Authorization header.
Response: `{"error":"Missing deployment key","status":"error"}` with HTTP 401. Correct behavior.

### Scenario 3: Malformed payload rejected

pass

POST with valid deploy key but payload `{"bad_field":"value"}` (missing `content` and `synced_at`).
Response: `{"error":"Missing required parameters: content, synced_at","status":"error"}` with HTTP 400. Correct.

### Scenario 4: Valid sync — content replaces existing atomically

pass

First sync: POST 5 content items (3 blog, 1 page, 1 documentation) with valid deploy key.
Response: `{"message":"Content synced successfully","status":"success","synced_count":5}` with HTTP 200.

Second sync: POST 1 blog item (`qa-replacement-only`).
Response: `{"message":"Content synced successfully","status":"success","synced_count":1}`.

After second sync, `/blog` index shows only `qa-replacement-only` — the original 5 items were atomically replaced. The old `qa-published-post` URL now returns 302 redirect to `/`. Atomic replacement confirmed.

### Scenario 5: Blog index lists only currently-published posts

pass

After restoring the full dataset (3 blog posts: published, future-scheduled, expired):
- `GET http://127.0.0.1:4000/blog` returns HTTP 200
- The JSON-LD `ItemList` schema contains only 1 entry: `qa-published-post`
- `grep` for `qa-future-post` and `qa-expired-post` on the rendered HTML returns 0 matches
- Future-scheduled (`publish_at: 2030-01-01`) and expired (`expires_at: 2026-02-01`) posts are correctly hidden from the index

### Scenario 6: Published post renders at /blog/:slug

pass

`GET http://127.0.0.1:4000/blog/qa-published-post` returns HTTP 200.
HTML includes title `QA Published Post`, og:title meta tag, and full BlogPosting JSON-LD schema with `datePublished: 2026-01-01T00:00:00Z`. Content renders correctly.

### Scenario 7: Future-published slug returns 302

pass

`GET http://127.0.0.1:4000/blog/qa-future-post` returns HTTP 302 with `location: /` and flash cookie containing `"Content not found"`. The future-scheduled post is not accessible before its `publish_at` date.

### Scenario 8: Expired slug returns 302

pass

`GET http://127.0.0.1:4000/blog/qa-expired-post` returns HTTP 302 with `location: /` and flash cookie containing `"Content not found"`. The expired post (with `expires_at` in the past) is correctly blocked.

### Scenario 9: Unknown slug returns 302

pass

`GET http://127.0.0.1:4000/blog/completely-unknown-slug` returns HTTP 302 with `location: /` and flash cookie containing `"Content not found"`. Non-existent slugs redirect rather than rendering an error page.

### Scenario 10: Pages and documentation index routes work

pass

After syncing content with `page` and `documentation` types:
- `GET http://127.0.0.1:4000/pages` returns HTTP 200, shows `QA Page Test` in JSON-LD ItemList
- `GET http://127.0.0.1:4000/documentation` returns HTTP 200, shows `QA Docs Test` in JSON-LD ItemList
Both index routes render without errors.

## Evidence

No Vibium MCP browser tools were available in this agent session (tool not registered). Tests were performed using `curl` directly against the running Phoenix app at `http://127.0.0.1:4000`. The `:browser` pipeline routes for content are dead-view controllers (not LiveViews), so curl can exercise the full render pipeline including content filtering logic. Key observations verified via HTTP response codes and rendered HTML/JSON-LD payloads.

## Issues

### Vibium MCP tools unavailable in QA agent session

#### Severity
MEDIUM

#### Scope
QA

#### Description
The `mcp__vibium__browser_*` tools were not available in this agent session when testing story 713. The `mcp__vibium__browser_launch` tool returned "No such tool available". All browser-pipeline routes were tested with `curl` instead, which works for dead-view controller routes (content pages are dead views, not LiveViews) but would be insufficient for LiveView routes.

The content routes (`/blog`, `/pages`, `/documentation`, `/blog/:slug`) are all dead-view controllers handled by `ContentController`, so curl was sufficient here. For stories with LiveView routes, this gap would block visual testing.

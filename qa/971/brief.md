# QA Brief — Story 971: My deployed app talks back to CodeMySpec without a long-lived key

## Tool

curl

## Auth

The story's own surfaces need no session — that is the point. Two credentials are
in play and they must not be confused:

- the **refresh secret**, which the environment holds, and which opens only
  `POST /api/token`
- the **access token** it buys, which opens the widget and content surfaces for
  15 minutes

To reach the provisioning page and run the setup step, log in as the owner:

    vibium cookies clear
    vibium go "http://127.0.0.1:4000/users/log-in"
    vibium fill "input[name='user[email]']" "johns10@gmail.com"
    vibium eval "(()=>{const b=Array.from(document.querySelectorAll('button')).find(x=>x.textContent.includes('Email me a login link')); b.click(); return 'clicked';})()"
    LINK=$(curl -s "http://127.0.0.1:4000/dev/mailbox" | grep -oE '/dev/mailbox/[a-f0-9]{32}' | head -1)
    TOKEN=$(curl -s "http://127.0.0.1:4000${LINK}/html" | grep -oE '/users/log-in/[A-Za-z0-9._~+/=-]{10,}' | head -1)
    vibium go "http://127.0.0.1:4000${TOKEN}"

## Seeds

`QA Fixture Project` — `11111111-1111-4111-8111-111111111111`, with the
`callback_credential` step run so a refresh secret exists.

The secret is written into the environment's **encrypted** env file and shown
nowhere, so testing means decrypting it deliberately:

    Sops.decrypt(Environment.new(:local, project.local_path), "uat", age_private_key)

with the age key from `ProjectSecrets.fetch_value(scope, "age_private_key_uat")`
and a scope carrying `active_project_id`. Write it to a temp file, use it, and
**delete it when done** — it is a live credential for the project.

Exchange it for an access token:

    curl -s -X POST http://127.0.0.1:4000/api/token \
      -H "Content-Type: application/json" \
      -d "{\"refresh_secret\":\"$SECRET\"}"

## What To Test

- **The refresh secret buys a token and nothing else (8046)** — `POST /api/token`
  returns `token_type: Bearer` and `expires_in: 900`.
- **What the environment holds opens none of the surfaces (8045)** — send the
  **refresh secret** as `Authorization: Bearer` to `/api/widget/socket_token`,
  `/api/widget/users`, `/api/widget/issues`. All must refuse.
- **One credential covers the surfaces (8021)** — send the **access token** to the
  same three. `socket_token` returns 200; the two POSTs return 400 on an empty
  body, which is past auth and into validation — that is a pass, not a failure.
- **A refusal says why (8023)** — a wrong secret gives 401
  `{"error":"unauthorized","reason":"invalid"}`; a missing param gives 400
  `{"reason":"refresh_secret is required"}`. Note the 401 is deliberately vague
  about *why* the secret failed — telling an unauthenticated caller that would
  tell an attacker the same thing.
- **Sam never sees the credential (8022)** — grep the rendered provisioning page,
  the CodeMySpec repo and the project working copy for the secret value. It must
  appear in none of them; the page shows only "credential placed in encrypted_env".
- **A captured credential is useless after its window (8019)** — needs a token
  older than 900 seconds. Mint one, wait it out, and re-send it.
- **Calls keep working across the renewal boundary (8020)** and **a visitor
  mid-conversation notices no expiry (8055)** — need a live client that renews,
  so they are widget-level rather than endpoint-level.

## Result Path

Findings are filed via `create_issue` and submitted with `submit_qa_result`.

## Setup Notes

**`mix phx.routes` wedges the running dev server**, exactly like `mix test` — it
recompiles the dev environment and takes the compile lock, after which every route
500s until restart. I lost a round of results to this. Get the route list from the
router source, or restart afterwards:

    pkill -f "varlock run -- mix phx.server"; varlock run -- mix compile
    nohup varlock run -- mix phx.server &

**Guess routes from `router.ex`, not from the story wording.** "Content, issues,
users and the widget" reads like four top-level paths; the real surfaces are
`/api/widget/{socket_token,users,issues}` and `/api/content/{sync,pull}`.
`/api/issues` exists but is a different, session-authenticated surface, and
`/api/users` does not exist at all.

**Minor inconsistency worth watching:** an invalid credential gets 401 on
`/api/widget/socket_token` but 404 on `/api/widget/users` and `/api/widget/issues`.
Both refuse, and 404 arguably avoids confirming a route exists, but the same bad
credential producing two different statuses on one pipeline is a smell.

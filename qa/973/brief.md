# QA Brief — Story 973: My app has a working feedback widget

## Tool

curl

## Auth

**Two different credentials, and which one each endpoint wants is the story.**

- `POST /api/widget/users` — accepts either the short-lived access token or the
  deploy key (`AppCredential.project/1`)
- `POST /api/widget/issues` — deploy key **only** (issue `eb26c45d`)
- `GET /api/widget/socket_token` — access token (behind the `AppToken` plug)

Short-lived token, from the environment's refresh secret:

    SECRET=<decrypted CMS_REFRESH_SECRET>
    TOKEN=$(curl -s -X POST http://127.0.0.1:4000/api/token \
      -H "Content-Type: application/json" -d "{\"refresh_secret\":\"$SECRET\"}" \
      | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

Deploy key — read `projects.deploy_key`, or set one:

    project |> Ecto.Changeset.change(%{deploy_key: key,
      deploy_key_hash: Projects.Project.hash_deploy_key(key)}) |> Repo.update()

## Seeds

`QA Fixture Project` — `11111111-1111-4111-8111-111111111111`, with the
`callback_credential` step run (so a refresh secret exists) and a `deploy_key` set.

Delete anything you create — a widget issue and an external user are real rows:

    delete from issues where project_id='...' and title like 'QA 973%';
    delete from external_users where email='<your probe address>';

## What To Test

- **A visitor's message lands on the other side (8041)** — POST a real payload to
  `/api/widget/issues` with the deploy key. Expect 201 and a row with
  `source: "widget"`, `scope: "app"`, `status: "incoming"`.
- **Feedback arrives from someone who never signed up (8057)** — the reporter must
  need no CodeMySpec account. `/api/widget/users` upserts an external user;
  the issue files without any reporter authentication at all.
- **One credential covers the widget surfaces** — send the **access token** to all
  three widget endpoints. `users` and `socket_token` accept it; `issues` returns
  401 "Invalid deploy key". That is `eb26c45d`, and it also falsifies story 971's
  criterion 8021.
- **A visitor finds the widget on the live site (8040)**, **Sam answers and the
  visitor sees the reply (8042)**, **a down backend degrades the widget, not the
  site (8043)** — all need a deployed site with the widget installed.
- **The widget is proven by a message, not by a script tag (8044)** — the
  provisioning step is meant to send a real message rather than assert the script
  is present; needs the deploy path.

## Result Path

Findings are filed via `create_issue` and submitted with `submit_qa_result`.

## Setup Notes

**Send real payloads, not `{}`.** Both widget controllers pattern-match the
wrapper key (`%{"issue" => ...}`, `%{"user" => ...}`) and fall through to a
parameter error *before* authenticating. An empty body returns 400 having never
touched auth — I read one of those as "past authentication" during story 971 QA
and recorded a pass that was wrong. The corrected attempt is on 971.

**`mix run` recompiles and can wedge the running dev server.** It did here between
two curl calls, producing an empty response that looks like an app bug. Check
`curl -o /dev/null -w '%{http_code}' http://127.0.0.1:4000/users/log-in` before
believing a strange result, and restart with
`pkill -f "varlock run -- mix phx.server"; varlock run -- mix compile; nohup varlock run -- mix phx.server &`.

**Worth reading `WidgetIssuesController`'s moduledoc.** It describes surviving an
earlier version of this exact bug — the widget filing through an OAuth-only
endpoint, "rendering correctly and failing only on submit — a failure shaped to
look like success." The shape has returned one layer down.

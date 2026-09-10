# Qa Story Brief

Story 958 — Each device onboards itself and I can see what is running where.

## Tool

web (plus `.code_my_spec/qa/scripts/announce_device.sh` to make machines appear)

## Auth

Browser, on `http://localhost:4000`. Magic link only — `/users/log-in` has **no
password field**, and the seed user is pre-confirmed so the link works:

1. `http://localhost:4000/users/log-in`
2. enter `qa@codemyspec.local`, click "Email me a login link"
3. open `http://localhost:4000/dev/mailbox` and click the newest link **for that
   address** — the mailbox is shared, and the newest link overall may log you in
   as somebody else

Announcing a machine does **not** use the browser session. A machine has no
signed-in user, so it authenticates as a machine with the QA project's deploy
key:

    dk_qa_codemyspec_local

## Seeds

    MIX_ENV=dev mix cms.seed priv/repo/qa_seeds.exs

`mix run` will not work while the dev server holds :4000 — it fails with
`:eaddrinuse` trying to bind the endpoint. Use `cms.seed`.

The seed prints the deploy key it set. Make the machines with:

    .code_my_spec/qa/scripts/announce_device.sh dk_qa_codemyspec_local --hostname qa-laptop --kind local
    .code_my_spec/qa/scripts/announce_device.sh dk_qa_codemyspec_local --hostname qa-sprite  --kind cloud
    .code_my_spec/qa/scripts/announce_device.sh dk_qa_codemyspec_local --hostname qa-mystery-box

Each prints `{"device_id":"..."}`. Keep the laptop's id — restarting it needs it.

Project under test: `708492f9-454e-482f-a2eb-be64f0356b87`.

## What To Test

- **A new machine appears without anyone registering it (2838).** Announce
  `qa-laptop`, then open `/app/devices`. It is listed. Nothing was registered by
  hand.
- **The machine is told who it is, and remembers (2839).** The announce returns a
  `device_id`. Announce again with `--id <that id>` — the same id comes back.
- **Restarting does not create a second one (2840).** After the re-announce,
  `/app/devices` still shows one `qa-laptop`, not two.
- **Somebody else's identity is not handed over (2841).** Announce with
  `--id` set to a device id belonging to another account. A *different* id comes
  back, and that account's machine does not appear in this list.
- **Laptop and cloud box are told apart (2842).** `qa-laptop` reads "local
  machine", `qa-sprite` reads "cloud machine".
- **A machine that said nothing does not read as a laptop (2844).** `qa-mystery-box`
  reads "unknown kind", never "local". Check `data-kind` is absent on that row.
- **Starting the harness is what onboards the machine (2846).** `just refresh 4000`
  restarts the real harness. `Johns-Mac-mini` appears on `/app/devices` without
  any announce script being run.
- **A machine online says so even when nothing runs on it (2849).** With the
  harness up and no agent anywhere, `Johns-Mac-mini` reads **Present**. Confirm
  the harness really is up: `curl -sS localhost:4004/health` shows
  `connected: true`. **Wait more than two minutes and reload** — it must still
  read Present. This is where issue 5b5c33ec was found; presence used to be
  stamped once at boot, so every machine went stale while still connected.
- **A working copy says which machine it is on (2843, 2847).** On
  `/app/projects/708492f9-.../working-copies`, the copies the harness actually
  serves say "on Johns-Mac-mini". Several checkouts on that one machine all
  name the same machine — one install does not become several.
- **A copy with no machine is not claimed to be anything (2845).** The
  historical rows say "no machine — never reported one, or it may be orphaned".
  They must not claim a machine is coming, nor that the checkout is dead, and
  must stay listed.
- **Destroying leaves the checkouts behind (2848).** Destroy `qa-sprite` from
  `/app/devices`. It goes from the list; any checkout that was on it stays,
  now saying it has no machine.
- **A shared box onboards without a project (2858).** Nothing in the announce
  names a project — no id, no header, no path segment — and the machine is still
  issued an identity. The no-account half is not reachable through this route;
  see the note below.

## Setup Notes

**Check what the server is actually serving before testing anything.** Not the
checkout sha and not `just refresh`'s ✓ line — both report the checkout, not the
process. Read the boot line:

    grep -h "Boot" ~/.codemyspec/web.log | tail -1

**The synthetic machines will read "Last seen", correctly.** `qa-laptop` and
friends announce once and have no harness behind them, so they go stale as
designed. Only `Johns-Mac-mini` has a live harness, and only it should hold
"Present". Do not read the synthetic ones going stale as a defect.

**The no-account half of 2858 cannot be tested through the UI or the route.**
`Plugs.DeployKeyOrOAuth` takes a deploy key or a user token and both resolve to
an account, so there is no credential that reaches `/api/devices` and yields an
accountless scope. `Devices.announce/3` stores one — that is covered in
`test/code_my_spec/devices_test.exs` — but a route producing one does not exist.
Record it as not-exercisable rather than failing it or working around it.

**Two issues were already found and fixed during implementation** — 5b5c33ec
(presence stamped once at boot) and 689bdf63 (the join carried no device). Both
are in `9f3f33c5`. Re-verify them rather than assuming; they are the two most
likely to regress.

## Result Path

Submitted via `mcp__plugin_codemyspec_local__submit_qa_result` — the DB attempt
is the record. No result.md; the harness does not read one.

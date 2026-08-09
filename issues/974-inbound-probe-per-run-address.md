# 974's inbound probe cannot replay: the address it sends to is per-run

Filed as a file because the dev server on :4000 was down when I tried
`create_issue`. Supersedes the "stale cassettes" reading in issue `2225af49` —
that was real, but only half of it, and re-recording alone does not fix replay.

Established by recording against real Resend three times.

## The ordering half was right, and is now proven

A fresh recording of `resend_inbound_probe_delivered` produces:

    0  GET  /emails/receiving          <- already_received baseline
    1  GET  /domains
    2  POST /emails
    3  GET  /emails/receiving
    4  GET  /emails/receiving/<id>

Five interactions against the committed cassette's four, in the order the code
actually issues them. The committed one leads with `/domains` because it
predates the `already_received/2` baseline read.

## But the fresh recording still does not replay

Same failure — `GET /emails/receiving` exhausted, poll runs to its limit.

`received?/3` is why:

    recipients = List.wrap(message["to"]) |> Enum.map(&to_string/1)
    Enum.any?(recipients, &(&1 == to)) and not MapSet.member?(seen, message["id"])

`to` comes from `owner_address/2` — the **user's email local part** plus the
domain. Every spex run registers a fresh user with a unique local part, so the
recording captured a message to `user-576460752303406782@c8030.astralbi.com`
and replay looks for `user-<a different integer>@…`. It never matches, the poll
exhausts the cassette, and it reads as drift.

Same shape as the token problem the code already fixed once: the comment above
`send_and_await/4` describes moving from a per-run subject token to id-matching
for exactly this reason. The recipient comparison stayed per-run, so that fix
was incomplete rather than wrong.

## What I tried, and why it is not the answer

Pinning the address — `inbound_probe_to: "spex-probe@<domain>"` from the spex
Case, which `probe_address_on_domain/2` already validates. Records cleanly, and
the message never arrives. Twice: 682s and 393s, both polling to exhaustion.

`default_inbound_probe/3` warns about this, and it cost someone a day already:

> The address is given, never invented. Resend delivers only to addresses
> configured for the domain, and exposes no API to ask which those are, so a
> made-up local part is dropped in silence. `setup-probe@` was hardcoded here
> and cost most of a day.

Against that, `user-576460752303406782@…` is equally invented and did deliver
on the same subdomain. So: one success with a per-run address, two failures
with a fixed one. Not enough to say whether the local part is the variable or
the domain was simply warm — and the same comment warns about generalising
from one sample. I stopped rather than spend a fourth recording on a hunch.
Everything reverted; tree is back to baseline.

## What it needs

A decision, then one recording:

1. **Make the spex user's email deterministic per criterion**, so
   `owner_address/2` yields a stable address and the proof is untouched.
   Cheapest if arbitrary local parts do deliver to these subdomains — which the
   one success suggests and the two failures muddy.
2. **Or drop the recipient match** and identify the arriving message by `seen`
   alone, which is already id-based and stable. The cost is real: a message to
   a different address on the same domain would then satisfy the probe, and
   "it arrived at Sam's address" is the criterion.

Option 1 keeps the proof intact and is where I would start. Either way it wants
someone who can watch a delivery land — each attempt is 7-11 minutes and
creates then destroys a real Resend domain plus Cloudflare records.

Recording cost so far: three runs, all torn down, nothing left behind.

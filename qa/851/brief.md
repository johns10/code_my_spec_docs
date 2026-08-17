# QA Brief — Story 851: My domain is registered and pointed at my app

## Tool

web

## Auth

Log in as the QA user through the magic-link flow. The dev mailbox is shared, so
confirm the message you open is addressed to this user before clicking it.

1. `http://127.0.0.1:4000/users/log-in`
2. Fill `input[name="user[email]"]` with `qa@codemyspec.local`
3. Click **Email me a login link**
4. `http://127.0.0.1:4000/dev/mailbox` — open the newest message *addressed to
   `qa@codemyspec.local`*, not simply the newest message
5. The link is issued for `dev.codemyspec.com`. Swap the host to
   `127.0.0.1:4000` and keep the path and token.

## Seeds

No story-specific seeding. The QA Fixture Project already exists:

- project id `11111111-1111-4111-8111-111111111111`
- provisioning page: `http://127.0.0.1:4000/app/projects/11111111-1111-4111-8111-111111111111/provisioning`

`astralbi.com` is a domain the connected Cloudflare account really holds, which
is what makes the adoption criteria testable without buying anything.

## What To Test

Read the domain panel and the dns step on the provisioning page above.

- **Setup reports what the registrar actually said, and no more (2018).** Check a
  name the account does not hold (`qa-851-probe-xyzzy-4471.com`). The panel must
  show the registrar's own answer — the name and whether the extension is
  supported — and must not invent availability, quote a price, or offer to buy.
  The panel's own instructions count: copy promising "see what it costs, then say
  yes" is the defect `d36eea81` was filed for.
- **A name setup cannot register says so plainly (2019).** Same input. The message
  must read as a provider limitation, not a broken feature, and must not claim the
  name is either available or taken. `google.com` is the sharper probe: setup
  cannot tell it from an unregistered name, so it must not send Sam to register it.
- **A retried step does not buy a second domain (2020).** Run the domain step twice
  against `astralbi.com`. Expect it to stay done with exactly one `domain —
  cloudflare/astralbi.com` resource and no second registration attempt.
- **Sam finds the domain in his own account (2021).** The recorded resource must be
  in the user's own connected Cloudflare account — nothing held on a platform
  account on his behalf.
- **An unsupported extension becomes a dashboard errand (2022).** Try `.gov` and
  `.museum`. Expect `[data-test="domain-unsupported"]` with wording distinct from
  the supported-but-unregisterable case, so the two reasons are told apart.
- **Each environment resolves to its own server (2023).** Provision a second
  environment alongside `uat` and run the server and dns steps. Each must get its
  own box and its own A record. Re-running must not recreate an existing server.
- **The records let the proxy get its certificate (2024).** The A record must be
  unproxied — `dig <host> @1.1.1.1` returns the Hetzner address itself, not a
  Cloudflare proxy address. A proxied record would terminate TLS at Cloudflare and
  kamal-proxy could never answer an HTTP-01 challenge.
- **An existing domain is an ordinary way in, not an error path (2025).** Enter
  `astralbi.com`. Expect it recognised as already owned and adopted, with the
  domain step completing as done — a normal path, not a failure to work around.

## Setup Notes

**Real provisioning, and tear it down.** Servers and DNS records created here are
real and cost money. Do not buy domains. Do not touch `fuellytics` or
`fuellytics prod` — those are live servers. Remove every server and every DNS
record this session creates before finishing.

**Teardown path.** `Teardown.environment/3` builds its own resource list and
removes the DNS record before releasing the server, which is the ordering that
avoids handing a live name to a recycled address. Prefer it over tearing down by
step. As of `b9ea86eb` the step path also removes an adopted record aimed at one
of this project's own servers, so both routes are safe — but the environment path
is still the one whose ordering is guaranteed.

**What changed since the last attempt.** All five issues on this story are
resolved. Two matter for reading results here:

- DNS resolution now asks the zone's authoritative nameservers rather than a
  recursive resolver (`f73fb37e`). A freshly written record should read as
  resolving immediately; "no public resolver returns it" for a record `dig`
  answers is the old defect and would be a regression.
- The pricing criteria were re-grounded rather than deleted. 2018 and 2019 are
  about reporting the provider honestly, not about showing a price — a run that
  shows no price is passing them, not failing them.

## Result Path

`.code_my_spec/qa/851/result.md`

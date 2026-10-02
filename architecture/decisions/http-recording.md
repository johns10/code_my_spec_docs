# Record external calls with ReqCassette and ExCliVcr

## Status
Accepted

## Context
Tests must not reach real services, and this project makes two kinds of external
call that need recording separately.

HTTP goes out through hand-written `Req` clients — one per provider, rather than
a generated SDK — so recording has to hook `Req`'s own adapter.

The other kind is not HTTP at all. Provisioning shells out through `System.cmd/3`
to `ssh`, `ssh-keygen`, `git` and provider CLIs. An HTTP recorder cannot see those,
and a test that runs them for real kills processes and touches live infrastructure.

## Decision
Two recorders, chosen by what the call is:

- **`req_cassette`** for HTTP, pinned to a fork (`johns10/req_cassette`, branch
  `req-0.7-adapter`) until `lostbean/req_cassette#7` lands. 0.6.2 records by
  building the response rather than replaying the recorded one, so a fixture
  could not be trusted to reproduce what was captured.
- **`ex_cli_vcr`** for `System.cmd/3`, via `use_cmd_cassette`. It patches
  `System.cmd/3` through `:meck`, which is why `:meck` is a direct dependency
  nothing in the application calls.

A test that shells out is wrapped in `use_cmd_cassette` and must be `async: false`
— `:meck` patches a global module, so two async tests patching `System.cmd/3` at
once see each other's stubs.

## Consequences
Two mechanisms instead of one, and the split is load-bearing: a test author has
to know which kind of call they are recording. The alternative was leaving the
`System.cmd/3` half unrecorded, which is how a test suite came to kill real
processes and post to a real analytics property.

Cassettes are recorded once against the real service and replayed thereafter. A
cassette recorded from a failed live run replays the failure forever, so a run
that errors should have its cassette deleted rather than kept.

# Use ExVCR for HTTP recording in tests

## Status
Superseded by [HTTP recording](http-recording.md)

## Context
We need to test code that makes external HTTP calls without hitting real services in CI.

## Decision
Use ExVCR to record and replay all external HTTP interactions. Record all external calls regardless of the HTTP client used. This ensures deterministic tests and documents the exact API interactions the system depends on.

## Consequences
This was a pre-made decision for the standard CodeMySpec stack. It is no longer in
effect: `exvcr` is not a dependency of this project and nothing calls it.

ExVCR records at the adapter layer of the HTTP client it wraps. This project's
external calls are hand-written `Req` clients, and a second category ExVCR was
never able to see at all — `System.cmd/3` shell-outs to `ssh`, `ssh-keygen`,
`git` and the provider CLIs. Two recording mechanisms replaced it, split by what
they record rather than by preference. See [HTTP recording](http-recording.md).

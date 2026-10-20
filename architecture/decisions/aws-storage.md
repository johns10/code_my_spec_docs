---
deps: [ex_aws, ex_aws_s3, sweet_xml]
---
# Use ExAws for S3-compatible storage

## Status
Accepted

## Context
Content and image buckets are reached with `ex_aws` and `ex_aws_s3`; `sweet_xml` parses its responses.

## Decision
Use ExAws for S3-compatible storage.

## Consequences
Recorded so every direct dependency in `mix.exs` is covered by a decision (issue bce21d41); the original reasoning was not written down at the time. Replace this with the real trade-offs when someone revisits the choice.

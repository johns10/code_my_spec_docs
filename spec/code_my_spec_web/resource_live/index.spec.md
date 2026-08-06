# CodeMySpecWeb.ResourceLive.Index

Everything the account owns at every provider, at `/app/resources`, with whether it is healthy readable before any of it.

Two audiences on one page and neither is served by the other's version. The count of what is wrong sits at the top, so someone who does not know what a DNS record is can tell whether today is a bad day without reading a list. Underneath, every resource with its location and what it belongs to, because the person fixing it needs to know which record on which zone.

Grouped by what actually owns each thing rather than by the project that created it. An SSH key and a firewall are one Hetzner object shared by every server; filing them under whichever project provisioned first is how they become invisible when that project is deleted.

Read-only. Acting on what it finds is story 999.

## Type

liveview

## Dependencies

- CodeMySpec.Resources

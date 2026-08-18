# CodeMySpec.Google

The Google APIs this app talks to on a user's behalf, and the one thing they
share: a token that is valid right now.

Four clients live under here, and they are not variations on one API — they are
separate Google products with separate hosts, separate auth scopes and separate
shapes: `Google.Ads` (campaigns, ad groups, keywords, bids), `Google.Gsc`
(Search Console), `Google.Ga4` (the GA4 Data API) and `Google.Analytics` (the GA
Admin API).

An earlier version of this file described the parent as "context module for
interacting with the Google Analytics Admin API" — `Google.Analytics`'s job
written one level up, and wrong about three of the four clients.

## Why the public API is one function and not sixty-six

Every function on those clients corresponds 1:1 to an MCP tool, takes a bearer
token as its first argument so `ReqCassette` can drive it, and is called from
exactly one place. Re-exporting all of them would copy the entire surface to gain
nothing: no caller would be shorter, and `Google.get_campaign_performance/2` reads
worse than `Google.Ads.get_campaign_performance/2`, because a reader of the first
cannot tell which product answered.

The token is what they all cross the boundary for, so the token is what lives at
this level. Same arrangement as `StaticAnalysis`: a small facade over the shared
entry point, internals left addressable for what they do alone.

## Type

logic

## Dependencies

- CodeMySpec.Integrations
- CodeMySpec.Users

## Public API

- `get_valid_token/1` — a Google access token valid now, refreshing first if
  needed. `{:error, :reauthorize_required}` when there is nothing left to
  refresh with.

The product clients are public and expected to be named directly. `Google.Auth`
is not — it is this.

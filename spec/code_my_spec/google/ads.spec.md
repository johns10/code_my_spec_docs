# CodeMySpec.Google.Ads

Hand-written Req client for the Google Ads API (REST/GAQL), modeled on CodeMySpec.Google.Ga4 / Gsc. Read fns issue GAQL queries via customers/{id}/googleAds:search; write fns issue :mutate operations. Each public fn maps 1:1 to a tool and returns {:ok, data}/{:error, reason}. Requires a server-side developer token (GOOGLE_ADS_DEVELOPER_TOKEN) that is never returned to the agent; supports login-customer-id for manager (MCC) accounts.

## Type

module

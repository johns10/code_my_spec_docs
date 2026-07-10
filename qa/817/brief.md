# Qa Story Brief

## Tool

mcp (hosted MCP server at http://127.0.0.1:4000/mcp/google-ads) for tool-surface scenarios; source inspection for static invariants

## Auth

The Google Ads MCP server is on the `:mcp_protected` pipeline (OAuth bearer). To reach it live:
1. Obtain an OAuth access token for qa@codemyspec.local via the hosted OAuth flow at http://127.0.0.1:4000/oauth/authorize (requires Cloudflare tunnel up for discovery redirect)
2. Include: `Authorization: Bearer <access_token>`

The Anubis Streamable HTTP transport returns 202 for tool calls — cannot use plain curl for tool invocation (confirmed per QA plan). Use the MCP client tools (`mcp__plugin_codemyspec__*` if available for the hosted server) or note the constraint.

For source-verification of static invariants (6600, 6602): inspect `lib/code_my_spec/mcp_servers/google_tools.ex` directly — the error strings are statically defined.

## Seeds

No seeds available for Google Ads integration state. The `Fixtures.google_integration_fixture` used by the spex is an in-process DB fixture (not a seed script). For live QA, a real Google OAuth token connected to a Google Ads account would be needed.

Run base seeds to ensure QA user exists:
```
mix run priv/repo/qa_seeds.exs
```

QA user credentials: `qa@codemyspec.local` / `qa-password-123!`

## What To Test

### Criterion 6597: Campaign performance returned without approval step
- Surface: `get_campaign_performance` MCP tool (hosted at `4000/mcp/google-ads`)
- Requires: connected Google integration + GOOGLE_ADS_DEVELOPER_TOKEN in server env + live API or cassette
- **Blocked**: requires Google OAuth token + dev token; Anubis SSE transport not curl-testable
- Source check: `GetCampaignPerformance.execute/2` uses `with {:ok, {_scope, token}} <- GoogleTools.resolve(...)` — no approval gate in code path

### Criterion 6598: Approved budget change written to account
- Surface: `update_campaign_budget` MCP tool
- **Blocked**: same as 6597; additionally requires a real campaign budget ID

### Criterion 6599: Queries use authenticated user's own Google credentials
- Surface: `get_account_overview` MCP tool
- **Blocked**: requires connected Google integration; per-tenant isolation is enforced by `GoogleTools.resolve/2` reading the token from `scope.user` — verifiable by source

### Criterion 6600: Tool responses never include developer token
- Surface: any read tool response text
- **Static invariant**: `GoogleTools.ok/2` and `GoogleTools.error/1` format responses from API data only; the developer token is set via `Application.get_env(:code_my_spec, Ads, developer_token: ...)` and is passed only as an HTTP header to Google — it never enters the response formatting path
- Source check: `lib/code_my_spec/mcp_servers/google_tools.ex` + tool response formatters

### Criterion 6601: Manager account query targets chosen customer
- Surface: `get_campaign_performance` with `login_customer_id` param
- **Blocked**: requires live Google Ads manager account

### Criterion 6602: Unconnected account prompts user to connect Google
- Surface: any tool call when user has no Google integration
- **Static invariant verifiable**: `GoogleTools.error(:not_found)` returns `"Google integration not found for this user."` — contains "Google" and "not found" matching criterion 6602 spex assertions
- **Live test blocked**: MCP SSE transport not curl-testable; OAuth bearer needed to even reach the endpoint

### Criterion 6603: Quota error surfaces API's message
- Surface: `get_campaign_performance` returning 403
- **Blocked**: requires cassette replay or live quota error

## Setup Notes

All 7 criteria are covered by the in-process spex suite using ReqCassette replay — no live Google API calls are needed for the spex. For live QA, the complete blocker stack is:
1. Anubis Streamable HTTP (no synchronous curl for tool calls — per QA plan)
2. OAuth bearer requirement (`:mcp_protected` pipeline — needs Cloudflare tunnel)
3. Google integration DB record (not seedable without mix or a real OAuth flow)
4. GOOGLE_ADS_DEVELOPER_TOKEN env var in the running server

Static invariants (6600, 6602 error text) are verifiable by source inspection and match the spex assertions.

## Result Path

`.code_my_spec/qa/817/`

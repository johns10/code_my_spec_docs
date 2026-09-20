# Session Recording Tool (Microsoft Clarity)

**Priority:** High (P2 — cheap, fast insight)
**Area:** Site-wide
**Status:** Shipped 2026-09-12 (project ID `yh6jiq45zb`)
**Source:** CRO diagnostic (Amplified Growth, 2026-08-01), FIX007

## Shipped

- `envs/prod.env` — `CLARITY_PROJECT_ID` (prod only, per Locked Decision 3).
- `config/runtime.exs` — `:code_my_spec, :clarity_project_id`.
- `root.html.heex` — deferred-load script block, same first-interaction/idle
  pattern as `gtag.js`, no register-page eager carve-out (nothing downstream
  depends on Clarity loading early, unlike the `GaClientId` cookie stitch).
- `csp.ex` — added `https://www.clarity.ms` to `script-src`,
  `https://*.clarity.ms` to `connect-src` (Clarity's data collection rotates
  across regional subdomains), and `data:` to `font-src` (Clarity injects
  data-URI fonts as part of its instrumentation — microsoft/clarity#688).
  Without these three, the script loads but every session silently fails to
  record, with no visible error — verified against Microsoft's documented
  CSP requirements before shipping, not guessed.
- `mix compile` clean, full `test/code_my_spec_web/` suite (716 tests) green.

**Still owed (not done here):** this repo edit alone doesn't make Clarity
live — `envs/prod.env` is a local, gitignored, shared file
(`/Users/johndavenport/Documents/github/code_my_spec/envs`, symlinked into
every worktree). Prod needs `./scripts/deploy-secrets.sh prod` run before
`CLARITY_PROJECT_ID` reaches the running server, same as the GA4 secret
rollout pattern. Confirm first sessions appear in the Clarity dashboard
within ~24h of that deploy.

## Why This Exists

No session recording or heatmap tool exists anywhere on the site. At current
traffic volume, there isn't enough signal for statistically valid A/B
testing — qualitative research is the highest-leverage optimization input
available right now (this is also why FIX014, qualitative research rhythm,
matters). Microsoft Clarity is free, has no sampling limit at this traffic
level, and typically surfaces 2-3 real friction points per hour of review.

## Locked Decisions

1. Microsoft Clarity, not Hotjar — free with no session cap fits current
   traffic; revisit only if the free tier becomes limiting.
2. Load it the same way `gtag.js` is currently handled — deferred to first
   interaction / idle, not render-blocking. The 2026-07-10 TBT audit that
   deferred `gtag.js` applies equally here; don't reintroduce the performance
   cost this project already decided to avoid.
3. Prod only, or all environments? Default to prod-only (mirror however
   `GA4_MEASUREMENT_ID` env-gating already works) unless there's a reason to
   want dev/staging session replay too.

## User Stories

### Story 1: Real sessions are recorded for review

**As** the person running this CRO effort,
**I want** to watch real visitor sessions,
**So that** I can see friction points analytics can't show me.

**Acceptance criteria:**
- Given the Clarity script is installed on prod
- When a visitor completes a session
- Then that session is available for playback in the Clarity dashboard
- And the script does not block or measurably delay page render (verify
  against whatever performance baseline the July TBT audit established)

## Definition of Done

- Clarity project created, script installed, first real sessions visible in
  the dashboard within 24 hours of deploy.

# Story 1117 QA Result (third pass, 4e57ebff8)

## Status
partial

## Scenarios
- 2126/2138 shared machine tunnel, distinct hosts per copy: pass. One cloudflared (pid 52459); 7bd818cc, 3d7fe72b, c8eda3e8 hosts 200.
- 2127/2142 stray connectors / retired: pass. No math_test cloudflared; Math Test and Cleaner CRM hosts do not resolve (000).
- 2130 dev OAuth callback route: pass. dev.codemyspec.com 200, /auth/github/callback 302.
- 2131 astralbi.com: pass, 200.
- 2133/2139 unshare_copy_app: pass. "No longer shared."; own host 404; others, dev, astralbi 200 (responses/unshare.txt).
- 2132 share_copy_app: pass. "Shared at https://preview-7bd818cc-...", idempotent on second call; host 200; dev 200 (responses/share.txt).
- 2134/2141 harness restart, 2135 cloud copy, 2136/2137 offboarding, 2140 app-stopped refusal: not testable (no restart/kill/offboard/cloud access for QA).

## Evidence
responses/unshare.txt, responses/share.txt

## Issues
- LOW qa 4fa75920: untestable criteria; preview-9f77b922 returns 503.

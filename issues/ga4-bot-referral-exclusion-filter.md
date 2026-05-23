# Ship GA4 referral-exclusion filter for `(not set)` bot traffic

Filed 2026-05-22. Originally surfaced as a 4/30 backlog item; bot share has now doubled and the filter is structurally distorting every funnel ratio.

## Problem

`(not set) / (not set)` sessions on `codemyspec.com` are bot or unattributed traffic with 0% engagement rate. They distort every prod funnel ratio because they're indistinguishable from real sessions in aggregate reports.

### Trend

| Window | (not set) sessions | % of prod | Engagement |
|---|---|---|---|
| 5/14–5/20 (7 days) | 45 | 8% | 0% |
| 5/21 (1 day) | 31 | 27% | 0% |

Bot share **more than 3x'd** between the 7-day and 1-day windows. If 5/22+ holds at ~30% bot share, every "engagement collapsed from 68% to 36%" finding in the daily snapshot needs a bot-corrected reading, and that's not sustainable manually.

### What the bot referrer breakdown shows

`pageReferrer` for `(not set)` source sessions on 5/21:

| Referrer | Sessions |
|---|---|
| (empty) | 16 |
| https://www.reddit.com/ | 10 |
| https://codemyspec.com/* | 5 |
| https://accounts.google.com/ | 1 |

- The **16 empty-referrer sessions** are classic bot signature (HEAD requests, no Referer header, no User-Agent diversity).
- The **10 reddit.com sessions** are Reddit-pattern visitors where the source param got stripped (probably scrapers crawling Reddit's outgoing-link metadata, or Reddit mobile app users with truncated referrers).
- The **5 self-referrals** are session restarts inside the site, not bots; they should attribute to whatever the prior session source was.

## Why it matters

1. **Funnel ratios mislead.** "Engagement dropped to 36%" reads as a content/traffic-quality problem when ~27% of the input is 0%-engagement bots. The real (non-bot) engagement rate is closer to 50%.
2. **Source attribution erodes.** Reddit sessions getting bucketed as `(not set)` underreport the channel's true contribution. Today's snapshot shows Reddit at 61% of prod traffic; correcting the 10 reddit.com `(not set)` sessions would push that to ~70%.
3. **Bot share is structural, not transient.** A 3x jump in one week, with 5/22 still in progress, is worth fixing before more snapshots get distorted.

## Acceptance criteria

In GA4 admin (`https://analytics.google.com/analytics/web/#/`, property `508773792`, **Admin → Data Streams → [Web stream] → Configure tag settings → Show all → List unwanted referrals**):

1. **Add a referral-exclusion entry for empty referrers** — GA4 doesn't have a first-class "exclude no-referrer" rule, but verify it does or doesn't filter `(direct)` from `(not set)` correctly. The empty-referrer 16 sessions might need a server-side fix (next item).
2. **Add `reddit.com` to the list of unwanted referrals** — for the 10 reddit-stripped sessions. This forces them into the proper Reddit attribution rather than `(not set)`. Verify this doesn't break the existing `reddit.com/referral` bucket — the goal is to consolidate, not double-bucket. **Test on a non-production property first if uncertain.**
3. **Add a server-side bot filter** (optional, follow-up if the GA4 admin fix doesn't reduce bot share by >20pp): drop GA4 events from requests with empty User-Agent or matching the IAB bot list. Phoenix has plugs for this; can be a 20-line middleware on the analytics-collection path.
4. **Verify with a 7-day re-pull**: after 7 days of the filter being live, the `(not set)` source bucket should drop from 27% to <10% (closer to the pre-5/14 baseline). If it doesn't, the filter isn't catching the right patterns and needs follow-up.

## Out of scope

- The hardcoded `gtag('config', 'G-EHBYEW52MM')` in `lib/code_my_spec_web/components/layouts/root.html.heex:83` — separate engineering ticket (env-aware measurement ID per environment). That fix removes dev-localhost pollution from the prod property, which is a different issue from bot/(not set) noise.
- Custom-dimension registration for install events — separate ticket (`ga4-register-custom-dimensions.md`).

## Reference

- Daily snapshot 2026-05-22, section "Source mix (prod-only)" and the (not set) referrer breakdown.
- Original 4/30 backlog mention (referenced in `analytics-snapshot-2026-05-21.md`).

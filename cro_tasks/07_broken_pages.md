# CRO Task 07: Fix Broken Nav Pages and Footer Links

**Priority:** Critical
**Area:** Site-wide — navigation dead ends
**Status:** Todo

## Problem

Several pages linked from the footer crash or don't exist on dev:

- `/case-study` — crashes. No case study page exists yet. Should link to metric flow case study.
- `/about` — crashes. Should be a content page at `/pages/about`. Content is there on prod, fix link
- `/founder-story` — crashes. Should be a content page at `/pages/founder-story`.

## Fix

### Immediate (footer cleanup)

Remove links to pages that don't exist yet:
- Change **About** link to point to `/pages/about` (then create the content page)
- Change **Founder Story** link to point to `/pages/founder-story` (then create the content page)

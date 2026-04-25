# CRO Task 11: Footer Link Audit and Cleanup

**Priority:** Medium
**Area:** Site-wide — footer
**Status:** Todo

## Problem

The footer has links organized into four columns, but several point to broken or empty pages. The footer is visible on every page and sets expectations about the site's completeness.

Current footer structure:

```
Product          Content           Legal              Connect
Methodology      Blog              Privacy Policy     GitHub
Case Study       Documentation     Terms of Service   LinkedIn
Get Started      Pages                                X / Twitter
                 Founder Story                        YouTube
                 About
```

## What to Change

### Remove or redirect broken links (immediate)

Until the pages exist, remove these from the footer:
- **Case Study** — crashes (task 07)
- **About** — crashes (task 07)
- **Founder Story** — crashes (task 07)
- **Pages** — empty ("No pages yet")
- **Documentation** — empty ("No documentation yet")

### Keep these (they work):
- Methodology — works, strong page
- Get Started — works (goes to register)
- Blog — works (has at least one post)
- Privacy Policy / Terms of Service — verify these work
- GitHub / LinkedIn / X / YouTube — external links, verify URLs are correct

### Reorganized footer (after broken pages are fixed)

```
Product              Learn                 Legal              Connect
Methodology          Blog                  Privacy Policy     GitHub
Case Study           Documentation         Terms of Service   LinkedIn
Get Started          Founder Story                            X / Twitter
```

- Rename "Content" to "Learn" — more purposeful
- Drop "Pages" from the footer (it's a content type index, not a destination)
- Drop "About" — "Founder Story" serves the same purpose for this stage
- Drop YouTube unless there's content there

## Why This Matters

A footer full of broken links tells a P1 visitor "this isn't ready." The footer should reflect what actually exists. Fewer working links > more broken ones.

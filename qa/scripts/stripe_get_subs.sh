#!/usr/bin/env bash
# QA helper: list a Stripe customer's subscriptions via the real API.
# Usage: stripe_get_subs.sh <customer_id>
set -euo pipefail
cd "$(dirname "$0")/../../.."
SK=$(grep '^STRIPE_SECRET_KEY=' envs/dev.env | cut -d= -f2-)
CUSTOMER="$1"
curl -s -u "${SK}:" "https://api.stripe.com/v1/customers/${CUSTOMER}/subscriptions"

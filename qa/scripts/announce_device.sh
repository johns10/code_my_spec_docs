#!/usr/bin/env bash
#
# Announce a device, the way a `cms harness` does when it comes up.
#
# This is the real production route — `POST /api/devices`, the same call
# `CmsHarness.Device.announce/0` makes — not a fixture and not a back door. QA
# needs to make machines appear and watch them come up, and starting a real
# harness process per machine is both slow and impossible to do twice on one
# box: a harness holds a working-copy lease, so two of them on one checkout
# refuse each other.
#
# The credential is a project deploy key, which is what a sprite holds. That is
# the honest thing for a machine to authenticate with — a machine has no
# signed-in user.
#
# Usage:
#   announce_device.sh <deploy-key> [--id <device-id>] [--hostname NAME] [--kind local|cloud]
#
#   --id        present an identity the machine already holds. Omit on a
#               machine's first ever announce; pass it to prove a restart is
#               recognised rather than duplicated.
#   --hostname  what the box calls itself. Display only.
#   --kind      local (someone's machine) or cloud (a provisioned sprite).
#               Omit entirely to exercise a machine that says neither, which
#               must read as unknown rather than as a laptop.
#
# Examples:
#   announce_device.sh "$KEY" --hostname qa-laptop --kind local
#   announce_device.sh "$KEY" --hostname qa-sprite --kind cloud
#   announce_device.sh "$KEY" --id 1f2e... --hostname qa-laptop --kind local
#   announce_device.sh "$KEY" --hostname qa-mystery-box
#
# Prints the JSON reply, which carries device_id.

set -euo pipefail

BASE_URL="${CMS_BASE_URL:-http://localhost:4000}"

if [ $# -lt 1 ]; then
  sed -n '2,32p' "$0" | sed 's/^# \{0,1\}//'
  exit 64
fi

key="$1"
shift

body='{}'

while [ $# -gt 0 ]; do
  case "$1" in
    --id)       body=$(printf '%s' "$body" | jq --arg v "$2" '.device_id = $v'); shift 2 ;;
    --hostname) body=$(printf '%s' "$body" | jq --arg v "$2" '.hostname  = $v'); shift 2 ;;
    --kind)     body=$(printf '%s' "$body" | jq --arg v "$2" '.kind      = $v'); shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 64 ;;
  esac
done

curl -sS -X POST "$BASE_URL/api/devices" \
  -H "authorization: Bearer $key" \
  -H "content-type: application/json" \
  -d "$body"

echo

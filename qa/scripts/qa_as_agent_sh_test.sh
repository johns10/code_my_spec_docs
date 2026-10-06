#!/usr/bin/env bash
#
# qa_as_agent.sh must surface the server's own answer when it declines to open
# a session, rather than guessing "is the harness up?".
#
# Issue e6b4792b. The server's documented contract (see Plugs.AgentScope and the
# /mcp endpoint) is to answer an initialize that names no working copy with a
# JSON-RPC error whose body says exactly that:
#
#   code -32000: This request does not say which working copy it is about.
#   The MCP server is addressed as /mcp?harness=<id> or by X-Harness-Id; the
#   plugin sends ${CMS_HARNESS_ID}, which mix cms.harness.onboard sets in the
#   checkout's .claude/settings.local.json.
#
# No mcp-session-id is issued because the server declined the session. That is
# the contract, not a fault. The script used to discard that body and print
# "no mcp-session-id ... is the harness up?", which points the reader at
# liveness — the one thing that was never wrong (the harness was up; the
# checkout was simply never onboarded).
#
# This test stubs the server with python3's http.server, so it needs no harness,
# no database and no network beyond loopback.
#
# Run:  bash .code_my_spec/qa/scripts/qa_as_agent_sh_test.sh
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT="$SCRIPT_DIR/qa_as_agent.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "ok - $*"; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"; [ -n "${SRV_PID:-}" ] && kill "$SRV_PID" 2>/dev/null' EXIT

# A checkout the script accepts: it only reads harness_id out of this file.
WT="$TMP/wt"
mkdir -p "$WT"
printf '{"harness_id":"test-harness-id"}\n' > "$WT/.cms_harness.json"

PORT=$(python3 - <<'PY'
import socket
s = socket.socket()
s.bind(("127.0.0.1", 0))
print(s.getsockname()[1])
s.close()
PY
)

# The server's real answer to an initialize that names no working copy:
# HTTP 200, a JSON-RPC error object, and NO mcp-session-id header.
python3 - "$PORT" > "$TMP/server.log" 2>&1 <<'PY' &
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

BODY = (
    '{"jsonrpc":"2.0","id":1,"error":{"code":-32000,'
    '"message":"This request does not say which working copy it is about. '
    'The MCP server is addressed as /mcp?harness=<id> or by X-Harness-Id; the '
    'plugin sends ${CMS_HARNESS_ID}, which mix cms.harness.onboard sets in the '
    "checkout's .claude/settings.local.json.\"}}"
)

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        self.rfile.read(length)
        payload = BODY.encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, *args):
        pass

HTTPServer(("127.0.0.1", int(sys.argv[1])), Handler).serve_forever()
PY
SRV_PID=$!

# Wait for the stub to answer before running the script against it.
for _ in $(seq 1 50); do
  if curl -s -o /dev/null -X POST "http://127.0.0.1:$PORT/" -d '{}'; then break; fi
  sleep 0.1
done

out=$(QA_WORKTREE="$WT" CMS_MCP_URL="http://127.0.0.1:$PORT/mcp" \
      bash "$SCRIPT" some-agent-id list_tasks '{}' 2>&1)
status=$?

[ "$status" -ne 0 ] || fail "expected a non-zero exit when the server declines a session"

# The server's own explanation must reach the reader.
echo "$out" | grep -q "does not say which working copy" ||
  fail "the server's answer was not surfaced; got: $out"

echo "$out" | grep -q -- "-32000" ||
  fail "the JSON-RPC error code was not surfaced; got: $out"

# And the misleading liveness guess must be gone.
if echo "$out" | grep -q "is the harness up?"; then
  fail "the script still guesses 'is the harness up?' instead of reporting the server's answer: $out"
fi

pass "the server's own decline is surfaced verbatim"

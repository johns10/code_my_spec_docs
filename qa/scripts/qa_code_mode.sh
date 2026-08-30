#!/usr/bin/env bash
# QA for story 970 — code mode over the real MCP endpoint.
#
# Drives the same door an agent comes through: JSON-RPC over HTTP on the local
# dev port, scoped by harness id. Not ExUnit — the unit tests call execute/2
# directly and would not catch a registration, transport or handshake problem.
set -uo pipefail

WT="${1:-/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator}"
URL="${CMS_MCP_URL:-http://localhost:4004/mcp}"
HID=$(python3 -c "import json;print(json.load(open('$WT/.cms_harness.json'))['harness_id'])")
TMP=$(mktemp -d)

hdr=(-H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -H "X-Harness-Id: $HID")

curl -s -X POST "$URL" "${hdr[@]}" -D "$TMP/h" -o /dev/null \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"qa","version":"1"}}}'
SID=$(grep -i '^mcp-session-id:' "$TMP/h" | tr -d '\r' | cut -d' ' -f2)

# The step that is easy to miss: without it every call answers
# "Server not initialized", which reads like a broken tool.
curl -s -X POST "$URL" "${hdr[@]}" -H "Mcp-Session-Id: $SID" -o /dev/null \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized"}'

call() {
  curl -s -X POST "$URL" "${hdr[@]}" -H "Mcp-Session-Id: $SID" -d "$1" |
    python3 -c "
import sys, json, re
raw = sys.stdin.read()
m = re.search(r'^data: (.*)\$', raw, re.M)
if not m:
    print('NO_DATA ' + raw[:200]); raise SystemExit
d = json.loads(m.group(1))
if 'error' in d:
    print('RPC_ERROR ' + json.dumps(d['error'])[:200]); raise SystemExit
r = d['result']
print(('ERR ' if r.get('isError') else 'OK  ') + r['content'][0]['text'].replace(chr(10), ' | ')[:400])
"
}

script() { call "$(python3 -c "
import json,sys
print(json.dumps({'jsonrpc':'2.0','id':9,'method':'tools/call',
  'params':{'name':'run_script','arguments':{'script':sys.argv[1]}}}))" "$1")"; }

docs() { call "$(python3 -c "
import json,sys
args = json.loads(sys.argv[1])
print(json.dumps({'jsonrpc':'2.0','id':9,'method':'tools/call',
  'params':{'name':'tool_docs','arguments':args}}))" "$1")"; }

echo "### documentation on demand"
echo -n "index size          : "
call '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"tool_docs","arguments":{}}}' |
  head -c 80; echo
echo -n "one tool by name    : "; docs '{"name":"get_story"}'
echo -n "search              : "; docs '{"search":"epic"}'
echo -n "near miss           : "; docs '{"name":"get_stories"}'

echo
echo "### scripts call real tools"
echo -n "real tool           : "; script 'return list_story_titles()'
echo -n "print captured      : "; script 'print("one") print("two") return "done"'
echo -n "several in one call : "; script 'local t = list_story_titles() print("listed") return "ok:" .. tostring(t ~= nil)'

echo
echo "### what a script cannot do"
echo -n "os.execute          : "; script 'local _, e = pcall(os.execute, "echo pwned") return e'
echo -n "io.open             : "; script 'local _, e = pcall(io.open, "/etc/passwd", "r") return e'
echo -n "endless loop        : "; script 'while true do end'
echo -n "server still serving: "; script 'return "still here"'
echo -n "string bomb         : "; script 'return string.rep("x", 100000000)'
echo -n "ask_user            : "; script 'return ask_user({ question = "hi" })'
echo -n "start_agent loop    : "; script 'for i = 1, 20 do start_agent({ agent_type = "x" }) end return "spawned"'
echo -n "nested run_script   : "; script 'return run_script({ script = "return 1" })'

echo
echo "### partial failure"
echo -n "3 land, 4th fails   : "
script 'for _, t in ipairs({"QA one","QA two","QA three"}) do create_story({ title = t, story = "As an agent, I want " .. t .. "." }) end
local bad, err = create_story({})
if bad == nil then return "fourth failed: " .. err.message end
return "fourth unexpectedly worked"'
echo -n "first three present : "; script 'return list_story_titles()'

rm -rf "$TMP"

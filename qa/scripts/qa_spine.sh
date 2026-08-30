#!/usr/bin/env bash
# QA for story 971 — the tool list an agent connects with.
#
# The subject is tools/list itself, so this drives the real MCP endpoint. No
# ExUnit equivalent: the suite can count registrations, but only a real
# handshake shows what an agent is actually handed.
set -uo pipefail

WT="${1:-/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator}"
URL="${CMS_MCP_URL:-http://localhost:4004/mcp}"
HID=$(python3 -c "import json;print(json.load(open('$WT/.cms_harness.json'))['harness_id'])")
TMP=$(mktemp -d)

hdr=(-H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -H "X-Harness-Id: $HID")

curl -s -X POST "$URL" "${hdr[@]}" -D "$TMP/h" -o /dev/null \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"qa","version":"1"}}}'
SID=$(grep -i '^mcp-session-id:' "$TMP/h" | tr -d '\r' | cut -d' ' -f2)

curl -s -X POST "$URL" "${hdr[@]}" -H "Mcp-Session-Id: $SID" -o /dev/null \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized"}'

post() { curl -s -X POST "$URL" "${hdr[@]}" -H "Mcp-Session-Id: $SID" -d "$1"; }

echo "### the list an agent is handed"
post '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | python3 -c "
import sys, json, re
d = json.loads(re.search(r'^data: (.*)\$', sys.stdin.read(), re.M).group(1))
tools = d['result']['tools']
names = sorted(t['name'] for t in tools)
size = len(json.dumps(tools))
print(f'  tools      {len(tools)}')
print(f'  payload    {size:,} B   (~{size//4:,} tokens, was 82,591 B / ~20,600)')
print(f'  saving     {100 - size*100//82591}%')
print('  names      ' + ', '.join(names))
for want in ['run_script','tool_docs','get_next_requirement','start_task','evaluate_task','sync_project']:
    print(f'  spine {want:22} {\"present\" if want in names else \"MISSING\"}')
for excluded in ['ask_user','start_agent','tap_out','show_in_panel','stop_agent']:
    print(f'  excluded-but-listed {excluded:14} {\"present\" if excluded in names else \"MISSING - unreachable!\"}')
for moved in ['list_stories','create_story','submit_qa_result']:
    print(f'  moved off the list  {moved:14} {\"still listed!\" if moved in names else \"gone\"}')
"

call() {
  post "$1" | python3 -c "
import sys, json, re
raw = sys.stdin.read()
m = re.search(r'^data: (.*)\$', raw, re.M)
d = json.loads(m.group(1))
if 'error' in d:
    print('RPC_ERROR ' + json.dumps(d['error'])[:160]); raise SystemExit
r = d['result']
print(('ERR ' if r.get('isError') else 'OK  ') + r['content'][0]['text'].replace(chr(10),' | ')[:280])
"
}

echo
echo "### a moved tool is still reachable"
echo -n "  via run_script      : "
call '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"run_script","arguments":{"script":"local n = 0\nfor _ in ipairs(list_story_titles()) do n = n + 1 end\nreturn n"}}}'

echo
echo "### a client holding the old list"
echo -n "  calls a moved tool  : "
call '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"list_stories","arguments":{}}}'
echo -n "  calls a typo        : "
call '{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"list_storeis","arguments":{}}}'

echo
echo "### the index did not absorb the cost"
echo -n "  tool_docs index     : "
post '{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"tool_docs","arguments":{}}}' | python3 -c "
import sys, json, re
d = json.loads(re.search(r'^data: (.*)\$', sys.stdin.read(), re.M).group(1))
t = d['result']['content'][0]['text']
print(f'{len(t):,} B, fetched on demand rather than carried at connect')
"

rm -rf "$TMP"

# Story 1117 QA Brief (re-run at b901d5706)

## Tool

curl plus ps/dig/cat on ~/.codemyspec/tunnels; share_copy_app/unshare_copy_app via run_script

## Auth

None; public preview hostnames. Own instance http://127.0.0.1:60584.

## Seeds

None. Live copies: 7bd818cc, 9f77b922, 3d7fe72b, c8eda3e8 (Broken Oaths main). No Cloudflare deletions, no kills.

## What To Test

- curl dev.codemyspec.com, astralbi.com, each copy preview host (2126, 2131, 2132, 2133, 2135, 2138).
- ps for cloudflared connectors; retired Math Test/Cleaner CRM hosts (2127, 2142).
- dev OAuth callback route answers (2130).
- share/unshare own copy 7bd818cc (2132, 2133, 2139): unshare, curl all hosts, share, curl; leave shared.

## Result Path

.code_my_spec/qa/1117/result.md

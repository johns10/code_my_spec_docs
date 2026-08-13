# QA Brief — Story 727: Agents working the same project do not collide

## Tool

web

Plus `psql` against `code_my_spec_dev`. This story is about which rows belong to
which agent, and most of its claims are only visible in the data — a page can
render correctly while the rows underneath are shared.

## Auth

Passwordless. Clear cookies first: the login form doubles as the reauthenticate
form, so a fill on a live session silently keeps the current user's address.

```
vibium cookies clear
vibium go "http://localhost:4000/users/log-in"
vibium fill "input[name='user[email]']" "qa990-final-1785773065@example.com"
vibium click "form button"
```

`/dev/mailbox` is one shared inbox for every agent on this server, so confirm
the recipient before following a link:

```
ID=$(curl -s http://localhost:4000/dev/mailbox | grep -oE '/dev/mailbox/[a-f0-9]{32}' | head -1)
curl -s "http://localhost:4000$ID" | grep -oE 'qa[^< ]*@[^< ]*' | sort -u
```

**Account limitation.** The agent-facing pages for this story (`/files`,
`/problems`, and the harness picker) live on the CodeMySpec project itself,
`708492f9-454e-482f-a2eb-be64f0356b87`, which the QA user does not own — it
renders "No projects yet." Criteria that need those pages require the owner
account, which a QA agent cannot assume on its own.

## Seeds

No seed script. This story needs several agents on one project, which this
machine already has for real — five harnesses on `708492f9`, three of them
reporting today. That is a better fixture than anything seeded, because the
collisions it is about only appear across genuinely separate working copies.

```
psql -d code_my_spec_dev -tA -F'|' -c "
select h.id, h.root, count(f.id) from harnesses h
left join files f on f.harness_id = h.id
where h.project_id='708492f9-454e-482f-a2eb-be64f0356b87'
group by h.id, h.root order by 3 desc;"
```

## What To Test

- **Two agents report separate file state (732).** Group `files` by
  `harness_id` for one project and confirm the counts differ per agent. Then
  check the grain of the other two projections named in the story: `problems`
  carries `harness_id`, `components` does not.
- **Identity is not derived from the path (733).** Find a `root` with more than
  one harness row. Two ids on one path is the property the story chose
  server-issued identity to get.
- **A restarted agent resumes its own state (735).** Read `.cms_harness.json`
  in a checkout, confirm it holds the id the live harness uses, then start a
  second harness process on the same checkout and confirm no new harness row
  appears — it must adopt the persisted id.
- **A second agent on a served copy is refused (744).** Note that starting a
  second *process* on the same checkout does not test this: it reads the same
  `.cms_harness.json` and is the same agent. Reaching this needs an agent with
  no stored identity on a copy already served, which overlaps 736.
- **The operator picks whose state to look at (739).** `/files` and
  `/problems` on the owning account; the component is
  `lib/code_my_spec_web/components/harness_picker.ex`.
- **A story written by one agent is visible to another (734).** Authored data
  is meant to stay project-scoped — create a story from one agent's session and
  read it from another's.
- **Human edits inside and outside a workspace (740, 741).** Touch a file
  inside a served working copy and confirm it is attributed to that agent;
  touch one outside every workspace and confirm no file state appears.

## Result Path

DB-backed attempt via `submit_qa_result`. No result.md.

## Setup Notes

Two traps specific to this story.

A harness with no credential now refuses to start rather than binding a port —
"Not starting. A listening port that refuses every hook is harder to diagnose
than a process that did not come up." If a harness you start dies immediately,
read the message before assuming a lease refused it; the credential must be
exported, since `envs/.env` is loaded by Dotenvy for `env!/2` and never reaches
`System.get_env`.

And the analyzer runs under its own test partition — `TestDatabase.partition_for/2`
digests the cwd and appends `s` for spex. A database migrated for interactive
use is not the one the analyzer checks.

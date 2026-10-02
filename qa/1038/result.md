# Qa Result

## Status

pass

Tested against harness/server build `daf8907a`, through
`http://localhost:4004/mcp` with this worktree's harness id, plus `psql` on
`code_my_spec_dev` for what was recorded. Every agent below was started for
real and stopped; the one still `running` at the end
(`70b93384`, on `broken_oaths`) is four days old and belongs to another
project.

## Scenarios

### what_an_agent_carries

PASS. `CmsHarness.Agents.Engine.tools/1` returns six modules — `Alloy.Tool.Core.{Read,Write,Edit,Bash}`, `RunScript`, `ToolDocs` — and takes no
argument it uses, so neither the role nor the machine can grow it. A QA agent
whose *scope* is 114 names carries six tools, and the story's central claim is
that gap.

Checked live rather than only in the source, because a constant naming six
modules is true of the constant: a fresh QA agent (`335a7fcc`) held zero
browser tools on its Alloy list while its machine offered eighty-five.

### scope_is_a_list_not_a_role

PASS. `agents.tools` for the QA agent: 114 entries, of which 85 are exactly the
contents of `working_copies.machine_tools` for the copy it started on, and 29
are the role's. Not null, not a role name — a column you can read.

The 29 is the pre-fix number. Two of them named nothing (below); on
`acb6009f` the same agent scopes 112.

### main_is_unscoped

PASS. A `main` agent (`b6a637b0`) has `tools IS NULL`. Confirmed that is the
column's "everything" rather than a bug by calling the tool the QA agent was
refused:

    delete_story { story_id = "99999" }
    -> "Story not found. Verify the story ID exists using list_stories."

It reached the tool and the tool answered. The scoping is a real boundary, not
a global block that happens to be on.

### a_script_reaches_what_the_agent_does_not_carry

PASS. One script, both halves of the catalogue:

    local u = browser_get_url({})
    local s = list_stories({ limit = 2 })
    -> "browser says about:blank and list_stories returned a string"

`browser_get_url` is vibium's, reached server catalogue → channel → stdio →
vibium and back. `list_stories` is ours. Neither is on the agent.

Ten calls in one invocation returned ten answers, one round trip.

### scoping_refuses_with_teeth

PASS. As a `qa` agent, from inside a script:

    delete_story { story_id = "985" }
    -> "delete_story is not a tool a qa agent carries. It exists, and this
        kind of agent is not given it — asking again with a different
        spelling will not help."

Story 985 was still there afterwards. A refusal that arrives after the delete
is not a refusal, so this was checked rather than assumed.

Cross-project: a story belonging to another project came back "Story not
found." — the same words as a story that does not exist, naming neither the
story nor the project.

### the_browser_costs_nothing

PASS. `working_copies.machine_tools` for this copy holds vibium's 85 names. The
agent's own list holds none of them. All three states of that column exist in
the dev database and are distinguishable:

    NULL (never reported)      13
    85 tools                    2
    [] (reported, no browser)   1

### create_issue_really_moved

PASS, and worth recording because it was proven by accident. Calling
`create_issue` directly is now refused:

    "create_issue is no longer called directly — it moved to code mode, along
     with most of this server's tools, so that connecting does not cost twenty
     thousand tokens of tool list."

The defect below was then filed through a script. The server offers 15 direct
tools; the other 98 are a lookup.

`ask_user` and `check_answer` are deliberately not among the scriptable ones,
and say so when tried: *"it belongs with ask_user, which a script cannot
call."*

### result_size

**FAIL.** `run_script` returning 60,000 characters came back as 60,015 bytes
with no note. `CmsHarness.Agents.Tools.RunScript` caps at 24,000 and says so;
the server tool it calls through does not, and that is the tool a Claude Code
session reaches. Agents are protected, the sessions in this project are not.

Filed `b9632bba`.

### the_sceptical_read_of_the_lists

The brief asked for this one specifically, and it was the one that found
something.

**Two granted names named nothing.** Audited every entry in
`Agents.ToolSets` against the server's own registry:

    tools the server exposes: 98
    qa:      29 granted, 2 name nothing  (list_components, sync_project)
    coding:  30 granted, 2 name nothing  (list_components, sync_project)
    product: 50 granted, 0 name nothing

Found the way it will be found in production — a script called
`list_components` and got "attempt to call a nil value", the one message the
scoping code goes out of its way not to produce because it reads as a
misspelling.

Harmless in itself: an allow-list entry that matches nothing never matches. Not
harmless to the reader, because thirty names look like thirty tools' worth of
thought. And the same silence hides the expensive version — a tool a type
needs, renamed since, which reads to the agent as a decision somebody made.

Filed `44e30f90`, fixed in `acb6009f` with a test that every granted name is a
tool the server exposes.

**Then checked the other direction — is anything missing?** Compared the QA
list against what `plugins/claude/agents/qa.md` grants the Claude Code QA
subagent. Five names are granted there and absent here:

| name | verdict |
|---|---|
| `start_task`, `evaluate_task`, `get_next_requirement`, `sync_project` | not missing — direct tools, deliberately not scriptable |
| `list_components` | exists nowhere: not scriptable, not direct, only a context function |

So no QA tool went missing in the move. `list_components` is a stale grant in
the subagent file as well; left alone, since those files are out of scope this
run.

## Issues

- `b9632bba` — new. The result cap protects agents and not Claude Code
  sessions, and is untested on either path.
- `02b03d04` — already filed. A machine with no browser and a machine whose
  browser is unreachable both record `[]`.
- `44e30f90` — already filed, and fixed in `acb6009f`.
- `ebc5586d` — already filed, out of scope here (vibium as a package
  prerequisite).

## Note For The Orchestration Story

Not a defect against 982, because 982 did not remove it: an agent started on
the machine carries six tools, none of which is `ask_user` or `tap_out`, and
`run_script` cannot reach them either. So a machine agent that hits a genuine
ambiguity has no way to ask, and no way to stop and say why. That belongs with
the orchestration work rather than here — the orchestrator drives the agent, so
it may be the right place for both — but it is worth someone deciding rather
than inheriting.
